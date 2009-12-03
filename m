From: "Michael Chan" <mchan@broadcom.com>
Subject: [PATCH 3/5] bnx2: Print warning when unable to allocate the
 full SKB/page ring.
Date: Thu, 3 Dec 2009 11:46:33 -0800
Message-ID: <1259869595-6450-3-git-send-email-mchan@broadcom.com>
References: <1259869595-6450-1-git-send-email-mchan@broadcom.com>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mms1.broadcom.com ([216.31.210.17]:4589 "EHLO mms1.broadcom.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754707AbZLCTjX (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 3 Dec 2009 14:39:23 -0500
In-Reply-To: <1259869595-6450-1-git-send-email-mchan@broadcom.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Signed-off-by: Michael Chan <mchan@broadcom.com>
Signed-off-by: Benjamin Li <benli@broadcom.com>
---
 drivers/net/bnx2.c |   12 ++++++++++--
 1 files changed, 10 insertions(+), 2 deletions(-)

diff --git a/drivers/net/bnx2.c b/drivers/net/bnx2.c
index 665253a..dba3840 100644
--- a/drivers/net/bnx2.c
+++ b/drivers/net/bnx2.c
@@ -5158,8 +5158,12 @@ bnx2_init_rx_ring(struct bnx2 *bp, int ring_num)
 
 	ring_prod = prod = rxr->rx_pg_prod;
 	for (i = 0; i < bp->rx_pg_ring_size; i++) {
-		if (bnx2_alloc_rx_page(bp, rxr, ring_prod) < 0)
+		if (bnx2_alloc_rx_page(bp, rxr, ring_prod) < 0) {
+			printk(KERN_WARNING PFX "%s: init'ed rx page ring %d "
+						"with %d/%d pages only\n",
+			       bp->dev->name, ring_num, i, bp->rx_pg_ring_size);
 			break;
+		}
 		prod = NEXT_RX_BD(prod);
 		ring_prod = RX_PG_RING_IDX(prod);
 	}
@@ -5167,8 +5171,12 @@ bnx2_init_rx_ring(struct bnx2 *bp, int ring_num)
 
 	ring_prod = prod = rxr->rx_prod;
 	for (i = 0; i < bp->rx_ring_size; i++) {
-		if (bnx2_alloc_rx_skb(bp, rxr, ring_prod) < 0)
+		if (bnx2_alloc_rx_skb(bp, rxr, ring_prod) < 0) {
+			printk(KERN_WARNING PFX "%s: init'ed rx ring %d with "
+						"%d/%d skbs only\n",
+			       bp->dev->name, ring_num, i, bp->rx_ring_size);
 			break;
+		}
 		prod = NEXT_RX_BD(prod);
 		ring_prod = RX_RING_IDX(prod);
 	}
-- 
1.6.4.GIT


