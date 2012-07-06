From: <s-paulraj@ti.com>
Subject: [PATCH 4/4] net: add context callback parameter to phy connect
Date: Fri, 6 Jul 2012 16:10:09 -0400
Message-ID: <1341605409-20666-1-git-send-email-s-paulraj@ti.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: Sandeep Paulraj <s-paulraj@ti.com>
To: <netdev@vger.kernel.org>, <davem@davemloft.net>, <cyril@ti.com>,
	<grant.likely@secretlab.ca>, <linux-keystone@list.ti.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from bear.ext.ti.com ([192.94.94.41]:48114 "EHLO bear.ext.ti.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751281Ab2GFUKO (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 6 Jul 2012 16:10:14 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Sandeep Paulraj <s-paulraj@ti.com>

This patch introduces a context argument for the adjust link callback in all
drivers that currently use the phy_connect() and it variants.

Signed-off-by: Cyril Chemparathy <cyril@ti.com>
Signed-off-by: Sandeep Paulraj <s-paulraj@ti.com>
---
 drivers/net/ethernet/8390/ax88796.c                |    4 ++--
 drivers/net/ethernet/adi/bfin_mac.c                |    4 ++--
 drivers/net/ethernet/aeroflex/greth.c              |    7 ++++---
 drivers/net/ethernet/amd/au1000_eth.c              |    4 ++--
 drivers/net/ethernet/broadcom/bcm63xx_enet.c       |    4 ++--
 drivers/net/ethernet/broadcom/sb1250-mac.c         |    6 +++---
 drivers/net/ethernet/broadcom/tg3.c                |    4 ++--
 drivers/net/ethernet/cadence/macb.c                |    4 ++--
 drivers/net/ethernet/dnet.c                        |    6 +++---
 drivers/net/ethernet/ethoc.c                       |    4 ++--
 drivers/net/ethernet/faraday/ftgmac100.c           |    4 ++--
 drivers/net/ethernet/freescale/fec.c               |    4 ++--
 drivers/net/ethernet/freescale/fec_mpc52xx.c       |    5 +++--
 .../net/ethernet/freescale/fs_enet/fs_enet-main.c  |    6 +++---
 drivers/net/ethernet/freescale/gianfar.c           |    8 ++++----
 drivers/net/ethernet/freescale/ucc_geth.c          |    6 +++---
 drivers/net/ethernet/lantiq_etop.c                 |    4 ++--
 drivers/net/ethernet/nxp/lpc_eth.c                 |    5 +++--
 drivers/net/ethernet/octeon/octeon_mgmt.c          |    4 ++--
 drivers/net/ethernet/pasemi/pasemi_mac.c           |    4 ++--
 drivers/net/ethernet/rdc/r6040.c                   |    4 ++--
 drivers/net/ethernet/renesas/sh_eth.c              |    4 ++--
 drivers/net/ethernet/s6gmac.c                      |    4 ++--
 drivers/net/ethernet/smsc/smsc911x.c               |    4 ++--
 drivers/net/ethernet/smsc/smsc9420.c               |    5 +++--
 drivers/net/ethernet/stmicro/stmmac/stmmac_main.c  |    6 ++++--
 drivers/net/ethernet/ti/cpmac.c                    |    4 ++--
 drivers/net/ethernet/ti/cpsw.c                     |    5 +++--
 drivers/net/ethernet/ti/davinci_emac.c             |    4 ++--
 drivers/net/ethernet/toshiba/tc35815.c             |    5 +++--
 drivers/net/ethernet/xilinx/ll_temac_main.c        |    4 ++--
 drivers/net/ethernet/xilinx/xilinx_axienet_main.c  |    3 ++-
 drivers/net/ethernet/xilinx/xilinx_emaclite.c      |    5 +++--
 drivers/net/ethernet/xscale/ixp4xx_eth.c           |    4 ++--
 34 files changed, 84 insertions(+), 74 deletions(-)

diff --git a/drivers/net/ethernet/8390/ax88796.c b/drivers/net/ethernet/8390/ax88796.c
index 203ff9d..ef02795 100644
--- a/drivers/net/ethernet/8390/ax88796.c
+++ b/drivers/net/ethernet/8390/ax88796.c
@@ -317,7 +317,7 @@ static void ax_block_output(struct net_device *dev, int count,
 #define AX_MEMR_EEO		BIT(6)
 #define AX_MEMR_EECLK		BIT(7)
 
-static void ax_handle_link_change(struct net_device *dev)
+static void ax_handle_link_change(struct net_device *dev, void *context)
 {
 	struct ax_device  *ax = to_ax_dev(dev);
 	struct phy_device *phy_dev = ax->phy_dev;
@@ -359,7 +359,7 @@ static int ax_mii_probe(struct net_device *dev)
 	}
 
 	ret = phy_connect_direct(dev, phy_dev, ax_handle_link_change, 0,
-				 PHY_INTERFACE_MODE_MII);
+				 PHY_INTERFACE_MODE_MII, NULL);
 	if (ret) {
 		netdev_err(dev, "Could not attach to PHY\n");
 		return ret;
diff --git a/drivers/net/ethernet/adi/bfin_mac.c b/drivers/net/ethernet/adi/bfin_mac.c
index f816426..55d1f99 100644
--- a/drivers/net/ethernet/adi/bfin_mac.c
+++ b/drivers/net/ethernet/adi/bfin_mac.c
@@ -313,7 +313,7 @@ static int bfin_mdiobus_reset(struct mii_bus *bus)
 	return 0;
 }
 
-static void bfin_mac_adjust_link(struct net_device *dev)
+static void bfin_mac_adjust_link(struct net_device *dev, void *context)
 {
 	struct bfin_mac_local *lp = netdev_priv(dev);
 	struct phy_device *phydev = lp->phydev;
@@ -426,7 +426,7 @@ static int mii_probe(struct net_device *dev, int phy_mode)
 	}
 
 	phydev = phy_connect(dev, dev_name(&phydev->dev), &bfin_mac_adjust_link,
-			0, phy_mode);
+			0, phy_mode, NULL);
 
 	if (IS_ERR(phydev)) {
 		netdev_err(dev, "could not attach PHY\n");
diff --git a/drivers/net/ethernet/aeroflex/greth.c b/drivers/net/ethernet/aeroflex/greth.c
index 3485011..3b803f2 100644
--- a/drivers/net/ethernet/aeroflex/greth.c
+++ b/drivers/net/ethernet/aeroflex/greth.c
@@ -1218,7 +1218,7 @@ static int greth_mdio_reset(struct mii_bus *bus)
 	return 0;
 }
 
