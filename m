From: Ian Campbell <ian.campbell@citrix.com>
Subject: [PATCH 06/14] stmmac: convert to SKB paged frag API.
Date: Thu, 22 Sep 2011 08:53:20 +0100
Message-ID: <1316678008-16842-6-git-send-email-ian.campbell@citrix.com>
References: <1316677996.23371.10.camel@zakaz.uk.xensource.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: Ian Campbell <ian.campbell@citrix.com>,
	Giuseppe Cavallaro <peppe.cavallaro@st.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp02.citrix.com ([66.165.176.63]:47636 "EHLO
	SMTP02.CITRIX.COM" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751528Ab1IVHxm (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 22 Sep 2011 03:53:42 -0400
In-Reply-To: <1316677996.23371.10.camel@zakaz.uk.xensource.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Signed-off-by: Ian Campbell <ian.campbell@citrix.com>
Cc: Giuseppe Cavallaro <peppe.cavallaro@st.com>
Cc: netdev@vger.kernel.org
---
 drivers/net/ethernet/stmicro/stmmac/stmmac_main.c |    5 ++---
 1 files changed, 2 insertions(+), 3 deletions(-)

diff --git a/drivers/net/ethernet/stmicro/stmmac/stmmac_main.c b/drivers/net/ethernet/stmicro/stmmac/stmmac_main.c
index d0fbc54..c0ee6b6 100644
--- a/drivers/net/ethernet/stmicro/stmmac/stmmac_main.c
+++ b/drivers/net/ethernet/stmicro/stmmac/stmmac_main.c
@@ -1113,9 +1113,8 @@ static netdev_tx_t stmmac_xmit(struct sk_buff *skb, struct net_device *dev)
 		desc = priv->dma_tx + entry;
 
 		TX_DBG("\t[entry %d] segment len: %d\n", entry, len);
-		desc->des2 = dma_map_page(priv->device, frag->page,
-					  frag->page_offset,
-					  len, DMA_TO_DEVICE);
+		desc->des2 = skb_frag_dma_map(priv->device, frag, 0, len,
+					      DMA_TO_DEVICE);
 		priv->tx_skbuff[entry] = NULL;
 		priv->hw->desc->prepare_tx_desc(desc, 0, len, csum_insertion);
 		wmb();
-- 
1.7.2.5
