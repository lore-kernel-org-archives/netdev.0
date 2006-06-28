From: "Michael Chan" <mchan@broadcom.com>
Subject: [PATCH 1/2] bnx2: Use dev_kfree_skb() instead of the _irq
 version
Date: Wed, 28 Jun 2006 10:59:14 -0700
Message-ID: <1151517555.3502.19.camel@rh4>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mms2.broadcom.com ([216.31.210.18]:15887 "EHLO
	mms2.broadcom.com") by vger.kernel.org with ESMTP id S1751515AbWF1R6L
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 28 Jun 2006 13:58:11 -0400
To: davem@davemloft.net
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Change all dev_kfree_skb_irq() and dev_kfree_skb_any() to
dev_kfree_skb().  These calls are never used in irq context.

Signed-off-by: Michael Chan <mchan@broadcom.com>


diff --git a/drivers/net/bnx2.c b/drivers/net/bnx2.c
index e89d5df..e59cb59 100644
--- a/drivers/net/bnx2.c
+++ b/drivers/net/bnx2.c
@@ -1676,7 +1676,7 @@ bnx2_tx_int(struct bnx2 *bp)
 
 		tx_free_bd += last + 1;
 
-		dev_kfree_skb_irq(skb);
+		dev_kfree_skb(skb);
 
 		hw_cons = bp->hw_tx_cons =
 			sblk->status_tx_quick_consumer_index0;
@@ -1824,7 +1824,7 @@ reuse_rx:
 		if ((len > (bp->dev->mtu + ETH_HLEN)) &&
 			(ntohs(skb->protocol) != 0x8100)) {
 
-			dev_kfree_skb_irq(skb);
+			dev_kfree_skb(skb);
 			goto next_rx;
 
 		}
@@ -3643,7 +3643,7 @@ bnx2_free_tx_skbs(struct bnx2 *bp)
 				skb_shinfo(skb)->frags[j].size,
 				PCI_DMA_TODEVICE);
 		}
-		dev_kfree_skb_any(skb);
+		dev_kfree_skb(skb);
 		i += j + 1;
 	}
 
@@ -3669,7 +3669,7 @@ bnx2_free_rx_skbs(struct bnx2 *bp)
 
 		rx_buf->skb = NULL;
 
-		dev_kfree_skb_any(skb);
+		dev_kfree_skb(skb);
 	}
 }
 
@@ -3999,7 +3999,7 @@ bnx2_run_loopback(struct bnx2 *bp, int l
 	udelay(5);
 
 	pci_unmap_single(bp->pdev, map, pkt_size, PCI_DMA_TODEVICE);
-	dev_kfree_skb_irq(skb);
+	dev_kfree_skb(skb);
 
 	if (bp->status_blk->status_tx_quick_consumer_index0 != bp->tx_prod) {
 		goto loopback_test_done;


