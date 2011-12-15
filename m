From: Timur Tabi <timur@freescale.com>
Subject: [PATCH] phylib: update mdiobus_alloc() to allocate extra private space
Date: Thu, 15 Dec 2011 10:51:35 -0600
Message-ID: <1323967895-5205-1-git-send-email-timur@freescale.com>
Mime-Version: 1.0
Content-Type: text/plain
To: <davem@davemloft.net>, <afleming@freescale.com>,
	<netdev@vger.kernel.org>, <linuxppc-dev@ozlabs.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from am1ehsobe006.messaging.microsoft.com ([213.199.154.209]:45807
	"EHLO AM1EHSOBE006.bigfish.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S932644Ab1LOQvl (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 15 Dec 2011 11:51:41 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Augment mdiobus_alloc() to take a parameter indicating the number of extra
bytes to allocate for private data.  Almost all callers of mdiobus_alloc()
separately allocate a private data structure.  By allowing mdiobus_alloc()
to allocate extra memory, the two allocations can be merged into one.

This patch does not change any of the callers to actually take advantage
of this feature, however.  That change can be made by the individual
maintainers at their leisure.  For now, all callers ask for zero additional
bytes, which mimics the previous behavior.

Signed-off-by: Timur Tabi <timur@freescale.com>
---
 arch/powerpc/platforms/pasemi/gpio_mdio.c         |    2 +-
 drivers/net/ethernet/adi/bfin_mac.c               |    2 +-
 drivers/net/ethernet/aeroflex/greth.c             |    2 +-
 drivers/net/ethernet/amd/au1000_eth.c             |    2 +-
 drivers/net/ethernet/broadcom/bcm63xx_enet.c      |    2 +-
 drivers/net/ethernet/broadcom/sb1250-mac.c        |    2 +-
 drivers/net/ethernet/broadcom/tg3.c               |    2 +-
 drivers/net/ethernet/cadence/macb.c               |    2 +-
 drivers/net/ethernet/dnet.c                       |    2 +-
 drivers/net/ethernet/ethoc.c                      |    2 +-
 drivers/net/ethernet/faraday/ftgmac100.c          |    2 +-
 drivers/net/ethernet/freescale/fec.c              |    2 +-
 drivers/net/ethernet/freescale/fec_mpc52xx_phy.c  |    2 +-
 drivers/net/ethernet/freescale/fs_enet/mii-fec.c  |    2 +-
 drivers/net/ethernet/freescale/fsl_pq_mdio.c      |    2 +-
 drivers/net/ethernet/lantiq_etop.c                |    2 +-
 drivers/net/ethernet/marvell/mv643xx_eth.c        |    2 +-
 drivers/net/ethernet/marvell/pxa168_eth.c         |    2 +-
 drivers/net/ethernet/rdc/r6040.c                  |    2 +-
 drivers/net/ethernet/s6gmac.c                     |    2 +-
 drivers/net/ethernet/smsc/smsc911x.c              |    2 +-
 drivers/net/ethernet/smsc/smsc9420.c              |    2 +-
 drivers/net/ethernet/stmicro/stmmac/stmmac_mdio.c |    2 +-
 drivers/net/ethernet/ti/cpmac.c                   |    2 +-
 drivers/net/ethernet/ti/davinci_mdio.c            |    2 +-
 drivers/net/ethernet/toshiba/tc35815.c            |    2 +-
 drivers/net/ethernet/xilinx/ll_temac_mdio.c       |    2 +-
 drivers/net/ethernet/xilinx/xilinx_emaclite.c     |    2 +-
 drivers/net/ethernet/xscale/ixp4xx_eth.c          |    2 +-
 drivers/net/phy/fixed.c                           |    2 +-
 drivers/net/phy/mdio-bitbang.c                    |    2 +-
 drivers/net/phy/mdio-octeon.c                     |    2 +-
 drivers/net/phy/mdio_bus.c                        |   20 +++++++++++++++++---
 drivers/staging/et131x/et131x.c                   |    2 +-
 include/linux/phy.h                               |    2 +-
 net/dsa/dsa.c                                     |    2 +-
 36 files changed, 52 insertions(+), 38 deletions(-)

diff --git a/arch/powerpc/platforms/pasemi/gpio_mdio.c b/arch/powerpc/platforms/pasemi/gpio_mdio.c
index 9886296..754a57b 100644
--- a/arch/powerpc/platforms/pasemi/gpio_mdio.c
+++ b/arch/powerpc/platforms/pasemi/gpio_mdio.c
@@ -230,7 +230,7 @@ static int __devinit gpio_mdio_probe(struct platform_device *ofdev)
 	if (!priv)
 		goto out;
 
-	new_bus = mdiobus_alloc();
+	new_bus = mdiobus_alloc(0);
 
 	if (!new_bus)
 		goto out_free_priv;
diff --git a/drivers/net/ethernet/adi/bfin_mac.c b/drivers/net/ethernet/adi/bfin_mac.c
index b6d69c9..ea71758 100644
--- a/drivers/net/ethernet/adi/bfin_mac.c
+++ b/drivers/net/ethernet/adi/bfin_mac.c
@@ -1659,7 +1659,7 @@ static int __devinit bfin_mii_bus_probe(struct platform_device *pdev)
 	}
 
 	rc = -ENOMEM;
