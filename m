From: Ben Shelton <ben.shelton@ni.com>
Subject: [PATCH] net/macb: Factor out one-time assignment from loop
Date: Wed, 22 Apr 2015 17:28:54 -0500
Message-ID: <1429741734-29536-1-git-send-email-ben.shelton@ni.com>
Cc: Ben Shelton <ben.shelton@ni.com>
To: nicolas.ferre@atmel.com, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

In 02c958dd3 (net/macb: add TX multiqueue support for gem), the
initialization of tx_head and tx_tail in macb_init_rings() was moved
inside the loop that iterates over each element in the ring.  Since
tx_head and tx_tail only need to be assigned once, move them back out of
the loop.

Signed-off-by: Ben Shelton <ben.shelton@ni.com>
---
 drivers/net/ethernet/cadence/macb.c | 4 ++--
 1 file changed, 2 insertions(+), 2 deletions(-)

diff --git a/drivers/net/ethernet/cadence/macb.c b/drivers/net/ethernet/cadence/macb.c
index 9f53872..665c290 100644
--- a/drivers/net/ethernet/cadence/macb.c
+++ b/drivers/net/ethernet/cadence/macb.c
@@ -1473,9 +1473,9 @@ static void macb_init_rings(struct macb *bp)
 	for (i = 0; i < TX_RING_SIZE; i++) {
 		bp->queues[0].tx_ring[i].addr = 0;
 		bp->queues[0].tx_ring[i].ctrl = MACB_BIT(TX_USED);
-		bp->queues[0].tx_head = 0;
-		bp->queues[0].tx_tail = 0;
 	}
+	bp->queues[0].tx_head = 0;
+	bp->queues[0].tx_tail = 0;
 	bp->queues[0].tx_ring[TX_RING_SIZE - 1].ctrl |= MACB_BIT(TX_WRAP);
 
 	bp->rx_tail = 0;
-- 
2.3.6
