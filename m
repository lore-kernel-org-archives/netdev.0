From: Jarek Poplawski <jarkao2@gmail.com>
Subject: [PATCH net-2.6 v2] epic100: hamachi: yellowfin: Fix skb allocation
 size
Date: Sat, 25 Dec 2010 18:39:59 +0100
Message-ID: <20101225173959.GB2264@del.dom.local>
References: <4D122093.6060900@scarlet.be>
 <1293035100.3027.247.camel@edumazet-laptop>
 <4D132C5F.8090404@scarlet.be>
 <1293106348.7789.5.camel@edumazet-laptop>
 <20101223202523.GA1913@del.dom.local>
 <4D148271.8030509@scarlet.be>
 <20101224151325.GA1895@del.dom.local>
 <20101225121044.GA1841@del.dom.local>
 <4D15F6C9.50700@scarlet.be>
 <20101225151217.GA1994@del.dom.local>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Joel Soete <soete.joel@scarlet.be>,
	Eric Dumazet <eric.dumazet@gmail.com>,
	Andrew Morton <akpm@linux-foundation.org>,
	Linux Kernel <linux-kernel@vger.kernel.org>,
	netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <20101225151217.GA1994@del.dom.local>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Joel Soete reported oopses during pppoe over sundance NIC, caused by
a bug in skb allocation and dma mapping code, where skb_reserve()
bytes weren't taken into account. As a followup to the patch:
"sundance: Fix oopses with corrupted skb_shared_info" very similar
code is fixed here for three other drivers.

Signed-off-by: Jarek Poplawski <jarkao2@gmail.com>
Cc: Joel Soete <soete.joel@scarlet.be>
Cc: Eric Dumazet <eric.dumazet@gmail.com>
---
v2: a tiny changelog fix only

 drivers/net/epic100.c   |    4 ++--
 drivers/net/hamachi.c   |    4 ++--
 drivers/net/yellowfin.c |    4 ++--
 3 files changed, 6 insertions(+), 6 deletions(-)

diff --git a/drivers/net/epic100.c b/drivers/net/epic100.c
index aa56963..c353bf3 100644
--- a/drivers/net/epic100.c
+++ b/drivers/net/epic100.c
@@ -935,7 +935,7 @@ static void epic_init_ring(struct net_device *dev)
 
 	/* Fill in the Rx buffers.  Handle allocation failure gracefully. */
 	for (i = 0; i < RX_RING_SIZE; i++) {
-		struct sk_buff *skb = dev_alloc_skb(ep->rx_buf_sz);
+		struct sk_buff *skb = dev_alloc_skb(ep->rx_buf_sz + 2);
 		ep->rx_skbuff[i] = skb;
 		if (skb == NULL)
 			break;
@@ -1233,7 +1233,7 @@ static int epic_rx(struct net_device *dev, int budget)
 		entry = ep->dirty_rx % RX_RING_SIZE;
 		if (ep->rx_skbuff[entry] == NULL) {
 			struct sk_buff *skb;
-			skb = ep->rx_skbuff[entry] = dev_alloc_skb(ep->rx_buf_sz);
+			skb = ep->rx_skbuff[entry] = dev_alloc_skb(ep->rx_buf_sz + 2);
 			if (skb == NULL)
 				break;
 			skb_reserve(skb, 2);	/* Align IP on 16 byte boundaries */
diff --git a/drivers/net/hamachi.c b/drivers/net/hamachi.c
index 9a64858..80d25ed 100644
--- a/drivers/net/hamachi.c
+++ b/drivers/net/hamachi.c
@@ -1202,7 +1202,7 @@ static void hamachi_init_ring(struct net_device *dev)
 	}
 	/* Fill in the Rx buffers.  Handle allocation failure gracefully. */
 	for (i = 0; i < RX_RING_SIZE; i++) {
-		struct sk_buff *skb = dev_alloc_skb(hmp->rx_buf_sz);
+		struct sk_buff *skb = dev_alloc_skb(hmp->rx_buf_sz + 2);
 		hmp->rx_skbuff[i] = skb;
 		if (skb == NULL)
 			break;
@@ -1669,7 +1669,7 @@ static int hamachi_rx(struct net_device *dev)
 		entry = hmp->dirty_rx % RX_RING_SIZE;
 		desc = &(hmp->rx_ring[entry]);
 		if (hmp->rx_skbuff[entry] == NULL) {
-			struct sk_buff *skb = dev_alloc_skb(hmp->rx_buf_sz);
+			struct sk_buff *skb = dev_alloc_skb(hmp->rx_buf_sz + 2);
 
 			hmp->rx_skbuff[entry] = skb;
 			if (skb == NULL)
diff --git a/drivers/net/yellowfin.c b/drivers/net/yellowfin.c
index cd1b3dc..ec47e22 100644
--- a/drivers/net/yellowfin.c
+++ b/drivers/net/yellowfin.c
@@ -744,7 +744,7 @@ static int yellowfin_init_ring(struct net_device *dev)
 	}
 
 	for (i = 0; i < RX_RING_SIZE; i++) {
-		struct sk_buff *skb = dev_alloc_skb(yp->rx_buf_sz);
+		struct sk_buff *skb = dev_alloc_skb(yp->rx_buf_sz + 2);
 		yp->rx_skbuff[i] = skb;
 		if (skb == NULL)
 			break;
@@ -1157,7 +1157,7 @@ static int yellowfin_rx(struct net_device *dev)
 	for (; yp->cur_rx - yp->dirty_rx > 0; yp->dirty_rx++) {
 		entry = yp->dirty_rx % RX_RING_SIZE;
 		if (yp->rx_skbuff[entry] == NULL) {
-			struct sk_buff *skb = dev_alloc_skb(yp->rx_buf_sz);
+			struct sk_buff *skb = dev_alloc_skb(yp->rx_buf_sz + 2);
 			if (skb == NULL)
 				break;				/* Better luck next round. */
 			yp->rx_skbuff[entry] = skb;
