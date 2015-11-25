From: Geliang Tang <geliangtang-9Onoh4P/yGk@public.gmane.org>
Subject: [PATCH 4/7] iwlwifi: fix a problematic usage of WARN_ON_ONCE()
Date: Wed, 25 Nov 2015 21:12:17 +0800
Message-ID: <7701ed112cc71a9a17ba5b3022166011a98d0dca.1448456395.git.geliangtang@163.com>
References: <86c73f180d3054c1bf17bdac8c89026209167c9b.1448456395.git.geliangtang@163.com>
Cc: Geliang Tang <geliangtang-9Onoh4P/yGk@public.gmane.org>, linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: Johannes Berg <johannes.berg-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org>,
	Emmanuel Grumbach <emmanuel.grumbach-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org>,
	Intel Linux Wireless <linuxwifi-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org>,
	Kalle Valo <kvalo-sgV2jX0FEOL9JmXXK+q4OQ@public.gmane.org>
Return-path: <linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <86c73f180d3054c1bf17bdac8c89026209167c9b.1448456395.git.geliangtang-9Onoh4P/yGk@public.gmane.org>
In-Reply-To: <582529c23f77af64373f59fa92e29186df700d79.1448456395.git.geliangtang-9Onoh4P/yGk@public.gmane.org>
References: <86c73f180d3054c1bf17bdac8c89026209167c9b.1448456395.git.geliangtang-9Onoh4P/yGk@public.gmane.org> <8bb789c0803579a01e1ee977ed67408c422acd79.1448456395.git.geliangtang-9Onoh4P/yGk@public.gmane.org> <582529c23f77af64373f59fa92e29186df700d79.1448456395.git.geliangtang-9Onoh4P/yGk@public.gmane.org>
Sender: linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

WARN_ON_ONCE() takes a condition rather than a format string. This
patch converted WARN_ON_ONCE() to WARN_ONCE() instead.

Signed-off-by: Geliang Tang <geliangtang-9Onoh4P/yGk@public.gmane.org>
---
 drivers/net/wireless/intel/iwlwifi/mvm/rs.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/drivers/net/wireless/intel/iwlwifi/mvm/rs.c b/drivers/net/wireless/intel/iwlwifi/mvm/rs.c
index d1ad103..58d7bee 100644
--- a/drivers/net/wireless/intel/iwlwifi/mvm/rs.c
+++ b/drivers/net/wireless/intel/iwlwifi/mvm/rs.c
@@ -1827,7 +1827,7 @@ static int rs_switch_to_column(struct iwl_mvm *mvm,
 		rate->type = lq_sta->is_vht ? LQ_VHT_MIMO2 : LQ_HT_MIMO2;
 		rate_mask = lq_sta->active_mimo2_rate;
 	} else {
-		WARN_ON_ONCE("Bad column mode");
+		WARN_ONCE(1, "Bad column mode");
 	}
 
 	if (column->mode != RS_LEGACY) {
-- 
2.5.0


--
To unsubscribe from this list: send the line "unsubscribe linux-wireless" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
