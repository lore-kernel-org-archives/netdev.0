From: akpm@linux-foundation.org
Subject: [patch 06/19] dmfe: trivial/spelling fixes
Date: Tue, 06 Mar 2007 02:41:51 -0800
Message-ID: <200703061041.l26Afpuf019750@shell0.pdx.osdl.net>
Cc: netdev@vger.kernel.org, akpm@linux-foundation.org,
	maximlevitsky@gmail.com, val_henson@linux.intel.com
To: jeff@garzik.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.osdl.org ([65.172.181.24]:34712 "EHLO smtp.osdl.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S934070AbXCFKmq (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 6 Mar 2007 05:42:46 -0500
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Maxim Levitsky <maximlevitsky@gmail.com>

Fix a typo, wrap lines on 80-th column, change KERN_ERR to KERN_INFO for
link status message

Signed-off-by: Maxim Levitsky <maximlevitsky@gmail.com>
Cc: Valerie Henson <val_henson@linux.intel.com>
Cc: Jeff Garzik <jeff@garzik.org>
Signed-off-by: Andrew Morton <akpm@linux-foundation.org>
---

 drivers/net/tulip/dmfe.c |  126 ++++++++++++++++++++++++++-----------
 1 file changed, 89 insertions(+), 37 deletions(-)

diff -puN drivers/net/tulip/dmfe.c~dmfe-trivial-spelling-fixes drivers/net/tulip/dmfe.c
--- a/drivers/net/tulip/dmfe.c~dmfe-trivial-spelling-fixes
+++ a/drivers/net/tulip/dmfe.c
@@ -143,9 +143,16 @@
 #define DMFE_TX_TIMEOUT ((3*HZ)/2)	/* tx packet time-out time 1.5 s" */
 #define DMFE_TX_KICK 	(HZ/2)	/* tx packet Kick-out time 0.5 s" */
 
-#define DMFE_DBUG(dbug_now, msg, value) if (dmfe_debug || (dbug_now)) printk(KERN_ERR DRV_NAME ": %s %lx\n", (msg), (long) (value))
-
-#define SHOW_MEDIA_TYPE(mode) printk(KERN_ERR DRV_NAME ": Change Speed to %sMhz %s duplex\n",mode & 1 ?"100":"10", mode & 4 ? "full":"half");
+#define DMFE_DBUG(dbug_now, msg, value) \
+	do { \
+ 		if (dmfe_debug || (dbug_now)) \
+			printk(KERN_ERR DRV_NAME ": %s %lx\n",\
+ 				(msg), (long) (value)); \
+	} while (0)
+
+#define SHOW_MEDIA_TYPE(mode) \
+	printk (KERN_INFO DRV_NAME ": Change Speed to %sMhz %s duplex\n" , \
+		(mode & 1) ? "100":"10", (mode & 4) ? "full":"half");
 
 
 /* CR9 definition: SROM/MII */
@@ -163,10 +170,20 @@
 
 #define SROM_V41_CODE   0x14
 
-#define SROM_CLK_WRITE(data, ioaddr) outl(data|CR9_SROM_READ|CR9_SRCS,ioaddr);udelay(5);outl(data|CR9_SROM_READ|CR9_SRCS|CR9_SRCLK,ioaddr);udelay(5);outl(data|CR9_SROM_READ|CR9_SRCS,ioaddr);udelay(5);
+#define SROM_CLK_WRITE(data, ioaddr) \
+	outl(data|CR9_SROM_READ|CR9_SRCS,ioaddr); \
+	udelay(5); \
+	outl(data|CR9_SROM_READ|CR9_SRCS|CR9_SRCLK,ioaddr); \
+	udelay(5); \
+	outl(data|CR9_SROM_READ|CR9_SRCS,ioaddr); \
+	udelay(5);
+
+#define __CHK_IO_SIZE(pci_id, dev_rev) \
+ (( ((pci_id)==PCI_DM9132_ID) || ((dev_rev) >= 0x02000030) ) ? \
+	DM9102A_IO_SIZE: DM9102_IO_SIZE)
 
-#define __CHK_IO_SIZE(pci_id, dev_rev) ( ((pci_id)==PCI_DM9132_ID) || ((dev_rev) >= 0x02000030) ) ? DM9102A_IO_SIZE: DM9102_IO_SIZE
-#define CHK_IO_SIZE(pci_dev, dev_rev) __CHK_IO_SIZE(((pci_dev)->device << 16) | (pci_dev)->vendor, dev_rev)
+#define CHK_IO_SIZE(pci_dev, dev_rev) \
+	(__CHK_IO_SIZE(((pci_dev)->device << 16) | (pci_dev)->vendor, dev_rev))
 
 /* Sten Check */
 #define DEVICE net_device
@@ -329,7 +346,7 @@ static void dmfe_program_DM9802(struct d
 static void dmfe_HPNA_remote_cmd_chk(struct dmfe_board_info * );
 static void dmfe_set_phyxcer(struct dmfe_board_info *);
 
-/* DM910X network baord routine ---------------------------- */
+/* DM910X network board routine ---------------------------- */
 
 /*
  *	Search DM910X board ,allocate space and register it
@@ -356,7 +373,8 @@ static int __devinit dmfe_init_one (stru
 	SET_NETDEV_DEV(dev, &pdev->dev);
 
 	if (pci_set_dma_mask(pdev, DMA_32BIT_MASK)) {
-		printk(KERN_WARNING DRV_NAME ": 32-bit PCI DMA not available.\n");
+		printk(KERN_WARNING DRV_NAME
+			": 32-bit PCI DMA not available.\n");
 		err = -ENODEV;
 		goto err_out_free;
 	}
@@ -400,8 +418,11 @@ static int __devinit dmfe_init_one (stru
 	db = netdev_priv(dev);
 
 	/* Allocate Tx/Rx descriptor memory */
-	db->desc_pool_ptr = pci_alloc_consistent(pdev, sizeof(struct tx_desc) * DESC_ALL_CNT + 0x20, &db->desc_pool_dma_ptr);
-	db->buf_pool_ptr = pci_alloc_consistent(pdev, TX_BUF_ALLOC * TX_DESC_CNT + 4, &db->buf_pool_dma_ptr);
+	db->desc_pool_ptr = pci_alloc_consistent(pdev, sizeof(struct tx_desc) *
+			DESC_ALL_CNT + 0x20, &db->desc_pool_dma_ptr);
+
+	db->buf_pool_ptr = pci_alloc_consistent(pdev, TX_BUF_ALLOC *
+			TX_DESC_CNT + 4, &db->buf_pool_dma_ptr);
 
 	db->first_tx_desc = (struct tx_desc *) db->desc_pool_ptr;
 	db->first_tx_desc_dma = db->desc_pool_dma_ptr;
@@ -437,7 +458,8 @@ static int __devinit dmfe_init_one (stru
 
 	/* read 64 word srom data */
 	for (i = 0; i < 64; i++)
-		((u16 *) db->srom)[i] = cpu_to_le16(read_srom_word(db->ioaddr, i));
+		((u16 *) db->srom)[i] =
+			cpu_to_le16(read_srom_word(db->ioaddr, i));
 
 	/* Set Node address */
 	for (i = 0; i < 6; i++)
@@ -506,7 +528,8 @@ static int dmfe_open(struct DEVICE *dev)
 
 	DMFE_DBUG(0, "dmfe_open", 0);
 
-	ret = request_irq(dev->irq, &dmfe_interrupt, IRQF_SHARED, dev->name, dev);
+	ret = request_irq(dev->irq, &dmfe_interrupt,
+			  IRQF_SHARED, dev->name, dev);
 	if (ret)
 		return ret;
 
@@ -647,7 +670,8 @@ static int dmfe_start_xmit(struct sk_buf
 	/* No Tx resource check, it never happen nromally */
 	if (db->tx_queue_cnt >= TX_FREE_DESC_CNT) {
 		spin_unlock_irqrestore(&db->lock, flags);
-		printk(KERN_ERR DRV_NAME ": No Tx resource %ld\n", db->tx_queue_cnt);
+		printk(KERN_ERR DRV_NAME ": No Tx resource %ld\n",
+		       db->tx_queue_cnt);
 		return 1;
 	}
 
@@ -719,7 +743,8 @@ static int dmfe_stop(struct DEVICE *dev)
 
 #if 0
 	/* show statistic counter */
-	printk(DRV_NAME ": FU:%lx EC:%lx LC:%lx NC:%lx LOC:%lx TXJT:%lx RESET:%lx RCR8:%lx FAL:%lx TT:%lx\n",
+	printk(DRV_NAME ": FU:%lx EC:%lx LC:%lx NC:%lx"
+		" LOC:%lx TXJT:%lx RESET:%lx RCR8:%lx FAL:%lx TT:%lx\n",
 		db->tx_fifo_underrun, db->tx_excessive_collision,
 		db->tx_late_collision, db->tx_no_carrier, db->tx_loss_carrier,
 		db->tx_jabber_timeout, db->reset_count, db->reset_cr8,
@@ -916,7 +941,9 @@ static void dmfe_rx_packet(struct DEVICE
 		db->rx_avail_cnt--;
 		db->interval_rx_cnt++;
 
-		pci_unmap_single(db->pdev, le32_to_cpu(rxptr->rdes2), RX_ALLOC_SIZE, PCI_DMA_FROMDEVICE);
+		pci_unmap_single(db->pdev, le32_to_cpu(rxptr->rdes2),
+				 RX_ALLOC_SIZE, PCI_DMA_FROMDEVICE);
+
 		if ( (rdes0 & 0x300) != 0x300) {
 			/* A packet without First/Last flag */
 			/* reuse this SKB */
@@ -1074,7 +1101,8 @@ static void dmfe_timer(unsigned long dat
 		if (db->chip_type && (db->chip_id==PCI_DM9102_ID)) {
 			db->cr6_data &= ~0x40000;
 			update_cr6(db->cr6_data, db->ioaddr);
-			phy_write(db->ioaddr, db->phy_addr, 0, 0x1000, db->chip_id);
+			phy_write(db->ioaddr,
+				  db->phy_addr, 0, 0x1000, db->chip_id);
 			db->cr6_data |= 0x40000;
 			update_cr6(db->cr6_data, db->ioaddr);
 			db->timer.expires = DMFE_TIMER_WUT + HZ * 2;
@@ -1148,7 +1176,8 @@ static void dmfe_timer(unsigned long dat
 		/* For Force 10/100M Half/Full mode: Enable Auto-Nego mode */
 		/* AUTO or force 1M Homerun/Longrun don't need */
 		if ( !(db->media_mode & 0x38) )
-			phy_write(db->ioaddr, db->phy_addr, 0, 0x1000, db->chip_id);
+			phy_write(db->ioaddr, db->phy_addr,
+				  0, 0x1000, db->chip_id);
 
 		/* AUTO mode, if INT phyxcer link failed, select EXT device */
 		if (db->media_mode & DMFE_AUTO) {
@@ -1252,7 +1281,8 @@ static void dmfe_reuse_skb(struct dmfe_b
 
 	if (!(rxptr->rdes0 & cpu_to_le32(0x80000000))) {
 		rxptr->rx_skb_ptr = skb;
-		rxptr->rdes2 = cpu_to_le32( pci_map_single(db->pdev, skb->data, RX_ALLOC_SIZE, PCI_DMA_FROMDEVICE) );
+		rxptr->rdes2 = cpu_to_le32( pci_map_single(db->pdev,
+			    skb->data, RX_ALLOC_SIZE, PCI_DMA_FROMDEVICE) );
 		wmb();
 		rxptr->rdes0 = cpu_to_le32(0x80000000);
 		db->rx_avail_cnt++;
@@ -1284,8 +1314,11 @@ static void dmfe_descriptor_init(struct 
 	outl(db->first_tx_desc_dma, ioaddr + DCR4);     /* TX DESC address */
 
 	/* rx descriptor start pointer */
-	db->first_rx_desc = (void *)db->first_tx_desc + sizeof(struct tx_desc) * TX_DESC_CNT;
-	db->first_rx_desc_dma =  db->first_tx_desc_dma + sizeof(struct tx_desc) * TX_DESC_CNT;
+	db->first_rx_desc = (void *)db->first_tx_desc +
+			sizeof(struct tx_desc) * TX_DESC_CNT;
+
+	db->first_rx_desc_dma =  db->first_tx_desc_dma +
+			sizeof(struct tx_desc) * TX_DESC_CNT;
 	db->rx_insert_ptr = db->first_rx_desc;
 	db->rx_ready_ptr = db->first_rx_desc;
 	outl(db->first_rx_desc_dma, ioaddr + DCR3);	/* RX DESC address */
@@ -1463,7 +1496,8 @@ static void allocate_rx_buffer(struct dm
 		if ( ( skb = dev_alloc_skb(RX_ALLOC_SIZE) ) == NULL )
 			break;
 		rxptr->rx_skb_ptr = skb; /* FIXME (?) */
-		rxptr->rdes2 = cpu_to_le32( pci_map_single(db->pdev, skb->data, RX_ALLOC_SIZE, PCI_DMA_FROMDEVICE) );
+		rxptr->rdes2 = cpu_to_le32( pci_map_single(db->pdev, skb->data,
+				    RX_ALLOC_SIZE, PCI_DMA_FROMDEVICE) );
 		wmb();
 		rxptr->rdes0 = cpu_to_le32(0x80000000);
 		rxptr = rxptr->next_rx_desc;
@@ -1503,7 +1537,8 @@ static u16 read_srom_word(long ioaddr, i
 	for (i = 16; i > 0; i--) {
 		outl(CR9_SROM_READ | CR9_SRCS | CR9_SRCLK, cr9_ioaddr);
 		udelay(5);
-		srom_data = (srom_data << 1) | ((inl(cr9_ioaddr) & CR9_CRDOUT) ? 1 : 0);
+		srom_data = (srom_data << 1) |
+				((inl(cr9_ioaddr) & CR9_CRDOUT) ? 1 : 0);
 		outl(CR9_SROM_READ | CR9_SRCS, cr9_ioaddr);
 		udelay(5);
 	}
@@ -1530,9 +1565,11 @@ static u8 dmfe_sense_speed(struct dmfe_b
 
 	if ( (phy_mode & 0x24) == 0x24 ) {
 		if (db->chip_id == PCI_DM9132_ID)	/* DM9132 */
-			phy_mode = phy_read(db->ioaddr, db->phy_addr, 7, db->chip_id) & 0xf000;
+			phy_mode = phy_read(db->ioaddr,
+				    db->phy_addr, 7, db->chip_id) & 0xf000;
 		else 				/* DM9102/DM9102A */
-			phy_mode = phy_read(db->ioaddr, db->phy_addr, 17, db->chip_id) & 0xf000;
+			phy_mode = phy_read(db->ioaddr,
+				    db->phy_addr, 17, db->chip_id) & 0xf000;
 		/* printk(DRV_NAME ": Phy_mode %x ",phy_mode); */
 		switch (phy_mode) {
 		case 0x1000: db->op_mode = DMFE_10MHF; break;
@@ -1569,8 +1606,11 @@ static void dmfe_set_phyxcer(struct dmfe
 
 	/* DM9009 Chip: Phyxcer reg18 bit12=0 */
 	if (db->chip_id == PCI_DM9009_ID) {
-		phy_reg = phy_read(db->ioaddr, db->phy_addr, 18, db->chip_id) & ~0x1000;
-		phy_write(db->ioaddr, db->phy_addr, 18, phy_reg, db->chip_id);
+		phy_reg = phy_read(db->ioaddr,
+				   db->phy_addr, 18, db->chip_id) & ~0x1000;
+
+		phy_write(db->ioaddr,
+			  db->phy_addr, 18, phy_reg, db->chip_id);
 	}
 
 	/* Phyxcer capability setting */
@@ -1643,10 +1683,12 @@ static void dmfe_process_mode(struct dmf
 			case DMFE_100MHF: phy_reg = 0x2000; break;
 			case DMFE_100MFD: phy_reg = 0x2100; break;
 			}
-			phy_write(db->ioaddr, db->phy_addr, 0, phy_reg, db->chip_id);
+			phy_write(db->ioaddr,
+				  db->phy_addr, 0, phy_reg, db->chip_id);
        			if ( db->chip_type && (db->chip_id == PCI_DM9102_ID) )
 				mdelay(20);
-			phy_write(db->ioaddr, db->phy_addr, 0, phy_reg, db->chip_id);
+			phy_write(db->ioaddr,
+				  db->phy_addr, 0, phy_reg, db->chip_id);
 		}
 	}
 }
@@ -1656,7 +1698,8 @@ static void dmfe_process_mode(struct dmf
  *	Write a word to Phy register
  */
 
-static void phy_write(unsigned long iobase, u8 phy_addr, u8 offset, u16 phy_data, u32 chip_id)
+static void phy_write(unsigned long iobase, u8 phy_addr, u8 offset,
+		      u16 phy_data, u32 chip_id)
 {
 	u16 i;
 	unsigned long ioaddr;
@@ -1682,11 +1725,13 @@ static void phy_write(unsigned long ioba
 
 		/* Send Phy address */
 		for (i = 0x10; i > 0; i = i >> 1)
-			phy_write_1bit(ioaddr, phy_addr & i ? PHY_DATA_1 : PHY_DATA_0);
+			phy_write_1bit(ioaddr,
+				       phy_addr & i ? PHY_DATA_1 : PHY_DATA_0);
 
 		/* Send register address */
 		for (i = 0x10; i > 0; i = i >> 1)
-			phy_write_1bit(ioaddr, offset & i ? PHY_DATA_1 : PHY_DATA_0);
+			phy_write_1bit(ioaddr,
+				       offset & i ? PHY_DATA_1 : PHY_DATA_0);
 
 		/* written trasnition */
 		phy_write_1bit(ioaddr, PHY_DATA_1);
@@ -1694,7 +1739,8 @@ static void phy_write(unsigned long ioba
 
 		/* Write a word data to PHY controller */
 		for ( i = 0x8000; i > 0; i >>= 1)
-			phy_write_1bit(ioaddr, phy_data & i ? PHY_DATA_1 : PHY_DATA_0);
+			phy_write_1bit(ioaddr,
+				       phy_data & i ? PHY_DATA_1 : PHY_DATA_0);
 	}
 }
 
@@ -1731,11 +1777,13 @@ static u16 phy_read(unsigned long iobase
 
 		/* Send Phy address */
 		for (i = 0x10; i > 0; i = i >> 1)
-			phy_write_1bit(ioaddr, phy_addr & i ? PHY_DATA_1 : PHY_DATA_0);
+			phy_write_1bit(ioaddr,
+				       phy_addr & i ? PHY_DATA_1 : PHY_DATA_0);
 
 		/* Send register address */
 		for (i = 0x10; i > 0; i = i >> 1)
-			phy_write_1bit(ioaddr, offset & i ? PHY_DATA_1 : PHY_DATA_0);
+			phy_write_1bit(ioaddr,
+				       offset & i ? PHY_DATA_1 : PHY_DATA_0);
 
 		/* Skip transition state */
 		phy_read_1bit(ioaddr);
@@ -1956,7 +2004,8 @@ static void dmfe_HPNA_remote_cmd_chk(str
 
 	/* Check remote device status match our setting ot not */
 	if ( phy_reg != (db->HPNA_command & 0x0f00) ) {
-		phy_write(db->ioaddr, db->phy_addr, 16, db->HPNA_command, db->chip_id);
+		phy_write(db->ioaddr, db->phy_addr, 16, db->HPNA_command,
+			  db->chip_id);
 		db->HPNA_timer=8;
 	} else
 		db->HPNA_timer=600;	/* Match, every 10 minutes, check */
@@ -1996,8 +2045,11 @@ module_param(HPNA_tx_cmd, byte, 0);
 module_param(HPNA_NoiseFloor, byte, 0);
 module_param(SF_mode, byte, 0);
 MODULE_PARM_DESC(debug, "Davicom DM9xxx enable debugging (0-1)");
-MODULE_PARM_DESC(mode, "Davicom DM9xxx: Bit 0: 10/100Mbps, bit 2: duplex, bit 8: HomePNA");
-MODULE_PARM_DESC(SF_mode, "Davicom DM9xxx special function (bit 0: VLAN, bit 1 Flow Control, bit 2: TX pause packet)");
+MODULE_PARM_DESC(mode, "Davicom DM9xxx: "
+		"Bit 0: 10/100Mbps, bit 2: duplex, bit 8: HomePNA");
+
+MODULE_PARM_DESC(SF_mode, "Davicom DM9xxx special function "
+		"(bit 0: VLAN, bit 1 Flow Control, bit 2: TX pause packet)");
 
 /*	Description:
  *	when user used insmod to add module, system invoked init_module()
_
