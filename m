From: Michal Simek <michal.simek@xilinx.com>
Subject: [PATCH 10/14] net: axienet: Use pdev instead of op
Date: Wed, 12 Feb 2014 16:55:44 +0100
Message-ID: <99e22ae9202079e1c71815766a8b3f53ed464a29.1392220536.git.michal.simek@xilinx.com>
References: <cover.1392220536.git.michal.simek@xilinx.com>
Content-Type: multipart/signed;
    boundary="=_mimegpg-monstr-desktop-2315-1392220625-0001";
    micalg=pgp-sha1; protocol="application/pgp-signature"
Cc: Srikanth Thokala <sthokal@xilinx.com>,
	Srikanth Thokala <srikanth.thokala@xilinx.com>,
	Michal Simek <monstr@monstr.eu>,
	Anirudha Sarangi <anirudh@xilinx.com>,
	John Linn <John.Linn@xilinx.com>,
	Grant Likely <grant.likely@linaro.org>,
	Rob Herring <robh+dt@kernel.org>,
	linux-arm-kernel@lists.infradead.org, linux-kernel@vger.kernel.org,
	devicetree@vger.kernel.org
To: netdev@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <cover.1392220536.git.michal.simek@xilinx.com>
In-Reply-To: <cover.1392220536.git.michal.simek@xilinx.com>
References: <cover.1392220536.git.michal.simek@xilinx.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This is a MIME GnuPG-signed message.  If you see this text, it means that
your E-mail or Usenet software does not support MIME signed messages.
The Internet standard for MIME PGP messages, RFC 2015, was published in 1996.
To open this message correctly you will need to install E-mail or Usenet
software that supports modern Internet standards.

--=_mimegpg-monstr-desktop-2315-1392220625-0001

From: Srikanth Thokala <srikanth.thokala@xilinx.com>

Synchronize names with other drivers

Signed-off-by: Srikanth Thokala <sthokal@xilinx.com>
Signed-off-by: Michal Simek <michal.simek@xilinx.com>
---

 drivers/net/ethernet/xilinx/xilinx_axienet_main.c | 49 ++++++++++++-----------
 1 file changed, 25 insertions(+), 24 deletions(-)

diff --git a/drivers/net/ethernet/xilinx/xilinx_axienet_main.c b/drivers/net/ethernet/xilinx/xilinx_axienet_main.c
index 4fd8a1d..324033c 100644
--- a/drivers/net/ethernet/xilinx/xilinx_axienet_main.c
+++ b/drivers/net/ethernet/xilinx/xilinx_axienet_main.c
@@ -1480,7 +1480,7 @@ static void axienet_dma_err_handler(unsigned long data)

 /**
  * axienet_of_probe - Axi Ethernet probe function.
- * @op:		Pointer to platform device structure.
+ * @pdev:	Pointer to platform device structure.
  * @match:	Pointer to device id structure
  *
  * returns: 0, on success
@@ -1491,7 +1491,7 @@ static void axienet_dma_err_handler(unsigned long data)
  * device. Parses through device tree and populates fields of
  * axienet_local. It registers the Ethernet device.
  */
