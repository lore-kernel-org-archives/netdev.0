From: Ian Campbell <ian.campbell@citrix.com>
Subject: [PATCH 19/75] bnx2x: convert to SKB paged frag API.
Date: Fri, 19 Aug 2011 14:26:51 +0100
Message-ID: <1313760467-8598-19-git-send-email-ian.campbell@citrix.com>
References: <1313760393.5010.356.camel@zakaz.uk.xensource.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: linux-kernel@vger.kernel.org,
	Ian Campbell <ian.campbell@citrix.com>,
	Eilon Greenstein <eilong@broadcom.com>
To: netdev@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1313760393.5010.356.camel@zakaz.uk.xensource.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Signed-off-by: Ian Campbell <ian.campbell@citrix.com>
Cc: Eilon Greenstein <eilong@broadcom.com>
Cc: netdev@vger.kernel.org
Cc: linux-kernel@vger.kernel.org
---
 drivers/net/bnx2x/bnx2x_cmn.c |    5 ++---
 1 files changed, 2 insertions(+), 3 deletions(-)

diff --git a/drivers/net/bnx2x/bnx2x_cmn.c b/drivers/net/bnx2x/bnx2x_cmn.c
index 37e5790..c6689f6 100644
--- a/drivers/net/bnx2x/bnx2x_cmn.c
+++ b/drivers/net/bnx2x/bnx2x_cmn.c
@@ -2794,9 +2794,8 @@ netdev_tx_t bnx2x_start_xmit(struct sk_buff *skb, struct net_device *dev)
 	for (i = 0; i < skb_shinfo(skb)->nr_frags; i++) {
 		skb_frag_t *frag = &skb_shinfo(skb)->frags[i];
 
-		mapping = dma_map_page(&bp->pdev->dev, frag->page,
-				       frag->page_offset, frag->size,
-				       DMA_TO_DEVICE);
+		mapping = skb_frag_dma_map(&bp->pdev->dev, frag, 0, frag->size,
+					   DMA_TO_DEVICE);
 		if (unlikely(dma_mapping_error(&bp->pdev->dev, mapping))) {
 
 			DP(NETIF_MSG_TX_QUEUED, "Unable to map page - "
-- 
1.7.2.5
