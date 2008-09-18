From: "Benjamin Li" <benli@broadcom.com>
Subject: [UPDATED][NET-NEXT PATCH 4/4] bnx2: Remove timer_interval field
 from the bnx2 structure
Date: Thu, 18 Sep 2008 09:57:13 -0700
Message-ID: <1221757033-4874-5-git-send-email-benli@broadcom.com>
References: <20080918063933.GA8027@verge.net.au>
 <1221757033-4874-1-git-send-email-benli@broadcom.com>
 <1221757033-4874-2-git-send-email-benli@broadcom.com>
 <1221757033-4874-3-git-send-email-benli@broadcom.com>
 <1221757033-4874-4-git-send-email-benli@broadcom.com>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: benli@broadcom.com,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: "Jeff Garzik" <jeff@garzik.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mms1.broadcom.com ([216.31.210.17]:4709 "EHLO mms1.broadcom.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756442AbYIRQ51 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 18 Sep 2008 12:57:27 -0400
In-Reply-To: <1221757033-4874-4-git-send-email-benli@broadcom.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The timer_interval field is only assigned once, and never reassigned.
We can safely replace all instances of the timer_interval with a
constant value.

Signed-off-by: Benjamin Li <benli@broadcom.com>
Signed-off-by: Michael Chan <mchan@broadcom.com>
---
 drivers/net/bnx2.c |   13 ++++++-------
 drivers/net/bnx2.h |    3 ++-
 2 files changed, 8 insertions(+), 8 deletions(-)

diff --git a/drivers/net/bnx2.c b/drivers/net/bnx2.c
index 8417766..883e0a7 100644
--- a/drivers/net/bnx2.c
+++ b/drivers/net/bnx2.c
@@ -5598,7 +5598,7 @@ bnx2_5706_serdes_timer(struct bnx2 *bp)
 	} else if ((bp->link_up == 0) && (bp->autoneg & AUTONEG_SPEED)) {
 		u32 bmcr;
 
-		bp->current_interval = bp->timer_interval;
+		bp->current_interval = BNX2_TIMER_INTERVAL;
 
 		bnx2_read_phy(bp, bp->mii_bmcr, &bmcr);
 
@@ -5627,7 +5627,7 @@ bnx2_5706_serdes_timer(struct bnx2 *bp)
 			bp->phy_flags &= ~BNX2_PHY_FLAG_PARALLEL_DETECT;
 		}
 	} else
-		bp->current_interval = bp->timer_interval;
+		bp->current_interval = BNX2_TIMER_INTERVAL;
 
 	if (check_link) {
 		u32 val;
@@ -5672,11 +5672,11 @@ bnx2_5708_serdes_timer(struct bnx2 *bp)
 		} else {
 			bnx2_disable_forced_2g5(bp);
 			bp->serdes_an_pending = 2;
-			bp->current_interval = bp->timer_interval;
+			bp->current_interval = BNX2_TIMER_INTERVAL;
 		}
 
 	} else
-		bp->current_interval = bp->timer_interval;
+		bp->current_interval = BNX2_TIMER_INTERVAL;
 
 	spin_unlock(&bp->phy_lock);
 }
@@ -7514,8 +7514,7 @@ bnx2_init_board(struct pci_dev *pdev, struct net_device *dev)
 
 	bp->stats_ticks = USEC_PER_SEC & BNX2_HC_STATS_TICKS_HC_STAT_TICKS;
 
-	bp->timer_interval =  HZ;
-	bp->current_interval =  HZ;
+	bp->current_interval = BNX2_TIMER_INTERVAL;
 
 	bp->phy_addr = 1;
 
@@ -7605,7 +7604,7 @@ bnx2_init_board(struct pci_dev *pdev, struct net_device *dev)
 	bp->req_flow_ctrl = FLOW_CTRL_RX | FLOW_CTRL_TX;
 
 	init_timer(&bp->timer);
-	bp->timer.expires = RUN_AT(bp->timer_interval);
+	bp->timer.expires = RUN_AT(BNX2_TIMER_INTERVAL);
 	bp->timer.data = (unsigned long) bp;
 	bp->timer.function = bnx2_timer;
 
diff --git a/drivers/net/bnx2.h b/drivers/net/bnx2.h
index cb47c98..682b8f0 100644
--- a/drivers/net/bnx2.h
+++ b/drivers/net/bnx2.h
@@ -6654,6 +6654,8 @@ struct bnx2_napi {
 	struct bnx2_tx_ring_info	tx_ring;
 };
 
+#define BNX2_TIMER_INTERVAL			HZ
+
 struct bnx2 {
 	/* Fields used in the tx and intr/napi performance paths are grouped */
 	/* together in the beginning of the structure. */
@@ -6701,7 +6703,6 @@ struct bnx2 {
 
 	/* End of fields used in the performance code paths. */
 
-	int			timer_interval;
 	int			current_interval;
 	struct			timer_list timer;
 	struct work_struct	reset_task;
-- 
1.6.0.1


