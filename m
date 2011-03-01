From: Joe Perches <joe@perches.com>
Subject: [PATCH 2/2] tlan: Use pr_fmt, pr_<level> and netdev_<level>
Date: Tue,  1 Mar 2011 08:56:33 -0800
Message-ID: <cddc758d21e65894b7c8655ce27d48a2bae3e42d.1298998514.git.joe@perches.com>
References: <901ce76108a5ab7327159b57a1b8c9283673532b.1298998514.git.joe@perches.com>
Cc: Sakari Ailus <sakari.ailus@iki.fi>, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: Samuel Chessman <chessman@tux.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <901ce76108a5ab7327159b57a1b8c9283673532b.1298998514.git.joe@perches.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Neatening and standardization to the current logging mechanisms.
Miscellaneous speen/speed typo correction.

Signed-off-by: Joe Perches <joe@perches.com>
---
 drivers/net/tlan.c |  164 ++++++++++++++++++++++++---------------------------
 1 files changed, 77 insertions(+), 87 deletions(-)

diff --git a/drivers/net/tlan.c b/drivers/net/tlan.c
index 7721e6c..ace6404 100644
--- a/drivers/net/tlan.c
+++ b/drivers/net/tlan.c
@@ -27,6 +27,8 @@
  *
  ******************************************************************************/
 
+#define pr_fmt(fmt) KBUILD_MODNAME ": " fmt
+
 #include <linux/module.h>
 #include <linux/init.h>
 #include <linux/ioport.h>
@@ -59,7 +61,7 @@ module_param_array(speed, int, NULL, 0);
 MODULE_PARM_DESC(aui, "ThunderLAN use AUI port(s) (0-1)");
 MODULE_PARM_DESC(duplex,
 		 "ThunderLAN duplex setting(s) (0-default, 1-half, 2-full)");
-MODULE_PARM_DESC(speed, "ThunderLAN port speen setting(s) (0,10,100)");
+MODULE_PARM_DESC(speed, "ThunderLAN port speed setting(s) (0,10,100)");
 
 MODULE_AUTHOR("Maintainer: Samuel Chessman <chessman@tux.org>");
 MODULE_DESCRIPTION("Driver for TI ThunderLAN based ethernet PCI adapters");