-static int axienet_of_probe(struct platform_device *op)
+static int axienet_of_probe(struct platform_device *pdev)
 {
 	__be32 *p;
 	int size, ret = 0;
@@ -1505,9 +1505,9 @@ static int axienet_of_probe(struct platform_device *op)
 		return -ENOMEM;

 	ether_setup(ndev);
-	platform_set_drvdata(op, ndev);
+	platform_set_drvdata(pdev, ndev);

-	SET_NETDEV_DEV(ndev, &op->dev);
+	SET_NETDEV_DEV(ndev, &pdev->dev);
 	ndev->flags &= ~IFF_MULTICAST;  /* clear multicast */
 	ndev->features = NETIF_F_SG;
 	ndev->netdev_ops = &axienet_netdev_ops;
@@ -1515,18 +1515,18 @@ static int axienet_of_probe(struct platform_device *op)

 	lp = netdev_priv(ndev);
 	lp->ndev = ndev;
-	lp->dev = &op->dev;
+	lp->dev = &pdev->dev;
 	lp->options = XAE_OPTION_DEFAULTS;
 	/* Map device registers */
-	lp->regs = of_iomap(op->dev.of_node, 0);
+	lp->regs = of_iomap(pdev->dev.of_node, 0);
 	if (!lp->regs) {
-		dev_err(&op->dev, "could not map Axi Ethernet regs.\n");
+		dev_err(&pdev->dev, "could not map Axi Ethernet regs.\n");
 		goto nodev;
 	}
 	/* Setup checksum offload, but default to off if not specified */
 	lp->features = 0;

-	p = (__be32 *) of_get_property(op->dev.of_node, "xlnx,txcsum", NULL);
+	p = (__be32 *) of_get_property(pdev->dev.of_node, "xlnx,txcsum", NULL);
 	if (p) {
 		switch (be32_to_cpup(p)) {
 		case 1:
@@ -1547,7 +1547,7 @@ static int axienet_of_probe(struct platform_device *op)
 			lp->csum_offload_on_tx_path = XAE_NO_CSUM_OFFLOAD;
 		}
 	}
-	p = (__be32 *) of_get_property(op->dev.of_node, "xlnx,rxcsum", NULL);
+	p = (__be32 *) of_get_property(pdev->dev.of_node, "xlnx,rxcsum", NULL);
 	if (p) {
 		switch (be32_to_cpup(p)) {
 		case 1:
@@ -1570,43 +1570,44 @@ static int axienet_of_probe(struct platform_device *op)
 	 * Here we check for memory allocated for Rx/Tx in the hardware from
 	 * the device-tree and accordingly set flags.
 	 */
-	p = (__be32 *) of_get_property(op->dev.of_node, "xlnx,rxmem", NULL);
+	p = (__be32 *) of_get_property(pdev->dev.of_node, "xlnx,rxmem", NULL);
 	if (p)
 		lp->rxmem = be32_to_cpup(p);
-	p = (__be32 *) of_get_property(op->dev.of_node, "xlnx,temac-type",
+	p = (__be32 *) of_get_property(pdev->dev.of_node, "xlnx,temac-type",
 				       NULL);
 	if (p)
 		lp->temac_type = be32_to_cpup(p);
-	p = (__be32 *) of_get_property(op->dev.of_node, "xlnx,phy-type", NULL);
+	p = (__be32 *) of_get_property(pdev->dev.of_node,
+						"xlnx,phy-type", NULL);
 	if (p)
 		lp->phy_type = be32_to_cpup(p);

 	/* Find the DMA node, map the DMA registers, and decode the DMA IRQs */
-	np = of_parse_phandle(op->dev.of_node, "axistream-connected", 0);
+	np = of_parse_phandle(pdev->dev.of_node, "axistream-connected", 0);
 	if (!np) {
-		dev_err(&op->dev, "could not find DMA node\n");
+		dev_err(&pdev->dev, "could not find DMA node\n");
 		goto err_iounmap;
 	}
 	lp->dma_regs = of_iomap(np, 0);
 	if (lp->dma_regs) {
-		dev_dbg(&op->dev, "MEM base: %p\n", lp->dma_regs);
+		dev_dbg(&pdev->dev, "MEM base: %p\n", lp->dma_regs);
 	} else {
-		dev_err(&op->dev, "unable to map DMA registers\n");
+		dev_err(&pdev->dev, "unable to map DMA registers\n");
 		of_node_put(np);
 	}
 	lp->rx_irq = irq_of_parse_and_map(np, 1);
 	lp->tx_irq = irq_of_parse_and_map(np, 0);
 	of_node_put(np);
 	if ((lp->rx_irq <= 0) || (lp->tx_irq <= 0)) {
-		dev_err(&op->dev, "could not determine irqs\n");
+		dev_err(&pdev->dev, "could not determine irqs\n");
 		ret = -ENOMEM;
 		goto err_iounmap_2;
 	}

 	/* Retrieve the MAC address */
-	addr = of_get_property(op->dev.of_node, "local-mac-address", &size);
+	addr = of_get_property(pdev->dev.of_node, "local-mac-address", &size);
 	if ((!addr) || (size != 6)) {
-		dev_err(&op->dev, "could not find MAC address\n");
+		dev_err(&pdev->dev, "could not find MAC address\n");
 		ret = -ENODEV;
 		goto err_iounmap_2;
 	}
@@ -1615,11 +1616,11 @@ static int axienet_of_probe(struct platform_device *op)
 	lp->coalesce_count_rx = XAXIDMA_DFT_RX_THRESHOLD;
 	lp->coalesce_count_tx = XAXIDMA_DFT_TX_THRESHOLD;

-	lp->phy_node = of_parse_phandle(op->dev.of_node, "phy-handle", 0);
+	lp->phy_node = of_parse_phandle(pdev->dev.of_node, "phy-handle", 0);
 	if (lp->phy_node)
-		ret = axienet_mdio_setup(lp, op->dev.of_node);
+		ret = axienet_mdio_setup(lp, pdev->dev.of_node);
 	if (ret)
-		dev_warn(&op->dev, "error registering MDIO bus\n");
+		dev_warn(&pdev->dev, "error registering MDIO bus\n");

 	ret = register_netdev(lp->ndev);
 	if (ret) {
@@ -1640,9 +1641,9 @@ nodev:
 	return ret;
 }

-static int axienet_of_remove(struct platform_device *op)
+static int axienet_of_remove(struct platform_device *pdev)
 {
-	struct net_device *ndev = platform_get_drvdata(op);
+	struct net_device *ndev = platform_get_drvdata(pdev);
 	struct axienet_local *lp = netdev_priv(ndev);

 	axienet_mdio_teardown(lp);
--
1.8.2.3


--=_mimegpg-monstr-desktop-2315-1392220625-0001
Content-Type: application/pgp-signature
Content-Transfer-Encoding: 7bit

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.10 (GNU/Linux)

iEYEABECAAYFAlL7mdEACgkQykllyylKDCHDwQCfbWJQM1RRBIZcoiIl1Mc4gXKp
m/kAn2IhsbUcUoHQYvxioLRx3reI4/kT
=akZh
-----END PGP SIGNATURE-----

--=_mimegpg-monstr-desktop-2315-1392220625-0001--
