From: Ian Campbell <ian.campbell@citrix.com>
Subject: [PATCH 17/75] bna: convert to SKB paged frag API.
Date: Fri, 19 Aug 2011 14:26:49 +0100
Message-ID: <1313760467-8598-17-git-send-email-ian.campbell@citrix.com>
References: <1313760393.5010.356.camel@zakaz.uk.xensource.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: linux-kernel@vger.kernel.org,
	Ian Campbell <ian.campbell@citrix.com>,
	Rasesh Mody <rmody@brocade.com>,
	Debashis Dutt <ddutt@brocade.com>
To: netdev@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1313760393.5010.356.camel@zakaz.uk.xensource.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Signed-off-by: Ian Campbell <ian.campbell@citrix.com>
Cc: Rasesh Mody <rmody@brocade.com>
Cc: Debashis Dutt <ddutt@brocade.com>
Cc: netdev@vger.kernel.org
Cc: linux-kernel@vger.kernel.org
---
 drivers/net/bna/bnad.c |    4 ++--
 1 files changed, 2 insertions(+), 2 deletions(-)

diff --git a/drivers/net/bna/bnad.c b/drivers/net/bna/bnad.c
index 8e35b25..7b8c21f 100644
--- a/drivers/net/bna/bnad.c
+++ b/drivers/net/bna/bnad.c
@@ -2622,8 +2622,8 @@ bnad_start_xmit(struct sk_buff *skb, struct net_device *netdev)
 
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
