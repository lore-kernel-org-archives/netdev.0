From: Andrew Lunn <andrew@lunn.ch>
Subject: [RFC PATCH net-next 08/24] phy: Centralise print about attached phy
Date: Mon,  4 Jan 2016 18:36:46 +0100
Message-ID: <1451929022-5580-9-git-send-email-andrew@lunn.ch>
References: <1451929022-5580-1-git-send-email-andrew@lunn.ch>
Cc: netdev <netdev@vger.kernel.org>, Andrew Lunn <andrew@lunn.ch>
To: Florian Fainelli <f.fainelli@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from vps0.lunn.ch ([178.209.37.122]:34971 "EHLO vps0.lunn.ch"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752913AbcADRiT (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 4 Jan 2016 12:38:19 -0500
In-Reply-To: <1451929022-5580-1-git-send-email-andrew@lunn.ch>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Many Ethernet drivers contain the same netdev_info() print statement
about the attached phy. Move it into the phy device code.

Signed-off-by: Andrew Lunn <andrew@lunn.ch>
---
 drivers/net/ethernet/adi/bfin_mac.c          |  5 -----
 drivers/net/ethernet/agere/et131x.c          |  4 ----
 drivers/net/ethernet/amd/au1000_eth.c        |  4 ----
 drivers/net/ethernet/broadcom/b44.c          |  3 ---
 drivers/net/ethernet/broadcom/bcm63xx_enet.c |  3 ---
 drivers/net/ethernet/broadcom/sb1250-mac.c   |  4 ----
 drivers/net/ethernet/broadcom/tg3.c          |  8 +-------
 drivers/net/ethernet/cadence/macb.c          |  2 --
 drivers/net/ethernet/dnet.c                  |  3 ---
 drivers/net/ethernet/freescale/fec_main.c    |  4 ----
 drivers/net/ethernet/lantiq_etop.c           |  3 ---
 drivers/net/ethernet/nxp/lpc_eth.c           |  3 ---
 drivers/net/ethernet/rdc/r6040.c             |  4 ----
 drivers/net/ethernet/renesas/ravb_main.c     |  3 ---
 drivers/net/ethernet/renesas/sh_eth.c        |  3 ---
 drivers/net/ethernet/smsc/smsc911x.c         |  4 ----
 drivers/net/ethernet/smsc/smsc9420.c         |  7 -------
 drivers/net/ethernet/synopsys/dwc_eth_qos.c  | 13 -------------
 drivers/net/ethernet/ti/cpsw.c               |  2 --
 drivers/net/ethernet/ti/davinci_emac.c       |  5 -----
 drivers/net/ethernet/toshiba/tc35815.c       |  4 ----
 drivers/net/phy/phy_device.c                 |  4 ++++
 drivers/staging/netlogic/xlr_net.c           |  2 --
 net/dsa/slave.c                              |  3 ---
 24 files changed, 5 insertions(+), 95 deletions(-)

diff --git a/drivers/net/ethernet/adi/bfin_mac.c b/drivers/net/ethernet/adi/bfin_mac.c
index 5f8a5182b8dc..4c6f7a7f9352 100644
--- a/drivers/net/ethernet/adi/bfin_mac.c
+++ b/drivers/net/ethernet/adi/bfin_mac.c
@@ -444,11 +444,6 @@ static int mii_probe(struct net_device *dev, int phy_mode)
 	lp->old_duplex = -1;
 	lp->phydev = phydev;
 
-	pr_info("attached PHY driver [%s] "
-	        "(mii_bus:phy_addr=%s, irq=%d, mdc_clk=%dHz(mdc_div=%d)@sclk=%dMHz)\n",
-		phydev->drv->name, phydev_name(phydev), phydev->irq,
-	        MDC_CLK, mdc_div, sclk/1000000);
-
 	return 0;
 }
 
diff --git a/drivers/net/ethernet/agere/et131x.c b/drivers/net/ethernet/agere/et131x.c
index 80b706f0fc97..8c49b97ed19b 100644
--- a/drivers/net/ethernet/agere/et131x.c
+++ b/drivers/net/ethernet/agere/et131x.c
@@ -3289,10 +3289,6 @@ static int et131x_mii_probe(struct net_device *netdev)
 	phydev->autoneg = AUTONEG_ENABLE;
 	adapter->phydev = phydev;
 
-	dev_info(&adapter->pdev->dev,
-		 "attached PHY driver [%s] (mii_bus:phy_addr=%s)\n",
-		 phydev->drv->name, phydev_name(phydev));
-
 	return 0;
 }
 
