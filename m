From: "Pradeep A. Dalvi" <netdev@pradeepdalvi.com>
Subject: [PATCH/RESEND net 1/5][TRIVIAL 1/4] drivers/net/ethernet: dev_alloc_skb to netdev_alloc_skb
Date: Tue, 24 Jan 2012 03:22:27 +0530
Message-ID: <1327355547-7537-1-git-send-email-netdev@pradeepdalvi.com>
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
 drivers/net/ethernet/3com/3c501.c               |    2 +-
 drivers/net/ethernet/3com/3c509.c               |    2 +-
 drivers/net/ethernet/3com/3c574_cs.c            |    2 +-
 drivers/net/ethernet/3com/3c589_cs.c            |    2 +-
 drivers/net/ethernet/3com/3c59x.c               |    5 +++--
 drivers/net/ethernet/3com/typhoon.c             |    5 ++---
 drivers/net/ethernet/8390/axnet_cs.c            |    2 +-
 drivers/net/ethernet/8390/lib8390.c             |    2 +-
 drivers/net/ethernet/adaptec/starfire.c         |    8 +++-----
 drivers/net/ethernet/aeroflex/greth.c           |    1 -
 drivers/net/ethernet/amd/7990.c                 |    2 +-
 drivers/net/ethernet/amd/a2065.c                |    2 +-
 drivers/net/ethernet/amd/am79c961a.c            |    2 +-
 drivers/net/ethernet/amd/amd8111e.c             |    6 ++++--
 drivers/net/ethernet/amd/ariadne.c              |    2 +-
 drivers/net/ethernet/amd/atarilance.c           |    2 +-
 drivers/net/ethernet/amd/au1000_eth.c           |    2 +-
 drivers/net/ethernet/amd/declance.c             |    2 +-
 drivers/net/ethernet/amd/depca.c                |    2 +-
 drivers/net/ethernet/amd/lance.c                |    2 +-
 drivers/net/ethernet/amd/ni65.c                 |    2 +-
 drivers/net/ethernet/amd/nmclan_cs.c            |    2 +-
 drivers/net/ethernet/amd/pcnet32.c              |   14 +++++++-------
 drivers/net/ethernet/amd/sun3lance.c            |    2 +-
 drivers/net/ethernet/amd/sunlance.c             |    4 ++--
 drivers/net/ethernet/apple/mace.c               |    4 ++--
 drivers/net/ethernet/apple/macmace.c            |    2 +-
 drivers/net/ethernet/atheros/atl1c/atl1c_main.c |    2 +-
 drivers/net/ethernet/cadence/at91_ether.c       |    2 +-
 29 files changed, 44 insertions(+), 45 deletions(-)

diff --git a/drivers/net/ethernet/3com/3c501.c b/drivers/net/ethernet/3com/3c501.c
index 68da81d..bf73e1a 100644
--- a/drivers/net/ethernet/3com/3c501.c
+++ b/drivers/net/ethernet/3com/3c501.c
@@ -702,7 +702,7 @@ static void el_receive(struct net_device *dev)
 	 */
 
 	outb(AX_SYS, AX_CMD);
