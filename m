From: Ian Campbell <ian.campbell@citrix.com>
Subject: [PATCH 01/14] ibmveth: convert to SKB paged frag API.
Date: Wed, 31 Aug 2011 11:46:53 +0100
Message-ID: <1314787626-12273-1-git-send-email-ian.campbell@citrix.com>
References: <1314787608.28989.41.camel@zakaz.uk.xensource.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: Ian Campbell <ian.campbell@citrix.com>,
	Santiago Leon <santil@linux.vnet.ibm.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp02.citrix.com ([66.165.176.63]:10632 "EHLO
	SMTP02.CITRIX.COM" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753319Ab1HaKrK (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 31 Aug 2011 06:47:10 -0400
In-Reply-To: <1314787608.28989.41.camel@zakaz.uk.xensource.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Signed-off-by: Ian Campbell <ian.campbell@citrix.com>
Cc: Santiago Leon <santil@linux.vnet.ibm.com>
Cc: netdev@vger.kernel.org
---
 drivers/net/ethernet/ibm/ibmveth.c |    5 ++---
 1 files changed, 2 insertions(+), 3 deletions(-)

diff --git a/drivers/net/ethernet/ibm/ibmveth.c b/drivers/net/ethernet/ibm/ibmveth.c
index bba1ffc..8cca4a6 100644
--- a/drivers/net/ethernet/ibm/ibmveth.c
+++ b/drivers/net/ethernet/ibm/ibmveth.c
@@ -1002,9 +1002,8 @@ retry_bounce:
 		unsigned long dma_addr;
 		skb_frag_t *frag = &skb_shinfo(skb)->frags[i];
 
-		dma_addr = dma_map_page(&adapter->vdev->dev, frag->page,
-					frag->page_offset, frag->size,
-					DMA_TO_DEVICE);
+		dma_addr = skb_frag_dma_map(&adapter->vdev->dev, frag, 0,
+					    frag->size, DMA_TO_DEVICE);
 
 		if (dma_mapping_error(&adapter->vdev->dev, dma_addr))
 			goto map_failed_frags;
-- 
1.7.2.5
