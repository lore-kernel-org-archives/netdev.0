From: Stephen Rothwell <sfr@canb.auug.org.au>
Subject: linux-next: manual merge of the net-next tree with the
 wireless-drivers tree
Date: Mon, 29 Feb 2016 12:56:38 +1100
Message-ID: <20160229125638.5e6f43b3@canb.auug.org.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: linux-next@vger.kernel.org, linux-kernel@vger.kernel.org,
	Matti Gottlieb <matti.gottlieb@intel.com>,
	Emmanuel Grumbach <emmanuel.grumbach@intel.com>,
	Sara Sharon <sara.sharon@intel.com>
To: David Miller <davem@davemloft.net>, <netdev@vger.kernel.org>,
	Kalle Valo <kvalo@codeaurora.org>
Return-path: <linux-next-owner@vger.kernel.org>
Sender: linux-next-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi all,

Today's linux-next merge of the net-next tree got a conflict in:

  drivers/net/wireless/intel/iwlwifi/mvm/fw.c

between commit:

  905e36ae172c ("iwlwifi: mvm: Fix paging memory leak")

from the wireless-drivers tree and commit:

  43413a975d06 ("iwlwifi: mvm: support rss queues configuration command")

from the net-next tree.

I fixed it up (see below) and can carry the fix as necessary (no action
is required).

-- 
Cheers,
Stephen Rothwell

diff --cc drivers/net/wireless/intel/iwlwifi/mvm/fw.c
index 0ccc697fef76,070e2af05ca2..000000000000
--- a/drivers/net/wireless/intel/iwlwifi/mvm/fw.c
+++ b/drivers/net/wireless/intel/iwlwifi/mvm/fw.c
@@@ -107,7 -108,25 +108,25 @@@ static int iwl_send_tx_ant_cfg(struct i
  				    sizeof(tx_ant_cmd), &tx_ant_cmd);
  }
  
+ static int iwl_send_rss_cfg_cmd(struct iwl_mvm *mvm)
+ {
+ 	int i;
+ 	struct iwl_rss_config_cmd cmd = {
+ 		.flags = cpu_to_le32(IWL_RSS_ENABLE),
+ 		.hash_mask = IWL_RSS_HASH_TYPE_IPV4_TCP |
+ 			     IWL_RSS_HASH_TYPE_IPV4_PAYLOAD |
+ 			     IWL_RSS_HASH_TYPE_IPV6_TCP |
+ 			     IWL_RSS_HASH_TYPE_IPV6_PAYLOAD,
+ 	};
+ 
+ 	for (i = 0; i < ARRAY_SIZE(cmd.indirection_table); i++)
+ 		cmd.indirection_table[i] = i % mvm->trans->num_rx_queues;
+ 	memcpy(cmd.secret_key, mvm->secret_key, ARRAY_SIZE(cmd.secret_key));
+ 
+ 	return iwl_mvm_send_cmd_pdu(mvm, RSS_CONFIG_CMD, 0, sizeof(cmd), &cmd);
+ }
+ 
 -static void iwl_free_fw_paging(struct iwl_mvm *mvm)
 +void iwl_free_fw_paging(struct iwl_mvm *mvm)
  {
  	int i;
  