@@ -397,7 +399,7 @@ static int __init tlan_probe(void)
 {
 	int rc = -ENODEV;
 
-	printk(KERN_INFO "%s", tlan_banner);
+	pr_info("%s", tlan_banner);
 
 	TLAN_DBG(TLAN_DEBUG_PROBE, "Starting PCI Probe....\n");
 
@@ -406,16 +408,16 @@ static int __init tlan_probe(void)
 	rc = pci_register_driver(&tlan_driver);
 
 	if (rc != 0) {
-		printk(KERN_ERR "TLAN: Could not register pci driver.\n");
+		pr_err("Could not register pci driver\n");
 		goto err_out_pci_free;
 	}
 
 	TLAN_DBG(TLAN_DEBUG_PROBE, "Starting EISA Probe....\n");
 	tlan_eisa_probe();
 
-	printk(KERN_INFO "TLAN: %d device%s installed, PCI: %d  EISA: %d\n",
-	       tlan_devices_installed, tlan_devices_installed == 1 ? "" : "s",
-	       tlan_have_pci, tlan_have_eisa);
+	pr_info("%d device%s installed, PCI: %d  EISA: %d\n",
+		tlan_devices_installed, tlan_devices_installed == 1 ? "" : "s",
+		tlan_have_pci, tlan_have_eisa);
 
 	if (tlan_devices_installed == 0) {
 		rc = -ENODEV;
@@ -474,7 +476,7 @@ static int __devinit tlan_probe1(struct pci_dev *pdev,
 
 		rc = pci_request_regions(pdev, tlan_signature);
 		if (rc) {
-			printk(KERN_ERR "TLAN: Could not reserve IO regions\n");
+			pr_err("Could not reserve IO regions\n");
 			goto err_out;
 		}
 	}
@@ -482,7 +484,7 @@ static int __devinit tlan_probe1(struct pci_dev *pdev,
 
 	dev = alloc_etherdev(sizeof(struct tlan_priv));
 	if (dev == NULL) {
-		printk(KERN_ERR "TLAN: Could not allocate memory for device.\n");
+		pr_err("Could not allocate memory for device\n");
 		rc = -ENOMEM;
 		goto err_out_regions;
 	}
@@ -501,8 +503,7 @@ static int __devinit tlan_probe1(struct pci_dev *pdev,
 
 		rc = pci_set_dma_mask(pdev, DMA_BIT_MASK(32));
 		if (rc) {
-			printk(KERN_ERR
-			       "TLAN: No suitable PCI mapping available.\n");
+			pr_err("No suitable PCI mapping available\n");
 			goto err_out_free_dev;
 		}
 
@@ -516,7 +517,7 @@ static int __devinit tlan_probe1(struct pci_dev *pdev,
 			}
 		}
 		if (!pci_io_base) {
-			printk(KERN_ERR "TLAN: No IO mappings available\n");
+			pr_err("No IO mappings available\n");
 			rc = -EIO;
 			goto err_out_free_dev;
 		}
@@ -572,13 +573,13 @@ static int __devinit tlan_probe1(struct pci_dev *pdev,
 
 	rc = tlan_init(dev);
 	if (rc) {
-		printk(KERN_ERR "TLAN: Could not set up device.\n");
+		pr_err("Could not set up device\n");
 		goto err_out_free_dev;
 	}
 
 	rc = register_netdev(dev);
 	if (rc) {
-		printk(KERN_ERR "TLAN: Could not register device.\n");
+		pr_err("Could not register device\n");
 		goto err_out_uninit;
 	}
 
@@ -595,12 +596,11 @@ static int __devinit tlan_probe1(struct pci_dev *pdev,
 		tlan_have_eisa++;
 	}
 
-	printk(KERN_INFO "TLAN: %s irq=%2d, io=%04x, %s, Rev. %d\n",
-	       dev->name,
-	       (int) dev->irq,
-	       (int) dev->base_addr,
-	       priv->adapter->device_label,
-	       priv->adapter_rev);
+	netdev_info(dev, "irq=%2d, io=%04x, %s, Rev. %d\n",
+		    (int)dev->irq,
+		    (int)dev->base_addr,
+		    priv->adapter->device_label,
+		    priv->adapter_rev);
 	return 0;
 
 err_out_uninit:
@@ -716,7 +716,7 @@ static void  __init tlan_eisa_probe(void)
 		}
 
 		if (debug == 0x10)
-			printk(KERN_INFO "Found one\n");
+			pr_info("Found one\n");
 
 
 		/* Get irq from board */
@@ -745,12 +745,12 @@ static void  __init tlan_eisa_probe(void)
 
 out:
 		if (debug == 0x10)
-			printk(KERN_INFO "None found\n");
+			pr_info("None found\n");
 		continue;
 
 out2:
 		if (debug == 0x10)
-			printk(KERN_INFO "Card found but it is not enabled, skipping\n");
+			pr_info("Card found but it is not enabled, skipping\n");
 		continue;
 
 	}
@@ -818,8 +818,7 @@ static int tlan_init(struct net_device *dev)
 	priv->dma_size = dma_size;
 
 	if (priv->dma_storage == NULL) {
-		printk(KERN_ERR
-		       "TLAN:  Could not allocate lists and buffers for %s.\n",
+		pr_err("Could not allocate lists and buffers for %s\n",
 		       dev->name);
 		return -ENOMEM;
 	}
@@ -837,9 +836,8 @@ static int tlan_init(struct net_device *dev)
 					 (u8) priv->adapter->addr_ofs + i,
 					 (u8 *) &dev->dev_addr[i]);
 	if (err) {
-		printk(KERN_ERR "TLAN: %s: Error reading MAC from eeprom: %d\n",
-		       dev->name,
-		       err);
+		pr_err("%s: Error reading MAC from eeprom: %d\n",
+		       dev->name, err);
 	}
 	dev->addr_len = 6;
 
@@ -883,8 +881,8 @@ static int tlan_open(struct net_device *dev)
 			  dev->name, dev);
 
 	if (err) {
-		pr_err("TLAN:  Cannot open %s because IRQ %d is already in use.\n",
-		       dev->name, dev->irq);
+		netdev_err(dev, "Cannot open because IRQ %d is already in use\n",
+			   dev->irq);
 		return err;
 	}
 
@@ -1367,8 +1365,8 @@ static u32 tlan_handle_tx_eof(struct net_device *dev, u16 host_int)
 	}
 
 	if (!ack)
