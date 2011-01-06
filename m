From: Joe Perches <joe@perches.com>
Subject: [PATCH] tlan: Use pr_fmt, pr_<level> and netdev_<level>, remove
 changelog
Date: Thu, 06 Jan 2011 14:48:08 -0800
Message-ID: <1294354088.12561.295.camel@Joe-Laptop>
References: <4D260ED0.5040301@iki.fi>
	 <1294339817-31434-1-git-send-email-sakari.ailus@iki.fi>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, Samuel Chessman <chessman@tux.org>
To: Sakari Ailus <sakari.ailus@iki.fi>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.perches.com ([173.55.12.10]:3008 "EHLO mail.perches.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754476Ab1AFWsJ (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 6 Jan 2011 17:48:09 -0500
In-Reply-To: <1294339817-31434-1-git-send-email-sakari.ailus@iki.fi>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Neatening and standardization to the standard logging mechanisms.
The changelog isn't useful anymore.
Miscellaneous speen/speed typo correction.

Signed-off-by: Joe Perches <joe@perches.com>
---

On top of Sakari Ailus' patches...

 drivers/net/tlan.c |  304 +++++++++++++---------------------------------------
 1 files changed, 74 insertions(+), 230 deletions(-)

diff --git a/drivers/net/tlan.c b/drivers/net/tlan.c
index bbb0b12..ecfae1d 100644
--- a/drivers/net/tlan.c
+++ b/drivers/net/tlan.c
@@ -25,153 +25,10 @@
  *		Microchip Technology, 24C01A/02A/04A Data Sheet
  *			available in PDF format from www.microchip.com
  *
- * Change History
- *
- *	Tigran Aivazian <tigran@sco.com>:	TLan_PciProbe() now uses
- *						new PCI BIOS interface.
- *	Alan Cox	<alan@lxorguk.ukuu.org.uk>:
- *						Fixed the out of memory
- *						handling.
- *
- *	Torben Mathiasen <torben.mathiasen@compaq.com> New Maintainer!
- *
- *	v1.1 Dec 20, 1999    - Removed linux version checking
- *			       Patch from Tigran Aivazian.
- *			     - v1.1 includes Alan's SMP updates.
- *			     - We still have problems on SMP though,
- *			       but I'm looking into that.
- *
- *	v1.2 Jan 02, 2000    - Hopefully fixed the SMP deadlock.
- *			     - Removed dependency of HZ being 100.
- *			     - We now allow higher priority timers to
- *			       overwrite timers like TLAN_TIMER_ACTIVITY
- *			       Patch from John Cagle <john.cagle@compaq.com>.
- *			     - Fixed a few compiler warnings.
- *
- *	v1.3 Feb 04, 2000    - Fixed the remaining HZ issues.
- *			     - Removed call to pci_present().
- *			     - Removed SA_INTERRUPT flag from irq handler.
- *			     - Added __init and __initdata to reduce resisdent
- *			       code size.
- *			     - Driver now uses module_init/module_exit.
- *			     - Rewrote init_module and tlan_probe to
- *			       share a lot more code. We now use tlan_probe
- *			       with builtin and module driver.
- *			     - Driver ported to new net API.
- *			     - tlan.txt has been reworked to reflect current
- *			       driver (almost)
- *			     - Other minor stuff
- *
- *	v1.4 Feb 10, 2000    - Updated with more changes required after Dave's
- *			       network cleanup in 2.3.43pre7 (Tigran & myself)
- *			     - Minor stuff.
- *
- *	v1.5 March 22, 2000  - Fixed another timer bug that would hang the
- *			       driver if no cable/link were present.
- *			     - Cosmetic changes.
- *			     - TODO: Port completely to new PCI/DMA API
- *				     Auto-Neg fallback.
- *
- *	v1.6 April 04, 2000  - Fixed driver support for kernel-parameters.
- *			       Haven't tested it though, as the kernel support
- *			       is currently broken (2.3.99p4p3).
- *			     - Updated tlan.txt accordingly.
- *			     - Adjusted minimum/maximum frame length.
- *			     - There is now a TLAN website up at
- *			       http://hp.sourceforge.net/
- *
- *	v1.7 April 07, 2000  - Started to implement custom ioctls. Driver now
- *			       reports PHY information when used with Donald
- *			       Beckers userspace MII diagnostics utility.
- *
- *	v1.8 April 23, 2000  - Fixed support for forced speed/duplex settings.
- *			     - Added link information to Auto-Neg and forced
- *			       modes. When NIC operates with auto-neg the driver
- *			       will report Link speed & duplex modes as well as
- *			       link partner abilities. When forced link is used,
- *			       the driver will report status of the established
- *			       link.
- *			       Please read tlan.txt for additional information.
- *			     - Removed call to check_region(), and used
- *			       return value of request_region() instead.
- *
- *	v1.8a May 28, 2000   - Minor updates.
- *
- *	v1.9 July 25, 2000   - Fixed a few remaining Full-Duplex issues.
- *			     - Updated with timer fixes from Andrew Morton.
- *			     - Fixed module race in TLan_Open.
- *			     - Added routine to monitor PHY status.
- *			     - Added activity led support for Proliant devices.
- *
- *	v1.10 Aug 30, 2000   - Added support for EISA based tlan controllers
- *			       like the Compaq NetFlex3/E.
- *			     - Rewrote tlan_probe to better handle multiple
- *			       bus probes. Probing and device setup is now
- *			       done through TLan_Probe and TLan_init_one. Actual
- *			       hardware probe is done with kernel API and
- *			       TLan_EisaProbe.
- *			     - Adjusted debug information for probing.
- *			     - Fixed bug that would cause general debug
- *			       information to be printed after driver removal.
- *			     - Added transmit timeout handling.
- *			     - Fixed OOM return values in tlan_probe.
- *			     - Fixed possible mem leak in tlan_exit
- *			       (now tlan_remove_one).
- *			     - Fixed timer bug in TLan_phyMonitor.
- *			     - This driver version is alpha quality, please
- *			       send me any bug issues you may encounter.
- *
- *	v1.11 Aug 31, 2000   - Do not try to register irq 0 if no irq line was
- *			       set for EISA cards.
- *			     - Added support for NetFlex3/E with nibble-rate
- *			       10Base-T PHY. This is untestet as I haven't got
- *			       one of these cards.
- *			     - Fixed timer being added twice.
- *			     - Disabled PhyMonitoring by default as this is
- *			       work in progress. Define MONITOR to enable it.
- *			     - Now we don't display link info with PHYs that
- *			       doesn't support it (level1).
- *			     - Incresed tx_timeout beacuse of auto-neg.
- *			     - Adjusted timers for forced speeds.
- *
- *	v1.12 Oct 12, 2000   - Minor fixes (memleak, init, etc.)
- *
- *	v1.13 Nov 28, 2000   - Stop flooding console with auto-neg issues
- *			       when link can't be established.
- *			     - Added the bbuf option as a kernel parameter.
- *			     - Fixed ioaddr probe bug.
- *			     - Fixed stupid deadlock with MII interrupts.
- *			     - Added support for speed/duplex selection with
- *			       multiple nics.
- *			     - Added partly fix for TX Channel lockup with
- *			       TLAN v1.0 silicon. This needs to be investigated
- *			       further.
- *
- *	v1.14 Dec 16, 2000   - Added support for servicing multiple frames per.
- *			       interrupt. Thanks goes to
- *			       Adam Keys <adam@ti.com>
- *			       Denis Beaudoin <dbeaudoin@ti.com>
- *			       for providing the patch.
- *			     - Fixed auto-neg output when using multiple
- *			       adapters.
- *			     - Converted to use new taskq interface.
- *
- *	v1.14a Jan 6, 2001   - Minor adjustments (spinlocks, etc.)
- *
- *	Samuel Chessman <chessman@tux.org> New Maintainer!
- *
- *	v1.15 Apr 4, 2002    - Correct operation when aui=1 to be
- *			       10T half duplex no loopback
- *			       Thanks to Gunnar Eikman
- *
- *	Sakari Ailus <sakari.ailus@iki.fi>:
- *
- *	v1.15a Dec 15 2008   - Remove bbuf support, it doesn't work anyway.
- *	v1.16  Jan 6  2011   - Make checkpatch.pl happy.
- *	v1.17  Jan 6  2011   - Add suspend/resume support.
- *
  ******************************************************************************/
 
+#define pr_fmt(fmt) KBUILD_MODNAME ": " fmt
+
 #include <linux/module.h>
 #include <linux/init.h>
 #include <linux/ioport.h>
@@ -204,7 +61,7 @@ module_param_array(speed, int, NULL, 0);
 MODULE_PARM_DESC(aui, "ThunderLAN use AUI port(s) (0-1)");
 MODULE_PARM_DESC(duplex,
 		 "ThunderLAN duplex setting(s) (0-default, 1-half, 2-full)");
-MODULE_PARM_DESC(speed, "ThunderLAN port speen setting(s) (0,10,100)");
+MODULE_PARM_DESC(speed, "ThunderLAN port speed setting(s) (0,10,100)");
 
 MODULE_AUTHOR("Maintainer: Samuel Chessman <chessman@tux.org>");
 MODULE_DESCRIPTION("Driver for TI ThunderLAN based ethernet PCI adapters");
@@ -542,7 +399,7 @@ static int __init tlan_probe(void)
 {
 	int rc = -ENODEV;
 
-	printk(KERN_INFO "%s", tlan_banner);
+	pr_info("%s", tlan_banner);
 
 	TLAN_DBG(TLAN_DEBUG_PROBE, "Starting PCI Probe....\n");
 
@@ -551,16 +408,16 @@ static int __init tlan_probe(void)
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
@@ -619,7 +476,7 @@ static int __devinit tlan_probe1(struct pci_dev *pdev,
 
 		rc = pci_request_regions(pdev, tlan_signature);
 		if (rc) {
-			printk(KERN_ERR "TLAN: Could not reserve IO regions\n");
+			pr_err("Could not reserve IO regions\n");
 			goto err_out;
 		}
 	}
@@ -627,7 +484,7 @@ static int __devinit tlan_probe1(struct pci_dev *pdev,
 
 	dev = alloc_etherdev(sizeof(struct tlan_priv));
 	if (dev == NULL) {
-		printk(KERN_ERR "TLAN: Could not allocate memory for device.\n");
+		pr_err("Could not allocate memory for device\n");
 		rc = -ENOMEM;
 		goto err_out_regions;
 	}
@@ -646,8 +503,7 @@ static int __devinit tlan_probe1(struct pci_dev *pdev,
 
 		rc = pci_set_dma_mask(pdev, DMA_BIT_MASK(32));
 		if (rc) {
-			printk(KERN_ERR
-			       "TLAN: No suitable PCI mapping available.\n");
+			pr_err("No suitable PCI mapping available\n");
 			goto err_out_free_dev;
 		}
 
@@ -661,7 +517,7 @@ static int __devinit tlan_probe1(struct pci_dev *pdev,
 			}
 		}
 		if (!pci_io_base) {
-			printk(KERN_ERR "TLAN: No IO mappings available\n");
+			pr_err("No IO mappings available\n");
 			rc = -EIO;
 			goto err_out_free_dev;
 		}
@@ -717,13 +573,13 @@ static int __devinit tlan_probe1(struct pci_dev *pdev,
 
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
 
@@ -740,12 +596,11 @@ static int __devinit tlan_probe1(struct pci_dev *pdev,
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
@@ -861,7 +716,7 @@ static void  __init tlan_eisa_probe(void)
 		}
 
 		if (debug == 0x10)
-			printk(KERN_INFO "Found one\n");
+			pr_info("Found one\n");
 
 
 		/* Get irq from board */
@@ -890,12 +745,12 @@ static void  __init tlan_eisa_probe(void)
 
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
@@ -963,8 +818,7 @@ static int tlan_init(struct net_device *dev)
 	priv->dma_size = dma_size;
 
 	if (priv->dma_storage == NULL) {
-		printk(KERN_ERR
-		       "TLAN:  Could not allocate lists and buffers for %s.\n",
+		pr_err("Could not allocate lists and buffers for %s\n",
 		       dev->name);
 		return -ENOMEM;
 	}
@@ -982,9 +836,8 @@ static int tlan_init(struct net_device *dev)
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
 
@@ -1028,8 +881,8 @@ static int tlan_open(struct net_device *dev)
 			  dev->name, dev);
 
 	if (err) {
-		pr_err("TLAN:  Cannot open %s because IRQ %d is already in use.\n",
-		       dev->name, dev->irq);
+		netdev_err(dev, "Cannot open because IRQ %d is already in use\n",
+			   dev->irq);
 		return err;
 	}
 
@@ -1512,8 +1365,8 @@ static u32 tlan_handle_tx_eof(struct net_device *dev, u16 host_int)
 	}
 
 	if (!ack)
-		printk(KERN_INFO
-		       "TLAN: Received interrupt for uncompleted TX frame.\n");
+		netdev_info(dev,
+			    "Received interrupt for uncompleted TX frame\n");
 
 	if (eoc) {
 		TLAN_DBG(TLAN_DEBUG_TX,
@@ -1666,8 +1519,8 @@ drop_and_reuse:
 	}
 
 	if (!ack)
-		printk(KERN_INFO
-		       "TLAN: Received interrupt for uncompleted RX frame.\n");
+		netdev_info(dev,
+			    "Received interrupt for uncompleted RX frame\n");
 
 
 	if (eoc) {
@@ -1723,7 +1576,7 @@ drop_and_reuse:
 
 static u32 tlan_handle_dummy(struct net_device *dev, u16 host_int)
 {
-	pr_info("TLAN:  Test interrupt on %s.\n", dev->name);
+	netdev_info(dev, "Test interrupt\n");
 	return 1;
 
 }
@@ -1816,7 +1669,7 @@ static u32 tlan_handle_status_check(struct net_device *dev, u16 host_int)
 	if (host_int & TLAN_HI_IV_MASK) {
 		netif_stop_queue(dev);
 		error = inl(dev->base_addr + TLAN_CH_PARM);
-		pr_info("TLAN:  %s: Adaptor Error = 0x%x\n", dev->name, error);
+		netdev_info(dev, "Adaptor Error = 0x%x\n", error);
 		tlan_read_and_clear_stats(dev, TLAN_RECORD);
 		outl(TLAN_HC_AD_RST, dev->base_addr + TLAN_HOST_CMD);
 
@@ -2057,7 +1910,7 @@ static void tlan_reset_lists(struct net_device *dev)
 		list->buffer[0].count = TLAN_MAX_FRAME_SIZE | TLAN_LAST_BUFFER;
 		skb = netdev_alloc_skb_ip_align(dev, TLAN_MAX_FRAME_SIZE + 5);
 		if (!skb) {
-			pr_err("TLAN: out of memory for received data.\n");
+			netdev_err(dev, "Out of memory for received data\n");
 			break;
 		}
 
@@ -2141,13 +1994,13 @@ static void tlan_print_dio(u16 io_base)
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
@@ -2176,14 +2029,14 @@ static void tlan_print_list(struct tlan_list *list, char *type, int num)
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
@@ -2398,7 +2251,7 @@ tlan_finish_reset(struct net_device *dev)
 	if ((priv->adapter->flags & TLAN_ADAPTER_UNMANAGED_PHY) ||
 	    (priv->aui)) {
 		status = MII_GS_LINK;
-		pr_info("TLAN:  %s: Link forced.\n", dev->name);
+		netdev_info(dev, "Link forced\n");
 	} else {
 		tlan_mii_read_reg(dev, phy, MII_GEN_STS, &status);
 		udelay(1000);
@@ -2410,24 +2263,20 @@ tlan_finish_reset(struct net_device *dev)
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
-				pr_info("TLAN: Partner capability:");
+			netdev_info(dev,
+				    "Link active with %s %uMbps %s-Duplex\n",
+				    !(tlphy_par & TLAN_PHY_AN_EN_STAT)
+				    ? "forced" : "Autonegotiation enabled,",
+				    tlphy_par & TLAN_PHY_SPEED_100
+				    ? 100 : 10,
+				    tlphy_par & TLAN_PHY_DUPLEX_FULL
+				    ? "Full" : "Half");
+			if (tlphy_par & TLAN_PHY_AN_EN_STAT) {
+				netdev_info(dev, "Partner capability:");
 				for (i = 5; i < 10; i++)
 					if (partner & (1<<i))
-						printk(" %s", media[i-5]);
-				printk("\n");
+						pr_cont(" %s", media[i-5]);
+				pr_cont("\n");
 			}
 
 			tlan_dio_write8(dev->base_addr, TLAN_LED_REG,
@@ -2439,7 +2288,7 @@ tlan_finish_reset(struct net_device *dev)
 			tlan_set_timer(dev, (10*HZ), TLAN_TIMER_LINK_BEAT);
 #endif
 		} else if (status & MII_GS_LINK)  {
-			pr_info("TLAN: %s: Link active\n", dev->name);
+			netdev_info(dev, "Link active\n");
 			tlan_dio_write8(dev->base_addr, TLAN_LED_REG,
 					TLAN_LED_LINK);
 		}
@@ -2465,8 +2314,7 @@ tlan_finish_reset(struct net_device *dev)
 		outl(TLAN_HC_GO | TLAN_HC_RT, dev->base_addr + TLAN_HOST_CMD);
 		netif_carrier_on(dev);
 	} else {
-		pr_info("TLAN: %s: Link inactive, will retry in 10 secs...\n",
-		       dev->name);
+		netdev_info(dev, "Link inactive, will retry in 10 secs...\n");
 		tlan_set_timer(dev, (10*HZ), TLAN_TIMER_FINISH_RESET);
 		return;
 	}
@@ -2550,23 +2398,20 @@ static void tlan_phy_print(struct net_device *dev)
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
@@ -2633,7 +2478,7 @@ static void tlan_phy_detect(struct net_device *dev)
 	else if (priv->phy[0] != TLAN_PHY_NONE)
 		priv->phy_num = 0;
 	else
-		pr_info("TLAN:  Cannot initialize device, no PHY was found!\n");
+		netdev_info(dev, "Cannot initialize device, no PHY was found!\n");
 
 }
 
@@ -2761,8 +2606,7 @@ static void tlan_phy_start_link(struct net_device *dev)
 			 * but the card need additional time to start AN.
 			 * .5 sec should be plenty extra.
 			 */
-			pr_info("TLAN: %s: Starting autonegotiation.\n",
-				dev->name);
+			netdev_info(dev, "Starting autonegotiation\n");
 			tlan_set_timer(dev, (2*HZ), TLAN_TIMER_PHY_FINISH_AN);
 			return;
 		}
@@ -2825,16 +2669,16 @@ static void tlan_phy_finish_auto_neg(struct net_device *dev)
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
@@ -2859,11 +2703,11 @@ static void tlan_phy_finish_auto_neg(struct net_device *dev)
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
 