-	skb = dev_alloc_skb(pkt_len+2);
+	skb = netdev_alloc_skb(dev, pkt_len + 2);
 
 	/*
 	 *	Start of frame
diff --git a/drivers/net/ethernet/3com/3c509.c b/drivers/net/ethernet/3com/3c509.c
index 92053e6..41719da 100644
--- a/drivers/net/ethernet/3com/3c509.c
+++ b/drivers/net/ethernet/3com/3c509.c
@@ -1066,7 +1066,7 @@ el3_rx(struct net_device *dev)
 			short pkt_len = rx_status & 0x7ff;
 			struct sk_buff *skb;
 
-			skb = dev_alloc_skb(pkt_len+5);
+			skb = netdev_alloc_skb(dev, pkt_len + 5);
 			if (el3_debug > 4)
 				pr_debug("Receiving packet size %d status %4.4x.\n",
 					   pkt_len, rx_status);
diff --git a/drivers/net/ethernet/3com/3c574_cs.c b/drivers/net/ethernet/3com/3c574_cs.c
index 9c01bc9..e61b2f8 100644
--- a/drivers/net/ethernet/3com/3c574_cs.c
+++ b/drivers/net/ethernet/3com/3c574_cs.c
@@ -1012,7 +1012,7 @@ static int el3_rx(struct net_device *dev, int worklimit)
 			short pkt_len = rx_status & 0x7ff;
 			struct sk_buff *skb;
 
-			skb = dev_alloc_skb(pkt_len+5);
+			skb = netdev_alloc_skb(dev, pkt_len + 5);
 
 			pr_debug("  Receiving packet size %d status %4.4x.\n",
 				  pkt_len, rx_status);
diff --git a/drivers/net/ethernet/3com/3c589_cs.c b/drivers/net/ethernet/3com/3c589_cs.c
index da410f0..b23253b 100644
--- a/drivers/net/ethernet/3com/3c589_cs.c
+++ b/drivers/net/ethernet/3com/3c589_cs.c
@@ -819,7 +819,7 @@ static int el3_rx(struct net_device *dev)
 	    short pkt_len = rx_status & 0x7ff;
 	    struct sk_buff *skb;
 
-	    skb = dev_alloc_skb(pkt_len+5);
+	    skb = netdev_alloc_skb(dev, pkt_len + 5);
 
 	    netdev_dbg(dev, "    Receiving packet size %d status %4.4x.\n",
 		       pkt_len, rx_status);
diff --git a/drivers/net/ethernet/3com/3c59x.c b/drivers/net/ethernet/3com/3c59x.c
index 8153a3e..c461561 100644
--- a/drivers/net/ethernet/3com/3c59x.c
+++ b/drivers/net/ethernet/3com/3c59x.c
@@ -2500,7 +2500,7 @@ static int vortex_rx(struct net_device *dev)
 			int pkt_len = rx_status & 0x1fff;
 			struct sk_buff *skb;
 
-			skb = dev_alloc_skb(pkt_len + 5);
+			skb = netdev_alloc_skb(dev, pkt_len + 5);
 			if (vortex_debug > 4)
 				pr_debug("Receiving packet size %d status %4.4x.\n",
 					   pkt_len, rx_status);
@@ -2579,7 +2579,8 @@ boomerang_rx(struct net_device *dev)
 
 			/* Check if the packet is long enough to just accept without
 			   copying to a properly sized skbuff. */
