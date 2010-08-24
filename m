From: Joe Perches <joe@perches.com>
Subject: [PATCH net-next - trivial] drivers/net: Remove address use from assignments of function pointers
Date: Mon, 23 Aug 2010 21:20:02 -0700
Message-ID: <1282623603-31052-1-git-send-email-joe@perches.com>
Cc: linux-kernel@vger.kernel.org
To: netdev@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

"foo = &function" is more commonly written "foo = function"

Done with coccinelle script:

// <smpl>
@r@
identifier f;
@@

f(...) { ... }

@@
identifier r.f;
@@

- &f
+ f
// </smpl>

drivers/net/tehuti.c used a function and struct with the
same name, the function was renamed.

Compile tested x86 only.

Signed-off-by: Joe Perches <joe@perches.com>
---
 drivers/net/3c503.c                |    8 +++---
 drivers/net/3c515.c                |    2 +-
 drivers/net/3c59x.c                |    2 +-
 drivers/net/atl1e/atl1e_main.c     |    2 +-
 drivers/net/atlx/atl1.c            |    2 +-
 drivers/net/atlx/atl2.c            |    4 +-
 drivers/net/atp.c                  |    2 +-
 drivers/net/bcm63xx_enet.c         |    2 +-
 drivers/net/cpmac.c                |    2 +-
 drivers/net/declance.c             |    2 +-
 drivers/net/dl2k.c                 |    2 +-
 drivers/net/e1000/e1000_main.c     |    6 ++--
 drivers/net/e1000e/netdev.c        |    4 +-
 drivers/net/ehea/ehea_main.c       |    6 ++--
 drivers/net/epic100.c              |    2 +-
 drivers/net/fealnx.c               |    4 +-
 drivers/net/forcedeth.c            |    6 ++--
 drivers/net/hamachi.c              |    2 +-
 drivers/net/hp.c                   |    8 +++---
 drivers/net/hydra.c                |    8 +++---
 drivers/net/igb/igb_main.c         |    4 +-
 drivers/net/ioc3-eth.c             |    2 +-
 drivers/net/ixgb/ixgb_main.c       |    2 +-
 drivers/net/ixgbe/ixgbe_main.c     |    4 +-
 drivers/net/ixgbevf/ixgbevf_main.c |    2 +-
 drivers/net/mac8390.c              |   48 ++++++++++++++++++------------------
 drivers/net/natsemi.c              |    2 +-
 drivers/net/pci-skeleton.c         |    2 +-
 drivers/net/pcmcia/3c574_cs.c      |    2 +-
 drivers/net/pcmcia/3c589_cs.c      |    2 +-
 drivers/net/pcmcia/axnet_cs.c      |   10 +++---
 drivers/net/pcmcia/pcnet_cs.c      |   16 ++++++------
 drivers/net/pcmcia/smc91c92_cs.c   |    4 +-
 drivers/net/rrunner.c              |    2 +-
 drivers/net/sh_eth.c               |    2 +-
 drivers/net/sis900.c               |    2 +-
 drivers/net/sunbmac.c              |    2 +-
 drivers/net/sundance.c             |    2 +-
 drivers/net/sunhme.c               |    2 +-
 drivers/net/sunlance.c             |    2 +-
 drivers/net/tehuti.c               |    8 +++---
 drivers/net/tlan.c                 |    8 +++---
 drivers/net/tulip/dmfe.c           |    2 +-
 drivers/net/tulip/uli526x.c        |    2 +-
 drivers/net/tulip/winbond-840.c    |    2 +-
 drivers/net/wan/lmc/lmc_main.c     |    2 +-
 drivers/net/wd.c                   |    8 +++---
 drivers/net/wireless/ray_cs.c      |   12 ++++----
 drivers/net/yellowfin.c            |    2 +-
 49 files changed, 118 insertions(+), 118 deletions(-)

diff --git a/drivers/net/3c503.c b/drivers/net/3c503.c
index baac246..4777a1c 100644
--- a/drivers/net/3c503.c
+++ b/drivers/net/3c503.c
@@ -337,10 +337,10 @@ el2_probe1(struct net_device *dev, int ioaddr)
     /* Finish setting the board's parameters. */
     ei_status.stop_page = EL2_MB1_STOP_PG;
     ei_status.word16 = wordlength;
-    ei_status.reset_8390 = &el2_reset_8390;
-    ei_status.get_8390_hdr = &el2_get_8390_hdr;
-    ei_status.block_input = &el2_block_input;
-    ei_status.block_output = &el2_block_output;
+    ei_status.reset_8390 = el2_reset_8390;
+    ei_status.get_8390_hdr = el2_get_8390_hdr;
+    ei_status.block_input = el2_block_input;
+    ei_status.block_output = el2_block_output;
 
     if (dev->irq == 2)
 	dev->irq = 9;
diff --git a/drivers/net/3c515.c b/drivers/net/3c515.c
index 3bba835..8a6eb0c 100644
--- a/drivers/net/3c515.c
+++ b/drivers/net/3c515.c
@@ -734,7 +734,7 @@ static int corkscrew_open(struct net_device *dev)
 		init_timer(&vp->timer);
 		vp->timer.expires = jiffies + media_tbl[dev->if_port].wait;
 		vp->timer.data = (unsigned long) dev;
-		vp->timer.function = &corkscrew_timer;	/* timer handler */
+		vp->timer.function = corkscrew_timer;	/* timer handler */
 		add_timer(&vp->timer);
 	} else
 		dev->if_port = vp->default_media;
diff --git a/drivers/net/3c59x.c b/drivers/net/3c59x.c
index c754d88..7a01588 100644
--- a/drivers/net/3c59x.c
+++ b/drivers/net/3c59x.c
@@ -1738,7 +1738,7 @@ vortex_open(struct net_device *dev)
 
 	/* Use the now-standard shared IRQ implementation. */
 	if ((retval = request_irq(dev->irq, vp->full_bus_master_rx ?
-				&boomerang_interrupt : &vortex_interrupt, IRQF_SHARED, dev->name, dev))) {
+				boomerang_interrupt : vortex_interrupt, IRQF_SHARED, dev->name, dev))) {
 		pr_err("%s: Could not reserve IRQ %d\n", dev->name, dev->irq);
 		goto err;
 	}
