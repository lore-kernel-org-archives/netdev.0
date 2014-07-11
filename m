From: varkabhadram@gmail.com
Subject: [PATCH net-next 7/8] ethernet: amd: fix spaces and few coding styles
Date: Fri, 11 Jul 2014 13:05:09 +0530
Message-ID: <1405064110-22579-8-git-send-email-varkabhadram@gmail.com>
References: <1405064110-22579-1-git-send-email-varkabhadram@gmail.com>
Cc: Thomas.Lendacky@amd.com, geert+renesas@linux-m68k.org,
	ebiederm@xmission.com, macro@linux-mips.org,
	linux-kernel@vger.kernel.org, davem@davemloft.net,
	Varka Bhadram <varkab@cdac.in>
To: netdev@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1405064110-22579-1-git-send-email-varkabhadram@gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Varka Bhadram <varkab@cdac.in>

This patch fix the following spacing issues:
	no space before tabs
	space required after that ';'
	space required before the open parenthesis '(
	space prohibited before that ':' (ctx:WxE)
	space prohibited before that close parenthesis ')'
	no spaces at the start of a line

Signed-off-by: Varka Bhadram <varkab@cdac.in>
---
 drivers/net/ethernet/amd/amd8111e.c |  577 +++++++++++++++++------------------
 1 file changed, 286 insertions(+), 291 deletions(-)

diff --git a/drivers/net/ethernet/amd/amd8111e.c b/drivers/net/ethernet/amd/amd8111e.c
index 8231be7..f0d3809 100644
--- a/drivers/net/ethernet/amd/amd8111e.c
+++ b/drivers/net/ethernet/amd/amd8111e.c
@@ -32,14 +32,14 @@ Module Name:
 
 Abstract:
 
- 	 AMD8111 based 10/100 Ethernet Controller Driver.
+	AMD8111 based 10/100 ethernet controller driver.
 
 Environment:
 
 	Kernel Mode
 
 Revision History:
- 	3.0.0
+	3.0.0
 	   Initial Revision.
 	3.0.1
 	 1. Dynamic interrupt coalescing.
@@ -99,7 +99,8 @@ Revision History:
 #define MODULE_NAME	"amd8111e"
 #define MODULE_VERS	"3.0.7"
 MODULE_AUTHOR("Advanced Micro Devices, Inc.");
-MODULE_DESCRIPTION ("AMD8111 based 10/100 Ethernet Controller. Driver Version "MODULE_VERS);
+MODULE_DESCRIPTION("AMD8111 based 10/100 Ethernet Controller. Driver Version "
+		   MODULE_VERS);
 MODULE_LICENSE("GPL");
 module_param_array(speed_duplex, int, NULL, 0);
 MODULE_PARM_DESC(speed_duplex, "Set device speed and duplex modes, 0: Auto Negotiate, 1: 10Mbps Half Duplex, 2: 10Mbps Full Duplex, 3: 100Mbps Half Duplex, 4: 100Mbps Full Duplex");
