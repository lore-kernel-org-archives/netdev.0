From: "Pradeep A. Dalvi" <netdev@pradeepdalvi.com>
Subject: [PATCH/RESEND net 2/5][TRIVIAL 2/4] drivers/net/ethernet: dev_alloc_skb to netdev_alloc_skb
Date: Tue, 24 Jan 2012 03:24:11 +0530
Message-ID: <1327355651-7567-1-git-send-email-netdev@pradeepdalvi.com>
Mime-Version: 1.0
Cc: "David S. Miller" <davem@davemloft.net>,
	linux-kernel@vger.kernel.org,
	Eric Dumazet <eric.dumazet@gmail.com>,
	"Pradeep A. Dalvi" <netdev@pradeepdalvi.com>
To: netdev@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Replaced deprecating dev_alloc_skb with netdev_alloc_skb in drivers/net/ethernet
  - Removed extra skb->dev = dev after netdev_alloc_skb

Signed-off-by: Pradeep A. Dalvi <netdev@pradeepdalvi.com>
---
 drivers/net/ethernet/cadence/macb.c                   |    2 +-
 drivers/net/ethernet/cirrus/cs89x0.c                  |    4 ++--
 drivers/net/ethernet/cirrus/ep93xx_eth.c              |    2 +-
 drivers/net/ethernet/davicom/dm9000.c                 |    2 +-
 drivers/net/ethernet/dec/ewrk3.c                      |    4 +++-
 drivers/net/ethernet/dec/tulip/de2104x.c              |    6 ++----
 drivers/net/ethernet/dec/tulip/de4x5.c                |    4 ++--
 drivers/net/ethernet/dec/tulip/interrupt.c            |    8 ++++----
 drivers/net/ethernet/dec/tulip/tulip_core.c           |    5 ++---
 drivers/net/ethernet/dec/tulip/winbond-840.c          |    6 +++---
 drivers/net/ethernet/dec/tulip/xircom_cb.c            |    2 +-
 drivers/net/ethernet/dlink/de600.c                    |    2 +-
 drivers/net/ethernet/dlink/de620.c                    |    2 +-
 drivers/net/ethernet/dlink/sundance.c                 |    9 ++++-----
 drivers/net/ethernet/dnet.c                           |    2 +-
 drivers/net/ethernet/fealnx.c                         |    8 +++-----
 drivers/net/ethernet/freescale/fec.c                  |    4 ++--
 drivers/net/ethernet/freescale/fec_mpc52xx.c          |    4 ++--
 drivers/net/ethernet/freescale/fs_enet/fs_enet-main.c |   12 ++++++------
 drivers/net/ethernet/freescale/ucc_geth.c             |    7 +++----
 drivers/net/ethernet/fujitsu/at1700.c                 |    2 +-
 21 files changed, 46 insertions(+), 51 deletions(-)

