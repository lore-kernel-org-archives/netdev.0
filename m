From: Francois Romieu <romieu@fr.zoreil.com>
Subject: Pull request for 'ipg' branch
Date: Tue, 4 Dec 2007 22:45:51 +0100
Message-ID: <20071204214551.GA6345@electric-eye.fr.zoreil.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Pekka Enberg <penberg@cs.helsinki.fi>,
	Sorbica Shieh <sorbica@icplus.com.tw>,
	Jesse Huang <jesse@icplus.com.tw>,
	Andrew Morton <akpm@linux-foundation.org>,
	netdev@vger.kernel.org
To: jeff@garzik.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from electric-eye.fr.zoreil.com ([213.41.134.224]:34334 "EHLO
	electric-eye.fr.zoreil.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1752170AbXLDVvX (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 4 Dec 2007 16:51:23 -0500
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Please pull from branch 'ipg' in repository

git://git.kernel.org/pub/scm/linux/kernel/git/romieu/netdev-2.6.git ipg

to get the changes below.

Distance from 'upstream' (558f08ed31c6909d3c9ae5d6dbf81220ede4b54a)
-------------------------------------------------------------------

4918e9ebf74735bb8e664f97dc1dcc1e3d6abf9e
e7b6ced0731fc6ad1a15a015de7e8c2e15da95f8
46bc63253ca320770b855249ef8cb894940a3437
992a029067f6e5c70021a0df65b2469a06362832
adf129afde7ea8444fb6441da27e2d3385dbc297
25ba65ab7ff51de58ea0c70d23b3257f658f180d
2af61e99e3d1c959840ea007ff56b15db794fb99
9312ed326b6d944ec01636db69cba84de46c0c69

Diffstat
--------

 drivers/net/ipg.c |  284 ++++++++++++++++++++++++-----------------------------
 drivers/net/ipg.h |   99 +++++++------------
 2 files changed, 168 insertions(+), 215 deletions(-)

Shortlog
--------

Pekka Enberg (8):
      ipg: remove old contact information
      ipg: remove boolean macros
      ipg: remove IPG_DEV_KFREE_SKB macro
      ipg: remove driver version
      ipg: remove commented out code
      ipg: remove some internal comments
      ipg: naming convention fixes
      ipg: fix checkpatch reported errors

Patch
-----

diff --git a/drivers/net/ipg.c b/drivers/net/ipg.c
index dbd23bb..f736c35 100644
--- a/drivers/net/ipg.c
+++ b/drivers/net/ipg.c
@@ -34,9 +34,9 @@
 	 IPG_AC_DMA | IPG_AC_FIFO | IPG_AC_NETWORK | IPG_AC_HOST | \
 	 IPG_AC_AUTO_INIT)
 
-#define ipg_w32(val32,reg)	iowrite32((val32), ioaddr + (reg))
-#define ipg_w16(val16,reg)	iowrite16((val16), ioaddr + (reg))
-#define ipg_w8(val8,reg)	iowrite8((val8), ioaddr + (reg))
+#define ipg_w32(val32, reg)	iowrite32((val32), ioaddr + (reg))
+#define ipg_w16(val16, reg)	iowrite16((val16), ioaddr + (reg))
+#define ipg_w8(val8, reg)	iowrite8((val8), ioaddr + (reg))
 
 #define ipg_r32(reg)		ioread32(ioaddr + (reg))
 #define ipg_r16(reg)		ioread16(ioaddr + (reg))
@@ -51,24 +51,25 @@ enum {
 #define DRV_NAME	"ipg"
 
 MODULE_AUTHOR("IC Plus Corp. 2003");
-MODULE_DESCRIPTION("IC Plus IP1000 Gigabit Ethernet Adapter Linux Driver "
-		   DrvVer);
+MODULE_DESCRIPTION("IC Plus IP1000 Gigabit Ethernet Adapter Linux Driver");
 MODULE_LICENSE("GPL");
 
-//variable record -- index by leading revision/length
-//Revision/Length(=N*4), Address1, Data1, Address2, Data2,...,AddressN,DataN
+/*
+ * Variable record -- index by leading revision/length
+ * Revision/Length(=N*4), Address1, Data1, Address2, Data2,...,AddressN,DataN
+ */
 static unsigned short DefaultPhyParam[] = {
-	// 11/12/03 IP1000A v1-3 rev=0x40
+	/* 11/12/03 IP1000A v1-3 rev=0x40 */
 	/*--------------------------------------------------------------------------
 	(0x4000|(15*4)), 31, 0x0001, 27, 0x01e0, 31, 0x0002, 22, 0x85bd, 24, 0xfff2,
 				 27, 0x0c10, 28, 0x0c10, 29, 0x2c10, 31, 0x0003, 23, 0x92f6,
 				 31, 0x0000, 23, 0x003d, 30, 0x00de, 20, 0x20e7,  9, 0x0700,
 	  --------------------------------------------------------------------------*/
-	// 12/17/03 IP1000A v1-4 rev=0x40
+	/* 12/17/03 IP1000A v1-4 rev=0x40 */
 	(0x4000 | (07 * 4)), 31, 0x0001, 27, 0x01e0, 31, 0x0002, 27, 0xeb8e, 31,
 	    0x0000,
 	30, 0x005e, 9, 0x0700,
-	// 01/09/04 IP1000A v1-5 rev=0x41
+	/* 01/09/04 IP1000A v1-5 rev=0x41 */
 	(0x4100 | (07 * 4)), 31, 0x0001, 27, 0x01e0, 31, 0x0002, 27, 0xeb8e, 31,
 	    0x0000,
 	30, 0x005e, 9, 0x0700,
@@ -188,7 +189,7 @@ static void send_end(void __iomem *ioaddr, u8 phyctrlpolarity)
 		phyctrlpolarity) & IPG_PC_RSVD_MASK, PHY_CTRL);
 }
 
