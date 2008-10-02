From: Lennert Buytenhek <buytenh@wantstofly.org>
Subject: [PATCHv2 1/3] phylib: rename mii_bus::dev to mii_bus::parent
Date: Thu, 2 Oct 2008 03:41:33 +0200
Message-ID: <20081002014133.GB26575@xi.wantstofly.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Byron Bradley <byron.bbradley@gmail.com>,
	Tim Ellis <tim.ellis@mac.com>, Imre Kaloz <kaloz@openwrt.org>,
	Nicolas Pitre <nico@cam.org>, Dirk Teurlings <dirk@upexia.nl>,
	Peter van Valderen <p.v.valderen@gmail.com>
To: netdev@vger.kernel.org, Andy Fleming <afleming@freescale.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from xi.wantstofly.org ([83.160.184.112]:42385 "EHLO
	xi.wantstofly.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751807AbYJBBle (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 1 Oct 2008 21:41:34 -0400
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

In preparation of giving mii_bus objects a device tree presence of
their own, rename struct mii_bus's ->dev argument to ->parent, since
having a 'struct device *dev' that points to our parent device
conflicts with introducing a 'struct device dev' representing our own
device.

Signed-off-by: Lennert Buytenhek <buytenh@marvell.com>
---
 arch/powerpc/platforms/82xx/ep8248e.c     |    2 +-
 arch/powerpc/platforms/pasemi/gpio_mdio.c |    2 +-
 drivers/net/fec_mpc52xx_phy.c             |    2 +-
 drivers/net/fs_enet/mii-bitbang.c         |    2 +-
 drivers/net/fs_enet/mii-fec.c             |    2 +-
 drivers/net/gianfar_mii.c                 |    2 +-
 drivers/net/macb.c                        |    2 +-
 drivers/net/mv643xx_eth.c                 |    2 +-
 drivers/net/phy/fixed.c                   |    2 +-
 drivers/net/phy/mdio-ofgpio.c             |    2 +-
 drivers/net/phy/mdio_bus.c                |    2 +-
 drivers/net/sb1250-mac.c                  |    2 +-
 drivers/net/sh_eth.c                      |    2 +-
 drivers/net/tc35815.c                     |    2 +-
 drivers/net/tg3.c                         |    2 +-
 drivers/net/ucc_geth_mii.c                |    2 +-
 include/linux/phy.h                       |    2 +-
 17 files changed, 17 insertions(+), 17 deletions(-)

diff --git a/arch/powerpc/platforms/82xx/ep8248e.c b/arch/powerpc/platforms/82xx/ep8248e.c
index d5770fd..0eb6d7f 100644
--- a/arch/powerpc/platforms/82xx/ep8248e.c
+++ b/arch/powerpc/platforms/82xx/ep8248e.c
@@ -137,7 +137,7 @@ static int __devinit ep8248e_mdio_probe(struct of_device *ofdev,
 		bus->irq[i] = -1;
 
 	bus->name = "ep8248e-mdio-bitbang";
-	bus->dev = &ofdev->dev;
+	bus->parent = &ofdev->dev;
 	snprintf(bus->id, MII_BUS_ID_SIZE, "%x", res.start);
 
 	return mdiobus_register(bus);
diff --git a/arch/powerpc/platforms/pasemi/gpio_mdio.c b/arch/powerpc/platforms/pasemi/gpio_mdio.c
index ab69554..798c7ab 100644
--- a/arch/powerpc/platforms/pasemi/gpio_mdio.c
+++ b/arch/powerpc/platforms/pasemi/gpio_mdio.c
@@ -272,7 +272,7 @@ static int __devinit gpio_mdio_probe(struct of_device *ofdev,
 	prop = of_get_property(np, "mdio-pin", NULL);
 	priv->mdio_pin = *prop;
 
-	new_bus->dev = dev;
+	new_bus->parent = dev;
 	dev_set_drvdata(dev, new_bus);
 
 	err = mdiobus_register(new_bus);
diff --git a/drivers/net/fec_mpc52xx_phy.c b/drivers/net/fec_mpc52xx_phy.c
index f563444..2a52330 100644
--- a/drivers/net/fec_mpc52xx_phy.c
+++ b/drivers/net/fec_mpc52xx_phy.c
@@ -127,7 +127,7 @@ static int mpc52xx_fec_mdio_probe(struct of_device *of, const struct of_device_i
 	snprintf(bus->id, MII_BUS_ID_SIZE, "%x", res.start);
 	bus->priv = priv;
 
-	bus->dev = dev;
+	bus->parent = dev;
 	dev_set_drvdata(dev, bus);
 
 	/* set MII speed */
diff --git a/drivers/net/fs_enet/mii-bitbang.c b/drivers/net/fs_enet/mii-bitbang.c
index be4b72f..2774252 100644
--- a/drivers/net/fs_enet/mii-bitbang.c
+++ b/drivers/net/fs_enet/mii-bitbang.c
@@ -203,7 +203,7 @@ static int __devinit fs_enet_mdio_probe(struct of_device *ofdev,
 		if (!strcmp(np->type, "ethernet-phy"))
 			add_phy(new_bus, np);
 
-	new_bus->dev = &ofdev->dev;
+	new_bus->parent = &ofdev->dev;
 	dev_set_drvdata(&ofdev->dev, new_bus);
 
 	ret = mdiobus_register(new_bus);
diff --git a/drivers/net/fs_enet/mii-fec.c b/drivers/net/fs_enet/mii-fec.c
index 695f74c..4d89a22 100644
--- a/drivers/net/fs_enet/mii-fec.c
+++ b/drivers/net/fs_enet/mii-fec.c
@@ -172,7 +172,7 @@ static int __devinit fs_enet_mdio_probe(struct of_device *ofdev,
 		if (!strcmp(np->type, "ethernet-phy"))
 			add_phy(new_bus, np);
 
-	new_bus->dev = &ofdev->dev;
+	new_bus->parent = &ofdev->dev;
 	dev_set_drvdata(&ofdev->dev, new_bus);
 
 	ret = mdiobus_register(new_bus);
diff --git a/drivers/net/gianfar_mii.c b/drivers/net/gianfar_mii.c
index ebcfb27..574884c 100644
--- a/drivers/net/gianfar_mii.c
+++ b/drivers/net/gianfar_mii.c
@@ -196,7 +196,7 @@ static int gfar_mdio_probe(struct device *dev)
 
 	new_bus->irq = pdata->irq;
 
-	new_bus->dev = dev;
+	new_bus->parent = dev;
 	dev_set_drvdata(dev, new_bus);
 
 	/*
diff --git a/drivers/net/macb.c b/drivers/net/macb.c
index 84c77f1..045361f 100644
--- a/drivers/net/macb.c
+++ b/drivers/net/macb.c
@@ -250,7 +250,7 @@ static int macb_mii_init(struct macb *bp)
 	bp->mii_bus.reset = &macb_mdio_reset;
 	snprintf(bp->mii_bus.id, MII_BUS_ID_SIZE, "%x", bp->pdev->id);
 	bp->mii_bus.priv = bp;
-	bp->mii_bus.dev = &bp->dev->dev;
+	bp->mii_bus.parent = &bp->dev->dev;
 	pdata = bp->pdev->dev.platform_data;
 
 	if (pdata)
diff --git a/drivers/net/mv643xx_eth.c b/drivers/net/mv643xx_eth.c
index 55aa8ba..0709c49 100644
--- a/drivers/net/mv643xx_eth.c
+++ b/drivers/net/mv643xx_eth.c
@@ -2344,7 +2344,7 @@ static int mv643xx_eth_shared_probe(struct platform_device *pdev)
 		msp->smi_bus.read = smi_bus_read;
 		msp->smi_bus.write = smi_bus_write,
 		snprintf(msp->smi_bus.id, MII_BUS_ID_SIZE, "%d", pdev->id);
-		msp->smi_bus.dev = &pdev->dev;
+		msp->smi_bus.parent = &pdev->dev;
 		msp->smi_bus.phy_mask = 0xffffffff;
 		if (mdiobus_register(&msp->smi_bus) < 0)
 			goto out_unmap;
diff --git a/drivers/net/phy/fixed.c b/drivers/net/phy/fixed.c
index 4e07956..1cec896 100644
--- a/drivers/net/phy/fixed.c
+++ b/drivers/net/phy/fixed.c
@@ -215,7 +215,7 @@ static int __init fixed_mdio_bus_init(void)
 
 	snprintf(fmb->mii_bus.id, MII_BUS_ID_SIZE, "0");
 	fmb->mii_bus.name = "Fixed MDIO Bus";
-	fmb->mii_bus.dev = &pdev->dev;
+	fmb->mii_bus.parent = &pdev->dev;
 	fmb->mii_bus.read = &fixed_mdio_read;
 	fmb->mii_bus.write = &fixed_mdio_write;
 	fmb->mii_bus.irq = fmb->irqs;
diff --git a/drivers/net/phy/mdio-ofgpio.c b/drivers/net/phy/mdio-ofgpio.c
index 7edfc0c..27bd453 100644
--- a/drivers/net/phy/mdio-ofgpio.c
+++ b/drivers/net/phy/mdio-ofgpio.c
@@ -142,7 +142,7 @@ static int __devinit mdio_ofgpio_probe(struct of_device *ofdev,
 		if (!strcmp(np->type, "ethernet-phy"))
 			add_phy(new_bus, np);
 
-	new_bus->dev = &ofdev->dev;
+	new_bus->parent = &ofdev->dev;
 	dev_set_drvdata(&ofdev->dev, new_bus);
 
 	ret = mdiobus_register(new_bus);
diff --git a/drivers/net/phy/mdio_bus.c b/drivers/net/phy/mdio_bus.c
index a00e647..73e2696 100644
--- a/drivers/net/phy/mdio_bus.c
+++ b/drivers/net/phy/mdio_bus.c
@@ -107,7 +107,7 @@ struct phy_device *mdiobus_scan(struct mii_bus *bus, int addr)
 
 	phydev->irq = bus->irq != NULL ? bus->irq[addr] : PHY_POLL;
 
-	phydev->dev.parent = bus->dev;
+	phydev->dev.parent = bus->parent;
 	phydev->dev.bus = &mdio_bus_type;
 	snprintf(phydev->dev.bus_id, BUS_ID_SIZE, PHY_ID_FMT, bus->id, addr);
 
diff --git a/drivers/net/sb1250-mac.c b/drivers/net/sb1250-mac.c
index fe41e4e..d6de19c 100644
--- a/drivers/net/sb1250-mac.c
+++ b/drivers/net/sb1250-mac.c
@@ -2377,7 +2377,7 @@ static int sbmac_init(struct platform_device *pldev, long long base)
 	for (i = 0; i < PHY_MAX_ADDR; ++i)
 		sc->mii_bus.irq[i] = SBMAC_PHY_INT;
 
-	sc->mii_bus.dev = &pldev->dev;
+	sc->mii_bus.parent = &pldev->dev;
 	dev_set_drvdata(&pldev->dev, &sc->mii_bus);
 
 	return 0;
diff --git a/drivers/net/sh_eth.c b/drivers/net/sh_eth.c
index 1c370e6..1b3b7b6 100644
--- a/drivers/net/sh_eth.c
+++ b/drivers/net/sh_eth.c
@@ -1140,7 +1140,7 @@ static int sh_mdio_init(struct net_device *ndev, int id)
 
 	/* Hook up MII support for ethtool */
 	mdp->mii_bus->name = "sh_mii";
-	mdp->mii_bus->dev = &ndev->dev;
+	mdp->mii_bus->parent = &ndev->dev;
 	mdp->mii_bus->id[0] = id;
 
 	/* PHY IRQ */
diff --git a/drivers/net/tc35815.c b/drivers/net/tc35815.c
index 8487ace..1f2b1f2 100644
--- a/drivers/net/tc35815.c
+++ b/drivers/net/tc35815.c
@@ -768,7 +768,7 @@ static int tc_mii_init(struct net_device *dev)
 	snprintf(lp->mii_bus.id, MII_BUS_ID_SIZE, "%x",
 		 (lp->pci_dev->bus->number << 8) | lp->pci_dev->devfn);
 	lp->mii_bus.priv = dev;
-	lp->mii_bus.dev = &lp->pci_dev->dev;
+	lp->mii_bus.parent = &lp->pci_dev->dev;
 	lp->mii_bus.irq = kmalloc(sizeof(int) * PHY_MAX_ADDR, GFP_KERNEL);
 	if (!lp->mii_bus.irq) {
 		err = -ENOMEM;
diff --git a/drivers/net/tg3.c b/drivers/net/tg3.c
index 71d2c5c..fc815a3 100644
--- a/drivers/net/tg3.c
+++ b/drivers/net/tg3.c
@@ -961,7 +961,7 @@ static int tg3_mdio_init(struct tg3 *tp)
 	snprintf(mdio_bus->id, MII_BUS_ID_SIZE, "%x",
 		 (tp->pdev->bus->number << 8) | tp->pdev->devfn);
 	mdio_bus->priv     = tp;
-	mdio_bus->dev      = &tp->pdev->dev;
+	mdio_bus->parent   = &tp->pdev->dev;
 	mdio_bus->read     = &tg3_mdio_read;
 	mdio_bus->write    = &tg3_mdio_write;
 	mdio_bus->reset    = &tg3_mdio_reset;
diff --git a/drivers/net/ucc_geth_mii.c b/drivers/net/ucc_geth_mii.c
index 6d9e7ad..75b72fe 100644
--- a/drivers/net/ucc_geth_mii.c
+++ b/drivers/net/ucc_geth_mii.c
@@ -187,7 +187,7 @@ static int uec_mdio_probe(struct of_device *ofdev, const struct of_device_id *ma
 
 	new_bus->priv = (void __force *)regs;
 
-	new_bus->dev = device;
+	new_bus->parent = device;
 	dev_set_drvdata(device, new_bus);
 
 	/* Read MII management master from device tree */
diff --git a/include/linux/phy.h b/include/linux/phy.h
index 344ba69..3bfda82 100644
--- a/include/linux/phy.h
+++ b/include/linux/phy.h
@@ -99,7 +99,7 @@ struct mii_bus {
 	 */
 	struct mutex mdio_lock;
 
-	struct device *dev;
+	struct device *parent;
 
 	/* list of all PHYs on bus */
 	struct phy_device *phy_map[PHY_MAX_ADDR];
-- 
1.5.6.4