diff --git a/drivers/net/ethernet/cadence/macb.c b/drivers/net/ethernet/cadence/macb.c
index 2320068..a9d8d5d 100644
--- a/drivers/net/ethernet/cadence/macb.c
+++ b/drivers/net/ethernet/cadence/macb.c
@@ -397,7 +397,7 @@ static int macb_rx_frame(struct macb *bp, unsigned int first_frag,
 	netdev_dbg(bp->dev, "macb_rx_frame frags %u - %u (len %u)\n",
 		   first_frag, last_frag, len);
 
-	skb = dev_alloc_skb(len + RX_OFFSET);
+	skb = netdev_alloc_skb(bp->dev, len + RX_OFFSET);
 	if (!skb) {
 		bp->stats.rx_dropped++;
 		for (frag = first_frag; ; frag = NEXT_RX(frag)) {
diff --git a/drivers/net/ethernet/cirrus/cs89x0.c b/drivers/net/ethernet/cirrus/cs89x0.c
index f328da2..d5ff936 100644
--- a/drivers/net/ethernet/cirrus/cs89x0.c
+++ b/drivers/net/ethernet/cirrus/cs89x0.c
@@ -911,7 +911,7 @@ dma_rx(struct net_device *dev)
 	}
 
 	/* Malloc up new buffer. */
-	skb = dev_alloc_skb(length + 2);
+	skb = netdev_alloc_skb(dev, length + 2);
 	if (skb == NULL) {
 		if (net_debug)	/* I don't think we want to do this to a stressed system */
 			printk("%s: Memory squeeze, dropping packet.\n", dev->name);
@@ -1616,7 +1616,7 @@ net_rx(struct net_device *dev)
 	}
 
 	/* Malloc up new buffer. */
-	skb = dev_alloc_skb(length + 2);
+	skb = netdev_alloc_skb(dev, length + 2);
 	if (skb == NULL) {
 #if 0		/* Again, this seems a cruel thing to do */
 		printk(KERN_WARNING "%s: Memory squeeze, dropping packet.\n", dev->name);
diff --git a/drivers/net/ethernet/cirrus/ep93xx_eth.c b/drivers/net/ethernet/cirrus/ep93xx_eth.c
index 4317af8..c21e5ab 100644
--- a/drivers/net/ethernet/cirrus/ep93xx_eth.c
+++ b/drivers/net/ethernet/cirrus/ep93xx_eth.c
@@ -282,7 +282,7 @@ static int ep93xx_rx(struct net_device *dev, int processed, int budget)
 		if (rstat0 & RSTAT0_CRCI)
 			length -= 4;
 
-		skb = dev_alloc_skb(length + 2);
+		skb = netdev_alloc_skb(dev, length + 2);
 		if (likely(skb != NULL)) {
 			struct ep93xx_rdesc *rxd = &ep->descs->rdesc[entry];
 			skb_reserve(skb, 2);
diff --git a/drivers/net/ethernet/davicom/dm9000.c b/drivers/net/ethernet/davicom/dm9000.c
index f801754..9087817 100644
--- a/drivers/net/ethernet/davicom/dm9000.c
+++ b/drivers/net/ethernet/davicom/dm9000.c
@@ -1028,7 +1028,7 @@ dm9000_rx(struct net_device *dev)
 
 		/* Move data from DM9000 */
 		if (GoodPacket &&
-		    ((skb = dev_alloc_skb(RxLen + 4)) != NULL)) {
+		    ((skb = netdev_alloc_skb(dev, RxLen + 4)) != NULL)) {
 			skb_reserve(skb, 2);
 			rdptr = (u8 *) skb_put(skb, RxLen - 4);
 
diff --git a/drivers/net/ethernet/dec/ewrk3.c b/drivers/net/ethernet/dec/ewrk3.c
index f9df5e4..1879f84 100644
--- a/drivers/net/ethernet/dec/ewrk3.c
+++ b/drivers/net/ethernet/dec/ewrk3.c
@@ -986,8 +986,10 @@ static int ewrk3_rx(struct net_device *dev)
 						dev->stats.rx_fifo_errors++;
 				} else {
 					struct sk_buff *skb;
+					skb = netdev_alloc_skb(dev,
+							pkt_len + 2);
 
-					if ((skb = dev_alloc_skb(pkt_len + 2)) != NULL) {
+					if (skb != NULL) {
 						unsigned char *p;
 						skb_reserve(skb, 2);	/* Align to 16 bytes */
 						p = skb_put(skb, pkt_len);
diff --git a/drivers/net/ethernet/dec/tulip/de2104x.c b/drivers/net/ethernet/dec/tulip/de2104x.c
index 1eb46a0..68f1c39 100644
--- a/drivers/net/ethernet/dec/tulip/de2104x.c
+++ b/drivers/net/ethernet/dec/tulip/de2104x.c
@@ -439,7 +439,7 @@ static void de_rx (struct de_private *de)
 			  rx_tail, status, len, copying_skb);
 
 		buflen = copying_skb ? (len + RX_OFFSET) : de->rx_buf_sz;
-		copy_skb = dev_alloc_skb (buflen);
+		copy_skb = netdev_alloc_skb(de->dev, buflen);
 		if (unlikely(!copy_skb)) {
 			de->net_stats.rx_dropped++;
 			drop = 1;
@@ -1283,12 +1283,10 @@ static int de_refill_rx (struct de_private *de)
 	for (i = 0; i < DE_RX_RING_SIZE; i++) {
 		struct sk_buff *skb;
 
-		skb = dev_alloc_skb(de->rx_buf_sz);
+		skb = netdev_alloc_skb(de->dev, de->rx_buf_sz);
 		if (!skb)
 			goto err_out;
 
-		skb->dev = de->dev;
-
 		de->rx_skb[i].mapping = pci_map_single(de->pdev,
 			skb->data, de->rx_buf_sz, PCI_DMA_FROMDEVICE);
 		de->rx_skb[i].skb = skb;
diff --git a/drivers/net/ethernet/dec/tulip/de4x5.c b/drivers/net/ethernet/dec/tulip/de4x5.c
index 4d71f5a..3f89eae 100644
--- a/drivers/net/ethernet/dec/tulip/de4x5.c
+++ b/drivers/net/ethernet/dec/tulip/de4x5.c
@@ -3598,7 +3598,7 @@ de4x5_alloc_rx_buff(struct net_device *dev, int index, int len)
     struct sk_buff *ret;
     u_long i=0, tmp;
 
-    p = dev_alloc_skb(IEEE802_3_SZ + DE4X5_ALIGN + 2);
+	p = netdev_alloc_skb(dev, IEEE802_3_SZ + DE4X5_ALIGN + 2);
     if (!p) return NULL;
 
     tmp = virt_to_bus(p->data);
@@ -3618,7 +3618,7 @@ de4x5_alloc_rx_buff(struct net_device *dev, int index, int len)
 #else
     if (lp->state != OPEN) return (struct sk_buff *)1; /* Fake out the open */
 
-    p = dev_alloc_skb(len + 2);
+	p = netdev_alloc_skb(dev, len + 2);
     if (!p) return NULL;
 
     skb_reserve(p, 2);	                               /* Align */
diff --git a/drivers/net/ethernet/dec/tulip/interrupt.c b/drivers/net/ethernet/dec/tulip/interrupt.c
index 4fb8c8c..026e893 100644
--- a/drivers/net/ethernet/dec/tulip/interrupt.c
+++ b/drivers/net/ethernet/dec/tulip/interrupt.c
@@ -69,7 +69,8 @@ int tulip_refill_rx(struct net_device *dev)
 			struct sk_buff *skb;
 			dma_addr_t mapping;
 
-			skb = tp->rx_buffers[entry].skb = dev_alloc_skb(PKT_BUF_SZ);
+			skb = tp->rx_buffers[entry].skb =
+				netdev_alloc_skb(dev, PKT_BUF_SZ);
 			if (skb == NULL)
 				break;
 
@@ -77,7 +78,6 @@ int tulip_refill_rx(struct net_device *dev)
 						 PCI_DMA_FROMDEVICE);
 			tp->rx_buffers[entry].mapping = mapping;
 
-			skb->dev = dev;			/* Mark as being used by this device. */
 			tp->rx_ring[entry].buffer1 = cpu_to_le32(mapping);
 			refilled++;
 		}
@@ -202,7 +202,7 @@ int tulip_poll(struct napi_struct *napi, int budget)
                                /* Check if the packet is long enough to accept without copying
                                   to a minimally-sized skbuff. */
                                if (pkt_len < tulip_rx_copybreak &&
-                                   (skb = dev_alloc_skb(pkt_len + 2)) != NULL) {
+                                   (skb = netdev_alloc_skb(dev, pkt_len + 2)) != NULL) {
                                        skb_reserve(skb, 2);    /* 16 byte align the IP header */
                                        pci_dma_sync_single_for_cpu(tp->pdev,
 								   tp->rx_buffers[entry].mapping,
@@ -428,7 +428,7 @@ static int tulip_rx(struct net_device *dev)
 			/* Check if the packet is long enough to accept without copying
 			   to a minimally-sized skbuff. */
 			if (pkt_len < tulip_rx_copybreak &&
-			    (skb = dev_alloc_skb(pkt_len + 2)) != NULL) {
+			    (skb = netdev_alloc_skb(dev, pkt_len + 2)) != NULL) {
 				skb_reserve(skb, 2);	/* 16 byte align the IP header */
 				pci_dma_sync_single_for_cpu(tp->pdev,
 							    tp->rx_buffers[entry].mapping,
diff --git a/drivers/net/ethernet/dec/tulip/tulip_core.c b/drivers/net/ethernet/dec/tulip/tulip_core.c
index 4eb0d76..3c3ce7c 100644
--- a/drivers/net/ethernet/dec/tulip/tulip_core.c
+++ b/drivers/net/ethernet/dec/tulip/tulip_core.c
@@ -636,16 +636,15 @@ static void tulip_init_ring(struct net_device *dev)
 		dma_addr_t mapping;
 
 		/* Note the receive buffer must be longword aligned.
-		   dev_alloc_skb() provides 16 byte alignment.  But do *not*
+		   netdev_alloc_skb() provides 16 byte alignment.  But do *not*
 		   use skb_reserve() to align the IP header! */
-		struct sk_buff *skb = dev_alloc_skb(PKT_BUF_SZ);
+		struct sk_buff *skb = netdev_alloc_skb(dev, PKT_BUF_SZ);
 		tp->rx_buffers[i].skb = skb;
 		if (skb == NULL)
 			break;
 		mapping = pci_map_single(tp->pdev, skb->data,
 					 PKT_BUF_SZ, PCI_DMA_FROMDEVICE);
 		tp->rx_buffers[i].mapping = mapping;
-		skb->dev = dev;			/* Mark as being used by this device. */
 		tp->rx_ring[i].status = cpu_to_le32(DescOwned);	/* Owned by Tulip chip */
 		tp->rx_ring[i].buffer1 = cpu_to_le32(mapping);
 	}
diff --git a/drivers/net/ethernet/dec/tulip/winbond-840.c b/drivers/net/ethernet/dec/tulip/winbond-840.c
index 52da7b2..2ac6fff 100644
--- a/drivers/net/ethernet/dec/tulip/winbond-840.c
+++ b/drivers/net/ethernet/dec/tulip/winbond-840.c
@@ -815,7 +815,7 @@ static void init_rxtx_rings(struct net_device *dev)
 
 	/* Fill in the Rx buffers.  Handle allocation failure gracefully. */
 	for (i = 0; i < RX_RING_SIZE; i++) {
-		struct sk_buff *skb = dev_alloc_skb(np->rx_buf_sz);
+		struct sk_buff *skb = netdev_alloc_skb(dev, np->rx_buf_sz);
 		np->rx_skbuff[i] = skb;
 		if (skb == NULL)
 			break;
@@ -1231,7 +1231,7 @@ static int netdev_rx(struct net_device *dev)
 			/* Check if the packet is long enough to accept without copying
 			   to a minimally-sized skbuff. */
 			if (pkt_len < rx_copybreak &&
-			    (skb = dev_alloc_skb(pkt_len + 2)) != NULL) {
+			    (skb = netdev_alloc_skb(dev, pkt_len + 2)) != NULL) {
 				skb_reserve(skb, 2);	/* 16 byte align the IP header */
 				pci_dma_sync_single_for_cpu(np->pci_dev,np->rx_addr[entry],
 							    np->rx_skbuff[entry]->len,
@@ -1270,7 +1270,7 @@ static int netdev_rx(struct net_device *dev)
 		struct sk_buff *skb;
 		entry = np->dirty_rx % RX_RING_SIZE;
 		if (np->rx_skbuff[entry] == NULL) {
-			skb = dev_alloc_skb(np->rx_buf_sz);
+			skb = netdev_alloc_skb(dev, np->rx_buf_sz);
 			np->rx_skbuff[entry] = skb;
 			if (skb == NULL)
 				break;			/* Better luck next round. */
diff --git a/drivers/net/ethernet/dec/tulip/xircom_cb.c b/drivers/net/ethernet/dec/tulip/xircom_cb.c
index 988b8eb..2483a3e 100644
--- a/drivers/net/ethernet/dec/tulip/xircom_cb.c
+++ b/drivers/net/ethernet/dec/tulip/xircom_cb.c
@@ -1085,7 +1085,7 @@ investigate_read_descriptor(struct net_device *dev, struct xircom_private *card,
 			pkt_len = 1518;
 		}
 
-		skb = dev_alloc_skb(pkt_len + 2);
+		skb = netdev_alloc_skb(dev, pkt_len + 2);
 		if (skb == NULL) {
 			dev->stats.rx_dropped++;
 			goto out;
diff --git a/drivers/net/ethernet/dlink/de600.c b/drivers/net/ethernet/dlink/de600.c
index c24fab1..682750c 100644
--- a/drivers/net/ethernet/dlink/de600.c
+++ b/drivers/net/ethernet/dlink/de600.c
@@ -335,7 +335,7 @@ static void de600_rx_intr(struct net_device *dev)
 		return;
 	}
 
-	skb = dev_alloc_skb(size+2);
+	skb = netdev_alloc_skb(dev, size + 2);
 	if (skb == NULL) {
 		printk("%s: Couldn't allocate a sk_buff of size %d.\n", dev->name, size);
 		return;
diff --git a/drivers/net/ethernet/dlink/de620.c b/drivers/net/ethernet/dlink/de620.c
index 3b934ab..afc5aaa 100644
--- a/drivers/net/ethernet/dlink/de620.c
+++ b/drivers/net/ethernet/dlink/de620.c
@@ -650,7 +650,7 @@ static int de620_rx_intr(struct net_device *dev)
 		printk(KERN_WARNING "%s: Illegal packet size: %d!\n", dev->name, size);
 	}
 	else { /* Good packet? */
-		skb = dev_alloc_skb(size+2);
+		skb = netdev_alloc_skb(dev, size + 2);
 		if (skb == NULL) { /* Yeah, but no place to put it... */
 			printk(KERN_WARNING "%s: Couldn't allocate a sk_buff of size %d.\n", dev->name, size);
 			dev->stats.rx_dropped++;
diff --git a/drivers/net/ethernet/dlink/sundance.c b/drivers/net/ethernet/dlink/sundance.c
index 28a3a9b..7227f29 100644
--- a/drivers/net/ethernet/dlink/sundance.c
+++ b/drivers/net/ethernet/dlink/sundance.c
@@ -1020,11 +1020,11 @@ static void init_ring(struct net_device *dev)
 
 	/* Fill in the Rx buffers.  Handle allocation failure gracefully. */
 	for (i = 0; i < RX_RING_SIZE; i++) {
-		struct sk_buff *skb = dev_alloc_skb(np->rx_buf_sz + 2);
+		struct sk_buff *skb =
+			netdev_alloc_skb(dev, np->rx_buf_sz + 2);
 		np->rx_skbuff[i] = skb;
 		if (skb == NULL)
 			break;
-		skb->dev = dev;		/* Mark as being used by this device. */
 		skb_reserve(skb, 2);	/* 16 byte align the IP header. */
 		np->rx_ring[i].frag[0].addr = cpu_to_le32(
 			dma_map_single(&np->pci_dev->dev, skb->data,
@@ -1358,7 +1358,7 @@ static void rx_poll(unsigned long data)
 			/* Check if the packet is long enough to accept without copying
 			   to a minimally-sized skbuff. */
 			if (pkt_len < rx_copybreak &&
-			    (skb = dev_alloc_skb(pkt_len + 2)) != NULL) {
+			    (skb = netdev_alloc_skb(dev, pkt_len + 2)) != NULL) {
 				skb_reserve(skb, 2);	/* 16 byte align the IP header */
 				dma_sync_single_for_cpu(&np->pci_dev->dev,
 						le32_to_cpu(desc->frag[0].addr),
@@ -1411,11 +1411,10 @@ static void refill_rx (struct net_device *dev)
 		struct sk_buff *skb;
 		entry = np->dirty_rx % RX_RING_SIZE;
 		if (np->rx_skbuff[entry] == NULL) {
-			skb = dev_alloc_skb(np->rx_buf_sz + 2);
+			skb = netdev_alloc_skb(dev, np->rx_buf_sz + 2);
 			np->rx_skbuff[entry] = skb;
 			if (skb == NULL)
 				break;		/* Better luck next round. */
-			skb->dev = dev;		/* Mark as being used by this device. */
 			skb_reserve(skb, 2);	/* Align IP on 16 byte boundaries */
 			np->rx_ring[entry].frag[0].addr = cpu_to_le32(
 				dma_map_single(&np->pci_dev->dev, skb->data,
diff --git a/drivers/net/ethernet/dnet.c b/drivers/net/ethernet/dnet.c
index 925c9ba..6b2f224 100644
--- a/drivers/net/ethernet/dnet.c
+++ b/drivers/net/ethernet/dnet.c
@@ -421,7 +421,7 @@ static int dnet_poll(struct napi_struct *napi, int budget)
 			printk(KERN_ERR "%s packet receive error %x\n",
 			       __func__, cmd_word);
 
-		skb = dev_alloc_skb(pkt_len + 5);
+		skb = netdev_alloc_skb(dev, pkt_len + 5);
 		if (skb != NULL) {
 			/* Align IP on 16 byte boundaries */
 			skb_reserve(skb, 2);
diff --git a/drivers/net/ethernet/fealnx.c b/drivers/net/ethernet/fealnx.c
index c82d444..1637b98 100644
--- a/drivers/net/ethernet/fealnx.c
+++ b/drivers/net/ethernet/fealnx.c
@@ -1070,14 +1070,13 @@ static void allocate_rx_buffers(struct net_device *dev)
 	while (np->really_rx_count != RX_RING_SIZE) {
 		struct sk_buff *skb;
 
-		skb = dev_alloc_skb(np->rx_buf_sz);
+		skb = netdev_alloc_skb(dev, np->rx_buf_sz);
 		if (skb == NULL)
 			break;	/* Better luck next round. */
 
 		while (np->lack_rxbuf->skbuff)
 			np->lack_rxbuf = np->lack_rxbuf->next_desc_logical;
 
-		skb->dev = dev;	/* Mark as being used by this device. */
 		np->lack_rxbuf->skbuff = skb;
 		np->lack_rxbuf->buffer = pci_map_single(np->pci_dev, skb->data,
 			np->rx_buf_sz, PCI_DMA_FROMDEVICE);
@@ -1265,7 +1264,7 @@ static void init_ring(struct net_device *dev)
 
 	/* allocate skb for rx buffers */
 	for (i = 0; i < RX_RING_SIZE; i++) {
-		struct sk_buff *skb = dev_alloc_skb(np->rx_buf_sz);
+		struct sk_buff *skb = netdev_alloc_skb(dev, np->rx_buf_sz);
 
 		if (skb == NULL) {
 			np->lack_rxbuf = &np->rx_ring[i];
@@ -1274,7 +1273,6 @@ static void init_ring(struct net_device *dev)
 
 		++np->really_rx_count;
 		np->rx_ring[i].skbuff = skb;
-		skb->dev = dev;	/* Mark as being used by this device. */
 		np->rx_ring[i].buffer = pci_map_single(np->pci_dev, skb->data,
 			np->rx_buf_sz, PCI_DMA_FROMDEVICE);
 		np->rx_ring[i].status = RXOWN;
@@ -1704,7 +1702,7 @@ static int netdev_rx(struct net_device *dev)
 			/* Check if the packet is long enough to accept without copying
 			   to a minimally-sized skbuff. */
 			if (pkt_len < rx_copybreak &&
-			    (skb = dev_alloc_skb(pkt_len + 2)) != NULL) {
+			    (skb = netdev_alloc_skb(dev, pkt_len + 2)) != NULL) {
 				skb_reserve(skb, 2);	/* 16 byte align the IP header */
 				pci_dma_sync_single_for_cpu(np->pci_dev,
 							    np->cur_rx->buffer,
diff --git a/drivers/net/ethernet/freescale/fec.c b/drivers/net/ethernet/freescale/fec.c
index 7b25e9c..4ad061f 100644
--- a/drivers/net/ethernet/freescale/fec.c
+++ b/drivers/net/ethernet/freescale/fec.c
@@ -711,7 +711,7 @@ fec_enet_rx(struct net_device *ndev)
 		 * include that when passing upstream as it messes up
 		 * bridging applications.
 		 */
-		skb = dev_alloc_skb(pkt_len - 4 + NET_IP_ALIGN);
+		skb = netdev_alloc_skb(dev, pkt_len - 4 + NET_IP_ALIGN);
 
 		if (unlikely(!skb)) {
 			printk("%s: Memory squeeze, dropping packet.\n",
@@ -1210,7 +1210,7 @@ static int fec_enet_alloc_buffers(struct net_device *ndev)
 
 	bdp = fep->rx_bd_base;
 	for (i = 0; i < RX_RING_SIZE; i++) {
-		skb = dev_alloc_skb(FEC_ENET_RX_FRSIZE);
+		skb = netdev_alloc_skb(dev, FEC_ENET_RX_FRSIZE);
 		if (!skb) {
 			fec_enet_free_buffers(ndev);
 			return -ENOMEM;
diff --git a/drivers/net/ethernet/freescale/fec_mpc52xx.c b/drivers/net/ethernet/freescale/fec_mpc52xx.c
index 30745b5..7b34d8c 100644
--- a/drivers/net/ethernet/freescale/fec_mpc52xx.c
+++ b/drivers/net/ethernet/freescale/fec_mpc52xx.c
@@ -160,7 +160,7 @@ static int mpc52xx_fec_alloc_rx_buffers(struct net_device *dev, struct bcom_task
 	struct sk_buff *skb;
 
 	while (!bcom_queue_full(rxtsk)) {
-		skb = dev_alloc_skb(FEC_RX_BUFFER_SIZE);
+		skb = netdev_alloc_skb(dev, FEC_RX_BUFFER_SIZE);
 		if (!skb)
 			return -EAGAIN;
 
@@ -416,7 +416,7 @@ static irqreturn_t mpc52xx_fec_rx_interrupt(int irq, void *dev_id)
 
 		/* skbs are allocated on open, so now we allocate a new one,
 		 * and remove the old (with the packet) */
-		skb = dev_alloc_skb(FEC_RX_BUFFER_SIZE);
+		skb = netdev_alloc_skb(dev, FEC_RX_BUFFER_SIZE);
 		if (!skb) {
 			/* Can't get a new one : reuse the same & drop pkt */
 			dev_notice(&dev->dev, "Low memory - dropped packet.\n");
diff --git a/drivers/net/ethernet/freescale/fs_enet/fs_enet-main.c b/drivers/net/ethernet/freescale/fs_enet/fs_enet-main.c
index 910a8e1..999638a 100644
--- a/drivers/net/ethernet/freescale/fs_enet/fs_enet-main.c
+++ b/drivers/net/ethernet/freescale/fs_enet/fs_enet-main.c
@@ -154,7 +154,7 @@ static int fs_enet_rx_napi(struct napi_struct *napi, int budget)
 
 			if (pkt_len <= fpi->rx_copybreak) {
 				/* +2 to make IP header L1 cache aligned */
-				skbn = dev_alloc_skb(pkt_len + 2);
+				skbn = netdev_alloc_skb(dev, pkt_len + 2);
 				if (skbn != NULL) {
 					skb_reserve(skbn, 2);	/* align IP header */
 					skb_copy_from_linear_data(skb,
@@ -165,7 +165,7 @@ static int fs_enet_rx_napi(struct napi_struct *napi, int budget)
 					skbn = skbt;
 				}
 			} else {
-				skbn = dev_alloc_skb(ENET_RX_FRSIZE);
+				skbn = netdev_alloc_skb(dev, ENET_RX_FRSIZE);
 
 				if (skbn)
 					skb_align(skbn, ENET_RX_ALIGN);
@@ -286,7 +286,7 @@ static int fs_enet_rx_non_napi(struct net_device *dev)
 
 			if (pkt_len <= fpi->rx_copybreak) {
 				/* +2 to make IP header L1 cache aligned */
-				skbn = dev_alloc_skb(pkt_len + 2);
+				skbn = netdev_alloc_skb(dev, pkt_len + 2);
 				if (skbn != NULL) {
 					skb_reserve(skbn, 2);	/* align IP header */
 					skb_copy_from_linear_data(skb,
@@ -297,7 +297,7 @@ static int fs_enet_rx_non_napi(struct net_device *dev)
 					skbn = skbt;
 				}
 			} else {
-				skbn = dev_alloc_skb(ENET_RX_FRSIZE);
+				skbn = netdev_alloc_skb(dev, ENET_RX_FRSIZE);
 
 				if (skbn)
 					skb_align(skbn, ENET_RX_ALIGN);
@@ -504,7 +504,7 @@ void fs_init_bds(struct net_device *dev)
 	 * Initialize the receive buffer descriptors.
 	 */
 	for (i = 0, bdp = fep->rx_bd_base; i < fep->rx_ring; i++, bdp++) {
-		skb = dev_alloc_skb(ENET_RX_FRSIZE);
+		skb = netdev_alloc_skb(dev, ENET_RX_FRSIZE);
 		if (skb == NULL) {
 			dev_warn(fep->dev,
 				 "Memory squeeze, unable to allocate skb\n");
@@ -592,7 +592,7 @@ static struct sk_buff *tx_skb_align_workaround(struct net_device *dev,
 	struct fs_enet_private *fep = netdev_priv(dev);
 
 	/* Alloc new skb */
-	new_skb = dev_alloc_skb(skb->len + 4);
+	new_skb = netdev_alloc_skb(dev, skb->len + 4);
 	if (!new_skb) {
 		if (net_ratelimit()) {
 			dev_warn(fep->dev,
diff --git a/drivers/net/ethernet/freescale/ucc_geth.c b/drivers/net/ethernet/freescale/ucc_geth.c
index ba2dc08..162faff 100644
--- a/drivers/net/ethernet/freescale/ucc_geth.c
+++ b/drivers/net/ethernet/freescale/ucc_geth.c
@@ -214,8 +214,9 @@ static struct sk_buff *get_new_skb(struct ucc_geth_private *ugeth,
 
 	skb = __skb_dequeue(&ugeth->rx_recycle);
 	if (!skb)
-		skb = dev_alloc_skb(ugeth->ug_info->uf_info.max_rx_buf_length +
-				    UCC_GETH_RX_DATA_BUF_ALIGNMENT);
+		skb = netdev_alloc_skb(ugeth->ndev,
+				ugeth->ug_info->uf_info.max_rx_buf_length +
+				UCC_GETH_RX_DATA_BUF_ALIGNMENT);
 	if (skb == NULL)
 		return NULL;
 
@@ -227,8 +228,6 @@ static struct sk_buff *get_new_skb(struct ucc_geth_private *ugeth,
 		    (((unsigned)skb->data) & (UCC_GETH_RX_DATA_BUF_ALIGNMENT -
 					      1)));
 
-	skb->dev = ugeth->ndev;
-
 	out_be32(&((struct qe_bd __iomem *)bd)->buf,
 		      dma_map_single(ugeth->dev,
 				     skb->data,
diff --git a/drivers/net/ethernet/fujitsu/at1700.c b/drivers/net/ethernet/fujitsu/at1700.c
index 7c6c908..586b46f 100644
--- a/drivers/net/ethernet/fujitsu/at1700.c
+++ b/drivers/net/ethernet/fujitsu/at1700.c
@@ -757,7 +757,7 @@ net_rx(struct net_device *dev)
 				dev->stats.rx_errors++;
 				break;
 			}
-			skb = dev_alloc_skb(pkt_len+3);
+			skb = netdev_alloc_skb(dev, pkt_len + 3);
 			if (skb == NULL) {
 				printk("%s: Memory squeeze, dropping packet (len %d).\n",
 					   dev->name, pkt_len);