-static u16 read_phy_bit(void __iomem * ioaddr, u8 phyctrlpolarity)
+static u16 read_phy_bit(void __iomem *ioaddr, u8 phyctrlpolarity)
 {
 	u16 bit_data;
 
@@ -205,7 +206,7 @@ static u16 read_phy_bit(void __iomem * ioaddr, u8 phyctrlpolarity)
  * Read a register from the Physical Layer device located
  * on the IPG NIC, using the IPG PHYCTRL register.
  */
-static int mdio_read(struct net_device * dev, int phy_id, int phy_reg)
+static int mdio_read(struct net_device *dev, int phy_id, int phy_reg)
 {
 	void __iomem *ioaddr = ipg_ioaddr(dev);
 	/*
@@ -374,7 +375,6 @@ static void mdio_write(struct net_device *dev, int phy_id, int phy_reg, int val)
 	}
 }
 
-/* Set LED_Mode JES20040127EEPROM */
 static void ipg_set_led_mode(struct net_device *dev)
 {
 	struct ipg_nic_private *sp = netdev_priv(dev);
@@ -384,19 +384,18 @@ static void ipg_set_led_mode(struct net_device *dev)
 	mode = ipg_r32(ASIC_CTRL);
 	mode &= ~(IPG_AC_LED_MODE_BIT_1 | IPG_AC_LED_MODE | IPG_AC_LED_SPEED);
 
-	if ((sp->LED_Mode & 0x03) > 1)
+	if ((sp->led_mode & 0x03) > 1)
 		mode |= IPG_AC_LED_MODE_BIT_1;	/* Write Asic Control Bit 29 */
 
-	if ((sp->LED_Mode & 0x01) == 1)
+	if ((sp->led_mode & 0x01) == 1)
 		mode |= IPG_AC_LED_MODE;	/* Write Asic Control Bit 14 */
 
-	if ((sp->LED_Mode & 0x08) == 8)
+	if ((sp->led_mode & 0x08) == 8)
 		mode |= IPG_AC_LED_SPEED;	/* Write Asic Control Bit 27 */
 
 	ipg_w32(mode, ASIC_CTRL);
 }
 
-/* Set PHYSet JES20040127EEPROM */
 static void ipg_set_phy_set(struct net_device *dev)
 {
 	struct ipg_nic_private *sp = netdev_priv(dev);
@@ -405,7 +404,7 @@ static void ipg_set_phy_set(struct net_device *dev)
 
 	physet = ipg_r8(PHY_SET);
 	physet &= ~(IPG_PS_MEM_LENB9B | IPG_PS_MEM_LEN9 | IPG_PS_NON_COMPDET);
-	physet |= ((sp->LED_Mode & 0x70) >> 4);
+	physet |= ((sp->led_mode & 0x70) >> 4);
 	ipg_w8(physet, PHY_SET);
 }
 
@@ -415,7 +414,7 @@ static int ipg_reset(struct net_device *dev, u32 resetflags)
 	 * register as specified by the 'resetflags' input
 	 * parameter.
 	 */
-	void __iomem *ioaddr = ipg_ioaddr(dev);	//JES20040127EEPROM:
+	void __iomem *ioaddr = ipg_ioaddr(dev);
 	unsigned int timeout_count = 0;
 
 	IPG_DEBUG_MSG("_reset\n");
@@ -430,10 +429,10 @@ static int ipg_reset(struct net_device *dev, u32 resetflags)
 		if (++timeout_count > IPG_AC_RESET_TIMEOUT)
 			return -ETIME;
 	}
-	/* Set LED Mode in Asic Control JES20040127EEPROM */
+	/* Set LED Mode in Asic Control */
 	ipg_set_led_mode(dev);
 
-	/* Set PHYSet Register Value JES20040127EEPROM */
+	/* Set PHYSet Register Value */
 	ipg_set_phy_set(dev);
 	return 0;
 }
