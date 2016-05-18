From: Luca Coelho <luca-XPOmlcxoEMv1KXRcyAk9cg@public.gmane.org>
Subject: [PATCH] iwlwifi: mvm: fix merge damage in tx.c
Date: Wed, 18 May 2016 22:00:09 +0300
Message-ID: <1463598009-31865-1-git-send-email-luca@coelho.fi>
References: <1463597411.29999.16.camel@intel.com>
Cc: linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, reinoudkoornstra-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org,
	linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linuxwifi-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org,
	johannes.berg-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org, akpm-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org,
	kvalo-sgV2jX0FEOL9JmXXK+q4OQ@public.gmane.org, egrumbach-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org
To: linus-hQyY1W1yCW8ekmWlsbkhG0B+6BGkLq7r@public.gmane.org
Return-path: <linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <1463597411.29999.16.camel-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org>
Sender: linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

From: Luca Coelho <luciano.coelho-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org>

During the merge in commit 909b27f70643 ("Merge
git://git.kernel.org/pub/scm/linux/kernel/git/davem/net"), there was a
small merge damage where one instance of info was not converted into
skb_info.  Fix this.

Signed-off-by: Luca Coelho <luciano.coelho-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org>
---
 drivers/net/wireless/intel/iwlwifi/mvm/tx.c | 3 ++-
 1 file changed, 2 insertions(+), 1 deletion(-)

diff --git a/drivers/net/wireless/intel/iwlwifi/mvm/tx.c b/drivers/net/wireless/intel/iwlwifi/mvm/tx.c
index 8802109..c53aa0f 100644
--- a/drivers/net/wireless/intel/iwlwifi/mvm/tx.c
+++ b/drivers/net/wireless/intel/iwlwifi/mvm/tx.c
@@ -211,6 +211,7 @@ void iwl_mvm_set_tx_cmd(struct iwl_mvm *mvm, struct sk_buff *skb,
 			struct iwl_tx_cmd *tx_cmd,
 			struct ieee80211_tx_info *info, u8 sta_id)
 {
+	struct ieee80211_tx_info *skb_info = IEEE80211_SKB_CB(skb);
 	struct ieee80211_hdr *hdr = (void *)skb->data;
 	__le16 fc = hdr->frame_control;
 	u32 tx_flags = le32_to_cpu(tx_cmd->tx_flags);
@@ -294,7 +295,7 @@ void iwl_mvm_set_tx_cmd(struct iwl_mvm *mvm, struct sk_buff *skb,
 	tx_cmd->tx_flags = cpu_to_le32(tx_flags);
 	/* Total # bytes to be transmitted */
 	tx_cmd->len = cpu_to_le16((u16)skb->len +
-		(uintptr_t)info->driver_data[0]);
+		(uintptr_t)skb_info->driver_data[0]);
 	tx_cmd->life_time = cpu_to_le32(TX_CMD_LIFE_TIME_INFINITE);
 	tx_cmd->sta_id = sta_id;
 
-- 
2.8.1

--
To unsubscribe from this list: send the line "unsubscribe linux-wireless" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
