From: Ian Campbell <ian.campbell@citrix.com>
Subject: [PATCH 13/14] gianfar: convert to SKB paged frag API.
Date: Tue, 30 Aug 2011 10:18:29 +0100
Message-ID: <1314695910-22344-13-git-send-email-ian.campbell@citrix.com>
References: <1314695847.10283.102.camel@zakaz.uk.xensource.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: Ian Campbell <ian.campbell@citrix.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp02.citrix.com ([66.165.176.63]:34590 "EHLO
	SMTP02.CITRIX.COM" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752937Ab1H3JSv (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 30 Aug 2011 05:18:51 -0400
In-Reply-To: <1314695847.10283.102.camel@zakaz.uk.xensource.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Signed-off-by: Ian Campbell <ian.campbell@citrix.com>
Cc: netdev@vger.kernel.org
---
 drivers/net/ethernet/freescale/gianfar.c |   10 +++++-----
 1 files changed, 5 insertions(+), 5 deletions(-)

diff --git a/drivers/net/ethernet/freescale/gianfar.c b/drivers/net/ethernet/freescale/gianfar.c
index 81d409d..83199fd 100644
--- a/drivers/net/ethernet/freescale/gianfar.c
+++ b/drivers/net/ethernet/freescale/gianfar.c
@@ -2140,11 +2140,11 @@ static int gfar_start_xmit(struct sk_buff *skb, struct net_device *dev)
 			if (i == nr_frags - 1)
 				lstatus |= BD_LFLAG(TXBD_LAST | TXBD_INTERRUPT);
 
-			bufaddr = dma_map_page(&priv->ofdev->dev,
-					skb_shinfo(skb)->frags[i].page,
-					skb_shinfo(skb)->frags[i].page_offset,
-					length,
-					DMA_TO_DEVICE);
+			bufaddr = skb_frag_dma_map(&priv->ofdev->dev,
+						   &skb_shinfo(skb)->frags[i],
+						   0,
+						   length,
+						   DMA_TO_DEVICE);
 
 			/* set the TxBD length and buffer pointer */
 			txbdp->bufPtr = bufaddr;
-- 
1.7.2.5
