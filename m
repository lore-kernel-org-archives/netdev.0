From: Joe Perches <joe@perches.com>
Subject: [PATCH net-next 1/2] drivers/net/sungem: Use netdev_<level>, netif_<level> and pr_<level>
Date: Tue, 17 Aug 2010 10:55:04 -0700
Message-ID: <1282067705-14800-1-git-send-email-joe@perches.com>
Cc: linux-kernel@vger.kernel.org
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.perches.com ([173.55.12.10]:1127 "EHLO mail.perches.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754819Ab0HQRzH (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 17 Aug 2010 13:55:07 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Use the current logging message styles.

Signed-off-by: Joe Perches <joe@perches.com>
---
 drivers/net/sungem.c     |  211 ++++++++++++++++++----------------------------
 drivers/net/sungem_phy.c |    3 +-
 2 files changed, 85 insertions(+), 129 deletions(-)

diff --git a/drivers/net/sungem.c b/drivers/net/sungem.c
index 434f9d7..4ceb3cf 100644
--- a/drivers/net/sungem.c
+++ b/drivers/net/sungem.c
@@ -31,6 +31,8 @@
  *    about when we can start taking interrupts or get xmit() called...
  */
 
+#define pr_fmt(fmt) KBUILD_MODNAME ": " fmt
+
 #include <linux/module.h>
 #include <linux/kernel.h>
 #include <linux/types.h>
@@ -105,7 +107,6 @@ MODULE_DESCRIPTION("Sun GEM Gbit ethernet driver");
 MODULE_LICENSE("GPL");
 
 #define GEM_MODULE_NAME	"gem"
-#define PFX GEM_MODULE_NAME ": "
 
 static DEFINE_PCI_DEVICE_TABLE(gem_pci_tbl) = {
 	{ PCI_VENDOR_ID_SUN, PCI_DEVICE_ID_SUN_GEM,
@@ -262,8 +263,7 @@ static int gem_pcs_interrupt(struct net_device *dev, struct gem *gp, u32 gem_sta
 			gp->dev->name, pcs_istat);
 
 	if (!(pcs_istat & PCS_ISTAT_LSC)) {
-		printk(KERN_ERR "%s: PCS irq but no link status change???\n",
-		       dev->name);
+		netdev_err(dev, "PCS irq but no link status change???\n");
 		return 0;
 	}
 
@@ -282,20 +282,16 @@ static int gem_pcs_interrupt(struct net_device *dev, struct gem *gp, u32 gem_sta
 		 * when autoneg has completed.
 		 */
 		if (pcs_miistat & PCS_MIISTAT_RF)
-			printk(KERN_INFO "%s: PCS AutoNEG complete, "
-			       "RemoteFault\n", dev->name);
+			netdev_info(dev, "PCS AutoNEG complete, RemoteFault\n");
 		else
-			printk(KERN_INFO "%s: PCS AutoNEG complete.\n",
-			       dev->name);
+			netdev_info(dev, "PCS AutoNEG complete\n");
 	}
 
 	if (pcs_miistat & PCS_MIISTAT_LS) {
-		printk(KERN_INFO "%s: PCS link is now up.\n",
-		       dev->name);
+		netdev_info(dev, "PCS link is now up\n");
 		netif_carrier_on(gp->dev);
 	} else {
-		printk(KERN_INFO "%s: PCS link is now down.\n",
-		       dev->name);
+		netdev_info(dev, "PCS link is now down\n");
 		netif_carrier_off(gp->dev);
 		/* If this happens and the link timer is not running,
 		 * reset so we re-negotiate.
@@ -323,14 +319,12 @@ static int gem_txmac_interrupt(struct net_device *dev, struct gem *gp, u32 gem_s
 		return 0;
 
 	if (txmac_stat & MAC_TXSTAT_URUN) {
-		printk(KERN_ERR "%s: TX MAC xmit underrun.\n",
-		       dev->name);
+		netdev_err(dev, "TX MAC xmit underrun\n");
 		gp->net_stats.tx_fifo_errors++;
 	}
 
 	if (txmac_stat & MAC_TXSTAT_MPE) {
-		printk(KERN_ERR "%s: TX MAC max packet size error.\n",
-		       dev->name);
+		netdev_err(dev, "TX MAC max packet size error\n");
 		gp->net_stats.tx_errors++;
 	}
 
@@ -377,8 +371,7 @@ static int gem_rxmac_reset(struct gem *gp)
 		udelay(10);
 	}
 	if (limit == 5000) {
-		printk(KERN_ERR "%s: RX MAC will not reset, resetting whole "
-                       "chip.\n", dev->name);
+		netdev_err(dev, "RX MAC will not reset, resetting whole chip\n");
 		return 1;
 	}
 
@@ -390,8 +383,7 @@ static int gem_rxmac_reset(struct gem *gp)
 		udelay(10);
 	}
 	if (limit == 5000) {
-		printk(KERN_ERR "%s: RX MAC will not disable, resetting whole "
-		       "chip.\n", dev->name);
+		netdev_err(dev, "RX MAC will not disable, resetting whole chip\n");
 		return 1;
 	}
 
@@ -403,8 +395,7 @@ static int gem_rxmac_reset(struct gem *gp)
 		udelay(10);
 	}
 	if (limit == 5000) {
-		printk(KERN_ERR "%s: RX DMA will not disable, resetting whole "
-		       "chip.\n", dev->name);
+		netdev_err(dev, "RX DMA will not disable, resetting whole chip\n");
 		return 1;
 	}
 
@@ -419,8 +410,7 @@ static int gem_rxmac_reset(struct gem *gp)
 		udelay(10);
 	}
 	if (limit == 5000) {
-		printk(KERN_ERR "%s: RX reset command will not execute, resetting "
-		       "whole chip.\n", dev->name);
+		netdev_err(dev, "RX reset command will not execute, resetting whole chip\n");
 		return 1;
 	}
 
@@ -429,8 +419,7 @@ static int gem_rxmac_reset(struct gem *gp)
 		struct gem_rxd *rxd = &gp->init_block->rxd[i];
 
 		if (gp->rx_skbs[i] == NULL) {
-			printk(KERN_ERR "%s: Parts of RX ring empty, resetting "
-			       "whole chip.\n", dev->name);
+			netdev_err(dev, "Parts of RX ring empty, resetting whole chip\n");
 			return 1;
 		}
 
@@ -479,8 +468,7 @@ static int gem_rxmac_interrupt(struct net_device *dev, struct gem *gp, u32 gem_s
 	if (rxmac_stat & MAC_RXSTAT_OFLW) {
 		u32 smac = readl(gp->regs + MAC_SMACHINE);
 
-		printk(KERN_ERR "%s: RX MAC fifo overflow smac[%08x].\n",
-				dev->name, smac);
+		netdev_err(dev, "RX MAC fifo overflow smac[%08x]\n", smac);
 		gp->net_stats.rx_over_errors++;
 		gp->net_stats.rx_fifo_errors++;
 
@@ -542,19 +530,18 @@ static int gem_pci_interrupt(struct net_device *dev, struct gem *gp, u32 gem_sta
 
 	if (gp->pdev->vendor == PCI_VENDOR_ID_SUN &&
 	    gp->pdev->device == PCI_DEVICE_ID_SUN_GEM) {
-		printk(KERN_ERR "%s: PCI error [%04x] ",
-		       dev->name, pci_estat);
+		netdev_err(dev, "PCI error [%04x]", pci_estat);
 
 		if (pci_estat & GREG_PCIESTAT_BADACK)
-			printk("<No ACK64# during ABS64 cycle> ");
+			pr_cont(" <No ACK64# during ABS64 cycle>");
 		if (pci_estat & GREG_PCIESTAT_DTRTO)
-			printk("<Delayed transaction timeout> ");
+			pr_cont(" <Delayed transaction timeout>");
 		if (pci_estat & GREG_PCIESTAT_OTHER)
-			printk("<other>");
-		printk("\n");
+			pr_cont(" <other>");
+		pr_cont("\n");
 	} else {
 		pci_estat |= GREG_PCIESTAT_OTHER;
-		printk(KERN_ERR "%s: PCI error\n", dev->name);
+		netdev_err(dev, "PCI error\n");
 	}
 
 	if (pci_estat & GREG_PCIESTAT_OTHER) {
@@ -565,26 +552,20 @@ static int gem_pci_interrupt(struct net_device *dev, struct gem *gp, u32 gem_sta
 		 */
 		pci_read_config_word(gp->pdev, PCI_STATUS,
 				     &pci_cfg_stat);
-		printk(KERN_ERR "%s: Read PCI cfg space status [%04x]\n",
-		       dev->name, pci_cfg_stat);
+		netdev_err(dev, "Read PCI cfg space status [%04x]\n",
+			   pci_cfg_stat);
 		if (pci_cfg_stat & PCI_STATUS_PARITY)
-			printk(KERN_ERR "%s: PCI parity error detected.\n",
-			       dev->name);
+			netdev_err(dev, "PCI parity error detected\n");
 		if (pci_cfg_stat & PCI_STATUS_SIG_TARGET_ABORT)
-			printk(KERN_ERR "%s: PCI target abort.\n",
-			       dev->name);
+			netdev_err(dev, "PCI target abort\n");
 		if (pci_cfg_stat & PCI_STATUS_REC_TARGET_ABORT)
-			printk(KERN_ERR "%s: PCI master acks target abort.\n",
-			       dev->name);
+			netdev_err(dev, "PCI master acks target abort\n");
 		if (pci_cfg_stat & PCI_STATUS_REC_MASTER_ABORT)
-			printk(KERN_ERR "%s: PCI master abort.\n",
-			       dev->name);
+			netdev_err(dev, "PCI master abort\n");
 		if (pci_cfg_stat & PCI_STATUS_SIG_SYSTEM_ERROR)
-			printk(KERN_ERR "%s: PCI system error SERR#.\n",
-			       dev->name);
+			netdev_err(dev, "PCI system error SERR#\n");
 		if (pci_cfg_stat & PCI_STATUS_DETECTED_PARITY)
-			printk(KERN_ERR "%s: PCI parity error.\n",
-			       dev->name);
+			netdev_err(dev, "PCI parity error\n");
 
 		/* Write the error bits back to clear them. */
 		pci_cfg_stat &= (PCI_STATUS_PARITY |
@@ -874,8 +855,7 @@ static int gem_rx(struct gem *gp, int work_to_do)
 	gp->rx_new = entry;
 
 	if (drops)
-		printk(KERN_INFO "%s: Memory squeeze, deferring packet.\n",
-		       gp->dev->name);
+		netdev_info(gp->dev, "Memory squeeze, deferring packet\n");
 
 	return work_done;
 }
@@ -981,21 +961,19 @@ static void gem_tx_timeout(struct net_device *dev)
 {
 	struct gem *gp = netdev_priv(dev);
 
-	printk(KERN_ERR "%s: transmit timed out, resetting\n", dev->name);
+	netdev_err(dev, "transmit timed out, resetting\n");
 	if (!gp->running) {
-		printk("%s: hrm.. hw not running !\n", dev->name);
+		netdev_err(dev, "hrm.. hw not running !\n");
 		return;
 	}
-	printk(KERN_ERR "%s: TX_STATE[%08x:%08x:%08x]\n",
-	       dev->name,
-	       readl(gp->regs + TXDMA_CFG),
-	       readl(gp->regs + MAC_TXSTAT),
-	       readl(gp->regs + MAC_TXCFG));
-	printk(KERN_ERR "%s: RX_STATE[%08x:%08x:%08x]\n",
-	       dev->name,
-	       readl(gp->regs + RXDMA_CFG),
-	       readl(gp->regs + MAC_RXSTAT),
-	       readl(gp->regs + MAC_RXCFG));
+	netdev_err(dev, "TX_STATE[%08x:%08x:%08x]\n",
+		   readl(gp->regs + TXDMA_CFG),
+		   readl(gp->regs + MAC_TXSTAT),
+		   readl(gp->regs + MAC_TXCFG));
+	netdev_err(dev, "RX_STATE[%08x:%08x:%08x]\n",
+		   readl(gp->regs + RXDMA_CFG),
+		   readl(gp->regs + MAC_RXSTAT),
+		   readl(gp->regs + MAC_RXCFG));
 
 	spin_lock_irq(&gp->lock);
 	spin_lock(&gp->tx_lock);
@@ -1048,8 +1026,7 @@ static netdev_tx_t gem_start_xmit(struct sk_buff *skb,
 	if (TX_BUFFS_AVAIL(gp) <= (skb_shinfo(skb)->nr_frags + 1)) {
 		netif_stop_queue(dev);
 		spin_unlock_irqrestore(&gp->tx_lock, flags);
-		printk(KERN_ERR PFX "%s: BUG! Tx Ring full when queue awake!\n",
-		       dev->name);
+		netdev_err(dev, "BUG! Tx Ring full when queue awake!\n");
 		return NETDEV_TX_BUSY;
 	}
 
@@ -1158,8 +1135,7 @@ static void gem_pcs_reset(struct gem *gp)
 			break;
 	}
 	if (limit < 0)
-		printk(KERN_WARNING "%s: PCS reset bit would not clear.\n",
-		       gp->dev->name);
+		netdev_warn(gp->dev, "PCS reset bit would not clear\n");
 }
 
 static void gem_pcs_reinit_adv(struct gem *gp)
@@ -1230,7 +1206,7 @@ static void gem_reset(struct gem *gp)
 	} while (val & (GREG_SWRST_TXRST | GREG_SWRST_RXRST));
 
 	if (limit < 0)
-		printk(KERN_ERR "%s: SW reset is ghetto.\n", gp->dev->name);
+		netdev_err(gp->dev, "SW reset is ghetto\n");
 
 	if (gp->phy_type == phy_serialink || gp->phy_type == phy_serdes)
 		gem_pcs_reinit_adv(gp);
@@ -1395,9 +1371,8 @@ static int gem_set_link_modes(struct gem *gp)
 		speed = SPEED_1000;
 	}
 
-	if (netif_msg_link(gp))
-		printk(KERN_INFO "%s: Link is up at %d Mbps, %s-duplex.\n",
-			gp->dev->name, speed, (full_duplex ? "full" : "half"));
+	netif_info(gp, link, gp->dev, "Link is up at %d Mbps, %s-duplex\n",
+		   speed, (full_duplex ? "full" : "half"));
 
 	if (!gp->running)
 		return 0;
@@ -1451,15 +1426,13 @@ static int gem_set_link_modes(struct gem *gp)
 
 	if (netif_msg_link(gp)) {
 		if (pause) {
-			printk(KERN_INFO "%s: Pause is enabled "
-			       "(rxfifo: %d off: %d on: %d)\n",
-			       gp->dev->name,
-			       gp->rx_fifo_sz,
-			       gp->rx_pause_off,
-			       gp->rx_pause_on);
+			netdev_info(gp->dev,
+				    "Pause is enabled (rxfifo: %d off: %d on: %d)\n",
+				    gp->rx_fifo_sz,
+				    gp->rx_pause_off,
+				    gp->rx_pause_on);
 		} else {
-			printk(KERN_INFO "%s: Pause is disabled\n",
-			       gp->dev->name);
+			netdev_info(gp->dev, "Pause is disabled\n");
 		}
 	}
 
@@ -1484,9 +1457,8 @@ static int gem_mdio_link_not_up(struct gem *gp)
 {
 	switch (gp->lstate) {
 	case link_force_ret:
-		if (netif_msg_link(gp))
-			printk(KERN_INFO "%s: Autoneg failed again, keeping"
-				" forced mode\n", gp->dev->name);
+		netif_info(gp, link, gp->dev,
+			   "Autoneg failed again, keeping forced mode\n");
 		gp->phy_mii.def->ops->setup_forced(&gp->phy_mii,
 			gp->last_forced_speed, DUPLEX_HALF);
 		gp->timer_ticks = 5;
@@ -1499,9 +1471,7 @@ static int gem_mdio_link_not_up(struct gem *gp)
 		 */
 		if (gp->phy_mii.def->magic_aneg)
 			return 1;
-		if (netif_msg_link(gp))
-			printk(KERN_INFO "%s: switching to forced 100bt\n",
-				gp->dev->name);
+		netif_info(gp, link, gp->dev, "switching to forced 100bt\n");
 		/* Try forced modes. */
 		gp->phy_mii.def->ops->setup_forced(&gp->phy_mii, SPEED_100,
 			DUPLEX_HALF);
@@ -1517,9 +1487,8 @@ static int gem_mdio_link_not_up(struct gem *gp)
 			gp->phy_mii.def->ops->setup_forced(&gp->phy_mii, SPEED_10,
 				DUPLEX_HALF);
 			gp->timer_ticks = 5;
-			if (netif_msg_link(gp))
-				printk(KERN_INFO "%s: switching to forced 10bt\n",
-					gp->dev->name);
+			netif_info(gp, link, gp->dev,
+				   "switching to forced 10bt\n");
 			return 0;
 		} else
 			return 1;
@@ -1574,8 +1543,8 @@ static void gem_link_timer(unsigned long data)
 			gp->last_forced_speed = gp->phy_mii.speed;
 			gp->timer_ticks = 5;
 			if (netif_msg_link(gp))
-				printk(KERN_INFO "%s: Got link after fallback, retrying"
-					" autoneg once...\n", gp->dev->name);
+				netdev_info(gp->dev,
+					    "Got link after fallback, retrying autoneg once...\n");
 			gp->phy_mii.def->ops->setup_aneg(&gp->phy_mii, gp->phy_mii.advertising);
 		} else if (gp->lstate != link_up) {
 			gp->lstate = link_up;
@@ -1589,9 +1558,7 @@ static void gem_link_timer(unsigned long data)
 		 */
 		if (gp->lstate == link_up) {
 			gp->lstate = link_down;
-			if (netif_msg_link(gp))
-				printk(KERN_INFO "%s: Link down\n",
-					gp->dev->name);
+			netif_info(gp, link, gp->dev, "Link down\n");
 			netif_carrier_off(gp->dev);
 			gp->reset_task_pending = 1;
 			schedule_work(&gp->reset_task);
@@ -1746,8 +1713,7 @@ static void gem_init_phy(struct gem *gp)
 			if (phy_read(gp, MII_BMCR) != 0xffff)
 				break;
 			if (i == 2)
-				printk(KERN_WARNING "%s: GMAC PHY not responding !\n",
-				       gp->dev->name);
+				netdev_warn(gp->dev, "GMAC PHY not responding !\n");
 		}
 	}
 
@@ -2038,7 +2004,7 @@ static int gem_check_invariants(struct gem *gp)
 		 * as this chip has no gigabit PHY.
 		 */
 		if ((mif_cfg & (MIF_CFG_MDI0 | MIF_CFG_MDI1)) == 0) {
-			printk(KERN_ERR PFX "RIO GEM lacks MII phy, mif_cfg[%08x]\n",
+			pr_err("RIO GEM lacks MII phy, mif_cfg[%08x]\n",
 			       mif_cfg);
 			return -1;
 		}
@@ -2078,7 +2044,7 @@ static int gem_check_invariants(struct gem *gp)
 		}
 		if (i == 32) {
 			if (pdev->device != PCI_DEVICE_ID_SUN_GEM) {
-				printk(KERN_ERR PFX "RIO MII phy will not respond.\n");
+				pr_err("RIO MII phy will not respond\n");
 				return -1;
 			}
 			gp->phy_type = phy_serdes;
@@ -2093,7 +2059,7 @@ static int gem_check_invariants(struct gem *gp)
 		if (pdev->device == PCI_DEVICE_ID_SUN_GEM) {
 			if (gp->tx_fifo_sz != (9 * 1024) ||
 			    gp->rx_fifo_sz != (20 * 1024)) {
-				printk(KERN_ERR PFX "GEM has bogus fifo sizes tx(%d) rx(%d)\n",
+				pr_err("GEM has bogus fifo sizes tx(%d) rx(%d)\n",
 				       gp->tx_fifo_sz, gp->rx_fifo_sz);
 				return -1;
 			}
@@ -2101,7 +2067,7 @@ static int gem_check_invariants(struct gem *gp)
 		} else {
 			if (gp->tx_fifo_sz != (2 * 1024) ||
 			    gp->rx_fifo_sz != (2 * 1024)) {
-				printk(KERN_ERR PFX "RIO GEM has bogus fifo sizes tx(%d) rx(%d)\n",
+				pr_err("RIO GEM has bogus fifo sizes tx(%d) rx(%d)\n",
 				       gp->tx_fifo_sz, gp->rx_fifo_sz);
 				return -1;
 			}
@@ -2239,7 +2205,7 @@ static int gem_do_start(struct net_device *dev)
 
 	if (request_irq(gp->pdev->irq, gem_interrupt,
 				   IRQF_SHARED, dev->name, (void *)dev)) {
-		printk(KERN_ERR "%s: failed to request irq !\n", gp->dev->name);
+		netdev_err(dev, "failed to request irq !\n");
 
 		spin_lock_irqsave(&gp->lock, flags);
 		spin_lock(&gp->tx_lock);
@@ -2378,9 +2344,8 @@ static int gem_suspend(struct pci_dev *pdev, pm_message_t state)
 
 	mutex_lock(&gp->pm_mutex);
 
-	printk(KERN_INFO "%s: suspending, WakeOnLan %s\n",
-	       dev->name,
-	       (gp->wake_on_lan && gp->opened) ? "enabled" : "disabled");
+	netdev_info(dev, "suspending, WakeOnLan %s\n",
+		    (gp->wake_on_lan && gp->opened) ? "enabled" : "disabled");
 
 	/* Keep the cell enabled during the entire operation */
 	spin_lock_irqsave(&gp->lock, flags);
@@ -2440,7 +2405,7 @@ static int gem_resume(struct pci_dev *pdev)
 	struct gem *gp = netdev_priv(dev);
 	unsigned long flags;
 
-	printk(KERN_INFO "%s: resuming\n", dev->name);
+	netdev_info(dev, "resuming\n");
 
 	mutex_lock(&gp->pm_mutex);
 
@@ -2452,8 +2417,7 @@ static int gem_resume(struct pci_dev *pdev)
 
 	/* Make sure PCI access and bus master are enabled */
 	if (pci_enable_device(gp->pdev)) {
-		printk(KERN_ERR "%s: Can't re-enable chip !\n",
-		       dev->name);
+		netdev_err(dev, "Can't re-enable chip !\n");
 		/* Put cell and forget it for now, it will be considered as
 		 * still asleep, a new sleep cycle may bring it back
 		 */
@@ -2938,7 +2902,7 @@ static int __devinit gem_get_device_address(struct gem *gp)
 		addr = idprom->id_ethaddr;
 #else
 		printk("\n");
-		printk(KERN_ERR "%s: can't get mac-address\n", dev->name);
+		pr_err("%s: can't get mac-address\n", dev->name);
 		return -1;
 #endif
 	}
@@ -3009,14 +2973,12 @@ static const struct net_device_ops gem_netdev_ops = {
 static int __devinit gem_init_one(struct pci_dev *pdev,
 				  const struct pci_device_id *ent)
 {
-	static int gem_version_printed = 0;
 	unsigned long gemreg_base, gemreg_len;
 	struct net_device *dev;
 	struct gem *gp;
 	int err, pci_using_dac;
 
-	if (gem_version_printed++ == 0)
-		printk(KERN_INFO "%s", version);
+	printk_once(KERN_INFO "%s", version);
 
 	/* Apple gmac note: during probe, the chip is powered up by
 	 * the arch code to allow the code below to work (and to let
@@ -3026,8 +2988,7 @@ static int __devinit gem_init_one(struct pci_dev *pdev,
 	 */
 	err = pci_enable_device(pdev);
 	if (err) {
-		printk(KERN_ERR PFX "Cannot enable MMIO operation, "
-		       "aborting.\n");
+		pr_err("Cannot enable MMIO operation, aborting\n");
 		return err;
 	}
 	pci_set_master(pdev);
@@ -3048,8 +3009,7 @@ static int __devinit gem_init_one(struct pci_dev *pdev,
 	} else {
 		err = pci_set_dma_mask(pdev, DMA_BIT_MASK(32));
 		if (err) {
-			printk(KERN_ERR PFX "No usable DMA configuration, "
-			       "aborting.\n");
+			pr_err("No usable DMA configuration, aborting\n");
 			goto err_disable_device;
 		}
 		pci_using_dac = 0;
@@ -3059,15 +3019,14 @@ static int __devinit gem_init_one(struct pci_dev *pdev,
 	gemreg_len = pci_resource_len(pdev, 0);
 
 	if ((pci_resource_flags(pdev, 0) & IORESOURCE_IO) != 0) {
-		printk(KERN_ERR PFX "Cannot find proper PCI device "
-		       "base address, aborting.\n");
+		pr_err("Cannot find proper PCI device base address, aborting\n");
 		err = -ENODEV;
 		goto err_disable_device;
 	}
 
 	dev = alloc_etherdev(sizeof(*gp));
 	if (!dev) {
-		printk(KERN_ERR PFX "Etherdev alloc failed, aborting.\n");
+		pr_err("Etherdev alloc failed, aborting\n");
 		err = -ENOMEM;
 		goto err_disable_device;
 	}
@@ -3077,8 +3036,7 @@ static int __devinit gem_init_one(struct pci_dev *pdev,
 
 	err = pci_request_regions(pdev, DRV_NAME);
 	if (err) {
-		printk(KERN_ERR PFX "Cannot obtain PCI resources, "
-		       "aborting.\n");
+		pr_err("Cannot obtain PCI resources, aborting\n");
 		goto err_out_free_netdev;
 	}
 
@@ -3104,8 +3062,7 @@ static int __devinit gem_init_one(struct pci_dev *pdev,
 
 	gp->regs = ioremap(gemreg_base, gemreg_len);
 	if (!gp->regs) {
-		printk(KERN_ERR PFX "Cannot map device registers, "
-		       "aborting.\n");
+		pr_err("Cannot map device registers, aborting\n");
 		err = -EIO;
 		goto err_out_free_res;
 	}
@@ -3150,8 +3107,7 @@ static int __devinit gem_init_one(struct pci_dev *pdev,
 		pci_alloc_consistent(pdev, sizeof(struct gem_init_block),
 				     &gp->gblock_dvma);
 	if (!gp->init_block) {
-		printk(KERN_ERR PFX "Cannot allocate init block, "
-		       "aborting.\n");
+		pr_err("Cannot allocate init block, aborting\n");
 		err = -ENOMEM;
 		goto err_out_iounmap;
 	}
@@ -3180,19 +3136,18 @@ static int __devinit gem_init_one(struct pci_dev *pdev,
 
 	/* Register with kernel */
 	if (register_netdev(dev)) {
-		printk(KERN_ERR PFX "Cannot register net device, "
-		       "aborting.\n");
+		pr_err("Cannot register net device, aborting\n");
 		err = -ENOMEM;
 		goto err_out_free_consistent;
 	}
 
-	printk(KERN_INFO "%s: Sun GEM (PCI) 10/100/1000BaseT Ethernet %pM\n",
-	       dev->name, dev->dev_addr);
+	netdev_info(dev, "Sun GEM (PCI) 10/100/1000BaseT Ethernet %pM\n",
+		    dev->dev_addr);
 
 	if (gp->phy_type == phy_mii_mdio0 ||
      	    gp->phy_type == phy_mii_mdio1)
-		printk(KERN_INFO "%s: Found %s PHY\n", dev->name,
-			gp->phy_mii.def ? gp->phy_mii.def->name : "no");
+		netdev_info(dev, "Found %s PHY\n",
+			    gp->phy_mii.def ? gp->phy_mii.def->name : "no");
 
 	/* GEM can do it all... */
 	dev->features |= NETIF_F_SG | NETIF_F_HW_CSUM | NETIF_F_LLTX;
diff --git a/drivers/net/sungem_phy.c b/drivers/net/sungem_phy.c
index 78f8cee..4a4fac6 100644
--- a/drivers/net/sungem_phy.c
+++ b/drivers/net/sungem_phy.c
@@ -1175,7 +1175,8 @@ int mii_phy_probe(struct mii_phy *phy, int mii_id)
 
 	/* Read ID and find matching entry */
 	id = (phy_read(phy, MII_PHYSID1) << 16 | phy_read(phy, MII_PHYSID2));
-	printk(KERN_DEBUG "PHY ID: %x, addr: %x\n", id, mii_id);
+	printk(KERN_DEBUG KBUILD_MODNAME ": " "PHY ID: %x, addr: %x\n",
+	       id, mii_id);
 	for (i=0; (def = mii_phy_table[i]) != NULL; i++)
 		if ((id & def->phy_id_mask) == def->phy_id)
 			break;
-- 
1.7.2.19.g9a302