diff --git a/drivers/net/ethernet/amd/au1000_eth.c b/drivers/net/ethernet/amd/au1000_eth.c
index 8a8d6f2a0f6f..edd85664b1c7 100644
--- a/drivers/net/ethernet/amd/au1000_eth.c
+++ b/drivers/net/ethernet/amd/au1000_eth.c
@@ -583,10 +583,6 @@ static int au1000_mii_probe(struct net_device *dev)
 	aup->old_duplex = -1;
 	aup->phy_dev = phydev;
 
-	netdev_info(dev, "attached PHY driver [%s] "
-	       "(mii_bus:phy_addr=%s, irq=%d)\n",
-	       phydev->drv->name, phydev_name(phydev), phydev->irq);
-
 	return 0;
 }
 
diff --git a/drivers/net/ethernet/broadcom/b44.c b/drivers/net/ethernet/broadcom/b44.c
index 928a2210e788..9d009c540729 100644
--- a/drivers/net/ethernet/broadcom/b44.c
+++ b/drivers/net/ethernet/broadcom/b44.c
@@ -2315,9 +2315,6 @@ static int b44_register_phy_one(struct b44 *bp)
 	bp->old_link = 0;
 	bp->phy_addr = phydev->addr;
 
-	dev_info(sdev->dev, "attached PHY driver [%s] (mii_bus:phy_addr=%s)\n",
-		 phydev->drv->name, phydev_name(phydev));
-
 	return 0;
 
 err_out_mdiobus_unregister:
diff --git a/drivers/net/ethernet/broadcom/bcm63xx_enet.c b/drivers/net/ethernet/broadcom/bcm63xx_enet.c
index a54bafad3538..ac29e91e6e02 100644
--- a/drivers/net/ethernet/broadcom/bcm63xx_enet.c
+++ b/drivers/net/ethernet/broadcom/bcm63xx_enet.c
@@ -908,9 +908,6 @@ static int bcm_enet_open(struct net_device *dev)
 		else
 			phydev->advertising &= ~SUPPORTED_Pause;
 
-		dev_info(kdev, "attached PHY at address %d [%s]\n",
-			 phydev->addr, phydev->drv->name);
-
 		priv->old_link = 0;
 		priv->old_duplex = -1;
 		priv->old_pause = -1;
diff --git a/drivers/net/ethernet/broadcom/sb1250-mac.c b/drivers/net/ethernet/broadcom/sb1250-mac.c
index f557a2aaec23..51eaf55b8827 100644
--- a/drivers/net/ethernet/broadcom/sb1250-mac.c
+++ b/drivers/net/ethernet/broadcom/sb1250-mac.c
@@ -2390,10 +2390,6 @@ static int sbmac_mii_probe(struct net_device *dev)
 			      SUPPORTED_Asym_Pause;
 	phy_dev->advertising = phy_dev->supported;
 
-	pr_info("%s: attached PHY driver [%s] (mii_bus:phy_addr=%s, irq=%d)\n",
-		dev->name, phy_dev->drv->name,
-		dev_name(&phy_dev->dev), phy_dev->irq);
-
 	sc->phy_dev = phy_dev;
 
 	return 0;
diff --git a/drivers/net/ethernet/broadcom/tg3.c b/drivers/net/ethernet/broadcom/tg3.c
index 69d84d67f09a..28a9887397b8 100644
--- a/drivers/net/ethernet/broadcom/tg3.c
+++ b/drivers/net/ethernet/broadcom/tg3.c
@@ -17898,13 +17898,7 @@ static int tg3_init_one(struct pci_dev *pdev,
 		    tg3_bus_string(tp, str),
 		    dev->dev_addr);
 
-	if (tp->phy_flags & TG3_PHYFLG_IS_CONNECTED) {
-		struct phy_device *phydev;
-		phydev = tp->mdio_bus->phy_map[tp->phy_addr];
-		netdev_info(dev,
-			    "attached PHY driver [%s] (mii_bus:phy_addr=%s)\n",
-			    phydev->drv->name, phydev_name(phydev));
-	} else {
+	if (!(tp->phy_flags & TG3_PHYFLG_IS_CONNECTED)) {
 		char *ethtype;
 
 		if (tp->phy_flags & TG3_PHYFLG_10_100_ONLY)
diff --git a/drivers/net/ethernet/cadence/macb.c b/drivers/net/ethernet/cadence/macb.c
index 001d60c5521c..9771aaa8aaa6 100644
--- a/drivers/net/ethernet/cadence/macb.c
+++ b/drivers/net/ethernet/cadence/macb.c
@@ -2950,8 +2950,6 @@ static int macb_probe(struct platform_device *pdev)
 		    dev->base_addr, dev->irq, dev->dev_addr);
 
 	phydev = bp->phy_dev;
-	netdev_info(dev, "attached PHY driver [%s] (mii_bus:phy_addr=%s, irq=%d)\n",
-		    phydev->drv->name, phydev_name(phydev), phydev->irq);
 
 	return 0;
 
diff --git a/drivers/net/ethernet/dnet.c b/drivers/net/ethernet/dnet.c
index 0ec367521354..87e93df35b62 100644
--- a/drivers/net/ethernet/dnet.c
+++ b/drivers/net/ethernet/dnet.c
@@ -886,9 +886,6 @@ static int dnet_probe(struct platform_device *pdev)
 	       (bp->capabilities & DNET_HAS_GIGABIT) ? "" : "no ",
 	       (bp->capabilities & DNET_HAS_DMA) ? "" : "no ");
 	phydev = bp->phy_dev;
