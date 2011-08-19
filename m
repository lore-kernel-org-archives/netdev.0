From: Ian Campbell <ian.campbell@citrix.com>
Subject: [PATCH 30/75] ibmveth: convert to SKB paged frag API.
Date: Fri, 19 Aug 2011 14:27:02 +0100
Message-ID: <1313760467-8598-30-git-send-email-ian.campbell@citrix.com>
References: <1313760393.5010.356.camel@zakaz.uk.xensource.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: linux-kernel@vger.kernel.org,
	Ian Campbell <ian.campbell@citrix.com>,
	Santiago Leon <santil@linux.vnet.ibm.com>
To: netdev@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1313760393.5010.356.camel@zakaz.uk.xensource.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Signed-off-by: Ian Campbell <ian.campbell@citrix.com>
Cc: Santiago Leon <santil@linux.vnet.ibm.com>
Cc: netdev@vger.kernel.org
Cc: linux-kernel@vger.kernel.org
---
 drivers/net/ibmveth.c |    5 ++---
 1 files changed, 2 insertions(+), 3 deletions(-)

diff --git a/drivers/net/ibmveth.c b/drivers/net/ibmveth.c
index ba99af0..b7895d7 100644
--- a/drivers/net/ibmveth.c
+++ b/drivers/net/ibmveth.c
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