-		printk(KERN_INFO
-		       "TLAN: Received interrupt for uncompleted TX frame.\n");
+		netdev_info(dev,
+			    "Received interrupt for uncompleted TX frame\n");
 
 	if (eoc) {
 		TLAN_DBG(TLAN_DEBUG_TX,
@@ -1522,8 +1520,8 @@ drop_and_reuse:
 	}
 
 	if (!ack)
-		printk(KERN_INFO
-		       "TLAN: Received interrupt for uncompleted RX frame.\n");
+		netdev_info(dev,
+			    "Received interrupt for uncompleted RX frame\n");
 
 
 	if (eoc) {
@@ -1579,7 +1577,7 @@ drop_and_reuse:
 
 static u32 tlan_handle_dummy(struct net_device *dev, u16 host_int)
 {
-	pr_info("TLAN:  Test interrupt on %s.\n", dev->name);
+	netdev_info(dev, "Test interrupt\n");
 	return 1;
 
 }
@@ -1673,7 +1671,7 @@ static u32 tlan_handle_status_check(struct net_device *dev, u16 host_int)
 	if (host_int & TLAN_HI_IV_MASK) {
 		netif_stop_queue(dev);
 		error = inl(dev->base_addr + TLAN_CH_PARM);
-		pr_info("TLAN:  %s: Adaptor Error = 0x%x\n", dev->name, error);
+		netdev_info(dev, "Adaptor Error = 0x%x\n", error);
 		tlan_read_and_clear_stats(dev, TLAN_RECORD);
 		outl(TLAN_HC_AD_RST, dev->base_addr + TLAN_HOST_CMD);
 
@@ -1914,7 +1912,7 @@ static void tlan_reset_lists(struct net_device *dev)
 		list->buffer[0].count = TLAN_MAX_FRAME_SIZE | TLAN_LAST_BUFFER;
 		skb = netdev_alloc_skb_ip_align(dev, TLAN_MAX_FRAME_SIZE + 5);
 		if (!skb) {
-			pr_err("TLAN: out of memory for received data.\n");
+			netdev_err(dev, "Out of memory for received data\n");
 			break;
 		}
 
@@ -1998,13 +1996,13 @@ static void tlan_print_dio(u16 io_base)
 	u32 data0, data1;
 	int	i;
 
-	pr_info("TLAN:   Contents of internal registers for io base 0x%04hx.\n",
-	       io_base);
-	pr_info("TLAN:      Off.  +0	 +4\n");
+	pr_info("Contents of internal registers for io base 0x%04hx\n",
+		io_base);
+	pr_info("Off.  +0        +4\n");
 	for (i = 0; i < 0x4C; i += 8) {
 		data0 = tlan_dio_read32(io_base, i);
 		data1 = tlan_dio_read32(io_base, i + 0x4);
-		pr_info("TLAN:      0x%02x  0x%08x 0x%08x\n", i, data0, data1);
+		pr_info("0x%02x  0x%08x 0x%08x\n", i, data0, data1);
 	}
 
 }
@@ -2033,14 +2031,14 @@ static void tlan_print_list(struct tlan_list *list, char *type, int num)
 {
 	int i;
 
-	pr_info("TLAN:   %s List %d at %p\n", type, num, list);
-	pr_info("TLAN:      Forward    = 0x%08x\n",  list->forward);
-	pr_info("TLAN:      CSTAT      = 0x%04hx\n", list->c_stat);
-	pr_info("TLAN:      Frame Size = 0x%04hx\n", list->frame_size);
+	pr_info("%s List %d at %p\n", type, num, list);
+	pr_info("   Forward    = 0x%08x\n",  list->forward);
+	pr_info("   CSTAT      = 0x%04hx\n", list->c_stat);
+	pr_info("   Frame Size = 0x%04hx\n", list->frame_size);
 	/* for (i = 0; i < 10; i++) { */
 	for (i = 0; i < 2; i++) {
-		pr_info("TLAN:      Buffer[%d].count, addr = 0x%08x, 0x%08x\n",
-		       i, list->buffer[i].count, list->buffer[i].address);
+		pr_info("   Buffer[%d].count, addr = 0x%08x, 0x%08x\n",
+			i, list->buffer[i].count, list->buffer[i].address);
 	}
 
 }
@@ -2255,7 +2253,7 @@ tlan_finish_reset(struct net_device *dev)
 	if ((priv->adapter->flags & TLAN_ADAPTER_UNMANAGED_PHY) ||
 	    (priv->aui)) {
 		status = MII_GS_LINK;
-		pr_info("TLAN:  %s: Link forced.\n", dev->name);
+		netdev_info(dev, "Link forced\n");
 	} else {
 		tlan_mii_read_reg(dev, phy, MII_GEN_STS, &status);
 		udelay(1000);
@@ -2267,24 +2265,21 @@ tlan_finish_reset(struct net_device *dev)
 			tlan_mii_read_reg(dev, phy, MII_AN_LPA, &partner);
 			tlan_mii_read_reg(dev, phy, TLAN_TLPHY_PAR, &tlphy_par);
 
-			pr_info("TLAN: %s: Link active with ", dev->name);
-			if (!(tlphy_par & TLAN_PHY_AN_EN_STAT)) {
-				pr_info("forced 10%sMbps %s-Duplex\n",
-					tlphy_par & TLAN_PHY_SPEED_100
-					? "" : "0",
-					tlphy_par & TLAN_PHY_DUPLEX_FULL
-					? "Full" : "Half");
-			} else {
-				pr_info("Autonegotiation enabled, at 10%sMbps %s-Duplex\n",
-					tlphy_par & TLAN_PHY_SPEED_100
-					? "" : "0",
-					tlphy_par & TLAN_PHY_DUPLEX_FULL
-					? "Full" : "half");
-				pr_info("TLAN: Partner capability: ");
-				for (i = 5; i <= 10; i++)
-					if (partner & (1<<i))
-						printk("%s", media[i-5]);
-				printk("\n");
+			netdev_info(dev,
+				    "Link active with %s %uMbps %s-Duplex\n",
+				    !(tlphy_par & TLAN_PHY_AN_EN_STAT)
+				    ? "forced" : "Autonegotiation enabled,",
+				    tlphy_par & TLAN_PHY_SPEED_100
+				    ? 100 : 10,
+				    tlphy_par & TLAN_PHY_DUPLEX_FULL
+				    ? "Full" : "Half");
+
+			if (tlphy_par & TLAN_PHY_AN_EN_STAT) {
+				netdev_info(dev, "Partner capability:");
+				for (i = 5; i < 10; i++)
+					if (partner & (1 << i))
+						pr_cont(" %s", media[i-5]);
+				pr_cont("\n");
 			}
 
 			tlan_dio_write8(dev->base_addr, TLAN_LED_REG,
@@ -2296,7 +2291,7 @@ tlan_finish_reset(struct net_device *dev)
 			tlan_set_timer(dev, (10*HZ), TLAN_TIMER_LINK_BEAT);
 #endif
 		} else if (status & MII_GS_LINK)  {
-			pr_info("TLAN: %s: Link active\n", dev->name);
+			netdev_info(dev, "Link active\n");
 			tlan_dio_write8(dev->base_addr, TLAN_LED_REG,
 					TLAN_LED_LINK);
 		}
@@ -2322,8 +2317,7 @@ tlan_finish_reset(struct net_device *dev)
 		outl(TLAN_HC_GO | TLAN_HC_RT, dev->base_addr + TLAN_HOST_CMD);
 		netif_carrier_on(dev);
 	} else {
-		pr_info("TLAN: %s: Link inactive, will retry in 10 secs...\n",
-		       dev->name);
+		netdev_info(dev, "Link inactive, will retry in 10 secs...\n");
 		tlan_set_timer(dev, (10*HZ), TLAN_TIMER_FINISH_RESET);
 		return;
 	}
@@ -2407,23 +2401,20 @@ static void tlan_phy_print(struct net_device *dev)
 	phy = priv->phy[priv->phy_num];
 
 	if (priv->adapter->flags & TLAN_ADAPTER_UNMANAGED_PHY) {
-		pr_info("TLAN:   Device %s, Unmanaged PHY.\n", dev->name);
+		netdev_info(dev, "Unmanaged PHY\n");
 	} else if (phy <= TLAN_PHY_MAX_ADDR) {
-		pr_info("TLAN:   Device %s, PHY 0x%02x.\n", dev->name, phy);
-		pr_info("TLAN:      Off.  +0     +1     +2     +3\n");
+		netdev_info(dev, "PHY 0x%02x\n", phy);
+		pr_info("   Off.  +0     +1     +2     +3\n");
 		for (i = 0; i < 0x20; i += 4) {
-			pr_info("TLAN:      0x%02x", i);
 			tlan_mii_read_reg(dev, phy, i, &data0);
-			printk(" 0x%04hx", data0);
 			tlan_mii_read_reg(dev, phy, i + 1, &data1);
-			printk(" 0x%04hx", data1);
 			tlan_mii_read_reg(dev, phy, i + 2, &data2);
-			printk(" 0x%04hx", data2);
 			tlan_mii_read_reg(dev, phy, i + 3, &data3);
-			printk(" 0x%04hx\n", data3);
+			pr_info("   0x%02x 0x%04hx 0x%04hx 0x%04hx 0x%04hx\n",
+				i, data0, data1, data2, data3);
 		}
 	} else {
-		pr_info("TLAN:   Device %s, Invalid PHY.\n", dev->name);
+		netdev_info(dev, "Invalid PHY\n");
 	}
 
 }
@@ -2490,7 +2481,7 @@ static void tlan_phy_detect(struct net_device *dev)
 	else if (priv->phy[0] != TLAN_PHY_NONE)
 		priv->phy_num = 0;
 	else
-		pr_info("TLAN:  Cannot initialize device, no PHY was found!\n");
+		netdev_info(dev, "Cannot initialize device, no PHY was found!\n");
 
 }
 
@@ -2618,8 +2609,7 @@ static void tlan_phy_start_link(struct net_device *dev)
 			 * but the card need additional time to start AN.
 			 * .5 sec should be plenty extra.
 			 */
-			pr_info("TLAN: %s: Starting autonegotiation.\n",
-				dev->name);
+			netdev_info(dev, "Starting autonegotiation\n");
 			tlan_set_timer(dev, (2*HZ), TLAN_TIMER_PHY_FINISH_AN);
 			return;
 		}
