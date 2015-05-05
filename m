From: Michal Simek <michal.simek@xilinx.com>
Subject: [PATCH 08/12] net: axienet: Use pdev instead of op
Date: Tue,  5 May 2015 11:26:01 +0200
Message-ID: <ff9d5d134684d649072e1c95e0ddbfbfabc3afef.1430817941.git.michal.simek@xilinx.com>
References: <7fb84f65a61bbe0fdb4b61a871cf4d4f7910955d.1430817941.git.michal.simek@xilinx.com>
Cc: Srikanth Thokala <srikanth.thokala@xilinx.com>,
	=?UTF-8?q?S=C3=B6ren=20Brinkmann?= <soren.brinkmann@xilinx.com>,
	monstr@monstr.eu, John Linn <John.Linn@xilinx.com>,
	Anirudha Sarangi <anirudh@xilinx.com>,
	linux-kernel@vger.kernel.org, linux-arm-kernel@lists.infradead.org
To: netdev@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <7fb84f65a61bbe0fdb4b61a871cf4d4f7910955d.1430817941.git.michal.simek@xilinx.com>
In-Reply-To: <7fb84f65a61bbe0fdb4b61a871cf4d4f7910955d.1430817941.git.michal.simek@xilinx.com>
References: <7fb84f65a61bbe0fdb4b61a871cf4d4f7910955d.1430817941.git.michal.simek@xilinx.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Srikanth Thokala <srikanth.thokala@xilinx.com>

Synchronize names with other drivers

Signed-off-by: Srikanth Thokala <sthokal@xilinx.com>
Signed-off-by: Michal Simek <michal.simek@xilinx.com>
---

 drivers/net/ethernet/xilinx/xilinx_axienet_main.c | 47 ++++++++++++-----------
 1 file changed, 24 insertions(+), 23 deletions(-)

diff --git a/drivers/net/ethernet/xilinx/xilinx_axienet_main.c b/drivers/net/ethernet/xilinx/xilinx_axienet_main.c
index ddaa07a0bf51..757b2dc30cef 100644
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
@@ -1504,9 +1504,9 @@ static int axienet_of_probe(struct platform_device *op)
 	if (!ndev)
 		return -ENOMEM;
 
-	platform_set_drvdata(op, ndev);
+	platform_set_drvdata(pdev, ndev);
 
-	SET_NETDEV_DEV(ndev, &op->dev);
+	SET_NETDEV_DEV(ndev, &pdev->dev);
 	ndev->flags &= ~IFF_MULTICAST;  /* clear multicast */
 	ndev->features = NETIF_F_SG;
 	ndev->netdev_ops = &axienet_netdev_ops;
@@ -1514,19 +1514,19 @@ static int axienet_of_probe(struct platform_device *op)
 
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
 		ret = -ENOMEM;
 		goto nodev;
 	}
 	/* Setup checksum offload, but default to off if not specified */
 	lp->features = 0;
 
-	p = (__be32 *) of_get_property(op->dev.of_node, "xlnx,txcsum", NULL);
+	p = (__be32 *)of_get_property(pdev->dev.of_node, "xlnx,txcsum", NULL);
 	if (p) {
 		switch (be32_to_cpup(p)) {
 		case 1:
@@ -1547,7 +1547,7 @@ static int axienet_of_probe(struct platform_device *op)
 			lp->csum_offload_on_tx_path = XAE_NO_CSUM_OFFLOAD;
 		}
 	}
-	p = (__be32 *) of_get_property(op->dev.of_node, "xlnx,rxcsum", NULL);
+	p = (__be32 *)of_get_property(pdev->dev.of_node, "xlnx,rxcsum", NULL);
 	if (p) {
 		switch (be32_to_cpup(p)) {
 		case 1:
@@ -1570,40 +1570,41 @@ static int axienet_of_probe(struct platform_device *op)
 	 * Here we check for memory allocated for Rx/Tx in the hardware from
 	 * the device-tree and accordingly set flags.
 	 */
-	p = (__be32 *) of_get_property(op->dev.of_node, "xlnx,rxmem", NULL);
+	p = (__be32 *)of_get_property(pdev->dev.of_node, "xlnx,rxmem", NULL);
 	if (p)
 		lp->rxmem = be32_to_cpup(p);
-	p = (__be32 *) of_get_property(op->dev.of_node, "xlnx,phy-type", NULL);
+	p = (__be32 *)of_get_property(pdev->dev.of_node,
+				      "xlnx,phy-type", NULL);
 	if (p)
 		lp->phy_type = be32_to_cpup(p);
 
 	/* Find the DMA node, map the DMA registers, and decode the DMA IRQs */
-	np = of_parse_phandle(op->dev.of_node, "axistream-connected", 0);
+	np = of_parse_phandle(pdev->dev.of_node, "axistream-connected", 0);
 	if (!np) {
-		dev_err(&op->dev, "could not find DMA node\n");
+		dev_err(&pdev->dev, "could not find DMA node\n");
 		ret = -ENODEV;
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
@@ -1612,11 +1613,11 @@ static int axienet_of_probe(struct platform_device *op)
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
@@ -1637,9 +1638,9 @@ nodev:
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
2.3.5