-	miibus = mdiobus_alloc();
+	miibus = mdiobus_alloc(0);
 	if (miibus == NULL)
 		goto out_err_alloc;
 	miibus->read = bfin_mdiobus_read;
diff --git a/drivers/net/ethernet/aeroflex/greth.c b/drivers/net/ethernet/aeroflex/greth.c
index c885aa9..c6bc550 100644
--- a/drivers/net/ethernet/aeroflex/greth.c
+++ b/drivers/net/ethernet/aeroflex/greth.c
@@ -1326,7 +1326,7 @@ static int greth_mdio_init(struct greth_private *greth)
 	int ret, phy;
 	unsigned long timeout;
 
-	greth->mdio = mdiobus_alloc();
+	greth->mdio = mdiobus_alloc(0);
 	if (!greth->mdio) {
 		return -ENOMEM;
 	}
diff --git a/drivers/net/ethernet/amd/au1000_eth.c b/drivers/net/ethernet/amd/au1000_eth.c
index cc9262b..5c30544 100644
--- a/drivers/net/ethernet/amd/au1000_eth.c
+++ b/drivers/net/ethernet/amd/au1000_eth.c
@@ -1159,7 +1159,7 @@ static int __devinit au1000_probe(struct platform_device *pdev)
 		goto err_mdiobus_alloc;
 	}
 