-static void greth_link_change(struct net_device *dev)
+static void greth_link_change(struct net_device *dev, void *context)
 {
 	struct greth_private *greth = netdev_priv(dev);
 	struct phy_device *phydev = greth->phy;
@@ -1289,7 +1289,8 @@ static int greth_mdio_probe(struct net_device *dev)
 	ret = phy_connect_direct(dev, phy, &greth_link_change,
 			0, greth->gbit_mac ?
 			PHY_INTERFACE_MODE_GMII :
-			PHY_INTERFACE_MODE_MII);
+			PHY_INTERFACE_MODE_MII.
+			NULL);
 	if (ret) {
 		if (netif_msg_ifup(greth))
 			dev_err(&dev->dev, "could not attach to PHY\n");
@@ -1363,7 +1364,7 @@ static int greth_mdio_init(struct greth_private *greth)
 		while (!phy_aneg_done(greth->phy) && time_before(jiffies, timeout)) {
 		}
 		genphy_read_status(greth->phy);
-		greth_link_change(greth->netdev);
+		greth_link_change(greth->netdev, NULL);
 	}
 
 	return 0;
diff --git a/drivers/net/ethernet/amd/au1000_eth.c b/drivers/net/ethernet/amd/au1000_eth.c
index 397596b..ed7e60a 100644
--- a/drivers/net/ethernet/amd/au1000_eth.c
+++ b/drivers/net/ethernet/amd/au1000_eth.c
@@ -292,7 +292,7 @@ static void au1000_enable_rx_tx(struct net_device *dev)
 }
 
 static void
-au1000_adjust_link(struct net_device *dev)
+au1000_adjust_link(struct net_device *dev, void *context)
 {
 	struct au1000_private *aup = netdev_priv(dev);
 	struct phy_device *phydev = aup->phy_dev;
@@ -438,7 +438,7 @@ static int au1000_mii_probe(struct net_device *dev)
 	BUG_ON(phydev->attached_dev);
 
 	phydev = phy_connect(dev, dev_name(&phydev->dev), &au1000_adjust_link,
-			0, PHY_INTERFACE_MODE_MII);
+			0, PHY_INTERFACE_MODE_MII, NULL);
 
 	if (IS_ERR(phydev)) {
 		netdev_err(dev, "Could not attach to PHY\n");
diff --git a/drivers/net/ethernet/broadcom/bcm63xx_enet.c b/drivers/net/ethernet/broadcom/bcm63xx_enet.c
index c7ca7ec..84b7033 100644
--- a/drivers/net/ethernet/broadcom/bcm63xx_enet.c
+++ b/drivers/net/ethernet/broadcom/bcm63xx_enet.c
@@ -698,7 +698,7 @@ static void bcm_enet_set_flow(struct bcm_enet_priv *priv, int rx_en, int tx_en)
 /*
  * link changed callback (from phylib)
  */
-static void bcm_enet_adjust_phy_link(struct net_device *dev)
+static void bcm_enet_adjust_phy_link(struct net_device *dev, void *context)
 {
 	struct bcm_enet_priv *priv;
 	struct phy_device *phydev;
@@ -800,7 +800,7 @@ static int bcm_enet_open(struct net_device *dev)
 			 priv->mii_bus->id, priv->phy_id);
 
 		phydev = phy_connect(dev, phy_id, bcm_enet_adjust_phy_link, 0,
-				     PHY_INTERFACE_MODE_MII);
+				     PHY_INTERFACE_MODE_MII, NULL);
 
 		if (IS_ERR(phydev)) {
 			dev_err(kdev, "could not attach to PHY\n");
diff --git a/drivers/net/ethernet/broadcom/sb1250-mac.c b/drivers/net/ethernet/broadcom/sb1250-mac.c
index 49e7a25..58155d3 100644
--- a/drivers/net/ethernet/broadcom/sb1250-mac.c
+++ b/drivers/net/ethernet/broadcom/sb1250-mac.c
@@ -316,7 +316,7 @@ static int sbmac_mii_ioctl(struct net_device *dev, struct ifreq *rq, int cmd);
 static int sbmac_close(struct net_device *dev);
 static int sbmac_poll(struct napi_struct *napi, int budget);
 
-static void sbmac_mii_poll(struct net_device *dev);
+static void sbmac_mii_poll(struct net_device *dev, void *context);
 static int sbmac_mii_probe(struct net_device *dev);
 
 static void sbmac_mii_sync(void __iomem *sbm_mdio);
@@ -2386,7 +2386,7 @@ static int sbmac_mii_probe(struct net_device *dev)
 	}
 
 	phy_dev = phy_connect(dev, dev_name(&phy_dev->dev), &sbmac_mii_poll, 0,
-			      PHY_INTERFACE_MODE_GMII);
+			      PHY_INTERFACE_MODE_GMII, NULL);
 	if (IS_ERR(phy_dev)) {
 		printk(KERN_ERR "%s: could not attach to PHY\n", dev->name);
 		return PTR_ERR(phy_dev);
@@ -2415,7 +2415,7 @@ static int sbmac_mii_probe(struct net_device *dev)
 }
 
 
