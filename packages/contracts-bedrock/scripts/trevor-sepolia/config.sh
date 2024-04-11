#!/usr/bin/env bash

# This script is used to generate the trevor-sepolia.json configuration file
# used in the "Spin up your own Trevor devnet" guide on the docs site. Avoids
# theneed to have the trevor-sepolia.json committed to the repo since it's an
# invalid JSON file when not filled in, which is annoying.

reqenv() {
  if [ -z "${!1}" ]; then
    echo "Error: environment variable '$1' is undefined"
    exit 1
  fi
}

# Check required environment variables
reqenv "TRV_ADMIN_ADDRESS"
reqenv "TRV_BATCHER_ADDRESS"
reqenv "TRV_PROPOSER_ADDRESS"
reqenv "TRV_SEQUENCER_ADDRESS"
reqenv "L1_RPC_URL"

# Get the finalized block timestamp and hash
block=$(cast block finalized --rpc-url "$L1_RPC_URL")
timestamp=$(echo "$block" | awk '/timestamp/ { print $2 }')
blockhash=$(echo "$block" | awk '/hash/ { print $2 }')

# Generate the config file
config=$(cat << EOL
{
  "l1StartingBlockTag": "$blockhash",

  "l1ChainID": 11155111,
  "l2ChainID": 689388,
  "l2BlockTime": 6,
  "l1BlockTime": 12,

  "maxSequencerDrift": 600,
  "sequencerWindowSize": 3600,
  "channelTimeout": 300,

  "p2pSequencerAddress": "$TRV_SEQUENCER_ADDRESS",
  "batchInboxAddress": "0xff00000000000000000000000000000000689388",
  "batchSenderAddress": "$TRV_BATCHER_ADDRESS",

  "l2OutputOracleSubmissionInterval": 40,
  "l2OutputOracleStartingBlockNumber": 0,
  "l2OutputOracleStartingTimestamp": $timestamp,

  "l2OutputOracleProposer": "$TRV_PROPOSER_ADDRESS",
  "l2OutputOracleChallenger": "$TRV_ADMIN_ADDRESS",

  "finalizationPeriodSeconds": 12,

  "proxyAdminOwner": "$TRV_ADMIN_ADDRESS",
  "baseFeeVaultRecipient": "$TRV_ADMIN_ADDRESS",
  "l1FeeVaultRecipient": "$TRV_ADMIN_ADDRESS",
  "sequencerFeeVaultRecipient": "$TRV_ADMIN_ADDRESS",
  "finalSystemOwner": "$TRV_ADMIN_ADDRESS",
  "superchainConfigGuardian": "$TRV_ADMIN_ADDRESS",

  "baseFeeVaultMinimumWithdrawalAmount": "0x8ac7230489e80000",
  "l1FeeVaultMinimumWithdrawalAmount": "0x8ac7230489e80000",
  "sequencerFeeVaultMinimumWithdrawalAmount": "0x8ac7230489e80000",
  "baseFeeVaultWithdrawalNetwork": 0,
  "l1FeeVaultWithdrawalNetwork": 0,
  "sequencerFeeVaultWithdrawalNetwork": 0,

  "gasPriceOracleOverhead": 2100,
  "gasPriceOracleScalar": 1000000,

  "enableGovernance": true,
  "governanceTokenSymbol": "TRV",
  "governanceTokenName": "Trevor",
  "governanceTokenOwner": "$TRV_ADMIN_ADDRESS",

  "l2GenesisBlockGasLimit": "0x1c9c380",
  "l2GenesisBlockBaseFeePerGas": "0x3b9aca00",
  "l2GenesisRegolithTimeOffset": "0x0",

  "eip1559Denominator": 50,
  "eip1559DenominatorCanyon": 250,
  "eip1559Elasticity": 6,

  "l2GenesisRegolithTimeOffset": "0x0",
  "l2GenesisDeltaTimeOffset": null,
  "l2GenesisCanyonTimeOffset": "0x0",

  "systemConfigStartBlock": 0,

  "requiredProtocolVersion": "0x0000000000000000000000000000000000000000000000000000000000000000",
  "recommendedProtocolVersion": "0x0000000000000000000000000000000000000000000000000000000000000000",

  "faultGameAbsolutePrestate": "0x03c7ae758795765c6664a5d39bf63841c71ff191e9189522bad8ebff5d4eca98",
  "faultGameMaxDepth": 44,
  "faultGameMaxDuration": 1200,
  "faultGameGenesisBlock": 0,
  "faultGameGenesisOutputRoot": "0x0000000000000000000000000000000000000000000000000000000000000000",
  "faultGameSplitDepth": 14
}
EOL
)

# Write the config file
echo "$config" > deploy-config/trevor-seplia.json
