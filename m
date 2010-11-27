From: Szymon Janc <szymon@janc.net.pl>
Subject: [PATCH 1/6] forcedeth: fix multiple code style issues
Date: Sat, 27 Nov 2010 19:39:43 +0100
Message-ID: <1290883188-2078-2-git-send-email-szymon@janc.net.pl>
References: <1290883188-2078-1-git-send-email-szymon@janc.net.pl>
Cc: Szymon Janc <szymon@janc.net.pl>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from cox.rootnode.net ([89.248.165.14]:56871 "EHLO cox.rootnode.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753342Ab0K0SvD (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sat, 27 Nov 2010 13:51:03 -0500
Received: from DSPAM-Daemon (localhost [127.0.0.1])
	by cox.rootnode.net (Postfix) with SMTP id 979518015248
	for <netdev@vger.kernel.org>; Sat, 27 Nov 2010 19:41:49 +0100 (CET)
In-Reply-To: <1290883188-2078-1-git-send-email-szymon@janc.net.pl>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Signed-off-by: Szymon Janc <szymon@janc.net.pl>
---
 drivers/net/forcedeth.c |  301 +++++++++++++++++++++--------------------------
 1 files changed, 135 insertions(+), 166 deletions(-)

diff --git a/drivers/net/forcedeth.c b/drivers/net/forcedeth.c
index 0fa1776..87757c8 100644
--- a/drivers/net/forcedeth.c
+++ b/drivers/net/forcedeth.c
@@ -186,9 +186,9 @@ enum {
 	NvRegSlotTime = 0x9c,
 #define NVREG_SLOTTIME_LEGBF_ENABLED	0x80000000
 #define NVREG_SLOTTIME_10_100_FULL	0x00007f00
-#define NVREG_SLOTTIME_1000_FULL 	0x0003ff00
+#define NVREG_SLOTTIME_1000_FULL	0x0003ff00
 #define NVREG_SLOTTIME_HALF		0x0000ff00
-#define NVREG_SLOTTIME_DEFAULT	 	0x00007f00
+#define NVREG_SLOTTIME_DEFAULT		0x00007f00
 #define NVREG_SLOTTIME_MASK		0x000000ff
 
 	NvRegTxDeferral = 0xA0,
@@ -297,7 +297,7 @@ enum {
 #define NVREG_WAKEUPFLAGS_ENABLE	0x1111
 
 	NvRegMgmtUnitGetVersion = 0x204,
-#define NVREG_MGMTUNITGETVERSION     	0x01
+#define NVREG_MGMTUNITGETVERSION	0x01
 	NvRegMgmtUnitVersion = 0x208,
 #define NVREG_MGMTUNITVERSION		0x08
 	NvRegPowerCap = 0x268,
@@ -368,8 +368,8 @@ struct ring_desc_ex {
 };
 
 union ring_type {
-	struct ring_desc* orig;
-	struct ring_desc_ex* ex;
+	struct ring_desc *orig;
+	struct ring_desc_ex *ex;
 };
 
 #define FLAG_MASK_V1 0xffff0000
@@ -444,10 +444,10 @@ union ring_type {
 #define NV_RX3_VLAN_TAG_MASK	(0x0000FFFF)
 
 /* Miscelaneous hardware related defines: */
-#define NV_PCI_REGSZ_VER1      	0x270
-#define NV_PCI_REGSZ_VER2      	0x2d4
-#define NV_PCI_REGSZ_VER3      	0x604
-#define NV_PCI_REGSZ_MAX       	0x604
+#define NV_PCI_REGSZ_VER1	0x270
+#define NV_PCI_REGSZ_VER2	0x2d4
+#define NV_PCI_REGSZ_VER3	0x604
+#define NV_PCI_REGSZ_MAX	0x604
 
 /* various timeout delays: all in usec */
 #define NV_TXRX_RESET_DELAY	4
@@ -717,7 +717,7 @@ static const struct register_test nv_registers_test[] = {
 	{ NvRegMulticastAddrA, 0xffffffff },
 	{ NvRegTxWatermark, 0x0ff },
 	{ NvRegWakeUpFlags, 0x07777 },
-	{ 0,0 }
+	{ 0, 0 }
 };
 
 struct nv_skb_map {
@@ -911,7 +911,7 @@ static int phy_cross = NV_CROSSOVER_DETECTION_DISABLED;
  * Power down phy when interface is down (persists through reboot;
  * older Linux and other OSes may not power it up again)
  */
-static int phy_power_down = 0;
+static int phy_power_down;
 
 static inline struct fe_priv *get_nvpriv(struct net_device *dev)
 {
@@ -984,12 +984,10 @@ static void setup_hw_rings(struct net_device *dev, int rxtx_flags)
 	u8 __iomem *base = get_hwbase(dev);
 
 	if (!nv_optimized(np)) {
-		if (rxtx_flags & NV_SETUP_RX_RING) {
+		if (rxtx_flags & NV_SETUP_RX_RING)
 			writel(dma_low(np->ring_addr), base + NvRegRxRingPhysAddr);
-		}
-		if (rxtx_flags & NV_SETUP_TX_RING) {
+		if (rxtx_flags & NV_SETUP_TX_RING)
 			writel(dma_low(np->ring_addr + np->rx_ring_size*sizeof(struct ring_desc)), base + NvRegTxRingPhysAddr);
-		}
 	} else {
 		if (rxtx_flags & NV_SETUP_RX_RING) {
 			writel(dma_low(np->ring_addr), base + NvRegRxRingPhysAddr);
@@ -1174,9 +1172,8 @@ static int phy_reset(struct net_device *dev, u32 bmcr_setup)
 	unsigned int tries = 0;
 
 	miicontrol = BMCR_RESET | bmcr_setup;
-	if (mii_rw(dev, np->phyaddr, MII_BMCR, miicontrol)) {
+	if (mii_rw(dev, np->phyaddr, MII_BMCR, miicontrol))
 		return -1;
-	}
 
 	/* wait for 500ms */
 	msleep(500);
@@ -1196,7 +1193,7 @@ static int phy_init(struct net_device *dev)
 {
 	struct fe_priv *np = get_nvpriv(dev);
 	u8 __iomem *base = get_hwbase(dev);
-	u32 phyinterface, phy_reserved, mii_status, mii_control, mii_control_1000,reg;
+	u32 phyinterface, phy_reserved, mii_status, mii_control, mii_control_1000, reg;
 
 	/* phy errata for E3016 phy */
 	if (np->phy_model == PHY_MODEL_MARVELL_E3016) {
@@ -1313,8 +1310,7 @@ static int phy_init(struct net_device *dev)
 			printk(KERN_INFO "%s: phy init failed.\n", pci_name(np->pci_dev));
 			return PHY_ERROR;
 		}
-	}
-	else
+	} else
 		np->gigabit = 0;
 
 	mii_control = mii_rw(dev, np->phyaddr, MII_BMCR, MII_READ);
@@ -1340,7 +1336,7 @@ static int phy_init(struct net_device *dev)
 	}
 
 	/* phy vendor specific configuration */
-	if ((np->phy_oui == PHY_OUI_CICADA) && (phyinterface & PHY_RGMII) ) {
+	if ((np->phy_oui == PHY_OUI_CICADA) && (phyinterface & PHY_RGMII)) {
 		phy_reserved = mii_rw(dev, np->phyaddr, MII_RESV1, MII_READ);
 		phy_reserved &= ~(PHY_CICADA_INIT1 | PHY_CICADA_INIT2);
 		phy_reserved |= (PHY_CICADA_INIT3 | PHY_CICADA_INIT4);
@@ -1501,12 +1497,10 @@ static int phy_init(struct net_device *dev)
 	/* restart auto negotiation, power down phy */
 	mii_control = mii_rw(dev, np->phyaddr, MII_BMCR, MII_READ);
 	mii_control |= (BMCR_ANRESTART | BMCR_ANENABLE);
-	if (phy_power_down) {
+	if (phy_power_down)
 		mii_control |= BMCR_PDOWN;
-	}
-	if (mii_rw(dev, np->phyaddr, MII_BMCR, mii_control)) {
+	if (mii_rw(dev, np->phyaddr, MII_BMCR, mii_control))
 		return PHY_ERROR;
-	}
 
 	return 0;
 }
@@ -1526,8 +1520,8 @@ static void nv_start_rx(struct net_device *dev)
 	}
 	writel(np->linkspeed, base + NvRegLinkSpeed);
 	pci_push(base);
-        rx_ctrl |= NVREG_RCVCTL_START;
-        if (np->mac_in_use)
+	rx_ctrl |= NVREG_RCVCTL_START;
+	if (np->mac_in_use)
 		rx_ctrl &= ~NVREG_RCVCTL_RX_PATH_EN;
 	writel(rx_ctrl, base + NvRegReceiverControl);
 	dprintk(KERN_DEBUG "%s: nv_start_rx to duplex %d, speed 0x%08x.\n",
@@ -1745,7 +1739,7 @@ static struct net_device_stats *nv_get_stats(struct net_device *dev)
 static int nv_alloc_rx(struct net_device *dev)
 {
 	struct fe_priv *np = netdev_priv(dev);
-	struct ring_desc* less_rx;
+	struct ring_desc *less_rx;
 
 	less_rx = np->get_rx.orig;
 	if (less_rx-- == np->first_rx.orig)
@@ -1767,9 +1761,8 @@ static int nv_alloc_rx(struct net_device *dev)
 				np->put_rx.orig = np->first_rx.orig;
 			if (unlikely(np->put_rx_ctx++ == np->last_rx_ctx))
 				np->put_rx_ctx = np->first_rx_ctx;
-		} else {
+		} else
 			return 1;
-		}
 	}
 	return 0;
 }
@@ -1777,7 +1770,7 @@ static int nv_alloc_rx(struct net_device *dev)
 static int nv_alloc_rx_optimized(struct net_device *dev)
 {
 	struct fe_priv *np = netdev_priv(dev);
-	struct ring_desc_ex* less_rx;
+	struct ring_desc_ex *less_rx;
 
 	less_rx = np->get_rx.ex;
 	if (less_rx-- == np->first_rx.ex)
@@ -1800,9 +1793,8 @@ static int nv_alloc_rx_optimized(struct net_device *dev)
 				np->put_rx.ex = np->first_rx.ex;
 			if (unlikely(np->put_rx_ctx++ == np->last_rx_ctx))
 				np->put_rx_ctx = np->first_rx_ctx;
-		} else {
+		} else
 			return 1;
-		}
 	}
 	return 0;
 }
@@ -2018,24 +2010,24 @@ static void nv_legacybackoff_reseed(struct net_device *dev)
 
 /* Known Good seed sets */
 static const u32 main_seedset[BACKOFF_SEEDSET_ROWS][BACKOFF_SEEDSET_LFSRS] = {
-    {145, 155, 165, 175, 185, 196, 235, 245, 255, 265, 275, 285, 660, 690, 874},
-    {245, 255, 265, 575, 385, 298, 335, 345, 355, 366, 375, 385, 761, 790, 974},
-    {145, 155, 165, 175, 185, 196, 235, 245, 255, 265, 275, 285, 660, 690, 874},
-    {245, 255, 265, 575, 385, 298, 335, 345, 355, 366, 375, 386, 761, 790, 974},
-    {266, 265, 276, 585, 397, 208, 345, 355, 365, 376, 385, 396, 771, 700, 984},
-    {266, 265, 276, 586, 397, 208, 346, 355, 365, 376, 285, 396, 771, 700, 984},
-    {366, 365, 376, 686, 497, 308, 447, 455, 466, 476, 485, 496, 871, 800,  84},
-    {466, 465, 476, 786, 597, 408, 547, 555, 566, 576, 585, 597, 971, 900, 184}};
+	{145, 155, 165, 175, 185, 196, 235, 245, 255, 265, 275, 285, 660, 690, 874},
+	{245, 255, 265, 575, 385, 298, 335, 345, 355, 366, 375, 385, 761, 790, 974},
+	{145, 155, 165, 175, 185, 196, 235, 245, 255, 265, 275, 285, 660, 690, 874},
+	{245, 255, 265, 575, 385, 298, 335, 345, 355, 366, 375, 386, 761, 790, 974},
+	{266, 265, 276, 585, 397, 208, 345, 355, 365, 376, 385, 396, 771, 700, 984},
+	{266, 265, 276, 586, 397, 208, 346, 355, 365, 376, 285, 396, 771, 700, 984},
+	{366, 365, 376, 686, 497, 308, 447, 455, 466, 476, 485, 496, 871, 800,  84},
+	{466, 465, 476, 786, 597, 408, 547, 555, 566, 576, 585, 597, 971, 900, 184} };
 
 static const u32 gear_seedset[BACKOFF_SEEDSET_ROWS][BACKOFF_SEEDSET_LFSRS] = {
-    {251, 262, 273, 324, 319, 508, 375, 364, 341, 371, 398, 193, 375,  30, 295},
-    {351, 375, 373, 469, 551, 639, 477, 464, 441, 472, 498, 293, 476, 130, 395},
-    {351, 375, 373, 469, 551, 639, 477, 464, 441, 472, 498, 293, 476, 130, 397},
-    {251, 262, 273, 324, 319, 508, 375, 364, 341, 371, 398, 193, 375,  30, 295},
-    {251, 262, 273, 324, 319, 508, 375, 364, 341, 371, 398, 193, 375,  30, 295},
-    {351, 375, 373, 469, 551, 639, 477, 464, 441, 472, 498, 293, 476, 130, 395},
-    {351, 375, 373, 469, 551, 639, 477, 464, 441, 472, 498, 293, 476, 130, 395},
-    {351, 375, 373, 469, 551, 639, 477, 464, 441, 472, 498, 293, 476, 130, 395}};
+	{251, 262, 273, 324, 319, 508, 375, 364, 341, 371, 398, 193, 375,  30, 295},
+	{351, 375, 373, 469, 551, 639, 477, 464, 441, 472, 498, 293, 476, 130, 395},
+	{351, 375, 373, 469, 551, 639, 477, 464, 441, 472, 498, 293, 476, 130, 397},
+	{251, 262, 273, 324, 319, 508, 375, 364, 341, 371, 398, 193, 375,  30, 295},
+	{251, 262, 273, 324, 319, 508, 375, 364, 341, 371, 398, 193, 375,  30, 295},
+	{351, 375, 373, 469, 551, 639, 477, 464, 441, 472, 498, 293, 476, 130, 395},
+	{351, 375, 373, 469, 551, 639, 477, 464, 441, 472, 498, 293, 476, 130, 395},
+	{351, 375, 373, 469, 551, 639, 477, 464, 441, 472, 498, 293, 476, 130, 395} };
 
 static void nv_gear_backoff_reseed(struct net_device *dev)
 {
@@ -2083,13 +2075,12 @@ static void nv_gear_backoff_reseed(struct net_device *dev)
 	temp = NVREG_BKOFFCTRL_DEFAULT | (0 << NVREG_BKOFFCTRL_SELECT);
 	temp |= combinedSeed & NVREG_BKOFFCTRL_SEED_MASK;
 	temp |= combinedSeed >> NVREG_BKOFFCTRL_GEAR;
-	writel(temp,base + NvRegBackOffControl);
+	writel(temp, base + NvRegBackOffControl);
 
-    	/* Setup seeds for all gear LFSRs. */
+	/* Setup seeds for all gear LFSRs. */
 	get_random_bytes(&seedset, sizeof(seedset));
 	seedset = seedset % BACKOFF_SEEDSET_ROWS;
-	for (i = 1; i <= BACKOFF_SEEDSET_LFSRS; i++)
-	{
+	for (i = 1; i <= BACKOFF_SEEDSET_LFSRS; i++) {
 		temp = NVREG_BKOFFCTRL_DEFAULT | (i << NVREG_BKOFFCTRL_SELECT);
 		temp |= main_seedset[seedset][i-1] & 0x3ff;
 		temp |= ((gear_seedset[seedset][i-1] & 0x3ff) << NVREG_BKOFFCTRL_GEAR);
@@ -2113,10 +2104,10 @@ static netdev_tx_t nv_start_xmit(struct sk_buff *skb, struct net_device *dev)
 	u32 size = skb_headlen(skb);
 	u32 entries = (size >> NV_TX2_TSO_MAX_SHIFT) + ((size & (NV_TX2_TSO_MAX_SIZE-1)) ? 1 : 0);
 	u32 empty_slots;
-	struct ring_desc* put_tx;
-	struct ring_desc* start_tx;
-	struct ring_desc* prev_tx;
-	struct nv_skb_map* prev_tx_ctx;
+	struct ring_desc *put_tx;
+	struct ring_desc *start_tx;
+	struct ring_desc *prev_tx;
+	struct nv_skb_map *prev_tx_ctx;
 	unsigned long flags;
 
 	/* add fragments to entries count */
@@ -2208,10 +2199,10 @@ static netdev_tx_t nv_start_xmit(struct sk_buff *skb, struct net_device *dev)
 		dev->name, entries, tx_flags_extra);
 	{
 		int j;
-		for (j=0; j<64; j++) {
+		for (j = 0; j < 64; j++) {
 			if ((j%16) == 0)
 				dprintk("\n%03x:", j);
-			dprintk(" %02x", ((unsigned char*)skb->data)[j]);
+			dprintk(" %02x", ((unsigned char *)skb->data)[j]);
 		}
 		dprintk("\n");
 	}
@@ -2233,11 +2224,11 @@ static netdev_tx_t nv_start_xmit_optimized(struct sk_buff *skb,
 	u32 size = skb_headlen(skb);
 	u32 entries = (size >> NV_TX2_TSO_MAX_SHIFT) + ((size & (NV_TX2_TSO_MAX_SIZE-1)) ? 1 : 0);
 	u32 empty_slots;
-	struct ring_desc_ex* put_tx;
-	struct ring_desc_ex* start_tx;
-	struct ring_desc_ex* prev_tx;
-	struct nv_skb_map* prev_tx_ctx;
-	struct nv_skb_map* start_tx_ctx;
+	struct ring_desc_ex *put_tx;
+	struct ring_desc_ex *start_tx;
+	struct ring_desc_ex *prev_tx;
+	struct nv_skb_map *prev_tx_ctx;
+	struct nv_skb_map *start_tx_ctx;
 	unsigned long flags;
 
 	/* add fragments to entries count */
@@ -2359,10 +2350,10 @@ static netdev_tx_t nv_start_xmit_optimized(struct sk_buff *skb,
 		dev->name, entries, tx_flags_extra);
 	{
 		int j;
-		for (j=0; j<64; j++) {
+		for (j = 0; j < 64; j++) {
 			if ((j%16) == 0)
 				dprintk("\n%03x:", j);
-			dprintk(" %02x", ((unsigned char*)skb->data)[j]);
+			dprintk(" %02x", ((unsigned char *)skb->data)[j]);
 		}
 		dprintk("\n");
 	}
@@ -2399,7 +2390,7 @@ static int nv_tx_done(struct net_device *dev, int limit)
 	struct fe_priv *np = netdev_priv(dev);
 	u32 flags;
 	int tx_work = 0;
-	struct ring_desc* orig_get_tx = np->get_tx.orig;
+	struct ring_desc *orig_get_tx = np->get_tx.orig;
 
 	while ((np->get_tx.orig != np->put_tx.orig) &&
 	       !((flags = le32_to_cpu(np->get_tx.orig->flaglen)) & NV_TX_VALID) &&
@@ -2464,7 +2455,7 @@ static int nv_tx_done_optimized(struct net_device *dev, int limit)
 	struct fe_priv *np = netdev_priv(dev);
 	u32 flags;
 	int tx_work = 0;
-	struct ring_desc_ex* orig_get_tx = np->get_tx.ex;
+	struct ring_desc_ex *orig_get_tx = np->get_tx.ex;
 
 	while ((np->get_tx.ex != np->put_tx.ex) &&
 	       !((flags = le32_to_cpu(np->get_tx.ex->flaglen)) & NV_TX2_VALID) &&
@@ -2491,9 +2482,8 @@ static int nv_tx_done_optimized(struct net_device *dev, int limit)
 			np->get_tx_ctx->skb = NULL;
 			tx_work++;
 
-			if (np->tx_limit) {
+			if (np->tx_limit)
 				nv_tx_flip_ownership(dev);
-			}
 		}
 		if (unlikely(np->get_tx.ex++ == np->last_tx.ex))
 			np->get_tx.ex = np->first_tx.ex;
@@ -2532,7 +2522,7 @@ static void nv_tx_timeout(struct net_device *dev)
 		printk(KERN_INFO "%s: Ring at %lx\n",
 		       dev->name, (unsigned long)np->ring_addr);
 		printk(KERN_INFO "%s: Dumping tx registers\n", dev->name);
-		for (i=0;i<=np->register_size;i+= 32) {
+		for (i = 0; i <= np->register_size; i += 32) {
 			printk(KERN_INFO "%3x: %08x %08x %08x %08x %08x %08x %08x %08x\n",
 					i,
 					readl(base + i + 0), readl(base + i + 4),
@@ -2541,7 +2531,7 @@ static void nv_tx_timeout(struct net_device *dev)
 					readl(base + i + 24), readl(base + i + 28));
 		}
 		printk(KERN_INFO "%s: Dumping tx ring\n", dev->name);
-		for (i=0;i<np->tx_ring_size;i+= 4) {
+		for (i = 0; i < np->tx_ring_size; i += 4) {
 			if (!nv_optimized(np)) {
 				printk(KERN_INFO "%03x: %08x %08x // %08x %08x // %08x %08x // %08x %08x\n",
 				       i,
@@ -2616,11 +2606,11 @@ static int nv_getlen(struct net_device *dev, void *packet, int datalen)
 	int protolen;	/* length as stored in the proto field */
 
 	/* 1) calculate len according to header */
-	if ( ((struct vlan_ethhdr *)packet)->h_vlan_proto == htons(ETH_P_8021Q)) {
-		protolen = ntohs( ((struct vlan_ethhdr *)packet)->h_vlan_encapsulated_proto );
+	if (((struct vlan_ethhdr *)packet)->h_vlan_proto == htons(ETH_P_8021Q)) {
+		protolen = ntohs(((struct vlan_ethhdr *)packet)->h_vlan_encapsulated_proto);
 		hdrlen = VLAN_HLEN;
 	} else {
-		protolen = ntohs( ((struct ethhdr *)packet)->h_proto);
+		protolen = ntohs(((struct ethhdr *)packet)->h_proto);
 		hdrlen = ETH_HLEN;
 	}
 	dprintk(KERN_DEBUG "%s: nv_getlen: datalen %d, protolen %d, hdrlen %d\n",
@@ -2667,7 +2657,7 @@ static int nv_rx_process(struct net_device *dev, int limit)
 	struct sk_buff *skb;
 	int len;
 
-	while((np->get_rx.orig != np->put_rx.orig) &&
+	while ((np->get_rx.orig != np->put_rx.orig) &&
 	      !((flags = le32_to_cpu(np->get_rx.orig->flaglen)) & NV_RX_AVAIL) &&
 		(rx_work < limit)) {
 
@@ -2687,11 +2677,11 @@ static int nv_rx_process(struct net_device *dev, int limit)
 
 		{
 			int j;
-			dprintk(KERN_DEBUG "Dumping packet (flags 0x%x).",flags);
-			for (j=0; j<64; j++) {
+			dprintk(KERN_DEBUG "Dumping packet (flags 0x%x).", flags);
+			for (j = 0; j < 64; j++) {
 				if ((j%16) == 0)
 					dprintk("\n%03x:", j);
-				dprintk(" %02x", ((unsigned char*)skb->data)[j]);
+				dprintk(" %02x", ((unsigned char *)skb->data)[j]);
 			}
 			dprintk("\n");
 		}
@@ -2710,9 +2700,8 @@ static int nv_rx_process(struct net_device *dev, int limit)
 					}
 					/* framing errors are soft errors */
 					else if ((flags & NV_RX_ERROR_MASK) == NV_RX_FRAMINGERR) {
-						if (flags & NV_RX_SUBSTRACT1) {
+						if (flags & NV_RX_SUBSTRACT1)
 							len--;
-						}
 					}
 					/* the rest are hard errors */
 					else {
@@ -2745,9 +2734,8 @@ static int nv_rx_process(struct net_device *dev, int limit)
 					}
 					/* framing errors are soft errors */
 					else if ((flags & NV_RX2_ERROR_MASK) == NV_RX2_FRAMINGERR) {
-						if (flags & NV_RX2_SUBSTRACT1) {
+						if (flags & NV_RX2_SUBSTRACT1)
 							len--;
-						}
 					}
 					/* the rest are hard errors */
 					else {
@@ -2797,7 +2785,7 @@ static int nv_rx_process_optimized(struct net_device *dev, int limit)
 	struct sk_buff *skb;
 	int len;
 
-	while((np->get_rx.ex != np->put_rx.ex) &&
+	while ((np->get_rx.ex != np->put_rx.ex) &&
 	      !((flags = le32_to_cpu(np->get_rx.ex->flaglen)) & NV_RX2_AVAIL) &&
 	      (rx_work < limit)) {
 
@@ -2817,11 +2805,11 @@ static int nv_rx_process_optimized(struct net_device *dev, int limit)
 
 		{
 			int j;
-			dprintk(KERN_DEBUG "Dumping packet (flags 0x%x).",flags);
-			for (j=0; j<64; j++) {
+			dprintk(KERN_DEBUG "Dumping packet (flags 0x%x).", flags);
+			for (j = 0; j < 64; j++) {
 				if ((j%16) == 0)
 					dprintk("\n%03x:", j);
-				dprintk(" %02x", ((unsigned char*)skb->data)[j]);
+				dprintk(" %02x", ((unsigned char *)skb->data)[j]);
 			}
 			dprintk("\n");
 		}
@@ -2838,9 +2826,8 @@ static int nv_rx_process_optimized(struct net_device *dev, int limit)
 				}
 				/* framing errors are soft errors */
 				else if ((flags & NV_RX2_ERROR_MASK) == NV_RX2_FRAMINGERR) {
-					if (flags & NV_RX2_SUBSTRACT1) {
+					if (flags & NV_RX2_SUBSTRACT1)
 						len--;
-					}
 				}
 				/* the rest are hard errors */
 				else {
@@ -2949,7 +2936,7 @@ static int nv_change_mtu(struct net_device *dev, int new_mtu)
 		/* reinit nic view of the rx queue */
 		writel(np->rx_buf_sz, base + NvRegOffloadConfig);
 		setup_hw_rings(dev, NV_SETUP_RX_RING | NV_SETUP_TX_RING);
-		writel( ((np->rx_ring_size-1) << NVREG_RINGSZ_RXSHIFT) + ((np->tx_ring_size-1) << NVREG_RINGSZ_TXSHIFT),
+		writel(((np->rx_ring_size-1) << NVREG_RINGSZ_RXSHIFT) + ((np->tx_ring_size-1) << NVREG_RINGSZ_TXSHIFT),
 			base + NvRegRingSizes);
 		pci_push(base);
 		writel(NVREG_TXRXCTL_KICK|np->txrxctl_bits, get_hwbase(dev) + NvRegTxRxControl);
@@ -2986,7 +2973,7 @@ static void nv_copy_mac_to_hw(struct net_device *dev)
 static int nv_set_mac_address(struct net_device *dev, void *addr)
 {
 	struct fe_priv *np = netdev_priv(dev);
-	struct sockaddr *macaddr = (struct sockaddr*)addr;
+	struct sockaddr *macaddr = (struct sockaddr *)addr;
 
 	if (!is_valid_ether_addr(macaddr->sa_data))
 		return -EADDRNOTAVAIL;
@@ -3302,7 +3289,7 @@ set_speed:
 	}
 	writel(txreg, base + NvRegTxWatermark);
 
-	writel(NVREG_MISC1_FORCE | ( np->duplex ? 0 : NVREG_MISC1_HD),
+	writel(NVREG_MISC1_FORCE | (np->duplex ? 0 : NVREG_MISC1_HD),
 		base + NvRegMisc1);
 	pci_push(base);
 	writel(np->linkspeed, base + NvRegLinkSpeed);
@@ -3312,8 +3299,8 @@ set_speed:
 	/* setup pause frame */
 	if (np->duplex != 0) {
 		if (np->autoneg && np->pause_flags & NV_PAUSEFRAME_AUTONEG) {
-			adv_pause = adv & (ADVERTISE_PAUSE_CAP| ADVERTISE_PAUSE_ASYM);
-			lpa_pause = lpa & (LPA_PAUSE_CAP| LPA_PAUSE_ASYM);
+			adv_pause = adv & (ADVERTISE_PAUSE_CAP | ADVERTISE_PAUSE_ASYM);
+			lpa_pause = lpa & (LPA_PAUSE_CAP | LPA_PAUSE_ASYM);
 
 			switch (adv_pause) {
 			case ADVERTISE_PAUSE_CAP:
@@ -3324,22 +3311,17 @@ set_speed:
 				}
 				break;
 			case ADVERTISE_PAUSE_ASYM:
-				if (lpa_pause == (LPA_PAUSE_CAP| LPA_PAUSE_ASYM))
-				{
+				if (lpa_pause == (LPA_PAUSE_CAP | LPA_PAUSE_ASYM))
 					pause_flags |= NV_PAUSEFRAME_TX_ENABLE;
-				}
 				break;
-			case ADVERTISE_PAUSE_CAP| ADVERTISE_PAUSE_ASYM:
-				if (lpa_pause & LPA_PAUSE_CAP)
-				{
+			case ADVERTISE_PAUSE_CAP | ADVERTISE_PAUSE_ASYM:
+				if (lpa_pause & LPA_PAUSE_CAP) {
 					pause_flags |=  NV_PAUSEFRAME_RX_ENABLE;
 					if (np->pause_flags & NV_PAUSEFRAME_TX_REQ)
 						pause_flags |= NV_PAUSEFRAME_TX_ENABLE;
 				}
 				if (lpa_pause == LPA_PAUSE_ASYM)
-				{
 					pause_flags |= NV_PAUSEFRAME_RX_ENABLE;
-				}
 				break;
 			}
 		} else {
@@ -3514,7 +3496,7 @@ static irqreturn_t nv_nic_irq_tx(int foo, void *data)
 
 	dprintk(KERN_DEBUG "%s: nv_nic_irq_tx\n", dev->name);
 
-	for (i=0; ; i++) {
+	for (i = 0;; i++) {
 		events = readl(base + NvRegMSIXIrqStatus) & NVREG_IRQ_TX_ALL;
 		writel(NVREG_IRQ_TX_ALL, base + NvRegMSIXIrqStatus);
 		dprintk(KERN_DEBUG "%s: tx irq: %08x\n", dev->name, events);
@@ -3553,7 +3535,7 @@ static int nv_napi_poll(struct napi_struct *napi, int budget)
 	u8 __iomem *base = get_hwbase(dev);
 	unsigned long flags;
 	int retcode;
-	int rx_count, tx_work=0, rx_work=0;
+	int rx_count, tx_work = 0, rx_work = 0;
 
 	do {
 		if (!nv_optimized(np)) {
@@ -3628,7 +3610,7 @@ static irqreturn_t nv_nic_irq_rx(int foo, void *data)
 
 	dprintk(KERN_DEBUG "%s: nv_nic_irq_rx\n", dev->name);
 
-	for (i=0; ; i++) {
+	for (i = 0;; i++) {
 		events = readl(base + NvRegMSIXIrqStatus) & NVREG_IRQ_RX_ALL;
 		writel(NVREG_IRQ_RX_ALL, base + NvRegMSIXIrqStatus);
 		dprintk(KERN_DEBUG "%s: rx irq: %08x\n", dev->name, events);
@@ -3675,7 +3657,7 @@ static irqreturn_t nv_nic_irq_other(int foo, void *data)
 
 	dprintk(KERN_DEBUG "%s: nv_nic_irq_other\n", dev->name);
 
-	for (i=0; ; i++) {
+	for (i = 0;; i++) {
 		events = readl(base + NvRegMSIXIrqStatus) & NVREG_IRQ_OTHER;
 		writel(NVREG_IRQ_OTHER, base + NvRegMSIXIrqStatus);
 		dprintk(KERN_DEBUG "%s: irq: %08x\n", dev->name, events);
@@ -3776,17 +3758,15 @@ static void set_msix_vector_map(struct net_device *dev, u32 vector, u32 irqmask)
 	 * the remaining 8 interrupts.
 	 */
 	for (i = 0; i < 8; i++) {
-		if ((irqmask >> i) & 0x1) {
+		if ((irqmask >> i) & 0x1)
 			msixmap |= vector << (i << 2);
-		}
 	}
 	writel(readl(base + NvRegMSIXMap0) | msixmap, base + NvRegMSIXMap0);
 
 	msixmap = 0;
 	for (i = 0; i < 8; i++) {
-		if ((irqmask >> (i + 8)) & 0x1) {
+		if ((irqmask >> (i + 8)) & 0x1)
 			msixmap |= vector << (i << 2);
-		}
 	}
 	writel(readl(base + NvRegMSIXMap1) | msixmap, base + NvRegMSIXMap1);
 }
@@ -3809,9 +3789,8 @@ static int nv_request_irq(struct net_device *dev, int intr_test)
 	}
 
 	if (np->msi_flags & NV_MSI_X_CAPABLE) {
-		for (i = 0; i < (np->msi_flags & NV_MSI_X_VECTORS_MASK); i++) {
+		for (i = 0; i < (np->msi_flags & NV_MSI_X_VECTORS_MASK); i++)
 			np->msi_x_entry[i].entry = i;
-		}
 		if ((ret = pci_enable_msix(np->pci_dev, np->msi_x_entry, (np->msi_flags & NV_MSI_X_VECTORS_MASK))) == 0) {
 			np->msi_flags |= NV_MSI_X_ENABLED;
 			if (optimization_mode == NV_OPTIMIZATION_MODE_THROUGHPUT && !intr_test) {
@@ -3903,9 +3882,8 @@ static void nv_free_irq(struct net_device *dev)
 	int i;
 
 	if (np->msi_flags & NV_MSI_X_ENABLED) {
-		for (i = 0; i < (np->msi_flags & NV_MSI_X_VECTORS_MASK); i++) {
+		for (i = 0; i < (np->msi_flags & NV_MSI_X_VECTORS_MASK); i++)
 			free_irq(np->msi_x_entry[i].vector, dev);
-		}
 		pci_disable_msix(np->pci_dev);
 		np->msi_flags &= ~NV_MSI_X_ENABLED;
 	} else {
@@ -3975,7 +3953,7 @@ static void nv_do_nic_poll(unsigned long data)
 			/* reinit nic view of the rx queue */
 			writel(np->rx_buf_sz, base + NvRegOffloadConfig);
 			setup_hw_rings(dev, NV_SETUP_RX_RING | NV_SETUP_TX_RING);
-			writel( ((np->rx_ring_size-1) << NVREG_RINGSZ_RXSHIFT) + ((np->tx_ring_size-1) << NVREG_RINGSZ_TXSHIFT),
+			writel(((np->rx_ring_size-1) << NVREG_RINGSZ_RXSHIFT) + ((np->tx_ring_size-1) << NVREG_RINGSZ_TXSHIFT),
 				base + NvRegRingSizes);
 			pci_push(base);
 			writel(NVREG_TXRXCTL_KICK|np->txrxctl_bits, get_hwbase(dev) + NvRegTxRxControl);
@@ -4105,7 +4083,7 @@ static int nv_get_settings(struct net_device *dev, struct ethtool_cmd *ecmd)
 	}
 
 	if (netif_carrier_ok(dev)) {
-		switch(np->linkspeed & (NVREG_LINKSPEED_MASK)) {
+		switch (np->linkspeed & (NVREG_LINKSPEED_MASK)) {
 		case NVREG_LINKSPEED_10:
 			ecmd->speed = SPEED_10;
 			break;
@@ -4344,7 +4322,7 @@ static void nv_get_regs(struct net_device *dev, struct ethtool_regs *regs, void
 
 	regs->version = FORCEDETH_REGS_VER;
 	spin_lock_irq(&np->lock);
-	for (i = 0;i <= np->register_size/sizeof(u32); i++)
+	for (i = 0; i <= np->register_size/sizeof(u32); i++)
 		rbuf[i] = readl(base + i*sizeof(u32));
 	spin_unlock_irq(&np->lock);
 }
@@ -4491,14 +4469,14 @@ static int nv_set_ringparam(struct net_device *dev, struct ethtool_ringparam* ri
 	np->tx_ring_size = ring->tx_pending;
 
 	if (!nv_optimized(np)) {
-		np->rx_ring.orig = (struct ring_desc*)rxtx_ring;
+		np->rx_ring.orig = (struct ring_desc *)rxtx_ring;
 		np->tx_ring.orig = &np->rx_ring.orig[np->rx_ring_size];
 	} else {
-		np->rx_ring.ex = (struct ring_desc_ex*)rxtx_ring;
+		np->rx_ring.ex = (struct ring_desc_ex *)rxtx_ring;
 		np->tx_ring.ex = &np->rx_ring.ex[np->rx_ring_size];
 	}
-	np->rx_skb = (struct nv_skb_map*)rx_skbuff;
-	np->tx_skb = (struct nv_skb_map*)tx_skbuff;
+	np->rx_skb = (struct nv_skb_map *)rx_skbuff;
+	np->tx_skb = (struct nv_skb_map *)tx_skbuff;
 	np->ring_addr = ring_addr;
 
 	memset(np->rx_skb, 0, sizeof(struct nv_skb_map) * np->rx_ring_size);
@@ -4515,7 +4493,7 @@ static int nv_set_ringparam(struct net_device *dev, struct ethtool_ringparam* ri
 		/* reinit nic view of the queues */
 		writel(np->rx_buf_sz, base + NvRegOffloadConfig);
 		setup_hw_rings(dev, NV_SETUP_RX_RING | NV_SETUP_TX_RING);
-		writel( ((np->rx_ring_size-1) << NVREG_RINGSZ_RXSHIFT) + ((np->tx_ring_size-1) << NVREG_RINGSZ_TXSHIFT),
+		writel(((np->rx_ring_size-1) << NVREG_RINGSZ_RXSHIFT) + ((np->tx_ring_size-1) << NVREG_RINGSZ_TXSHIFT),
 			base + NvRegRingSizes);
 		pci_push(base);
 		writel(NVREG_TXRXCTL_KICK|np->txrxctl_bits, get_hwbase(dev) + NvRegTxRxControl);
@@ -4841,7 +4819,7 @@ static int nv_loopback_test(struct net_device *dev)
 	/* reinit nic view of the rx queue */
 	writel(np->rx_buf_sz, base + NvRegOffloadConfig);
 	setup_hw_rings(dev, NV_SETUP_RX_RING | NV_SETUP_TX_RING);
-	writel( ((np->rx_ring_size-1) << NVREG_RINGSZ_RXSHIFT) + ((np->tx_ring_size-1) << NVREG_RINGSZ_TXSHIFT),
+	writel(((np->rx_ring_size-1) << NVREG_RINGSZ_RXSHIFT) + ((np->tx_ring_size-1) << NVREG_RINGSZ_TXSHIFT),
 		base + NvRegRingSizes);
 	pci_push(base);
 
@@ -4893,9 +4871,8 @@ static int nv_loopback_test(struct net_device *dev)
 		if (flags & NV_RX_ERROR)
 			ret = 0;
 	} else {
-		if (flags & NV_RX2_ERROR) {
+		if (flags & NV_RX2_ERROR)
 			ret = 0;
-		}
 	}
 
 	if (ret) {
@@ -4958,11 +4935,10 @@ static void nv_self_test(struct net_device *dev, struct ethtool_test *test, u64
 			netif_addr_lock(dev);
 			spin_lock_irq(&np->lock);
 			nv_disable_hw_interrupts(dev, np->irqmask);
-			if (!(np->msi_flags & NV_MSI_X_ENABLED)) {
+			if (!(np->msi_flags & NV_MSI_X_ENABLED))
 				writel(NVREG_IRQSTAT_MASK, base + NvRegIrqStatus);
-			} else {
+			else
 				writel(NVREG_IRQSTAT_MASK, base + NvRegMSIXIrqStatus);
-			}
 			/* stop engines */
 			nv_stop_rxtx(dev);
 			nv_txrx_reset(dev);
@@ -5003,7 +4979,7 @@ static void nv_self_test(struct net_device *dev, struct ethtool_test *test, u64
 			/* reinit nic view of the rx queue */
 			writel(np->rx_buf_sz, base + NvRegOffloadConfig);
 			setup_hw_rings(dev, NV_SETUP_RX_RING | NV_SETUP_TX_RING);
-			writel( ((np->rx_ring_size-1) << NVREG_RINGSZ_RXSHIFT) + ((np->tx_ring_size-1) << NVREG_RINGSZ_TXSHIFT),
+			writel(((np->rx_ring_size-1) << NVREG_RINGSZ_RXSHIFT) + ((np->tx_ring_size-1) << NVREG_RINGSZ_TXSHIFT),
 				base + NvRegRingSizes);
 			pci_push(base);
 			writel(NVREG_TXRXCTL_KICK|np->txrxctl_bits, get_hwbase(dev) + NvRegTxRxControl);
@@ -5106,8 +5082,7 @@ static int nv_mgmt_acquire_sema(struct net_device *dev)
 		    ((tx_ctrl & NVREG_XMITCTL_MGMT_SEMA_MASK) == NVREG_XMITCTL_MGMT_SEMA_FREE)) {
 			np->mgmt_sema = 1;
 			return 1;
-		}
-		else
+		} else
 			udelay(50);
 	}
 
@@ -5204,7 +5179,7 @@ static int nv_open(struct net_device *dev)
 
 	/* give hw rings */
 	setup_hw_rings(dev, NV_SETUP_RX_RING | NV_SETUP_TX_RING);
-	writel( ((np->rx_ring_size-1) << NVREG_RINGSZ_RXSHIFT) + ((np->tx_ring_size-1) << NVREG_RINGSZ_TXSHIFT),
+	writel(((np->rx_ring_size-1) << NVREG_RINGSZ_RXSHIFT) + ((np->tx_ring_size-1) << NVREG_RINGSZ_TXSHIFT),
 		base + NvRegRingSizes);
 
 	writel(np->linkspeed, base + NvRegLinkSpeed);
@@ -5251,8 +5226,7 @@ static int nv_open(struct net_device *dev)
 			writel(NVREG_POLL_DEFAULT_THROUGHPUT, base + NvRegPollingInterval);
 		else
 			writel(NVREG_POLL_DEFAULT_CPU, base + NvRegPollingInterval);
-	}
-	else
+	} else
 		writel(poll_interval & 0xFFFF, base + NvRegPollingInterval);
 	writel(NVREG_UNKSETUP6_VAL, base + NvRegUnknownSetupReg6);
 	writel((np->phyaddr << NVREG_ADAPTCTL_PHYSHIFT)|NVREG_ADAPTCTL_PHYVALID|NVREG_ADAPTCTL_RUNNING,
@@ -5263,7 +5237,7 @@ static int nv_open(struct net_device *dev)
 		writel(NVREG_WAKEUPFLAGS_ENABLE , base + NvRegWakeUpFlags);
 
 	i = readl(base + NvRegPowerState);
-	if ( (i & NVREG_POWERSTATE_POWEREDUP) == 0)
+	if ((i & NVREG_POWERSTATE_POWEREDUP) == 0)
 		writel(NVREG_POWERSTATE_POWEREDUP|i, base + NvRegPowerState);
 
 	pci_push(base);
@@ -5276,9 +5250,8 @@ static int nv_open(struct net_device *dev)
 	writel(NVREG_IRQSTAT_MASK, base + NvRegIrqStatus);
 	pci_push(base);
 
-	if (nv_request_irq(dev, 0)) {
+	if (nv_request_irq(dev, 0))
 		goto out_drain;
-	}
 
 	/* ask for interrupts */
 	nv_enable_hw_interrupts(dev, np->irqmask);
@@ -5466,7 +5439,7 @@ static int __devinit nv_probe(struct pci_dev *pci_dev, const struct pci_device_i
 	addr = 0;
 	for (i = 0; i < DEVICE_COUNT_RESOURCE; i++) {
 		dprintk(KERN_DEBUG "%s: resource %d start %p len %ld flags 0x%08lx.\n",
-				pci_name(pci_dev), i, (void*)pci_resource_start(pci_dev, i),
+				pci_name(pci_dev), i, (void *)pci_resource_start(pci_dev, i),
 				pci_resource_len(pci_dev, i),
 				pci_resource_flags(pci_dev, i));
 		if (pci_resource_flags(pci_dev, i) & IORESOURCE_MEM &&
@@ -5631,7 +5604,7 @@ static int __devinit nv_probe(struct pci_dev *pci_dev, const struct pci_device_i
 		 */
 		dev_printk(KERN_ERR, &pci_dev->dev,
 			"Invalid Mac address detected: %pM\n",
-		        dev->dev_addr);
+			dev->dev_addr);
 		dev_printk(KERN_ERR, &pci_dev->dev,
 			"Please complain to your hardware vendor. Switching to a random MAC.\n");
 		random_ether_addr(dev->dev_addr);
@@ -5663,16 +5636,15 @@ static int __devinit nv_probe(struct pci_dev *pci_dev, const struct pci_device_i
 		writel(powerstate, base + NvRegPowerState2);
 	}
 
-	if (np->desc_ver == DESC_VER_1) {
+	if (np->desc_ver == DESC_VER_1)
 		np->tx_flags = NV_TX_VALID;
-	} else {
+	else
 		np->tx_flags = NV_TX2_VALID;
-	}
 
 	np->msi_flags = 0;
-	if ((id->driver_data & DEV_HAS_MSI) && msi) {
+	if ((id->driver_data & DEV_HAS_MSI) && msi)
 		np->msi_flags |= NV_MSI_CAPABLE;
-	}
+
 	if ((id->driver_data & DEV_HAS_MSI_X) && msix) {
 		/* msix has had reported issues when modifying irqmask
 		   as in the case of napi, therefore, disable for now
@@ -5735,9 +5707,8 @@ static int __devinit nv_probe(struct pci_dev *pci_dev, const struct pci_device_i
 		    nv_mgmt_acquire_sema(dev) &&
 		    nv_mgmt_get_version(dev)) {
 			np->mac_in_use = 1;
-			if (np->mgmt_version > 0) {
+			if (np->mgmt_version > 0)
 				np->mac_in_use = readl(base + NvRegMgmtUnitControl) & NVREG_MGMTUNITCONTROL_INUSE;
-			}
 			dprintk(KERN_INFO "%s: mgmt unit is running. mac in use %x.\n",
 				pci_name(pci_dev), np->mac_in_use);
 			/* management unit setup the phy already? */
@@ -5799,9 +5770,8 @@ static int __devinit nv_probe(struct pci_dev *pci_dev, const struct pci_device_i
 	} else {
 		/* see if it is a gigabit phy */
 		u32 mii_status = mii_rw(dev, np->phyaddr, MII_BMSR, MII_READ);
-		if (mii_status & PHY_GIGABIT) {
+		if (mii_status & PHY_GIGABIT)
 			np->gigabit = PHY_GIGABIT;
-		}
 	}
 
 	/* set default link speed settings */
@@ -5829,19 +5799,19 @@ static int __devinit nv_probe(struct pci_dev *pci_dev, const struct pci_device_i
 		   dev->dev_addr[5]);
 
 	dev_printk(KERN_INFO, &pci_dev->dev, "%s%s%s%s%s%s%s%s%s%sdesc-v%u\n",
-		   dev->features & NETIF_F_HIGHDMA ? "highdma " : "",
-		   dev->features & (NETIF_F_IP_CSUM | NETIF_F_SG) ?
-		   	"csum " : "",
-		   dev->features & (NETIF_F_HW_VLAN_RX | NETIF_F_HW_VLAN_TX) ?
-		   	"vlan " : "",
-		   id->driver_data & DEV_HAS_POWER_CNTRL ? "pwrctl " : "",
-		   id->driver_data & DEV_HAS_MGMT_UNIT ? "mgmt " : "",
-		   id->driver_data & DEV_NEED_TIMERIRQ ? "timirq " : "",
-		   np->gigabit == PHY_GIGABIT ? "gbit " : "",
-		   np->need_linktimer ? "lnktim " : "",
-		   np->msi_flags & NV_MSI_CAPABLE ? "msi " : "",
-		   np->msi_flags & NV_MSI_X_CAPABLE ? "msi-x " : "",
-		   np->desc_ver);
+		dev->features & NETIF_F_HIGHDMA ? "highdma " : "",
+		dev->features & (NETIF_F_IP_CSUM | NETIF_F_SG) ?
+			"csum " : "",
+		dev->features & (NETIF_F_HW_VLAN_RX | NETIF_F_HW_VLAN_TX) ?
+			"vlan " : "",
+		id->driver_data & DEV_HAS_POWER_CNTRL ? "pwrctl " : "",
+		id->driver_data & DEV_HAS_MGMT_UNIT ? "mgmt " : "",
+		id->driver_data & DEV_NEED_TIMERIRQ ? "timirq " : "",
+		np->gigabit == PHY_GIGABIT ? "gbit " : "",
+		np->need_linktimer ? "lnktim " : "",
+		np->msi_flags & NV_MSI_CAPABLE ? "msi " : "",
+		np->msi_flags & NV_MSI_X_CAPABLE ? "msi-x " : "",
+		np->desc_ver);
 
 	return 0;
 
@@ -5931,13 +5901,13 @@ static int nv_suspend(struct pci_dev *pdev, pm_message_t state)
 	int i;
 
 	if (netif_running(dev)) {
-		// Gross.
+		/* Gross. */
 		nv_close(dev);
 	}
 	netif_device_detach(dev);
 
 	/* save non-pci configuration space */
-	for (i = 0;i <= np->register_size/sizeof(u32); i++)
+	for (i = 0; i <= np->register_size/sizeof(u32); i++)
 		np->saved_config_space[i] = readl(base + i*sizeof(u32));
 
 	pci_save_state(pdev);
@@ -5960,7 +5930,7 @@ static int nv_resume(struct pci_dev *pdev)
 	pci_enable_wake(pdev, PCI_D0, 0);
 
 	/* restore non-pci configuration space */
-	for (i = 0;i <= np->register_size/sizeof(u32); i++)
+	for (i = 0; i <= np->register_size/sizeof(u32); i++)
 		writel(np->saved_config_space[i], base+i*sizeof(u32));
 
 	if (np->driver_data & DEV_NEED_MSI_FIX)
@@ -5990,9 +5960,8 @@ static void nv_shutdown(struct pci_dev *pdev)
 	 * If we really go for poweroff, we must not restore the MAC,
 	 * otherwise the MAC for WOL will be reversed at least on some boards.
 	 */
-	if (system_state != SYSTEM_POWER_OFF) {
+	if (system_state != SYSTEM_POWER_OFF)
 		nv_restore_mac_addr(pdev);
-	}
 
 	pci_disable_device(pdev);
 	/*
-- 
1.7.2.3