@@ -113,19 +114,20 @@ static int amd8111e_read_phy(struct amd8111e_priv *lp, int phy_id, int reg, u32
 {
 	void __iomem *mmio = lp->mmio;
 	unsigned int reg_val;
-	unsigned int repeat= REPEAT_CNT;
+	unsigned int repeat = REPEAT_CNT;
 
 	reg_val = readl(mmio + PHY_ACCESS);
 	while (reg_val & PHY_CMD_ACTIVE)
-		reg_val = readl( mmio + PHY_ACCESS );
+		reg_val = readl(mmio + PHY_ACCESS);
 
-	writel( PHY_RD_CMD | ((phy_id & 0x1f) << 21) |
+	writel(PHY_RD_CMD | ((phy_id & 0x1f) << 21) |
 			   ((reg & 0x1f) << 16),  mmio +PHY_ACCESS);
-	do{
+	do {
 		reg_val = readl(mmio + PHY_ACCESS);
 		udelay(30);  /* It takes 30 us to read/write data */
 	} while (--repeat && (reg_val & PHY_CMD_ACTIVE));
-	if(reg_val & PHY_RD_ERR)
+
+	if (reg_val & PHY_RD_ERR)
 		goto err_phy_read;
 
 	*val = reg_val & 0xffff;
@@ -133,11 +135,11 @@ static int amd8111e_read_phy(struct amd8111e_priv *lp, int phy_id, int reg, u32
 err_phy_read:
 	*val = 0;
 	return -EINVAL;
-
 }
 
 /* This function will write into PHY registers. */
-static int amd8111e_write_phy(struct amd8111e_priv *lp,int phy_id, int reg, u32 val)
+static int amd8111e_write_phy(struct amd8111e_priv *lp,
+			      int phy_id, int reg, u32 val)
 {
 	unsigned int repeat = REPEAT_CNT;
 	void __iomem *mmio = lp->mmio;
@@ -145,17 +147,17 @@ static int amd8111e_write_phy(struct amd8111e_priv *lp,int phy_id, int reg, u32
 
 	reg_val = readl(mmio + PHY_ACCESS);
 	while (reg_val & PHY_CMD_ACTIVE)
-		reg_val = readl( mmio + PHY_ACCESS );
+		reg_val = readl(mmio + PHY_ACCESS);
 
-	writel( PHY_WR_CMD | ((phy_id & 0x1f) << 21) |
+	writel(PHY_WR_CMD | ((phy_id & 0x1f) << 21) |
 			   ((reg & 0x1f) << 16)|val, mmio + PHY_ACCESS);
 
-	do{
+	do {
 		reg_val = readl(mmio + PHY_ACCESS);
 		udelay(30);  /* It takes 30 us to read/write the data */
 	} while (--repeat && (reg_val & PHY_CMD_ACTIVE));
 
-	if(reg_val & PHY_RD_ERR)
+	if (reg_val & PHY_RD_ERR)
 		goto err_phy_write;
 
 	return 0;
@@ -171,9 +173,8 @@ static int amd8111e_mdio_read(struct net_device *dev, int phy_id, int reg_num)
 	struct amd8111e_priv *lp = netdev_priv(dev);
 	unsigned int reg_val;
 
-	amd8111e_read_phy(lp,phy_id,reg_num,&reg_val);
+	amd8111e_read_phy(lp, phy_id, reg_num, &reg_val);
 	return reg_val;
-
 }
 
 /* This is the mii register write function provided to the mii interface. */
@@ -190,17 +191,16 @@ static void amd8111e_mdio_write(struct net_device *dev, int phy_id, int reg_num,
 static void amd8111e_set_ext_phy(struct net_device *dev)
 {
 	struct amd8111e_priv *lp = netdev_priv(dev);
-	u32 bmcr,advert,tmp;
+	u32 bmcr, advert, tmp;
 
 	/* Determine mii register values to set the speed */
 	advert = amd8111e_mdio_read(dev, lp->ext_phy_addr, MII_ADVERTISE);
 	tmp = advert & ~(ADVERTISE_ALL | ADVERTISE_100BASE4);
-	switch (lp->ext_phy_option){
-
+	switch (lp->ext_phy_option) {
 		default:
 		case SPEED_AUTONEG: /* advertise all values */
-			tmp |= ( ADVERTISE_10HALF|ADVERTISE_10FULL|
-				ADVERTISE_100HALF|ADVERTISE_100FULL) ;
+			tmp |= (ADVERTISE_10HALF | ADVERTISE_10FULL |
+				ADVERTISE_100HALF | ADVERTISE_100FULL);
 			break;
 		case SPEED10_HALF:
 			tmp |= ADVERTISE_10HALF;
@@ -216,13 +216,12 @@ static void amd8111e_set_ext_phy(struct net_device *dev)
 			break;
 	}
 
-	if(advert != tmp)
+	if (advert != tmp)
 		amd8111e_mdio_write(dev, lp->ext_phy_addr, MII_ADVERTISE, tmp);
 	/* Restart auto negotiation */
 	bmcr = amd8111e_mdio_read(dev, lp->ext_phy_addr, MII_BMCR);
 	bmcr |= (BMCR_ANENABLE | BMCR_ANRESTART);
 	amd8111e_mdio_write(dev, lp->ext_phy_addr, MII_BMCR, bmcr);
-
 }
 
 /* This function will unmap skb->data space and will free
@@ -235,20 +234,23 @@ static int amd8111e_free_skbs(struct net_device *dev)
 	int i;
 
 	/* Freeing transmit skbs */
-	for(i = 0; i < NUM_TX_BUFFERS; i++){
-		if(lp->tx_skbuff[i]){
-			pci_unmap_single(lp->pci_dev,lp->tx_dma_addr[i],					lp->tx_skbuff[i]->len,PCI_DMA_TODEVICE);
-			dev_kfree_skb (lp->tx_skbuff[i]);
+	for (i = 0; i < NUM_TX_BUFFERS; i++) {
+		if (lp->tx_skbuff[i]) {
+			pci_unmap_single(lp->pci_dev, lp->tx_dma_addr[i],
+					 lp->tx_skbuff[i]->len,
+					 PCI_DMA_TODEVICE);
+			dev_kfree_skb(lp->tx_skbuff[i]);
 			lp->tx_skbuff[i] = NULL;
 			lp->tx_dma_addr[i] = 0;
 		}
 	}
 	/* Freeing previously allocated receive buffers */
-	for (i = 0; i < NUM_RX_BUFFERS; i++){
+	for (i = 0; i < NUM_RX_BUFFERS; i++) {
 		rx_skbuff = lp->rx_skbuff[i];
-		if(rx_skbuff != NULL){
-			pci_unmap_single(lp->pci_dev,lp->rx_dma_addr[i],
-				  lp->rx_buff_len - 2,PCI_DMA_FROMDEVICE);
+		if (rx_skbuff != NULL) {
+			pci_unmap_single(lp->pci_dev, lp->rx_dma_addr[i],
+					 lp->rx_buff_len - 2,
+					 PCI_DMA_FROMDEVICE);
 			dev_kfree_skb(lp->rx_skbuff[i]);
 			lp->rx_skbuff[i] = NULL;
 			lp->rx_dma_addr[i] = 0;
@@ -266,13 +268,13 @@ static inline void amd8111e_set_rx_buff_len(struct net_device *dev)
 	struct amd8111e_priv *lp = netdev_priv(dev);
 	unsigned int mtu = dev->mtu;
 
-	if (mtu > ETH_DATA_LEN){
+	if (mtu > ETH_DATA_LEN) {
 		/* MTU + ethernet header + FCS
 		 * + optional VLAN tag + skb reserve space 2
 		 */
 		lp->rx_buff_len = mtu + ETH_HLEN + 10;
 		lp->options |= OPTION_JUMBO_ENABLE;
-	} else{
+	} else {
 		lp->rx_buff_len = PKT_BUFF_SZ;
 		lp->options &= ~OPTION_JUMBO_ENABLE;
 	}
@@ -293,22 +295,25 @@ static int amd8111e_init_ring(struct net_device *dev)
 	lp->tx_ring_idx = 0;
 
 
-	if(lp->opened)
+	if (lp->opened) {
 		/* Free previously allocated transmit and receive skbs */
 		amd8111e_free_skbs(dev);
-
-	else{
+	} else {
 		 /* allocate the tx and rx descriptors */
-	     	if((lp->tx_ring = pci_alloc_consistent(lp->pci_dev,
-			sizeof(struct amd8111e_tx_dr)*NUM_TX_RING_DR,
-			&lp->tx_ring_dma_addr)) == NULL)
+		lp->tx_ring = pci_alloc_consistent(lp->pci_dev,
+						   (sizeof(struct amd8111e_tx_dr) *
+							NUM_TX_RING_DR),
+						   &lp->tx_ring_dma_addr);
 
+		if (!lp->tx_ring)
 			goto err_no_mem;
 
-	     	if((lp->rx_ring = pci_alloc_consistent(lp->pci_dev,
-			sizeof(struct amd8111e_rx_dr)*NUM_RX_RING_DR,
-			&lp->rx_ring_dma_addr)) == NULL)
+		lp->rx_ring = pci_alloc_consistent(lp->pci_dev,
+						   (sizeof(struct amd8111e_rx_dr) *
+							NUM_RX_RING_DR),
+						    &lp->rx_ring_dma_addr);
 
+		if (!lp->rx_ring)
 			goto err_free_tx_ring;
 
 	}
@@ -317,20 +322,21 @@ static int amd8111e_init_ring(struct net_device *dev)
 
 	/* Allocating receive  skbs */
 	for (i = 0; i < NUM_RX_BUFFERS; i++) {
-
 		lp->rx_skbuff[i] = netdev_alloc_skb(dev, lp->rx_buff_len);
 		if (!lp->rx_skbuff[i]) {
 				/* Release previos allocated skbs */
-				for(--i; i >= 0 ;i--)
+				for (--i; i >= 0; i--)
 					dev_kfree_skb(lp->rx_skbuff[i]);
 				goto err_free_rx_ring;
 		}
-		skb_reserve(lp->rx_skbuff[i],2);
+		skb_reserve(lp->rx_skbuff[i], 2);
 	}
         /* Initilaizing receive descriptors */
 	for (i = 0; i < NUM_RX_BUFFERS; i++) {
 		lp->rx_dma_addr[i] = pci_map_single(lp->pci_dev,
-			lp->rx_skbuff[i]->data,lp->rx_buff_len-2, PCI_DMA_FROMDEVICE);
+						    lp->rx_skbuff[i]->data,
+						    lp->rx_buff_len-2,
+						    PCI_DMA_FROMDEVICE);
 
 		lp->rx_ring[i].buff_phy_addr = cpu_to_le32(lp->rx_dma_addr[i]);
 		lp->rx_ring[i].buff_count = cpu_to_le16(lp->rx_buff_len-2);
@@ -350,14 +356,16 @@ static int amd8111e_init_ring(struct net_device *dev)
 err_free_rx_ring:
 
 	pci_free_consistent(lp->pci_dev,
-		sizeof(struct amd8111e_rx_dr)*NUM_RX_RING_DR,lp->rx_ring,
-		lp->rx_ring_dma_addr);
+			    sizeof(struct amd8111e_rx_dr)*NUM_RX_RING_DR,
+			    lp->rx_ring,
+			    lp->rx_ring_dma_addr);
 
 err_free_tx_ring:
 
 	pci_free_consistent(lp->pci_dev,
-		 sizeof(struct amd8111e_tx_dr)*NUM_TX_RING_DR,lp->tx_ring,
-		 lp->tx_ring_dma_addr);
+			    sizeof(struct amd8111e_tx_dr)*NUM_TX_RING_DR,
+			    lp->tx_ring,
+			    lp->tx_ring_dma_addr);
 
 err_no_mem:
 	return -ENOMEM;
@@ -376,52 +384,51 @@ static int amd8111e_set_coalesce(struct net_device *dev, enum coal_mode cmod)
 	struct amd8111e_coalesce_conf *coal_conf = &lp->coal_conf;
 
 
-	switch(cmod)
+	switch (cmod)
 	{
-		case RX_INTR_COAL :
+		case RX_INTR_COAL:
 			timeout = coal_conf->rx_timeout;
 			event_count = coal_conf->rx_event_count;
-			if( timeout > MAX_TIMEOUT ||
-					event_count > MAX_EVENT_COUNT )
+			if (timeout > MAX_TIMEOUT ||
+			    event_count > MAX_EVENT_COUNT)
 				return -EINVAL;
 
 			timeout = timeout * DELAY_TIMER_CONV;
-			writel(VAL0|STINTEN, mmio+INTEN0);
-			writel((u32)DLY_INT_A_R0|( event_count<< 16 )|timeout,
-							mmio+DLY_INT_A);
+			writel(VAL0 | STINTEN, mmio + INTEN0);
+			writel((u32)DLY_INT_A_R0 | (event_count << 16) |
+			       timeout, mmio+DLY_INT_A);
 			break;
 
-		case TX_INTR_COAL :
+		case TX_INTR_COAL:
 			timeout = coal_conf->tx_timeout;
 			event_count = coal_conf->tx_event_count;
-			if( timeout > MAX_TIMEOUT ||
-					event_count > MAX_EVENT_COUNT )
+			if (timeout > MAX_TIMEOUT ||
+			    event_count > MAX_EVENT_COUNT)
 				return -EINVAL;
 
 
 			timeout = timeout * DELAY_TIMER_CONV;
-			writel(VAL0|STINTEN,mmio+INTEN0);
-			writel((u32)DLY_INT_B_T0|( event_count<< 16 )|timeout,
-							 mmio+DLY_INT_B);
+			writel(VAL0 | STINTEN, mmio + INTEN0);
+			writel((u32)DLY_INT_B_T0 | (event_count << 16) |
+			       timeout, mmio + DLY_INT_B);
 			break;
 
 		case DISABLE_COAL:
-			writel(0,mmio+STVAL);
-			writel(STINTEN, mmio+INTEN0);
-			writel(0, mmio +DLY_INT_B);
-			writel(0, mmio+DLY_INT_A);
+			writel(0, mmio + STVAL);
+			writel(STINTEN, mmio + INTEN0);
+			writel(0, mmio + DLY_INT_B);
+			writel(0, mmio + DLY_INT_A);
 			break;
 		 case ENABLE_COAL:
-		       /* Start the timer */
-			writel((u32)SOFT_TIMER_FREQ, mmio+STVAL); /*  0.5 sec */
-			writel(VAL0|STINTEN, mmio+INTEN0);
+		       /* Start the timer (0.5 sec) */
+			writel((u32)SOFT_TIMER_FREQ, mmio + STVAL);
+			writel(VAL0 | STINTEN, mmio + INTEN0);
 			break;
 		default:
 			break;
+	}
 
-   }
 	return 0;
-
 }
 
 /* This function initializes the device registers  and starts the device. */
@@ -429,67 +436,67 @@ static int amd8111e_restart(struct net_device *dev)
 {
 	struct amd8111e_priv *lp = netdev_priv(dev);
 	void __iomem *mmio = lp->mmio;
-	int i,reg_val;
+	int i, reg_val;
 
 	/* stop the chip */
 	 writel(RUN, mmio + CMD0);
 
-	if(amd8111e_init_ring(dev))
+	if (amd8111e_init_ring(dev))
 		return -ENOMEM;
 
 	/* enable the port manager and set auto negotiation always */
-	writel((u32) VAL1|EN_PMGR, mmio + CMD3 );
-	writel((u32)XPHYANE|XPHYRST , mmio + CTRL2);
+	writel((u32) VAL1 | EN_PMGR, mmio + CMD3);
+	writel((u32)XPHYANE | XPHYRST , mmio + CTRL2);
 
 	amd8111e_set_ext_phy(dev);
 
 	/* set control registers */
 	reg_val = readl(mmio + CTRL1);
 	reg_val &= ~XMTSP_MASK;
-	writel( reg_val| XMTSP_128 | CACHE_ALIGN, mmio + CTRL1 );
+	writel(reg_val | XMTSP_128 | CACHE_ALIGN, mmio + CTRL1);
 
 	/* enable interrupt */
-	writel( APINT5EN | APINT4EN | APINT3EN | APINT2EN | APINT1EN |
+	writel(APINT5EN | APINT4EN | APINT3EN | APINT2EN | APINT1EN |
 		APINT0EN | MIIPDTINTEN | MCCIINTEN | MCCINTEN | MREINTEN |
 		SPNDINTEN | MPINTEN | SINTEN | STINTEN, mmio + INTEN0);
 
 	writel(VAL3 | LCINTEN | VAL1 | TINTEN0 | VAL0 | RINTEN0, mmio + INTEN0);
 
 	/* initialize tx and rx ring base addresses */
-	writel((u32)lp->tx_ring_dma_addr,mmio + XMT_RING_BASE_ADDR0);
-	writel((u32)lp->rx_ring_dma_addr,mmio+ RCV_RING_BASE_ADDR0);
+	writel((u32)lp->tx_ring_dma_addr, mmio + XMT_RING_BASE_ADDR0);
+	writel((u32)lp->rx_ring_dma_addr, mmio + RCV_RING_BASE_ADDR0);
 
 	writew((u32)NUM_TX_RING_DR, mmio + XMT_RING_LEN0);
 	writew((u16)NUM_RX_RING_DR, mmio + RCV_RING_LEN0);
 
 	/* set default IPG to 96 */
-	writew((u32)DEFAULT_IPG,mmio+IPG);
+	writew((u32)DEFAULT_IPG, mmio + IPG);
 	writew((u32)(DEFAULT_IPG-IFS1_DELTA), mmio + IFS1);
 
-	if(lp->options & OPTION_JUMBO_ENABLE){
+	if (lp->options & OPTION_JUMBO_ENABLE) {
 		writel((u32)VAL2|JUMBO, mmio + CMD3);
 		/* Reset REX_UFLO */
-		writel( REX_UFLO, mmio + CMD2);
+		writel(REX_UFLO, mmio + CMD2);
 		/* Should not set REX_UFLO for jumbo frames */
-		writel( VAL0 | APAD_XMT|REX_RTRY , mmio + CMD2);
-	}else{
-		writel( VAL0 | APAD_XMT | REX_RTRY|REX_UFLO, mmio + CMD2);
+		writel(VAL0 | APAD_XMT | REX_RTRY , mmio + CMD2);
+	} else {
+		writel(VAL0 | APAD_XMT | REX_RTRY | REX_UFLO, mmio + CMD2);
 		writel((u32)JUMBO, mmio + CMD3);
 	}
 
 #if AMD8111E_VLAN_TAG_USED
-	writel((u32) VAL2|VSIZE|VL_TAG_DEL, mmio + CMD3);
+	writel((u32) VAL2 | VSIZE | VL_TAG_DEL, mmio + CMD3);
 #endif
-	writel( VAL0 | APAD_XMT | REX_RTRY, mmio + CMD2 );
+	writel(VAL0 | APAD_XMT | REX_RTRY, mmio + CMD2);
 
 	/* Setting the MAC address to the device */
 	for (i = 0; i < ETH_ALEN; i++)
-		writeb( dev->dev_addr[i], mmio + PADR + i );
+		writeb(dev->dev_addr[i], mmio + PADR + i);
 
 	/* Enable interrupt coalesce */
-	if(lp->options & OPTION_INTR_COAL_ENABLE){
+	if (lp->options & OPTION_INTR_COAL_ENABLE) {
 		netdev_info(dev, "Interrupt Coalescing Enabled");
-		amd8111e_set_coalesce(dev,ENABLE_COAL);
+		amd8111e_set_coalesce(dev, ENABLE_COAL);
 	}
 
 	/* set RUN bit to start the chip */
@@ -497,15 +504,16 @@ static int amd8111e_restart(struct net_device *dev)
 	writel(VAL0 | INTREN | RUN, mmio + CMD0);
 
 	/* To avoid PCI posting bug */
-	readl(mmio+CMD0);
+	readl(mmio + CMD0);
+
 	return 0;
 }
 
 /* This function clears necessary the device registers. */
-static void amd8111e_init_hw_default( struct amd8111e_priv *lp)
+static void amd8111e_init_hw_default(struct amd8111e_priv *lp)
 {
 	unsigned int reg_val;
-	unsigned int logic_filter[2] ={0,};
+	unsigned int logic_filter[2] = {0,};
 	void __iomem *mmio = lp->mmio;
 
 
@@ -513,7 +521,7 @@ static void amd8111e_init_hw_default( struct amd8111e_priv *lp)
 	writel(RUN, mmio + CMD0);
 
 	/* AUTOPOLL0 Register *//*TBD default value is 8100 in FPS */
-	writew( 0x8100 | lp->ext_phy_addr, mmio + AUTOPOLL0);
+	writew(0x8100 | lp->ext_phy_addr, mmio + AUTOPOLL0);
 
 	/* Clear RCV_RING_BASE_ADDR */
 	writel(0, mmio + RCV_RING_BASE_ADDR0);
@@ -525,13 +533,13 @@ static void amd8111e_init_hw_default( struct amd8111e_priv *lp)
 	writel(0, mmio + XMT_RING_BASE_ADDR3);
 
 	/* Clear CMD0  */
-	writel(CMD0_CLEAR,mmio + CMD0);
+	writel(CMD0_CLEAR, mmio + CMD0);
 
 	/* Clear CMD2 */
 	writel(CMD2_CLEAR, mmio +CMD2);
 
 	/* Clear CMD7 */
-	writel(CMD7_CLEAR , mmio + CMD7);
+	writel(CMD7_CLEAR, mmio + CMD7);
 
 	/* Clear DLY_INT_A and DLY_INT_B */
 	writel(0x0, mmio + DLY_INT_A);
@@ -548,22 +556,22 @@ static void amd8111e_init_hw_default( struct amd8111e_priv *lp)
 	writel(0x0, mmio + STVAL);
 
 	/* Clear INTEN0 */
-	writel( INTEN0_CLEAR, mmio + INTEN0);
+	writel(INTEN0_CLEAR, mmio + INTEN0);
 
 	/* Clear LADRF */
 	writel(0x0 , mmio + LADRF);
 
 	/* Set SRAM_SIZE & SRAM_BOUNDARY registers  */
-	writel( 0x80010,mmio + SRAM_SIZE);
+	writel(0x80010, mmio + SRAM_SIZE);
 
 	/* Clear RCV_RING0_LEN */
-	writel(0x0, mmio +  RCV_RING_LEN0);
+	writel(0x0, mmio + RCV_RING_LEN0);
 
 	/* Clear XMT_RING0/1/2/3_LEN */
-	writel(0x0, mmio +  XMT_RING_LEN0);
-	writel(0x0, mmio +  XMT_RING_LEN1);
-	writel(0x0, mmio +  XMT_RING_LEN2);
-	writel(0x0, mmio +  XMT_RING_LEN3);
+	writel(0x0, mmio + XMT_RING_LEN0);
+	writel(0x0, mmio + XMT_RING_LEN1);
+	writel(0x0, mmio + XMT_RING_LEN2);
+	writel(0x0, mmio + XMT_RING_LEN3);
 
 	/* Clear XMT_RING_LIMIT */
 	writel(0x0, mmio + XMT_RING_LIMIT);
@@ -572,22 +580,21 @@ static void amd8111e_init_hw_default( struct amd8111e_priv *lp)
 	writew(MIB_CLEAR, mmio + MIB_ADDR);
 
 	/* Clear LARF */
-	amd8111e_writeq(*(u64 *)logic_filter,mmio+LADRF);
+	amd8111e_writeq(*(u64 *)logic_filter, mmio + LADRF);
 
 	/* SRAM_SIZE register */
 	reg_val = readl(mmio + SRAM_SIZE);
 
-	if(lp->options & OPTION_JUMBO_ENABLE)
-		writel( VAL2|JUMBO, mmio + CMD3);
+	if (lp->options & OPTION_JUMBO_ENABLE)
+		writel(VAL2 | JUMBO, mmio + CMD3);
 #if AMD8111E_VLAN_TAG_USED
-	writel(VAL2|VSIZE|VL_TAG_DEL, mmio + CMD3 );
+	writel(VAL2 | VSIZE | VL_TAG_DEL, mmio + CMD3);
 #endif
 	/* Set default value to CTRL1 Register */
 	writel(CTRL1_DEFAULT, mmio + CTRL1);
 
 	/* To avoid PCI posting bug */
 	readl(mmio + CMD2);
-
 }
 
 /* This function disables the interrupt and clears all the pending
@@ -606,7 +613,6 @@ static void amd8111e_disable_interrupt(struct amd8111e_priv *lp)
 
 	/* To avoid PCI posting bug */
 	readl(lp->mmio + INT0);
-
 }
 
 /* This function stops the chip. */
@@ -622,21 +628,21 @@ static void amd8111e_stop_chip(struct amd8111e_priv *lp)
 static void amd8111e_free_ring(struct amd8111e_priv *lp)
 {
 	/* Free transmit and receive descriptor rings */
-	if(lp->rx_ring){
+	if (lp->rx_ring) {
 		pci_free_consistent(lp->pci_dev,
-			sizeof(struct amd8111e_rx_dr)*NUM_RX_RING_DR,
-			lp->rx_ring, lp->rx_ring_dma_addr);
+				    sizeof(struct amd8111e_rx_dr) *
+					NUM_RX_RING_DR,
+				    lp->rx_ring, lp->rx_ring_dma_addr);
 		lp->rx_ring = NULL;
 	}
 
-	if(lp->tx_ring){
+	if (lp->tx_ring) {
 		pci_free_consistent(lp->pci_dev,
-			sizeof(struct amd8111e_tx_dr)*NUM_TX_RING_DR,
-			lp->tx_ring, lp->tx_ring_dma_addr);
-
+				    sizeof(struct amd8111e_tx_dr) *
+					NUM_TX_RING_DR,
+				    lp->tx_ring, lp->tx_ring_dma_addr);
 		lp->tx_ring = NULL;
 	}
-
 }
 
 /* This function will free all the transmit skbs that are actually
@@ -648,12 +654,13 @@ static int amd8111e_tx(struct net_device *dev)
 	struct amd8111e_priv *lp = netdev_priv(dev);
 	int tx_index = lp->tx_complete_idx & TX_RING_DR_MOD_MASK;
 	int status;
+
 	/* Complete all the transmit packet */
-	while (lp->tx_complete_idx != lp->tx_idx){
+	while (lp->tx_complete_idx != lp->tx_idx) {
 		tx_index =  lp->tx_complete_idx & TX_RING_DR_MOD_MASK;
 		status = le16_to_cpu(lp->tx_ring[tx_index].tx_flags);
 
-		if(status & OWN_BIT)
+		if (status & OWN_BIT)
 			break;	/* It still hasn't been Txed */
 
 		lp->tx_ring[tx_index].buff_phy_addr = 0;
@@ -661,9 +668,9 @@ static int amd8111e_tx(struct net_device *dev)
 		/* We must free the original skb */
 		if (lp->tx_skbuff[tx_index]) {
 			pci_unmap_single(lp->pci_dev, lp->tx_dma_addr[tx_index],
-				  	lp->tx_skbuff[tx_index]->len,
-					PCI_DMA_TODEVICE);
-			dev_kfree_skb_irq (lp->tx_skbuff[tx_index]);
+					 lp->tx_skbuff[tx_index]->len,
+					 PCI_DMA_TODEVICE);
+			dev_kfree_skb_irq(lp->tx_skbuff[tx_index]);
 			lp->tx_skbuff[tx_index] = NULL;
 			lp->tx_dma_addr[tx_index] = 0;
 		}
@@ -674,10 +681,10 @@ static int amd8111e_tx(struct net_device *dev)
 			le16_to_cpu(lp->tx_ring[tx_index].buff_count);
 
 		if (netif_queue_stopped(dev) &&
-			lp->tx_complete_idx > lp->tx_idx - NUM_TX_BUFFERS +2){
+			lp->tx_complete_idx > lp->tx_idx - NUM_TX_BUFFERS + 2) {
 			/* The ring is no longer full, clear tbusy. */
 			/* lp->tx_full = 0; */
-			netif_wake_queue (dev);
+			netif_wake_queue(dev);
 		}
 	}
 	return 0;
@@ -690,7 +697,7 @@ static int amd8111e_rx_poll(struct napi_struct *napi, int budget)
 	struct net_device *dev = lp->amd8111e_net_dev;
 	int rx_index = lp->rx_idx & RX_RING_DR_MOD_MASK;
 	void __iomem *mmio = lp->mmio;
-	struct sk_buff *skb,*new_skb;
+	struct sk_buff *skb, *new_skb;
 	int min_pkt_len, status;
 	unsigned int intr0;
 	int num_rx_pkt = 0;
@@ -704,11 +711,11 @@ static int amd8111e_rx_poll(struct napi_struct *napi, int budget)
 	if (rx_pkt_limit <= 0)
 		goto rx_not_empty;
 
-	do{
+	do {
 		/* process receive packets until we use the quota.
 		 * If we own the next entry, it's a new packet. Send it up.
 		 */
-		while(1) {
+		while (1) {
 			status = le16_to_cpu(lp->rx_ring[rx_index].rx_flags);
 			if (status & OWN_BIT)
 				break;
@@ -719,13 +726,13 @@ static int amd8111e_rx_poll(struct napi_struct *napi, int budget)
 			 * jabber packet to use two buffers, with only
 			 * the last correctly noting the error.
 			 */
-			if(status & ERR_BIT) {
+			if (status & ERR_BIT) {
 				/* reseting flags */
 				lp->rx_ring[rx_index].rx_flags &= RESET_RX_FLAGS;
 				goto err_next_pkt;
 			}
 			/* check for STP and ENP */
-			if(!((status & STP_BIT) && (status & ENP_BIT))){
+			if (!((status & STP_BIT) && (status & ENP_BIT))) {
 				/* reseting flags */
 				lp->rx_ring[rx_index].rx_flags &= RESET_RX_FLAGS;
 				goto err_next_pkt;
@@ -736,17 +743,17 @@ static int amd8111e_rx_poll(struct napi_struct *napi, int budget)
 			vtag = status & TT_MASK;
 			/*MAC will strip vlan tag*/
 			if (vtag != 0)
-				min_pkt_len =MIN_PKT_LEN - 4;
+				min_pkt_len = MIN_PKT_LEN - 4;
 			else
 #endif
-				min_pkt_len =MIN_PKT_LEN;
+				min_pkt_len = MIN_PKT_LEN;
 
 			if (pkt_len < min_pkt_len) {
 				lp->rx_ring[rx_index].rx_flags &= RESET_RX_FLAGS;
 				lp->drv_rx_errors++;
 				goto err_next_pkt;
 			}
-			if(--rx_pkt_limit < 0)
+			if (--rx_pkt_limit < 0)
 				goto rx_not_empty;
 			new_skb = netdev_alloc_skb(dev, lp->rx_buff_len);
 			if (!new_skb) {
@@ -760,8 +767,10 @@ static int amd8111e_rx_poll(struct napi_struct *napi, int budget)
 
 			skb_reserve(new_skb, 2);
 			skb = lp->rx_skbuff[rx_index];
-			pci_unmap_single(lp->pci_dev,lp->rx_dma_addr[rx_index],
-					 lp->rx_buff_len-2, PCI_DMA_FROMDEVICE);
+			pci_unmap_single(lp->pci_dev,
+					 lp->rx_dma_addr[rx_index],
+					 lp->rx_buff_len-2,
+					 PCI_DMA_FROMDEVICE);
 			skb_put(skb, pkt_len);
 			lp->rx_skbuff[rx_index] = new_skb;
 			lp->rx_dma_addr[rx_index] = pci_map_single(lp->pci_dev,
@@ -772,7 +781,7 @@ static int amd8111e_rx_poll(struct napi_struct *napi, int budget)
 			skb->protocol = eth_type_trans(skb, dev);
 
 #if AMD8111E_VLAN_TAG_USED
-			if (vtag == TT_VLAN_TAGGED){
+			if (vtag == TT_VLAN_TAGGED) {
 				u16 vlan_tag = le16_to_cpu(lp->rx_ring[rx_index].tag_ctrl_info);
 				__vlan_hwaccel_put_tag(skb, htons(ETH_P_8021Q), vlan_tag);
 			}
@@ -797,9 +806,9 @@ static int amd8111e_rx_poll(struct napi_struct *napi, int budget)
 		 */
 		intr0 = readl(mmio + INT0);
 		/*Ack receive packets */
-		writel(intr0 & RINT0,mmio + INT0);
+		writel(intr0 & RINT0, mmio + INT0);
 
-	} while(intr0 & RINT0);
+	} while (intr0 & RINT0);
 
 	if (rx_pkt_limit > 0) {
 		/* Receive descriptor is empty now */
@@ -818,25 +827,25 @@ rx_not_empty:
 static int amd8111e_link_change(struct net_device *dev)
 {
 	struct amd8111e_priv *lp = netdev_priv(dev);
-	int status0,speed;
+	int status0, speed;
 
 	/* read the link change */
-     	status0 = readl(lp->mmio + STAT0);
+	status0 = readl(lp->mmio + STAT0);
 
-	if(status0 & LINK_STATS){
-		if(status0 & AUTONEG_COMPLETE)
+	if (status0 & LINK_STATS) {
+		if (status0 & AUTONEG_COMPLETE)
 			lp->link_config.autoneg = AUTONEG_ENABLE;
 		else
 			lp->link_config.autoneg = AUTONEG_DISABLE;
 
-		if(status0 & FULL_DPLX)
+		if (status0 & FULL_DPLX)
 			lp->link_config.duplex = DUPLEX_FULL;
 		else
 			lp->link_config.duplex = DUPLEX_HALF;
 		speed = (status0 & SPEED_MASK) >> 7;
-		if(speed == PHY_SPEED_10)
+		if (speed == PHY_SPEED_10)
 			lp->link_config.speed = SPEED_10;
-		else if(speed == PHY_SPEED_100)
+		else if (speed == PHY_SPEED_100)
 			lp->link_config.speed = SPEED_100;
 
 		netdev_info(dev, "Link is Up. Speed is %s Mbps %s Duplex\n",
@@ -846,8 +855,7 @@ static int amd8111e_link_change(struct net_device *dev)
 							"Full" : "Half");
 
 		netif_carrier_on(dev);
-	}
-	else{
+	} else {
 		lp->link_config.speed = SPEED_INVALID;
 		lp->link_config.duplex = DUPLEX_INVALID;
 		lp->link_config.autoneg = AUTONEG_INVALID;
@@ -865,7 +873,7 @@ static int amd8111e_read_mib(void __iomem *mmio, u8 MIB_COUNTER)
 	unsigned  int data;
 	unsigned int repeat = REPEAT_CNT;
 
-	writew( MIB_RD_CMD | MIB_COUNTER, mmio + MIB_ADDR);
+	writew(MIB_RD_CMD | MIB_COUNTER, mmio + MIB_ADDR);
 	do {
 		status = readw(mmio + MIB_ADDR);
 		udelay(2);	/* controller takes MAX 2 us to get mib data */
@@ -888,11 +896,12 @@ static struct net_device_stats *amd8111e_get_stats(struct net_device *dev)
 
 	if (!lp->opened)
 		return new_stats;
-	spin_lock_irqsave (&lp->lock, flags);
+
+	spin_lock_irqsave(&lp->lock, flags);
 
 	/* stats.rx_packets */
-	new_stats->rx_packets = amd8111e_read_mib(mmio, rcv_broadcast_pkts)+
-				amd8111e_read_mib(mmio, rcv_multicast_pkts)+
+	new_stats->rx_packets = amd8111e_read_mib(mmio, rcv_broadcast_pkts) +
+				amd8111e_read_mib(mmio, rcv_multicast_pkts) +
 				amd8111e_read_mib(mmio, rcv_unicast_pkts);
 
 	/* stats.tx_packets */
@@ -906,12 +915,12 @@ static struct net_device_stats *amd8111e_get_stats(struct net_device *dev)
 
 	/* stats.rx_errors */
 	/* hw errors + errors driver reported */
-	new_stats->rx_errors = amd8111e_read_mib(mmio, rcv_undersize_pkts)+
-				amd8111e_read_mib(mmio, rcv_fragments)+
-				amd8111e_read_mib(mmio, rcv_jabbers)+
-				amd8111e_read_mib(mmio, rcv_alignment_errors)+
-				amd8111e_read_mib(mmio, rcv_fcs_errors)+
-				amd8111e_read_mib(mmio, rcv_miss_pkts)+
+	new_stats->rx_errors = amd8111e_read_mib(mmio, rcv_undersize_pkts) +
+				amd8111e_read_mib(mmio, rcv_fragments) +
+				amd8111e_read_mib(mmio, rcv_jabbers) +
+				amd8111e_read_mib(mmio, rcv_alignment_errors) +
+				amd8111e_read_mib(mmio, rcv_fcs_errors) +
+				amd8111e_read_mib(mmio, rcv_miss_pkts) +
 				lp->drv_rx_errors;
 
 	/* stats.tx_errors */
@@ -921,7 +930,7 @@ static struct net_device_stats *amd8111e_get_stats(struct net_device *dev)
 	new_stats->rx_dropped = amd8111e_read_mib(mmio, rcv_miss_pkts);
 
 	/* stats.tx_dropped*/
-	new_stats->tx_dropped = amd8111e_read_mib(mmio,  xmt_underrun_pkts);
+	new_stats->tx_dropped = amd8111e_read_mib(mmio, xmt_underrun_pkts);
 
 	/* stats.multicast*/
 	new_stats->multicast = amd8111e_read_mib(mmio, rcv_multicast_pkts);
@@ -968,7 +977,7 @@ static struct net_device_stats *amd8111e_get_stats(struct net_device *dev)
 	/* Reset the mibs for collecting new statistics */
 	/* writew(MIB_CLEAR, mmio + MIB_ADDR);*/
 
-	spin_unlock_irqrestore (&lp->lock, flags);
+	spin_unlock_irqrestore(&lp->lock, flags);
 
 	return new_stats;
 }
@@ -999,113 +1008,90 @@ static int amd8111e_calc_coalesce(struct net_device *dev)
 	rx_data_rate = coal_conf->rx_bytes - coal_conf->rx_prev_bytes;
 	coal_conf->rx_prev_bytes =  coal_conf->rx_bytes;
 
-	if(rx_pkt_rate < 800){
-		if(coal_conf->rx_coal_type != NO_COALESCE){
-
+	if (rx_pkt_rate < 800) {
+		if (coal_conf->rx_coal_type != NO_COALESCE) {
 			coal_conf->rx_timeout = 0x0;
 			coal_conf->rx_event_count = 0;
-			amd8111e_set_coalesce(dev,RX_INTR_COAL);
+			amd8111e_set_coalesce(dev, RX_INTR_COAL);
 			coal_conf->rx_coal_type = NO_COALESCE;
 		}
-	}
-	else{
-
+	} else {
 		rx_pkt_size = rx_data_rate/rx_pkt_rate;
-		if (rx_pkt_size < 128){
-			if(coal_conf->rx_coal_type != NO_COALESCE){
-
+		if (rx_pkt_size < 128) {
+			if (coal_conf->rx_coal_type != NO_COALESCE) {
 				coal_conf->rx_timeout = 0;
 				coal_conf->rx_event_count = 0;
-				amd8111e_set_coalesce(dev,RX_INTR_COAL);
+				amd8111e_set_coalesce(dev, RX_INTR_COAL);
 				coal_conf->rx_coal_type = NO_COALESCE;
 			}
 
-		}
-		else if ( (rx_pkt_size >= 128) && (rx_pkt_size < 512) ){
-
-			if(coal_conf->rx_coal_type !=  LOW_COALESCE){
+		} else if ((rx_pkt_size >= 128) && (rx_pkt_size < 512)) {
+			if (coal_conf->rx_coal_type !=  LOW_COALESCE) {
 				coal_conf->rx_timeout = 1;
 				coal_conf->rx_event_count = 4;
-				amd8111e_set_coalesce(dev,RX_INTR_COAL);
+				amd8111e_set_coalesce(dev, RX_INTR_COAL);
 				coal_conf->rx_coal_type = LOW_COALESCE;
 			}
-		}
-		else if ((rx_pkt_size >= 512) && (rx_pkt_size < 1024)){
-
-			if(coal_conf->rx_coal_type !=  MEDIUM_COALESCE){
+		} else if ((rx_pkt_size >= 512) && (rx_pkt_size < 1024)) {
+			if (coal_conf->rx_coal_type !=  MEDIUM_COALESCE) {
 				coal_conf->rx_timeout = 1;
 				coal_conf->rx_event_count = 4;
-				amd8111e_set_coalesce(dev,RX_INTR_COAL);
+				amd8111e_set_coalesce(dev, RX_INTR_COAL);
 				coal_conf->rx_coal_type = MEDIUM_COALESCE;
 			}
-
-		}
-		else if(rx_pkt_size >= 1024){
-			if(coal_conf->rx_coal_type !=  HIGH_COALESCE){
+		} else if (rx_pkt_size >= 1024) {
+			if (coal_conf->rx_coal_type !=  HIGH_COALESCE) {
 				coal_conf->rx_timeout = 2;
 				coal_conf->rx_event_count = 3;
-				amd8111e_set_coalesce(dev,RX_INTR_COAL);
+				amd8111e_set_coalesce(dev, RX_INTR_COAL);
 				coal_conf->rx_coal_type = HIGH_COALESCE;
 			}
 		}
 	}
-    	/* NOW FOR TX INTR COALESC */
-	if(tx_pkt_rate < 800){
-		if(coal_conf->tx_coal_type != NO_COALESCE){
 
+	/* NOW FOR TX INTR COALESC */
+	if (tx_pkt_rate < 800) {
+		if (coal_conf->tx_coal_type != NO_COALESCE) {
 			coal_conf->tx_timeout = 0x0;
 			coal_conf->tx_event_count = 0;
-			amd8111e_set_coalesce(dev,TX_INTR_COAL);
+			amd8111e_set_coalesce(dev, TX_INTR_COAL);
 			coal_conf->tx_coal_type = NO_COALESCE;
 		}
-	}
-	else{
-
-		tx_pkt_size = tx_data_rate/tx_pkt_rate;
-		if (tx_pkt_size < 128){
-
-			if(coal_conf->tx_coal_type != NO_COALESCE){
-
+	} else {
+		tx_pkt_size = tx_data_rate / tx_pkt_rate;
+		if (tx_pkt_size < 128) {
+			if (coal_conf->tx_coal_type != NO_COALESCE) {
 				coal_conf->tx_timeout = 0;
 				coal_conf->tx_event_count = 0;
-				amd8111e_set_coalesce(dev,TX_INTR_COAL);
+				amd8111e_set_coalesce(dev, TX_INTR_COAL);
 				coal_conf->tx_coal_type = NO_COALESCE;
 			}
-
-		}
-		else if ( (tx_pkt_size >= 128) && (tx_pkt_size < 512) ){
-
-			if(coal_conf->tx_coal_type !=  LOW_COALESCE){
+		} else if ((tx_pkt_size >= 128) && (tx_pkt_size < 512)) {
+			if (coal_conf->tx_coal_type !=  LOW_COALESCE) {
 				coal_conf->tx_timeout = 1;
 				coal_conf->tx_event_count = 2;
-				amd8111e_set_coalesce(dev,TX_INTR_COAL);
+				amd8111e_set_coalesce(dev, TX_INTR_COAL);
 				coal_conf->tx_coal_type = LOW_COALESCE;
-
 			}
-		}
-		else if ((tx_pkt_size >= 512) && (tx_pkt_size < 1024)){
-
-			if(coal_conf->tx_coal_type !=  MEDIUM_COALESCE){
+		} else if ((tx_pkt_size >= 512) && (tx_pkt_size < 1024)) {
+			if (coal_conf->tx_coal_type !=  MEDIUM_COALESCE) {
 				coal_conf->tx_timeout = 2;
 				coal_conf->tx_event_count = 5;
-				amd8111e_set_coalesce(dev,TX_INTR_COAL);
+				amd8111e_set_coalesce(dev, TX_INTR_COAL);
 				coal_conf->tx_coal_type = MEDIUM_COALESCE;
 			}
-
-		}
-		else if(tx_pkt_size >= 1024){
-			if (tx_pkt_size >= 1024){
-				if(coal_conf->tx_coal_type !=  HIGH_COALESCE){
+		} else if (tx_pkt_size >= 1024) {
+			if (tx_pkt_size >= 1024) {
+				if (coal_conf->tx_coal_type !=  HIGH_COALESCE) {
 					coal_conf->tx_timeout = 4;
 					coal_conf->tx_event_count = 8;
-					amd8111e_set_coalesce(dev,TX_INTR_COAL);
+					amd8111e_set_coalesce(dev, TX_INTR_COAL);
 					coal_conf->tx_coal_type = HIGH_COALESCE;
 				}
 			}
 		}
 	}
 	return 0;
-
 }
 
 /* This is device interrupt function. It handles transmit,
@@ -1114,13 +1100,13 @@ static int amd8111e_calc_coalesce(struct net_device *dev)
 static irqreturn_t amd8111e_interrupt(int irq, void *dev_id)
 {
 
-	struct net_device *dev = (struct net_device *) dev_id;
+	struct net_device *dev = (struct net_device *)dev_id;
 	struct amd8111e_priv *lp = netdev_priv(dev);
 	void __iomem *mmio = lp->mmio;
 	unsigned int intr0, intren0;
 	unsigned int handled = 1;
 
-	if(unlikely(dev == NULL))
+	if (unlikely(dev == NULL))
 		return IRQ_NONE;
 
 	spin_lock(&lp->lock);
@@ -1134,7 +1120,7 @@ static irqreturn_t amd8111e_interrupt(int irq, void *dev_id)
 
 	/* Process all the INT event until INTR bit is clear. */
 
-	if (!(intr0 & INTR)){
+	if (!(intr0 & INTR)) {
 		handled = 0;
 		goto err_no_interrupt;
 	}
@@ -1169,7 +1155,7 @@ static irqreturn_t amd8111e_interrupt(int irq, void *dev_id)
 		amd8111e_calc_coalesce(dev);
 
 err_no_interrupt:
-	writel( VAL0 | INTREN,mmio + CMD0);
+	writel(VAL0 | INTREN, mmio + CMD0);
 
 	spin_unlock(&lp->lock);
 
@@ -1209,7 +1195,7 @@ static int amd8111e_close(struct net_device *dev)
 	netif_carrier_off(lp->amd8111e_net_dev);
 
 	/* Delete ipg timer */
-	if(lp->options & OPTION_DYN_IPG_ENABLE)
+	if (lp->options & OPTION_DYN_IPG_ENABLE)
 		del_timer_sync(&lp->ipg_data.ipg_timer);
 
 	spin_unlock_irq(&lp->lock);
@@ -1225,12 +1211,12 @@ static int amd8111e_close(struct net_device *dev)
 /* This function opens new interface.It requests irq for the device,
  * initializes the device,buffers and descriptors, and starts the device.
  */
-static int amd8111e_open(struct net_device *dev )
+static int amd8111e_open(struct net_device *dev)
 {
 	struct amd8111e_priv *lp = netdev_priv(dev);
 
-	if(dev->irq ==0 || request_irq(dev->irq, amd8111e_interrupt, IRQF_SHARED,
-					 dev->name, dev))
+	if ((dev->irq == 0) || request_irq(dev->irq, amd8111e_interrupt,
+					   IRQF_SHARED, dev->name, dev))
 		return -EAGAIN;
 
 	napi_enable(&lp->napi);
@@ -1239,7 +1225,7 @@ static int amd8111e_open(struct net_device *dev )
 
 	amd8111e_init_hw_default(lp);
 
-	if(amd8111e_restart(dev)){
+	if (amd8111e_restart(dev)) {
 		spin_unlock_irq(&lp->lock);
 		napi_disable(&lp->napi);
 		if (dev->irq)
@@ -1247,7 +1233,7 @@ static int amd8111e_open(struct net_device *dev )
 		return -ENOMEM;
 	}
 	/* Start ipg timer */
-	if(lp->options & OPTION_DYN_IPG_ENABLE){
+	if (lp->options & OPTION_DYN_IPG_ENABLE) {
 		add_timer(&lp->ipg_data.ipg_timer);
 		netdev_info(dev, "Dynamic IPG Enabled\n");
 	}
@@ -1264,9 +1250,10 @@ static int amd8111e_open(struct net_device *dev )
 /* This function checks if there is any transmit  descriptors
  * available to queue more packet.
  */
-static int amd8111e_tx_queue_avail(struct amd8111e_priv *lp )
+static int amd8111e_tx_queue_avail(struct amd8111e_priv *lp)
 {
 	int tx_index = lp->tx_idx & TX_BUFF_MOD_MASK;
+
 	if (lp->tx_skbuff[tx_index])
 		return -1;
 	else
@@ -1317,13 +1304,14 @@ static netdev_tx_t amd8111e_start_xmit(struct sk_buff *skb,
 	lp->tx_idx++;
 
 	/* Trigger an immediate send poll. */
-	writel( VAL1 | TDMD0, lp->mmio + CMD0);
-	writel( VAL2 | RDMD0,lp->mmio + CMD0);
+	writel(VAL1 | TDMD0, lp->mmio + CMD0);
+	writel(VAL2 | RDMD0, lp->mmio + CMD0);
 
-	if(amd8111e_tx_queue_avail(lp) < 0){
+	if (amd8111e_tx_queue_avail(lp) < 0)
 		netif_stop_queue(dev);
-	}
+
 	spin_unlock_irqrestore(&lp->lock, flags);
+
 	return NETDEV_TX_OK;
 }
 /* This function returns all the memory mapped registers of the device. */
@@ -1354,28 +1342,29 @@ static void amd8111e_set_multicast_list(struct net_device *dev)
 {
 	struct netdev_hw_addr *ha;
 	struct amd8111e_priv *lp = netdev_priv(dev);
-	u32 mc_filter[2] ;
+	u32 mc_filter[2];
 	int bit_num;
 
-	if(dev->flags & IFF_PROMISC){
-		writel( VAL2 | PROM, lp->mmio + CMD2);
+	if (dev->flags & IFF_PROMISC) {
+		writel(VAL2 | PROM, lp->mmio + CMD2);
 		return;
+	} else {
+		writel(PROM, lp->mmio + CMD2);
 	}
-	else
-		writel( PROM, lp->mmio + CMD2);
+
 	if (dev->flags & IFF_ALLMULTI ||
 	    netdev_mc_count(dev) > MAX_FILTER_SIZE) {
 		/* get all multicast packet */
 		mc_filter[1] = mc_filter[0] = 0xffffffff;
 		lp->options |= OPTION_MULTICAST_ENABLE;
-		amd8111e_writeq(*(u64 *)mc_filter,lp->mmio + LADRF);
+		amd8111e_writeq(*(u64 *)mc_filter, lp->mmio + LADRF);
 		return;
 	}
 	if (netdev_mc_empty(dev)) {
 		/* get only own packets */
 		mc_filter[1] = mc_filter[0] = 0;
 		lp->options &= ~OPTION_MULTICAST_ENABLE;
-		amd8111e_writeq(*(u64 *)mc_filter,lp->mmio + LADRF);
+		amd8111e_writeq(*(u64 *)mc_filter, lp->mmio + LADRF);
 		/* disable promiscuous mode */
 		writel(PROM, lp->mmio + CMD2);
 		return;
@@ -1387,21 +1376,21 @@ static void amd8111e_set_multicast_list(struct net_device *dev)
 		bit_num = (ether_crc_le(ETH_ALEN, ha->addr) >> 26) & 0x3f;
 		mc_filter[bit_num >> 5] |= 1 << (bit_num & 31);
 	}
-	amd8111e_writeq(*(u64 *)mc_filter,lp->mmio+ LADRF);
+	amd8111e_writeq(*(u64 *)mc_filter, lp->mmio + LADRF);
 
 	/* To eliminate PCI posting bug */
 	readl(lp->mmio + CMD2);
-
 }
 
 static void amd8111e_get_drvinfo(struct net_device *dev, struct ethtool_drvinfo *info)
 {
 	struct amd8111e_priv *lp = netdev_priv(dev);
 	struct pci_dev *pci_dev = lp->pci_dev;
+
 	strlcpy(info->driver, MODULE_NAME, sizeof(info->driver));
 	strlcpy(info->version, MODULE_VERS, sizeof(info->version));
 	snprintf(info->fw_version, sizeof(info->fw_version),
-		"%u", chip_version);
+		 "%u", chip_version);
 	strlcpy(info->bus_info, pci_name(pci_dev), sizeof(info->bus_info));
 }
 
@@ -1413,6 +1402,7 @@ static int amd8111e_get_regs_len(struct net_device *dev)
 static void amd8111e_get_regs(struct net_device *dev, struct ethtool_regs *regs, void *buf)
 {
 	struct amd8111e_priv *lp = netdev_priv(dev);
+
 	regs->version = 0;
 	amd8111e_read_regs(lp, buf);
 }
@@ -1420,9 +1410,11 @@ static void amd8111e_get_regs(struct net_device *dev, struct ethtool_regs *regs,
 static int amd8111e_get_settings(struct net_device *dev, struct ethtool_cmd *ecmd)
 {
 	struct amd8111e_priv *lp = netdev_priv(dev);
+
 	spin_lock_irq(&lp->lock);
 	mii_ethtool_gset(&lp->mii_if, ecmd);
 	spin_unlock_irq(&lp->lock);
+
 	return 0;
 }
 
@@ -1430,27 +1422,32 @@ static int amd8111e_set_settings(struct net_device *dev, struct ethtool_cmd *ecm
 {
 	struct amd8111e_priv *lp = netdev_priv(dev);
 	int res;
+
 	spin_lock_irq(&lp->lock);
 	res = mii_ethtool_sset(&lp->mii_if, ecmd);
 	spin_unlock_irq(&lp->lock);
+
 	return res;
 }
 
 static int amd8111e_nway_reset(struct net_device *dev)
 {
 	struct amd8111e_priv *lp = netdev_priv(dev);
+
 	return mii_nway_restart(&lp->mii_if);
 }
 
 static u32 amd8111e_get_link(struct net_device *dev)
 {
 	struct amd8111e_priv *lp = netdev_priv(dev);
+
 	return mii_link_ok(&lp->mii_if);
 }
 
 static void amd8111e_get_wol(struct net_device *dev, struct ethtool_wolinfo *wol_info)
 {
 	struct amd8111e_priv *lp = netdev_priv(dev);
+
 	wol_info->supported = WAKE_MAGIC|WAKE_PHY;
 	if (lp->options & OPTION_WOL_ENABLE)
 		wol_info->wolopts = WAKE_MAGIC;
@@ -1459,18 +1456,21 @@ static void amd8111e_get_wol(struct net_device *dev, struct ethtool_wolinfo *wol
 static int amd8111e_set_wol(struct net_device *dev, struct ethtool_wolinfo *wol_info)
 {
 	struct amd8111e_priv *lp = netdev_priv(dev);
+
 	if (wol_info->wolopts & ~(WAKE_MAGIC|WAKE_PHY))
 		return -EINVAL;
+
 	spin_lock_irq(&lp->lock);
 	if (wol_info->wolopts & WAKE_MAGIC)
 		lp->options |=
 			(OPTION_WOL_ENABLE | OPTION_WAKE_MAGIC_ENABLE);
-	else if(wol_info->wolopts & WAKE_PHY)
+	else if (wol_info->wolopts & WAKE_PHY)
 		lp->options |=
 			(OPTION_WOL_ENABLE | OPTION_WAKE_PHY_ENABLE);
 	else
 		lp->options &= ~OPTION_WOL_ENABLE;
 	spin_unlock_irq(&lp->lock);
+
 	return 0;
 }
 
@@ -1497,13 +1497,11 @@ static int amd8111e_ioctl(struct net_device *dev , struct ifreq *ifr, int cmd)
 	int err;
 	u32 mii_regval;
 
-	switch(cmd) {
+	switch (cmd) {
 	case SIOCGMIIPHY:
 		data->phy_id = lp->ext_phy_addr;
-
 	/* fallthru */
 	case SIOCGMIIREG:
-
 		spin_lock_irq(&lp->lock);
 		err = amd8111e_read_phy(lp, data->phy_id,
 			data->reg_num & PHY_REG_ADDR_MASK, &mii_regval);
@@ -1513,12 +1511,10 @@ static int amd8111e_ioctl(struct net_device *dev , struct ifreq *ifr, int cmd)
 		return err;
 
 	case SIOCSMIIREG:
-
 		spin_lock_irq(&lp->lock);
 		err = amd8111e_write_phy(lp, data->phy_id,
 			data->reg_num & PHY_REG_ADDR_MASK, data->val_in);
 		spin_unlock_irq(&lp->lock);
-
 		return err;
 
 	default:
@@ -1537,7 +1533,7 @@ static int amd8111e_set_mac_address(struct net_device *dev, void *p)
 	spin_lock_irq(&lp->lock);
 	/* Setting the MAC address to the device */
 	for (i = 0; i < ETH_ALEN; i++)
-		writeb( dev->dev_addr[i], lp->mmio + PADR + i );
+		writeb(dev->dev_addr[i], lp->mmio + PADR + i);
 
 	spin_unlock_irq(&lp->lock);
 
@@ -1572,18 +1568,20 @@ static int amd8111e_change_mtu(struct net_device *dev, int new_mtu)
 
 	err = amd8111e_restart(dev);
 	spin_unlock_irq(&lp->lock);
-	if(!err)
+	if (!err)
 		netif_start_queue(dev);
+
 	return err;
 }
 
 static int amd8111e_enable_magicpkt(struct amd8111e_priv *lp)
 {
-	writel( VAL1|MPPLBA, lp->mmio + CMD3);
-	writel( VAL0|MPEN_SW, lp->mmio + CMD7);
+	writel(VAL1 | MPPLBA, lp->mmio + CMD3);
+	writel(VAL0 | MPEN_SW, lp->mmio + CMD7);
 
 	/* To eliminate PCI posting bug */
 	readl(lp->mmio + CMD7);
+
 	return 0;
 }
 
@@ -1591,10 +1589,11 @@ static int amd8111e_enable_link_change(struct amd8111e_priv *lp)
 {
 
 	/* Adapter is already stoped/suspended/interrupt-disabled */
-	writel(VAL0|LCMODE_SW,lp->mmio + CMD7);
+	writel(VAL0 | LCMODE_SW, lp->mmio + CMD7);
 
 	/* To eliminate PCI posting bug */
 	readl(lp->mmio + CMD7);
+
 	return 0;
 }
 
@@ -1613,7 +1612,7 @@ static void amd8111e_tx_timeout(struct net_device *dev)
 	spin_lock_irq(&lp->lock);
 	err = amd8111e_restart(dev);
 	spin_unlock_irq(&lp->lock);
-	if(!err)
+	if (!err)
 		netif_wake_queue(dev);
 }
 static int amd8111e_suspend(struct pci_dev *pci_dev, pm_message_t state)
@@ -1633,23 +1632,22 @@ static int amd8111e_suspend(struct pci_dev *pci_dev, pm_message_t state)
 
 	/* stop chip */
 	spin_lock_irq(&lp->lock);
-	if(lp->options & OPTION_DYN_IPG_ENABLE)
+	if (lp->options & OPTION_DYN_IPG_ENABLE)
 		del_timer_sync(&lp->ipg_data.ipg_timer);
 	amd8111e_stop_chip(lp);
 	spin_unlock_irq(&lp->lock);
 
-	if(lp->options & OPTION_WOL_ENABLE){
-		 /* enable wol */
-		if(lp->options & OPTION_WAKE_MAGIC_ENABLE)
+	if (lp->options & OPTION_WOL_ENABLE) {
+		/* enable wol */
+		if (lp->options & OPTION_WAKE_MAGIC_ENABLE)
 			amd8111e_enable_magicpkt(lp);
-		if(lp->options & OPTION_WAKE_PHY_ENABLE)
+		if (lp->options & OPTION_WAKE_PHY_ENABLE)
 			amd8111e_enable_link_change(lp);
 
 		pci_enable_wake(pci_dev, PCI_D3hot, 1);
 		pci_enable_wake(pci_dev, PCI_D3cold, 1);
 
-	}
-	else{
+	} else {
 		pci_enable_wake(pci_dev, PCI_D3hot, 0);
 		pci_enable_wake(pci_dev, PCI_D3cold, 0);
 	}
@@ -1678,7 +1676,7 @@ static int amd8111e_resume(struct pci_dev *pci_dev)
 	spin_lock_irq(&lp->lock);
 	amd8111e_restart(dev);
 	/* Restart ipg timer */
-	if(lp->options & OPTION_DYN_IPG_ENABLE)
+	if (lp->options & OPTION_DYN_IPG_ENABLE)
 		mod_timer(&lp->ipg_data.ipg_timer,
 				jiffies + IPG_CONVERGE_JIFFIES);
 	spin_unlock_irq(&lp->lock);
@@ -1695,55 +1693,52 @@ static void amd8111e_config_ipg(struct net_device *dev)
 	unsigned int total_col_cnt;
 	unsigned int tmp_ipg;
 
-	if(lp->link_config.duplex == DUPLEX_FULL){
+	if (lp->link_config.duplex == DUPLEX_FULL) {
 		ipg_data->ipg = DEFAULT_IPG;
 		return;
 	}
 
-	if(ipg_data->ipg_state == SSTATE){
-
-		if(ipg_data->timer_tick == IPG_STABLE_TIME){
-
+	if (ipg_data->ipg_state == SSTATE) {
+		if (ipg_data->timer_tick == IPG_STABLE_TIME) {
 			ipg_data->timer_tick = 0;
 			ipg_data->ipg = MIN_IPG - IPG_STEP;
 			ipg_data->current_ipg = MIN_IPG;
 			ipg_data->diff_col_cnt = 0xFFFFFFFF;
 			ipg_data->ipg_state = CSTATE;
-		}
-		else
+		} else {
 			ipg_data->timer_tick++;
+		}
 	}
 
-	if(ipg_data->ipg_state == CSTATE){
-
+	if (ipg_data->ipg_state == CSTATE) {
 		/* Get the current collision count */
-
 		total_col_cnt = ipg_data->col_cnt =
 				amd8111e_read_mib(mmio, xmt_collisions);
 
 		if ((total_col_cnt - prev_col_cnt) <
-				(ipg_data->diff_col_cnt)){
+				(ipg_data->diff_col_cnt)) {
 
 			ipg_data->diff_col_cnt =
-				total_col_cnt - prev_col_cnt ;
+				total_col_cnt - prev_col_cnt;
 
 			ipg_data->ipg = ipg_data->current_ipg;
 		}
 
 		ipg_data->current_ipg += IPG_STEP;
 
-		if (ipg_data->current_ipg <= MAX_IPG)
+		if (ipg_data->current_ipg <= MAX_IPG) {
 			tmp_ipg = ipg_data->current_ipg;
-		else{
+		} else {
 			tmp_ipg = ipg_data->ipg;
 			ipg_data->ipg_state = SSTATE;
 		}
+
 		writew((u32)tmp_ipg, mmio + IPG);
 		writew((u32)(tmp_ipg - IFS1_DELTA), mmio + IFS1);
 	}
-	 mod_timer(&lp->ipg_data.ipg_timer, jiffies + IPG_CONVERGE_JIFFIES);
-	return;
+	mod_timer(&lp->ipg_data.ipg_timer, jiffies + IPG_CONVERGE_JIFFIES);
 
+	return;
 }
 
 static void amd8111e_probe_ext_phy(struct net_device *dev)
@@ -1783,27 +1778,27 @@ static const struct net_device_ops amd8111e_netdev_ops = {
 };
 
 static int amd8111e_probe_one(struct pci_dev *pdev,
-				  const struct pci_device_id *ent)
+			      const struct pci_device_id *ent)
 {
 	int err, i;
-	unsigned long reg_addr,reg_len;
+	unsigned long reg_addr, reg_len;
 	struct amd8111e_priv *lp;
 	struct net_device *dev;
 
 	err = pci_enable_device(pdev);
-	if(err){
+	if (err) {
 		dev_err(&pdev->dev, "Cannot enable new PCI device\n");
 		return err;
 	}
 
-	if(!(pci_resource_flags(pdev, 0) & IORESOURCE_MEM)){
+	if (!(pci_resource_flags(pdev, 0) & IORESOURCE_MEM)) {
 		dev_err(&pdev->dev, "Cannot find PCI base address\n");
 		err = -ENODEV;
 		goto err_disable_pdev;
 	}
 
 	err = pci_request_regions(pdev, MODULE_NAME);
-	if(err){
+	if (err) {
 		dev_err(&pdev->dev, "Cannot obtain PCI resources\n");
 		goto err_disable_pdev;
 	}
@@ -1836,7 +1831,7 @@ static int amd8111e_probe_one(struct pci_dev *pdev,
 	SET_NETDEV_DEV(dev, &pdev->dev);
 
 #if AMD8111E_VLAN_TAG_USED
-	dev->features |= NETIF_F_HW_VLAN_CTAG_TX | NETIF_F_HW_VLAN_CTAG_RX ;
+	dev->features |= NETIF_F_HW_VLAN_CTAG_TX | NETIF_F_HW_VLAN_CTAG_RX;
 #endif
 
 	lp = netdev_priv(dev);
@@ -1859,16 +1854,16 @@ static int amd8111e_probe_one(struct pci_dev *pdev,
 
 	/* Setting user defined parametrs */
 	lp->ext_phy_option = speed_duplex[card_idx];
-	if(coalesce[card_idx])
+	if (coalesce[card_idx])
 		lp->options |= OPTION_INTR_COAL_ENABLE;
-	if(dynamic_ipg[card_idx++])
+	if (dynamic_ipg[card_idx++])
 		lp->options |= OPTION_DYN_IPG_ENABLE;
 
 
 	/* Initialize driver entry points */
 	dev->netdev_ops = &amd8111e_netdev_ops;
 	dev->ethtool_ops = &ops;
-	dev->irq =pdev->irq;
+	dev->irq = pdev->irq;
 	dev->watchdog_timeo = AMD8111E_TX_TIMEOUT;
 	netif_napi_add(dev, &lp->napi, amd8111e_rx_poll, 32);
 
@@ -1897,7 +1892,7 @@ static int amd8111e_probe_one(struct pci_dev *pdev,
 	pci_set_drvdata(pdev, dev);
 
 	/* Initialize software ipg timer */
-	if(lp->options & OPTION_DYN_IPG_ENABLE){
+	if (lp->options & OPTION_DYN_IPG_ENABLE) {
 		init_timer(&lp->ipg_data.ipg_timer);
 		lp->ipg_data.ipg_timer.data = (unsigned long) dev;
 		lp->ipg_data.ipg_timer.function = (void *)&amd8111e_config_ipg;
@@ -1908,7 +1903,7 @@ static int amd8111e_probe_one(struct pci_dev *pdev,
 	}
 
 	/*  display driver and device information */
-    	chip_version = (readl(lp->mmio + CHIPID) & 0xf0000000)>>28;
+	chip_version = (readl(lp->mmio + CHIPID) & 0xf0000000) >> 28;
 	dev_info(&pdev->dev, "AMD-8111e Driver Version: %s\n", MODULE_VERS);
 	dev_info(&pdev->dev, "[ Rev %x ] PCI 10/100BaseT Ethernet %pM\n",
 		 chip_version, dev->dev_addr);
@@ -1918,7 +1913,7 @@ static int amd8111e_probe_one(struct pci_dev *pdev,
 	else
 		dev_info(&pdev->dev, "Couldn't detect MII PHY, assuming address 0x01\n");
 
-    	return 0;
+	return 0;
 
 err_free_dev:
 	free_netdev(dev);
@@ -1952,7 +1947,7 @@ static DEFINE_PCI_DEVICE_TABLE(amd8111e_pci_tbl) = {
 MODULE_DEVICE_TABLE(pci, amd8111e_pci_tbl);
 
 static struct pci_driver amd8111e_driver = {
-	.name   	= MODULE_NAME,
+	.name		= MODULE_NAME,
 	.id_table	= amd8111e_pci_tbl,
 	.probe		= amd8111e_probe_one,
 	.remove		= amd8111e_remove_one,
-- 
1.7.9.5