-static void sbmac_mii_poll(struct net_device *dev)
+static void sbmac_mii_poll(struct net_device *dev, void *context)
 {
 	struct sbmac_softc *sc = netdev_priv(dev);
 	struct phy_device *phy_dev = sc->phy_dev;
diff --git a/drivers/net/ethernet/broadcom/tg3.c b/drivers/net/ethernet/broadcom/tg3.c
index e47ff8b..2130a76 100644
--- a/drivers/net/ethernet/broadcom/tg3.c
+++ b/drivers/net/ethernet/broadcom/tg3.c
@@ -1756,7 +1756,7 @@ static void tg3_setup_flow_control(struct tg3 *tp, u32 lcladv, u32 rmtadv)
 		tw32_f(MAC_TX_MODE, tp->tx_mode);
 }
 
-static void tg3_adjust_link(struct net_device *dev)
+static void tg3_adjust_link(struct net_device *dev, void *context)
 {
 	u8 oldflowctrl, linkmesg = 0;
 	u32 mac_mode, lcl_adv, rmt_adv;
@@ -1854,7 +1854,7 @@ static int tg3_phy_init(struct tg3 *tp)
 
 	/* Attach the MAC to the PHY. */
 	phydev = phy_connect(tp->dev, dev_name(&phydev->dev), tg3_adjust_link,
-			     phydev->dev_flags, phydev->interface);
+			     phydev->dev_flags, phydev->interface, NULL);
 	if (IS_ERR(phydev)) {
 		dev_err(&tp->pdev->dev, "Could not attach to PHY\n");
 		return PTR_ERR(phydev);
diff --git a/drivers/net/ethernet/cadence/macb.c b/drivers/net/ethernet/cadence/macb.c
index 1466bc4..943833c 100644
--- a/drivers/net/ethernet/cadence/macb.c
+++ b/drivers/net/ethernet/cadence/macb.c
@@ -135,7 +135,7 @@ static int macb_mdio_reset(struct mii_bus *bus)
 	return 0;
 }
 
-static void macb_handle_link_change(struct net_device *dev)
+static void macb_handle_link_change(struct net_device *dev, void *context)
 {
 	struct macb *bp = netdev_priv(dev);
 	struct phy_device *phydev = bp->phy_dev;
@@ -206,7 +206,7 @@ static int macb_mii_probe(struct net_device *dev)
 
 	/* attach the mac to the phy */
 	ret = phy_connect_direct(dev, phydev, &macb_handle_link_change, 0,
-				 bp->phy_interface);
+				 bp->phy_interface, NULL);
 	if (ret) {
 		netdev_err(dev, "Could not attach to PHY\n");
 		return ret;
diff --git a/drivers/net/ethernet/dnet.c b/drivers/net/ethernet/dnet.c
index 290b26f..68bc305 100644
--- a/drivers/net/ethernet/dnet.c
+++ b/drivers/net/ethernet/dnet.c
@@ -176,7 +176,7 @@ static int dnet_mdio_reset(struct mii_bus *bus)
 	return 0;
 }
 
-static void dnet_handle_link_change(struct net_device *dev)
+static void dnet_handle_link_change(struct net_device *dev, void *context)
 {
 	struct dnet *bp = netdev_priv(dev);
 	struct phy_device *phydev = bp->phy_dev;
@@ -282,11 +282,11 @@ static int dnet_mii_probe(struct net_device *dev)
 	if (bp->capabilities & DNET_HAS_RMII) {
 		phydev = phy_connect(dev, dev_name(&phydev->dev),
 				     &dnet_handle_link_change, 0,
-				     PHY_INTERFACE_MODE_RMII);
+				     PHY_INTERFACE_MODE_RMII, NULL);
 	} else {
 		phydev = phy_connect(dev, dev_name(&phydev->dev),
 				     &dnet_handle_link_change, 0,
-				     PHY_INTERFACE_MODE_MII);
+				     PHY_INTERFACE_MODE_MII, NULL);
 	}
 
 	if (IS_ERR(phydev)) {
diff --git a/drivers/net/ethernet/ethoc.c b/drivers/net/ethernet/ethoc.c
index a381678..dd33a50 100644
--- a/drivers/net/ethernet/ethoc.c
+++ b/drivers/net/ethernet/ethoc.c
@@ -661,7 +661,7 @@ static int ethoc_mdio_reset(struct mii_bus *bus)
 	return 0;
 }
 
-static void ethoc_mdio_poll(struct net_device *dev)
+static void ethoc_mdio_poll(struct net_device *dev, void *context)
 {
 }
 
