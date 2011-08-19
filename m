From: Ian Campbell <ian.campbell@citrix.com>
Subject: [PATCH 28/75] gianfar: convert to SKB paged frag API.
Date: Fri, 19 Aug 2011 14:27:00 +0100
Message-ID: <1313760467-8598-28-git-send-email-ian.campbell@citrix.com>
References: <1313760393.5010.356.camel@zakaz.uk.xensource.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: linux-kernel@vger.kernel.org,
	Ian Campbell <ian.campbell@citrix.com>,
	Grant Likely <grant.likely@secretlab.ca>,
	"David S. Miller" <davem@davemloft.net>,
	Joe Perches <joe@perches.com>,
	Sebastian Poehn <sebastian.poehn@belden.com>,
	Eric Dumazet <eric.dumazet@gmail.com>,
	devicetree-discuss@lists.ozlabs.org
To: netdev@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1313760393.5010.356.camel@zakaz.uk.xensource.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Signed-off-by: Ian Campbell <ian.campbell@citrix.com>
Cc: Grant Likely <grant.likely@secretlab.ca>
Cc: "David S. Miller" <davem@davemloft.net>
Cc: Joe Perches <joe@perches.com>
Cc: Sebastian Poehn <sebastian.poehn@belden.com>
Cc: Eric Dumazet <eric.dumazet@gmail.com>
Cc: netdev@vger.kernel.org
Cc: linux-kernel@vger.kernel.org
Cc: devicetree-discuss@lists.ozlabs.org
---
 drivers/net/gianfar.c |   10 +++++-----
 1 files changed, 5 insertions(+), 5 deletions(-)

diff --git a/drivers/net/gianfar.c b/drivers/net/gianfar.c
index 2659daa..6586937 100644
--- a/drivers/net/gianfar.c
+++ b/drivers/net/gianfar.c
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
