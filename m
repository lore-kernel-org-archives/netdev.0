From: Joe Perches <joe@perches.com>
Subject: [PATCH 20/21] drivers/net/tlan: use pr_<level> and add pr_fmt(fmt)
Date: Sun,  4 Oct 2009 17:53:47 -0700
Message-ID: <d4468c1b062875f4b88ba94f4631232ecff9c27b.1254701151.git.joe@perches.com>
References: <cover.1254701151.git.joe@perches.com>
Cc: Samuel Chessman <chessman@tux.org>, netdev@vger.kernel.org
To: linux-kernel@vger.kernel.org
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1758326AbZJEAzs@vger.kernel.org>
In-Reply-To: <cover.1254701151.git.joe@perches.com>
In-Reply-To: <cover.1254701151.git.joe@perches.com>
References: <cover.1254701151.git.joe@perches.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Added #define pr_fmt(fmt) KBUILD_MODNAME ": " fmt
Converted printk(KERN_<level> to pr_<level>(
Removed "TLAN: " prefixes

Signed-off-by: Joe Perches <joe@perches.com>
---
 drivers/net/tlan.c |  135 ++++++++++++++++++++++++++--------------------------
 1 files changed, 68 insertions(+), 67 deletions(-)

diff --git a/drivers/net/tlan.c b/drivers/net/tlan.c
index 3d31b47..9527a84 100644
--- a/drivers/net/tlan.c
+++ b/drivers/net/tlan.c
@@ -170,6 +170,8 @@
  *
  *******************************************************************************/
 
+#define pr_fmt(fmt) KBUILD_MODNAME ": " fmt
+
 #include <linux/module.h>
 #include <linux/init.h>
 #include <linux/ioport.h>
@@ -468,7 +470,7 @@ static int __init tlan_probe(void)
 {
 	int rc = -ENODEV;
 
-	printk(KERN_INFO "%s", tlan_banner);
+	pr_info("%s", tlan_banner);
 
 	TLAN_DBG(TLAN_DEBUG_PROBE, "Starting PCI Probe....\n");
 
@@ -477,16 +479,16 @@ static int __init tlan_probe(void)
 	rc = pci_register_driver(&tlan_driver);
 
 	if (rc != 0) {
-		printk(KERN_ERR "TLAN: Could not register pci driver.\n");
+		pr_err("Could not register pci driver.\n");
 		goto err_out_pci_free;
 	}
 
 	TLAN_DBG(TLAN_DEBUG_PROBE, "Starting EISA Probe....\n");
 	TLan_EisaProbe();
 
-	printk(KERN_INFO "TLAN: %d device%s installed, PCI: %d  EISA: %d\n",
-		 TLanDevicesInstalled, TLanDevicesInstalled == 1 ? "" : "s",
-		 tlan_have_pci, tlan_have_eisa);
+	pr_info("%d device%s installed, PCI: %d  EISA: %d\n",
+		TLanDevicesInstalled, TLanDevicesInstalled == 1 ? "" : "s",
+		tlan_have_pci, tlan_have_eisa);
 
 	if (TLanDevicesInstalled == 0) {
 		rc = -ENODEV;
@@ -545,7 +547,7 @@ static int __devinit TLan_probe1(struct pci_dev *pdev,
 
 		rc = pci_request_regions(pdev, TLanSignature);
 		if (rc) {
-			printk(KERN_ERR "TLAN: Could not reserve IO regions\n");
+			pr_err("Could not reserve IO regions\n");
 			goto err_out;
 		}
 	}
@@ -553,7 +555,7 @@ static int __devinit TLan_probe1(struct pci_dev *pdev,
 
 	dev = alloc_etherdev(sizeof(TLanPrivateInfo));
 	if (dev == NULL) {
-		printk(KERN_ERR "TLAN: Could not allocate memory for device.\n");
+		pr_err("Could not allocate memory for device.\n");
 		rc = -ENOMEM;
 		goto err_out_regions;
 	}
@@ -572,7 +574,7 @@ static int __devinit TLan_probe1(struct pci_dev *pdev,
 
 		rc = pci_set_dma_mask(pdev, DMA_BIT_MASK(32));
 		if (rc) {
-			printk(KERN_ERR "TLAN: No suitable PCI mapping available.\n");
+			pr_err("No suitable PCI mapping available.\n");
 			goto err_out_free_dev;
 		}
 
@@ -585,7 +587,7 @@ static int __devinit TLan_probe1(struct pci_dev *pdev,
 			}
 		}
 		if (!pci_io_base) {
-			printk(KERN_ERR "TLAN: No IO mappings available\n");
+			pr_err("No IO mappings available\n");
 			rc = -EIO;
 			goto err_out_free_dev;
 		}
@@ -641,13 +643,13 @@ static int __devinit TLan_probe1(struct pci_dev *pdev,
 
 	rc = TLan_Init(dev);
 	if (rc) {
-		printk(KERN_ERR "TLAN: Could not set up device.\n");
+		pr_err("Could not set up device.\n");
 		goto err_out_free_dev;
 	}
 
 	rc = register_netdev(dev);
 	if (rc) {
-		printk(KERN_ERR "TLAN: Could not register device.\n");
+		pr_err("Could not register device.\n");
 		goto err_out_uninit;
 	}
 
@@ -664,12 +666,12 @@ static int __devinit TLan_probe1(struct pci_dev *pdev,
 		tlan_have_eisa++;
 	}
 
-	printk(KERN_INFO "TLAN: %s irq=%2d, io=%04x, %s, Rev. %d\n",
-			dev->name,
-			(int) dev->irq,
-			(int) dev->base_addr,
-			priv->adapter->deviceLabel,
-			priv->adapterRev);
+	pr_info("%s irq=%2d, io=%04x, %s, Rev. %d\n",
+		dev->name,
+		(int)dev->irq,
+		(int)dev->base_addr,
+		priv->adapter->deviceLabel,
+		priv->adapterRev);
 	return 0;
 
 err_out_uninit:
@@ -882,8 +884,8 @@ static int TLan_Init( struct net_device *dev )
 	priv->dmaSize = dma_size;
 
 	if ( priv->dmaStorage == NULL ) {
-		printk(KERN_ERR "TLAN:  Could not allocate lists and buffers for %s.\n",
-			dev->name );
+		pr_err("Could not allocate lists and buffers for %s.\n",
+		       dev->name);
 		return -ENOMEM;
 	}
 	memset( priv->dmaStorage, 0, dma_size );
@@ -898,9 +900,8 @@ static int TLan_Init( struct net_device *dev )
 					(u8) priv->adapter->addrOfs + i,
 					(u8 *) &dev->dev_addr[i] );
 	if ( err ) {
-		printk(KERN_ERR "TLAN: %s: Error reading MAC from eeprom: %d\n",
-			dev->name,
-			err );
+		pr_err("%s: Error reading MAC from eeprom: %d\n",
+		       dev->name, err);
 	}
 	dev->addr_len = 6;
 
@@ -944,8 +945,8 @@ static int TLan_Open( struct net_device *dev )
 			   dev->name, dev );
 
 	if ( err ) {
-		pr_err("TLAN:  Cannot open %s because IRQ %d is already in use.\n",
-		       dev->name, dev->irq );
+		pr_err("Cannot open %s because IRQ %d is already in use.\n",
+		       dev->name, dev->irq);
 		return err;
 	}
 
@@ -1433,7 +1434,7 @@ static u32 TLan_HandleTxEOF( struct net_device *dev, u16 host_int )
 	}
 
 	if (!ack)
-		printk(KERN_INFO "TLAN: Received interrupt for uncompleted TX frame.\n");
+		pr_info("Received interrupt for uncompleted TX frame.\n");
 
 	if ( eoc ) {
 		TLAN_DBG( TLAN_DEBUG_TX,
@@ -1583,7 +1584,7 @@ drop_and_reuse:
 	}
 
 	if (!ack)
-		printk(KERN_INFO "TLAN: Received interrupt for uncompleted RX frame.\n");
+		pr_info("Received interrupt for uncompleted RX frame.\n");
 
 
 	if ( eoc ) {
@@ -1638,7 +1639,7 @@ drop_and_reuse:
 
 static u32 TLan_HandleDummy( struct net_device *dev, u16 host_int )
 {
-	printk( "TLAN:  Test interrupt on %s.\n", dev->name );
+	pr_info("Test interrupt on %s.\n", dev->name);
 	return 1;
 
 } /* TLan_HandleDummy */
@@ -1730,7 +1731,7 @@ static u32 TLan_HandleStatusCheck( struct net_device *dev, u16 host_int )
 	if ( host_int & TLAN_HI_IV_MASK ) {
 		netif_stop_queue( dev );
 		error = inl( dev->base_addr + TLAN_CH_PARM );
-		printk( "TLAN:  %s: Adaptor Error = 0x%x\n", dev->name, error );
+		pr_info("%s: Adaptor Error = 0x%x\n", dev->name, error);
 		TLan_ReadAndClearStats( dev, TLAN_RECORD );
 		outl( TLAN_HC_AD_RST, dev->base_addr + TLAN_HOST_CMD );
 
@@ -1969,7 +1970,7 @@ static void TLan_ResetLists( struct net_device *dev )
 		list->buffer[0].count = TLAN_MAX_FRAME_SIZE | TLAN_LAST_BUFFER;
 		skb = netdev_alloc_skb(dev, TLAN_MAX_FRAME_SIZE + 7 );
 		if ( !skb ) {
-			pr_err("TLAN: out of memory for received data.\n" );
+			pr_err("out of memory for received data.\n");
 			break;
 		}
 
@@ -2054,13 +2055,13 @@ static void TLan_PrintDio( u16 io_base )
 	u32 data0, data1;
 	int	i;
 
-	printk( "TLAN:   Contents of internal registers for io base 0x%04hx.\n",
-		io_base );
-	printk( "TLAN:      Off.  +0         +4\n" );
+	pr_info("Contents of internal registers for io base 0x%04hx.\n",
+		io_base);
+	pr_info("   Off.  +0         +4\n");
 	for ( i = 0; i < 0x4C; i+= 8 ) {
 		data0 = TLan_DioRead32( io_base, i );
 		data1 = TLan_DioRead32( io_base, i + 0x4 );
-		printk( "TLAN:      0x%02x  0x%08x 0x%08x\n", i, data0, data1 );
+		pr_info("   0x%02x  0x%08x 0x%08x\n", i, data0, data1);
 	}
 
 } /* TLan_PrintDio */
@@ -2089,14 +2090,14 @@ static void TLan_PrintList( TLanList *list, char *type, int num)
 {
 	int i;
 
-	printk( "TLAN:   %s List %d at %p\n", type, num, list );
-	printk( "TLAN:      Forward    = 0x%08x\n",  list->forward );
-	printk( "TLAN:      CSTAT      = 0x%04hx\n", list->cStat );
-	printk( "TLAN:      Frame Size = 0x%04hx\n", list->frameSize );
+	pr_info("%s List %d at %p\n", type, num, list);
+	pr_info("   Forward    = 0x%08x\n",  list->forward);
+	pr_info("   CSTAT      = 0x%04hx\n", list->cStat);
+	pr_info("   Frame Size = 0x%04hx\n", list->frameSize);
 	/* for ( i = 0; i < 10; i++ ) { */
 	for ( i = 0; i < 2; i++ ) {
-		printk( "TLAN:      Buffer[%d].count, addr = 0x%08x, 0x%08x\n",
-			i, list->buffer[i].count, list->buffer[i].address );
+		pr_info("   Buffer[%d].count, addr = 0x%08x, 0x%08x\n",
+			i, list->buffer[i].count, list->buffer[i].address);
 	}
 
 } /* TLan_PrintList */
@@ -2315,7 +2316,7 @@ TLan_FinishReset( struct net_device *dev )
 	if ( ( priv->adapter->flags & TLAN_ADAPTER_UNMANAGED_PHY ) ||
 	     ( priv->aui ) ) {
 		status = MII_GS_LINK;
-		printk( "TLAN:  %s: Link forced.\n", dev->name );
+		pr_info("%s: Link forced.\n", dev->name);
 	} else {
 		TLan_MiiReadReg( dev, phy, MII_GEN_STS, &status );
 		udelay( 1000 );
@@ -2327,7 +2328,7 @@ TLan_FinishReset( struct net_device *dev )
 			TLan_MiiReadReg( dev, phy, MII_AN_LPA, &partner );
 			TLan_MiiReadReg( dev, phy, TLAN_TLPHY_PAR, &tlphy_par );
 
-			printk( "TLAN: %s: Link active with ", dev->name );
+			pr_info("%s: Link active with ", dev->name);
 			if (!(tlphy_par & TLAN_PHY_AN_EN_STAT)) {
 			      	 printk( "forced 10%sMbps %s-Duplex\n",
 					 tlphy_par & TLAN_PHY_SPEED_100 ? "" : "0",
@@ -2336,7 +2337,7 @@ TLan_FinishReset( struct net_device *dev )
 				printk( "AutoNegotiation enabled, at 10%sMbps %s-Duplex\n",
 					tlphy_par & TLAN_PHY_SPEED_100 ? "" : "0",
 					tlphy_par & TLAN_PHY_DUPLEX_FULL ? "Full" : "Half");
-				printk("TLAN: Partner capability: ");
+				printk("Partner capability: ");
 					for (i = 5; i <= 10; i++)
 						if (partner & (1<<i))
 							printk("%s",media[i-5]);
@@ -2351,7 +2352,7 @@ TLan_FinishReset( struct net_device *dev )
 			TLan_SetTimer( dev, (10*HZ), TLAN_TIMER_LINK_BEAT );
 #endif
 		} else if (status & MII_GS_LINK)  {
-			printk( "TLAN: %s: Link active\n", dev->name );
+			pr_info("%s: Link active\n", dev->name);
 			TLan_DioWrite8( dev->base_addr, TLAN_LED_REG, TLAN_LED_LINK );
 		}
 	}
@@ -2376,8 +2377,8 @@ TLan_FinishReset( struct net_device *dev )
 		outl( TLAN_HC_GO | TLAN_HC_RT, dev->base_addr + TLAN_HOST_CMD );
 		netif_carrier_on(dev);
 	} else {
-		printk( "TLAN: %s: Link inactive, will retry in 10 secs...\n",
-			dev->name );
+		pr_info("%s: Link inactive, will retry in 10 secs...\n",
+			dev->name);
 		TLan_SetTimer( dev, (10*HZ), TLAN_TIMER_FINISH_RESET );
 		return;
 	}
@@ -2461,23 +2462,23 @@ static void TLan_PhyPrint( struct net_device *dev )
 	phy = priv->phy[priv->phyNum];
 
 	if ( priv->adapter->flags & TLAN_ADAPTER_UNMANAGED_PHY ) {
-		printk( "TLAN:   Device %s, Unmanaged PHY.\n", dev->name );
+		pr_info("Device %s, Unmanaged PHY.\n", dev->name);
 	} else if ( phy <= TLAN_PHY_MAX_ADDR ) {
-		printk( "TLAN:   Device %s, PHY 0x%02x.\n", dev->name, phy );
-		printk( "TLAN:      Off.  +0     +1     +2     +3 \n" );
+		pr_info("Device %s, PHY 0x%02x.\n", dev->name, phy);
+		pr_info("   Off.  +0     +1     +2     +3 \n");
                 for ( i = 0; i < 0x20; i+= 4 ) {
-			printk( "TLAN:      0x%02x", i );
+			pr_info("   0x%02x", i);
 			TLan_MiiReadReg( dev, phy, i, &data0 );
-			printk( " 0x%04hx", data0 );
+			pr_cont(" 0x%04hx", data0);
 			TLan_MiiReadReg( dev, phy, i + 1, &data1 );
-			printk( " 0x%04hx", data1 );
+			pr_cont(" 0x%04hx", data1);
 			TLan_MiiReadReg( dev, phy, i + 2, &data2 );
-			printk( " 0x%04hx", data2 );
+			pr_cont(" 0x%04hx", data2);
 			TLan_MiiReadReg( dev, phy, i + 3, &data3 );
-			printk( " 0x%04hx\n", data3 );
+			pr_cont(" 0x%04hx\n", data3);
 		}
 	} else {
-		printk( "TLAN:   Device %s, Invalid PHY.\n", dev->name );
+		pr_info("Device %s, Invalid PHY.\n", dev->name);
 	}
 
 } /* TLan_PhyPrint */
@@ -2545,7 +2546,7 @@ static void TLan_PhyDetect( struct net_device *dev )
 	} else if ( priv->phy[0] != TLAN_PHY_NONE ) {
 		priv->phyNum = 0;
 	} else {
-		printk( "TLAN:  Cannot initialize device, no PHY was found!\n" );
+		pr_info("Cannot initialize device, no PHY was found!\n");
 	}
 
 } /* TLan_PhyDetect */
@@ -2674,7 +2675,7 @@ static void TLan_PhyStartLink( struct net_device *dev )
 		 	* but the card need additional time to start AN.
 		 	* .5 sec should be plenty extra.
 		 	*/
-			printk( "TLAN: %s: Starting autonegotiation.\n", dev->name );
+			pr_info("%s: Starting autonegotiation.\n", dev->name);
 			TLan_SetTimer( dev, (2*HZ), TLAN_TIMER_PHY_FINISH_AN );
 			return;
 		}
@@ -2736,17 +2737,17 @@ static void TLan_PhyFinishAutoNeg( struct net_device *dev )
 		/* Wait for 8 sec to give the process
 		 * more time.  Perhaps we should fail after a while.
 		 */
-		 if (!priv->neg_be_verbose++) {
-			 pr_info("TLAN:  Giving autonegotiation more time.\n");
-		 	 pr_info("TLAN:  Please check that your adapter has\n");
-		 	 pr_info("TLAN:  been properly connected to a HUB or Switch.\n");
-			 pr_info("TLAN:  Trying to establish link in the background...\n");
-		 }
+		if (!priv->neg_be_verbose++) {
+			pr_info("Giving autonegotiation more time.\n");
+			pr_info("Please check that your adapter has\n");
+			pr_info("been properly connected to a HUB or Switch.\n");
+			pr_info("Trying to establish link in the background...\n");
+		}
 		TLan_SetTimer( dev, (8*HZ), TLAN_TIMER_PHY_FINISH_AN );
 		return;
 	}
 