-			if (pkt_len < rx_copybreak && (skb = dev_alloc_skb(pkt_len + 2)) != NULL) {
+			if (pkt_len < rx_copybreak &&
+					(skb = netdev_alloc_skb(dev, pkt_len + 2)) != NULL) {
 				skb_reserve(skb, 2);	/* Align IP on 16 byte boundaries */
 				pci_dma_sync_single_for_cpu(VORTEX_PCI(vp), dma, PKT_BUF_SZ, PCI_DMA_FROMDEVICE);
 				/* 'skb_put()' points to the start of sk_buff data area. */
diff --git a/drivers/net/ethernet/3com/typhoon.c b/drivers/net/ethernet/3com/typhoon.c
index 6d6bc75..f7d622e 100644
--- a/drivers/net/ethernet/3com/typhoon.c
+++ b/drivers/net/ethernet/3com/typhoon.c
@@ -1607,7 +1607,7 @@ typhoon_alloc_rx_skb(struct typhoon *tp, u32 idx)
 				le32_to_cpu(indexes->rxBuffCleared))
 		return -ENOMEM;
 
-	skb = dev_alloc_skb(PKT_BUF_SZ);
+	skb = netdev_alloc_skb(tp->dev, PKT_BUF_SZ);
 	if(!skb)
 		return -ENOMEM;
 
@@ -1618,7 +1618,6 @@ typhoon_alloc_rx_skb(struct typhoon *tp, u32 idx)
 	skb_reserve(skb, 2);
 #endif
 
-	skb->dev = tp->dev;
 	dma_addr = pci_map_single(tp->pdev, skb->data,
 				  PKT_BUF_SZ, PCI_DMA_FROMDEVICE);
 
@@ -1673,7 +1672,7 @@ typhoon_rx(struct typhoon *tp, struct basic_ring *rxRing, volatile __le32 * read
 		pkt_len = le16_to_cpu(rx->frameLen);
 
 		if(pkt_len < rx_copybreak &&
-		   (new_skb = dev_alloc_skb(pkt_len + 2)) != NULL) {
+		   (new_skb = netdev_alloc_skb(tp->dev, pkt_len + 2)) != NULL) {
 			skb_reserve(new_skb, 2);
 			pci_dma_sync_single_for_cpu(tp->pdev, dma_addr,
 						    PKT_BUF_SZ,
diff --git a/drivers/net/ethernet/8390/axnet_cs.c b/drivers/net/ethernet/8390/axnet_cs.c
index bba51cd..0965d58 100644
--- a/drivers/net/ethernet/8390/axnet_cs.c
+++ b/drivers/net/ethernet/8390/axnet_cs.c
@@ -1408,7 +1408,7 @@ static void ei_receive(struct net_device *dev)
 		{
 			struct sk_buff *skb;
 			
-			skb = dev_alloc_skb(pkt_len+2);
+			skb = netdev_alloc_skb(dev, pkt_len + 2);
 			if (skb == NULL) 
 			{
 				if (ei_debug > 1)
diff --git a/drivers/net/ethernet/8390/lib8390.c b/drivers/net/ethernet/8390/lib8390.c
index 05ae214..e77f624 100644
--- a/drivers/net/ethernet/8390/lib8390.c
+++ b/drivers/net/ethernet/8390/lib8390.c
@@ -717,7 +717,7 @@ static void ei_receive(struct net_device *dev)
 		} else if ((pkt_stat & 0x0F) == ENRSR_RXOK) {
 			struct sk_buff *skb;
 
-			skb = dev_alloc_skb(pkt_len+2);
+			skb = netdev_alloc_skb(dev, pkt_len + 2);
 			if (skb == NULL) {
 				if (ei_debug > 1)
 					netdev_dbg(dev, "Couldn't allocate a sk_buff of size %d\n",
diff --git a/drivers/net/ethernet/adaptec/starfire.c b/drivers/net/ethernet/adaptec/starfire.c
index cb4f38a..d818689 100644
--- a/drivers/net/ethernet/adaptec/starfire.c
+++ b/drivers/net/ethernet/adaptec/starfire.c
@@ -1180,12 +1180,11 @@ static void init_ring(struct net_device *dev)
 
 	/* Fill in the Rx buffers.  Handle allocation failure gracefully. */
 	for (i = 0; i < RX_RING_SIZE; i++) {
-		struct sk_buff *skb = dev_alloc_skb(np->rx_buf_sz);
+		struct sk_buff *skb = netdev_alloc_skb(dev, np->rx_buf_sz);
 		np->rx_info[i].skb = skb;
 		if (skb == NULL)
 			break;
 		np->rx_info[i].mapping = pci_map_single(np->pci_dev, skb->data, np->rx_buf_sz, PCI_DMA_FROMDEVICE);
-		skb->dev = dev;			/* Mark as being used by this device. */
 		/* Grrr, we cannot offset to correctly align the IP header. */
 		np->rx_ring[i].rxaddr = cpu_to_dma(np->rx_info[i].mapping | RxDescValid);
 	}
@@ -1473,7 +1472,7 @@ static int __netdev_rx(struct net_device *dev, int *quota)
 		/* Check if the packet is long enough to accept without copying
 		   to a minimally-sized skbuff. */
 		if (pkt_len < rx_copybreak &&
-		    (skb = dev_alloc_skb(pkt_len + 2)) != NULL) {
+		    (skb = netdev_alloc_skb(dev, pkt_len + 2)) != NULL) {
 			skb_reserve(skb, 2);	/* 16 byte align the IP header */
 			pci_dma_sync_single_for_cpu(np->pci_dev,
 						    np->rx_info[entry].mapping,
@@ -1597,13 +1596,12 @@ static void refill_rx_ring(struct net_device *dev)
 	for (; np->cur_rx - np->dirty_rx > 0; np->dirty_rx++) {
 		entry = np->dirty_rx % RX_RING_SIZE;
 		if (np->rx_info[entry].skb == NULL) {
-			skb = dev_alloc_skb(np->rx_buf_sz);
+			skb = netdev_alloc_skb(dev, np->rx_buf_sz);
 			np->rx_info[entry].skb = skb;
 			if (skb == NULL)
 				break;	/* Better luck next round. */
 			np->rx_info[entry].mapping =
 				pci_map_single(np->pci_dev, skb->data, np->rx_buf_sz, PCI_DMA_FROMDEVICE);
-			skb->dev = dev;	/* Mark as being used by this device. */
 			np->rx_ring[entry].rxaddr =
 				cpu_to_dma(np->rx_info[entry].mapping | RxDescValid);
 		}
diff --git a/drivers/net/ethernet/aeroflex/greth.c b/drivers/net/ethernet/aeroflex/greth.c
index c885aa9..b23751e 100644
--- a/drivers/net/ethernet/aeroflex/greth.c
+++ b/drivers/net/ethernet/aeroflex/greth.c
@@ -785,7 +785,6 @@ static int greth_rx(struct net_device *dev, int limit)
 
 			} else {
 				skb_reserve(skb, NET_IP_ALIGN);
-				skb->dev = dev;
 
 				dma_sync_single_for_cpu(greth->dev,
 							dma_addr,
diff --git a/drivers/net/ethernet/amd/7990.c b/drivers/net/ethernet/amd/7990.c
index 60b35fb..1b046f5 100644
--- a/drivers/net/ethernet/amd/7990.c
+++ b/drivers/net/ethernet/amd/7990.c
@@ -316,7 +316,7 @@ static int lance_rx (struct net_device *dev)
                         if (bits & LE_R1_EOP) dev->stats.rx_errors++;
                 } else {
 			int len = (rd->mblength & 0xfff) - 4;
-			struct sk_buff *skb = dev_alloc_skb (len+2);
+			struct sk_buff *skb = netdev_alloc_skb(dev, len + 2);
 
                         if (!skb) {
                                 printk ("%s: Memory squeeze, deferring packet.\n",
diff --git a/drivers/net/ethernet/amd/a2065.c b/drivers/net/ethernet/amd/a2065.c
index 825e5d4..689dfca 100644
--- a/drivers/net/ethernet/amd/a2065.c
+++ b/drivers/net/ethernet/amd/a2065.c
@@ -290,7 +290,7 @@ static int lance_rx(struct net_device *dev)
 				dev->stats.rx_errors++;
 		} else {
 			int len = (rd->mblength & 0xfff) - 4;
-			struct sk_buff *skb = dev_alloc_skb(len + 2);
+			struct sk_buff *skb = netdev_alloc_skb(dev, len + 2);
 
 			if (!skb) {
 				netdev_warn(dev, "Memory squeeze, deferring packet\n");
diff --git a/drivers/net/ethernet/amd/am79c961a.c b/drivers/net/ethernet/amd/am79c961a.c
index 7d5ded8..bb77ce9 100644
--- a/drivers/net/ethernet/amd/am79c961a.c
+++ b/drivers/net/ethernet/amd/am79c961a.c
@@ -516,7 +516,7 @@ am79c961_rx(struct net_device *dev, struct dev_priv *priv)
 		}
 
 		len = am_readword(dev, hdraddr + 6);
-		skb = dev_alloc_skb(len + 2);
+		skb = netdev_alloc_skb(dev, len + 2);
 
 		if (skb) {
 			skb_reserve(skb, 2);
diff --git a/drivers/net/ethernet/amd/amd8111e.c b/drivers/net/ethernet/amd/amd8111e.c
index 33e0a8c..1974bc2 100644
--- a/drivers/net/ethernet/amd/amd8111e.c
+++ b/drivers/net/ethernet/amd/amd8111e.c
@@ -336,7 +336,8 @@ static int amd8111e_init_ring(struct net_device *dev)
 	/* Allocating receive  skbs */
 	for (i = 0; i < NUM_RX_BUFFERS; i++) {
 
-		if (!(lp->rx_skbuff[i] = dev_alloc_skb(lp->rx_buff_len))) {
+		lp->rx_skbuff[i] = netdev_alloc_skb(dev, lp->rx_buff_len);
+		if (!lp->rx_skbuff[i]) {
 				/* Release previos allocated skbs */
 				for(--i; i >= 0 ;i--)
 					dev_kfree_skb(lp->rx_skbuff[i]);
@@ -768,7 +769,8 @@ static int amd8111e_rx_poll(struct napi_struct *napi, int budget)
 			}
 			if(--rx_pkt_limit < 0)
 				goto rx_not_empty;
-			if(!(new_skb = dev_alloc_skb(lp->rx_buff_len))){
+			new_skb = netdev_alloc_skb(dev, lp->rx_buff_len);
+			if (new_skb == NULL) {
 				/* if allocation fail,
 				   ignore that pkt and go to next one */
 				lp->rx_ring[rx_index].rx_flags &= RESET_RX_FLAGS;
diff --git a/drivers/net/ethernet/amd/ariadne.c b/drivers/net/ethernet/amd/ariadne.c
index eb18e1f..f4c228e 100644
--- a/drivers/net/ethernet/amd/ariadne.c
+++ b/drivers/net/ethernet/amd/ariadne.c
@@ -191,7 +191,7 @@ static int ariadne_rx(struct net_device *dev)
 			short pkt_len = swapw(priv->rx_ring[entry]->RMD3);
 			struct sk_buff *skb;
 
-			skb = dev_alloc_skb(pkt_len + 2);
+			skb = netdev_alloc_skb(dev, pkt_len + 2);
 			if (skb == NULL) {
 				netdev_warn(dev, "Memory squeeze, deferring packet\n");
 				for (i = 0; i < RX_RING_SIZE; i++)
diff --git a/drivers/net/ethernet/amd/atarilance.c b/drivers/net/ethernet/amd/atarilance.c
index 15bfa28..70ed79c 100644
--- a/drivers/net/ethernet/amd/atarilance.c
+++ b/drivers/net/ethernet/amd/atarilance.c
@@ -997,7 +997,7 @@ static int lance_rx( struct net_device *dev )
 				dev->stats.rx_errors++;
 			}
 			else {
-				skb = dev_alloc_skb( pkt_len+2 );
+				skb = netdev_alloc_skb(dev, pkt_len + 2);
 				if (skb == NULL) {
 					DPRINTK( 1, ( "%s: Memory squeeze, deferring packet.\n",
 								  dev->name ));
diff --git a/drivers/net/ethernet/amd/au1000_eth.c b/drivers/net/ethernet/amd/au1000_eth.c
index 8b95dd3..722e716 100644
--- a/drivers/net/ethernet/amd/au1000_eth.c
+++ b/drivers/net/ethernet/amd/au1000_eth.c
@@ -725,7 +725,7 @@ static int au1000_rx(struct net_device *dev)
 			/* good frame */
 			frmlen = (status & RX_FRAME_LEN_MASK);
 			frmlen -= 4; /* Remove FCS */
-			skb = dev_alloc_skb(frmlen + 2);
+			skb = netdev_alloc_skb(dev, frmlen + 2);
 			if (skb == NULL) {
 				netdev_err(dev, "Memory squeeze, dropping packet.\n");
 				dev->stats.rx_dropped++;
diff --git a/drivers/net/ethernet/amd/declance.c b/drivers/net/ethernet/amd/declance.c
index 73f8d4f..39fe95e 100644
--- a/drivers/net/ethernet/amd/declance.c
+++ b/drivers/net/ethernet/amd/declance.c
@@ -605,7 +605,7 @@ static int lance_rx(struct net_device *dev)
 				dev->stats.rx_errors++;
 		} else {
 			len = (*rds_ptr(rd, mblength, lp->type) & 0xfff) - 4;
-			skb = dev_alloc_skb(len + 2);
+			skb = netdev_alloc_skb(dev, len + 2);
 
 			if (skb == 0) {
 				printk("%s: Memory squeeze, deferring packet.\n",
diff --git a/drivers/net/ethernet/amd/depca.c b/drivers/net/ethernet/amd/depca.c
index 681970c..86dd957 100644
--- a/drivers/net/ethernet/amd/depca.c
+++ b/drivers/net/ethernet/amd/depca.c
@@ -1042,7 +1042,7 @@ static int depca_rx(struct net_device *dev)
 				short len, pkt_len = readw(&lp->rx_ring[entry].msg_length) - 4;
 				struct sk_buff *skb;
 
-				skb = dev_alloc_skb(pkt_len + 2);
+				skb = netdev_alloc_skb(dev, pkt_len + 2);
 				if (skb != NULL) {
 					unsigned char *buf;
 					skb_reserve(skb, 2);	/* 16 byte align the IP header */
diff --git a/drivers/net/ethernet/amd/lance.c b/drivers/net/ethernet/amd/lance.c
index a6e2e84..8958e7a 100644
--- a/drivers/net/ethernet/amd/lance.c
+++ b/drivers/net/ethernet/amd/lance.c
@@ -1183,7 +1183,7 @@ lance_rx(struct net_device *dev)
 			}
 			else
 			{
-				skb = dev_alloc_skb(pkt_len+2);
+				skb = netdev_alloc_skb(pkt_len + 2);
 				if (skb == NULL)
 				{
 					printk("%s: Memory squeeze, deferring packet.\n", dev->name);
diff --git a/drivers/net/ethernet/amd/ni65.c b/drivers/net/ethernet/amd/ni65.c
index 6e6aa72..fb78e25 100644
--- a/drivers/net/ethernet/amd/ni65.c
+++ b/drivers/net/ethernet/amd/ni65.c
@@ -1091,7 +1091,7 @@ static void ni65_recv_intr(struct net_device *dev,int csr0)
 			if (skb)
 				skb_reserve(skb,16);
 #else
-			struct sk_buff *skb = dev_alloc_skb(len+2);
+			struct sk_buff *skb = netdev_alloc_skb(dev, len + 2);
 #endif
 			if(skb)
 			{
diff --git a/drivers/net/ethernet/amd/nmclan_cs.c b/drivers/net/ethernet/amd/nmclan_cs.c
index 6be0dd6..d1633e9 100644
--- a/drivers/net/ethernet/amd/nmclan_cs.c
+++ b/drivers/net/ethernet/amd/nmclan_cs.c
@@ -1104,7 +1104,7 @@ static int mace_rx(struct net_device *dev, unsigned char RxCnt)
       pr_debug("    receiving packet size 0x%X rx_status"
 	    " 0x%X.\n", pkt_len, rx_status);
 
-      skb = dev_alloc_skb(pkt_len+2);
+	skb = netdev_alloc_skb(dev, pkt_len + 2);
 
       if (skb != NULL) {
 	skb_reserve(skb, 2);
diff --git a/drivers/net/ethernet/amd/pcnet32.c b/drivers/net/ethernet/amd/pcnet32.c
index 20e6dab..becc97a 100644
--- a/drivers/net/ethernet/amd/pcnet32.c
+++ b/drivers/net/ethernet/amd/pcnet32.c
@@ -588,11 +588,11 @@ static void pcnet32_realloc_rx_ring(struct net_device *dev,
 	/* now allocate any new buffers needed */
 	for (; new < size; new++) {
 		struct sk_buff *rx_skbuff;
-		new_skb_list[new] = dev_alloc_skb(PKT_BUF_SKB);
+		new_skb_list[new] = netdev_alloc_skb(dev, PKT_BUF_SKB);
 		rx_skbuff = new_skb_list[new];
 		if (!rx_skbuff) {
 			/* keep the original lists and buffers */
-			netif_err(lp, drv, dev, "%s dev_alloc_skb failed\n",
+			netif_err(lp, drv, dev, "%s netdev_alloc_skb failed\n",
 				  __func__);
 			goto free_all_new;
 		}
@@ -909,7 +909,7 @@ static int pcnet32_loopback_test(struct net_device *dev, uint64_t * data1)
 	/* Initialize Transmit buffers. */
 	size = data_len + 15;
 	for (x = 0; x < numbuffs; x++) {
-		skb = dev_alloc_skb(size);
+		skb = netdev_alloc_skb(dev, size);
 		if (!skb) {
 			netif_printk(lp, hw, KERN_DEBUG, dev,
 				     "Cannot allocate skb at line: %d!\n",
@@ -1152,7 +1152,7 @@ static void pcnet32_rx_entry(struct net_device *dev,
 	if (pkt_len > rx_copybreak) {
 		struct sk_buff *newskb;
 
-		newskb = dev_alloc_skb(PKT_BUF_SKB);
+		newskb = netdev_alloc_skb(dev, PKT_BUF_SKB);
 		if (newskb) {
 			skb_reserve(newskb, NET_IP_ALIGN);
 			skb = lp->rx_skbuff[entry];
@@ -1172,7 +1172,7 @@ static void pcnet32_rx_entry(struct net_device *dev,
 		} else
 			skb = NULL;
 	} else
-		skb = dev_alloc_skb(pkt_len + NET_IP_ALIGN);
+		skb = netdev_alloc_skb(dev, pkt_len + NET_IP_ALIGN);
 
 	if (skb == NULL) {
 		netif_err(lp, drv, dev, "Memory squeeze, dropping packet\n");
@@ -2273,11 +2273,11 @@ static int pcnet32_init_ring(struct net_device *dev)
 	for (i = 0; i < lp->rx_ring_size; i++) {
 		struct sk_buff *rx_skbuff = lp->rx_skbuff[i];
 		if (rx_skbuff == NULL) {
-			lp->rx_skbuff[i] = dev_alloc_skb(PKT_BUF_SKB);
+			lp->rx_skbuff[i] = netdev_alloc_skb(dev, PKT_BUF_SKB);
 			rx_skbuff = lp->rx_skbuff[i];
 			if (!rx_skbuff) {
 				/* there is not much we can do at this point */
-				netif_err(lp, drv, dev, "%s dev_alloc_skb failed\n",
+				netif_err(lp, drv, dev, "%s netdev_alloc_skb failed\n",
 					  __func__);
 				return -1;
 			}
diff --git a/drivers/net/ethernet/amd/sun3lance.c b/drivers/net/ethernet/amd/sun3lance.c
index 080b71f..74b3891 100644
--- a/drivers/net/ethernet/amd/sun3lance.c
+++ b/drivers/net/ethernet/amd/sun3lance.c
@@ -810,7 +810,7 @@ static int lance_rx( struct net_device *dev )
 				dev->stats.rx_errors++;
 			}
 			else {
-				skb = dev_alloc_skb( pkt_len+2 );
+				skb = netdev_alloc_skb(dev, pkt_len + 2);
 				if (skb == NULL) {
 					DPRINTK( 1, ( "%s: Memory squeeze, deferring packet.\n",
 						      dev->name ));
diff --git a/drivers/net/ethernet/amd/sunlance.c b/drivers/net/ethernet/amd/sunlance.c
index 7ea16d3..e3fe350 100644
--- a/drivers/net/ethernet/amd/sunlance.c
+++ b/drivers/net/ethernet/amd/sunlance.c
@@ -534,7 +534,7 @@ static void lance_rx_dvma(struct net_device *dev)
 			if (bits & LE_R1_EOP) dev->stats.rx_errors++;
 		} else {
 			len = (rd->mblength & 0xfff) - 4;
-			skb = dev_alloc_skb(len + 2);
+			skb = netdev_alloc_skb(dev, len + 2);
 
 			if (skb == NULL) {
 				printk(KERN_INFO "%s: Memory squeeze, deferring packet.\n",
@@ -706,7 +706,7 @@ static void lance_rx_pio(struct net_device *dev)
 			if (bits & LE_R1_EOP) dev->stats.rx_errors++;
 		} else {
 			len = (sbus_readw(&rd->mblength) & 0xfff) - 4;
-			skb = dev_alloc_skb(len + 2);
+			skb = netdev_alloc_skb(dev, len + 2);
 
 			if (skb == NULL) {
 				printk(KERN_INFO "%s: Memory squeeze, deferring packet.\n",
diff --git a/drivers/net/ethernet/apple/mace.c b/drivers/net/ethernet/apple/mace.c
index bec87bd..31a2d56 100644
--- a/drivers/net/ethernet/apple/mace.c
+++ b/drivers/net/ethernet/apple/mace.c
@@ -447,7 +447,7 @@ static int mace_open(struct net_device *dev)
     memset((char *)mp->rx_cmds, 0, N_RX_RING * sizeof(struct dbdma_cmd));
     cp = mp->rx_cmds;
     for (i = 0; i < N_RX_RING - 1; ++i) {
-	skb = dev_alloc_skb(RX_BUFLEN + 2);
+	skb = netdev_alloc_skb(dev, RX_BUFLEN + 2);
 	if (!skb) {
 	    data = dummy_buf;
 	} else {
@@ -959,7 +959,7 @@ static irqreturn_t mace_rxdma_intr(int irq, void *dev_id)
 	cp = mp->rx_cmds + i;
 	skb = mp->rx_bufs[i];
 	if (!skb) {
-	    skb = dev_alloc_skb(RX_BUFLEN + 2);
+		skb = netdev_alloc_skb(RX_BUFLEN + 2);
 	    if (skb) {
 		skb_reserve(skb, 2);
 		mp->rx_bufs[i] = skb;
diff --git a/drivers/net/ethernet/apple/macmace.c b/drivers/net/ethernet/apple/macmace.c
index 7cf81bb..ab7ff86 100644
--- a/drivers/net/ethernet/apple/macmace.c
+++ b/drivers/net/ethernet/apple/macmace.c
@@ -661,7 +661,7 @@ static void mace_dma_rx_frame(struct net_device *dev, struct mace_frame *mf)
 	} else {
 		unsigned int frame_length = mf->rcvcnt + ((frame_status & 0x0F) << 8 );
 
-		skb = dev_alloc_skb(frame_length + 2);
+		skb = netdev_alloc_skb(dev, frame_length + 2);
 		if (!skb) {
 			dev->stats.rx_dropped++;
 			return;
diff --git a/drivers/net/ethernet/atheros/atl1c/atl1c_main.c b/drivers/net/ethernet/atheros/atl1c/atl1c_main.c
index b859124..c170c6e 100644
--- a/drivers/net/ethernet/atheros/atl1c/atl1c_main.c
+++ b/drivers/net/ethernet/atheros/atl1c/atl1c_main.c
@@ -1765,7 +1765,7 @@ static int atl1c_alloc_rx_buffer(struct atl1c_adapter *adapter, const int ringid
 	while (next_info->flags & ATL1C_BUFFER_FREE) {
 		rfd_desc = ATL1C_RFD_DESC(rfd_ring, rfd_next_to_use);
 
-		skb = dev_alloc_skb(adapter->rx_buffer_len);
+		skb = netdev_alloc_skb(adapter->netdev, adapter->rx_buffer_len);
 		if (unlikely(!skb)) {
 			if (netif_msg_rx_err(adapter))
 				dev_warn(&pdev->dev, "alloc rx buffer failed\n");
diff --git a/drivers/net/ethernet/cadence/at91_ether.c b/drivers/net/ethernet/cadence/at91_ether.c
index 1a5b6ef..9061170 100644
--- a/drivers/net/ethernet/cadence/at91_ether.c
+++ b/drivers/net/ethernet/cadence/at91_ether.c
@@ -886,7 +886,7 @@ static void at91ether_rx(struct net_device *dev)
 	while (dlist->descriptors[lp->rxBuffIndex].addr & EMAC_DESC_DONE) {
 		p_recv = dlist->recv_buf[lp->rxBuffIndex];
 		pktlen = dlist->descriptors[lp->rxBuffIndex].size & 0x7ff;	/* Length of frame including FCS */
-		skb = dev_alloc_skb(pktlen + 2);
+		skb = netdev_alloc_skb(dev, pktlen + 2);
 		if (skb != NULL) {
 			skb_reserve(skb, 2);
 			memcpy(skb_put(skb, pktlen), p_recv, pktlen);