-	dev_info(&pdev->dev, "attached PHY driver [%s] "
-	       "(mii_bus:phy_addr=%s, irq=%d)\n",
-	       phydev->drv->name, phydev_name(phydev), phydev->irq);
 
 	return 0;
 
diff --git a/drivers/net/ethernet/freescale/fec_main.c b/drivers/net/ethernet/freescale/fec_main.c
index d2328fc5da57..9bbc1b8e8646 100644
--- a/drivers/net/ethernet/freescale/fec_main.c
+++ b/drivers/net/ethernet/freescale/fec_main.c
@@ -1972,10 +1972,6 @@ static int fec_enet_mii_probe(struct net_device *ndev)
 	fep->link = 0;
 	fep->full_duplex = 0;
 
-	netdev_info(ndev, "Freescale FEC PHY driver [%s] (mii_bus:phy_addr=%s, irq=%d)\n",
-		    fep->phy_dev->drv->name, dev_name(&fep->phy_dev->dev),
-		    fep->phy_dev->irq);
-
 	return 0;
 }
 
diff --git a/drivers/net/ethernet/lantiq_etop.c b/drivers/net/ethernet/lantiq_etop.c
index 274a3cec84c2..32d78d63074e 100644
--- a/drivers/net/ethernet/lantiq_etop.c
+++ b/drivers/net/ethernet/lantiq_etop.c
@@ -408,9 +408,6 @@ ltq_etop_mdio_probe(struct net_device *dev)
 
 	phydev->advertising = phydev->supported;
 	priv->phydev = phydev;
-	pr_info("%s: attached PHY [%s] (phy_addr=%s, irq=%d)\n",
-	       dev->name, phydev->drv->name,
-	       phydev_name(phydev), phydev->irq);
 
 	return 0;
 }
diff --git a/drivers/net/ethernet/nxp/lpc_eth.c b/drivers/net/ethernet/nxp/lpc_eth.c
index 5801aa197697..1fe7514346a8 100644
--- a/drivers/net/ethernet/nxp/lpc_eth.c
+++ b/drivers/net/ethernet/nxp/lpc_eth.c
@@ -816,9 +816,6 @@ static int lpc_mii_probe(struct net_device *ndev)
 	pldat->duplex = -1;
 	pldat->phy_dev = phydev;
 
-	netdev_info(ndev,
-		"attached PHY driver [%s] (mii_bus:phy_addr=%s, irq=%d)\n",
-		phydev->drv->name, phydev_name(phydev), phydev->irq);
 	return 0;
 }
 
diff --git a/drivers/net/ethernet/rdc/r6040.c b/drivers/net/ethernet/rdc/r6040.c
index 86a0887811c7..70e335731849 100644
--- a/drivers/net/ethernet/rdc/r6040.c
+++ b/drivers/net/ethernet/rdc/r6040.c
@@ -1061,10 +1061,6 @@ static int r6040_mii_probe(struct net_device *dev)
 	lp->old_link = 0;
 	lp->old_duplex = -1;
 
-	dev_info(&lp->pdev->dev, "attached PHY driver [%s] "
-		"(mii_bus:phy_addr=%s)\n",
-		phydev->drv->name, phydev_name(phydev));
-
 	return 0;
 }
 
diff --git a/drivers/net/ethernet/renesas/ravb_main.c b/drivers/net/ethernet/renesas/ravb_main.c
index 2f6c974e4a6d..9cea8e950361 100644
--- a/drivers/net/ethernet/renesas/ravb_main.c
+++ b/drivers/net/ethernet/renesas/ravb_main.c
@@ -927,9 +927,6 @@ static int ravb_phy_init(struct net_device *ndev)
 	/* 10BASE is not supported */
 	phydev->supported &= ~PHY_10BT_FEATURES;
 
