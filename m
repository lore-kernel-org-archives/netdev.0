From: ebiederm@xmission.com (Eric W. Biederman)
Subject: [PATCH 02/11] bnx2: Call dev_kfree_skby_any instead of dev_kfree_skb.
Date: Mon, 10 Mar 2014 20:18:49 -0700
Message-ID: <87ppltpgme.fsf_-_@xmission.com>
References: <874n3fow2i.fsf@xmission.com>
	<20140304.160825.893718566461536483.davem@davemloft.net>
	<871ty9qvaf.fsf_-_@xmission.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: netdev@vger.kernel.org, xiyou.wangcong@gmail.com, mpm@selenic.com,
	satyam.sharma@gmail.com
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from out01.mta.xmission.com ([166.70.13.231]:37542 "EHLO
	out01.mta.xmission.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753190AbaCKDS4 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 10 Mar 2014 23:18:56 -0400
In-Reply-To: <871ty9qvaf.fsf_-_@xmission.com> (Eric W. Biederman's message of
	"Mon, 10 Mar 2014 20:16:40 -0700")
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


Replace dev_kfree_skb with dev_kfree_skb_any in functions that can
be called in hard irq and other contexts.

Signed-off-by: "Eric W. Biederman" <ebiederm@xmission.com>
---
 drivers/net/ethernet/broadcom/bnx2.c |   10 +++++-----
 1 files changed, 5 insertions(+), 5 deletions(-)

diff --git a/drivers/net/ethernet/broadcom/bnx2.c b/drivers/net/ethernet/broadcom/bnx2.c
index ca6b36220d94..c94735de808d 100644
--- a/drivers/net/ethernet/broadcom/bnx2.c
+++ b/drivers/net/ethernet/broadcom/bnx2.c
@@ -2885,7 +2885,7 @@ bnx2_tx_int(struct bnx2 *bp, struct bnx2_napi *bnapi, int budget)
 		sw_cons = BNX2_NEXT_TX_BD(sw_cons);
 
 		tx_bytes += skb->len;
-		dev_kfree_skb(skb);
+		dev_kfree_skb_any(skb);
 		tx_pkt++;
 		if (tx_pkt == budget)
 			break;
@@ -2943,7 +2943,7 @@ bnx2_reuse_rx_skb_pages(struct bnx2 *bp, struct bnx2_rx_ring_info *rxr,
 		__skb_frag_set_page(&shinfo->frags[shinfo->nr_frags], NULL);
 
 		cons_rx_pg->page = page;
-		dev_kfree_skb(skb);
+		dev_kfree_skb_any(skb);
 	}
 
 	hw_prod = rxr->rx_pg_prod;
@@ -3234,7 +3234,7 @@ bnx2_rx_int(struct bnx2 *bp, struct bnx2_napi *bnapi, int budget)
 		if ((len > (bp->dev->mtu + ETH_HLEN)) &&
 			(ntohs(skb->protocol) != 0x8100)) {
 
-			dev_kfree_skb(skb);
+			dev_kfree_skb_any(skb);
 			goto next_rx;
 
 		}
@@ -6604,7 +6604,7 @@ bnx2_start_xmit(struct sk_buff *skb, struct net_device *dev)
 
 	mapping = dma_map_single(&bp->pdev->dev, skb->data, len, PCI_DMA_TODEVICE);
 	if (dma_mapping_error(&bp->pdev->dev, mapping)) {
-		dev_kfree_skb(skb);
+		dev_kfree_skb_any(skb);
 		return NETDEV_TX_OK;
 	}
 
@@ -6697,7 +6697,7 @@ dma_error:
 			       PCI_DMA_TODEVICE);
 	}
 
-	dev_kfree_skb(skb);
+	dev_kfree_skb_any(skb);
 	return NETDEV_TX_OK;
 }
 
-- 
1.7.5.4