-	aup->mii_bus = mdiobus_alloc();
+	aup->mii_bus = mdiobus_alloc(0);
 	if (aup->mii_bus == NULL) {
 		dev_err(&pdev->dev, "failed to allocate mdiobus structure\n");
 		err = -ENOMEM;
diff --git a/drivers/net/ethernet/broadcom/bcm63xx_enet.c b/drivers/net/ethernet/broadcom/bcm63xx_enet.c
index a11a8ad..c847801 100644
--- a/drivers/net/ethernet/broadcom/bcm63xx_enet.c
+++ b/drivers/net/ethernet/broadcom/bcm63xx_enet.c
@@ -1715,7 +1715,7 @@ static int __devinit bcm_enet_probe(struct platform_device *pdev)
 	/* MII bus registration */
 	if (priv->has_phy) {
 
-		priv->mii_bus = mdiobus_alloc();
+		priv->mii_bus = mdiobus_alloc(0);
 		if (!priv->mii_bus) {
 			ret = -ENOMEM;
 			goto out_uninit_hw;
diff --git a/drivers/net/ethernet/broadcom/sb1250-mac.c b/drivers/net/ethernet/broadcom/sb1250-mac.c
index 8fa7abc..4ff830e 100644
--- a/drivers/net/ethernet/broadcom/sb1250-mac.c
+++ b/drivers/net/ethernet/broadcom/sb1250-mac.c
@@ -2252,7 +2252,7 @@ static int sbmac_init(struct platform_device *pldev, long long base)
 	/* This is needed for PASS2 for Rx H/W checksum feature */
 	sbmac_set_iphdr_offset(sc);
 
-	sc->mii_bus = mdiobus_alloc();
+	sc->mii_bus = mdiobus_alloc(0);
 	if (sc->mii_bus == NULL) {
 		err = -ENOMEM;
 		goto uninit_ctx;
diff --git a/drivers/net/ethernet/broadcom/tg3.c b/drivers/net/ethernet/broadcom/tg3.c
index 1979151..6ce2c4c 100644
--- a/drivers/net/ethernet/broadcom/tg3.c
+++ b/drivers/net/ethernet/broadcom/tg3.c
@@ -1323,7 +1323,7 @@ static int tg3_mdio_init(struct tg3 *tp)
 	if (!tg3_flag(tp, USE_PHYLIB) || tg3_flag(tp, MDIOBUS_INITED))
 		return 0;
 
-	tp->mdio_bus = mdiobus_alloc();
+	tp->mdio_bus = mdiobus_alloc(0);
 	if (tp->mdio_bus == NULL)
 		return -ENOMEM;
 
diff --git a/drivers/net/ethernet/cadence/macb.c b/drivers/net/ethernet/cadence/macb.c
index a437b46..dc3b09e 100644
--- a/drivers/net/ethernet/cadence/macb.c
+++ b/drivers/net/ethernet/cadence/macb.c
@@ -234,7 +234,7 @@ static int macb_mii_init(struct macb *bp)
 	/* Enable management port */
 	macb_writel(bp, NCR, MACB_BIT(MPE));
 
-	bp->mii_bus = mdiobus_alloc();
+	bp->mii_bus = mdiobus_alloc(0);
 	if (bp->mii_bus == NULL) {
 		err = -ENOMEM;
 		goto err_out;
diff --git a/drivers/net/ethernet/dnet.c b/drivers/net/ethernet/dnet.c
index ce88c0f..04a55a4 100644
--- a/drivers/net/ethernet/dnet.c
+++ b/drivers/net/ethernet/dnet.c
@@ -316,7 +316,7 @@ static int dnet_mii_init(struct dnet *bp)
 {
 	int err, i;
 
-	bp->mii_bus = mdiobus_alloc();
+	bp->mii_bus = mdiobus_alloc(0);
 	if (bp->mii_bus == NULL)
 		return -ENOMEM;
 
diff --git a/drivers/net/ethernet/ethoc.c b/drivers/net/ethernet/ethoc.c
index 60f0e78..9916475 100644
--- a/drivers/net/ethernet/ethoc.c
+++ b/drivers/net/ethernet/ethoc.c
@@ -1056,7 +1056,7 @@ static int __devinit ethoc_probe(struct platform_device *pdev)
 	ethoc_set_mac_address(netdev, netdev->dev_addr);
 
 	/* register MII bus */
-	priv->mdio = mdiobus_alloc();
+	priv->mdio = mdiobus_alloc(0);
 	if (!priv->mdio) {
 		ret = -ENOMEM;
 		goto free;
diff --git a/drivers/net/ethernet/faraday/ftgmac100.c b/drivers/net/ethernet/faraday/ftgmac100.c
index fb5579a..19fc332 100644
--- a/drivers/net/ethernet/faraday/ftgmac100.c
+++ b/drivers/net/ethernet/faraday/ftgmac100.c
@@ -1248,7 +1248,7 @@ static int ftgmac100_probe(struct platform_device *pdev)
 	priv->irq = irq;
 
 	/* initialize mdio bus */
-	priv->mii_bus = mdiobus_alloc();
+	priv->mii_bus = mdiobus_alloc(0);
 	if (!priv->mii_bus) {
 		err = -EIO;
 		goto err_alloc_mdiobus;
diff --git a/drivers/net/ethernet/freescale/fec.c b/drivers/net/ethernet/freescale/fec.c
index 01ee9cc..ab1d39c 100644
--- a/drivers/net/ethernet/freescale/fec.c
+++ b/drivers/net/ethernet/freescale/fec.c
@@ -1066,7 +1066,7 @@ static int fec_enet_mii_init(struct platform_device *pdev)
 	fep->phy_speed <<= 1;
 	writel(fep->phy_speed, fep->hwp + FEC_MII_SPEED);
 
-	fep->mii_bus = mdiobus_alloc();
+	fep->mii_bus = mdiobus_alloc(0);
 	if (fep->mii_bus == NULL) {
 		err = -ENOMEM;
 		goto err_out;
diff --git a/drivers/net/ethernet/freescale/fec_mpc52xx_phy.c b/drivers/net/ethernet/freescale/fec_mpc52xx_phy.c
index 360a578..f5918c1 100644
--- a/drivers/net/ethernet/freescale/fec_mpc52xx_phy.c
+++ b/drivers/net/ethernet/freescale/fec_mpc52xx_phy.c
@@ -70,7 +70,7 @@ static int mpc52xx_fec_mdio_probe(struct platform_device *of)
 	struct resource res;
 	int err;
 
-	bus = mdiobus_alloc();
+	bus = mdiobus_alloc(0);
 	if (bus == NULL)
 		return -ENOMEM;
 	priv = kzalloc(sizeof(*priv), GFP_KERNEL);
diff --git a/drivers/net/ethernet/freescale/fs_enet/mii-fec.c b/drivers/net/ethernet/freescale/fs_enet/mii-fec.c
index 55bb867..74964ce 100644
--- a/drivers/net/ethernet/freescale/fs_enet/mii-fec.c
+++ b/drivers/net/ethernet/freescale/fs_enet/mii-fec.c
@@ -116,7 +116,7 @@ static int __devinit fs_enet_mdio_probe(struct platform_device *ofdev)
 		return -EINVAL;
 	get_bus_freq = match->data;
 
-	new_bus = mdiobus_alloc();
+	new_bus = mdiobus_alloc(0);
 	if (!new_bus)
 		goto out;
 
diff --git a/drivers/net/ethernet/freescale/fsl_pq_mdio.c b/drivers/net/ethernet/freescale/fsl_pq_mdio.c
index f109602..332418a 100644
--- a/drivers/net/ethernet/freescale/fsl_pq_mdio.c
+++ b/drivers/net/ethernet/freescale/fsl_pq_mdio.c
@@ -266,7 +266,7 @@ static int fsl_pq_mdio_probe(struct platform_device *ofdev)
 	if (!priv)
 		return -ENOMEM;
 
-	new_bus = mdiobus_alloc();
+	new_bus = mdiobus_alloc(0);
 	if (!new_bus) {
 		err = -ENOMEM;
 		goto err_free_priv;
diff --git a/drivers/net/ethernet/lantiq_etop.c b/drivers/net/ethernet/lantiq_etop.c
index 0b3567a..94a6055 100644
--- a/drivers/net/ethernet/lantiq_etop.c
+++ b/drivers/net/ethernet/lantiq_etop.c
@@ -425,7 +425,7 @@ ltq_etop_mdio_init(struct net_device *dev)
 	int i;
 	int err;
 
-	priv->mii_bus = mdiobus_alloc();
+	priv->mii_bus = mdiobus_alloc(0);
 	if (!priv->mii_bus) {
 		netdev_err(dev, "failed to allocate mii bus\n");
 		err = -ENOMEM;
diff --git a/drivers/net/ethernet/marvell/mv643xx_eth.c b/drivers/net/ethernet/marvell/mv643xx_eth.c
index e87847e..250e0cc 100644
--- a/drivers/net/ethernet/marvell/mv643xx_eth.c
+++ b/drivers/net/ethernet/marvell/mv643xx_eth.c
@@ -2604,7 +2604,7 @@ static int mv643xx_eth_shared_probe(struct platform_device *pdev)
 	 * Set up and register SMI bus.
 	 */
 	if (pd == NULL || pd->shared_smi == NULL) {
-		msp->smi_bus = mdiobus_alloc();
+		msp->smi_bus = mdiobus_alloc(0);
 		if (msp->smi_bus == NULL)
 			goto out_unmap;
 
diff --git a/drivers/net/ethernet/marvell/pxa168_eth.c b/drivers/net/ethernet/marvell/pxa168_eth.c
index 5ec409e..2dfb98a 100644
--- a/drivers/net/ethernet/marvell/pxa168_eth.c
+++ b/drivers/net/ethernet/marvell/pxa168_eth.c
@@ -1543,7 +1543,7 @@ static int pxa168_eth_probe(struct platform_device *pdev)
 	pep->timeout.function = rxq_refill_timer_wrapper;
 	pep->timeout.data = (unsigned long)pep;
 
-	pep->smi_bus = mdiobus_alloc();
+	pep->smi_bus = mdiobus_alloc(0);
 	if (pep->smi_bus == NULL) {
 		err = -ENOMEM;
 		goto err_base;
diff --git a/drivers/net/ethernet/rdc/r6040.c b/drivers/net/ethernet/rdc/r6040.c
index 4bf68cf..4175e57 100644
--- a/drivers/net/ethernet/rdc/r6040.c
+++ b/drivers/net/ethernet/rdc/r6040.c
@@ -1176,7 +1176,7 @@ static int __devinit r6040_init_one(struct pci_dev *pdev,
 
 	netif_napi_add(dev, &lp->napi, r6040_poll, 64);
 
-	lp->mii_bus = mdiobus_alloc();
+	lp->mii_bus = mdiobus_alloc(0);
 	if (!lp->mii_bus) {
 		dev_err(&pdev->dev, "mdiobus_alloc() failed\n");
 		err = -ENOMEM;
diff --git a/drivers/net/ethernet/s6gmac.c b/drivers/net/ethernet/s6gmac.c
index a7ff8ea..d8f11ef 100644
--- a/drivers/net/ethernet/s6gmac.c
+++ b/drivers/net/ethernet/s6gmac.c
@@ -994,7 +994,7 @@ static int __devinit s6gmac_probe(struct platform_device *pdev)
 			dev->name);
 		goto errdev;
 	}
-	mb = mdiobus_alloc();
+	mb = mdiobus_alloc(0);
 	if (!mb) {
 		printk(KERN_ERR DRV_PRMT "error allocating mii bus\n");
 		goto errmii;
diff --git a/drivers/net/ethernet/smsc/smsc911x.c b/drivers/net/ethernet/smsc/smsc911x.c
index 06d0df6..103297b 100644
--- a/drivers/net/ethernet/smsc/smsc911x.c
+++ b/drivers/net/ethernet/smsc/smsc911x.c
@@ -1037,7 +1037,7 @@ static int __devinit smsc911x_mii_init(struct platform_device *pdev,
 	struct smsc911x_data *pdata = netdev_priv(dev);
 	int err = -ENXIO, i;
 
-	pdata->mii_bus = mdiobus_alloc();
+	pdata->mii_bus = mdiobus_alloc(0);
 	if (!pdata->mii_bus) {
 		err = -ENOMEM;
 		goto err_out_1;
diff --git a/drivers/net/ethernet/smsc/smsc9420.c b/drivers/net/ethernet/smsc/smsc9420.c
index a9efbdf..16738a1 100644
--- a/drivers/net/ethernet/smsc/smsc9420.c
+++ b/drivers/net/ethernet/smsc/smsc9420.c
@@ -1205,7 +1205,7 @@ static int smsc9420_mii_init(struct net_device *dev)
 	struct smsc9420_pdata *pd = netdev_priv(dev);
 	int err = -ENXIO, i;
 
-	pd->mii_bus = mdiobus_alloc();
+	pd->mii_bus = mdiobus_alloc(0);
 	if (!pd->mii_bus) {
 		err = -ENOMEM;
 		goto err_out_1;
diff --git a/drivers/net/ethernet/stmicro/stmmac/stmmac_mdio.c b/drivers/net/ethernet/stmicro/stmmac/stmmac_mdio.c
index 9c3b9d5..5dc0396 100644
--- a/drivers/net/ethernet/stmicro/stmmac/stmmac_mdio.c
+++ b/drivers/net/ethernet/stmicro/stmmac/stmmac_mdio.c
@@ -144,7 +144,7 @@ int stmmac_mdio_register(struct net_device *ndev)
 	if (!mdio_bus_data)
 		return 0;
 
-	new_bus = mdiobus_alloc();
+	new_bus = mdiobus_alloc(0);
 	if (new_bus == NULL)
 		return -ENOMEM;
 
diff --git a/drivers/net/ethernet/ti/cpmac.c b/drivers/net/ethernet/ti/cpmac.c
index aaac0c7..b13df3c 100644
--- a/drivers/net/ethernet/ti/cpmac.c
+++ b/drivers/net/ethernet/ti/cpmac.c
@@ -1227,7 +1227,7 @@ int __devinit cpmac_init(void)
 	u32 mask;
 	int i, res;
 
-	cpmac_mii = mdiobus_alloc();
+	cpmac_mii = mdiobus_alloc(0);
 	if (cpmac_mii == NULL)
 		return -ENOMEM;
 
diff --git a/drivers/net/ethernet/ti/davinci_mdio.c b/drivers/net/ethernet/ti/davinci_mdio.c
index 7615040..fffddef 100644
--- a/drivers/net/ethernet/ti/davinci_mdio.c
+++ b/drivers/net/ethernet/ti/davinci_mdio.c
@@ -300,7 +300,7 @@ static int __devinit davinci_mdio_probe(struct platform_device *pdev)
 
 	data->pdata = pdata ? (*pdata) : default_pdata;
 
-	data->bus = mdiobus_alloc();
+	data->bus = mdiobus_alloc(0);
 	if (!data->bus) {
 		dev_err(dev, "failed to alloc mii bus\n");
 		ret = -ENOMEM;
diff --git a/drivers/net/ethernet/toshiba/tc35815.c b/drivers/net/ethernet/toshiba/tc35815.c
index 71b785c..4538908 100644
--- a/drivers/net/ethernet/toshiba/tc35815.c
+++ b/drivers/net/ethernet/toshiba/tc35815.c
@@ -673,7 +673,7 @@ static int tc_mii_init(struct net_device *dev)
 	int err;
 	int i;
 
-	lp->mii_bus = mdiobus_alloc();
+	lp->mii_bus = mdiobus_alloc(0);
 	if (lp->mii_bus == NULL) {
 		err = -ENOMEM;
 		goto err_out;
diff --git a/drivers/net/ethernet/xilinx/ll_temac_mdio.c b/drivers/net/ethernet/xilinx/ll_temac_mdio.c
index 8cf9d4f..7d0ebf5 100644
--- a/drivers/net/ethernet/xilinx/ll_temac_mdio.c
+++ b/drivers/net/ethernet/xilinx/ll_temac_mdio.c
@@ -81,7 +81,7 @@ int temac_mdio_setup(struct temac_local *lp, struct device_node *np)
 	temac_indirect_out32(lp, XTE_MC_OFFSET, 1 << 6 | clk_div);
 	mutex_unlock(&lp->indirect_mutex);
 
-	bus = mdiobus_alloc();
+	bus = mdiobus_alloc(0);
 	if (!bus)
 		return -ENOMEM;
 
diff --git a/drivers/net/ethernet/xilinx/xilinx_emaclite.c b/drivers/net/ethernet/xilinx/xilinx_emaclite.c
index dca6541..4ecd7ac 100644
--- a/drivers/net/ethernet/xilinx/xilinx_emaclite.c
+++ b/drivers/net/ethernet/xilinx/xilinx_emaclite.c
@@ -861,7 +861,7 @@ static int xemaclite_mdio_setup(struct net_local *lp, struct device *dev)
 	out_be32(lp->base_addr + XEL_MDIOCTRL_OFFSET,
 		 XEL_MDIOCTRL_MDIOEN_MASK);
 
-	bus = mdiobus_alloc();
+	bus = mdiobus_alloc(0);
 	if (!bus)
 		return -ENOMEM;
 
diff --git a/drivers/net/ethernet/xscale/ixp4xx_eth.c b/drivers/net/ethernet/xscale/ixp4xx_eth.c
index f45c85a..43b4892 100644
--- a/drivers/net/ethernet/xscale/ixp4xx_eth.c
+++ b/drivers/net/ethernet/xscale/ixp4xx_eth.c
@@ -509,7 +509,7 @@ static int ixp4xx_mdio_register(void)
 {
 	int err;
 
-	if (!(mdio_bus = mdiobus_alloc()))
+	if (!(mdio_bus = mdiobus_alloc(0)))
 		return -ENOMEM;
 
 	if (cpu_is_ixp43x()) {
diff --git a/drivers/net/phy/fixed.c b/drivers/net/phy/fixed.c
index 1fa4d73..18e838e 100644
--- a/drivers/net/phy/fixed.c
+++ b/drivers/net/phy/fixed.c
@@ -214,7 +214,7 @@ static int __init fixed_mdio_bus_init(void)
 		goto err_pdev;
 	}
 
-	fmb->mii_bus = mdiobus_alloc();
+	fmb->mii_bus = mdiobus_alloc(0);
 	if (fmb->mii_bus == NULL) {
 		ret = -ENOMEM;
 		goto err_mdiobus_reg;
diff --git a/drivers/net/phy/mdio-bitbang.c b/drivers/net/phy/mdio-bitbang.c
index daec9b0..097cf50 100644
--- a/drivers/net/phy/mdio-bitbang.c
+++ b/drivers/net/phy/mdio-bitbang.c
@@ -214,7 +214,7 @@ struct mii_bus *alloc_mdio_bitbang(struct mdiobb_ctrl *ctrl)
 {
 	struct mii_bus *bus;
 
-	bus = mdiobus_alloc();
+	bus = mdiobus_alloc(0);
 	if (!bus)
 		return NULL;
 
diff --git a/drivers/net/phy/mdio-octeon.c b/drivers/net/phy/mdio-octeon.c
index bd12ba9..4c68668 100644
--- a/drivers/net/phy/mdio-octeon.c
+++ b/drivers/net/phy/mdio-octeon.c
@@ -99,7 +99,7 @@ static int __devinit octeon_mdiobus_probe(struct platform_device *pdev)
 	/* The platform_device id is our unit number.  */
 	bus->unit = pdev->id;
 
-	bus->mii_bus = mdiobus_alloc();
+	bus->mii_bus = mdiobus_alloc(0);
 
 	if (!bus->mii_bus)
 		goto err;
diff --git a/drivers/net/phy/mdio_bus.c b/drivers/net/phy/mdio_bus.c
index 6c58da2..e6fd35d 100644
--- a/drivers/net/phy/mdio_bus.c
+++ b/drivers/net/phy/mdio_bus.c
@@ -41,14 +41,28 @@
  *
  * Description: called by a bus driver to allocate an mii_bus
  * structure to fill in.
+ *
+ * 'size' is an an extra amount of memory to allocate for private storage.
+ * If non-zero, then bus->priv is points to that memory.
  */
-struct mii_bus *mdiobus_alloc(void)
+struct mii_bus *mdiobus_alloc(size_t size)
 {
 	struct mii_bus *bus;
+	size_t aligned_size = ALIGN(sizeof(*bus), NETDEV_ALIGN);
+	size_t alloc_size;
+
+	/* If we alloc extra space, it should be aligned */
+	if (size)
+		alloc_size = aligned_size + size;
+	else
+		alloc_size = sizeof(*bus);
 
-	bus = kzalloc(sizeof(*bus), GFP_KERNEL);
-	if (bus != NULL)
+	bus = kzalloc(alloc_size, GFP_KERNEL);
+	if (bus) {
 		bus->state = MDIOBUS_ALLOCATED;
+		if (size)
+			bus->priv = (void *)bus + aligned_size;
+	}
 
 	return bus;
 }
diff --git a/drivers/staging/et131x/et131x.c b/drivers/staging/et131x/et131x.c
index 0c1c6ca..1f5a2f9 100644
--- a/drivers/staging/et131x/et131x.c
+++ b/drivers/staging/et131x/et131x.c
@@ -5396,7 +5396,7 @@ static int __devinit et131x_pci_setup(struct pci_dev *pdev,
 	et1310_disable_phy_coma(adapter);
 
 	/* Setup the mii_bus struct */
-	adapter->mii_bus = mdiobus_alloc();
+	adapter->mii_bus = mdiobus_alloc(0);
 	if (!adapter->mii_bus) {
 		dev_err(&pdev->dev, "Alloc of mii_bus struct failed\n");
 		goto err_mem_free;
diff --git a/include/linux/phy.h b/include/linux/phy.h
index 79f337c..603153f 100644
--- a/include/linux/phy.h
+++ b/include/linux/phy.h
@@ -129,7 +129,7 @@ struct mii_bus {
 };
 #define to_mii_bus(d) container_of(d, struct mii_bus, dev)
 
-struct mii_bus *mdiobus_alloc(void);
+struct mii_bus *mdiobus_alloc(size_t size);
 int mdiobus_register(struct mii_bus *bus);
 void mdiobus_unregister(struct mii_bus *bus);
 void mdiobus_free(struct mii_bus *bus);
diff --git a/net/dsa/dsa.c b/net/dsa/dsa.c
index 88e7c2f..dd0e270 100644
--- a/net/dsa/dsa.c
+++ b/net/dsa/dsa.c
@@ -154,7 +154,7 @@ dsa_switch_setup(struct dsa_switch_tree *dst, int index,
 	if (ret < 0)
 		goto out;
 
-	ds->slave_mii_bus = mdiobus_alloc();
+	ds->slave_mii_bus = mdiobus_alloc(0);
 	if (ds->slave_mii_bus == NULL) {
 		ret = -ENOMEM;
 		goto out;
-- 
1.7.3.4
