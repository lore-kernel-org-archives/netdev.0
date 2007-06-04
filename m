From: Stephen Hemminger <shemminger@linux-foundation.org>
Subject: [PATCH 4/4] b44: use netdev_alloc_skb
Date: Mon, 04 Jun 2007 13:25:40 -0700
Message-ID: <20070604202712.537466404@linux-foundation.org>
References: <20070604202536.503165465@linux-foundation.org>
Cc: netdev@vger.kernel.org
To: Gary Zambrano <zambrano@broadcom.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp2.linux-foundation.org ([207.189.120.14]:41350 "EHLO
	smtp2.linux-foundation.org" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1753526AbXFDUlA (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 4 Jun 2007 16:41:00 -0400
Content-Disposition: inline; filename=b44-netdev_alloc.patch
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Use netdev_alloc_skb rather than dev_alloc_skb when allocating
receive buffers.

Signed-off-by: Stephen Hemminger <shemminger@linux-foundation.org>

---
 drivers/net/b44.c |    5 ++---
 1 file changed, 2 insertions(+), 3 deletions(-)

--- a/drivers/net/b44.c	2007-06-04 12:49:11.000000000 -0700
+++ b/drivers/net/b44.c	2007-06-04 12:49:26.000000000 -0700
@@ -653,7 +653,7 @@ static int b44_alloc_rx_skb(struct b44 *
 		src_map = &bp->rx_buffers[src_idx];
 	dest_idx = dest_idx_unmasked & (B44_RX_RING_SIZE - 1);
 	map = &bp->rx_buffers[dest_idx];
-	skb = dev_alloc_skb(RX_PKT_BUF_SZ);
+	skb = netdev_alloc_skb(bp->dev, RX_PKT_BUF_SZ);
 	if (skb == NULL)
 		return -ENOMEM;
 
@@ -669,7 +669,7 @@ static int b44_alloc_rx_skb(struct b44 *
 		if (!dma_mapping_error(mapping))
 			pci_unmap_single(bp->pdev, mapping, RX_PKT_BUF_SZ,PCI_DMA_FROMDEVICE);
 		dev_kfree_skb_any(skb);
-		skb = __dev_alloc_skb(RX_PKT_BUF_SZ,GFP_DMA);
+		skb = __netdev_alloc_skb(bp->dev, RX_PKT_BUF_SZ, GFP_ATOMIC|GFP_DMA);
 		if (skb == NULL)
 			return -ENOMEM;
 		mapping = pci_map_single(bp->pdev, skb->data,
@@ -684,7 +684,6 @@ static int b44_alloc_rx_skb(struct b44 *
 		}
 	}
 
-	skb->dev = bp->dev;
 	rh = (struct rx_header *) skb->data;
 	skb_reserve(skb, RX_PKT_OFFSET);
 

-- 
Stephen Hemminger <shemminger@linux-foundation.org>

