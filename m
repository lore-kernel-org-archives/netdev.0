From: Pekka J Enberg <penberg@cs.helsinki.fi>
Subject: [PATCH 7/8] ipg: naming convention fixes
Date: Fri, 23 Nov 2007 10:20:04 +0200 (EET)
Message-ID: <Pine.LNX.4.64.0711231019500.18378@sbz-30.cs.Helsinki.FI>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
To: romieu@fr.zoreil.com, sorbica@icplus.com.tw, jesse@icplus.com.tw,
	netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from courier.cs.helsinki.fi ([128.214.9.1]:42513 "EHLO
	mail.cs.helsinki.fi" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752428AbXKWIUF (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 23 Nov 2007 03:20:05 -0500
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Pekka Enberg <penberg@cs.helsinki.fi>

This changes some camel-case names to follow proper kernel naming convention.

Cc: Francois Romieu <romieu@fr.zoreil.com>
Cc: Sorbica Shieh <sorbica@icplus.com.tw>
Cc: Jesse Huang <jesse@icplus.com.tw>
Signed-off-by: Pekka Enberg <penberg@cs.helsinki.fi>
---
 drivers/net/ipg.c |  174 +++++++++++++++++++++++++++---------------------------
 drivers/net/ipg.h |   19 +++--
 2 files changed, 97 insertions(+), 96 deletions(-)

Index: linux-2.6/drivers/net/ipg.c
===================================================================
--- linux-2.6.orig/drivers/net/ipg.c
+++ linux-2.6/drivers/net/ipg.c
@@ -382,13 +382,13 @@ static void ipg_set_led_mode(struct net_
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
@@ -402,7 +402,7 @@ static void ipg_set_phy_set(struct net_d
 
 	physet = ipg_r8(PHY_SET);
 	physet &= ~(IPG_PS_MEM_LENB9B | IPG_PS_MEM_LEN9 | IPG_PS_NON_COMPDET);
-	physet |= ((sp->LED_Mode & 0x70) >> 4);
+	physet |= ((sp->led_mode & 0x70) >> 4);
 	ipg_w8(physet, PHY_SET);
 }
 
@@ -733,7 +733,7 @@ static int ipg_get_rxbuff(struct net_dev
 
 	skb = netdev_alloc_skb(dev, IPG_RXSUPPORT_SIZE + NET_IP_ALIGN);
 	if (!skb) {
-		sp->RxBuff[entry] = NULL;
+		sp->rx_buff[entry] = NULL;
 		return -ENOMEM;
 	}
 
@@ -746,7 +746,7 @@ static int ipg_get_rxbuff(struct net_dev
 	skb->dev = dev;
 
 	/* Save the address of the sk_buff structure. */
-	sp->RxBuff[entry] = skb;
+	sp->rx_buff[entry] = skb;
 
 	rxfd->frag_info = cpu_to_le64(pci_map_single(sp->pdev, skb->data,
 		sp->rx_buf_sz, PCI_DMA_FROMDEVICE));
@@ -769,12 +769,12 @@ static int init_rfdlist(struct net_devic
 	for (i = 0; i < IPG_RFDLIST_LENGTH; i++) {
 		struct ipg_rx *rxfd = sp->rxd + i;
 
-		if (sp->RxBuff[i]) {
+		if (sp->rx_buff[i]) {
 			pci_unmap_single(sp->pdev,
 				le64_to_cpu(rxfd->frag_info) & ~IPG_RFI_FRAGLEN,
 				sp->rx_buf_sz, PCI_DMA_FROMDEVICE);
-			dev_kfree_skb_irq(sp->RxBuff[i]);
-			sp->RxBuff[i] = NULL;
+			dev_kfree_skb_irq(sp->rx_buff[i]);
+			sp->rx_buff[i] = NULL;
 		}
 
 		/* Clear out the RFS field. */
@@ -825,9 +825,9 @@ static void init_tfdlist(struct net_devi
 
 		txfd->tfc = cpu_to_le64(IPG_TFC_TFDDONE);
 
-		if (sp->TxBuff[i]) {
-			dev_kfree_skb_irq(sp->TxBuff[i]);
-			sp->TxBuff[i] = NULL;
+		if (sp->tx_buff[i]) {
+			dev_kfree_skb_irq(sp->tx_buff[i]);
+			sp->tx_buff[i] = NULL;
 		}
 
 		txfd->next_desc = cpu_to_le64(sp->txd_map +
@@ -844,7 +844,7 @@ static void init_tfdlist(struct net_devi
 	ipg_w32((u32) sp->txd_map, TFD_LIST_PTR_0);
 	ipg_w32(0x00000000, TFD_LIST_PTR_1);
 
-	sp->ResetCurrentTFD = 1;
+	sp->reset_current_tfd = 1;
 }
 
 /*
@@ -869,7 +869,7 @@ static void ipg_nic_txfree(struct net_de
 
 	for (released = 0; released < pending; released++) {
 		unsigned int dirty = sp->tx_dirty % IPG_TFDLIST_LENGTH;
-		struct sk_buff *skb = sp->TxBuff[dirty];
+		struct sk_buff *skb = sp->tx_buff[dirty];
 		struct ipg_tx *txfd = sp->txd + dirty;
 
 		IPG_DEBUG_MSG("TFC = %16.16lx\n", (unsigned long) txfd->tfc);
@@ -893,7 +893,7 @@ static void ipg_nic_txfree(struct net_de
 
 			dev_kfree_skb_irq(skb);
 
-			sp->TxBuff[dirty] = NULL;
+			sp->tx_buff[dirty] = NULL;
 		}
 	}
 
@@ -1065,7 +1065,7 @@ static int ipg_nic_rxrestore(struct net_
 		unsigned int entry = dirty % IPG_RFDLIST_LENGTH;
 
 		/* rx_copybreak may poke hole here and there. */
-		if (sp->RxBuff[entry])
+		if (sp->rx_buff[entry])
 			continue;
 
 		/* Generate a new receive buffer to replace the
@@ -1096,15 +1096,15 @@ static int ipg_nic_rxrestore(struct net_
                 previous receiving and need to continue dumping the current one
 */
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
@@ -1112,14 +1112,14 @@ inline void ipg_nic_rx_free_skb(struct n
 	struct ipg_nic_private *sp = netdev_priv(dev);
 	unsigned int entry = sp->rx_current % IPG_RFDLIST_LENGTH;
 
-	if (sp->RxBuff[entry]) {
+	if (sp->rx_buff[entry]) {
 		struct ipg_rx *rxfd = sp->rxd + entry;
 
 		pci_unmap_single(sp->pdev,
 			le64_to_cpu(rxfd->frag_info & ~IPG_RFI_FRAGLEN),
 			sp->rx_buf_sz, PCI_DMA_FROMDEVICE);
-		dev_kfree_skb_irq(sp->RxBuff[entry]);
-		sp->RxBuff[entry] = NULL;
+		dev_kfree_skb_irq(sp->rx_buff[entry]);
+		sp->rx_buff[entry] = NULL;
 	}
 }
 
@@ -1127,12 +1127,12 @@ inline int ipg_nic_rx_check_frame_type(s
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
 
@@ -1181,39 +1181,39 @@ inline int ipg_nic_rx_check_error(struct
 		 * buffer since it is erroneous and we will
 		 * not pass it to higher layer processes.
 		 */
-		if (sp->RxBuff[entry]) {
+		if (sp->rx_buff[entry]) {
 			pci_unmap_single(sp->pdev,
 				le64_to_cpu(rxfd->frag_info & ~IPG_RFI_FRAGLEN),
 				sp->rx_buf_sz, PCI_DMA_FROMDEVICE);
 
-			dev_kfree_skb_irq(sp->RxBuff[entry]);
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
+	if (jumbo->found_start) {
 		dev_kfree_skb_irq(jumbo->skb);
-		jumbo->FoundStart = 0;
-		jumbo->CurrentSize = 0;
+		jumbo->found_start = 0;
+		jumbo->current_size = 0;
 		jumbo->skb = NULL;
 	}
 
 	// 1: found error, 0 no error
-	if (ipg_nic_rx_check_error(dev) != NormalPacket)
+	if (ipg_nic_rx_check_error(dev) != NORMAL_PACKET)
 		return;
 
-	skb = sp->RxBuff[entry];
+	skb = sp->rx_buff[entry];
 	if (!skb)
 		return;
 
@@ -1227,27 +1227,27 @@ static void ipg_nic_rx_with_start_and_en
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
 
 	// 1: found error, 0 no error
-	if (ipg_nic_rx_check_error(dev) != NormalPacket)
+	if (ipg_nic_rx_check_error(dev) != NORMAL_PACKET)
 		return;
 
 	// accept this frame and send to upper layer
-	skb = sp->RxBuff[entry];
+	skb = sp->rx_buff[entry];
 	if (!skb)
 		return;
 
-	if (jumbo->FoundStart)
+	if (jumbo->found_start)
 		dev_kfree_skb_irq(jumbo->skb);
 
 	pci_unmap_single(pdev, le64_to_cpu(rxfd->frag_info & ~IPG_RFI_FRAGLEN),
@@ -1255,11 +1255,11 @@ static void ipg_nic_rx_with_start(struct
 
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
 
@@ -1267,21 +1267,21 @@ static void ipg_nic_rx_with_end(struct n
 				struct ipg_nic_private *sp,
 				struct ipg_rx *rxfd, unsigned entry)
 {
-	struct SJumbo *jumbo = &sp->Jumbo;
+	struct ipg_jumbo *jumbo = &sp->jumbo;
 
 	//1: found error, 0 no error
-	if (ipg_nic_rx_check_error(dev) == NormalPacket) {
-		struct sk_buff *skb = sp->RxBuff[entry];
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
@@ -1301,15 +1301,15 @@ static void ipg_nic_rx_with_end(struct n
 		}
 
 		dev->last_rx = jiffies;
-		jumbo->FoundStart = 0;
-		jumbo->CurrentSize = 0;
+		jumbo->found_start = 0;
+		jumbo->current_size = 0;
 		jumbo->skb = NULL;
 
 		ipg_nic_rx_free_skb(dev);
 	} else {
 		dev_kfree_skb_irq(jumbo->skb);
-		jumbo->FoundStart = 0;
-		jumbo->CurrentSize = 0;
+		jumbo->found_start = 0;
+		jumbo->current_size = 0;
 		jumbo->skb = NULL;
 	}
 }
@@ -1318,16 +1318,16 @@ static void ipg_nic_rx_no_start_no_end(s
 				       struct ipg_nic_private *sp,
 				       struct ipg_rx *rxfd, unsigned entry)
 {
-	struct SJumbo *jumbo = &sp->Jumbo;
+	struct ipg_jumbo *jumbo = &sp->jumbo;
 
 	//1: found error, 0 no error
-	if (ipg_nic_rx_check_error(dev) == NormalPacket) {
-		struct sk_buff *skb = sp->RxBuff[entry];
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
@@ -1338,8 +1338,8 @@ static void ipg_nic_rx_no_start_no_end(s
 		}
 	} else {
 		dev_kfree_skb_irq(jumbo->skb);
-		jumbo->FoundStart = 0;
-		jumbo->CurrentSize = 0;
+		jumbo->found_start = 0;
+		jumbo->current_size = 0;
 		jumbo->skb = NULL;
 	}
 }
@@ -1361,16 +1361,16 @@ static int ipg_nic_rx(struct net_device 
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
@@ -1409,7 +1409,7 @@ static int ipg_nic_rx(struct net_device 
 
 	for (i = 0; i < IPG_MAXRFDPROCESS_COUNT; i++, curr++) {
 		unsigned int entry = curr % IPG_RFDLIST_LENGTH;
-		struct sk_buff *skb = sp->RxBuff[entry];
+		struct sk_buff *skb = sp->rx_buff[entry];
 		unsigned int framelen;
 
 		rxfd = sp->rxd + entry;
@@ -1511,7 +1511,7 @@ static int ipg_nic_rx(struct net_device 
 		}
 
 		/* Assure RX buffer is not reused by IPG. */
-		sp->RxBuff[entry] = NULL;
+		sp->rx_buff[entry] = NULL;
 	}
 
 	/*
@@ -1545,15 +1545,15 @@ static int ipg_nic_rx(struct net_device 
 		 * buffer since it is erroneous and we will
 		 * not pass it to higher layer processes.
 		 */
-		if (sp->RxBuff[entry]) {
+		if (sp->rx_buff[entry]) {
 			pci_unmap_single(sp->pdev,
 				le64_to_cpu(rxfd->frag_info) & ~IPG_RFI_FRAGLEN,
 				sp->rx_buf_sz, PCI_DMA_FROMDEVICE);
-			dev_kfree_skb_irq(sp->RxBuff[entry]);
+			dev_kfree_skb_irq(sp->rx_buff[entry]);
 		}
 
 		/* Assure RX buffer is not reused by IPG. */
-		sp->RxBuff[entry] = NULL;
+		sp->rx_buff[entry] = NULL;
 	}
 
 	sp->rx_current = curr;
@@ -1719,11 +1719,11 @@ static void ipg_rx_clear(struct ipg_nic_
 	unsigned int i;
 
 	for (i = 0; i < IPG_RFDLIST_LENGTH; i++) {
-		if (sp->RxBuff[i]) {
+		if (sp->rx_buff[i]) {
 			struct ipg_rx *rxfd = sp->rxd + i;
 
-			dev_kfree_skb_irq(sp->RxBuff[i]);
-			sp->RxBuff[i] = NULL;
+			dev_kfree_skb_irq(sp->rx_buff[i]);
+			sp->rx_buff[i] = NULL;
 			pci_unmap_single(sp->pdev,
 				le64_to_cpu(rxfd->frag_info) & ~IPG_RFI_FRAGLEN,
 				sp->rx_buf_sz, PCI_DMA_FROMDEVICE);
@@ -1736,16 +1736,16 @@ static void ipg_tx_clear(struct ipg_nic_
 	unsigned int i;
 
 	for (i = 0; i < IPG_TFDLIST_LENGTH; i++) {
-		if (sp->TxBuff[i]) {
+		if (sp->tx_buff[i]) {
 			struct ipg_tx *txfd = sp->txd + i;
 
 			pci_unmap_single(sp->pdev,
 				le64_to_cpu(txfd->frag_info) & ~IPG_TFI_FRAGLEN,
-				sp->TxBuff[i]->len, PCI_DMA_TODEVICE);
+				sp->tx_buff[i]->len, PCI_DMA_TODEVICE);
 
-			dev_kfree_skb_irq(sp->TxBuff[i]);
+			dev_kfree_skb_irq(sp->tx_buff[i]);
 
-			sp->TxBuff[i] = NULL;
+			sp->tx_buff[i] = NULL;
 		}
 	}
 }
@@ -1816,9 +1816,9 @@ static int ipg_nic_open(struct net_devic
 
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
 
@@ -1893,14 +1893,14 @@ static int ipg_nic_hard_start_xmit(struc
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
@@ -2084,7 +2084,7 @@ static int ipg_hw_init(struct net_device
 
 	/* Read/Write and Reset EEPROM Value */
 	/* Read LED Mode Configuration from EEPROM */
-	sp->LED_Mode = read_eeprom(dev, 6);
+	sp->led_mode = read_eeprom(dev, 6);
 
 	/* Reset all functions within the IPG. Do not assert
 	 * RST_OUT as not compatible with some PHYs.
Index: linux-2.6/drivers/net/ipg.h
===================================================================
--- linux-2.6.orig/drivers/net/ipg.h
+++ linux-2.6/drivers/net/ipg.h
@@ -626,7 +626,7 @@ enum ipg_regs {
 #define		IPG_MINUSEDRFDSTOFREE	0x80
 
 /* specify the jumbo frame maximum size
- * per unit is 0x600 (the RxBuffer size that one RFD can carry)
+ * per unit is 0x600 (the rx_buffer size that one RFD can carry)
  */
 #define     MAX_JUMBOSIZE	        0x8	// max is 12K
 
@@ -767,11 +767,12 @@ struct ipg_rx {
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
@@ -779,14 +780,14 @@ struct ipg_nic_private {
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
 #ifdef JUMBO_FRAME
-	struct SJumbo Jumbo;
+	struct ipg_jumbo jumbo;
 #endif
 	unsigned int rx_buf_sz;
 	struct pci_dev *pdev;
@@ -795,12 +796,12 @@ struct ipg_nic_private {
 	spinlock_t lock;
 	int tenmbpsmode;
 
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
