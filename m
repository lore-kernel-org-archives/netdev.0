From: Stephen Hemminger <shemminger@vyatta.com>
Subject: [PATCH 7/7] tlan: wrap source lines
Date: Fri, 30 May 2008 09:49:58 -0700
Message-ID: <20080530165033.967889904@vyatta.com>
References: <20080530164951.033143725@vyatta.com>
Cc: netdev@vger.kernel.org
To: Jeff Garzik <jgarzik@pobox.com>, Samuel Chessman <chessman@tux.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from suva.vyatta.com ([69.59.150.140]:34083 "EHLO suva.vyatta.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752045AbYE3QyC (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 30 May 2008 12:54:02 -0400
Content-Disposition: inline; filename=tlan-wrap.patch
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Make driver more readable on standard 80 col windows.

Signed-off-by: Stephen Hemminger <shemminger@vyatta.com>


--- a/drivers/net/tlan.c	2008-05-30 09:32:57.000000000 -0700
+++ b/drivers/net/tlan.c	2008-05-30 09:41:03.000000000 -0700
@@ -13,8 +13,6 @@
  *  This software may be used and distributed according to the terms
  *  of the GNU General Public License, incorporated herein by reference.
  *
- ** This file is best viewed/edited with columns>=132.
- *
  ** Useful (if not required) reading:
  *
  *		Texas Instruments, ThunderLAN Programmer's Guide,
@@ -236,9 +234,11 @@ static struct board {
 	{ "Compaq Netelligent 10 T PCI UTP", TLAN_ADAPTER_ACTIVITY_LED, 0x83 },
 	{ "Compaq Netelligent 10/100 TX PCI UTP", TLAN_ADAPTER_ACTIVITY_LED, 0x83 },
 	{ "Compaq Integrated NetFlex-3/P", TLAN_ADAPTER_NONE, 0x83 },
-	{ "Compaq NetFlex-3/P", TLAN_ADAPTER_UNMANAGED_PHY | TLAN_ADAPTER_BIT_RATE_PHY, 0x83 },
+	{ "Compaq NetFlex-3/P",
+	  TLAN_ADAPTER_UNMANAGED_PHY | TLAN_ADAPTER_BIT_RATE_PHY, 0x83 },
 	{ "Compaq NetFlex-3/P", TLAN_ADAPTER_NONE, 0x83 },
-	{ "Compaq Netelligent Integrated 10/100 TX UTP", TLAN_ADAPTER_ACTIVITY_LED, 0x83 },
+	{ "Compaq Netelligent Integrated 10/100 TX UTP",
+	  TLAN_ADAPTER_ACTIVITY_LED, 0x83 },
 	{ "Compaq Netelligent Dual 10/100 TX PCI UTP", TLAN_ADAPTER_NONE, 0x83 },
 	{ "Compaq Netelligent 10/100 TX Embedded UTP", TLAN_ADAPTER_NONE, 0x83 },
 	{ "Olicom OC-2183/2185", TLAN_ADAPTER_USE_INTERN_10, 0x83 },
@@ -246,8 +246,9 @@ static struct board {
 	{ "Olicom OC-2326", TLAN_ADAPTER_USE_INTERN_10, 0xF8 },
 	{ "Compaq Netelligent 10/100 TX UTP", TLAN_ADAPTER_ACTIVITY_LED, 0x83 },
 	{ "Compaq Netelligent 10 T/2 PCI UTP/Coax", TLAN_ADAPTER_NONE, 0x83 },
-	{ "Compaq NetFlex-3/E", TLAN_ADAPTER_ACTIVITY_LED | 	/* EISA card */
-	                        TLAN_ADAPTER_UNMANAGED_PHY | TLAN_ADAPTER_BIT_RATE_PHY, 0x83 },
+	{ "Compaq NetFlex-3/E",
+	  TLAN_ADAPTER_ACTIVITY_LED | 	/* EISA card */
+	  TLAN_ADAPTER_UNMANAGED_PHY | TLAN_ADAPTER_BIT_RATE_PHY, 0x83 },
 	{ "Compaq NetFlex-3/E", TLAN_ADAPTER_ACTIVITY_LED, 0x83 }, /* EISA card */
 };
 
@@ -292,7 +293,8 @@ static int	TLan_Close( struct net_device
 static struct	net_device_stats *TLan_GetStats( struct net_device *);
 static void	TLan_SetMulticastList( struct net_device *);
 static int	TLan_ioctl( struct net_device *dev, struct ifreq *rq, int cmd);
-static int      TLan_probe1( struct pci_dev *pdev, long ioaddr, int irq, int rev, const struct pci_device_id *ent);
+static int      TLan_probe1( struct pci_dev *pdev, long ioaddr,
+			     int irq, int rev, const struct pci_device_id *ent);
 static void	TLan_tx_timeout( struct net_device *dev);
 static void	TLan_tx_timeout_work(struct work_struct *work);
 static int 	tlan_init_one( struct pci_dev *pdev, const struct pci_device_id *ent);
@@ -439,7 +441,9 @@ static void __devexit tlan_remove_one( s
 	unregister_netdev( dev );
 
 	if ( priv->dmaStorage ) {
-		pci_free_consistent(priv->pciDev, priv->dmaSize, priv->dmaStorage, priv->dmaStorageDMA );
+		pci_free_consistent(priv->pciDev,
+				    priv->dmaSize, priv->dmaStorage,
+				    priv->dmaStorageDMA );
 	}
 
 #ifdef CONFIG_PCI
@@ -522,7 +526,8 @@ static int __devinit tlan_init_one( stru
 	 **************************************************************/
 
 static int __devinit TLan_probe1(struct pci_dev *pdev,
-				long ioaddr, int irq, int rev, const struct pci_device_id *ent )
+				 long ioaddr, int irq, int rev,
+				 const struct pci_device_id *ent )
 {
 
 	struct net_device  *dev;
@@ -608,8 +613,10 @@ static int __devinit TLan_probe1(struct 
 	/* Kernel parameters */
 	if (dev->mem_start) {
 		priv->aui    = dev->mem_start & 0x01;
-		priv->duplex = ((dev->mem_start & 0x06) == 0x06) ? 0 : (dev->mem_start & 0x06) >> 1;
-		priv->speed  = ((dev->mem_start & 0x18) == 0x18) ? 0 : (dev->mem_start & 0x18) >> 3;
+		priv->duplex = ((dev->mem_start & 0x06) == 0x06) ? 0
+			: (dev->mem_start & 0x06) >> 1;
+		priv->speed  = ((dev->mem_start & 0x18) == 0x18) ? 0
+			: (dev->mem_start & 0x18) >> 3;
 
 		if (priv->speed == 0x1) {
 			priv->speed = TLAN_SPEED_10;
@@ -689,7 +696,8 @@ static void TLan_Eisa_Cleanup(void)
 		dev = TLan_Eisa_Devices;
 		priv = netdev_priv(dev);
 		if (priv->dmaStorage) {
-			pci_free_consistent(priv->pciDev, priv->dmaSize, priv->dmaStorage, priv->dmaStorageDMA );
+			pci_free_consistent(priv->pciDev, priv->dmaSize,
+					    priv->dmaStorage, priv->dmaStorageDMA );
 		}
 		release_region( dev->base_addr, 0x10);
 		unregister_netdev( dev );
@@ -744,8 +752,10 @@ static void  __init TLan_EisaProbe (void
 	/* Loop through all slots of the EISA bus */
 	for (ioaddr = 0x1000; ioaddr < 0x9000; ioaddr += 0x1000) {
 
-	TLAN_DBG(TLAN_DEBUG_PROBE,"EISA_ID 0x%4x: 0x%4x\n", (int) ioaddr + 0xC80, inw(ioaddr + EISA_ID));
-	TLAN_DBG(TLAN_DEBUG_PROBE,"EISA_ID 0x%4x: 0x%4x\n", (int) ioaddr + 0xC82, inw(ioaddr + EISA_ID2));
+	TLAN_DBG(TLAN_DEBUG_PROBE,"EISA_ID 0x%4x: 0x%4x\n",
+		 (int) ioaddr + 0xC80, inw(ioaddr + EISA_ID));
+	TLAN_DBG(TLAN_DEBUG_PROBE,"EISA_ID 0x%4x: 0x%4x\n",
+		 (int) ioaddr + 0xC82, inw(ioaddr + EISA_ID2));
 
 
 		TLAN_DBG(TLAN_DEBUG_PROBE, "Probing for EISA adapter at IO: 0x%4x : ",
@@ -872,9 +882,12 @@ static int TLan_Init( struct net_device 
 
 	if ( bbuf ) {
 		priv->rxBuffer = (u8 *) ( priv->txList + TLAN_NUM_TX_LISTS );
-		priv->rxBufferDMA =priv->txListDMA + sizeof(TLanList) * TLAN_NUM_TX_LISTS;
-		priv->txBuffer = priv->rxBuffer + ( TLAN_NUM_RX_LISTS * TLAN_MAX_FRAME_SIZE );
-		priv->txBufferDMA = priv->rxBufferDMA + ( TLAN_NUM_RX_LISTS * TLAN_MAX_FRAME_SIZE );
+		priv->rxBufferDMA =priv->txListDMA
+			+ sizeof(TLanList) * TLAN_NUM_TX_LISTS;
+		priv->txBuffer = priv->rxBuffer
+			+ ( TLAN_NUM_RX_LISTS * TLAN_MAX_FRAME_SIZE );
+		priv->txBufferDMA = priv->rxBufferDMA
+			+ ( TLAN_NUM_RX_LISTS * TLAN_MAX_FRAME_SIZE );
 	}
 
 	err = 0;
@@ -938,7 +951,8 @@ static int TLan_Open( struct net_device 
 			   dev->name, dev );
 
 	if ( err ) {
-		printk(KERN_ERR "TLAN:  Cannot open %s because IRQ %d is already in use.\n", dev->name, dev->irq );
+		pr_err("TLAN:  Cannot open %s because IRQ %d is already in use.\n",
+		       dev->name, dev->irq );
 		return err;
 	}
 
@@ -952,7 +966,8 @@ static int TLan_Open( struct net_device 
 	TLan_ReadAndClearStats( dev, TLAN_IGNORE );
 	TLan_ResetAdapter( dev );
 
-	TLAN_DBG( TLAN_DEBUG_GNRL, "%s: Opened.  TLAN Chip Rev: %x\n", dev->name, priv->tlanRev );
+	TLAN_DBG( TLAN_DEBUG_GNRL, "%s: Opened.  TLAN Chip Rev: %x\n",
+		  dev->name, priv->tlanRev );
 
 	return 0;
 
@@ -990,14 +1005,16 @@ static int TLan_ioctl(struct net_device 
 
 
 	case SIOCGMIIREG:		/* Read MII PHY register. */
-			TLan_MiiReadReg(dev, data->phy_id & 0x1f, data->reg_num & 0x1f, &data->val_out);
+			TLan_MiiReadReg(dev, data->phy_id & 0x1f,
+					data->reg_num & 0x1f, &data->val_out);
 			return 0;
 
 
 	case SIOCSMIIREG:		/* Write MII PHY register. */
 			if (!capable(CAP_NET_ADMIN))
 				return -EPERM;
-			TLan_MiiWriteReg(dev, data->phy_id & 0x1f, data->reg_num & 0x1f, data->val_in);
+			TLan_MiiWriteReg(dev, data->phy_id & 0x1f,
+					 data->reg_num & 0x1f, data->val_in);
 			return 0;
 		default:
 			return -EOPNOTSUPP;
@@ -1082,7 +1099,8 @@ static int TLan_StartTx( struct sk_buff 
 	unsigned long	flags;
 
 	if ( ! priv->phyOnline ) {
-		TLAN_DBG( TLAN_DEBUG_TX, "TRANSMIT:  %s PHY is not ready\n", dev->name );
+		TLAN_DBG( TLAN_DEBUG_TX, "TRANSMIT:  %s PHY is not ready\n",
+			  dev->name );
 		dev_kfree_skb_any(skb);
 		return 0;
 	}
@@ -1094,7 +1112,9 @@ static int TLan_StartTx( struct sk_buff 
 	tail_list_phys = priv->txListDMA + sizeof(TLanList) * priv->txTail;
 
 	if ( tail_list->cStat != TLAN_CSTAT_UNUSED ) {
-		TLAN_DBG( TLAN_DEBUG_TX, "TRANSMIT:  %s is busy (Head=%d Tail=%d)\n", dev->name, priv->txHead, priv->txTail );
+		TLAN_DBG( TLAN_DEBUG_TX,
+			  "TRANSMIT:  %s is busy (Head=%d Tail=%d)\n",
+			  dev->name, priv->txHead, priv->txTail );
 		netif_stop_queue(dev);
 		priv->txBusyCount++;
 		return 1;
@@ -1106,7 +1126,9 @@ static int TLan_StartTx( struct sk_buff 
 		tail_buffer = priv->txBuffer + ( priv->txTail * TLAN_MAX_FRAME_SIZE );
 		skb_copy_from_linear_data(skb, tail_buffer, skb->len);
 	} else {
-		tail_list->buffer[0].address = pci_map_single(priv->pciDev, skb->data, skb->len, PCI_DMA_TODEVICE);
+		tail_list->buffer[0].address = pci_map_single(priv->pciDev,
+							      skb->data, skb->len,
+							      PCI_DMA_TODEVICE);
 		TLan_StoreSKB(tail_list, skb);
 	}
 
@@ -1119,15 +1141,19 @@ static int TLan_StartTx( struct sk_buff 
 	tail_list->cStat = TLAN_CSTAT_READY;
 	if ( ! priv->txInProgress ) {
 		priv->txInProgress = 1;
-		TLAN_DBG( TLAN_DEBUG_TX, "TRANSMIT:  Starting TX on buffer %d\n", priv->txTail );
+		TLAN_DBG( TLAN_DEBUG_TX,
+			  "TRANSMIT:  Starting TX on buffer %d\n", priv->txTail );
 		outl( tail_list_phys, dev->base_addr + TLAN_CH_PARM );
 		outl( TLAN_HC_GO, dev->base_addr + TLAN_HOST_CMD );
 	} else {
-		TLAN_DBG( TLAN_DEBUG_TX, "TRANSMIT:  Adding buffer %d to TX channel\n", priv->txTail );
+		TLAN_DBG( TLAN_DEBUG_TX, "TRANSMIT:  Adding buffer %d to TX channel\n",
+			  priv->txTail );
 		if ( priv->txTail == 0 ) {
-			( priv->txList + ( TLAN_NUM_TX_LISTS - 1 ) )->forward = tail_list_phys;
+			( priv->txList + ( TLAN_NUM_TX_LISTS - 1 ) )->forward
+				= tail_list_phys;
 		} else {
-			( priv->txList + ( priv->txTail - 1 ) )->forward = tail_list_phys;
+			( priv->txList + ( priv->txTail - 1 ) )->forward
+				= tail_list_phys;
 		}
 	}
 	spin_unlock_irqrestore(&priv->lock, flags);
@@ -1260,8 +1286,10 @@ static struct net_device_stats *TLan_Get
 	/* Should only read stats if open ? */
 	TLan_ReadAndClearStats( dev, TLAN_RECORD );
 
-	TLAN_DBG( TLAN_DEBUG_RX, "RECEIVE:  %s EOC count = %d\n", dev->name, priv->rxEocCount );
-	TLAN_DBG( TLAN_DEBUG_TX, "TRANSMIT:  %s Busy count = %d\n", dev->name, priv->txBusyCount );
+	TLAN_DBG( TLAN_DEBUG_RX, "RECEIVE:  %s EOC count = %d\n", dev->name,
+		  priv->rxEocCount );
+	TLAN_DBG( TLAN_DEBUG_TX, "TRANSMIT:  %s Busy count = %d\n", dev->name,
+		  priv->txBusyCount );
 	if ( debug & TLAN_DEBUG_GNRL ) {
 		TLan_PrintDio( dev->base_addr );
 		TLan_PhyPrint( dev );
@@ -1311,10 +1339,12 @@ static void TLan_SetMulticastList( struc
 
 	if ( dev->flags & IFF_PROMISC ) {
 		tmp = TLan_DioRead8( dev->base_addr, TLAN_NET_CMD );
-		TLan_DioWrite8( dev->base_addr, TLAN_NET_CMD, tmp | TLAN_NET_CMD_CAF );
+		TLan_DioWrite8( dev->base_addr,
+				TLAN_NET_CMD, tmp | TLAN_NET_CMD_CAF );
 	} else {
 		tmp = TLan_DioRead8( dev->base_addr, TLAN_NET_CMD );
-		TLan_DioWrite8( dev->base_addr, TLAN_NET_CMD, tmp & ~TLAN_NET_CMD_CAF );
+		TLan_DioWrite8( dev->base_addr,
+				TLAN_NET_CMD, tmp & ~TLAN_NET_CMD_CAF );
 		if ( dev->flags & IFF_ALLMULTI ) {
 			for ( i = 0; i < 3; i++ )
 				TLan_SetMac( dev, i + 1, NULL );
@@ -1323,7 +1353,8 @@ static void TLan_SetMulticastList( struc
 		} else {
 			for ( i = 0; i < dev->mc_count; i++ ) {
 				if ( i < 3 ) {
-					TLan_SetMac( dev, i + 1, (char *) &dmi->dmi_addr );
+					TLan_SetMac( dev, i + 1,
+						     (char *) &dmi->dmi_addr );
 				} else {
 					offset = TLan_HashFunc( (u8 *) &dmi->dmi_addr );
 					if ( offset < 32 )
@@ -1390,14 +1421,16 @@ static u32 TLan_HandleTxEOF( struct net_
 	u32		ack = 0;
 	u16		tmpCStat;
 
-	TLAN_DBG( TLAN_DEBUG_TX, "TRANSMIT:  Handling TX EOF (Head=%d Tail=%d)\n", priv->txHead, priv->txTail );
+	TLAN_DBG( TLAN_DEBUG_TX, "TRANSMIT:  Handling TX EOF (Head=%d Tail=%d)\n",
+		  priv->txHead, priv->txTail );
 	head_list = priv->txList + priv->txHead;
 
 	while (((tmpCStat = head_list->cStat ) & TLAN_CSTAT_FRM_CMP) && (ack < 255)) {
 		ack++;
 		if ( ! bbuf ) {
 			struct sk_buff *skb = TLan_GetSKB(head_list);
-			pci_unmap_single(priv->pciDev, head_list->buffer[0].address, skb->len, PCI_DMA_TODEVICE);
+			pci_unmap_single(priv->pciDev, head_list->buffer[0].address,
+					 skb->len, PCI_DMA_TODEVICE);
 			dev_kfree_skb_any(skb);
 			head_list->buffer[8].address = 0;
 			head_list->buffer[9].address = 0;
@@ -1418,7 +1451,9 @@ static u32 TLan_HandleTxEOF( struct net_
 		printk(KERN_INFO "TLAN: Received interrupt for uncompleted TX frame.\n");
 
 	if ( eoc ) {
-		TLAN_DBG( TLAN_DEBUG_TX, "TRANSMIT:  Handling TX EOC (Head=%d Tail=%d)\n", priv->txHead, priv->txTail );
+		TLAN_DBG( TLAN_DEBUG_TX,
+			  "TRANSMIT:  Handling TX EOC (Head=%d Tail=%d)\n",
+			  priv->txHead, priv->txTail );
 		head_list = priv->txList + priv->txHead;
 		head_list_phys = priv->txListDMA + sizeof(TLanList) * priv->txHead;
 		if ( ( head_list->cStat & TLAN_CSTAT_READY ) == TLAN_CSTAT_READY ) {
@@ -1430,7 +1465,8 @@ static u32 TLan_HandleTxEOF( struct net_
 	}
 
 	if ( priv->adapter->flags & TLAN_ADAPTER_ACTIVITY_LED ) {
-		TLan_DioWrite8( dev->base_addr, TLAN_LED_REG, TLAN_LED_LINK | TLAN_LED_ACT );
+		TLan_DioWrite8( dev->base_addr,
+				TLAN_LED_REG, TLAN_LED_LINK | TLAN_LED_ACT );
 		if ( priv->timer.function == NULL ) {
 			 priv->timer.function = &TLan_Timer;
 			 priv->timer.data = (unsigned long) dev;
@@ -1515,7 +1551,8 @@ static u32 TLan_HandleRxEOF( struct net_
 	u16		tmpCStat;
 	dma_addr_t	head_list_phys;
 
-	TLAN_DBG( TLAN_DEBUG_RX, "RECEIVE:  Handling RX EOF (Head=%d Tail=%d)\n", priv->rxHead, priv->rxTail );
+	TLAN_DBG( TLAN_DEBUG_RX, "RECEIVE:  Handling RX EOF (Head=%d Tail=%d)\n",
+		  priv->rxHead, priv->rxTail );
 	head_list = priv->rxList + priv->rxHead;
 	head_list_phys = priv->rxListDMA + sizeof(TLanList) * priv->rxHead;
 
@@ -1528,41 +1565,48 @@ static u32 TLan_HandleRxEOF( struct net_
 
 		if (bbuf) {
 			skb = netdev_alloc_skb(dev, frameSize + 7);
-			if ( skb ) {
-				head_buffer = priv->rxBuffer + (priv->rxHead * TLAN_MAX_FRAME_SIZE);
-				skb_reserve(skb, 2);
-				pci_dma_sync_single_for_cpu(priv->pciDev,
-							    frameDma, frameSize,
-							    PCI_DMA_FROMDEVICE);
-				skb_copy_from_linear_data(skb, head_buffer, frameSize);
-				skb_put(skb, frameSize);
-				dev->stats.rx_bytes += frameSize;
+			if ( !skb )
+				goto drop_and_reuse;
 
-				skb->protocol = eth_type_trans( skb, dev );
-				netif_rx( skb );
-			}
+			head_buffer = priv->rxBuffer
+				+ (priv->rxHead * TLAN_MAX_FRAME_SIZE);
+			skb_reserve(skb, 2);
+			pci_dma_sync_single_for_cpu(priv->pciDev,
+						    frameDma, frameSize,
+						    PCI_DMA_FROMDEVICE);
+			skb_copy_from_linear_data(skb, head_buffer, frameSize);
+			skb_put(skb, frameSize);
+			dev->stats.rx_bytes += frameSize;
+
+			skb->protocol = eth_type_trans( skb, dev );
+			netif_rx( skb );
 		} else {
 			struct sk_buff *new_skb;
 
 			new_skb = netdev_alloc_skb(dev, TLAN_MAX_FRAME_SIZE + 7 );
-			if ( new_skb ) {
-				skb = TLan_GetSKB(head_list);
-				pci_unmap_single(priv->pciDev, frameDma, TLAN_MAX_FRAME_SIZE, PCI_DMA_FROMDEVICE);
-				skb_put( skb, frameSize );
+			if ( !new_skb )
+				goto drop_and_reuse;
 
-				dev->stats.rx_bytes += frameSize;
+			skb = TLan_GetSKB(head_list);
+			pci_unmap_single(priv->pciDev, frameDma,
+					 TLAN_MAX_FRAME_SIZE, PCI_DMA_FROMDEVICE);
+			skb_put( skb, frameSize );
 
-				skb->protocol = eth_type_trans( skb, dev );
-				netif_rx( skb );
+			dev->stats.rx_bytes += frameSize;
 
-				skb_reserve( new_skb, NET_IP_ALIGN );
-				head_list->buffer[0].address = pci_map_single(priv->pciDev, new_skb->data, TLAN_MAX_FRAME_SIZE, PCI_DMA_FROMDEVICE);
+			skb->protocol = eth_type_trans( skb, dev );
+			netif_rx( skb );
 
-				TLan_StoreSKB(head_list, new_skb);
-			}
+			skb_reserve( new_skb, NET_IP_ALIGN );
+			head_list->buffer[0].address = pci_map_single(priv->pciDev,
+								      new_skb->data,
+								      TLAN_MAX_FRAME_SIZE,
+								      PCI_DMA_FROMDEVICE);
 
-		}
+			TLan_StoreSKB(head_list, new_skb);
 
+		}
+drop_and_reuse:
 		head_list->forward = 0;
 		head_list->cStat = 0;
 		tail_list = priv->rxList + priv->rxTail;
@@ -1578,10 +1622,10 @@ static u32 TLan_HandleRxEOF( struct net_
 		printk(KERN_INFO "TLAN: Received interrupt for uncompleted RX frame.\n");
 
 
-
-
 	if ( eoc ) {
-		TLAN_DBG( TLAN_DEBUG_RX, "RECEIVE:  Handling RX EOC (Head=%d Tail=%d)\n", priv->rxHead, priv->rxTail );
+		TLAN_DBG( TLAN_DEBUG_RX,
+			  "RECEIVE:  Handling RX EOC (Head=%d Tail=%d)\n",
+			  priv->rxHead, priv->rxTail );
 		head_list = priv->rxList + priv->rxHead;
 		head_list_phys = priv->rxListDMA + sizeof(TLanList) * priv->rxHead;
 		outl(head_list_phys, dev->base_addr + TLAN_CH_PARM );
@@ -1590,7 +1634,8 @@ static u32 TLan_HandleRxEOF( struct net_
 	}
 
 	if ( priv->adapter->flags & TLAN_ADAPTER_ACTIVITY_LED ) {
-		TLan_DioWrite8( dev->base_addr, TLAN_LED_REG, TLAN_LED_LINK | TLAN_LED_ACT );
+		TLan_DioWrite8( dev->base_addr,
+				TLAN_LED_REG, TLAN_LED_LINK | TLAN_LED_ACT );
 		if ( priv->timer.function == NULL )  {
 			priv->timer.function = &TLan_Timer;
 			priv->timer.data = (unsigned long) dev;
@@ -1668,7 +1713,9 @@ static u32 TLan_HandleTxEOC( struct net_
 
 	host_int = 0;
 	if ( priv->tlanRev < 0x30 ) {
-		TLAN_DBG( TLAN_DEBUG_TX, "TRANSMIT:  Handling TX EOC (Head=%d Tail=%d) -- IRQ\n", priv->txHead, priv->txTail );
+		TLAN_DBG( TLAN_DEBUG_TX,
+			  "TRANSMIT:  Handling TX EOC (Head=%d Tail=%d) -- IRQ\n",
+			  priv->txHead, priv->txTail );
 		head_list = priv->txList + priv->txHead;
 		head_list_phys = priv->txListDMA + sizeof(TLanList) * priv->txHead;
 		if ( ( head_list->cStat & TLAN_CSTAT_READY ) == TLAN_CSTAT_READY ) {
@@ -1736,15 +1783,18 @@ static u32 TLan_HandleStatusCheck( struc
 		net_sts = TLan_DioRead8( dev->base_addr, TLAN_NET_STS );
 		if ( net_sts ) {
 			TLan_DioWrite8( dev->base_addr, TLAN_NET_STS, net_sts );
-			TLAN_DBG( TLAN_DEBUG_GNRL, "%s:    Net_Sts = %x\n", dev->name, (unsigned) net_sts );
+			TLAN_DBG( TLAN_DEBUG_GNRL, "%s:    Net_Sts = %x\n",
+				  dev->name, (unsigned) net_sts );
 		}
 		if ( ( net_sts & TLAN_NET_STS_MIRQ ) &&  ( priv->phyNum == 0 ) ) {
 			TLan_MiiReadReg( dev, phy, TLAN_TLPHY_STS, &tlphy_sts );
 			TLan_MiiReadReg( dev, phy, TLAN_TLPHY_CTL, &tlphy_ctl );
-        		if ( ! ( tlphy_sts & TLAN_TS_POLOK ) && ! ( tlphy_ctl & TLAN_TC_SWAPOL ) ) {
+        		if ( ! ( tlphy_sts & TLAN_TS_POLOK ) &&
+			     ! ( tlphy_ctl & TLAN_TC_SWAPOL ) ) {
                 		tlphy_ctl |= TLAN_TC_SWAPOL;
                 		TLan_MiiWriteReg( dev, phy, TLAN_TLPHY_CTL, tlphy_ctl);
-        		} else if ( ( tlphy_sts & TLAN_TS_POLOK ) && ( tlphy_ctl & TLAN_TC_SWAPOL ) ) {
+        		} else if ( ( tlphy_sts & TLAN_TS_POLOK )
+				    && ( tlphy_ctl & TLAN_TC_SWAPOL ) ) {
                 		tlphy_ctl &= ~TLAN_TC_SWAPOL;
                 		TLan_MiiWriteReg( dev, phy, TLAN_TLPHY_CTL, tlphy_ctl);
         		}
@@ -1789,7 +1839,9 @@ static u32 TLan_HandleRxEOC( struct net_
 	u32		ack = 1;
 
 	if (  priv->tlanRev < 0x30 ) {
-		TLAN_DBG( TLAN_DEBUG_RX, "RECEIVE:  Handling RX EOC (Head=%d Tail=%d) -- IRQ\n", priv->rxHead, priv->rxTail );
+		TLAN_DBG( TLAN_DEBUG_RX,
+			  "RECEIVE:  Handling RX EOC (Head=%d Tail=%d) -- IRQ\n",
+			  priv->rxHead, priv->rxTail );
 		head_list_phys = priv->rxListDMA + sizeof(TLanList) * priv->rxHead;
 		outl( head_list_phys, dev->base_addr + TLAN_CH_PARM );
 		ack |= TLAN_HC_GO | TLAN_HC_RT;
@@ -1880,10 +1932,12 @@ static void TLan_Timer( unsigned long da
 			if ( priv->timer.function == NULL ) {
 				elapsed = jiffies - priv->timerSetAt;
 				if ( elapsed >= TLAN_TIMER_ACT_DELAY ) {
-					TLan_DioWrite8( dev->base_addr, TLAN_LED_REG, TLAN_LED_LINK );
+					TLan_DioWrite8( dev->base_addr,
+							TLAN_LED_REG, TLAN_LED_LINK );
 				} else  {
 					priv->timer.function = &TLan_Timer;
-					priv->timer.expires = priv->timerSetAt + TLAN_TIMER_ACT_DELAY;
+					priv->timer.expires = priv->timerSetAt
+						+ TLAN_TIMER_ACT_DELAY;
 					spin_unlock_irqrestore(&priv->lock, flags);
 					add_timer( &priv->timer );
 					break;
@@ -1938,7 +1992,8 @@ static void TLan_ResetLists( struct net_
 		list = priv->txList + i;
 		list->cStat = TLAN_CSTAT_UNUSED;
 		if ( bbuf ) {
-			list->buffer[0].address = priv->txBufferDMA + ( i * TLAN_MAX_FRAME_SIZE );
+			list->buffer[0].address = priv->txBufferDMA
+				+ ( i * TLAN_MAX_FRAME_SIZE );
 		} else {
 			list->buffer[0].address = 0;
 		}
@@ -1957,16 +2012,19 @@ static void TLan_ResetLists( struct net_
 		list->frameSize = TLAN_MAX_FRAME_SIZE;
 		list->buffer[0].count = TLAN_MAX_FRAME_SIZE | TLAN_LAST_BUFFER;
 		if ( bbuf ) {
-			list->buffer[0].address = priv->rxBufferDMA + ( i * TLAN_MAX_FRAME_SIZE );
+			list->buffer[0].address = priv->rxBufferDMA
+				+ ( i * TLAN_MAX_FRAME_SIZE );
 		} else {
 			skb = netdev_alloc_skb(dev, TLAN_MAX_FRAME_SIZE + 7 );
 			if ( !skb ) {
-				printk( "TLAN:  Couldn't allocate memory for received data.\n" );
+				pr_err("TLAN: out of memory for received data.\n" );
 				break;
 			}
 
 			skb_reserve( skb, NET_IP_ALIGN );
-			list->buffer[0].address = pci_map_single(priv->pciDev, t, TLAN_MAX_FRAME_SIZE, PCI_DMA_FROMDEVICE);
+			list->buffer[0].address = pci_map_single(priv->pciDev, t,
+								 TLAN_MAX_FRAME_SIZE,
+								 PCI_DMA_FROMDEVICE);
 			TLan_StoreSKB(list, skb);
 		}
 		list->buffer[1].count = 0;
@@ -1996,7 +2054,9 @@ static void TLan_FreeLists( struct net_d
 			list = priv->txList + i;
 			skb = TLan_GetSKB(list);
 			if ( skb ) {
-				pci_unmap_single(priv->pciDev, list->buffer[0].address, skb->len, PCI_DMA_TODEVICE);
+				pci_unmap_single(priv->pciDev,
+						 list->buffer[0].address, skb->len,
+						 PCI_DMA_TODEVICE);
 				dev_kfree_skb_any( skb );
 				list->buffer[8].address = 0;
 				list->buffer[9].address = 0;
@@ -2007,7 +2067,10 @@ static void TLan_FreeLists( struct net_d
 			list = priv->rxList + i;
 			skb = TLan_GetSKB(list);
 			if ( skb ) {
-				pci_unmap_single(priv->pciDev, list->buffer[0].address, TLAN_MAX_FRAME_SIZE, PCI_DMA_FROMDEVICE);
+				pci_unmap_single(priv->pciDev,
+						 list->buffer[0].address,
+						 TLAN_MAX_FRAME_SIZE,
+						 PCI_DMA_FROMDEVICE);
 				dev_kfree_skb_any( skb );
 				list->buffer[8].address = 0;
 				list->buffer[9].address = 0;
@@ -2038,7 +2101,8 @@ static void TLan_PrintDio( u16 io_base )
 	u32 data0, data1;
 	int	i;
 
-	printk( "TLAN:   Contents of internal registers for io base 0x%04hx.\n", io_base );
+	printk( "TLAN:   Contents of internal registers for io base 0x%04hx.\n",
+		io_base );
 	printk( "TLAN:      Off.  +0         +4\n" );
 	for ( i = 0; i < 0x4C; i+= 8 ) {
 		data0 = TLan_DioRead32( io_base, i );
@@ -2078,7 +2142,8 @@ static void TLan_PrintList( TLanList *li
 	printk( "TLAN:      Frame Size = 0x%04hx\n", list->frameSize );
 	/* for ( i = 0; i < 10; i++ ) { */
 	for ( i = 0; i < 2; i++ ) {
-		printk( "TLAN:      Buffer[%d].count, addr = 0x%08x, 0x%08x\n", i, list->buffer[i].count, list->buffer[i].address );
+		printk( "TLAN:      Buffer[%d].count, addr = 0x%08x, 0x%08x\n",
+			i, list->buffer[i].count, list->buffer[i].address );
 	}
 
 } /* TLan_PrintList */
@@ -2294,14 +2359,16 @@ TLan_FinishReset( struct net_device *dev
 	TLan_MiiReadReg( dev, phy, MII_GEN_ID_HI, &tlphy_id1 );
 	TLan_MiiReadReg( dev, phy, MII_GEN_ID_LO, &tlphy_id2 );
 
-	if ( ( priv->adapter->flags & TLAN_ADAPTER_UNMANAGED_PHY ) || ( priv->aui ) ) {
+	if ( ( priv->adapter->flags & TLAN_ADAPTER_UNMANAGED_PHY ) ||
+	     ( priv->aui ) ) {
 		status = MII_GS_LINK;
 		printk( "TLAN:  %s: Link forced.\n", dev->name );
 	} else {
 		TLan_MiiReadReg( dev, phy, MII_GEN_STS, &status );
 		udelay( 1000 );
 		TLan_MiiReadReg( dev, phy, MII_GEN_STS, &status );
-		if ( (status & MII_GS_LINK) &&	 /* We only support link info on Nat.Sem. PHY's */
+		if ( (status & MII_GS_LINK) &&
+		     /* We only support link info on Nat.Sem. PHY's */
 			(tlphy_id1 == NAT_SEM_ID1) &&
 			(tlphy_id2 == NAT_SEM_ID2) ) {
 			TLan_MiiReadReg( dev, phy, MII_AN_LPA, &partner );
@@ -2310,12 +2377,12 @@ TLan_FinishReset( struct net_device *dev
 			printk( "TLAN: %s: Link active with ", dev->name );
 			if (!(tlphy_par & TLAN_PHY_AN_EN_STAT)) {
 			      	 printk( "forced 10%sMbps %s-Duplex\n",
-						tlphy_par & TLAN_PHY_SPEED_100 ? "" : "0",
-						tlphy_par & TLAN_PHY_DUPLEX_FULL ? "Full" : "Half");
+					 tlphy_par & TLAN_PHY_SPEED_100 ? "" : "0",
+					 tlphy_par & TLAN_PHY_DUPLEX_FULL ? "Full" : "Half");
 			} else {
 				printk( "AutoNegotiation enabled, at 10%sMbps %s-Duplex\n",
-						tlphy_par & TLAN_PHY_SPEED_100 ? "" : "0",
-						tlphy_par & TLAN_PHY_DUPLEX_FULL ? "Full" : "Half");
+					tlphy_par & TLAN_PHY_SPEED_100 ? "" : "0",
+					tlphy_par & TLAN_PHY_DUPLEX_FULL ? "Full" : "Half");
 				printk("TLAN: Partner capability: ");
 					for (i = 5; i <= 10; i++)
 						if (partner & (1<<i))
@@ -2356,7 +2423,8 @@ TLan_FinishReset( struct net_device *dev
 		outl( TLAN_HC_GO | TLAN_HC_RT, dev->base_addr + TLAN_HOST_CMD );
 		netif_carrier_on(dev);
 	} else {
-		printk( "TLAN: %s: Link inactive, will retry in 10 secs...\n", dev->name );
+		printk( "TLAN: %s: Link inactive, will retry in 10 secs...\n",
+			dev->name );
 		TLan_SetTimer( dev, (10*HZ), TLAN_TIMER_FINISH_RESET );
 		return;
 	}
@@ -2396,10 +2464,12 @@ static void TLan_SetMac( struct net_devi
 
 	if ( mac != NULL ) {
 		for ( i = 0; i < 6; i++ )
-			TLan_DioWrite8( dev->base_addr, TLAN_AREG_0 + areg + i, mac[i] );
+			TLan_DioWrite8( dev->base_addr,
+					TLAN_AREG_0 + areg + i, mac[i] );
 	} else {
 		for ( i = 0; i < 6; i++ )
-			TLan_DioWrite8( dev->base_addr, TLAN_AREG_0 + areg + i, 0 );
+			TLan_DioWrite8( dev->base_addr,
+					TLAN_AREG_0 + areg + i, 0 );
 	}
 
 } /* TLan_SetMac */
@@ -2505,9 +2575,13 @@ static void TLan_PhyDetect( struct net_d
 		TLan_MiiReadReg( dev, phy, MII_GEN_CTL, &control );
 		TLan_MiiReadReg( dev, phy, MII_GEN_ID_HI, &hi );
 		TLan_MiiReadReg( dev, phy, MII_GEN_ID_LO, &lo );
-		if ( ( control != 0xFFFF ) || ( hi != 0xFFFF ) || ( lo != 0xFFFF ) ) {
-			TLAN_DBG( TLAN_DEBUG_GNRL, "PHY found at %02x %04x %04x %04x\n", phy, control, hi, lo );
-			if ( ( priv->phy[1] == TLAN_PHY_NONE ) && ( phy != TLAN_PHY_MAX_ADDR ) ) {
+		if ( ( control != 0xFFFF ) ||
+		     ( hi != 0xFFFF ) || ( lo != 0xFFFF ) ) {
+			TLAN_DBG( TLAN_DEBUG_GNRL,
+				  "PHY found at %02x %04x %04x %04x\n",
+				  phy, control, hi, lo );
+			if ( ( priv->phy[1] == TLAN_PHY_NONE ) &&
+			     ( phy != TLAN_PHY_MAX_ADDR ) ) {
 				priv->phy[1] = phy;
 			}
 		}
@@ -2535,7 +2609,9 @@ static void TLan_PhyPowerDown( struct ne
 	value = MII_GC_PDOWN | MII_GC_LOOPBK | MII_GC_ISOLATE;
 	TLan_MiiSync( dev->base_addr );
 	TLan_MiiWriteReg( dev, priv->phy[priv->phyNum], MII_GEN_CTL, value );
-	if ( ( priv->phyNum == 0 ) && ( priv->phy[1] != TLAN_PHY_NONE ) && ( ! ( priv->adapter->flags & TLAN_ADAPTER_USE_INTERN_10 ) ) ) {
+	if ( ( priv->phyNum == 0 ) &&
+	     ( priv->phy[1] != TLAN_PHY_NONE ) &&
+	     ( ! ( priv->adapter->flags & TLAN_ADAPTER_USE_INTERN_10 ) ) ) {
 		TLan_MiiSync( dev->base_addr );
 		TLan_MiiWriteReg( dev, priv->phy[1], MII_GEN_CTL, value );
 	}
@@ -2708,10 +2784,10 @@ static void TLan_PhyFinishAutoNeg( struc
 		 * more time.  Perhaps we should fail after a while.
 		 */
 		 if (!priv->neg_be_verbose++) {
-			 printk(KERN_INFO "TLAN:  Giving autonegotiation more time.\n");
-		 	 printk(KERN_INFO "TLAN:  Please check that your adapter has\n");
-		 	 printk(KERN_INFO "TLAN:  been properly connected to a HUB or Switch.\n");
-			 printk(KERN_INFO "TLAN:  Trying to establish link in the background...\n");
+			 pr_info("TLAN:  Giving autonegotiation more time.\n");
+		 	 pr_info("TLAN:  Please check that your adapter has\n");
+		 	 pr_info("TLAN:  been properly connected to a HUB or Switch.\n");
+			 pr_info("TLAN:  Trying to establish link in the background...\n");
 		 }
 		TLan_SetTimer( dev, (8*HZ), TLAN_TIMER_PHY_FINISH_AN );
 		return;
@@ -2727,7 +2803,9 @@ static void TLan_PhyFinishAutoNeg( struc
 		priv->tlanFullDuplex = TRUE;
 	}
 
-	if ( ( ! ( mode & 0x0180 ) ) && ( priv->adapter->flags & TLAN_ADAPTER_USE_INTERN_10 ) && ( priv->phyNum != 0 ) ) {
+	if ( ( ! ( mode & 0x0180 ) ) &&
+	     ( priv->adapter->flags & TLAN_ADAPTER_USE_INTERN_10 ) &&
+	     ( priv->phyNum != 0 ) ) {
 		priv->phyNum = 0;
 		data = TLAN_NET_CFG_1FRAG | TLAN_NET_CFG_1CHAN | TLAN_NET_CFG_PHY_EN;
 		TLan_DioWrite16( dev->base_addr, TLAN_NET_CONFIG, data );
@@ -2736,12 +2814,14 @@ static void TLan_PhyFinishAutoNeg( struc
 	}
 
 	if ( priv->phyNum == 0 ) {
-		if ( ( priv->duplex == TLAN_DUPLEX_FULL ) || ( an_adv & an_lpa & 0x0040 ) ) {
-			TLan_MiiWriteReg( dev, phy, MII_GEN_CTL, MII_GC_AUTOENB | MII_GC_DUPLEX );
-			printk( "TLAN:  Starting internal PHY with FULL-DUPLEX\n" );
+		if ( ( priv->duplex == TLAN_DUPLEX_FULL ) ||
+		     ( an_adv & an_lpa & 0x0040 ) ) {
+			TLan_MiiWriteReg( dev, phy, MII_GEN_CTL,
+					  MII_GC_AUTOENB | MII_GC_DUPLEX );
+			pr_info("TLAN:  Starting internal PHY with FULL-DUPLEX\n" );
 		} else {
 			TLan_MiiWriteReg( dev, phy, MII_GEN_CTL, MII_GC_AUTOENB );
-			printk( "TLAN:  Starting internal PHY with HALF-DUPLEX\n" );
+			pr_info( "TLAN:  Starting internal PHY with HALF-DUPLEX\n" );
 		}
 	}
 
@@ -3149,7 +3229,8 @@ static int TLan_EeSendByte( u16 io_base,
 	TLan_SetBit( TLAN_NET_SIO_ETXEN, sio );
 
 	if ( ( ! err ) && stop ) {
-		TLan_ClearBit( TLAN_NET_SIO_EDATA, sio );	/* STOP, raise data while clock is high */
+		/* STOP, raise data while clock is high */
+		TLan_ClearBit( TLAN_NET_SIO_EDATA, sio );
 		TLan_SetBit( TLAN_NET_SIO_ECLOK, sio );
 		TLan_SetBit( TLAN_NET_SIO_EDATA, sio );
 	}
@@ -3212,7 +3293,8 @@ static void TLan_EeReceiveByte( u16 io_b
 		TLan_SetBit( TLAN_NET_SIO_EDATA, sio );		/* No ack = 1 (?) */
 		TLan_SetBit( TLAN_NET_SIO_ECLOK, sio );
 		TLan_ClearBit( TLAN_NET_SIO_ECLOK, sio );
-		TLan_ClearBit( TLAN_NET_SIO_EDATA, sio );	/* STOP, raise data while clock is high */
+		/* STOP, raise data while clock is high */
+		TLan_ClearBit( TLAN_NET_SIO_EDATA, sio );
 		TLan_SetBit( TLAN_NET_SIO_ECLOK, sio );
 		TLan_SetBit( TLAN_NET_SIO_EDATA, sio );
 	}
--- a/drivers/net/tlan.h	2008-05-30 09:38:23.000000000 -0700
+++ b/drivers/net/tlan.h	2008-05-30 09:41:32.000000000 -0700
@@ -13,8 +13,6 @@
  *  This software may be used and distributed according to the terms
  *  of the GNU General Public License, incorporated herein by reference.
  *
- ** This file is best viewed/edited with tabstop=4, colums>=132
- *
  *
  *  Dec 10, 1999	Torben Mathiasen <torben.mathiasen@compaq.com>
  *			New Maintainer
@@ -45,7 +43,9 @@
 #define TLAN_IGNORE		0
 #define TLAN_RECORD		1
 
-#define TLAN_DBG(lvl, format, args...)	if (debug&lvl) printk(KERN_DEBUG "TLAN: " format, ##args );
+#define TLAN_DBG(lvl, format, args...)	\
+	do { if (debug&lvl) printk(KERN_DEBUG "TLAN: " format, ##args ); } while(0)
+
 #define TLAN_DEBUG_GNRL		0x0001
 #define TLAN_DEBUG_TX		0x0002
 #define TLAN_DEBUG_RX		0x0004
@@ -515,12 +515,18 @@ static inline void TLan_DioWrite32(u16 b
  * 	xor( a, xor( b, xor( c, xor( d, xor( e, xor( f, xor( g, h ) ) ) ) ) ) )
  * #define DA( a, bit )		( ( (u8) a[bit/8] ) & ( (u8) ( 1 << bit%8 ) ) )
  *
- * 	hash  = XOR8( DA(a,0), DA(a, 6), DA(a,12), DA(a,18), DA(a,24), DA(a,30), DA(a,36), DA(a,42) );
- * 	hash |= XOR8( DA(a,1), DA(a, 7), DA(a,13), DA(a,19), DA(a,25), DA(a,31), DA(a,37), DA(a,43) ) << 1;
- * 	hash |= XOR8( DA(a,2), DA(a, 8), DA(a,14), DA(a,20), DA(a,26), DA(a,32), DA(a,38), DA(a,44) ) << 2;
- * 	hash |= XOR8( DA(a,3), DA(a, 9), DA(a,15), DA(a,21), DA(a,27), DA(a,33), DA(a,39), DA(a,45) ) << 3;
- * 	hash |= XOR8( DA(a,4), DA(a,10), DA(a,16), DA(a,22), DA(a,28), DA(a,34), DA(a,40), DA(a,46) ) << 4;
- * 	hash |= XOR8( DA(a,5), DA(a,11), DA(a,17), DA(a,23), DA(a,29), DA(a,35), DA(a,41), DA(a,47) ) << 5;
+ * 	hash  = XOR8( DA(a,0), DA(a, 6), DA(a,12), DA(a,18), DA(a,24),
+ * 	              DA(a,30), DA(a,36), DA(a,42) );
+ * 	hash |= XOR8( DA(a,1), DA(a, 7), DA(a,13), DA(a,19), DA(a,25),
+ * 		      DA(a,31), DA(a,37), DA(a,43) ) << 1;
+ * 	hash |= XOR8( DA(a,2), DA(a, 8), DA(a,14), DA(a,20), DA(a,26),
+ * 		      DA(a,32), DA(a,38), DA(a,44) ) << 2;
+ * 	hash |= XOR8( DA(a,3), DA(a, 9), DA(a,15), DA(a,21), DA(a,27),
+ * 		      DA(a,33), DA(a,39), DA(a,45) ) << 3;
+ * 	hash |= XOR8( DA(a,4), DA(a,10), DA(a,16), DA(a,22), DA(a,28),
+ * 	              DA(a,34), DA(a,40), DA(a,46) ) << 4;
+ * 	hash |= XOR8( DA(a,5), DA(a,11), DA(a,17), DA(a,23), DA(a,29),
+ * 	              DA(a,35), DA(a,41), DA(a,47) ) << 5;
  *
  */
 static inline u32 TLan_HashFunc( const u8 *a )

-- 