@@ -683,7 +683,7 @@ static int __devinit ethoc_mdio_probe(struct net_device *dev)
 	}
 
 	err = phy_connect_direct(dev, phy, ethoc_mdio_poll, 0,
-			PHY_INTERFACE_MODE_GMII);
+			PHY_INTERFACE_MODE_GMII, NULL);
 	if (err) {
 		dev_err(&dev->dev, "could not attach to PHY\n");
 		return err;
diff --git a/drivers/net/ethernet/faraday/ftgmac100.c b/drivers/net/ethernet/faraday/ftgmac100.c
index 16b0704..79c5502 100644
--- a/drivers/net/ethernet/faraday/ftgmac100.c
+++ b/drivers/net/ethernet/faraday/ftgmac100.c
@@ -803,7 +803,7 @@ err:
 /******************************************************************************
  * internal functions (mdio)
  *****************************************************************************/
-static void ftgmac100_adjust_link(struct net_device *netdev)
+static void ftgmac100_adjust_link(struct net_device *netdev, void *context)
 {
 	struct ftgmac100 *priv = netdev_priv(netdev);
 	struct phy_device *phydev = priv->phydev;
@@ -854,7 +854,7 @@ static int ftgmac100_mii_probe(struct ftgmac100 *priv)
 
 	phydev = phy_connect(netdev, dev_name(&phydev->dev),
 			     &ftgmac100_adjust_link, 0,
-			     PHY_INTERFACE_MODE_GMII);
+			     PHY_INTERFACE_MODE_GMII, NULL);
 
 	if (IS_ERR(phydev)) {
 		netdev_err(netdev, "%s: Could not attach to PHY\n", netdev->name);
diff --git a/drivers/net/ethernet/freescale/fec.c b/drivers/net/ethernet/freescale/fec.c
index ff7f4c5..b0b5adc 100644
--- a/drivers/net/ethernet/freescale/fec.c
+++ b/drivers/net/ethernet/freescale/fec.c
@@ -856,7 +856,7 @@ static void __inline__ fec_get_mac(struct net_device *ndev)
 /*
  * Phy section
  */
-static void fec_enet_adjust_link(struct net_device *ndev)
+static void fec_enet_adjust_link(struct net_device *ndev, void *context)
 {
 	struct fec_enet_private *fep = netdev_priv(ndev);
 	struct phy_device *phy_dev = fep->phy_dev;
@@ -994,7 +994,7 @@ static int fec_enet_mii_probe(struct net_device *ndev)
 
 	snprintf(phy_name, sizeof(phy_name), PHY_ID_FMT, mdio_bus_id, phy_id);
 	phy_dev = phy_connect(ndev, phy_name, &fec_enet_adjust_link, 0,
-			      fep->phy_interface);
+			      fep->phy_interface, NULL);
 	if (IS_ERR(phy_dev)) {
 		printk(KERN_ERR "%s: could not attach to PHY\n", ndev->name);
 		return PTR_ERR(phy_dev);
diff --git a/drivers/net/ethernet/freescale/fec_mpc52xx.c b/drivers/net/ethernet/freescale/fec_mpc52xx.c
index 2933d08..800b7fb 100644
--- a/drivers/net/ethernet/freescale/fec_mpc52xx.c
+++ b/drivers/net/ethernet/freescale/fec_mpc52xx.c
@@ -172,7 +172,7 @@ static int mpc52xx_fec_alloc_rx_buffers(struct net_device *dev, struct bcom_task
 }
 
 /* based on generic_adjust_link from fs_enet-main.c */
-static void mpc52xx_fec_adjust_link(struct net_device *dev)
+static void mpc52xx_fec_adjust_link(struct net_device *dev, void *context)
 {
 	struct mpc52xx_fec_priv *priv = netdev_priv(dev);
 	struct phy_device *phydev = priv->phydev;
@@ -229,7 +229,8 @@ static int mpc52xx_fec_open(struct net_device *dev)
 
 	if (priv->phy_node) {
 		priv->phydev = of_phy_connect(priv->ndev, priv->phy_node,
-					      mpc52xx_fec_adjust_link, 0, 0);
+					      mpc52xx_fec_adjust_link,
+					      0, 0, NULL);
 		if (!priv->phydev) {
 			dev_err(&dev->dev, "of_phy_connect failed\n");
 			return -ENODEV;
diff --git a/drivers/net/ethernet/freescale/fs_enet/fs_enet-main.c b/drivers/net/ethernet/freescale/fs_enet/fs_enet-main.c
index 2b7633f..82a1dcd 100644
--- a/drivers/net/ethernet/freescale/fs_enet/fs_enet-main.c
+++ b/drivers/net/ethernet/freescale/fs_enet/fs_enet-main.c
@@ -771,7 +771,7 @@ static void generic_adjust_link(struct  net_device *dev)
 }
 
 
-static void fs_adjust_link(struct net_device *dev)
+static void fs_adjust_link(struct net_device *dev, void *context)
 {
 	struct fs_enet_private *fep = netdev_priv(dev);
 	unsigned long flags;
@@ -800,10 +800,10 @@ static int fs_init_phy(struct net_device *dev)
 		PHY_INTERFACE_MODE_RMII : PHY_INTERFACE_MODE_MII;
 
 	phydev = of_phy_connect(dev, fep->fpi->phy_node, &fs_adjust_link, 0,
-				iface);
+				iface, NULL);
 	if (!phydev) {
 		phydev = of_phy_connect_fixed_link(dev, &fs_adjust_link,
-						   iface);
+						   iface, NULL);
 	}
 	if (!phydev) {
 		dev_err(&dev->dev, "Could not attach to PHY\n");
diff --git a/drivers/net/ethernet/freescale/gianfar.c b/drivers/net/ethernet/freescale/gianfar.c
index f2db8fc..4d3324a 100644
--- a/drivers/net/ethernet/freescale/gianfar.c
+++ b/drivers/net/ethernet/freescale/gianfar.c
@@ -120,7 +120,7 @@ static int gfar_change_mtu(struct net_device *dev, int new_mtu);
 static irqreturn_t gfar_error(int irq, void *dev_id);
 static irqreturn_t gfar_transmit(int irq, void *dev_id);
 static irqreturn_t gfar_interrupt(int irq, void *dev_id);
-static void adjust_link(struct net_device *dev);
+static void adjust_link(struct net_device *dev, void *context);
 static void init_registers(struct net_device *dev);
 static int init_phy(struct net_device *dev);
 static int gfar_probe(struct platform_device *ofdev);
@@ -1434,10 +1434,10 @@ static int init_phy(struct net_device *dev)
 	interface = gfar_get_interface(dev);
 
 	priv->phydev = of_phy_connect(dev, priv->phy_node, &adjust_link, 0,
-				      interface);
+				      interface, NULL);
 	if (!priv->phydev)
 		priv->phydev = of_phy_connect_fixed_link(dev, &adjust_link,
-							 interface);
+							 interface, NULL);
 	if (!priv->phydev) {
 		dev_err(&dev->dev, "could not attach to PHY\n");
 		return -ENODEV;
@@ -2939,7 +2939,7 @@ static irqreturn_t gfar_interrupt(int irq, void *grp_id)
  * function converts those variables into the appropriate
  * register values, and can bring down the device if needed.
  */
-static void adjust_link(struct net_device *dev)
+static void adjust_link(struct net_device *dev, void *context)
 {
 	struct gfar_private *priv = netdev_priv(dev);
 	struct gfar __iomem *regs = priv->gfargrp[0].regs;
diff --git a/drivers/net/ethernet/freescale/ucc_geth.c b/drivers/net/ethernet/freescale/ucc_geth.c
index 9ac14f8..7c79cb5 100644
--- a/drivers/net/ethernet/freescale/ucc_geth.c
+++ b/drivers/net/ethernet/freescale/ucc_geth.c
@@ -1598,7 +1598,7 @@ static void ugeth_activate(struct ucc_geth_private *ugeth)
  * register values, and can bring down the device if needed.
  */
 
-static void adjust_link(struct net_device *dev)
+static void adjust_link(struct net_device *dev, void *context)
 {
 	struct ucc_geth_private *ugeth = netdev_priv(dev);
 	struct ucc_geth __iomem *ug_regs;
@@ -1749,10 +1749,10 @@ static int init_phy(struct net_device *dev)
 	priv->oldduplex = -1;
 
 	phydev = of_phy_connect(dev, ug_info->phy_node, &adjust_link, 0,
-				priv->phy_interface);
+				priv->phy_interface, NULL);
 	if (!phydev)
 		phydev = of_phy_connect_fixed_link(dev, &adjust_link,
-						   priv->phy_interface);
+						   priv->phy_interface, NULL);
 	if (!phydev) {
 		dev_err(&dev->dev, "Could not attach to PHY\n");
 		return -ENODEV;
diff --git a/drivers/net/ethernet/lantiq_etop.c b/drivers/net/ethernet/lantiq_etop.c
index 5dc9cbd..07bca02 100644
--- a/drivers/net/ethernet/lantiq_etop.c
+++ b/drivers/net/ethernet/lantiq_etop.c
@@ -370,7 +370,7 @@ ltq_etop_mdio_rd(struct mii_bus *bus, int phy_addr, int phy_reg)
 }
 
 static void
-ltq_etop_mdio_link(struct net_device *dev)
+ltq_etop_mdio_link(struct net_device *dev, void *context)
 {
 	/* nothing to do  */
 }
@@ -395,7 +395,7 @@ ltq_etop_mdio_probe(struct net_device *dev)
 	}
 
 	phydev = phy_connect(dev, dev_name(&phydev->dev), &ltq_etop_mdio_link,
-			0, priv->pldata->mii_mode);
+			0, priv->pldata->mii_mode, NULL);
 
 	if (IS_ERR(phydev)) {
 		netdev_err(dev, "Could not attach to PHY\n");
diff --git a/drivers/net/ethernet/nxp/lpc_eth.c b/drivers/net/ethernet/nxp/lpc_eth.c
index 083d671..ed37ead 100644
--- a/drivers/net/ethernet/nxp/lpc_eth.c
+++ b/drivers/net/ethernet/nxp/lpc_eth.c
@@ -767,7 +767,7 @@ static int lpc_mdio_reset(struct mii_bus *bus)
 	return __lpc_mii_mngt_reset((struct netdata_local *)bus->priv);
 }
 
-static void lpc_handle_link_change(struct net_device *ndev)
+static void lpc_handle_link_change(struct net_device *ndev, void *context)
 {
 	struct netdata_local *pldat = netdev_priv(ndev);
 	struct phy_device *phydev = pldat->phy_dev;
@@ -819,7 +819,8 @@ static int lpc_mii_probe(struct net_device *ndev)
 		netdev_info(ndev, "using RMII interface\n");
 	phydev = phy_connect(ndev, dev_name(&phydev->dev),
 			     &lpc_handle_link_change, 0,
-			     lpc_phy_interface_mode(&pldat->pdev->dev));
+			     lpc_phy_interface_mode(&pldat->pdev->dev),
+			     NULL);
 
 	if (IS_ERR(phydev)) {
 		netdev_err(ndev, "Could not attach to PHY\n");
diff --git a/drivers/net/ethernet/octeon/octeon_mgmt.c b/drivers/net/ethernet/octeon/octeon_mgmt.c
index cd827ff..9fdca60 100644
--- a/drivers/net/ethernet/octeon/octeon_mgmt.c
+++ b/drivers/net/ethernet/octeon/octeon_mgmt.c
@@ -626,7 +626,7 @@ static int octeon_mgmt_ioctl(struct net_device *netdev,
 	return phy_mii_ioctl(p->phydev, rq, cmd);
 }
 
-static void octeon_mgmt_adjust_link(struct net_device *netdev)
+static void octeon_mgmt_adjust_link(struct net_device *netdev, void *context)
 {
 	struct octeon_mgmt *p = netdev_priv(netdev);
 	int port = p->port;
@@ -681,7 +681,7 @@ static int octeon_mgmt_init_phy(struct net_device *netdev)
 	snprintf(phy_id, sizeof(phy_id), PHY_ID_FMT, "mdio-octeon-0", p->port);
 
 	p->phydev = phy_connect(netdev, phy_id, octeon_mgmt_adjust_link, 0,
-				PHY_INTERFACE_MODE_MII);
+				PHY_INTERFACE_MODE_MII, NULL);
 
 	if (IS_ERR(p->phydev)) {
 		p->phydev = NULL;
diff --git a/drivers/net/ethernet/pasemi/pasemi_mac.c b/drivers/net/ethernet/pasemi/pasemi_mac.c
index e559dfa..9aba6b4 100644
--- a/drivers/net/ethernet/pasemi/pasemi_mac.c
+++ b/drivers/net/ethernet/pasemi/pasemi_mac.c
@@ -1021,7 +1021,7 @@ static irqreturn_t pasemi_mac_tx_intr(int irq, void *data)
 	return IRQ_HANDLED;
 }
 
-static void pasemi_adjust_link(struct net_device *dev)
+static void pasemi_adjust_link(struct net_device *dev, void *context)
 {
 	struct pasemi_mac *mac = netdev_priv(dev);
 	int msg;
@@ -1099,7 +1099,7 @@ static int pasemi_mac_phy_init(struct net_device *dev)
 	mac->duplex = -1;
 
 	phydev = of_phy_connect(dev, phy_dn, &pasemi_adjust_link, 0,
-				PHY_INTERFACE_MODE_SGMII);
+				PHY_INTERFACE_MODE_SGMII, NULL);
 
 	if (IS_ERR(phydev)) {
 		printk(KERN_ERR "%s: Could not attach to phy\n", dev->name);
diff --git a/drivers/net/ethernet/rdc/r6040.c b/drivers/net/ethernet/rdc/r6040.c
index d1827e8..c2f3e53 100644
--- a/drivers/net/ethernet/rdc/r6040.c
+++ b/drivers/net/ethernet/rdc/r6040.c
@@ -1000,7 +1000,7 @@ static const struct net_device_ops r6040_netdev_ops = {
 #endif
 };
 
-static void r6040_adjust_link(struct net_device *dev)
+static void r6040_adjust_link(struct net_device *dev, void *context)
 {
 	struct r6040_private *lp = netdev_priv(dev);
 	struct phy_device *phydev = lp->phydev;
@@ -1045,7 +1045,7 @@ static int r6040_mii_probe(struct net_device *dev)
 	}
 
 	phydev = phy_connect(dev, dev_name(&phydev->dev), &r6040_adjust_link,
-				0, PHY_INTERFACE_MODE_MII);
+				0, PHY_INTERFACE_MODE_MII, NULL);
 
 	if (IS_ERR(phydev)) {
 		dev_err(&lp->pdev->dev, "could not attach to PHY\n");
diff --git a/drivers/net/ethernet/renesas/sh_eth.c b/drivers/net/ethernet/renesas/sh_eth.c
index 79bf09b..eb089e6 100644
--- a/drivers/net/ethernet/renesas/sh_eth.c
+++ b/drivers/net/ethernet/renesas/sh_eth.c
@@ -1302,7 +1302,7 @@ static void sh_eth_timer(unsigned long data)
 }
 
 /* PHY state control function */
-static void sh_eth_adjust_link(struct net_device *ndev)
+static void sh_eth_adjust_link(struct net_device *ndev, void *context)
 {
 	struct sh_eth_private *mdp = netdev_priv(ndev);
 	struct phy_device *phydev = mdp->phydev;
@@ -1355,7 +1355,7 @@ static int sh_eth_phy_init(struct net_device *ndev)
 
 	/* Try connect to PHY */
 	phydev = phy_connect(ndev, phy_id, sh_eth_adjust_link,
-				0, mdp->phy_interface);
+				0, mdp->phy_interface, NULL);
 	if (IS_ERR(phydev)) {
 		dev_err(&ndev->dev, "phy_connect failed\n");
 		return PTR_ERR(phydev);
diff --git a/drivers/net/ethernet/s6gmac.c b/drivers/net/ethernet/s6gmac.c
index 2ed3ab4..d882267 100644
--- a/drivers/net/ethernet/s6gmac.c
+++ b/drivers/net/ethernet/s6gmac.c
@@ -739,7 +739,7 @@ static inline void s6gmac_linkisup(struct net_device *dev, int isup)
 	phy_print_status(phydev);
 }
 
-static void s6gmac_adjust_link(struct net_device *dev)
+static void s6gmac_adjust_link(struct net_device *dev, void *context)
 {
 	struct s6gmac *pd = netdev_priv(dev);
 	struct phy_device *phydev = pd->phydev;
@@ -796,7 +796,7 @@ static inline int s6gmac_phy_start(struct net_device *dev)
 	while ((i < PHY_MAX_ADDR) && (!(p = pd->mii.bus->phy_map[i])))
 		i++;
 	p = phy_connect(dev, dev_name(&p->dev), &s6gmac_adjust_link, 0,
-			PHY_INTERFACE_MODE_RGMII);
+			PHY_INTERFACE_MODE_RGMII, NULL);
 	if (IS_ERR(p)) {
 		printk(KERN_ERR "%s: Could not attach to PHY\n", dev->name);
 		return PTR_ERR(p);
diff --git a/drivers/net/ethernet/smsc/smsc911x.c b/drivers/net/ethernet/smsc/smsc911x.c
index 1466e5d..1221e242 100644
--- a/drivers/net/ethernet/smsc/smsc911x.c
+++ b/drivers/net/ethernet/smsc/smsc911x.c
@@ -916,7 +916,7 @@ static void smsc911x_phy_update_flowcontrol(struct smsc911x_data *pdata)
 
 /* Update link mode if anything has changed.  Called periodically when the
  * PHY is in polling mode, even if nothing has changed. */
-static void smsc911x_phy_adjust_link(struct net_device *dev)
+static void smsc911x_phy_adjust_link(struct net_device *dev, void *context)
 {
 	struct smsc911x_data *pdata = netdev_priv(dev);
 	struct phy_device *phy_dev = pdata->phy_dev;
@@ -999,7 +999,7 @@ static int smsc911x_mii_probe(struct net_device *dev)
 
 	ret = phy_connect_direct(dev, phydev,
 			&smsc911x_phy_adjust_link, 0,
-			pdata->config.phy_interface);
+			pdata->config.phy_interface, NULL);
 
 	if (ret) {
 		netdev_err(dev, "Could not attach to PHY\n");
diff --git a/drivers/net/ethernet/smsc/smsc9420.c b/drivers/net/ethernet/smsc/smsc9420.c
index fd33b21..40e727b 100644
--- a/drivers/net/ethernet/smsc/smsc9420.c
+++ b/drivers/net/ethernet/smsc/smsc9420.c
@@ -1130,7 +1130,7 @@ static void smsc9420_phy_update_flowcontrol(struct smsc9420_pdata *pd)
 
 /* Update link mode if anything has changed.  Called periodically when the
  * PHY is in polling mode, even if nothing has changed. */
-static void smsc9420_phy_adjust_link(struct net_device *dev)
+static void smsc9420_phy_adjust_link(struct net_device *dev, void *context)
 {
 	struct smsc9420_pdata *pd = netdev_priv(dev);
 	struct phy_device *phy_dev = pd->phy_dev;
@@ -1179,7 +1179,8 @@ static int smsc9420_mii_probe(struct net_device *dev)
 		phydev->phy_id);
 
 	phydev = phy_connect(dev, dev_name(&phydev->dev),
-		smsc9420_phy_adjust_link, 0, PHY_INTERFACE_MODE_MII);
+				smsc9420_phy_adjust_link, 0,
+				PHY_INTERFACE_MODE_MII, NULL);
 
 	if (IS_ERR(phydev)) {
 		pr_err("%s: Could not attach to PHY\n", dev->name);
diff --git a/drivers/net/ethernet/stmicro/stmmac/stmmac_main.c b/drivers/net/ethernet/stmicro/stmmac/stmmac_main.c
index 51b3b68..431f9b0 100644
--- a/drivers/net/ethernet/stmicro/stmmac/stmmac_main.c
+++ b/drivers/net/ethernet/stmicro/stmmac/stmmac_main.c
@@ -232,9 +232,10 @@ static inline void stmmac_hw_fix_mac_speed(struct stmmac_priv *priv)
 /**
  * stmmac_adjust_link
  * @dev: net device structure
+ * @context: context callback structure
  * Description: it adjusts the link parameters.
  */
-static void stmmac_adjust_link(struct net_device *dev)
+static void stmmac_adjust_link(struct net_device *dev, void *context)
 {
 	struct stmmac_priv *priv = netdev_priv(dev);
 	struct phy_device *phydev = priv->phydev;
@@ -350,7 +351,8 @@ static int stmmac_init_phy(struct net_device *dev)
 		 priv->plat->phy_addr);
 	pr_debug("stmmac_init_phy:  trying to attach to %s\n", phy_id);
 
-	phydev = phy_connect(dev, phy_id, &stmmac_adjust_link, 0, interface);
+	phydev = phy_connect(dev, phy_id, &stmmac_adjust_link,
+			     0, interface, NULL);
 
 	if (IS_ERR(phydev)) {
 		pr_err("%s: Could not attach to PHY\n", dev->name);
diff --git a/drivers/net/ethernet/ti/cpmac.c b/drivers/net/ethernet/ti/cpmac.c
index 860c252..f2cddc1 100644
--- a/drivers/net/ethernet/ti/cpmac.c
+++ b/drivers/net/ethernet/ti/cpmac.c
@@ -920,7 +920,7 @@ static const struct ethtool_ops cpmac_ethtool_ops = {
 	.set_ringparam = cpmac_set_ringparam,
 };
 
-static void cpmac_adjust_link(struct net_device *dev)
+static void cpmac_adjust_link(struct net_device *dev, void *context)
 {
 	struct cpmac_priv *priv = netdev_priv(dev);
 	int new_state = 0;
@@ -1174,7 +1174,7 @@ static int __devinit cpmac_probe(struct platform_device *pdev)
 						mdio_bus_id, phy_id);
 
 	priv->phy = phy_connect(dev, priv->phy_name, cpmac_adjust_link, 0,
-						PHY_INTERFACE_MODE_MII);
+				PHY_INTERFACE_MODE_MII, NULL);
 
 	if (IS_ERR(priv->phy)) {
 		if (netif_msg_drv(priv))
diff --git a/drivers/net/ethernet/ti/cpsw.c b/drivers/net/ethernet/ti/cpsw.c
index 6685bbb..5c97725 100644
--- a/drivers/net/ethernet/ti/cpsw.c
+++ b/drivers/net/ethernet/ti/cpsw.c
@@ -398,7 +398,7 @@ static void _cpsw_adjust_link(struct cpsw_slave *slave,
 	slave->mac_control = mac_control;
 }
 
-static void cpsw_adjust_link(struct net_device *ndev)
+static void cpsw_adjust_link(struct net_device *ndev, void *context)
 {
 	struct cpsw_priv	*priv = netdev_priv(ndev);
 	bool			link = false;
@@ -451,7 +451,8 @@ static void cpsw_slave_open(struct cpsw_slave *slave, struct cpsw_priv *priv)
 			   1 << slave_port, 0, ALE_MCAST_FWD_2);
 
 	slave->phy = phy_connect(priv->ndev, slave->data->phy_id,
-				 &cpsw_adjust_link, 0, slave->data->phy_if);
+				 &cpsw_adjust_link, 0,
+				 slave->data->phy_if, NULL);
 	if (IS_ERR(slave->phy)) {
 		dev_err(priv->dev, "phy %s not found on slave %d\n",
 			slave->data->phy_id, slave->slave_num);
diff --git a/drivers/net/ethernet/ti/davinci_emac.c b/drivers/net/ethernet/ti/davinci_emac.c
index 4da93a5..a902a2d 100644
--- a/drivers/net/ethernet/ti/davinci_emac.c
+++ b/drivers/net/ethernet/ti/davinci_emac.c
@@ -1446,7 +1446,7 @@ void emac_poll_controller(struct net_device *ndev)
 }
 #endif
 
-static void emac_adjust_link(struct net_device *ndev)
+static void emac_adjust_link(struct net_device *ndev, void *context)
 {
 	struct emac_priv *priv = netdev_priv(ndev);
 	struct phy_device *phydev = priv->phydev;
@@ -1597,7 +1597,7 @@ static int emac_dev_open(struct net_device *ndev)
 	if (priv->phy_id && *priv->phy_id) {
 		priv->phydev = phy_connect(ndev, priv->phy_id,
 					   &emac_adjust_link, 0,
-					   PHY_INTERFACE_MODE_MII);
+					   PHY_INTERFACE_MODE_MII, NULL);
 
 		if (IS_ERR(priv->phydev)) {
 			dev_err(emac_dev, "could not connect to phy %s\n",
diff --git a/drivers/net/ethernet/toshiba/tc35815.c b/drivers/net/ethernet/toshiba/tc35815.c
index 651a70c..ef21735 100644
--- a/drivers/net/ethernet/toshiba/tc35815.c
+++ b/drivers/net/ethernet/toshiba/tc35815.c
@@ -537,7 +537,7 @@ static int tc_mdio_write(struct mii_bus *bus, int mii_id, int regnum, u16 val)
 	return 0;
 }
 
-static void tc_handle_link_change(struct net_device *dev)
+static void tc_handle_link_change(struct net_device *dev, void *context)
 {
 	struct tc35815_local *lp = netdev_priv(dev);
 	struct phy_device *phydev = lp->phy_dev;
@@ -635,7 +635,8 @@ static int tc_mii_probe(struct net_device *dev)
 	phydev = phy_connect(dev, dev_name(&phydev->dev),
 			     &tc_handle_link_change, 0,
 			     lp->chiptype == TC35815_TX4939 ?
-			     PHY_INTERFACE_MODE_RMII : PHY_INTERFACE_MODE_MII);
+			     PHY_INTERFACE_MODE_RMII : PHY_INTERFACE_MODE_MII,
+			     NULL);
 	if (IS_ERR(phydev)) {
 		printk(KERN_ERR "%s: Could not attach to PHY\n", dev->name);
 		return PTR_ERR(phydev);
diff --git a/drivers/net/ethernet/xilinx/ll_temac_main.c b/drivers/net/ethernet/xilinx/ll_temac_main.c
index 1eaf712..97e2d77 100644
--- a/drivers/net/ethernet/xilinx/ll_temac_main.c
+++ b/drivers/net/ethernet/xilinx/ll_temac_main.c
@@ -590,7 +590,7 @@ static void temac_device_reset(struct net_device *ndev)
 	ndev->trans_start = jiffies; /* prevent tx timeout */
 }
 
-void temac_adjust_link(struct net_device *ndev)
+void temac_adjust_link(struct net_device *ndev, void *context)
 {
 	struct temac_local *lp = netdev_priv(ndev);
 	struct phy_device *phy = lp->phy_dev;
@@ -857,7 +857,7 @@ static int temac_open(struct net_device *ndev)
 
 	if (lp->phy_node) {
 		lp->phy_dev = of_phy_connect(lp->ndev, lp->phy_node,
-					     temac_adjust_link, 0, 0);
+					     temac_adjust_link, 0, 0, NULL);
 		if (!lp->phy_dev) {
 			dev_err(lp->dev, "of_phy_connect() failed\n");
 			return -ENODEV;
diff --git a/drivers/net/ethernet/xilinx/xilinx_axienet_main.c b/drivers/net/ethernet/xilinx/xilinx_axienet_main.c
index 9c365e1..d69ae3c 100644
--- a/drivers/net/ethernet/xilinx/xilinx_axienet_main.c
+++ b/drivers/net/ethernet/xilinx/xilinx_axienet_main.c
@@ -522,6 +522,7 @@ static void axienet_device_reset(struct net_device *ndev)
 /**
  * axienet_adjust_link - Adjust the PHY link speed/duplex.
  * @ndev:	Pointer to the net_device structure
+ * @context:    Pointer to the context argument
  *
  * This function is called to change the speed and duplex setting after
  * auto negotiation is done by the PHY. This is the function that gets
@@ -934,7 +935,7 @@ static int axienet_open(struct net_device *ndev)
 	if (lp->phy_node) {
 		lp->phy_dev = of_phy_connect(lp->ndev, lp->phy_node,
 					     axienet_adjust_link, 0,
-					     PHY_INTERFACE_MODE_GMII);
+					     PHY_INTERFACE_MODE_GMII, NULL);
 		if (!lp->phy_dev) {
 			dev_err(lp->dev, "of_phy_connect() failed\n");
 			return -ENODEV;
diff --git a/drivers/net/ethernet/xilinx/xilinx_emaclite.c b/drivers/net/ethernet/xilinx/xilinx_emaclite.c
index 77cfe51..eb641aa 100644
--- a/drivers/net/ethernet/xilinx/xilinx_emaclite.c
+++ b/drivers/net/ethernet/xilinx/xilinx_emaclite.c
@@ -892,11 +892,12 @@ err_register:
 /**
  * xemaclite_adjust_link - Link state callback for the Emaclite device
  * @ndev: pointer to net_device struct
+ * @context: pointer to context argument
  *
  * There's nothing in the Emaclite device to be configured when the link
  * state changes. We just print the status.
  */
-void xemaclite_adjust_link(struct net_device *ndev)
+void xemaclite_adjust_link(struct net_device *ndev, void *context)
 {
 	struct net_local *lp = netdev_priv(ndev);
 	struct phy_device *phy = lp->phy_dev;
@@ -932,7 +933,7 @@ static int xemaclite_open(struct net_device *dev)
 
 		lp->phy_dev = of_phy_connect(lp->ndev, lp->phy_node,
 					     xemaclite_adjust_link, 0,
-					     PHY_INTERFACE_MODE_MII);
+					     PHY_INTERFACE_MODE_MII, NULL);
 		if (!lp->phy_dev) {
 			dev_err(&lp->ndev->dev, "of_phy_connect() failed\n");
 			return -ENODEV;
diff --git a/drivers/net/ethernet/xscale/ixp4xx_eth.c b/drivers/net/ethernet/xscale/ixp4xx_eth.c
index 482648f..5c39324 100644
--- a/drivers/net/ethernet/xscale/ixp4xx_eth.c
+++ b/drivers/net/ethernet/xscale/ixp4xx_eth.c
@@ -543,7 +543,7 @@ static void ixp4xx_mdio_remove(void)
 }
 
 
-static void ixp4xx_adjust_link(struct net_device *dev)
+static void ixp4xx_adjust_link(struct net_device *dev, void *context)
 {
 	struct port *port = netdev_priv(dev);
 	struct phy_device *phydev = port->phydev;
@@ -1448,7 +1448,7 @@ static int __devinit eth_init_one(struct platform_device *pdev)
 	snprintf(phy_id, MII_BUS_ID_SIZE + 3, PHY_ID_FMT,
 		mdio_bus->id, plat->phy);
 	port->phydev = phy_connect(dev, phy_id, &ixp4xx_adjust_link, 0,
-				   PHY_INTERFACE_MODE_MII);
+				   PHY_INTERFACE_MODE_MII, NULL);
 	if (IS_ERR(port->phydev)) {
 		err = PTR_ERR(port->phydev);
 		goto err_free_mem;
-- 
1.7.9.5
