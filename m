From: "Pradeep A. Dalvi" <netdev@pradeepdalvi.com>
Subject: [PATCH/RESEND net 4/5][TRIVIAL] drivers/net/ethernet: dev_alloc_skb to netdev_alloc_skb
Date: Tue, 24 Jan 2012 02:23:38 +0530
Message-ID: <1327352018-6868-1-git-send-email-netdev@pradeepdalvi.com>
Mime-Version: 1.0
Cc: "David S. Miller" <davem@davemloft.net>,
	linux-kernel@vger.kernel.org,
	"Pradeep A. Dalvi" <netdev@pradeepdalvi.com>,
	Eric Dumazet <eric.dumazet@gmail.com>,
	Christoph Hellwig <hch@lst.de>
To: netdev@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Replaced deprecating dev_alloc_skb with netdev_alloc_skb in drivers/net/ethernet
  - Removed extra skb->dev = dev after netdev_alloc_skb

Signed-off-by: Pradeep A. Dalvi <netdev@pradeepdalvi.com>
CC: Eric Dumazet <eric.dumazet@gmail.com>
CC: Christoph Hellwig <hch@lst.de>
---
 drivers/net/ethernet/netx-eth.c                      |    2 +-
 drivers/net/ethernet/nuvoton/w90p910_ether.c         |    2 +-
 drivers/net/ethernet/nvidia/forcedeth.c              |   10 ++++++----
 drivers/net/ethernet/packetengines/hamachi.c         |   10 +++++-----
 drivers/net/ethernet/packetengines/yellowfin.c       |    9 ++++-----
 drivers/net/ethernet/pasemi/pasemi_mac.c             |    2 +-
 drivers/net/ethernet/qlogic/netxen/netxen_nic_init.c |    2 +-
 drivers/net/ethernet/qlogic/qlcnic/qlcnic_ethtool.c  |    2 +-
 drivers/net/ethernet/qlogic/qlcnic/qlcnic_init.c     |    2 +-
 drivers/net/ethernet/racal/ni5010.c                  |    2 +-
 drivers/net/ethernet/realtek/atp.c                   |    2 +-
 drivers/net/ethernet/renesas/sh_eth.c                |    6 ++----
 drivers/net/ethernet/seeq/ether3.c                   |    2 +-
 drivers/net/ethernet/seeq/seeq8005.c                 |    2 +-
 drivers/net/ethernet/sis/sis900.c                    |   10 ++++++----
 drivers/net/ethernet/smsc/epic100.c                  |    7 ++++---
 drivers/net/ethernet/smsc/smc911x.c                  |    2 +-
 drivers/net/ethernet/smsc/smc9194.c                  |    2 +-
 drivers/net/ethernet/smsc/smc91c92_cs.c              |    2 +-
 drivers/net/ethernet/smsc/smc91x.c                   |    2 +-
 drivers/net/ethernet/smsc/smsc9420.c                 |    2 --
 drivers/net/ethernet/sun/cassini.c                   |    2 +-
 drivers/net/ethernet/sun/sunbmac.c                   |    3 ++-
 drivers/net/ethernet/sun/sunhme.c                    |    3 ++-
 drivers/net/ethernet/sun/sunqe.c                     |    2 +-
 drivers/net/ethernet/tehuti/tehuti.c                 |    7 +++----
 drivers/net/ethernet/ti/davinci_emac.c               |    3 +--
 drivers/net/ethernet/tile/tilepro.c                  |    4 ++--
 drivers/net/ethernet/toshiba/tc35815.c               |    2 +-
 drivers/net/ethernet/via/via-rhine.c                 |    2 --
 drivers/net/ethernet/via/via-velocity.c              |    2 +-
 drivers/net/ethernet/xilinx/xilinx_emaclite.c        |    2 +-
 drivers/net/ethernet/xircom/xirc2ps_cs.c             |    3 ++-
 33 files changed, 58 insertions(+), 59 deletions(-)

diff --git a/drivers/net/ethernet/netx-eth.c b/drivers/net/ethernet/netx-eth.c
index 8d288af..0762d01 100644
--- a/drivers/net/ethernet/netx-eth.c
+++ b/drivers/net/ethernet/netx-eth.c
@@ -150,7 +150,7 @@ static void netx_eth_receive(struct net_device *ndev)
 	seg = (val & FIFO_PTR_SEGMENT_MASK) >> FIFO_PTR_SEGMENT_SHIFT;
 	len = (val & FIFO_PTR_FRAMELEN_MASK) >> FIFO_PTR_FRAMELEN_SHIFT;
 
