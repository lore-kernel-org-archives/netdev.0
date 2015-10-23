From: Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>
Subject: [PATCH 1/2] sh_eth: fix RX buffer size alignment
Date: Sat, 24 Oct 2015 00:46:03 +0300
Message-ID: <1685698.osUG5igxWz@wasted.cogentembedded.com>
References: <2249923.hKhT9K6gME@wasted.cogentembedded.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7Bit
Cc: linux-sh@vger.kernel.org
To: netdev@vger.kernel.org
Return-path: <linux-sh-owner@vger.kernel.org>
In-Reply-To: <2249923.hKhT9K6gME@wasted.cogentembedded.com>
Sender: linux-sh-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Both  Renesas R-Car and RZ/A1 manuals state that RX buffer  length must be
a multiple of 32 bytes, while the driver  only uses 16 byte granularity...

Signed-off-by: Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>

---
 drivers/net/ethernet/renesas/sh_eth.c |   10 +++++-----
 1 file changed, 5 insertions(+), 5 deletions(-)

Index: net/drivers/net/ethernet/renesas/sh_eth.c
===================================================================
--- net.orig/drivers/net/ethernet/renesas/sh_eth.c
+++ net/drivers/net/ethernet/renesas/sh_eth.c
@@ -1148,8 +1148,8 @@ static void sh_eth_ring_format(struct ne
 
 		/* RX descriptor */
 		rxdesc = &mdp->rx_ring[i];
-		/* The size of the buffer is a multiple of 16 bytes. */
-		rxdesc->buffer_length = ALIGN(mdp->rx_buf_sz, 16);
+		/* The size of the buffer is a multiple of 32 bytes. */
+		rxdesc->buffer_length = ALIGN(mdp->rx_buf_sz, 32);
 		dma_addr = dma_map_single(&ndev->dev, skb->data,
 					  rxdesc->buffer_length,
 					  DMA_FROM_DEVICE);
@@ -1506,7 +1506,7 @@ static int sh_eth_rx(struct net_device *
 			if (mdp->cd->rpadir)
 				skb_reserve(skb, NET_IP_ALIGN);
 			dma_unmap_single(&ndev->dev, rxdesc->addr,
-					 ALIGN(mdp->rx_buf_sz, 16),
+					 ALIGN(mdp->rx_buf_sz, 32),
 					 DMA_FROM_DEVICE);
 			skb_put(skb, pkt_len);
 			skb->protocol = eth_type_trans(skb, ndev);
@@ -1524,8 +1524,8 @@ static int sh_eth_rx(struct net_device *
 	for (; mdp->cur_rx - mdp->dirty_rx > 0; mdp->dirty_rx++) {
 		entry = mdp->dirty_rx % mdp->num_rx_ring;
 		rxdesc = &mdp->rx_ring[entry];
-		/* The size of the buffer is 16 byte boundary. */
-		rxdesc->buffer_length = ALIGN(mdp->rx_buf_sz, 16);
+		/* The size of the buffer is 32 byte boundary. */
+		rxdesc->buffer_length = ALIGN(mdp->rx_buf_sz, 32);
 
 		if (mdp->rx_skbuff[entry] == NULL) {
 			skb = netdev_alloc_skb(ndev, skbuff_size);

