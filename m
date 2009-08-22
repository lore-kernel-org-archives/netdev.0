From: "Michael Chan" <mchan@broadcom.com>
Subject: [PATCH -next 6/8] bnx2: Refine coalescing parameters.
Date: Fri, 21 Aug 2009 19:20:48 -0700
Message-ID: <1250907650-24672-6-git-send-email-mchan@broadcom.com>
References: <1250907650-24672-1-git-send-email-mchan@broadcom.com>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mms3.broadcom.com ([216.31.210.19]:4824 "EHLO MMS3.broadcom.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S933151AbZHVCNr (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 21 Aug 2009 22:13:47 -0400
In-Reply-To: <1250907650-24672-1-git-send-email-mchan@broadcom.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

- Set the USE_INT_PARAM bit so the rx-frames-irq and tx-frames-irq will take
  effect on 5709.
- Increase the default rx-frames to reduce interrupt count.
- Decrease the default rx-frames-irq and tx-frames-irq to catch more events
  during NAPI poll.

All these will reduce interrupts without affecting latency.

Signed-off-by: Michael Chan <mchan@broadcom.com>
---
 drivers/net/bnx2.c |   10 +++++-----
 1 files changed, 5 insertions(+), 5 deletions(-)

diff --git a/drivers/net/bnx2.c b/drivers/net/bnx2.c
index e025833..ea6e6b7 100644
--- a/drivers/net/bnx2.c
+++ b/drivers/net/bnx2.c
@@ -4921,7 +4921,7 @@ bnx2_init_chip(struct bnx2 *bp)
 	}
 
 	if (bp->flags & BNX2_FLAG_ONE_SHOT_MSI)
-		val |= BNX2_HC_CONFIG_ONE_SHOT;
+		val |= BNX2_HC_CONFIG_ONE_SHOT | BNX2_HC_CONFIG_USE_INT_PARAM;
 
 	REG_WR(bp, BNX2_HC_CONFIG, val);
 
@@ -7858,13 +7858,13 @@ bnx2_init_board(struct pci_dev *pdev, struct net_device *dev)
 
 	bp->rx_csum = 1;
 
-	bp->tx_quick_cons_trip_int = 20;
+	bp->tx_quick_cons_trip_int = 2;
 	bp->tx_quick_cons_trip = 20;
-	bp->tx_ticks_int = 80;
+	bp->tx_ticks_int = 18;
 	bp->tx_ticks = 80;
 
-	bp->rx_quick_cons_trip_int = 6;
-	bp->rx_quick_cons_trip = 6;
+	bp->rx_quick_cons_trip_int = 2;
+	bp->rx_quick_cons_trip = 12;
 	bp->rx_ticks_int = 18;
 	bp->rx_ticks = 18;
 
-- 
1.5.6.GIT


