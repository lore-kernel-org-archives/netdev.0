From: "Michael Chan" <mchan@broadcom.com>
Subject: [3/4][BNX2]: Use constants for stats ticks.
Date: Mon, 16 Jul 2007 13:07:46 -0700
Message-ID: <1184616466.17688.20.camel@dell>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
To: davem@davemloft.net, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mms2.broadcom.com ([216.31.210.18]:1303 "EHLO mms2.broadcom.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1757409AbXGPTPB (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 16 Jul 2007 15:15:01 -0400
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

[BNX2]: Use constants for stats ticks.

Change all stats related magic numbers to constants.

Signed-off-by: Michael Chan <mchan@broadcom.com>

diff --git a/drivers/net/bnx2.c b/drivers/net/bnx2.c
index 28399d8..2dd002b 100644
--- a/drivers/net/bnx2.c
+++ b/drivers/net/bnx2.c
@@ -4123,7 +4123,7 @@ bnx2_init_chip(struct bnx2 *bp)
 	if (CHIP_NUM(bp) == CHIP_NUM_5708)
 		REG_WR(bp, BNX2_HC_STATS_TICKS, 0);
 	else
-		REG_WR(bp, BNX2_HC_STATS_TICKS, bp->stats_ticks & 0xffff00);
+		REG_WR(bp, BNX2_HC_STATS_TICKS, bp->stats_ticks);
 	REG_WR(bp, BNX2_HC_STAT_COLLECT_TICKS, 0xbb8);  /* 3ms */
 
 	if (CHIP_ID(bp) == CHIP_ID_5706_A1)
@@ -5798,8 +5798,9 @@ bnx2_set_coalesce(struct net_device *dev, struct ethtool_coalesce *coal)
 		if (bp->stats_ticks != 0 && bp->stats_ticks != USEC_PER_SEC)
 			bp->stats_ticks = USEC_PER_SEC;
 	}
-	if (bp->stats_ticks > 0xffff00) bp->stats_ticks = 0xffff00;
-	bp->stats_ticks &= 0xffff00;
+	if (bp->stats_ticks > BNX2_HC_STATS_TICKS_HC_STAT_TICKS)
+		bp->stats_ticks = BNX2_HC_STATS_TICKS_HC_STAT_TICKS;
+	bp->stats_ticks &= BNX2_HC_STATS_TICKS_HC_STAT_TICKS;
 
 	if (netif_running(bp->dev)) {
 		bnx2_netif_stop(bp);
@@ -6696,7 +6697,7 @@ bnx2_init_board(struct pci_dev *pdev, struct net_device *dev)
 	bp->rx_ticks_int = 18;
 	bp->rx_ticks = 18;
 
-	bp->stats_ticks = 1000000 & 0xffff00;
+	bp->stats_ticks = USEC_PER_SEC & BNX2_HC_STATS_TICKS_HC_STAT_TICKS;
 
 	bp->timer_interval =  HZ;
 	bp->current_interval =  HZ;


