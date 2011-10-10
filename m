From: Ian Campbell <ian.campbell@citrix.com>
Subject: [PATCH 7/9] emac: convert to SKB paged frag API.
Date: Mon, 10 Oct 2011 12:11:39 +0100
Message-ID: <1318245101-16890-7-git-send-email-ian.campbell@citrix.com>
References: <1318245076.21903.408.camel@zakaz.uk.xensource.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: Ian Campbell <ian.campbell@citrix.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp02.citrix.com ([66.165.176.63]:44685 "EHLO
	SMTP02.CITRIX.COM" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753733Ab1JJLLx (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 10 Oct 2011 07:11:53 -0400
In-Reply-To: <1318245076.21903.408.camel@zakaz.uk.xensource.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Signed-off-by: Ian Campbell <ian.campbell@citrix.com>
Cc: netdev@vger.kernel.org
---
 drivers/net/ethernet/ibm/emac/core.c |    4 ++--
 1 files changed, 2 insertions(+), 2 deletions(-)

diff --git a/drivers/net/ethernet/ibm/emac/core.c b/drivers/net/ethernet/ibm/emac/core.c
index a573df1..6b3a033 100644
--- a/drivers/net/ethernet/ibm/emac/core.c
+++ b/drivers/net/ethernet/ibm/emac/core.c
@@ -1458,8 +1458,8 @@ static int emac_start_xmit_sg(struct sk_buff *skb, struct net_device *ndev)
 		if (unlikely(dev->tx_cnt + mal_tx_chunks(len) >= NUM_TX_BUFF))
 			goto undo_frame;
 
-		pd = dma_map_page(&dev->ofdev->dev, frag->page, frag->page_offset, len,
-				  DMA_TO_DEVICE);
+		pd = skb_frag_dma_map(&dev->ofdev->dev, frag, 0, len,
+				      DMA_TO_DEVICE);
 
 		slot = emac_xmit_split(dev, slot, pd, len, i == nr_frags - 1,
 				       ctrl);
-- 
1.7.2.5
