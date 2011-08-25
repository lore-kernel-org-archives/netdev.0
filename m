From: Ian Campbell <ian.campbell@citrix.com>
Subject: [PATCH 7/9] bnx2x: convert to SKB paged frag API.
Date: Thu, 25 Aug 2011 09:28:13 +0100
Message-ID: <1314260895-15936-7-git-send-email-ian.campbell@citrix.com>
References: <1314260881.10283.48.camel@zakaz.uk.xensource.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: Ian Campbell <ian.campbell@citrix.com>,
	Eilon Greenstein <eilong@broadcom.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.citrix.com ([66.165.176.89]:37967 "EHLO SMTP.CITRIX.COM"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751837Ab1HYI22 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 25 Aug 2011 04:28:28 -0400
In-Reply-To: <1314260881.10283.48.camel@zakaz.uk.xensource.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Signed-off-by: Ian Campbell <ian.campbell@citrix.com>
Reviewed-by: Konrad Rzeszutek Wilk <konrad.wilk@oracle.com>
Cc: Eilon Greenstein <eilong@broadcom.com>
Cc: netdev@vger.kernel.org
---
 drivers/net/ethernet/broadcom/bnx2x/bnx2x_cmn.c |    5 ++---
 1 files changed, 2 insertions(+), 3 deletions(-)

diff --git a/drivers/net/ethernet/broadcom/bnx2x/bnx2x_cmn.c b/drivers/net/ethernet/broadcom/bnx2x/bnx2x_cmn.c
index 93bff08..5c3eb17 100644
--- a/drivers/net/ethernet/broadcom/bnx2x/bnx2x_cmn.c
+++ b/drivers/net/ethernet/broadcom/bnx2x/bnx2x_cmn.c
@@ -2800,9 +2800,8 @@ netdev_tx_t bnx2x_start_xmit(struct sk_buff *skb, struct net_device *dev)
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