-	netdev_info(ndev, "attached PHY %d (IRQ %d) to driver %s\n",
-		    phydev->addr, phydev->irq, phydev_name(phydev));
-
 	priv->phydev = phydev;
 
 	return 0;
diff --git a/drivers/net/ethernet/renesas/sh_eth.c b/drivers/net/ethernet/renesas/sh_eth.c
index bb3b66696e94..767222390f93 100644
--- a/drivers/net/ethernet/renesas/sh_eth.c
+++ b/drivers/net/ethernet/renesas/sh_eth.c
@@ -1852,9 +1852,6 @@ static int sh_eth_phy_init(struct net_device *ndev)
 		return PTR_ERR(phydev);
 	}
 
-	netdev_info(ndev, "attached PHY %d (IRQ %d) to driver %s\n",
-		    phydev->addr, phydev->irq, phydev_name(phydev));
-
 	mdp->phydev = phydev;
 
 	return 0;
diff --git a/drivers/net/ethernet/smsc/smsc911x.c b/drivers/net/ethernet/smsc/smsc911x.c
index 067346d3209d..1646e09b173e 100644
--- a/drivers/net/ethernet/smsc/smsc911x.c
+++ b/drivers/net/ethernet/smsc/smsc911x.c
@@ -1031,10 +1031,6 @@ static int smsc911x_mii_probe(struct net_device *dev)
 		return ret;
 	}
 
-	netdev_info(dev,
-		    "attached PHY driver [%s] (mii_bus:phy_addr=%s, irq=%d)\n",
-		    phydev->drv->name, phydev_name(phydev), phydev->irq);
-
 	/* mask with MAC supported features */
 	phydev->supported &= (PHY_BASIC_FEATURES | SUPPORTED_Pause |
 			      SUPPORTED_Asym_Pause);
diff --git a/drivers/net/ethernet/smsc/smsc9420.c b/drivers/net/ethernet/smsc/smsc9420.c
index a02ed6b63064..78eaf34d7f06 100644
--- a/drivers/net/ethernet/smsc/smsc9420.c
+++ b/drivers/net/ethernet/smsc/smsc9420.c
@@ -1163,10 +1163,6 @@ static int smsc9420_mii_probe(struct net_device *dev)
 		return -ENODEV;
 	}
 
-	phydev = pd->mii_bus->phy_map[1];
-	netif_info(pd, probe, pd->dev, "PHY addr %d, phy_id 0x%08X\n",
-		   phydev->addr, phydev->phy_id);
-
 	phydev = phy_connect(dev, phydev_name(phydev),
 			     smsc9420_phy_adjust_link, PHY_INTERFACE_MODE_MII);
 
@@ -1175,9 +1171,6 @@ static int smsc9420_mii_probe(struct net_device *dev)
 		return PTR_ERR(phydev);
 	}
 
-	netdev_info(dev, "attached PHY driver [%s] (mii_bus:phy_addr=%s, irq=%d)\n",
-		    phydev->drv->name, phydev_name(phydev), phydev->irq);
-
 	/* mask with MAC supported features */
 	phydev->supported &= (PHY_BASIC_FEATURES | SUPPORTED_Pause |
 			      SUPPORTED_Asym_Pause);
diff --git a/drivers/net/ethernet/synopsys/dwc_eth_qos.c b/drivers/net/ethernet/synopsys/dwc_eth_qos.c
index 9066d7a8483c..8a5fa76eae1c 100644
--- a/drivers/net/ethernet/synopsys/dwc_eth_qos.c
+++ b/drivers/net/ethernet/synopsys/dwc_eth_qos.c
@@ -971,11 +971,6 @@ static int dwceqos_mii_probe(struct net_device *ndev)
 		return -ENODEV;
 	}
 
-	if (netif_msg_probe(lp))
-		netdev_dbg(lp->ndev,
-			   "phydev %p, phydev->phy_id 0xa%x, phydev->addr 0x%x\n",
-			   phydev, phydev->phy_id, phydev->addr);
-
 	phydev->supported &= PHY_GBIT_FEATURES;
 
 	lp->link    = 0;
@@ -983,14 +978,6 @@ static int dwceqos_mii_probe(struct net_device *ndev)
 	lp->duplex  = DUPLEX_UNKNOWN;
 	lp->phy_dev = phydev;
 
-	if (netif_msg_probe(lp)) {
-		netdev_dbg(lp->ndev, "phy_addr 0x%x, phy_id 0x%08x\n",
-			   lp->phy_dev->addr, lp->phy_dev->phy_id);
-
-		netdev_dbg(lp->ndev, "attach [%s] phy driver\n",
-			   lp->phy_dev->drv->name);
-	}
-
 	return 0;
 }
 