@@ -2682,16 +2672,16 @@ static void tlan_phy_finish_auto_neg(struct net_device *dev)
 		 * more time.  Perhaps we should fail after a while.
 		 */
 		if (!priv->neg_be_verbose++) {
-			pr_info("TLAN:  Giving autonegotiation more time.\n");
-			pr_info("TLAN:  Please check that your adapter has\n");
-			pr_info("TLAN:  been properly connected to a HUB or Switch.\n");
-			pr_info("TLAN:  Trying to establish link in the background...\n");
+			pr_info("Giving autonegotiation more time.\n");
+			pr_info("Please check that your adapter has\n");
+			pr_info("been properly connected to a HUB or Switch.\n");
+			pr_info("Trying to establish link in the background...\n");
 		}
 		tlan_set_timer(dev, (8*HZ), TLAN_TIMER_PHY_FINISH_AN);
 		return;
 	}
 
-	pr_info("TLAN: %s: Autonegotiation complete.\n", dev->name);
+	netdev_info(dev, "Autonegotiation complete\n");
 	tlan_mii_read_reg(dev, phy, MII_AN_ADV, &an_adv);
 	tlan_mii_read_reg(dev, phy, MII_AN_LPA, &an_lpa);
 	mode = an_adv & an_lpa & 0x03E0;
@@ -2716,11 +2706,11 @@ static void tlan_phy_finish_auto_neg(struct net_device *dev)
 		    (an_adv & an_lpa & 0x0040)) {
 			tlan_mii_write_reg(dev, phy, MII_GEN_CTL,
 					   MII_GC_AUTOENB | MII_GC_DUPLEX);
-			pr_info("TLAN:  Starting internal PHY with FULL-DUPLEX\n");
+			netdev_info(dev, "Starting internal PHY with FULL-DUPLEX\n");
 		} else {
 			tlan_mii_write_reg(dev, phy, MII_GEN_CTL,
 					   MII_GC_AUTOENB);
-			pr_info("TLAN:  Starting internal PHY with HALF-DUPLEX\n");
+			netdev_info(dev, "Starting internal PHY with HALF-DUPLEX\n");
 		}
 	}
 
-- 
1.7.4.2.g597a6.dirty
