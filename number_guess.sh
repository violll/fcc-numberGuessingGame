#!/bin/bash
PSQL="psql --username=freecodecamp --dbname=number_guess -t --no-align -c"

MAIN () {
  echo "Enter your username:"
  read USERNAME

  REQ_USERNAME=$($PSQL "SELECT username FROM players WHERE username='$USERNAME'")

  if [[ -z $REQ_USERNAME ]] 
  then
    echo "Welcome, $USERNAME! It looks like this is your first time here."
    NEW_USER_RES=$($PSQL "INSERT INTO players(username) VALUES('$USERNAME')")
  else
    echo "$($PSQL "SELECT * FROM players WHERE username='$USERNAME'")" | while IFS="|" read USERNAME GAMES_PLAYED BEST_GAME
    do
      echo "Welcome back, $USERNAME! You have played $GAMES_PLAYED games, and your best game took $BEST_GAME guesses."
    done
  fi

  GAMES_PLAYED=$($PSQL "SELECT games_played FROM players WHERE username='$USERNAME'")
  BEST_GAME=$($PSQL "SELECT best_game FROM players WHERE username='$USERNAME'")

  GUESS=-1
  NUM=$(( $RANDOM%1000 + 1 ))
  COUNT=0

  echo "Guess the secret number between 1 and 1000:"
  
  while [[ $GUESS != $NUM ]]
  do
    read GUESS
    
    if [[ $GUESS =~ ^[0-9]*\.[0-9]*$ ]]
    then
      echo "That is not an integer, guess again:"
    elif ! [[ $GUESS =~ [0-9] ]]
    then
      echo "That is not an integer, guess again:"
    else
      COUNT=$(( $COUNT+1 ))

      if (( $NUM > $GUESS ))
      then
        echo "It's higher than that, guess again:"

      elif (( $NUM < $GUESS ))
      then
        echo "It's lower than that, guess again:"

      elif (( $NUM == $GUESS ))
      then
        echo "You guessed it in $COUNT tries. The secret number was $NUM. Nice job!"
      fi
    fi

  done

  UPDATE_GAMES=$($PSQL "UPDATE players SET games_played=$GAMES_PLAYED+1 WHERE username='$USERNAME'")
  
  if (( $COUNT < $BEST_GAME ))
  then
    UPDATE_BEST=$($PSQL "UPDATE players SET best_game=$COUNT WHERE username='$USERNAME'")
  fi

}

MAIN
