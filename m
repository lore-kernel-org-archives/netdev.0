From: Stephen Rothwell <sfr@canb.auug.org.au>
Subject: linux-next: manual merge of the net-next tree with the
 wireless-drivers tree
Date: Mon, 9 May 2016 10:39:21 +1000
Message-ID: <20160509103921.72146ce1@canb.auug.org.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: linux-next@vger.kernel.org, linux-kernel@vger.kernel.org,
	Emmanuel Grumbach <emmanuel.grumbach@intel.com>,
	Sara Sharon <sara.sharon@intel.com>
To: David Miller <davem@davemloft.net>, <netdev@vger.kernel.org>,
	Kalle Valo <kvalo@codeaurora.org>
Return-path: <linux-next-owner@vger.kernel.org>
Sender: linux-next-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi all,

Today's linux-next merge of the net-next tree got a conflict in:

  drivers/net/wireless/intel/iwlwifi/mvm/tx.c

between commit:

  5c08b0f5026f ("iwlwifi: mvm: don't override the rate with the AMSDU len")

from the wireless-drivers tree and commit:

  d8fe484470dd ("iwlwifi: mvm: add support for new TX CMD API")

from the net-next tree.

I fixed it up (see below) and can carry the fix as necessary. This
is now fixed as far as linux-next is concerned, but any non trivial
conflicts should be mentioned to your upstream maintainer when your tree
is submitted for merging.  You may also want to consider cooperating
with the maintainer of the conflicting tree to minimise any particularly
complex conflicts.

-- 
Cheers,
Stephen Rothwell

diff --cc drivers/net/wireless/intel/iwlwifi/mvm/tx.c
index 34731e29c589,bd286fca3776..000000000000
--- a/drivers/net/wireless/intel/iwlwifi/mvm/tx.c
+++ b/drivers/net/wireless/intel/iwlwifi/mvm/tx.c
@@@ -186,10 -294,16 +295,16 @@@ void iwl_mvm_set_tx_cmd(struct iwl_mvm 
  	tx_cmd->tx_flags = cpu_to_le32(tx_flags);
  	/* Total # bytes to be transmitted */
  	tx_cmd->len = cpu_to_le16((u16)skb->len +
 -		(uintptr_t)info->driver_data[0]);
 +		(uintptr_t)skb_info->driver_data[0]);
- 	tx_cmd->next_frame_len = 0;
  	tx_cmd->life_time = cpu_to_le32(TX_CMD_LIFE_TIME_INFINITE);
  	tx_cmd->sta_id = sta_id;
+ 
+ 	/* padding is inserted later in transport */
+ 	if (ieee80211_hdrlen(fc) % 4 &&
+ 	    !(tx_cmd->offload_assist & cpu_to_le16(BIT(TX_CMD_OFFLD_AMSDU))))
+ 		tx_cmd->offload_assist |= cpu_to_le16(BIT(TX_CMD_OFFLD_PAD));
+ 
+ 	iwl_mvm_tx_csum(mvm, skb, hdr, info, tx_cmd);
  }
  
  /*
