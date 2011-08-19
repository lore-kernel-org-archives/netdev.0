From: Ian Campbell <ian.campbell@citrix.com>
Subject: [PATCH 51/75] stmmac: convert to SKB paged frag API.
Date: Fri, 19 Aug 2011 14:27:23 +0100
Message-ID: <1313760467-8598-51-git-send-email-ian.campbell@citrix.com>
References: <1313760393.5010.356.camel@zakaz.uk.xensource.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: linux-kernel@vger.kernel.org,
	Ian Campbell <ian.campbell@citrix.com>,
	Giuseppe Cavallaro <peppe.cavallaro@st.com>
To: netdev@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1313760393.5010.356.camel@zakaz.uk.xensource.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Signed-off-by: Ian Campbell <ian.campbell@citrix.com>
Cc: Giuseppe Cavallaro <peppe.cavallaro@st.com>
Cc: netdev@vger.kernel.org
Cc: linux-kernel@vger.kernel.org
---
 drivers/net/stmmac/stmmac_main.c |    5 ++---
 1 files changed, 2 insertions(+), 3 deletions(-)

diff --git a/drivers/net/stmmac/stmmac_main.c b/drivers/net/stmmac/stmmac_main.c
index c6e567e..3f5249c 100644
--- a/drivers/net/stmmac/stmmac_main.c
+++ b/drivers/net/stmmac/stmmac_main.c
@@ -1036,9 +1036,8 @@ static netdev_tx_t stmmac_xmit(struct sk_buff *skb, struct net_device *dev)
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
