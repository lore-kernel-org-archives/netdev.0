From: Colin King <colin.king@canonical.com>
Subject: [PATCH] ath6kl: remove redundant null pointer check on send_pkt
Date: Mon,  7 Sep 2015 14:49:05 +0100
Message-ID: <1441633745-5755-1-git-send-email-colin.king@canonical.com>
Cc: linux-kernel@vger.kernel.org
To: Kalle Valo <kvalo@qca.qualcomm.com>,
	linux-wireless@vger.kernel.org, netdev@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Colin Ian King <colin.king@canonical.com>

The check for send_pkt being NULL is redundant before the call
to htc_reclaim_txctrl_buf, therefore it should be removed. This was
detected by static analysis by cppcheck.

Signed-off-by: Colin Ian King <colin.king@canonical.com>
---
 drivers/net/wireless/ath/ath6kl/htc_mbox.c | 4 +---
 1 file changed, 1 insertion(+), 3 deletions(-)

diff --git a/drivers/net/wireless/ath/ath6kl/htc_mbox.c b/drivers/net/wireless/ath/ath6kl/htc_mbox.c
index e481f14..fffb65b 100644
--- a/drivers/net/wireless/ath/ath6kl/htc_mbox.c
+++ b/drivers/net/wireless/ath/ath6kl/htc_mbox.c
@@ -1085,9 +1085,7 @@ static int htc_setup_tx_complete(struct htc_target *target)
 	send_pkt->completion = NULL;
 	ath6kl_htc_tx_prep_pkt(send_pkt, 0, 0, 0);
 	status = ath6kl_htc_tx_issue(target, send_pkt);
-
-	if (send_pkt != NULL)
-		htc_reclaim_txctrl_buf(target, send_pkt);
+	htc_reclaim_txctrl_buf(target, send_pkt);
 
 	return status;
 }
-- 
2.5.0