diff --git a/drivers/net/ethernet/ti/cpsw.c b/drivers/net/ethernet/ti/cpsw.c
index 34ce7dce8c9d..4d2384c9c54f 100644
--- a/drivers/net/ethernet/ti/cpsw.c
+++ b/drivers/net/ethernet/ti/cpsw.c
@@ -1159,8 +1159,6 @@ static void cpsw_slave_open(struct cpsw_slave *slave, struct cpsw_priv *priv)
 			slave->data->phy_id, slave->slave_num);
 		slave->phy = NULL;
 	} else {
-		dev_info(priv->dev, "phy found : id is : 0x%x\n",
-			 slave->phy->phy_id);
 		phy_start(slave->phy);
 
 		/* Configure GMII_SEL register */
diff --git a/drivers/net/ethernet/ti/davinci_emac.c b/drivers/net/ethernet/ti/davinci_emac.c
index 5a40b0256327..7fba4411bad4 100644
--- a/drivers/net/ethernet/ti/davinci_emac.c
+++ b/drivers/net/ethernet/ti/davinci_emac.c
@@ -1643,11 +1643,6 @@ static int emac_dev_open(struct net_device *ndev)
 		priv->link = 0;
 		priv->speed = 0;
 		priv->duplex = ~0;
-
-		dev_info(emac_dev, "attached PHY driver [%s] "
-			"(mii_bus:phy_addr=%s, id=%x)\n",
-			priv->phydev->drv->name, phydev_name(priv->phydev),
-			priv->phydev->phy_id);
 	}
 
 	if (!priv->phydev) {
diff --git a/drivers/net/ethernet/toshiba/tc35815.c b/drivers/net/ethernet/toshiba/tc35815.c
index 8df6072ac78d..385c0a44db74 100644
--- a/drivers/net/ethernet/toshiba/tc35815.c
+++ b/drivers/net/ethernet/toshiba/tc35815.c
@@ -638,10 +638,6 @@ static int tc_mii_probe(struct net_device *dev)
 		printk(KERN_ERR "%s: Could not attach to PHY\n", dev->name);
 		return PTR_ERR(phydev);
 	}
-	printk(KERN_INFO "%s: attached PHY driver [%s] "
-		"(mii_bus:phy_addr=%s, id=%x)\n",
-		dev->name, phydev->drv->name, phydev_name(phydev),
-		phydev->phy_id);
 
 	/* mask with MAC supported features */
 	phydev->supported &= PHY_BASIC_FEATURES;
diff --git a/drivers/net/phy/phy_device.c b/drivers/net/phy/phy_device.c
index 0f179709a289..e41bea8e898d 100644
--- a/drivers/net/phy/phy_device.c
+++ b/drivers/net/phy/phy_device.c
@@ -662,6 +662,10 @@ int phy_attach_direct(struct net_device *dev, struct phy_device *phydev,
 	phydev->attached_dev = dev;
 	dev->phydev = phydev;
 
+	netdev_info(dev,
+		    "attached PHY driver [%s] (mii_bus:phy_addr=%s, irq=%d)\n",
+		    phydev->drv->name, phydev_name(phydev), phydev->irq);
+
 	phydev->dev_flags = flags;
 
 	phydev->interface = interface;
diff --git a/drivers/staging/netlogic/xlr_net.c b/drivers/staging/netlogic/xlr_net.c
index b939c4b5f229..77ac6ec564fb 100644
--- a/drivers/staging/netlogic/xlr_net.c
+++ b/drivers/staging/netlogic/xlr_net.c
@@ -854,8 +854,6 @@ static int xlr_mii_probe(struct xlr_net_priv *priv)
 				| ADVERTISED_MII);
 
 	phydev->advertising = phydev->supported;
-	pr_info("attached PHY driver [%s] (mii_bus:phy_addr=%s\n",
-		phydev->drv->name, phydev_name(phydev));
 	return 0;
 }
 
diff --git a/net/dsa/slave.c b/net/dsa/slave.c
index 1e9e9424a33d..ee1114613847 100644
--- a/net/dsa/slave.c
+++ b/net/dsa/slave.c
@@ -1080,9 +1080,6 @@ static int dsa_slave_phy_setup(struct dsa_slave_priv *p,
 			netdev_err(slave_dev, "failed to connect to port %d: %d\n", p->port, ret);
 			return ret;
 		}
-	} else {
-		netdev_info(slave_dev, "attached PHY at address %d [%s]\n",
-			    p->phy->addr, p->phy->drv->name);
 	}
 
 	return 0;
-- 
2.6.4
