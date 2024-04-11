#!/bin/bash

PSQL="psql --username=freecodecamp --dbname=number_guess -t --no-align -c"
RANDOM_NUMBER=$((1 + $RANDOM % 1000))

USERNAME_PROMPT () {
  echo "Enter your username:"
  read USERNAME
  if [[ ${#USERNAME} -gt 22 ]]
  then
    echo "Please limit your name to 22 characters."
    USERNAME_PROMPT  
  else
    USERNAME_CHECK=$($PSQL "SELECT username FROM players WHERE username='$USERNAME'";)  
  fi
}
USERNAME_PROMPT
if [[ -z $USERNAME_CHECK ]]
then
  INSERT_PLAYER=$($PSQL "INSERT INTO players(username, games_played) VALUES('$USERNAME', 0);")
  USER_ID=$($PSQL "SELECT user_id FROM players WHERE username='$USERNAME';")
  GAMES_PLAYED=$($PSQL "SELECT games_played FROM players WHERE username='$USERNAME';")
  BEST_GAME=$($PSQL "SELECT MIN(guesses) FROM games WHERE user_id='$USER_ID';")
  echo "Welcome, $USERNAME! It looks like this is your first time here."
else
  USER_ID=$($PSQL "SELECT user_id FROM players WHERE username='$USERNAME';")
  GAMES_PLAYED=$($PSQL "SELECT games_played FROM players WHERE username='$USERNAME';")
  BEST_GAME=$($PSQL "SELECT MIN(guesses) FROM games WHERE user_id='$USER_ID';")
  echo Welcome back, $USERNAME! You have played $GAMES_PLAYED games, and your best game took $BEST_GAME guesses.
fi

GUESS_COUNT=0
echo "Guess the secret number between 1 and 1000:"

GUESS_LOOP () {
  ((GUESS_COUNT++))
  read GUESS
  if [[ $GUESS == $RANDOM_NUMBER ]]
  then
    echo "You guessed it in $GUESS_COUNT tries. The secret number was $RANDOM_NUMBER. Nice job!"
    INSERT_GAMES=$($PSQL "INSERT INTO games(user_id, guesses) VALUES($USER_ID, $GUESS_COUNT);")
    UPDATE_PLAYER=$($PSQL "UPDATE players SET games_played=games_played+1 WHERE user_id=$USER_ID;")
  elif [[ ! $GUESS =~ ^[0-9]+$ ]]
  then
    echo "That is not an integer, guess again:"
    GUESS_LOOP
  elif [[ $GUESS -lt $RANDOM_NUMBER ]]
  then
    echo "It's higher than that, guess again:"
    GUESS_LOOP
  else
    echo "It's lower than that, guess again:"
    GUESS_LOOP
  fi
}
GUESS_LOOP