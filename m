From: Andy Shevchenko <andriy.shevchenko@linux.intel.com>
Subject: [PATCH v1 5/6] net/macb: replace macb_count_tx_descriptors() by DIV_ROUND_UP()
Date: Fri, 24 Jul 2015 21:24:03 +0300
Message-ID: <1437762244-2678-6-git-send-email-andriy.shevchenko@linux.intel.com>
References: <1437762244-2678-1-git-send-email-andriy.shevchenko@linux.intel.com>
Cc: Andy Shevchenko <andriy.shevchenko@linux.intel.com>
To: Cyrille Pitchen <cyrille.pitchen@atmel.com>,
	Nicolas Ferre <nicolas.ferre@atmel.com>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga11.intel.com ([192.55.52.93]:59514 "EHLO mga11.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754534AbbGXSYK (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 24 Jul 2015 14:24:10 -0400
In-Reply-To: <1437762244-2678-1-git-send-email-andriy.shevchenko@linux.intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

macb_count_tx_descriptors() repeats the generic macro DIV_ROUND_UP(). The patch
does a replacement.

There is no functional change.

Signed-off-by: Andy Shevchenko <andriy.shevchenko@linux.intel.com>
---
 drivers/net/ethernet/cadence/macb.c | 10 ++--------
 1 file changed, 2 insertions(+), 8 deletions(-)

diff --git a/drivers/net/ethernet/cadence/macb.c b/drivers/net/ethernet/cadence/macb.c
index 13d7e96..5818c04 100644
--- a/drivers/net/ethernet/cadence/macb.c
+++ b/drivers/net/ethernet/cadence/macb.c
@@ -1157,12 +1157,6 @@ static void macb_poll_controller(struct net_device *dev)
 }
 #endif
 
-static inline unsigned int macb_count_tx_descriptors(struct macb *bp,
-						     unsigned int len)
-{
-	return (len + bp->max_tx_length - 1) / bp->max_tx_length;
-}
-
 static unsigned int macb_tx_map(struct macb *bp,
 				struct macb_queue *queue,
 				struct sk_buff *skb)
@@ -1313,11 +1307,11 @@ static int macb_start_xmit(struct sk_buff *skb, struct net_device *dev)
 	 * socket buffer: skb fragments of jumbo frames may need to be
 	 * splitted into many buffer descriptors.
 	 */
-	count = macb_count_tx_descriptors(bp, skb_headlen(skb));
+	count = DIV_ROUND_UP(skb_headlen(skb), bp->max_tx_length);
 	nr_frags = skb_shinfo(skb)->nr_frags;
 	for (f = 0; f < nr_frags; f++) {
 		frag_size = skb_frag_size(&skb_shinfo(skb)->frags[f]);
-		count += macb_count_tx_descriptors(bp, frag_size);
+		count += DIV_ROUND_UP(frag_size, bp->max_tx_length);
 	}
 
 	spin_lock_irqsave(&bp->lock, flags);
-- 
2.4.6