-	printk( "TLAN: %s: Autonegotiation complete.\n", dev->name );
+	pr_info("%s: Autonegotiation complete.\n", dev->name);
 	TLan_MiiReadReg( dev, phy, MII_AN_ADV, &an_adv );
 	TLan_MiiReadReg( dev, phy, MII_AN_LPA, &an_lpa );
 	mode = an_adv & an_lpa & 0x03E0;
@@ -2771,10 +2772,10 @@ static void TLan_PhyFinishAutoNeg( struct net_device *dev )
 		     ( an_adv & an_lpa & 0x0040 ) ) {
 			TLan_MiiWriteReg( dev, phy, MII_GEN_CTL,
 					  MII_GC_AUTOENB | MII_GC_DUPLEX );
-			pr_info("TLAN:  Starting internal PHY with FULL-DUPLEX\n" );
+			pr_info("Starting internal PHY with FULL-DUPLEX\n");
 		} else {
 			TLan_MiiWriteReg( dev, phy, MII_GEN_CTL, MII_GC_AUTOENB );
-			pr_info( "TLAN:  Starting internal PHY with HALF-DUPLEX\n" );
+			pr_info("Starting internal PHY with HALF-DUPLEX\n");
 		}
 	}
 
@@ -2819,7 +2820,7 @@ void TLan_PhyMonitor( struct net_device *dev )
         if (!(phy_status & MII_GS_LINK)) {
  	       if (priv->link) {
 		      priv->link = 0;
-	              printk(KERN_DEBUG "TLAN: %s has lost link\n", dev->name);
+		      pr_dbg("%s has lost link\n", dev->name);
 		      netif_carrier_off(dev);
 		      TLan_SetTimer( dev, (2*HZ), TLAN_TIMER_LINK_BEAT );
 		      return;
@@ -2829,7 +2830,7 @@ void TLan_PhyMonitor( struct net_device *dev )
         /* Link restablished? */
         if ((phy_status & MII_GS_LINK) && !priv->link) {
  		priv->link = 1;
-        	printk(KERN_DEBUG "TLAN: %s has reestablished link\n", dev->name);
+		pr_dbg("%s has reestablished link\n", dev->name);
 		netif_carrier_on(dev);
         }
 
-- 
1.6.3.1.10.g659a0.dirty
