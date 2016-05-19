From: Arnd Bergmann <arnd-r2nGTMty4D4@public.gmane.org>
Subject: [PATCH] iwlegacy: avoid warning about missing braces
Date: Thu, 19 May 2016 09:58:49 +0200
Message-ID: <1463644741-529379-1-git-send-email-arnd@arndb.de>
Cc: Arnd Bergmann <arnd-r2nGTMty4D4@public.gmane.org>,
	Johannes Berg <johannes.berg-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org>,
	linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: Stanislaw Gruszka <sgruszka-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>,
	Kalle Valo <kvalo-sgV2jX0FEOL9JmXXK+q4OQ@public.gmane.org>
Return-path: <linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
Sender: linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

gcc-6 warns about code in il3945_hw_txq_ctx_free() being
somewhat ambiguous:

drivers/net/wireless/intel/iwlegacy/3945.c:1022:5: warning: suggest explicit braces to avoid ambiguous 'else' [-Wparentheses]

This adds a set of curly braces to avoid the warning.

Signed-off-by: Arnd Bergmann <arnd-r2nGTMty4D4@public.gmane.org>
---
 drivers/net/wireless/intel/iwlegacy/3945.c | 3 ++-
 1 file changed, 2 insertions(+), 1 deletion(-)

diff --git a/drivers/net/wireless/intel/iwlegacy/3945.c b/drivers/net/wireless/intel/iwlegacy/3945.c
index 7bcedbb53d94..209dc9988455 100644
--- a/drivers/net/wireless/intel/iwlegacy/3945.c
+++ b/drivers/net/wireless/intel/iwlegacy/3945.c
@@ -1019,12 +1019,13 @@ il3945_hw_txq_ctx_free(struct il_priv *il)
 	int txq_id;
 
 	/* Tx queues */
-	if (il->txq)
+	if (il->txq) {
 		for (txq_id = 0; txq_id < il->hw_params.max_txq_num; txq_id++)
 			if (txq_id == IL39_CMD_QUEUE_NUM)
 				il_cmd_queue_free(il);
 			else
 				il_tx_queue_free(il, txq_id);
+	}
 
 	/* free tx queue structure */
 	il_free_txq_mem(il);
-- 
2.7.0

--
To unsubscribe from this list: send the line "unsubscribe linux-wireless" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
