From: Ian Campbell <ian.campbell@citrix.com>
Subject: [PATCH 08/14] bna: convert to SKB paged frag API.
Date: Tue, 30 Aug 2011 10:18:24 +0100
Message-ID: <1314695910-22344-8-git-send-email-ian.campbell@citrix.com>
References: <1314695847.10283.102.camel@zakaz.uk.xensource.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: Ian Campbell <ian.campbell@citrix.com>,
	Rasesh Mody <rmody@brocade.com>,
	Debashis Dutt <ddutt@brocade.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.citrix.com ([66.165.176.89]:22544 "EHLO SMTP.CITRIX.COM"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752755Ab1H3JSp (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 30 Aug 2011 05:18:45 -0400
In-Reply-To: <1314695847.10283.102.camel@zakaz.uk.xensource.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Signed-off-by: Ian Campbell <ian.campbell@citrix.com>
Cc: Rasesh Mody <rmody@brocade.com>
Cc: Debashis Dutt <ddutt@brocade.com>
Cc: netdev@vger.kernel.org
---
 drivers/net/ethernet/brocade/bna/bnad.c |    4 ++--
 1 files changed, 2 insertions(+), 2 deletions(-)

diff --git a/drivers/net/ethernet/brocade/bna/bnad.c b/drivers/net/ethernet/brocade/bna/bnad.c
index 6ad4b47..181561c 100644
--- a/drivers/net/ethernet/brocade/bna/bnad.c
+++ b/drivers/net/ethernet/brocade/bna/bnad.c
@@ -2703,8 +2703,8 @@ bnad_start_xmit(struct sk_buff *skb, struct net_device *netdev)
 
 		BUG_ON(!(size <= BFI_TX_MAX_DATA_PER_VECTOR));
 		txqent->vector[vect_id].length = htons(size);
-		dma_addr = dma_map_page(&bnad->pcidev->dev, frag->page,
-					frag->page_offset, size, DMA_TO_DEVICE);
+		dma_addr = skb_frag_dma_map(&bnad->pcidev->dev, frag,
+					    0, size, DMA_TO_DEVICE);
 		dma_unmap_addr_set(&unmap_q->unmap_array[unmap_prod], dma_addr,
 				   dma_addr);
 		BNA_SET_DMA_ADDR(dma_addr, &txqent->vector[vect_id].host_addr);
-- 
1.7.2.5