diff --git a/drivers/net/atl1e/atl1e_main.c b/drivers/net/atl1e/atl1e_main.c
index 1acea57..1ae44bb 100644
--- a/drivers/net/atl1e/atl1e_main.c
+++ b/drivers/net/atl1e/atl1e_main.c
@@ -2316,7 +2316,7 @@ static int __devinit atl1e_probe(struct pci_dev *pdev,
 	netif_napi_add(netdev, &adapter->napi, atl1e_clean, 64);
 
 	init_timer(&adapter->phy_config_timer);
-	adapter->phy_config_timer.function = &atl1e_phy_config;
+	adapter->phy_config_timer.function = atl1e_phy_config;
 	adapter->phy_config_timer.data = (unsigned long) adapter;
 
 	/* get user settings */
diff --git a/drivers/net/atlx/atl1.c b/drivers/net/atlx/atl1.c
index 63b9ba0..5837b01 100644
--- a/drivers/net/atlx/atl1.c
+++ b/drivers/net/atlx/atl1.c
@@ -3036,7 +3036,7 @@ static int __devinit atl1_probe(struct pci_dev *pdev,
 	netif_carrier_off(netdev);
 	netif_stop_queue(netdev);
 
-	setup_timer(&adapter->phy_config_timer, &atl1_phy_config,
+	setup_timer(&adapter->phy_config_timer, atl1_phy_config,
 		    (unsigned long)adapter);
 	adapter->phy_timer_pending = false;
 
diff --git a/drivers/net/atlx/atl2.c b/drivers/net/atlx/atl2.c
index 8da8738..07adc84 100644
--- a/drivers/net/atlx/atl2.c
+++ b/drivers/net/atlx/atl2.c
@@ -1444,11 +1444,11 @@ static int __devinit atl2_probe(struct pci_dev *pdev,
 	atl2_check_options(adapter);
 
 	init_timer(&adapter->watchdog_timer);
-	adapter->watchdog_timer.function = &atl2_watchdog;
+	adapter->watchdog_timer.function = atl2_watchdog;
 	adapter->watchdog_timer.data = (unsigned long) adapter;
 
 	init_timer(&adapter->phy_config_timer);
-	adapter->phy_config_timer.function = &atl2_phy_config;
+	adapter->phy_config_timer.function = atl2_phy_config;
 	adapter->phy_config_timer.data = (unsigned long) adapter;
 
 	INIT_WORK(&adapter->reset_task, atl2_reset_task);
diff --git a/drivers/net/atp.c b/drivers/net/atp.c
index bd2f9d3..dfd96b2 100644
--- a/drivers/net/atp.c
+++ b/drivers/net/atp.c
@@ -445,7 +445,7 @@ static int net_open(struct net_device *dev)
 	init_timer(&lp->timer);
 	lp->timer.expires = jiffies + TIMED_CHECKER;
 	lp->timer.data = (unsigned long)dev;
-	lp->timer.function = &atp_timed_checker;    /* timer handler */
+	lp->timer.function = atp_timed_checker;    /* timer handler */
 	add_timer(&lp->timer);
 
 	netif_start_queue(dev);
diff --git a/drivers/net/bcm63xx_enet.c b/drivers/net/bcm63xx_enet.c
index 0d2c5da..23a4162 100644
--- a/drivers/net/bcm63xx_enet.c
+++ b/drivers/net/bcm63xx_enet.c
@@ -798,7 +798,7 @@ static int bcm_enet_open(struct net_device *dev)
 		snprintf(phy_id, sizeof(phy_id), PHY_ID_FMT,
 			 priv->mac_id ? "1" : "0", priv->phy_id);
 
-		phydev = phy_connect(dev, phy_id, &bcm_enet_adjust_phy_link, 0,
+		phydev = phy_connect(dev, phy_id, bcm_enet_adjust_phy_link, 0,
 				     PHY_INTERFACE_MODE_MII);
 
 		if (IS_ERR(phydev)) {
diff --git a/drivers/net/cpmac.c b/drivers/net/cpmac.c
index 8e142aa..5a5af1c 100644
--- a/drivers/net/cpmac.c
+++ b/drivers/net/cpmac.c
@@ -1175,7 +1175,7 @@ static int __devinit cpmac_probe(struct platform_device *pdev)
 	snprintf(priv->phy_name, MII_BUS_ID_SIZE, PHY_ID_FMT,
 						mdio_bus_id, phy_id);
 
-	priv->phy = phy_connect(dev, priv->phy_name, &cpmac_adjust_link, 0,
+	priv->phy = phy_connect(dev, priv->phy_name, cpmac_adjust_link, 0,
 						PHY_INTERFACE_MODE_MII);
 
 	if (IS_ERR(priv->phy)) {
diff --git a/drivers/net/declance.c b/drivers/net/declance.c
index d7de376..219eb5a 100644
--- a/drivers/net/declance.c
+++ b/drivers/net/declance.c
@@ -1255,7 +1255,7 @@ static int __devinit dec_lance_probe(struct device *bdev, const int type)
 	 */
 	init_timer(&lp->multicast_timer);
 	lp->multicast_timer.data = (unsigned long) dev;
-	lp->multicast_timer.function = &lance_set_multicast_retry;
+	lp->multicast_timer.function = lance_set_multicast_retry;
 
 	ret = register_netdev(dev);
 	if (ret) {
diff --git a/drivers/net/dl2k.c b/drivers/net/dl2k.c
index a2f238d..e1a8216 100644
--- a/drivers/net/dl2k.c
+++ b/drivers/net/dl2k.c
@@ -465,7 +465,7 @@ rio_open (struct net_device *dev)
 	init_timer (&np->timer);
 	np->timer.expires = jiffies + 1*HZ;
 	np->timer.data = (unsigned long) dev;
-	np->timer.function = &rio_timer;
+	np->timer.function = rio_timer;
 	add_timer (&np->timer);
 
 	/* Start Tx/Rx */
diff --git a/drivers/net/e1000/e1000_main.c b/drivers/net/e1000/e1000_main.c
index 5cc39ed..3e8ac4b 100644
--- a/drivers/net/e1000/e1000_main.c
+++ b/drivers/net/e1000/e1000_main.c
@@ -962,15 +962,15 @@ static int __devinit e1000_probe(struct pci_dev *pdev,
 	e1000_get_bus_info(hw);
 
 	init_timer(&adapter->tx_fifo_stall_timer);
-	adapter->tx_fifo_stall_timer.function = &e1000_82547_tx_fifo_stall;
+	adapter->tx_fifo_stall_timer.function = e1000_82547_tx_fifo_stall;
 	adapter->tx_fifo_stall_timer.data = (unsigned long)adapter;
 
 	init_timer(&adapter->watchdog_timer);
-	adapter->watchdog_timer.function = &e1000_watchdog;
+	adapter->watchdog_timer.function = e1000_watchdog;
 	adapter->watchdog_timer.data = (unsigned long) adapter;
 
 	init_timer(&adapter->phy_info_timer);
-	adapter->phy_info_timer.function = &e1000_update_phy_info;
+	adapter->phy_info_timer.function = e1000_update_phy_info;
 	adapter->phy_info_timer.data = (unsigned long)adapter;
 
 	INIT_WORK(&adapter->reset_task, e1000_reset_task);
diff --git a/drivers/net/e1000e/netdev.c b/drivers/net/e1000e/netdev.c
index 2b8ef44..5f3eac6 100644
--- a/drivers/net/e1000e/netdev.c
+++ b/drivers/net/e1000e/netdev.c
@@ -5745,11 +5745,11 @@ static int __devinit e1000_probe(struct pci_dev *pdev,
 	}
 
 	init_timer(&adapter->watchdog_timer);
-	adapter->watchdog_timer.function = &e1000_watchdog;
+	adapter->watchdog_timer.function = e1000_watchdog;
 	adapter->watchdog_timer.data = (unsigned long) adapter;
 
 	init_timer(&adapter->phy_info_timer);
-	adapter->phy_info_timer.function = &e1000_update_phy_info;
+	adapter->phy_info_timer.function = e1000_update_phy_info;
 	adapter->phy_info_timer.data = (unsigned long) adapter;
 
 	INIT_WORK(&adapter->reset_task, e1000_reset_task);
diff --git a/drivers/net/ehea/ehea_main.c b/drivers/net/ehea/ehea_main.c
index 2b98ee8..043d990 100644
--- a/drivers/net/ehea/ehea_main.c
+++ b/drivers/net/ehea/ehea_main.c
@@ -3721,7 +3721,7 @@ int __init ehea_module_init(void)
 	if (ret)
 		ehea_info("failed registering memory remove notifier");
 
-	ret = crash_shutdown_register(&ehea_crash_handler);
+	ret = crash_shutdown_register(ehea_crash_handler);
 	if (ret)
 		ehea_info("failed registering crash handler");
 
@@ -3746,7 +3746,7 @@ out3:
 out2:
 	unregister_memory_notifier(&ehea_mem_nb);
 	unregister_reboot_notifier(&ehea_reboot_nb);
-	crash_shutdown_unregister(&ehea_crash_handler);
+	crash_shutdown_unregister(ehea_crash_handler);
 out:
 	return ret;
 }
@@ -3759,7 +3759,7 @@ static void __exit ehea_module_exit(void)
 	driver_remove_file(&ehea_driver.driver, &driver_attr_capabilities);
 	ibmebus_unregister_driver(&ehea_driver);
 	unregister_reboot_notifier(&ehea_reboot_nb);
-	ret = crash_shutdown_unregister(&ehea_crash_handler);
+	ret = crash_shutdown_unregister(ehea_crash_handler);
 	if (ret)
 		ehea_info("failed unregistering crash handler");
 	unregister_memory_notifier(&ehea_mem_nb);
diff --git a/drivers/net/epic100.c b/drivers/net/epic100.c
index 57c8ac0..32543a3 100644
--- a/drivers/net/epic100.c
+++ b/drivers/net/epic100.c
@@ -758,7 +758,7 @@ static int epic_open(struct net_device *dev)
 	init_timer(&ep->timer);
 	ep->timer.expires = jiffies + 3*HZ;
 	ep->timer.data = (unsigned long)dev;
-	ep->timer.function = &epic_timer;				/* timer handler */
+	ep->timer.function = epic_timer;				/* timer handler */
 	add_timer(&ep->timer);
 
 	return 0;
diff --git a/drivers/net/fealnx.c b/drivers/net/fealnx.c
index d7e8f6b..dd54abe 100644
--- a/drivers/net/fealnx.c
+++ b/drivers/net/fealnx.c
@@ -915,14 +915,14 @@ static int netdev_open(struct net_device *dev)
 	init_timer(&np->timer);
 	np->timer.expires = RUN_AT(3 * HZ);
 	np->timer.data = (unsigned long) dev;
-	np->timer.function = &netdev_timer;
+	np->timer.function = netdev_timer;
 
 	/* timer handler */
 	add_timer(&np->timer);
 
 	init_timer(&np->reset_timer);
 	np->reset_timer.data = (unsigned long) dev;
-	np->reset_timer.function = &reset_timer;
+	np->reset_timer.function = reset_timer;
 	np->reset_timer_armed = 0;
 
 	return 0;
diff --git a/drivers/net/forcedeth.c b/drivers/net/forcedeth.c
index 4da05b1..6a44fe4 100644
--- a/drivers/net/forcedeth.c
+++ b/drivers/net/forcedeth.c
@@ -5440,13 +5440,13 @@ static int __devinit nv_probe(struct pci_dev *pci_dev, const struct pci_device_i
 
 	init_timer(&np->oom_kick);
 	np->oom_kick.data = (unsigned long) dev;
-	np->oom_kick.function = &nv_do_rx_refill;	/* timer handler */
+	np->oom_kick.function = nv_do_rx_refill;	/* timer handler */
 	init_timer(&np->nic_poll);
 	np->nic_poll.data = (unsigned long) dev;
-	np->nic_poll.function = &nv_do_nic_poll;	/* timer handler */
+	np->nic_poll.function = nv_do_nic_poll;	/* timer handler */
 	init_timer(&np->stats_poll);
 	np->stats_poll.data = (unsigned long) dev;
-	np->stats_poll.function = &nv_do_stats_poll;	/* timer handler */
+	np->stats_poll.function = nv_do_stats_poll;	/* timer handler */
 
 	err = pci_enable_device(pci_dev);
 	if (err)
diff --git a/drivers/net/hamachi.c b/drivers/net/hamachi.c
index 49aac70..9a64858 100644
--- a/drivers/net/hamachi.c
+++ b/drivers/net/hamachi.c
@@ -1004,7 +1004,7 @@ static int hamachi_open(struct net_device *dev)
 	init_timer(&hmp->timer);
 	hmp->timer.expires = RUN_AT((24*HZ)/10);			/* 2.4 sec. */
 	hmp->timer.data = (unsigned long)dev;
-	hmp->timer.function = &hamachi_timer;				/* timer handler */
+	hmp->timer.function = hamachi_timer;				/* timer handler */
 	add_timer(&hmp->timer);
 
 	return 0;
diff --git a/drivers/net/hp.c b/drivers/net/hp.c
index 86ececd..d15d2f2 100644
--- a/drivers/net/hp.c
+++ b/drivers/net/hp.c
@@ -204,10 +204,10 @@ static int __init hp_probe1(struct net_device *dev, int ioaddr)
 	ei_status.rx_start_page = HP_START_PG + TX_PAGES;
 	ei_status.stop_page = wordmode ? HP_16BSTOP_PG : HP_8BSTOP_PG;
 
-	ei_status.reset_8390 = &hp_reset_8390;
-	ei_status.get_8390_hdr = &hp_get_8390_hdr;
-	ei_status.block_input = &hp_block_input;
-	ei_status.block_output = &hp_block_output;
+	ei_status.reset_8390 = hp_reset_8390;
+	ei_status.get_8390_hdr = hp_get_8390_hdr;
+	ei_status.block_input = hp_block_input;
+	ei_status.block_output = hp_block_output;
 	hp_init_card(dev);
 
 	retval = register_netdev(dev);
diff --git a/drivers/net/hydra.c b/drivers/net/hydra.c
index 07d8e5b..376e953 100644
--- a/drivers/net/hydra.c
+++ b/drivers/net/hydra.c
@@ -155,10 +155,10 @@ static int __devinit hydra_init(struct zorro_dev *z)
 
     ei_status.rx_start_page = start_page + TX_PAGES;
 
-    ei_status.reset_8390 = &hydra_reset_8390;
-    ei_status.block_input = &hydra_block_input;
-    ei_status.block_output = &hydra_block_output;
-    ei_status.get_8390_hdr = &hydra_get_8390_hdr;
+    ei_status.reset_8390 = hydra_reset_8390;
+    ei_status.block_input = hydra_block_input;
+    ei_status.block_output = hydra_block_output;
+    ei_status.get_8390_hdr = hydra_get_8390_hdr;
     ei_status.reg_offset = hydra_offsets;
 
     dev->netdev_ops = &hydra_netdev_ops;
diff --git a/drivers/net/igb/igb_main.c b/drivers/net/igb/igb_main.c
index 985e37c..d35cc38 100644
--- a/drivers/net/igb/igb_main.c
+++ b/drivers/net/igb/igb_main.c
@@ -1888,9 +1888,9 @@ static int __devinit igb_probe(struct pci_dev *pdev,
 		goto err_eeprom;
 	}
 
-	setup_timer(&adapter->watchdog_timer, &igb_watchdog,
+	setup_timer(&adapter->watchdog_timer, igb_watchdog,
 	            (unsigned long) adapter);
-	setup_timer(&adapter->phy_info_timer, &igb_update_phy_info,
+	setup_timer(&adapter->phy_info_timer, igb_update_phy_info,
 	            (unsigned long) adapter);
 
 	INIT_WORK(&adapter->reset_task, igb_reset_task);
diff --git a/drivers/net/ioc3-eth.c b/drivers/net/ioc3-eth.c
index 0b3f6df..c8ee8d2 100644
--- a/drivers/net/ioc3-eth.c
+++ b/drivers/net/ioc3-eth.c
@@ -827,7 +827,7 @@ static void ioc3_mii_start(struct ioc3_private *ip)
 {
 	ip->ioc3_timer.expires = jiffies + (12 * HZ)/10;  /* 1.2 sec. */
 	ip->ioc3_timer.data = (unsigned long) ip;
-	ip->ioc3_timer.function = &ioc3_timer;
+	ip->ioc3_timer.function = ioc3_timer;
 	add_timer(&ip->ioc3_timer);
 }
 
diff --git a/drivers/net/ixgb/ixgb_main.c b/drivers/net/ixgb/ixgb_main.c
index 45fc89b..33c4ffe 100644
--- a/drivers/net/ixgb/ixgb_main.c
+++ b/drivers/net/ixgb/ixgb_main.c
@@ -470,7 +470,7 @@ ixgb_probe(struct pci_dev *pdev, const struct pci_device_id *ent)
 	adapter->part_num = ixgb_get_ee_pba_number(&adapter->hw);
 
 	init_timer(&adapter->watchdog_timer);
-	adapter->watchdog_timer.function = &ixgb_watchdog;
+	adapter->watchdog_timer.function = ixgb_watchdog;
 	adapter->watchdog_timer.data = (unsigned long)adapter;
 
 	INIT_WORK(&adapter->tx_timeout_task, ixgb_tx_timeout_task);
diff --git a/drivers/net/ixgbe/ixgbe_main.c b/drivers/net/ixgbe/ixgbe_main.c
index 18163e3..5e4dc1b 100644
--- a/drivers/net/ixgbe/ixgbe_main.c
+++ b/drivers/net/ixgbe/ixgbe_main.c
@@ -6730,7 +6730,7 @@ static int __devinit ixgbe_probe(struct pci_dev *pdev,
 	 * which might start the timer
 	 */
 	init_timer(&adapter->sfp_timer);
-	adapter->sfp_timer.function = &ixgbe_sfp_timer;
+	adapter->sfp_timer.function = ixgbe_sfp_timer;
 	adapter->sfp_timer.data = (unsigned long) adapter;
 
 	INIT_WORK(&adapter->sfp_task, ixgbe_sfp_task);
@@ -6862,7 +6862,7 @@ static int __devinit ixgbe_probe(struct pci_dev *pdev,
 		hw->mac.ops.disable_tx_laser(hw);
 
 	init_timer(&adapter->watchdog_timer);
-	adapter->watchdog_timer.function = &ixgbe_watchdog;
+	adapter->watchdog_timer.function = ixgbe_watchdog;
 	adapter->watchdog_timer.data = (unsigned long)adapter;
 
 	INIT_WORK(&adapter->reset_task, ixgbe_reset_task);
diff --git a/drivers/net/ixgbevf/ixgbevf_main.c b/drivers/net/ixgbevf/ixgbevf_main.c
index 918c003..5d3c869 100644
--- a/drivers/net/ixgbevf/ixgbevf_main.c
+++ b/drivers/net/ixgbevf/ixgbevf_main.c
@@ -3426,7 +3426,7 @@ static int __devinit ixgbevf_probe(struct pci_dev *pdev,
 	}
 
 	init_timer(&adapter->watchdog_timer);
-	adapter->watchdog_timer.function = &ixgbevf_watchdog;
+	adapter->watchdog_timer.function = ixgbevf_watchdog;
 	adapter->watchdog_timer.data = (unsigned long)adapter;
 
 	INIT_WORK(&adapter->reset_task, ixgbevf_reset_task);
diff --git a/drivers/net/mac8390.c b/drivers/net/mac8390.c
index 3832fa4..f84f5e6 100644
--- a/drivers/net/mac8390.c
+++ b/drivers/net/mac8390.c
@@ -562,19 +562,19 @@ static int __init mac8390_initdev(struct net_device *dev,
 
 		case ACCESS_16:
 			/* 16 bit card, register map is reversed */
-			ei_status.reset_8390 = &mac8390_no_reset;
-			ei_status.block_input = &slow_sane_block_input;
-			ei_status.block_output = &slow_sane_block_output;
-			ei_status.get_8390_hdr = &slow_sane_get_8390_hdr;
+			ei_status.reset_8390 = mac8390_no_reset;
+			ei_status.block_input = slow_sane_block_input;
+			ei_status.block_output = slow_sane_block_output;
+			ei_status.get_8390_hdr = slow_sane_get_8390_hdr;
 			ei_status.reg_offset = back4_offsets;
 			break;
 
 		case ACCESS_32:
 			/* 32 bit card, register map is reversed */
-			ei_status.reset_8390 = &mac8390_no_reset;
-			ei_status.block_input = &sane_block_input;
-			ei_status.block_output = &sane_block_output;
-			ei_status.get_8390_hdr = &sane_get_8390_hdr;
+			ei_status.reset_8390 = mac8390_no_reset;
+			ei_status.block_input = sane_block_input;
+			ei_status.block_output = sane_block_output;
+			ei_status.get_8390_hdr = sane_get_8390_hdr;
 			ei_status.reg_offset = back4_offsets;
 			access_bitmode = 1;
 			break;
@@ -586,19 +586,19 @@ static int __init mac8390_initdev(struct net_device *dev,
 		 * but overwrite system memory when run at 32 bit.
 		 * so we run them all at 16 bit.
 		 */
-		ei_status.reset_8390 = &mac8390_no_reset;
-		ei_status.block_input = &slow_sane_block_input;
-		ei_status.block_output = &slow_sane_block_output;
-		ei_status.get_8390_hdr = &slow_sane_get_8390_hdr;
+		ei_status.reset_8390 = mac8390_no_reset;
+		ei_status.block_input = slow_sane_block_input;
+		ei_status.block_output = slow_sane_block_output;
+		ei_status.get_8390_hdr = slow_sane_get_8390_hdr;
 		ei_status.reg_offset = back4_offsets;
 		break;
 
 	case MAC8390_CABLETRON:
 		/* 16 bit card, register map is short forward */
-		ei_status.reset_8390 = &mac8390_no_reset;
-		ei_status.block_input = &slow_sane_block_input;
-		ei_status.block_output = &slow_sane_block_output;
-		ei_status.get_8390_hdr = &slow_sane_get_8390_hdr;
+		ei_status.reset_8390 = mac8390_no_reset;
+		ei_status.block_input = slow_sane_block_input;
+		ei_status.block_output = slow_sane_block_output;
+		ei_status.get_8390_hdr = slow_sane_get_8390_hdr;
 		ei_status.reg_offset = fwrd2_offsets;
 		break;
 
@@ -606,19 +606,19 @@ static int __init mac8390_initdev(struct net_device *dev,
 	case MAC8390_KINETICS:
 		/* 16 bit memory, register map is forward */
 		/* dayna and similar */
-		ei_status.reset_8390 = &mac8390_no_reset;
-		ei_status.block_input = &dayna_block_input;
-		ei_status.block_output = &dayna_block_output;
-		ei_status.get_8390_hdr = &dayna_get_8390_hdr;
+		ei_status.reset_8390 = mac8390_no_reset;
+		ei_status.block_input = dayna_block_input;
+		ei_status.block_output = dayna_block_output;
+		ei_status.get_8390_hdr = dayna_get_8390_hdr;
 		ei_status.reg_offset = fwrd4_offsets;
 		break;
 
 	case MAC8390_INTERLAN:
 		/* 16 bit memory, register map is forward */
-		ei_status.reset_8390 = &interlan_reset;
-		ei_status.block_input = &slow_sane_block_input;
-		ei_status.block_output = &slow_sane_block_output;
-		ei_status.get_8390_hdr = &slow_sane_get_8390_hdr;
+		ei_status.reset_8390 = interlan_reset;
+		ei_status.block_input = slow_sane_block_input;
+		ei_status.block_output = slow_sane_block_output;
+		ei_status.get_8390_hdr = slow_sane_get_8390_hdr;
 		ei_status.reg_offset = fwrd4_offsets;
 		break;
 
diff --git a/drivers/net/natsemi.c b/drivers/net/natsemi.c
index a6033d4..2fd3963 100644
--- a/drivers/net/natsemi.c
+++ b/drivers/net/natsemi.c
@@ -1570,7 +1570,7 @@ static int netdev_open(struct net_device *dev)
 	init_timer(&np->timer);
 	np->timer.expires = round_jiffies(jiffies + NATSEMI_TIMER_FREQ);
 	np->timer.data = (unsigned long)dev;
-	np->timer.function = &netdev_timer; /* timer handler */
+	np->timer.function = netdev_timer; /* timer handler */
 	add_timer(&np->timer);
 
 	return 0;
diff --git a/drivers/net/pci-skeleton.c b/drivers/net/pci-skeleton.c
index 56f3fc4..8dd0343 100644
--- a/drivers/net/pci-skeleton.c
+++ b/drivers/net/pci-skeleton.c
@@ -1125,7 +1125,7 @@ static int netdrv_open(struct net_device *dev)
 	init_timer(&tp->timer);
 	tp->timer.expires = jiffies + 3 * HZ;
 	tp->timer.data = (unsigned long) dev;
-	tp->timer.function = &netdrv_timer;
+	tp->timer.function = netdrv_timer;
 	add_timer(&tp->timer);
 
 	DPRINTK("EXIT, returning 0\n");
diff --git a/drivers/net/pcmcia/3c574_cs.c b/drivers/net/pcmcia/3c574_cs.c
index 9b319be..042f677 100644
--- a/drivers/net/pcmcia/3c574_cs.c
+++ b/drivers/net/pcmcia/3c574_cs.c
@@ -707,7 +707,7 @@ static int el3_open(struct net_device *dev)
 	netif_start_queue(dev);
 	
 	tc574_reset(dev);
-	lp->media.function = &media_check;
+	lp->media.function = media_check;
 	lp->media.data = (unsigned long) dev;
 	lp->media.expires = jiffies + HZ;
 	add_timer(&lp->media);
diff --git a/drivers/net/pcmcia/3c589_cs.c b/drivers/net/pcmcia/3c589_cs.c
index 1c534f3..7f2baf5 100644
--- a/drivers/net/pcmcia/3c589_cs.c
+++ b/drivers/net/pcmcia/3c589_cs.c
@@ -538,7 +538,7 @@ static int el3_open(struct net_device *dev)
 
     tc589_reset(dev);
     init_timer(&lp->media);
-    lp->media.function = &media_check;
+    lp->media.function = media_check;
     lp->media.data = (unsigned long) dev;
     lp->media.expires = jiffies + HZ;
     add_timer(&lp->media);
diff --git a/drivers/net/pcmcia/axnet_cs.c b/drivers/net/pcmcia/axnet_cs.c
index e97f151..3f61fde 100644
--- a/drivers/net/pcmcia/axnet_cs.c
+++ b/drivers/net/pcmcia/axnet_cs.c
@@ -356,10 +356,10 @@ static int axnet_config(struct pcmcia_device *link)
     ei_status.tx_start_page = AXNET_START_PG;
     ei_status.rx_start_page = AXNET_START_PG + TX_PAGES;
     ei_status.stop_page = AXNET_STOP_PG;
-    ei_status.reset_8390 = &axnet_reset_8390;
-    ei_status.get_8390_hdr = &get_8390_hdr;
-    ei_status.block_input = &block_input;
-    ei_status.block_output = &block_output;
+    ei_status.reset_8390 = axnet_reset_8390;
+    ei_status.get_8390_hdr = get_8390_hdr;
+    ei_status.block_input = block_input;
+    ei_status.block_output = block_output;
 
     if (inb(dev->base_addr + AXNET_TEST) != 0)
 	info->flags |= IS_AX88790;
@@ -530,7 +530,7 @@ static int axnet_open(struct net_device *dev)
 
     info->link_status = 0x00;
     init_timer(&info->watchdog);
-    info->watchdog.function = &ei_watchdog;
+    info->watchdog.function = ei_watchdog;
     info->watchdog.data = (u_long)dev;
     info->watchdog.expires = jiffies + HZ;
     add_timer(&info->watchdog);
diff --git a/drivers/net/pcmcia/pcnet_cs.c b/drivers/net/pcmcia/pcnet_cs.c
index 1815b26..5ad42e0 100644
--- a/drivers/net/pcmcia/pcnet_cs.c
+++ b/drivers/net/pcmcia/pcnet_cs.c
@@ -624,7 +624,7 @@ static int pcnet_config(struct pcmcia_device *link)
 
     ei_status.name = "NE2000";
     ei_status.word16 = 1;
-    ei_status.reset_8390 = &pcnet_reset_8390;
+    ei_status.reset_8390 = pcnet_reset_8390;
 
     if (info->flags & (IS_DL10019|IS_DL10022))
 	mii_phy_probe(dev);
@@ -957,7 +957,7 @@ static int pcnet_open(struct net_device *dev)
     info->phy_id = info->eth_phy;
     info->link_status = 0x00;
     init_timer(&info->watchdog);
-    info->watchdog.function = &ei_watchdog;
+    info->watchdog.function = ei_watchdog;
     info->watchdog.data = (u_long)dev;
     info->watchdog.expires = jiffies + HZ;
     add_timer(&info->watchdog);
@@ -1341,9 +1341,9 @@ static int setup_dma_config(struct pcmcia_device *link, int start_pg,
     ei_status.stop_page = stop_pg;
 
     /* set up block i/o functions */
-    ei_status.get_8390_hdr = &dma_get_8390_hdr;
-    ei_status.block_input = &dma_block_input;
-    ei_status.block_output = &dma_block_output;
+    ei_status.get_8390_hdr = dma_get_8390_hdr;
+    ei_status.block_input = dma_block_input;
+    ei_status.block_output = dma_block_output;
 
     return 0;
 }
@@ -1489,9 +1489,9 @@ static int setup_shmem_window(struct pcmcia_device *link, int start_pg,
     ei_status.stop_page = start_pg + ((req.Size - offset) >> 8);
 
     /* set up block i/o functions */
-    ei_status.get_8390_hdr = &shmem_get_8390_hdr;
-    ei_status.block_input = &shmem_block_input;
-    ei_status.block_output = &shmem_block_output;
+    ei_status.get_8390_hdr = shmem_get_8390_hdr;
+    ei_status.block_input = shmem_block_input;
+    ei_status.block_output = shmem_block_output;
 
     info->flags |= USE_SHMEM;
     return 0;
diff --git a/drivers/net/pcmcia/smc91c92_cs.c b/drivers/net/pcmcia/smc91c92_cs.c
index cc7a357..3d1c549 100644
--- a/drivers/net/pcmcia/smc91c92_cs.c
+++ b/drivers/net/pcmcia/smc91c92_cs.c
@@ -296,7 +296,7 @@ static const struct net_device_ops smc_netdev_ops = {
 	.ndo_tx_timeout 	= smc_tx_timeout,
 	.ndo_set_config 	= s9k_config,
 	.ndo_set_multicast_list = set_rx_mode,
-	.ndo_do_ioctl		= &smc_ioctl,
+	.ndo_do_ioctl		= smc_ioctl,
 	.ndo_change_mtu		= eth_change_mtu,
 	.ndo_set_mac_address 	= eth_mac_addr,
 	.ndo_validate_addr	= eth_validate_addr,
@@ -1117,7 +1117,7 @@ static int smc_open(struct net_device *dev)
 
     smc_reset(dev);
     init_timer(&smc->media);
-    smc->media.function = &media_check;
+    smc->media.function = media_check;
     smc->media.data = (u_long) dev;
     smc->media.expires = jiffies + HZ;
     add_timer(&smc->media);
diff --git a/drivers/net/rrunner.c b/drivers/net/rrunner.c
index e26e107..e68c941 100644
--- a/drivers/net/rrunner.c
+++ b/drivers/net/rrunner.c
@@ -1245,7 +1245,7 @@ static int rr_open(struct net_device *dev)
 	init_timer(&rrpriv->timer);
 	rrpriv->timer.expires = RUN_AT(5*HZ);           /* 5 sec. watchdog */
 	rrpriv->timer.data = (unsigned long)dev;
-	rrpriv->timer.function = &rr_timer;               /* timer handler */
+	rrpriv->timer.function = rr_timer;               /* timer handler */
 	add_timer(&rrpriv->timer);
 
 	netif_start_queue(dev);
diff --git a/drivers/net/sh_eth.c b/drivers/net/sh_eth.c
index 79fd02b..a812efc 100644
--- a/drivers/net/sh_eth.c
+++ b/drivers/net/sh_eth.c
@@ -1031,7 +1031,7 @@ static int sh_eth_phy_init(struct net_device *ndev)
 	mdp->duplex = -1;
 
 	/* Try connect to PHY */
-	phydev = phy_connect(ndev, phy_id, &sh_eth_adjust_link,
+	phydev = phy_connect(ndev, phy_id, sh_eth_adjust_link,
 				0, PHY_INTERFACE_MODE_MII);
 	if (IS_ERR(phydev)) {
 		dev_err(&ndev->dev, "phy_connect failed\n");
diff --git a/drivers/net/sis900.c b/drivers/net/sis900.c
index bbbded7..ffdd859 100644
--- a/drivers/net/sis900.c
+++ b/drivers/net/sis900.c
@@ -1042,7 +1042,7 @@ sis900_open(struct net_device *net_dev)
 	init_timer(&sis_priv->timer);
 	sis_priv->timer.expires = jiffies + HZ;
 	sis_priv->timer.data = (unsigned long)net_dev;
-	sis_priv->timer.function = &sis900_timer;
+	sis_priv->timer.function = sis900_timer;
 	add_timer(&sis_priv->timer);
 
 	return 0;
diff --git a/drivers/net/sunbmac.c b/drivers/net/sunbmac.c
index 618643e..0a6a5ce 100644
--- a/drivers/net/sunbmac.c
+++ b/drivers/net/sunbmac.c
@@ -617,7 +617,7 @@ static void bigmac_begin_auto_negotiation(struct bigmac *bp)
 	bp->timer_ticks = 0;
 	bp->bigmac_timer.expires = jiffies + (12 * HZ) / 10;
 	bp->bigmac_timer.data = (unsigned long) bp;
-	bp->bigmac_timer.function = &bigmac_timer;
+	bp->bigmac_timer.function = bigmac_timer;
 	add_timer(&bp->bigmac_timer);
 }
 
diff --git a/drivers/net/sundance.c b/drivers/net/sundance.c
index 2678588..3fa9497 100644
--- a/drivers/net/sundance.c
+++ b/drivers/net/sundance.c
@@ -874,7 +874,7 @@ static int netdev_open(struct net_device *dev)
 	init_timer(&np->timer);
 	np->timer.expires = jiffies + 3*HZ;
 	np->timer.data = (unsigned long)dev;
-	np->timer.function = &netdev_timer;				/* timer handler */
+	np->timer.function = netdev_timer;				/* timer handler */
 	add_timer(&np->timer);
 
 	/* Enable interrupts by setting the interrupt mask. */
diff --git a/drivers/net/sunhme.c b/drivers/net/sunhme.c
index d96431e..45f315e 100644
--- a/drivers/net/sunhme.c
+++ b/drivers/net/sunhme.c
@@ -1409,7 +1409,7 @@ force_link:
 	hp->timer_ticks = 0;
 	hp->happy_timer.expires = jiffies + (12 * HZ)/10;  /* 1.2 sec. */
 	hp->happy_timer.data = (unsigned long) hp;
-	hp->happy_timer.function = &happy_meal_timer;
+	hp->happy_timer.function = happy_meal_timer;
 	add_timer(&hp->happy_timer);
 }
 
diff --git a/drivers/net/sunlance.c b/drivers/net/sunlance.c
index 8dcb858..2cf84e5 100644
--- a/drivers/net/sunlance.c
+++ b/drivers/net/sunlance.c
@@ -1483,7 +1483,7 @@ no_link_test:
 	 */
 	init_timer(&lp->multicast_timer);
 	lp->multicast_timer.data = (unsigned long) dev;
-	lp->multicast_timer.function = &lance_set_multicast_retry;
+	lp->multicast_timer.function = lance_set_multicast_retry;
 
 	if (register_netdev(dev)) {
 		printk(KERN_ERR "SunLance: Cannot register device.\n");
diff --git a/drivers/net/tehuti.c b/drivers/net/tehuti.c
index d808f95..3128d6a 100644
--- a/drivers/net/tehuti.c
+++ b/drivers/net/tehuti.c
@@ -92,7 +92,7 @@ static void bdx_rx_free(struct bdx_priv *priv);
 static void bdx_tx_free(struct bdx_priv *priv);
 
 /* Definitions needed by bdx_probe */
-static void bdx_ethtool_ops(struct net_device *netdev);
+static void bdx_set_ethtool_ops(struct net_device *netdev);
 
 /*************************************************************************
  *    Print Info                                                         *
@@ -2005,7 +2005,7 @@ bdx_probe(struct pci_dev *pdev, const struct pci_device_id *ent)
 		ndev->netdev_ops = &bdx_netdev_ops;
 		ndev->tx_queue_len = BDX_NDEV_TXQ_LEN;
 
-		bdx_ethtool_ops(ndev);	/* ethtool interface */
+		bdx_set_ethtool_ops(ndev);	/* ethtool interface */
 
 		/* these fields are used for info purposes only
 		 * so we can have them same for all ports of the board */
@@ -2410,10 +2410,10 @@ static void bdx_get_ethtool_stats(struct net_device *netdev,
 }
 
 /*
- * bdx_ethtool_ops - ethtool interface implementation
+ * bdx_set_ethtool_ops - ethtool interface implementation
  * @netdev
  */
-static void bdx_ethtool_ops(struct net_device *netdev)
+static void bdx_set_ethtool_ops(struct net_device *netdev)
 {
 	static const struct ethtool_ops bdx_ethtool_ops = {
 		.get_settings = bdx_get_settings,
diff --git a/drivers/net/tlan.c b/drivers/net/tlan.c
index ccee3ed..0564ca0 100644
--- a/drivers/net/tlan.c
+++ b/drivers/net/tlan.c
@@ -393,7 +393,7 @@ TLan_SetTimer( struct net_device *dev, u32 ticks, u32 type )
 			spin_unlock_irqrestore(&priv->lock, flags);
 		return;
 	}
-	priv->timer.function = &TLan_Timer;
+	priv->timer.function = TLan_Timer;
 	if (!in_irq())
 		spin_unlock_irqrestore(&priv->lock, flags);
 
@@ -1453,7 +1453,7 @@ static u32 TLan_HandleTxEOF( struct net_device *dev, u16 host_int )
 		TLan_DioWrite8( dev->base_addr,
 				TLAN_LED_REG, TLAN_LED_LINK | TLAN_LED_ACT );
 		if ( priv->timer.function == NULL ) {
-			 priv->timer.function = &TLan_Timer;
+			 priv->timer.function = TLan_Timer;
 			 priv->timer.data = (unsigned long) dev;
 			 priv->timer.expires = jiffies + TLAN_TIMER_ACT_DELAY;
 			 priv->timerSetAt = jiffies;
@@ -1601,7 +1601,7 @@ drop_and_reuse:
 		TLan_DioWrite8( dev->base_addr,
 				TLAN_LED_REG, TLAN_LED_LINK | TLAN_LED_ACT );
 		if ( priv->timer.function == NULL )  {
-			priv->timer.function = &TLan_Timer;
+			priv->timer.function = TLan_Timer;
 			priv->timer.data = (unsigned long) dev;
 			priv->timer.expires = jiffies + TLAN_TIMER_ACT_DELAY;
 			priv->timerSetAt = jiffies;
@@ -1897,7 +1897,7 @@ static void TLan_Timer( unsigned long data )
 					TLan_DioWrite8( dev->base_addr,
 							TLAN_LED_REG, TLAN_LED_LINK );
 				} else  {
-					priv->timer.function = &TLan_Timer;
+					priv->timer.function = TLan_Timer;
 					priv->timer.expires = priv->timerSetAt
 						+ TLAN_TIMER_ACT_DELAY;
 					spin_unlock_irqrestore(&priv->lock, flags);
diff --git a/drivers/net/tulip/dmfe.c b/drivers/net/tulip/dmfe.c
index 0bc4f30..a9f7d5d 100644
--- a/drivers/net/tulip/dmfe.c
+++ b/drivers/net/tulip/dmfe.c
@@ -599,7 +599,7 @@ static int dmfe_open(struct DEVICE *dev)
 	init_timer(&db->timer);
 	db->timer.expires = DMFE_TIMER_WUT + HZ * 2;
 	db->timer.data = (unsigned long)dev;
-	db->timer.function = &dmfe_timer;
+	db->timer.function = dmfe_timer;
 	add_timer(&db->timer);
 
 	return 0;
diff --git a/drivers/net/tulip/uli526x.c b/drivers/net/tulip/uli526x.c
index 96de582..1dc27a5 100644
--- a/drivers/net/tulip/uli526x.c
+++ b/drivers/net/tulip/uli526x.c
@@ -480,7 +480,7 @@ static int uli526x_open(struct net_device *dev)
 	init_timer(&db->timer);
 	db->timer.expires = ULI526X_TIMER_WUT + HZ * 2;
 	db->timer.data = (unsigned long)dev;
-	db->timer.function = &uli526x_timer;
+	db->timer.function = uli526x_timer;
 	add_timer(&db->timer);
 
 	return 0;
diff --git a/drivers/net/tulip/winbond-840.c b/drivers/net/tulip/winbond-840.c
index 66d41cf..f0b2310 100644
--- a/drivers/net/tulip/winbond-840.c
+++ b/drivers/net/tulip/winbond-840.c
@@ -662,7 +662,7 @@ static int netdev_open(struct net_device *dev)
 	init_timer(&np->timer);
 	np->timer.expires = jiffies + 1*HZ;
 	np->timer.data = (unsigned long)dev;
-	np->timer.function = &netdev_timer;				/* timer handler */
+	np->timer.function = netdev_timer;				/* timer handler */
 	add_timer(&np->timer);
 	return 0;
 out_err:
diff --git a/drivers/net/wan/lmc/lmc_main.c b/drivers/net/wan/lmc/lmc_main.c
index e2c6f7f..43af85b 100644
--- a/drivers/net/wan/lmc/lmc_main.c
+++ b/drivers/net/wan/lmc/lmc_main.c
@@ -1105,7 +1105,7 @@ static int lmc_open(struct net_device *dev)
     init_timer (&sc->timer);
     sc->timer.expires = jiffies + HZ;
     sc->timer.data = (unsigned long) dev;
-    sc->timer.function = &lmc_watchdog;
+    sc->timer.function = lmc_watchdog;
     add_timer (&sc->timer);
 
     lmc_trace(dev, "lmc_open out");
diff --git a/drivers/net/wd.c b/drivers/net/wd.c
index eb72c67..f1549ff 100644
--- a/drivers/net/wd.c
+++ b/drivers/net/wd.c
@@ -342,10 +342,10 @@ static int __init wd_probe1(struct net_device *dev, int ioaddr)
 	printk(" %s, IRQ %d, shared memory at %#lx-%#lx.\n",
 		   model_name, dev->irq, dev->mem_start, dev->mem_end-1);
 
-	ei_status.reset_8390 = &wd_reset_8390;
-	ei_status.block_input = &wd_block_input;
-	ei_status.block_output = &wd_block_output;
-	ei_status.get_8390_hdr = &wd_get_8390_hdr;
+	ei_status.reset_8390 = wd_reset_8390;
+	ei_status.block_input = wd_block_input;
+	ei_status.block_output = wd_block_output;
+	ei_status.get_8390_hdr = wd_get_8390_hdr;
 
 	dev->netdev_ops = &wd_netdev_ops;
 	NS8390_init(dev, 0);
diff --git a/drivers/net/wireless/ray_cs.c b/drivers/net/wireless/ray_cs.c
index 3bd9cf7..d91a831 100644
--- a/drivers/net/wireless/ray_cs.c
+++ b/drivers/net/wireless/ray_cs.c
@@ -604,7 +604,7 @@ static int dl_startup_params(struct net_device *dev)
 	/* Start kernel timer to wait for dl startup to complete. */
 	local->timer.expires = jiffies + HZ / 2;
 	local->timer.data = (long)local;
-	local->timer.function = &verify_dl_startup;
+	local->timer.function = verify_dl_startup;
 	add_timer(&local->timer);
 	dev_dbg(&link->dev,
 	      "ray_cs dl_startup_params started timer for verify_dl_startup\n");
@@ -1981,12 +1981,12 @@ static irqreturn_t ray_interrupt(int irq, void *dev_id)
 					dev_dbg(&link->dev,
 					      "ray_cs interrupt network \"%s\" start failed\n",
 					      local->sparm.b4.a_current_ess_id);
-					local->timer.function = &start_net;
+					local->timer.function = start_net;
 				} else {
 					dev_dbg(&link->dev,
 					      "ray_cs interrupt network \"%s\" join failed\n",
 					      local->sparm.b4.a_current_ess_id);
-					local->timer.function = &join_net;
+					local->timer.function = join_net;
 				}
 				add_timer(&local->timer);
 			}
@@ -2454,9 +2454,9 @@ static void authenticate(ray_dev_t *local)
 
 	del_timer(&local->timer);
 	if (build_auth_frame(local, local->bss_id, OPEN_AUTH_REQUEST)) {
-		local->timer.function = &join_net;
+		local->timer.function = join_net;
 	} else {
-		local->timer.function = &authenticate_timeout;
+		local->timer.function = authenticate_timeout;
 	}
 	local->timer.expires = jiffies + HZ * 2;
 	local->timer.data = (long)local;
@@ -2541,7 +2541,7 @@ static void associate(ray_dev_t *local)
 		del_timer(&local->timer);
 		local->timer.expires = jiffies + HZ * 2;
 		local->timer.data = (long)local;
-		local->timer.function = &join_net;
+		local->timer.function = join_net;
 		add_timer(&local->timer);
 		local->card_status = CARD_ASSOC_FAILED;
 		return;
diff --git a/drivers/net/yellowfin.c b/drivers/net/yellowfin.c
index 4eb67ae..cd1b3dc 100644
--- a/drivers/net/yellowfin.c
+++ b/drivers/net/yellowfin.c
@@ -646,7 +646,7 @@ static int yellowfin_open(struct net_device *dev)
 	init_timer(&yp->timer);
 	yp->timer.expires = jiffies + 3*HZ;
 	yp->timer.data = (unsigned long)dev;
-	yp->timer.function = &yellowfin_timer;				/* timer handler */
+	yp->timer.function = yellowfin_timer;				/* timer handler */
 	add_timer(&yp->timer);
 
 	return 0;
-- 
1.7.1