-	skb = dev_alloc_skb(len);
+	skb = netdev_alloc_skb(ndev, len);
 	if (unlikely(skb == NULL)) {
 		printk(KERN_NOTICE "%s: Low memory, packet dropped.\n",
 			ndev->name);
diff --git a/drivers/net/ethernet/nuvoton/w90p910_ether.c b/drivers/net/ethernet/nuvoton/w90p910_ether.c
index b75a049..6893a65 100644
--- a/drivers/net/ethernet/nuvoton/w90p910_ether.c
+++ b/drivers/net/ethernet/nuvoton/w90p910_ether.c
@@ -735,7 +735,7 @@ static void netdev_rx(struct net_device *dev)
 
 		if (status & RXDS_RXGD) {
 			data = ether->rdesc->recv_buf[ether->cur_rx];
-			skb = dev_alloc_skb(length+2);
+			skb = netdev_alloc_skb(dev, length + 2);
 			if (!skb) {
 				dev_err(&pdev->dev, "get skb buffer error\n");
 				ether->stats.rx_dropped++;
diff --git a/drivers/net/ethernet/nvidia/forcedeth.c b/drivers/net/ethernet/nvidia/forcedeth.c
index 4c4e7f4..accb55d 100644
--- a/drivers/net/ethernet/nvidia/forcedeth.c
+++ b/drivers/net/ethernet/nvidia/forcedeth.c
@@ -1815,7 +1815,8 @@ static int nv_alloc_rx(struct net_device *dev)
 		less_rx = np->last_rx.orig;
 
 	while (np->put_rx.orig != less_rx) {
-		struct sk_buff *skb = dev_alloc_skb(np->rx_buf_sz + NV_RX_ALLOC_PAD);
+		struct sk_buff *skb =
+			netdev_alloc_skb(dev, np->rx_buf_sz + NV_RX_ALLOC_PAD);
 		if (skb) {
 			np->put_rx_ctx->skb = skb;
 			np->put_rx_ctx->dma = pci_map_single(np->pci_dev,
@@ -1850,7 +1851,8 @@ static int nv_alloc_rx_optimized(struct net_device *dev)
 		less_rx = np->last_rx.ex;
 
 	while (np->put_rx.ex != less_rx) {
-		struct sk_buff *skb = dev_alloc_skb(np->rx_buf_sz + NV_RX_ALLOC_PAD);
+		struct sk_buff *skb =
+			netdev_alloc_skb(dev, np->rx_buf_sz + NV_RX_ALLOC_PAD);
 		if (skb) {
 			np->put_rx_ctx->skb = skb;
 			np->put_rx_ctx->dma = pci_map_single(np->pci_dev,
@@ -4993,9 +4995,9 @@ static int nv_loopback_test(struct net_device *dev)
 
 	/* setup packet for tx */
 	pkt_len = ETH_DATA_LEN;
-	tx_skb = dev_alloc_skb(pkt_len);
+	tx_skb = netdev_alloc_skb(dev, pkt_len);
 	if (!tx_skb) {
-		netdev_err(dev, "dev_alloc_skb() failed during loopback test\n");
+		netdev_err(dev, "netdev_alloc_skb() failed during loopback test\n");
 		ret = 0;
 		goto out;
 	}
diff --git a/drivers/net/ethernet/packetengines/hamachi.c b/drivers/net/ethernet/packetengines/hamachi.c
index 3458df3..8fc26af 100644
--- a/drivers/net/ethernet/packetengines/hamachi.c
+++ b/drivers/net/ethernet/packetengines/hamachi.c
@@ -1188,11 +1188,10 @@ static void hamachi_init_ring(struct net_device *dev)
 	}
 	/* Fill in the Rx buffers.  Handle allocation failure gracefully. */
 	for (i = 0; i < RX_RING_SIZE; i++) {
-		struct sk_buff *skb = dev_alloc_skb(hmp->rx_buf_sz + 2);
+		struct sk_buff *skb = netdev_alloc_skb(dev, hmp->rx_buf_sz + 2);
 		hmp->rx_skbuff[i] = skb;
 		if (skb == NULL)
 			break;
-		skb->dev = dev;         /* Mark as being used by this device. */
 		skb_reserve(skb, 2); /* 16 byte align the IP header. */
                 hmp->rx_ring[i].addr = cpu_to_leXX(pci_map_single(hmp->pci_dev,
 			skb->data, hmp->rx_buf_sz, PCI_DMA_FROMDEVICE));
@@ -1488,7 +1487,8 @@ static int hamachi_rx(struct net_device *dev)
 			/* Check if the packet is long enough to accept without copying
 			   to a minimally-sized skbuff. */
 			if (pkt_len < rx_copybreak &&
-			    (skb = dev_alloc_skb(pkt_len + 2)) != NULL) {
+			    (skb = netdev_alloc_skb(dev, pkt_len + 2))
+			    != NULL) {
 #ifdef RX_CHECKSUM
 				printk(KERN_ERR "%s: rx_copybreak non-zero "
 				  "not good with RX_CHECKSUM\n", dev->name);
@@ -1591,12 +1591,12 @@ static int hamachi_rx(struct net_device *dev)
 		entry = hmp->dirty_rx % RX_RING_SIZE;
 		desc = &(hmp->rx_ring[entry]);
 		if (hmp->rx_skbuff[entry] == NULL) {
-			struct sk_buff *skb = dev_alloc_skb(hmp->rx_buf_sz + 2);
+			struct sk_buff *skb = netdev_alloc_skb(dev,
+					hmp->rx_buf_sz + 2);
 
 			hmp->rx_skbuff[entry] = skb;
 			if (skb == NULL)
 				break;		/* Better luck next round. */
-			skb->dev = dev;		/* Mark as being used by this device. */
 			skb_reserve(skb, 2);	/* Align IP on 16 byte boundaries */
                 	desc->addr = cpu_to_leXX(pci_map_single(hmp->pci_dev,
 				skb->data, hmp->rx_buf_sz, PCI_DMA_FROMDEVICE));
diff --git a/drivers/net/ethernet/packetengines/yellowfin.c b/drivers/net/ethernet/packetengines/yellowfin.c
index db44e9a..68de55e 100644
--- a/drivers/net/ethernet/packetengines/yellowfin.c
+++ b/drivers/net/ethernet/packetengines/yellowfin.c
@@ -744,11 +744,10 @@ static int yellowfin_init_ring(struct net_device *dev)
 	}
 
 	for (i = 0; i < RX_RING_SIZE; i++) {
-		struct sk_buff *skb = dev_alloc_skb(yp->rx_buf_sz + 2);
+		struct sk_buff *skb = netdev_alloc_skb(dev, yp->rx_buf_sz + 2);
 		yp->rx_skbuff[i] = skb;
 		if (skb == NULL)
 			break;
-		skb->dev = dev;		/* Mark as being used by this device. */
 		skb_reserve(skb, 2);	/* 16 byte align the IP header. */
 		yp->rx_ring[i].addr = cpu_to_le32(pci_map_single(yp->pci_dev,
 			skb->data, yp->rx_buf_sz, PCI_DMA_FROMDEVICE));
@@ -1134,7 +1133,7 @@ static int yellowfin_rx(struct net_device *dev)
 					PCI_DMA_FROMDEVICE);
 				yp->rx_skbuff[entry] = NULL;
 			} else {
-				skb = dev_alloc_skb(pkt_len + 2);
+				skb = netdev_alloc_skb(dev, pkt_len + 2);
 				if (skb == NULL)
 					break;
 				skb_reserve(skb, 2);	/* 16 byte align the IP header */
@@ -1157,11 +1156,11 @@ static int yellowfin_rx(struct net_device *dev)
 	for (; yp->cur_rx - yp->dirty_rx > 0; yp->dirty_rx++) {
 		entry = yp->dirty_rx % RX_RING_SIZE;
 		if (yp->rx_skbuff[entry] == NULL) {
-			struct sk_buff *skb = dev_alloc_skb(yp->rx_buf_sz + 2);
+			struct sk_buff *skb = netdev_alloc_skb(dev,
+					yp->rx_buf_sz + 2);
 			if (skb == NULL)
 				break;				/* Better luck next round. */
 			yp->rx_skbuff[entry] = skb;
-			skb->dev = dev;	/* Mark as being used by this device. */
 			skb_reserve(skb, 2);	/* Align IP on 16 byte boundaries */
 			yp->rx_ring[entry].addr = cpu_to_le32(pci_map_single(yp->pci_dev,
 				skb->data, yp->rx_buf_sz, PCI_DMA_FROMDEVICE));
diff --git a/drivers/net/ethernet/pasemi/pasemi_mac.c b/drivers/net/ethernet/pasemi/pasemi_mac.c
index 49b549f..148de79 100644
--- a/drivers/net/ethernet/pasemi/pasemi_mac.c
+++ b/drivers/net/ethernet/pasemi/pasemi_mac.c
@@ -643,7 +643,7 @@ static void pasemi_mac_replenish_rx_ring(const struct net_device *dev,
 		/* Entry in use? */
 		WARN_ON(*buff);
 
-		skb = dev_alloc_skb(mac->bufsz);
+		skb = netdev_alloc_skb(dev, mac->bufsz);
 		skb_reserve(skb, LOCAL_SKB_ALIGN);
 
 		if (unlikely(!skb))
diff --git a/drivers/net/ethernet/qlogic/netxen/netxen_nic_init.c b/drivers/net/ethernet/qlogic/netxen/netxen_nic_init.c
index a8259cc..df36b48 100644
--- a/drivers/net/ethernet/qlogic/netxen/netxen_nic_init.c
+++ b/drivers/net/ethernet/qlogic/netxen/netxen_nic_init.c
@@ -1494,7 +1494,7 @@ netxen_alloc_rx_skb(struct netxen_adapter *adapter,
 	dma_addr_t dma;
 	struct pci_dev *pdev = adapter->pdev;
 
-	buffer->skb = dev_alloc_skb(rds_ring->skb_size);
+	buffer->skb = netdev_alloc_skb(adapter->netdev, rds_ring->skb_size);
 	if (!buffer->skb)
 		return 1;
 
diff --git a/drivers/net/ethernet/qlogic/qlcnic/qlcnic_ethtool.c b/drivers/net/ethernet/qlogic/qlcnic/qlcnic_ethtool.c
index cc228cf..8395d63 100644
--- a/drivers/net/ethernet/qlogic/qlcnic/qlcnic_ethtool.c
+++ b/drivers/net/ethernet/qlogic/qlcnic/qlcnic_ethtool.c
@@ -722,7 +722,7 @@ static int qlcnic_do_lb_test(struct qlcnic_adapter *adapter, u8 mode)
 	int i, loop, cnt = 0;
 
 	for (i = 0; i < QLCNIC_NUM_ILB_PKT; i++) {
-		skb = dev_alloc_skb(QLCNIC_ILB_PKT_SIZE);
+		skb = netdev_alloc_skb(adapter->netdev, QLCNIC_ILB_PKT_SIZE);
 		qlcnic_create_loopback_buff(skb->data, adapter->mac_addr);
 		skb_put(skb, QLCNIC_ILB_PKT_SIZE);
 
diff --git a/drivers/net/ethernet/qlogic/qlcnic/qlcnic_init.c b/drivers/net/ethernet/qlogic/qlcnic/qlcnic_init.c
index 3866958..b019f59 100644
--- a/drivers/net/ethernet/qlogic/qlcnic/qlcnic_init.c
+++ b/drivers/net/ethernet/qlogic/qlcnic/qlcnic_init.c
@@ -1434,7 +1434,7 @@ qlcnic_alloc_rx_skb(struct qlcnic_adapter *adapter,
 	dma_addr_t dma;
 	struct pci_dev *pdev = adapter->pdev;
 
-	skb = dev_alloc_skb(rds_ring->skb_size);
+	skb = netdev_alloc_skb(adapter->netdev, rds_ring->skb_size);
 	if (!skb) {
 		adapter->stats.skb_alloc_failure++;
 		return -ENOMEM;
diff --git a/drivers/net/ethernet/racal/ni5010.c b/drivers/net/ethernet/racal/ni5010.c
index 072810d..8079822 100644
--- a/drivers/net/ethernet/racal/ni5010.c
+++ b/drivers/net/ethernet/racal/ni5010.c
@@ -552,7 +552,7 @@ static void ni5010_rx(struct net_device *dev)
 	}
 
 	/* Malloc up new buffer. */
-	skb = dev_alloc_skb(i_pkt_size + 3);
+	skb = netdev_alloc_skb(dev, i_pkt_size + 3);
 	if (skb == NULL) {
 		printk(KERN_WARNING "%s: Memory squeeze, dropping packet.\n", dev->name);
 		dev->stats.rx_dropped++;
diff --git a/drivers/net/ethernet/realtek/atp.c b/drivers/net/ethernet/realtek/atp.c
index e3f57fd..46c1932 100644
--- a/drivers/net/ethernet/realtek/atp.c
+++ b/drivers/net/ethernet/realtek/atp.c
@@ -783,7 +783,7 @@ static void net_rx(struct net_device *dev)
 		int pkt_len = (rx_head.rx_count & 0x7ff) - 4;
 		struct sk_buff *skb;
 
-		skb = dev_alloc_skb(pkt_len + 2);
+		skb = netdev_alloc_skb(dev, pkt_len + 2);
 		if (skb == NULL) {
 			printk(KERN_ERR "%s: Memory squeeze, dropping packet.\n",
 				   dev->name);
diff --git a/drivers/net/ethernet/renesas/sh_eth.c b/drivers/net/ethernet/renesas/sh_eth.c
index 813d41c..4fe9621 100644
--- a/drivers/net/ethernet/renesas/sh_eth.c
+++ b/drivers/net/ethernet/renesas/sh_eth.c
@@ -653,13 +653,12 @@ static void sh_eth_ring_format(struct net_device *ndev)
 	for (i = 0; i < RX_RING_SIZE; i++) {
 		/* skb */
 		mdp->rx_skbuff[i] = NULL;
-		skb = dev_alloc_skb(mdp->rx_buf_sz);
+		skb = netdev_alloc_skb(ndev, mdp->rx_buf_sz);
 		mdp->rx_skbuff[i] = skb;
 		if (skb == NULL)
 			break;
 		dma_map_single(&ndev->dev, skb->tail, mdp->rx_buf_sz,
 				DMA_FROM_DEVICE);
-		skb->dev = ndev; /* Mark as being used by this device. */
 		sh_eth_set_receive_align(skb);
 
 		/* RX descriptor */
@@ -953,13 +952,12 @@ static int sh_eth_rx(struct net_device *ndev)
 		rxdesc->buffer_length = ALIGN(mdp->rx_buf_sz, 16);
 
 		if (mdp->rx_skbuff[entry] == NULL) {
-			skb = dev_alloc_skb(mdp->rx_buf_sz);
+			skb = netdev_alloc_skb(ndev, mdp->rx_buf_sz);
 			mdp->rx_skbuff[entry] = skb;
 			if (skb == NULL)
 				break;	/* Better luck next round. */
 			dma_map_single(&ndev->dev, skb->tail, mdp->rx_buf_sz,
 					DMA_FROM_DEVICE);
-			skb->dev = ndev;
 			sh_eth_set_receive_align(skb);
 
 			skb_checksum_none_assert(skb);
diff --git a/drivers/net/ethernet/seeq/ether3.c b/drivers/net/ethernet/seeq/ether3.c
index 893c880..7b819bd 100644
--- a/drivers/net/ethernet/seeq/ether3.c
+++ b/drivers/net/ethernet/seeq/ether3.c
@@ -643,7 +643,7 @@ if (next_ptr < RX_START || next_ptr >= RX_END) {
 			if (next_ptr <= this_ptr)
 				length += RX_END - RX_START;
 
-			skb = dev_alloc_skb(length + 2);
+			skb = netdev_alloc_skb(dev, length + 2);
 			if (skb) {
 				unsigned char *buf;
 
diff --git a/drivers/net/ethernet/seeq/seeq8005.c b/drivers/net/ethernet/seeq/seeq8005.c
index 6056145..7989907 100644
--- a/drivers/net/ethernet/seeq/seeq8005.c
+++ b/drivers/net/ethernet/seeq/seeq8005.c
@@ -548,7 +548,7 @@ static void seeq8005_rx(struct net_device *dev)
 			struct sk_buff *skb;
 			unsigned char *buf;
 
-			skb = dev_alloc_skb(pkt_len);
+			skb = netdev_alloc_skb(dev, pkt_len);
 			if (skb == NULL) {
 				printk("%s: Memory squeeze, dropping packet.\n", dev->name);
 				dev->stats.rx_dropped++;
diff --git a/drivers/net/ethernet/sis/sis900.c b/drivers/net/ethernet/sis/sis900.c
index c8efc70..5c2f9bd 100644
--- a/drivers/net/ethernet/sis/sis900.c
+++ b/drivers/net/ethernet/sis/sis900.c
@@ -1165,9 +1165,9 @@ sis900_init_rx_ring(struct net_device *net_dev)
 
 	/* allocate sock buffers */
 	for (i = 0; i < NUM_RX_DESC; i++) {
-		struct sk_buff *skb;
+		struct sk_buff *skb = netdev_alloc_skb(net_dev, RX_BUF_SIZE);
 
-		if ((skb = dev_alloc_skb(RX_BUF_SIZE)) == NULL) {
+		if (skb == NULL) {
 			/* not enough memory for skbuff, this makes a "hole"
 			   on the buffer ring, it is not clear how the
 			   hardware will react to this kind of degenerated
@@ -1770,7 +1770,8 @@ static int sis900_rx(struct net_device *net_dev)
 
 			/* refill the Rx buffer, what if there is not enough
 			 * memory for new socket buffer ?? */
-			if ((skb = dev_alloc_skb(RX_BUF_SIZE)) == NULL) {
+			skb = netdev_alloc_skb(net_dev, RX_BUF_SIZE);
+			if (skb == NULL) {
 				/*
 				 * Not enough memory to refill the buffer
 				 * so we need to recycle the old one so
@@ -1828,7 +1829,8 @@ refill_rx_ring:
 		entry = sis_priv->dirty_rx % NUM_RX_DESC;
 
 		if (sis_priv->rx_skbuff[entry] == NULL) {
-			if ((skb = dev_alloc_skb(RX_BUF_SIZE)) == NULL) {
+			skb = netdev_alloc_skb(net_dev, RX_BUF_SIZE);
+			if (skb == NULL) {
 				/* not enough memory for skbuff, this makes a
 				 * "hole" on the buffer ring, it is not clear
 				 * how the hardware will react to this kind
diff --git a/drivers/net/ethernet/smsc/epic100.c b/drivers/net/ethernet/smsc/epic100.c
index 2c077ce..9ea580a 100644
--- a/drivers/net/ethernet/smsc/epic100.c
+++ b/drivers/net/ethernet/smsc/epic100.c
@@ -935,7 +935,7 @@ static void epic_init_ring(struct net_device *dev)
 
 	/* Fill in the Rx buffers.  Handle allocation failure gracefully. */
 	for (i = 0; i < RX_RING_SIZE; i++) {
-		struct sk_buff *skb = dev_alloc_skb(ep->rx_buf_sz + 2);
+		struct sk_buff *skb = netdev_alloc_skb(dev, ep->rx_buf_sz + 2);
 		ep->rx_skbuff[i] = skb;
 		if (skb == NULL)
 			break;
@@ -1200,7 +1200,7 @@ static int epic_rx(struct net_device *dev, int budget)
 			/* Check if the packet is long enough to accept without copying
 			   to a minimally-sized skbuff. */
 			if (pkt_len < rx_copybreak &&
-			    (skb = dev_alloc_skb(pkt_len + 2)) != NULL) {
+			    (skb = netdev_alloc_skb(dev, pkt_len + 2)) != NULL) {
 				skb_reserve(skb, 2);	/* 16 byte align the IP header */
 				pci_dma_sync_single_for_cpu(ep->pci_dev,
 							    ep->rx_ring[entry].bufaddr,
@@ -1233,7 +1233,8 @@ static int epic_rx(struct net_device *dev, int budget)
 		entry = ep->dirty_rx % RX_RING_SIZE;
 		if (ep->rx_skbuff[entry] == NULL) {
 			struct sk_buff *skb;
-			skb = ep->rx_skbuff[entry] = dev_alloc_skb(ep->rx_buf_sz + 2);
+			skb = ep->rx_skbuff[entry] = netdev_alloc_skb(dev,
+					ep->rx_buf_sz + 2);
 			if (skb == NULL)
 				break;
 			skb_reserve(skb, 2);	/* Align IP on 16 byte boundaries */
diff --git a/drivers/net/ethernet/smsc/smc911x.c b/drivers/net/ethernet/smsc/smc911x.c
index 313ba3b..4b4ece1 100644
--- a/drivers/net/ethernet/smsc/smc911x.c
+++ b/drivers/net/ethernet/smsc/smc911x.c
@@ -401,7 +401,7 @@ static inline void	 smc911x_rcv(struct net_device *dev)
 	} else {
 		/* Receive a valid packet */
 		/* Alloc a buffer with extra room for DMA alignment */
-		skb=dev_alloc_skb(pkt_len+32);
+		skb = netdev_alloc_skb(dev, pkt_len + 32);
 		if (unlikely(skb == NULL)) {
 			PRINTK( "%s: Low memory, rcvd packet dropped.\n",
 				dev->name);
diff --git a/drivers/net/ethernet/smsc/smc9194.c b/drivers/net/ethernet/smsc/smc9194.c
index 4e45094..50823da 100644
--- a/drivers/net/ethernet/smsc/smc9194.c
+++ b/drivers/net/ethernet/smsc/smc9194.c
@@ -1222,7 +1222,7 @@ static void smc_rcv(struct net_device *dev)
 		if ( status & RS_MULTICAST )
 			dev->stats.multicast++;
 
-		skb = dev_alloc_skb( packet_length + 5);
+		skb = netdev_alloc_skb(dev, packet_length + 5);
 
 		if ( skb == NULL ) {
 			printk(KERN_NOTICE CARDNAME ": Low memory, packet dropped.\n");
diff --git a/drivers/net/ethernet/smsc/smc91c92_cs.c b/drivers/net/ethernet/smsc/smc91c92_cs.c
index ada927a..d6bc8e9 100644
--- a/drivers/net/ethernet/smsc/smc91c92_cs.c
+++ b/drivers/net/ethernet/smsc/smc91c92_cs.c
@@ -1500,7 +1500,7 @@ static void smc_rx(struct net_device *dev)
 	struct sk_buff *skb;
 	
 	/* Note: packet_length adds 5 or 6 extra bytes here! */
-	skb = dev_alloc_skb(packet_length+2);
+	skb = netdev_alloc_skb(dev, packet_length + 2);
 	
 	if (skb == NULL) {
 	    pr_debug("%s: Low memory, packet dropped.\n", dev->name);
diff --git a/drivers/net/ethernet/smsc/smc91x.c b/drivers/net/ethernet/smsc/smc91x.c
index 64ad3ed..3c86ddd 100644
--- a/drivers/net/ethernet/smsc/smc91x.c
+++ b/drivers/net/ethernet/smsc/smc91x.c
@@ -463,7 +463,7 @@ static inline void  smc_rcv(struct net_device *dev)
 		 * multiple of 4 bytes on 32 bit buses.
 		 * Hence packet_len - 6 + 2 + 2 + 2.
 		 */
-		skb = dev_alloc_skb(packet_len);
+		skb = netdev_alloc_skb(dev, packet_len);
 		if (unlikely(skb == NULL)) {
 			printk(KERN_NOTICE "%s: Low memory, packet dropped.\n",
 				dev->name);
diff --git a/drivers/net/ethernet/smsc/smsc9420.c b/drivers/net/ethernet/smsc/smsc9420.c
index a9efbdf..7e67543 100644
--- a/drivers/net/ethernet/smsc/smsc9420.c
+++ b/drivers/net/ethernet/smsc/smsc9420.c
@@ -850,8 +850,6 @@ static int smsc9420_alloc_rx_buffer(struct smsc9420_pdata *pd, int index)
 		return -ENOMEM;
 	}
 
-	skb->dev = pd->dev;
-
 	mapping = pci_map_single(pd->pdev, skb_tail_pointer(skb),
 				 PKT_BUF_SZ, PCI_DMA_FROMDEVICE);
 	if (pci_dma_mapping_error(pd->pdev, mapping)) {
diff --git a/drivers/net/ethernet/sun/cassini.c b/drivers/net/ethernet/sun/cassini.c
index f10665f..6ad5265 100644
--- a/drivers/net/ethernet/sun/cassini.c
+++ b/drivers/net/ethernet/sun/cassini.c
@@ -1975,7 +1975,7 @@ static int cas_rx_process_pkt(struct cas *cp, struct cas_rx_comp *rxc,
 	else
 		alloclen = max(hlen, RX_COPY_MIN);
 
-	skb = dev_alloc_skb(alloclen + swivel + cp->crc_size);
+	skb = netdev_alloc_skb(cp->dev, alloclen + swivel + cp->crc_size);
 	if (skb == NULL)
 		return -1;
 
diff --git a/drivers/net/ethernet/sun/sunbmac.c b/drivers/net/ethernet/sun/sunbmac.c
index 220f724..79d71bc 100644
--- a/drivers/net/ethernet/sun/sunbmac.c
+++ b/drivers/net/ethernet/sun/sunbmac.c
@@ -853,7 +853,8 @@ static void bigmac_rx(struct bigmac *bp)
 			/* Trim the original skb for the netif. */
 			skb_trim(skb, len);
 		} else {
-			struct sk_buff *copy_skb = dev_alloc_skb(len + 2);
+			struct sk_buff *copy_skb =
+				netdev_alloc_skb(bp->dev, len + 2);
 
 			if (copy_skb == NULL) {
 				drops++;
diff --git a/drivers/net/ethernet/sun/sunhme.c b/drivers/net/ethernet/sun/sunhme.c
index 09c5186..d49b558 100644
--- a/drivers/net/ethernet/sun/sunhme.c
+++ b/drivers/net/ethernet/sun/sunhme.c
@@ -2043,7 +2043,8 @@ static void happy_meal_rx(struct happy_meal *hp, struct net_device *dev)
 			/* Trim the original skb for the netif. */
 			skb_trim(skb, len);
 		} else {
-			struct sk_buff *copy_skb = dev_alloc_skb(len + 2);
+			struct sk_buff *copy_skb =
+				netdev_alloc_skb(dev, len + 2);
 
 			if (copy_skb == NULL) {
 				drops++;
diff --git a/drivers/net/ethernet/sun/sunqe.c b/drivers/net/ethernet/sun/sunqe.c
index b28f743..b42d1c5 100644
--- a/drivers/net/ethernet/sun/sunqe.c
+++ b/drivers/net/ethernet/sun/sunqe.c
@@ -435,7 +435,7 @@ static void qe_rx(struct sunqe *qep)
 			dev->stats.rx_length_errors++;
 			dev->stats.rx_dropped++;
 		} else {
-			skb = dev_alloc_skb(len + 2);
+			skb = netdev_alloc_skb(dev, len + 2);
 			if (skb == NULL) {
 				drops++;
 				dev->stats.rx_dropped++;
diff --git a/drivers/net/ethernet/tehuti/tehuti.c b/drivers/net/ethernet/tehuti/tehuti.c
index 4b19e9b..68df1ac 100644
--- a/drivers/net/ethernet/tehuti/tehuti.c
+++ b/drivers/net/ethernet/tehuti/tehuti.c
@@ -1089,12 +1089,11 @@ static void bdx_rx_alloc_skbs(struct bdx_priv *priv, struct rxf_fifo *f)
 	ENTER;
 	dno = bdx_rxdb_available(db) - 1;
 	while (dno > 0) {
-		skb = dev_alloc_skb(f->m.pktsz + NET_IP_ALIGN);
+		skb = netdev_alloc_skb(priv->ndev, f->m.pktsz + NET_IP_ALIGN);
 		if (!skb) {
-			pr_err("NO MEM: dev_alloc_skb failed\n");
+			pr_err("NO MEM: netdev_alloc_skb failed\n");
 			break;
 		}
-		skb->dev = priv->ndev;
 		skb_reserve(skb, NET_IP_ALIGN);
 
 		idx = bdx_rxdb_alloc_elem(db);
@@ -1258,7 +1257,7 @@ static int bdx_rx_receive(struct bdx_priv *priv, struct rxd_fifo *f, int budget)
 		skb = dm->skb;
 
 		if (len < BDX_COPYBREAK &&
-		    (skb2 = dev_alloc_skb(len + NET_IP_ALIGN))) {
+		    (skb2 = netdev_alloc_skb(priv->ndev, len + NET_IP_ALIGN))) {
 			skb_reserve(skb2, NET_IP_ALIGN);
 			/*skb_put(skb2, len); */
 			pci_dma_sync_single_for_cpu(priv->pdev,
diff --git a/drivers/net/ethernet/ti/davinci_emac.c b/drivers/net/ethernet/ti/davinci_emac.c
index 794ac30..757efc6 100644
--- a/drivers/net/ethernet/ti/davinci_emac.c
+++ b/drivers/net/ethernet/ti/davinci_emac.c
@@ -992,10 +992,9 @@ static irqreturn_t emac_irq(int irq, void *dev_id)
 
 static struct sk_buff *emac_rx_alloc(struct emac_priv *priv)
 {
-	struct sk_buff *skb = dev_alloc_skb(priv->rx_buf_size);
+	struct sk_buff *skb = netdev_alloc_skb(priv->ndev, priv->rx_buf_size);
 	if (WARN_ON(!skb))
 		return NULL;
-	skb->dev = priv->ndev;
 	skb_reserve(skb, NET_IP_ALIGN);
 	return skb;
 }
diff --git a/drivers/net/ethernet/tile/tilepro.c b/drivers/net/ethernet/tile/tilepro.c
index d9951af..a8e5daa 100644
--- a/drivers/net/ethernet/tile/tilepro.c
+++ b/drivers/net/ethernet/tile/tilepro.c
@@ -419,7 +419,7 @@ static bool tile_net_provide_needed_buffer(struct tile_net_cpu *info,
 #endif
 
 	/* Avoid "false sharing" with last cache line. */
-	/* ISSUE: This is already done by "dev_alloc_skb()". */
+	/* ISSUE: This is already done by "netdev_alloc_skb()". */
 	unsigned int len =
 		 (((small ? LIPP_SMALL_PACKET_SIZE : large_size) +
 		   CHIP_L2_LINE_SIZE() - 1) & -CHIP_L2_LINE_SIZE());
@@ -433,7 +433,7 @@ static bool tile_net_provide_needed_buffer(struct tile_net_cpu *info,
 	struct sk_buff **skb_ptr;
 
 	/* Request 96 extra bytes for alignment purposes. */
-	skb = dev_alloc_skb(len + padding);
+	skb = netdev_alloc_skb(info->napi->dev, len + padding);
 	if (skb == NULL)
 		return false;
 
diff --git a/drivers/net/ethernet/toshiba/tc35815.c b/drivers/net/ethernet/toshiba/tc35815.c
index 71b785c..73c1d26 100644
--- a/drivers/net/ethernet/toshiba/tc35815.c
+++ b/drivers/net/ethernet/toshiba/tc35815.c
@@ -453,7 +453,7 @@ static struct sk_buff *alloc_rxbuf_skb(struct net_device *dev,
 				       dma_addr_t *dma_handle)
 {
 	struct sk_buff *skb;
-	skb = dev_alloc_skb(RX_BUF_SIZE);
+	skb = netdev_alloc_skb(dev, RX_BUF_SIZE);
 	if (!skb)
 		return NULL;
 	*dma_handle = pci_map_single(hwdev, skb->data, RX_BUF_SIZE,
diff --git a/drivers/net/ethernet/via/via-rhine.c b/drivers/net/ethernet/via/via-rhine.c
index 10b18eb..df70e0c 100644
--- a/drivers/net/ethernet/via/via-rhine.c
+++ b/drivers/net/ethernet/via/via-rhine.c
@@ -1156,7 +1156,6 @@ static void alloc_rbufs(struct net_device *dev)
 		rp->rx_skbuff[i] = skb;
 		if (skb == NULL)
 			break;
-		skb->dev = dev;                 /* Mark as being used by this device. */
 
 		rp->rx_skbuff_dma[i] =
 			pci_map_single(rp->pdev, skb->data, rp->rx_buf_sz,
@@ -1941,7 +1940,6 @@ static int rhine_rx(struct net_device *dev, int limit)
 			rp->rx_skbuff[entry] = skb;
 			if (skb == NULL)
 				break;	/* Better luck next round. */
-			skb->dev = dev;	/* Mark as being used by this device. */
 			rp->rx_skbuff_dma[entry] =
 				pci_map_single(rp->pdev, skb->data,
 					       rp->rx_buf_sz,
diff --git a/drivers/net/ethernet/via/via-velocity.c b/drivers/net/ethernet/via/via-velocity.c
index 4128d6b..b0a260d 100644
--- a/drivers/net/ethernet/via/via-velocity.c
+++ b/drivers/net/ethernet/via/via-velocity.c
@@ -1509,7 +1509,7 @@ static int velocity_alloc_rx_buf(struct velocity_info *vptr, int idx)
 	struct rx_desc *rd = &(vptr->rx.ring[idx]);
 	struct velocity_rd_info *rd_info = &(vptr->rx.info[idx]);
 
-	rd_info->skb = dev_alloc_skb(vptr->rx.buf_sz + 64);
+	rd_info->skb = netdev_alloc_skb(vptr->dev, vptr->rx.buf_sz + 64);
 	if (rd_info->skb == NULL)
 		return -ENOMEM;
 
diff --git a/drivers/net/ethernet/xilinx/xilinx_emaclite.c b/drivers/net/ethernet/xilinx/xilinx_emaclite.c
index 79013e5..441088f 100644
--- a/drivers/net/ethernet/xilinx/xilinx_emaclite.c
+++ b/drivers/net/ethernet/xilinx/xilinx_emaclite.c
@@ -613,7 +613,7 @@ static void xemaclite_rx_handler(struct net_device *dev)
 	u32 len;
 
 	len = ETH_FRAME_LEN + ETH_FCS_LEN;
-	skb = dev_alloc_skb(len + ALIGNMENT);
+	skb = netdev_alloc_skb(dev, len + ALIGNMENT);
 	if (!skb) {
 		/* Couldn't get memory. */
 		dev->stats.rx_dropped++;
diff --git a/drivers/net/ethernet/xircom/xirc2ps_cs.c b/drivers/net/ethernet/xircom/xirc2ps_cs.c
index 33979c3..5ae54c3 100644
--- a/drivers/net/ethernet/xircom/xirc2ps_cs.c
+++ b/drivers/net/ethernet/xircom/xirc2ps_cs.c
@@ -1039,7 +1039,8 @@ xirc2ps_interrupt(int irq, void *dev_id)
 
 	    pr_debug("rsr=%#02x packet_length=%u\n", rsr, pktlen);
 
-	    skb = dev_alloc_skb(pktlen+3); /* 1 extra so we can use insw */
+		/* 1 extra so we can use insw */
+		skb = netdev_alloc_skb(dev, pktlen + 3);
 	    if (!skb) {
 		pr_notice("low memory, packet dropped (size=%u)\n", pktlen);
 		dev->stats.rx_dropped++;
