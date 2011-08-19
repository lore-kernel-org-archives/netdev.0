From: Ian Campbell <ian.campbell@citrix.com>
Subject: [PATCH 56/75] tsi108: convert to SKB paged frag API.
Date: Fri, 19 Aug 2011 14:27:28 +0100
Message-ID: <1313760467-8598-56-git-send-email-ian.campbell@citrix.com>
References: <1313760393.5010.356.camel@zakaz.uk.xensource.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: linux-kernel@vger.kernel.org,
	Ian Campbell <ian.campbell@citrix.com>,
	"David S. Miller" <davem@davemloft.net>,
	Eric Dumazet <eric.dumazet@gmail.com>,
	Alexey Dobriyan <adobriyan@gmail.com>
To: netdev@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1313760393.5010.356.camel@zakaz.uk.xensource.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Signed-off-by: Ian Campbell <ian.campbell@citrix.com>
Cc: "David S. Miller" <davem@davemloft.net>
Cc: Eric Dumazet <eric.dumazet@gmail.com>
Cc: Alexey Dobriyan <adobriyan@gmail.com>
Cc: netdev@vger.kernel.org
Cc: linux-kernel@vger.kernel.org
---
 drivers/net/tsi108_eth.c |    7 ++++---
 1 files changed, 4 insertions(+), 3 deletions(-)

diff --git a/drivers/net/tsi108_eth.c b/drivers/net/tsi108_eth.c
index 64cb9ac..6f4deee 100644
--- a/drivers/net/tsi108_eth.c
+++ b/drivers/net/tsi108_eth.c
@@ -711,9 +711,10 @@ static int tsi108_send_packet(struct sk_buff * skb, struct net_device *dev)
 		} else {
 			skb_frag_t *frag = &skb_shinfo(skb)->frags[i - 1];
 
-			data->txring[tx].buf0 =
-			    dma_map_page(NULL, frag->page, frag->page_offset,
-					    frag->size, DMA_TO_DEVICE);
+			data->txring[tx].buf0 = skb_frag_dma_map(NULL, frag,
+								 0,
+								 frag->size,
+								 DMA_TO_DEVICE);
 			data->txring[tx].len = frag->size;
 		}
 
-- 
1.7.2.5
