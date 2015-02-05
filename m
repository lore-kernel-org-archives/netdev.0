From: Lad Prabhakar <prabhakar.csengg@gmail.com>
Subject: [PATCH] net: bnx2x: fix sparse warnings
Date: Thu,  5 Feb 2015 15:47:17 +0000
Message-ID: <1423151237-20746-1-git-send-email-prabhakar.csengg@gmail.com>
Cc: linux-kernel@vger.kernel.org,
	"Lad, Prabhakar" <prabhakar.csengg@gmail.com>
To: Ariel Elior <ariel.elior@qlogic.com>, netdev@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: "Lad, Prabhakar" <prabhakar.csengg@gmail.com>

this patch fixes following sparse warnings:

bnx2x_main.c:9172:6: warning: symbol 'bnx2x_stop_ptp' was not declared. Should it be static?
bnx2x_main.c:13321:6: warning: symbol 'bnx2x_register_phc' was not declared. Should it be static?
bnx2x_main.c:14638:5: warning: symbol 'bnx2x_enable_ptp_packets' was not declared. Should it be static?

Signed-off-by: Lad, Prabhakar <prabhakar.csengg@gmail.com>
---
 Found this issue on linux-next (gcc  version 4.8.2,
 sparse version  0.4.5-rc1)and applies on top linux-next.

 drivers/net/ethernet/broadcom/bnx2x/bnx2x_main.c | 6 +++---
 1 file changed, 3 insertions(+), 3 deletions(-)

diff --git a/drivers/net/ethernet/broadcom/bnx2x/bnx2x_main.c b/drivers/net/ethernet/broadcom/bnx2x/bnx2x_main.c
index 0758c8b..7155e1d 100644
--- a/drivers/net/ethernet/broadcom/bnx2x/bnx2x_main.c
+++ b/drivers/net/ethernet/broadcom/bnx2x/bnx2x_main.c
@@ -9169,7 +9169,7 @@ static void bnx2x_disable_ptp(struct bnx2x *bp)
 }
 
 /* Called during unload, to stop PTP-related stuff */
-void bnx2x_stop_ptp(struct bnx2x *bp)
+static void bnx2x_stop_ptp(struct bnx2x *bp)
 {
 	/* Cancel PTP work queue. Should be done after the Tx queues are
 	 * drained to prevent additional scheduling.
@@ -13318,7 +13318,7 @@ static int bnx2x_ptp_enable(struct ptp_clock_info *ptp,
 	return -ENOTSUPP;
 }
 
-void bnx2x_register_phc(struct bnx2x *bp)
+static void bnx2x_register_phc(struct bnx2x *bp)
 {
 	/* Fill the ptp_clock_info struct and register PTP clock*/
 	bp->ptp_clock_info.owner = THIS_MODULE;
@@ -14635,7 +14635,7 @@ static int bnx2x_send_reset_timesync_ramrod(struct bnx2x *bp)
 	return bnx2x_func_state_change(bp, &func_params);
 }
 
-int bnx2x_enable_ptp_packets(struct bnx2x *bp)
+static int bnx2x_enable_ptp_packets(struct bnx2x *bp)
 {
 	struct bnx2x_queue_state_params q_params;
 	int rc, i;
-- 
1.9.1
