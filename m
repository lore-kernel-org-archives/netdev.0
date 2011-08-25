From: Ian Campbell <ian.campbell@citrix.com>
Subject: [PATCH 6/9] bnx2: convert to SKB paged frag API.
Date: Thu, 25 Aug 2011 09:28:12 +0100
Message-ID: <1314260895-15936-6-git-send-email-ian.campbell@citrix.com>
References: <1314260881.10283.48.camel@zakaz.uk.xensource.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: Ian Campbell <ian.campbell@citrix.com>,
	Michael Chan <mchan@broadcom.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp02.citrix.com ([66.165.176.63]:38678 "EHLO
	SMTP02.CITRIX.COM" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752522Ab1HYI21 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 25 Aug 2011 04:28:27 -0400
In-Reply-To: <1314260881.10283.48.camel@zakaz.uk.xensource.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Signed-off-by: Ian Campbell <ian.campbell@citrix.com>
Reviewed-by: Konrad Rzeszutek Wilk <konrad.wilk@oracle.com>
Cc: Michael Chan <mchan@broadcom.com>
Cc: netdev@vger.kernel.org
---
 drivers/net/ethernet/broadcom/bnx2.c |    8 ++++----
 1 files changed, 4 insertions(+), 4 deletions(-)

diff --git a/drivers/net/ethernet/broadcom/bnx2.c b/drivers/net/ethernet/broadcom/bnx2.c
index 4a9a8c81..9afb653 100644
--- a/drivers/net/ethernet/broadcom/bnx2.c
+++ b/drivers/net/ethernet/broadcom/bnx2.c
@@ -2930,8 +2930,8 @@ bnx2_reuse_rx_skb_pages(struct bnx2 *bp, struct bnx2_rx_ring_info *rxr,
 
 		shinfo = skb_shinfo(skb);
 		shinfo->nr_frags--;
-		page = shinfo->frags[shinfo->nr_frags].page;
-		shinfo->frags[shinfo->nr_frags].page = NULL;
+		page = skb_frag_page(&shinfo->frags[shinfo->nr_frags]);
+		__skb_frag_set_page(&shinfo->frags[shinfo->nr_frags], NULL);
 
 		cons_rx_pg->page = page;
 		dev_kfree_skb(skb);
@@ -6511,8 +6511,8 @@ bnx2_start_xmit(struct sk_buff *skb, struct net_device *dev)
 		txbd = &txr->tx_desc_ring[ring_prod];
 
 		len = frag->size;
-		mapping = dma_map_page(&bp->pdev->dev, frag->page, frag->page_offset,
-				       len, PCI_DMA_TODEVICE);
+		mapping = skb_frag_dma_map(&bp->pdev->dev, frag, 0, len,
+					   PCI_DMA_TODEVICE);
 		if (dma_mapping_error(&bp->pdev->dev, mapping))
 			goto dma_error;
 		dma_unmap_addr_set(&txr->tx_buf_ring[ring_prod], mapping,
-- 
1.7.2.5