@@ -551,7 +550,7 @@ static int ipg_config_autoneg(struct net_device *dev)
 		printk("\n");
 	} else {
 		/* Configure IPG for half duplex operation. */
-	        printk(KERN_INFO "%s: setting half duplex, "
+		printk(KERN_INFO "%s: setting half duplex, "
 		       "no TX flow control, no RX flow control.\n", dev->name);
 
 		mac_ctrl_val &= ~IPG_MC_DUPLEX_SELECT_FD &
@@ -736,7 +735,7 @@ static int ipg_get_rxbuff(struct net_device *dev, int entry)
 
 	skb = netdev_alloc_skb(dev, IPG_RXSUPPORT_SIZE + NET_IP_ALIGN);
 	if (!skb) {
-		sp->RxBuff[entry] = NULL;
+		sp->rx_buff[entry] = NULL;
 		return -ENOMEM;
 	}
 
@@ -749,7 +748,7 @@ static int ipg_get_rxbuff(struct net_device *dev, int entry)
 	skb->dev = dev;
 
 	/* Save the address of the sk_buff structure. */
-	sp->RxBuff[entry] = skb;
+	sp->rx_buff[entry] = skb;
 
 	rxfd->frag_info = cpu_to_le64(pci_map_single(sp->pdev, skb->data,
 		sp->rx_buf_sz, PCI_DMA_FROMDEVICE));
@@ -772,12 +771,12 @@ static int init_rfdlist(struct net_device *dev)
 	for (i = 0; i < IPG_RFDLIST_LENGTH; i++) {
 		struct ipg_rx *rxfd = sp->rxd + i;
 
-		if (sp->RxBuff[i]) {
+		if (sp->rx_buff[i]) {
 			pci_unmap_single(sp->pdev,
 				le64_to_cpu(rxfd->frag_info) & ~IPG_RFI_FRAGLEN,
 				sp->rx_buf_sz, PCI_DMA_FROMDEVICE);
-			IPG_DEV_KFREE_SKB(sp->RxBuff[i]);
-			sp->RxBuff[i] = NULL;
+			dev_kfree_skb_irq(sp->rx_buff[i]);
+			sp->rx_buff[i] = NULL;
 		}
 
 		/* Clear out the RFS field. */
@@ -828,9 +827,9 @@ static void init_tfdlist(struct net_device *dev)
 
 		txfd->tfc = cpu_to_le64(IPG_TFC_TFDDONE);
 
-		if (sp->TxBuff[i]) {
-			IPG_DEV_KFREE_SKB(sp->TxBuff[i]);
-			sp->TxBuff[i] = NULL;
+		if (sp->tx_buff[i]) {
+			dev_kfree_skb_irq(sp->tx_buff[i]);
+			sp->tx_buff[i] = NULL;
 		}
 
 		txfd->next_desc = cpu_to_le64(sp->txd_map +
@@ -847,7 +846,7 @@ static void init_tfdlist(struct net_device *dev)
 	ipg_w32((u32) sp->txd_map, TFD_LIST_PTR_0);
 	ipg_w32(0x00000000, TFD_LIST_PTR_1);
 
-	sp->ResetCurrentTFD = 1;
+	sp->reset_current_tfd = 1;
 }
 
 /*
@@ -872,7 +871,7 @@ static void ipg_nic_txfree(struct net_device *dev)
 
 	for (released = 0; released < pending; released++) {
 		unsigned int dirty = sp->tx_dirty % IPG_TFDLIST_LENGTH;
-		struct sk_buff *skb = sp->TxBuff[dirty];
+		struct sk_buff *skb = sp->tx_buff[dirty];
 		struct ipg_tx *txfd = sp->txd + dirty;
 
 		IPG_DEBUG_MSG("TFC = %16.16lx\n", (unsigned long) txfd->tfc);
@@ -894,9 +893,9 @@ static void ipg_nic_txfree(struct net_device *dev)
 				le64_to_cpu(txfd->frag_info) & ~IPG_TFI_FRAGLEN,
 				skb->len, PCI_DMA_TODEVICE);
 
-			IPG_DEV_KFREE_SKB(skb);
+			dev_kfree_skb_irq(skb);
 
-			sp->TxBuff[dirty] = NULL;
+			sp->tx_buff[dirty] = NULL;
 		}
 	}
 
@@ -1068,7 +1067,7 @@ static int ipg_nic_rxrestore(struct net_device *dev)
 		unsigned int entry = dirty % IPG_RFDLIST_LENGTH;
 
 		/* rx_copybreak may poke hole here and there. */
-		if (sp->RxBuff[entry])
+		if (sp->rx_buff[entry])
 			continue;
 
 		/* Generate a new receive buffer to replace the
@@ -1092,22 +1091,22 @@ static int ipg_nic_rxrestore(struct net_device *dev)
 #ifdef JUMBO_FRAME
 
 /* use jumboindex and jumbosize to control jumbo frame status
-   initial status is jumboindex=-1 and jumbosize=0
-   1. jumboindex = -1 and jumbosize=0 : previous jumbo frame has been done.
-   2. jumboindex != -1 and jumbosize != 0 : jumbo frame is not over size and receiving
-   3. jumboindex = -1 and jumbosize != 0 : jumbo frame is over size, already dump
-                previous receiving and need to continue dumping the current one
-*/
+ * initial status is jumboindex=-1 and jumbosize=0
+ * 1. jumboindex = -1 and jumbosize=0 : previous jumbo frame has been done.
+ * 2. jumboindex != -1 and jumbosize != 0 : jumbo frame is not over size and receiving
+ * 3. jumboindex = -1 and jumbosize != 0 : jumbo frame is over size, already dump
+ *               previous receiving and need to continue dumping the current one
+ */
 enum {
-	NormalPacket,
-	ErrorPacket
+	NORMAL_PACKET,
+	ERROR_PACKET
 };
 
 enum {
-	Frame_NoStart_NoEnd	= 0,
-	Frame_WithStart		= 1,
-	Frame_WithEnd		= 10,
-	Frame_WithStart_WithEnd = 11
+	FRAME_NO_START_NO_END	= 0,
+	FRAME_WITH_START		= 1,
+	FRAME_WITH_END		= 10,
+	FRAME_WITH_START_WITH_END = 11
 };
 
 inline void ipg_nic_rx_free_skb(struct net_device *dev)
@@ -1115,14 +1114,14 @@ inline void ipg_nic_rx_free_skb(struct net_device *dev)
 	struct ipg_nic_private *sp = netdev_priv(dev);
 	unsigned int entry = sp->rx_current % IPG_RFDLIST_LENGTH;
 
-	if (sp->RxBuff[entry]) {
+	if (sp->rx_buff[entry]) {
 		struct ipg_rx *rxfd = sp->rxd + entry;
 
 		pci_unmap_single(sp->pdev,
 			le64_to_cpu(rxfd->frag_info & ~IPG_RFI_FRAGLEN),
 			sp->rx_buf_sz, PCI_DMA_FROMDEVICE);
-		IPG_DEV_KFREE_SKB(sp->RxBuff[entry]);
-		sp->RxBuff[entry] = NULL;
+		dev_kfree_skb_irq(sp->rx_buff[entry]);
+		sp->rx_buff[entry] = NULL;
 	}
 }
 
@@ -1130,12 +1129,12 @@ inline int ipg_nic_rx_check_frame_type(struct net_device *dev)
 {
 	struct ipg_nic_private *sp = netdev_priv(dev);
 	struct ipg_rx *rxfd = sp->rxd + (sp->rx_current % IPG_RFDLIST_LENGTH);
-	int type = Frame_NoStart_NoEnd;
+	int type = FRAME_NO_START_NO_END;
 
 	if (le64_to_cpu(rxfd->rfs) & IPG_RFS_FRAMESTART)
-		type += Frame_WithStart;
+		type += FRAME_WITH_START;
 	if (le64_to_cpu(rxfd->rfs) & IPG_RFS_FRAMEEND)
-		type += Frame_WithEnd;
+		type += FRAME_WITH_END;
 	return type;
 }
 
@@ -1184,43 +1183,43 @@ inline int ipg_nic_rx_check_error(struct net_device *dev)
 		 * buffer since it is erroneous and we will
 		 * not pass it to higher layer processes.
 		 */
-		if (sp->RxBuff[entry]) {
+		if (sp->rx_buff[entry]) {
 			pci_unmap_single(sp->pdev,
 				le64_to_cpu(rxfd->frag_info & ~IPG_RFI_FRAGLEN),
 				sp->rx_buf_sz, PCI_DMA_FROMDEVICE);
 
-			IPG_DEV_KFREE_SKB(sp->RxBuff[entry]);
-			sp->RxBuff[entry] = NULL;
+			dev_kfree_skb_irq(sp->rx_buff[entry]);
+			sp->rx_buff[entry] = NULL;
 		}
-		return ErrorPacket;
+		return ERROR_PACKET;
 	}
-	return NormalPacket;
+	return NORMAL_PACKET;
 }
 
 static void ipg_nic_rx_with_start_and_end(struct net_device *dev,
 					  struct ipg_nic_private *sp,
 					  struct ipg_rx *rxfd, unsigned entry)
 {
-	struct SJumbo *jumbo = &sp->Jumbo;
+	struct ipg_jumbo *jumbo = &sp->jumbo;
 	struct sk_buff *skb;
 	int framelen;
 
-	if (jumbo->FoundStart) {
-		IPG_DEV_KFREE_SKB(jumbo->skb);
-		jumbo->FoundStart = 0;
-		jumbo->CurrentSize = 0;
+	if (jumbo->found_start) {
+		dev_kfree_skb_irq(jumbo->skb);
+		jumbo->found_start = 0;
+		jumbo->current_size = 0;
 		jumbo->skb = NULL;
 	}
 
-	// 1: found error, 0 no error
-	if (ipg_nic_rx_check_error(dev) != NormalPacket)
+	/* 1: found error, 0 no error */
+	if (ipg_nic_rx_check_error(dev) != NORMAL_PACKET)
 		return;
 
-	skb = sp->RxBuff[entry];
+	skb = sp->rx_buff[entry];
 	if (!skb)
 		return;
 
-	// accept this frame and send to upper layer
+	/* accept this frame and send to upper layer */
 	framelen = le64_to_cpu(rxfd->rfs) & IPG_RFS_RXFRAMELEN;
 	if (framelen > IPG_RXFRAG_SIZE)
 		framelen = IPG_RXFRAG_SIZE;
@@ -1230,39 +1229,39 @@ static void ipg_nic_rx_with_start_and_end(struct net_device *dev,
 	skb->ip_summed = CHECKSUM_NONE;
 	netif_rx(skb);
 	dev->last_rx = jiffies;
-	sp->RxBuff[entry] = NULL;
+	sp->rx_buff[entry] = NULL;
 }
 
 static void ipg_nic_rx_with_start(struct net_device *dev,
 				  struct ipg_nic_private *sp,
 				  struct ipg_rx *rxfd, unsigned entry)
 {
-	struct SJumbo *jumbo = &sp->Jumbo;
+	struct ipg_jumbo *jumbo = &sp->jumbo;
 	struct pci_dev *pdev = sp->pdev;
 	struct sk_buff *skb;
 
-	// 1: found error, 0 no error
-	if (ipg_nic_rx_check_error(dev) != NormalPacket)
+	/* 1: found error, 0 no error */
+	if (ipg_nic_rx_check_error(dev) != NORMAL_PACKET)
 		return;
 
-	// accept this frame and send to upper layer
-	skb = sp->RxBuff[entry];
+	/* accept this frame and send to upper layer */
+	skb = sp->rx_buff[entry];
 	if (!skb)
 		return;
 
-	if (jumbo->FoundStart)
-		IPG_DEV_KFREE_SKB(jumbo->skb);
+	if (jumbo->found_start)
+		dev_kfree_skb_irq(jumbo->skb);
 
 	pci_unmap_single(pdev, le64_to_cpu(rxfd->frag_info & ~IPG_RFI_FRAGLEN),
 			 sp->rx_buf_sz, PCI_DMA_FROMDEVICE);
 
 	skb_put(skb, IPG_RXFRAG_SIZE);
 
-	jumbo->FoundStart = 1;
-	jumbo->CurrentSize = IPG_RXFRAG_SIZE;
+	jumbo->found_start = 1;
+	jumbo->current_size = IPG_RXFRAG_SIZE;
 	jumbo->skb = skb;
 
-	sp->RxBuff[entry] = NULL;
+	sp->rx_buff[entry] = NULL;
 	dev->last_rx = jiffies;
 }
 
@@ -1270,27 +1269,27 @@ static void ipg_nic_rx_with_end(struct net_device *dev,
 				struct ipg_nic_private *sp,
 				struct ipg_rx *rxfd, unsigned entry)
 {
-	struct SJumbo *jumbo = &sp->Jumbo;
+	struct ipg_jumbo *jumbo = &sp->jumbo;
 
-	//1: found error, 0 no error
-	if (ipg_nic_rx_check_error(dev) == NormalPacket) {
-		struct sk_buff *skb = sp->RxBuff[entry];
+	/* 1: found error, 0 no error */
+	if (ipg_nic_rx_check_error(dev) == NORMAL_PACKET) {
+		struct sk_buff *skb = sp->rx_buff[entry];
 
 		if (!skb)
 			return;
 
-		if (jumbo->FoundStart) {
+		if (jumbo->found_start) {
 			int framelen, endframelen;
 
 			framelen = le64_to_cpu(rxfd->rfs) & IPG_RFS_RXFRAMELEN;
 
-			endframeLen = framelen - jumbo->CurrentSize;
+			endframeLen = framelen - jumbo->current_size;
 			/*
 			if (framelen > IPG_RXFRAG_SIZE)
 				framelen=IPG_RXFRAG_SIZE;
 			 */
 			if (framelen > IPG_RXSUPPORT_SIZE)
-				IPG_DEV_KFREE_SKB(jumbo->skb);
+				dev_kfree_skb_irq(jumbo->skb);
 			else {
 				memcpy(skb_put(jumbo->skb, endframeLen),
 				       skb->data, endframeLen);
@@ -1304,15 +1303,15 @@ static void ipg_nic_rx_with_end(struct net_device *dev,
 		}
 
 		dev->last_rx = jiffies;
-		jumbo->FoundStart = 0;
-		jumbo->CurrentSize = 0;
+		jumbo->found_start = 0;
+		jumbo->current_size = 0;
 		jumbo->skb = NULL;
 
 		ipg_nic_rx_free_skb(dev);
 	} else {
-		IPG_DEV_KFREE_SKB(jumbo->skb);
-		jumbo->FoundStart = 0;
-		jumbo->CurrentSize = 0;
+		dev_kfree_skb_irq(jumbo->skb);
+		jumbo->found_start = 0;
+		jumbo->current_size = 0;
 		jumbo->skb = NULL;
 	}
 }
@@ -1321,16 +1320,16 @@ static void ipg_nic_rx_no_start_no_end(struct net_device *dev,
 				       struct ipg_nic_private *sp,
 				       struct ipg_rx *rxfd, unsigned entry)
 {
-	struct SJumbo *jumbo = &sp->Jumbo;
+	struct ipg_jumbo *jumbo = &sp->jumbo;
 
-	//1: found error, 0 no error
-	if (ipg_nic_rx_check_error(dev) == NormalPacket) {
-		struct sk_buff *skb = sp->RxBuff[entry];
+	/* 1: found error, 0 no error */
+	if (ipg_nic_rx_check_error(dev) == NORMAL_PACKET) {
+		struct sk_buff *skb = sp->rx_buff[entry];
 
 		if (skb) {
-			if (jumbo->FoundStart) {
-				jumbo->CurrentSize += IPG_RXFRAG_SIZE;
-				if (jumbo->CurrentSize <= IPG_RXSUPPORT_SIZE) {
+			if (jumbo->found_start) {
+				jumbo->current_size += IPG_RXFRAG_SIZE;
+				if (jumbo->current_size <= IPG_RXSUPPORT_SIZE) {
 					memcpy(skb_put(jumbo->skb,
 						       IPG_RXFRAG_SIZE),
 					       skb->data, IPG_RXFRAG_SIZE);
@@ -1340,9 +1339,9 @@ static void ipg_nic_rx_no_start_no_end(struct net_device *dev,
 			ipg_nic_rx_free_skb(dev);
 		}
 	} else {
-		IPG_DEV_KFREE_SKB(jumbo->skb);
-		jumbo->FoundStart = 0;
-		jumbo->CurrentSize = 0;
+		dev_kfree_skb_irq(jumbo->skb);
+		jumbo->found_start = 0;
+		jumbo->current_size = 0;
 		jumbo->skb = NULL;
 	}
 }
@@ -1364,16 +1363,16 @@ static int ipg_nic_rx(struct net_device *dev)
 			break;
 
 		switch (ipg_nic_rx_check_frame_type(dev)) {
-		case Frame_WithStart_WithEnd:
+		case FRAME_WITH_START_WITH_END:
 			ipg_nic_rx_with_start_and_end(dev, tp, rxfd, entry);
 			break;
-		case Frame_WithStart:
+		case FRAME_WITH_START:
 			ipg_nic_rx_with_start(dev, tp, rxfd, entry);
 			break;
-		case Frame_WithEnd:
+		case FRAME_WITH_END:
 			ipg_nic_rx_with_end(dev, tp, rxfd, entry);
 			break;
-		case Frame_NoStart_NoEnd:
+		case FRAME_NO_START_NO_END:
 			ipg_nic_rx_no_start_no_end(dev, tp, rxfd, entry);
 			break;
 		}
@@ -1412,7 +1411,7 @@ static int ipg_nic_rx(struct net_device *dev)
 
 	for (i = 0; i < IPG_MAXRFDPROCESS_COUNT; i++, curr++) {
 		unsigned int entry = curr % IPG_RFDLIST_LENGTH;
-		struct sk_buff *skb = sp->RxBuff[entry];
+		struct sk_buff *skb = sp->rx_buff[entry];
 		unsigned int framelen;
 
 		rxfd = sp->rxd + entry;
@@ -1481,7 +1480,7 @@ static int ipg_nic_rx(struct net_device *dev)
 					le64_to_cpu(info) & ~IPG_RFI_FRAGLEN,
 					sp->rx_buf_sz, PCI_DMA_FROMDEVICE);
 
-				IPG_DEV_KFREE_SKB(skb);
+				dev_kfree_skb_irq(skb);
 			}
 		} else {
 
@@ -1493,35 +1492,13 @@ static int ipg_nic_rx(struct net_device *dev)
 			/* Set the buffer's protocol field to Ethernet. */
 			skb->protocol = eth_type_trans(skb, dev);
 
-			/* If the frame contains an IP/TCP/UDP frame,
-			 * determine if upper layer must check IP/TCP/UDP
-			 * checksums.
-			 *
-			 * NOTE: DO NOT RELY ON THE TCP/UDP CHECKSUM
-			 *       VERIFICATION FOR SILICON REVISIONS B3
-			 *       AND EARLIER!
-			 *
-			 if ((le64_to_cpu(rxfd->rfs &
-			     (IPG_RFS_TCPDETECTED | IPG_RFS_UDPDETECTED |
-			      IPG_RFS_IPDETECTED))) &&
-			    !(le64_to_cpu(rxfd->rfs &
-			      (IPG_RFS_TCPERROR | IPG_RFS_UDPERROR |
-			       IPG_RFS_IPERROR)))) {
-				 * Indicate IP checksums were performed
-				 * by the IPG.
-				 *
-				skb->ip_summed = CHECKSUM_UNNECESSARY;
-			 } else
+			/* The IPG encountered an error with (or
+			 * there were no) IP/TCP/UDP checksums.
+			 * This may or may not indicate an invalid
+			 * IP/TCP/UDP frame was received. Let the
+			 * upper layer decide.
 			 */
-			 {
-				/* The IPG encountered an error with (or
-				 * there were no) IP/TCP/UDP checksums.
-				 * This may or may not indicate an invalid
-				 * IP/TCP/UDP frame was received. Let the
-				 * upper layer decide.
-				 */
-				skb->ip_summed = CHECKSUM_NONE;
-			}
+			skb->ip_summed = CHECKSUM_NONE;
 
 			/* Hand off frame for higher layer processing.
 			 * The function netif_rx() releases the sk_buff
@@ -1536,7 +1513,7 @@ static int ipg_nic_rx(struct net_device *dev)
 		}
 
 		/* Assure RX buffer is not reused by IPG. */
-		sp->RxBuff[entry] = NULL;
+		sp->rx_buff[entry] = NULL;
 	}
 
 	/*
@@ -1570,15 +1547,15 @@ static int ipg_nic_rx(struct net_device *dev)
 		 * buffer since it is erroneous and we will
 		 * not pass it to higher layer processes.
 		 */
-		if (sp->RxBuff[entry]) {
+		if (sp->rx_buff[entry]) {
 			pci_unmap_single(sp->pdev,
 				le64_to_cpu(rxfd->frag_info) & ~IPG_RFI_FRAGLEN,
 				sp->rx_buf_sz, PCI_DMA_FROMDEVICE);
-			IPG_DEV_KFREE_SKB(sp->RxBuff[entry]);
+			dev_kfree_skb_irq(sp->rx_buff[entry]);
 		}
 
 		/* Assure RX buffer is not reused by IPG. */
-		sp->RxBuff[entry] = NULL;
+		sp->rx_buff[entry] = NULL;
 	}
 
 	sp->rx_current = curr;
@@ -1744,11 +1721,11 @@ static void ipg_rx_clear(struct ipg_nic_private *sp)
 	unsigned int i;
 
 	for (i = 0; i < IPG_RFDLIST_LENGTH; i++) {
-		if (sp->RxBuff[i]) {
+		if (sp->rx_buff[i]) {
 			struct ipg_rx *rxfd = sp->rxd + i;
 
-			IPG_DEV_KFREE_SKB(sp->RxBuff[i]);
-			sp->RxBuff[i] = NULL;
+			dev_kfree_skb_irq(sp->rx_buff[i]);
+			sp->rx_buff[i] = NULL;
 			pci_unmap_single(sp->pdev,
 				le64_to_cpu(rxfd->frag_info) & ~IPG_RFI_FRAGLEN,
 				sp->rx_buf_sz, PCI_DMA_FROMDEVICE);
@@ -1761,16 +1738,16 @@ static void ipg_tx_clear(struct ipg_nic_private *sp)
 	unsigned int i;
 
 	for (i = 0; i < IPG_TFDLIST_LENGTH; i++) {
-		if (sp->TxBuff[i]) {
+		if (sp->tx_buff[i]) {
 			struct ipg_tx *txfd = sp->txd + i;
 
 			pci_unmap_single(sp->pdev,
 				le64_to_cpu(txfd->frag_info) & ~IPG_TFI_FRAGLEN,
-				sp->TxBuff[i]->len, PCI_DMA_TODEVICE);
+				sp->tx_buff[i]->len, PCI_DMA_TODEVICE);
 
-			IPG_DEV_KFREE_SKB(sp->TxBuff[i]);
+			dev_kfree_skb_irq(sp->tx_buff[i]);
 
-			sp->TxBuff[i] = NULL;
+			sp->tx_buff[i] = NULL;
 		}
 	}
 }
@@ -1841,9 +1818,9 @@ static int ipg_nic_open(struct net_device *dev)
 
 #ifdef JUMBO_FRAME
 	/* initialize JUMBO Frame control variable */
-	sp->Jumbo.FoundStart = 0;
-	sp->Jumbo.CurrentSize = 0;
-	sp->Jumbo.skb = 0;
+	sp->jumbo.found_start = 0;
+	sp->jumbo.current_size = 0;
+	sp->jumbo.skb = 0;
 	dev->mtu = IPG_TXFRAG_SIZE;
 #endif
 
@@ -1918,14 +1895,14 @@ static int ipg_nic_hard_start_xmit(struct sk_buff *skb, struct net_device *dev)
 	if (sp->tenmbpsmode)
 		netif_stop_queue(dev);
 
-	if (sp->ResetCurrentTFD) {
-		sp->ResetCurrentTFD = 0;
+	if (sp->reset_current_tfd) {
+		sp->reset_current_tfd = 0;
 		entry = 0;
 	}
 
 	txfd = sp->txd + entry;
 
-	sp->TxBuff[entry] = skb;
+	sp->tx_buff[entry] = skb;
 
 	/* Clear all TFC fields, except TFDDONE. */
 	txfd->tfc = cpu_to_le64(IPG_TFC_TFDDONE);
@@ -2041,7 +2018,6 @@ static void ipg_set_phy_default_param(unsigned char rev,
 	}
 }
 
-/* JES20040127EEPROM */
 static int read_eeprom(struct net_device *dev, int eep_addr)
 {
 	void __iomem *ioaddr = ipg_ioaddr(dev);
@@ -2108,9 +2084,9 @@ static int ipg_hw_init(struct net_device *dev)
 	unsigned int i;
 	int rc;
 
-	/* Read/Write and Reset EEPROM Value Jesse20040128EEPROM_VALUE */
+	/* Read/Write and Reset EEPROM Value */
 	/* Read LED Mode Configuration from EEPROM */
-	sp->LED_Mode = read_eeprom(dev, 6);
+	sp->led_mode = read_eeprom(dev, 6);
 
 	/* Reset all functions within the IPG. Do not assert
 	 * RST_OUT as not compatible with some PHYs.
diff --git a/drivers/net/ipg.h b/drivers/net/ipg.h
index d5d092c..cda5388 100644
--- a/drivers/net/ipg.h
+++ b/drivers/net/ipg.h
@@ -1,20 +1,8 @@
 /*
- *
- * ipg.h
- *
  * Include file for Gigabit Ethernet device driver for Network
  * Interface Cards (NICs) utilizing the Tamarack Microelectronics
  * Inc. IPG Gigabit or Triple Speed Ethernet Media Access
  * Controller.
- *
- * Craig Rich
- * Sundance Technology, Inc.
- * 1485 Saratoga Avenue
- * Suite 200
- * San Jose, CA 95129
- * 408 873 4117
- * www.sundanceti.com
- * craig_rich@sundanceti.com
  */
 #ifndef __LINUX_IPG_H
 #define __LINUX_IPG_H
@@ -35,11 +23,6 @@
 #include <linux/skbuff.h>
 #include <linux/version.h>
 #include <asm/bitops.h>
-/*#include <asm/spinlock.h>*/
-
-#define DrvVer "2.09d"
-
-#define IPG_DEV_KFREE_SKB(skb) dev_kfree_skb_irq(skb)
 
 /*
  *	Constants
@@ -68,7 +51,7 @@
 /* I/O register offsets. */
 enum ipg_regs {
 	DMA_CTRL		= 0x00,
-	RX_DMA_STATUS		= 0x08, // Unused + reserved
+	RX_DMA_STATUS		= 0x08, /* Unused + reserved */
 	TFD_LIST_PTR_0		= 0x10,
 	TFD_LIST_PTR_1		= 0x14,
 	TX_DMA_BURST_THRESH	= 0x18,
@@ -81,22 +64,22 @@ enum ipg_regs {
 	RX_DMA_POLL_PERIOD	= 0x26,
 	DEBUG_CTRL		= 0x2c,
 	ASIC_CTRL		= 0x30,
-	FIFO_CTRL		= 0x38, // Unused
+	FIFO_CTRL		= 0x38, /* Unused */
 	FLOW_OFF_THRESH		= 0x3c,
 	FLOW_ON_THRESH		= 0x3e,
 	EEPROM_DATA		= 0x48,
 	EEPROM_CTRL		= 0x4a,
-	EXPROM_ADDR		= 0x4c, // Unused
-	EXPROM_DATA		= 0x50, // Unused
-	WAKE_EVENT		= 0x51, // Unused
-	COUNTDOWN		= 0x54, // Unused
+	EXPROM_ADDR		= 0x4c, /* Unused */
+	EXPROM_DATA		= 0x50, /* Unused */
+	WAKE_EVENT		= 0x51, /* Unused */
+	COUNTDOWN		= 0x54, /* Unused */
 	INT_STATUS_ACK		= 0x5a,
 	INT_ENABLE		= 0x5c,
-	INT_STATUS		= 0x5e, // Unused
+	INT_STATUS		= 0x5e, /* Unused */
 	TX_STATUS		= 0x60,
 	MAC_CTRL		= 0x6c,
-	VLAN_TAG		= 0x70, // Unused
-	PHY_SET			= 0x75,	// JES20040127EEPROM
+	VLAN_TAG		= 0x70, /* Unused */
+	PHY_SET			= 0x75,
 	PHY_CTRL		= 0x76,
 	STATION_ADDRESS_0	= 0x78,
 	STATION_ADDRESS_1	= 0x7a,
@@ -107,11 +90,11 @@ enum ipg_regs {
 	HASHTABLE_1		= 0x90,
 	RMON_STATISTICS_MASK	= 0x98,
 	STATISTICS_MASK		= 0x9c,
-	RX_JUMBO_FRAMES		= 0xbc, // Unused
-	TCP_CHECKSUM_ERRORS	= 0xc0, // Unused
-	IP_CHECKSUM_ERRORS	= 0xc2, // Unused
-	UDP_CHECKSUM_ERRORS	= 0xc4, // Unused
-	TX_JUMBO_FRAMES		= 0xf4  // Unused
+	RX_JUMBO_FRAMES		= 0xbc, /* Unused */
+	TCP_CHECKSUM_ERRORS	= 0xc0, /* Unused */
+	IP_CHECKSUM_ERRORS	= 0xc2, /* Unused */
+	UDP_CHECKSUM_ERRORS	= 0xc4, /* Unused */
+	TX_JUMBO_FRAMES		= 0xf4  /* Unused */
 };
 
 /* Ethernet MIB statistic register offsets. */
@@ -329,7 +312,7 @@ enum ipg_regs {
 #define IPG_RM_RECEIVEMULTICASTHASH     0x10
 #define IPG_RM_RECEIVEIPMULTICAST       0x20
 
-/* PhySet JES20040127EEPROM*/
+/* PhySet */
 #define IPG_PS_MEM_LENB9B               0x01
 #define IPG_PS_MEM_LEN9                 0x02
 #define IPG_PS_NON_COMPDET              0x04
@@ -386,8 +369,8 @@ enum ipg_regs {
 #define IPG_AC_RST_OUT                  0x01000000
 #define IPG_AC_INT_REQUEST              0x02000000
 #define IPG_AC_RESET_BUSY               0x04000000
-#define IPG_AC_LED_SPEED                0x08000000	//JES20040127EEPROM
-#define IPG_AC_LED_MODE_BIT_1           0x20000000	//JES20040127EEPROM
+#define IPG_AC_LED_SPEED                0x08000000
+#define IPG_AC_LED_MODE_BIT_1           0x20000000
 
 /* EepromCtrl */
 #define IPG_EC_RSVD_MASK                0x83FF
@@ -490,38 +473,34 @@ enum ipg_regs {
  *	Tune
  */
 
-/* Miscellaneous Constants. */
-#define   TRUE  1
-#define   FALSE 0
-
 /* Assign IPG_APPEND_FCS_ON_TX > 0 for auto FCS append on TX. */
-#define         IPG_APPEND_FCS_ON_TX         TRUE
+#define         IPG_APPEND_FCS_ON_TX         1
 
 /* Assign IPG_APPEND_FCS_ON_TX > 0 for auto FCS strip on RX. */
-#define         IPG_STRIP_FCS_ON_RX          TRUE
+#define         IPG_STRIP_FCS_ON_RX          1
 
 /* Assign IPG_DROP_ON_RX_ETH_ERRORS > 0 to drop RX frames with
  * Ethernet errors.
  */
-#define         IPG_DROP_ON_RX_ETH_ERRORS    TRUE
+#define         IPG_DROP_ON_RX_ETH_ERRORS    1
 
 /* Assign IPG_INSERT_MANUAL_VLAN_TAG > 0 to insert VLAN tags manually
  * (via TFC).
  */
-#define		IPG_INSERT_MANUAL_VLAN_TAG   FALSE
+#define		IPG_INSERT_MANUAL_VLAN_TAG   0
 
 /* Assign IPG_ADD_IPCHECKSUM_ON_TX > 0 for auto IP checksum on TX. */
-#define         IPG_ADD_IPCHECKSUM_ON_TX     FALSE
+#define         IPG_ADD_IPCHECKSUM_ON_TX     0
 
 /* Assign IPG_ADD_TCPCHECKSUM_ON_TX > 0 for auto TCP checksum on TX.
  * DO NOT USE FOR SILICON REVISIONS B3 AND EARLIER.
  */
-#define         IPG_ADD_TCPCHECKSUM_ON_TX    FALSE
+#define         IPG_ADD_TCPCHECKSUM_ON_TX    0
 
 /* Assign IPG_ADD_UDPCHECKSUM_ON_TX > 0 for auto UDP checksum on TX.
  * DO NOT USE FOR SILICON REVISIONS B3 AND EARLIER.
  */
-#define         IPG_ADD_UDPCHECKSUM_ON_TX    FALSE
+#define         IPG_ADD_UDPCHECKSUM_ON_TX    0
 
 /* If inserting VLAN tags manually, assign the IPG_MANUAL_VLAN_xx
  * constants as desired.
@@ -611,7 +590,7 @@ enum ipg_regs {
  * Define larger if expecting jumbo frames.
  */
 #ifdef JUMBO_FRAME
-//IPG_TXFRAG_SIZE must <= 0x2b00, or TX will crash
+/* IPG_TXFRAG_SIZE must <= 0x2b00, or TX will crash */
 #define		IPG_TXFRAG_SIZE		JUMBO_FRAME_SIZE
 #endif
 
@@ -619,7 +598,7 @@ enum ipg_regs {
  * Define larger if expecting jumbo frames.
  */
 #ifdef JUMBO_FRAME
-//4088=4096-8
+/* 4088 = 4096 - 8 */
 #define		IPG_RXFRAG_SIZE		__IPG_RXFRAG_SIZE
 #define     IPG_RXSUPPORT_SIZE   IPG_MAX_RXFRAME_SIZE
 #else
@@ -647,9 +626,9 @@ enum ipg_regs {
 #define		IPG_MINUSEDRFDSTOFREE	0x80
 
 /* specify the jumbo frame maximum size
- * per unit is 0x600 (the RxBuffer size that one RFD can carry)
+ * per unit is 0x600 (the rx_buffer size that one RFD can carry)
  */
-#define     MAX_JUMBOSIZE	        0x8	// max is 12K
+#define     MAX_JUMBOSIZE	        0x8	/* max is 12K */
 
 /* Key register values loaded at driver start up. */
 
@@ -753,8 +732,7 @@ enum ipg_regs {
  * Miscellaneous macros.
  */
 
-/* Marco for printing debug statements.
-#  define IPG_DDEBUG_MSG(args...) printk(KERN_DEBUG "IPG: " ## args) */
+/* Marco for printing debug statements. */
 #ifdef IPG_DEBUG
 #  define IPG_DEBUG_MSG(args...)
 #  define IPG_DDEBUG_MSG(args...) printk(KERN_DEBUG "IPG: " args)
@@ -789,11 +767,12 @@ struct ipg_rx {
 	__le64 frag_info;
 };
 
-struct SJumbo {
-	int FoundStart;
-	int CurrentSize;
+struct ipg_jumbo {
+	int found_start;
+	int current_size;
 	struct sk_buff *skb;
 };
+
 /* Structure of IPG NIC specific data. */
 struct ipg_nic_private {
 	void __iomem *ioaddr;
@@ -801,15 +780,14 @@ struct ipg_nic_private {
 	struct ipg_rx *rxd;
 	dma_addr_t txd_map;
 	dma_addr_t rxd_map;
-	struct sk_buff *TxBuff[IPG_TFDLIST_LENGTH];
-	struct sk_buff *RxBuff[IPG_RFDLIST_LENGTH];
+	struct sk_buff *tx_buff[IPG_TFDLIST_LENGTH];
+	struct sk_buff *rx_buff[IPG_RFDLIST_LENGTH];
 	unsigned int tx_current;
 	unsigned int tx_dirty;
 	unsigned int rx_current;
 	unsigned int rx_dirty;
-// Add by Grace 2005/05/19
 #ifdef JUMBO_FRAME
-	struct SJumbo Jumbo;
+	struct ipg_jumbo jumbo;
 #endif
 	unsigned int rx_buf_sz;
 	struct pci_dev *pdev;
@@ -818,13 +796,12 @@ struct ipg_nic_private {
 	spinlock_t lock;
 	int tenmbpsmode;
 
-	/*Jesse20040128EEPROM_VALUE */
-	u16 LED_Mode;
+	u16 led_mode;
 	u16 station_addr[3];	/* Station Address in EEPROM Reg 0x10..0x12 */
 
 	struct mutex		mii_mutex;
 	struct mii_if_info	mii_if;
-	int ResetCurrentTFD;
+	int reset_current_tfd;
 #ifdef IPG_DEBUG
 	int RFDlistendCount;
 	int RFDListCheckedCount;
-- 
Ueimor
