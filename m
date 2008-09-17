From: "Benjamin Li" <benli@broadcom.com>
Subject: [NET-NEXT PATCH] bnx2: Remove timer_interval field from the
 bnx2 structure
Date: Wed, 17 Sep 2008 16:02:21 -0700
Message-ID: <5dc0e7cc72714ac671d2af1c537869f8900f83b9.1219454143.git.benli@broadcom.com>
References: <cover.1219454143.git.benli@broadcom.com>
 <a93511dbe76cb994f3dbd16c3ad820617d4187e9.1219454143.git.benli@broadcom.com>
 <e5dd28099c48ea622c1ec67bce736dba9a139a20.1219454143.git.benli@broadcom.com>
 <2facac5d8110b82264e3c976afd5c5013c41dada.1219454143.git.benli@broadcom.com>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: benli@broadcom.com,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: unlisted-recipients:; (no To-header on input)
Return-path: <netdev-owner@vger.kernel.org>
Received: from mms1.broadcom.com ([216.31.210.17]:3855 "EHLO mms1.broadcom.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753990AbYIQXCi (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 17 Sep 2008 19:02:38 -0400
Received: from mail-irva-8.broadcom.com (mail-irva-8 [10.11.18.52]) by
 mail-irva-10.broadcom.com (Postfix) with ESMTP id 837282B0 for
 <netdev@vger.kernel.org>; Wed, 17 Sep 2008 16:02:23 -0700 (PDT)
In-Reply-To: <2facac5d8110b82264e3c976afd5c5013c41dada.1219454143.git.benli@broadcom.com>
In-Reply-To: <cover.1219454143.git.benli@broadcom.com>
References: <cover.1219454143.git.benli@broadcom.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The timer_interval field is only assigned once, and never reassigned.
We can safely replace all instances of the timer_interval with a
constant value.

Signed-off-by: Benjamin Li <benli@broadcom.com>
Signed-off-by: Michael Chan <mchan@broadcom.com>
---
 drivers/net/bnx2.c |   11 +++++------
 drivers/net/bnx2.h |    2 +-
 2 files changed, 6 insertions(+), 7 deletions(-)

diff --git a/drivers/net/bnx2.c b/drivers/net/bnx2.c
index 8417766..1b5b152 100644
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
@@ -7514,7 +7514,6 @@ bnx2_init_board(struct pci_dev *pdev, struct net_device *dev)
 
 	bp->stats_ticks = USEC_PER_SEC & BNX2_HC_STATS_TICKS_HC_STAT_TICKS;
 
-	bp->timer_interval =  HZ;
 	bp->current_interval =  HZ;
 
 	bp->phy_addr = 1;
@@ -7605,7 +7604,7 @@ bnx2_init_board(struct pci_dev *pdev, struct net_device *dev)
 	bp->req_flow_ctrl = FLOW_CTRL_RX | FLOW_CTRL_TX;
 
 	init_timer(&bp->timer);
-	bp->timer.expires = RUN_AT(bp->timer_interval);
+	bp->timer.expires = RUN_AT(BNX2_TIMER_INTERVAL);
 	bp->timer.data = (unsigned long) bp;
 	bp->timer.function = bnx2_timer;
 
diff --git a/drivers/net/bnx2.h b/drivers/net/bnx2.h
index cb47c98..e534c1d 100644
--- a/drivers/net/bnx2.h
+++ b/drivers/net/bnx2.h
@@ -6701,7 +6701,7 @@ struct bnx2 {
 
 	/* End of fields used in the performance code paths. */
 
-	int			timer_interval;
+#define BNX2_TIMER_INTERVAL			HZ
 	int			current_interval;
 	struct			timer_list timer;
 	struct work_struct	reset_task;
-- 
1.5.6.4


