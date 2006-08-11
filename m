From: "Michael Chan" <mchan@broadcom.com>
Subject: [PATCH 2/2] [BNX2]: Convert to netdev_alloc_skb()
Date: Thu, 10 Aug 2006 17:14:43 -0700
Message-ID: <1155255283.11815.4.camel@rh4>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mms3.broadcom.com ([216.31.210.19]:60687 "EHLO
	MMS3.broadcom.com") by vger.kernel.org with ESMTP id S932270AbWHKAOB
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 10 Aug 2006 20:14:01 -0400
To: davem@davemloft.net
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

[BNX2]: Convert to netdev_alloc_skb()

Convert dev_alloc_skb() to netdev_alloc_skb() and increase default
rx ring size to 255. The old ring size of 100 was too small.

Update version to 1.4.44.

Signed-off-by: Michael Chan <mchan@broadcom.com>

diff --git a/drivers/net/bnx2.c b/drivers/net/bnx2.c
index 2099edb..652eb05 100644
--- a/drivers/net/bnx2.c
+++ b/drivers/net/bnx2.c
@@ -56,8 +56,8 @@
 
 #define DRV_MODULE_NAME		"bnx2"
 #define PFX DRV_MODULE_NAME	": "
-#define DRV_MODULE_VERSION	"1.4.43"
-#define DRV_MODULE_RELDATE	"June 28, 2006"
+#define DRV_MODULE_VERSION	"1.4.44"
+#define DRV_MODULE_RELDATE	"August 10, 2006"
 
 #define RUN_AT(x) (jiffies + (x))
 
@@ -1571,7 +1571,7 @@ bnx2_alloc_rx_skb(struct bnx2 *bp, u16 i
 	struct rx_bd *rxbd = &bp->rx_desc_ring[RX_RING(index)][RX_IDX(index)];
 	unsigned long align;
 
-	skb = dev_alloc_skb(bp->rx_buf_size);
+	skb = netdev_alloc_skb(bp->dev, bp->rx_buf_size);
 	if (skb == NULL) {
 		return -ENOMEM;
 	}
@@ -1580,7 +1580,6 @@ bnx2_alloc_rx_skb(struct bnx2 *bp, u16 i
 		skb_reserve(skb, 8 - align);
 	}
 
-	skb->dev = bp->dev;
 	mapping = pci_map_single(bp->pdev, skb->data, bp->rx_buf_use_size,
 		PCI_DMA_FROMDEVICE);
 
@@ -1793,7 +1792,7 @@ bnx2_rx_int(struct bnx2 *bp, int budget)
 		if ((bp->dev->mtu > 1500) && (len <= RX_COPY_THRESH)) {
 			struct sk_buff *new_skb;
 
-			new_skb = dev_alloc_skb(len + 2);
+			new_skb = netdev_alloc_skb(bp->dev, len + 2);
 			if (new_skb == NULL)
 				goto reuse_rx;
 
@@ -1804,7 +1803,6 @@ bnx2_rx_int(struct bnx2 *bp, int budget)
 
 			skb_reserve(new_skb, 2);
 			skb_put(new_skb, len);
-			new_skb->dev = bp->dev;
 
 			bnx2_reuse_rx_skb(bp, skb,
 				sw_ring_cons, sw_ring_prod);
@@ -3961,7 +3959,7 @@ bnx2_run_loopback(struct bnx2 *bp, int l
 		return -EINVAL;
 
 	pkt_size = 1514;
-	skb = dev_alloc_skb(pkt_size);
+	skb = netdev_alloc_skb(bp->dev, pkt_size);
 	if (!skb)
 		return -ENOMEM;
 	packet = skb_put(skb, pkt_size);
@@ -5754,7 +5752,7 @@ bnx2_init_board(struct pci_dev *pdev, st
 	bp->mac_addr[5] = (u8) reg;
 
 	bp->tx_ring_size = MAX_TX_DESC_CNT;
-	bnx2_set_rx_ring_size(bp, 100);
+	bnx2_set_rx_ring_size(bp, 255);
 
 	bp->rx_csum = 1;
 


