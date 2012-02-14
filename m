From: Michal Schmidt <mschmidt@redhat.com>
Subject: [PATCH] bnx2x: remove the 'poll' module option
Date: Tue, 14 Feb 2012 20:05:46 +0100
Message-ID: <1329246346-9993-1-git-send-email-mschmidt@redhat.com>
Cc: eilong@broadcom.com, gideonn@broadcom.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:30368 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1759293Ab2BNTFu (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 14 Feb 2012 14:05:50 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

'poll' was a debugging option, but turning it on these days leads to
kernel panic. Remove it.

Signed-off-by: Michal Schmidt <mschmidt@redhat.com>
---
 drivers/net/ethernet/broadcom/bnx2x/bnx2x_main.c |   17 +----------------
 1 files changed, 1 insertions(+), 16 deletions(-)

diff --git a/drivers/net/ethernet/broadcom/bnx2x/bnx2x_main.c b/drivers/net/ethernet/broadcom/bnx2x/bnx2x_main.c
index ff19c3c..f4456ef 100644
--- a/drivers/net/ethernet/broadcom/bnx2x/bnx2x_main.c
+++ b/drivers/net/ethernet/broadcom/bnx2x/bnx2x_main.c
@@ -117,10 +117,6 @@ static int dropless_fc;
 module_param(dropless_fc, int, 0);
 MODULE_PARM_DESC(dropless_fc, " Pause on exhausted host ring");
 
-static int poll;
-module_param(poll, int, 0);
-MODULE_PARM_DESC(poll, " Use polling (for debug)");
-
 static int mrrs = -1;
 module_param(mrrs, int, 0);
 MODULE_PARM_DESC(mrrs, " Force Max Read Req Size (0..3) (for debug)");
@@ -4853,20 +4849,11 @@ void bnx2x_drv_pulse(struct bnx2x *bp)
 
 static void bnx2x_timer(unsigned long data)
 {
-	u8 cos;
 	struct bnx2x *bp = (struct bnx2x *) data;
 
 	if (!netif_running(bp->dev))
 		return;
 
-	if (poll) {
-		struct bnx2x_fastpath *fp = &bp->fp[0];
-
-		for_each_cos_in_tx_queue(fp, cos)
-			bnx2x_tx_int(bp, &fp->txdata[cos]);
-		bnx2x_rx_int(fp, 1000);
-	}
-
 	if (!BP_NOMCP(bp)) {
 		int mb_idx = BP_FW_MB_IDX(bp);
 		u32 drv_pulse;
@@ -10121,7 +10108,6 @@ static void __devinit bnx2x_set_modes_bitmap(struct bnx2x *bp)
 static int __devinit bnx2x_init_bp(struct bnx2x *bp)
 {
 	int func;
-	int timer_interval;
 	int rc;
 
 	mutex_init(&bp->port.phy_mutex);
@@ -10189,8 +10175,7 @@ static int __devinit bnx2x_init_bp(struct bnx2x *bp)
 	bp->tx_ticks = (50 / BNX2X_BTR) * BNX2X_BTR;
 	bp->rx_ticks = (25 / BNX2X_BTR) * BNX2X_BTR;
 
-	timer_interval = (CHIP_REV_IS_SLOW(bp) ? 5*HZ : HZ);
-	bp->current_interval = (poll ? poll : timer_interval);
+	bp->current_interval = CHIP_REV_IS_SLOW(bp) ? 5*HZ : HZ;
 
 	init_timer(&bp->timer);
 	bp->timer.expires = jiffies + bp->current_interval;
-- 
1.7.4.1
