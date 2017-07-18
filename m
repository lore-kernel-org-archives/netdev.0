From: Rob Herring <robh@kernel.org>
Subject: [PATCH] net: Convert to using %pOF instead of full_name
Date: Tue, 18 Jul 2017 16:43:19 -0500
Message-ID: <20170718214339.7774-39-robh@kernel.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 8bit
Cc: linux-kernel@vger.kernel.org, devicetree@vger.kernel.org,
        Andrew Lunn <andrew@lunn.ch>,
        Vivien Didelot <vivien.didelot@savoirfairelinux.com>,
        Florian Fainelli <f.fainelli@gmail.com>,
        Madalin Bucur <madalin.bucur@nxp.com>,
        Douglas Miller <dougmill@linux.vnet.ibm.com>,
        Grygorii Strashko <grygorii.strashko@ti.com>,
        Michal Simek <michal.simek@xilinx.com>,
        =?UTF-8?q?S=C3=B6ren=20Brinkmann?= <soren.brinkmann@xilinx.com>,
        netdev@vger.kernel.org, linux-omap@vger.kernel.org,
        linux-arm-kernel@lists.infradead.org
To: "David S . Miller" <davem@davemloft.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Now that we have a custom printf format specifier, convert users of
full_name to use %pOF instead. This is preparation to remove storing
of the full path string for each node.

Signed-off-by: Rob Herring <robh@kernel.org>
Cc: Andrew Lunn <andrew@lunn.ch>
Cc: Vivien Didelot <vivien.didelot@savoirfairelinux.com>
Cc: Florian Fainelli <f.fainelli@gmail.com>
Cc: Madalin Bucur <madalin.bucur@nxp.com>
Cc: Douglas Miller <dougmill@linux.vnet.ibm.com>
Cc: Grygorii Strashko <grygorii.strashko@ti.com>
Cc: Michal Simek <michal.simek@xilinx.com>
Cc: "Sören Brinkmann" <soren.brinkmann@xilinx.com>
Cc: netdev@vger.kernel.org
Cc: linux-omap@vger.kernel.org
Cc: linux-arm-kernel@lists.infradead.org
---
 drivers/net/dsa/mv88e6xxx/chip.c                |  2 +-
 drivers/net/ethernet/apple/mace.c               |  8 ++--
 drivers/net/ethernet/freescale/dpaa/dpaa_eth.c  |  4 +-
 drivers/net/ethernet/freescale/fec_mpc52xx.c    |  4 +-
 drivers/net/ethernet/freescale/fman/fman.c      | 12 +++---
 drivers/net/ethernet/freescale/fman/fman_port.c |  4 +-
 drivers/net/ethernet/freescale/fman/mac.c       | 50 +++++++++++------------
 drivers/net/ethernet/freescale/fsl_pq_mdio.c    | 20 +++++-----
 drivers/net/ethernet/ibm/ehea/ehea_main.c       |  5 +--
 drivers/net/ethernet/ibm/emac/core.c            | 53 +++++++++++--------------
 drivers/net/ethernet/ibm/emac/debug.h           |  2 +-
 drivers/net/ethernet/ibm/emac/mal.c             |  8 ++--
 drivers/net/ethernet/ibm/emac/rgmii.c           | 18 ++++-----
 drivers/net/ethernet/ibm/emac/tah.c             | 12 ++----
 drivers/net/ethernet/ibm/emac/zmii.c            | 17 ++++----
 drivers/net/ethernet/sun/niu.c                  | 24 +++++------
 drivers/net/ethernet/ti/cpsw.c                  |  8 ++--
 drivers/net/ethernet/ti/davinci_emac.c          |  4 +-
 drivers/net/ethernet/xilinx/ll_temac_main.c     |  2 +-
 drivers/net/phy/mdio-mux-mmioreg.c              | 18 ++++-----
 drivers/net/phy/mdio-mux.c                      | 16 ++++----
 21 files changed, 134 insertions(+), 157 deletions(-)

diff --git a/drivers/net/dsa/mv88e6xxx/chip.c b/drivers/net/dsa/mv88e6xxx/chip.c
index 53b088166c28..f7f6526baedb 100644
--- a/drivers/net/dsa/mv88e6xxx/chip.c
+++ b/drivers/net/dsa/mv88e6xxx/chip.c
@@ -2236,7 +2236,7 @@ static int mv88e6xxx_mdio_register(struct mv88e6xxx_chip *chip,

 	if (np) {
 		bus->name = np->full_name;
-		snprintf(bus->id, MII_BUS_ID_SIZE, "%s", np->full_name);
+		snprintf(bus->id, MII_BUS_ID_SIZE, "%pOF", np);
 	} else {
 		bus->name = "mv88e6xxx SMI";
 		snprintf(bus->id, MII_BUS_ID_SIZE, "mv88e6xxx-%d", index++);
diff --git a/drivers/net/ethernet/apple/mace.c b/drivers/net/ethernet/apple/mace.c
index 96dd5300e0e5..e58b157b7d7c 100644
--- a/drivers/net/ethernet/apple/mace.c
+++ b/drivers/net/ethernet/apple/mace.c
@@ -114,8 +114,8 @@ static int mace_probe(struct macio_dev *mdev, const struct of_device_id *match)
 	int j, rev, rc = -EBUSY;

 	if (macio_resource_count(mdev) != 3 || macio_irq_count(mdev) != 3) {
-		printk(KERN_ERR "can't use MACE %s: need 3 addrs and 3 irqs\n",
-		       mace->full_name);
+		printk(KERN_ERR "can't use MACE %pOF: need 3 addrs and 3 irqs\n",
+		       mace);
 		return -ENODEV;
 	}

@@ -123,8 +123,8 @@ static int mace_probe(struct macio_dev *mdev, const struct of_device_id *match)
 	if (addr == NULL) {
 		addr = of_get_property(mace, "local-mac-address", NULL);
 		if (addr == NULL) {
-			printk(KERN_ERR "Can't get mac-address for MACE %s\n",
-			       mace->full_name);
+			printk(KERN_ERR "Can't get mac-address for MACE %pOF\n",
+			       mace);
 			return -ENODEV;
 		}
 	}
diff --git a/drivers/net/ethernet/freescale/dpaa/dpaa_eth.c b/drivers/net/ethernet/freescale/dpaa/dpaa_eth.c
index 757b873735a5..550ea1ec7b6c 100644
--- a/drivers/net/ethernet/freescale/dpaa/dpaa_eth.c
+++ b/drivers/net/ethernet/freescale/dpaa/dpaa_eth.c
@@ -398,8 +398,8 @@ static struct mac_device *dpaa_mac_dev_get(struct platform_device *pdev)

 	of_dev = of_find_device_by_node(mac_node);
 	if (!of_dev) {
-		dev_err(dpaa_dev, "of_find_device_by_node(%s) failed\n",
-			mac_node->full_name);
+		dev_err(dpaa_dev, "of_find_device_by_node(%pOF) failed\n",
+			mac_node);
 		of_node_put(mac_node);
 		return ERR_PTR(-EINVAL);
 	}
diff --git a/drivers/net/ethernet/freescale/fec_mpc52xx.c b/drivers/net/ethernet/freescale/fec_mpc52xx.c
index aa8cf5d2a53c..6d7269d87a85 100644
--- a/drivers/net/ethernet/freescale/fec_mpc52xx.c
+++ b/drivers/net/ethernet/freescale/fec_mpc52xx.c
@@ -960,8 +960,8 @@ static int mpc52xx_fec_probe(struct platform_device *op)

 	/* We're done ! */
 	platform_set_drvdata(op, ndev);
-	netdev_info(ndev, "%s MAC %pM\n",
-		    op->dev.of_node->full_name, ndev->dev_addr);
+	netdev_info(ndev, "%pOF MAC %pM\n",
+		    op->dev.of_node, ndev->dev_addr);

 	return 0;

diff --git a/drivers/net/ethernet/freescale/fman/fman.c b/drivers/net/ethernet/freescale/fman/fman.c
index 4aefe2438969..e714b8fa55eb 100644
--- a/drivers/net/ethernet/freescale/fman/fman.c
+++ b/drivers/net/ethernet/freescale/fman/fman.c
@@ -1925,8 +1925,8 @@ static int fman_reset(struct fman *fman)

 		guts_regs = of_iomap(guts_node, 0);
 		if (!guts_regs) {
-			dev_err(fman->dev, "%s: Couldn't map %s regs\n",
-				__func__, guts_node->full_name);
+			dev_err(fman->dev, "%s: Couldn't map %pOF regs\n",
+				__func__, guts_node);
 			goto guts_regs;
 		}
 #define FMAN1_ALL_MACS_MASK	0xFCC00000
@@ -2780,8 +2780,8 @@ static struct fman *read_dts_node(struct platform_device *of_dev)

 	err = of_property_read_u32(fm_node, "cell-index", &val);
 	if (err) {
-		dev_err(&of_dev->dev, "%s: failed to read cell-index for %s\n",
-			__func__, fm_node->full_name);
+		dev_err(&of_dev->dev, "%s: failed to read cell-index for %pOF\n",
+			__func__, fm_node);
 		goto fman_node_put;
 	}
 	fman->dts_params.id = (u8)val;
@@ -2834,8 +2834,8 @@ static struct fman *read_dts_node(struct platform_device *of_dev)
 	err = of_property_read_u32_array(fm_node, "fsl,qman-channel-range",
 					 &range[0], 2);
 	if (err) {
-		dev_err(&of_dev->dev, "%s: failed to read fsl,qman-channel-range for %s\n",
-			__func__, fm_node->full_name);
+		dev_err(&of_dev->dev, "%s: failed to read fsl,qman-channel-range for %pOF\n",
+			__func__, fm_node);
 		goto fman_node_put;
 	}
 	fman->dts_params.qman_channel_base = range[0];
diff --git a/drivers/net/ethernet/freescale/fman/fman_port.c b/drivers/net/ethernet/freescale/fman/fman_port.c
index 57bf44fa16a1..49bfa11f2d20 100644
--- a/drivers/net/ethernet/freescale/fman/fman_port.c
+++ b/drivers/net/ethernet/freescale/fman/fman_port.c
@@ -1720,8 +1720,8 @@ static int fman_port_probe(struct platform_device *of_dev)

 	err = of_property_read_u32(port_node, "cell-index", &val);
 	if (err) {
-		dev_err(port->dev, "%s: reading cell-index for %s failed\n",
-			__func__, port_node->full_name);
+		dev_err(port->dev, "%s: reading cell-index for %pOF failed\n",
+			__func__, port_node);
 		err = -EINVAL;
 		goto return_err;
 	}
diff --git a/drivers/net/ethernet/freescale/fman/mac.c b/drivers/net/ethernet/freescale/fman/mac.c
index 6e67d22fd0d5..14cd2c8b0024 100644
--- a/drivers/net/ethernet/freescale/fman/mac.c
+++ b/drivers/net/ethernet/freescale/fman/mac.c
@@ -698,8 +698,8 @@ static int mac_probe(struct platform_device *_of_dev)
 		priv->internal_phy_node = of_parse_phandle(mac_node,
 							  "pcsphy-handle", 0);
 	} else {
-		dev_err(dev, "MAC node (%s) contains unsupported MAC\n",
-			mac_node->full_name);
+		dev_err(dev, "MAC node (%pOF) contains unsupported MAC\n",
+			mac_node);
 		err = -EINVAL;
 		goto _return;
 	}
@@ -712,16 +712,15 @@ static int mac_probe(struct platform_device *_of_dev)
 	/* Get the FM node */
 	dev_node = of_get_parent(mac_node);
 	if (!dev_node) {
-		dev_err(dev, "of_get_parent(%s) failed\n",
-			mac_node->full_name);
+		dev_err(dev, "of_get_parent(%pOF) failed\n",
+			mac_node);
 		err = -EINVAL;
 		goto _return_dev_set_drvdata;
 	}

 	of_dev = of_find_device_by_node(dev_node);
 	if (!of_dev) {
-		dev_err(dev, "of_find_device_by_node(%s) failed\n",
-			dev_node->full_name);
+		dev_err(dev, "of_find_device_by_node(%pOF) failed\n", dev_node);
 		err = -EINVAL;
 		goto _return_of_node_put;
 	}
@@ -729,8 +728,7 @@ static int mac_probe(struct platform_device *_of_dev)
 	/* Get the FMan cell-index */
 	err = of_property_read_u32(dev_node, "cell-index", &val);
 	if (err) {
-		dev_err(dev, "failed to read cell-index for %s\n",
-			dev_node->full_name);
+		dev_err(dev, "failed to read cell-index for %pOF\n", dev_node);
 		err = -EINVAL;
 		goto _return_of_node_put;
 	}
@@ -739,7 +737,7 @@ static int mac_probe(struct platform_device *_of_dev)

 	priv->fman = fman_bind(&of_dev->dev);
 	if (!priv->fman) {
-		dev_err(dev, "fman_bind(%s) failed\n", dev_node->full_name);
+		dev_err(dev, "fman_bind(%pOF) failed\n", dev_node);
 		err = -ENODEV;
 		goto _return_of_node_put;
 	}
@@ -749,8 +747,8 @@ static int mac_probe(struct platform_device *_of_dev)
 	/* Get the address of the memory mapped registers */
 	err = of_address_to_resource(mac_node, 0, &res);
 	if (err < 0) {
-		dev_err(dev, "of_address_to_resource(%s) = %d\n",
-			mac_node->full_name, err);
+		dev_err(dev, "of_address_to_resource(%pOF) = %d\n",
+			mac_node, err);
 		goto _return_dev_set_drvdata;
 	}

@@ -784,8 +782,7 @@ static int mac_probe(struct platform_device *_of_dev)
 	/* Get the cell-index */
 	err = of_property_read_u32(mac_node, "cell-index", &val);
 	if (err) {
-		dev_err(dev, "failed to read cell-index for %s\n",
-			mac_node->full_name);
+		dev_err(dev, "failed to read cell-index for %pOF\n", mac_node);
 		err = -EINVAL;
 		goto _return_dev_set_drvdata;
 	}
@@ -794,8 +791,7 @@ static int mac_probe(struct platform_device *_of_dev)
 	/* Get the MAC address */
 	mac_addr = of_get_mac_address(mac_node);
 	if (!mac_addr) {
-		dev_err(dev, "of_get_mac_address(%s) failed\n",
-			mac_node->full_name);
+		dev_err(dev, "of_get_mac_address(%pOF) failed\n", mac_node);
 		err = -EINVAL;
 		goto _return_dev_set_drvdata;
 	}
@@ -804,15 +800,15 @@ static int mac_probe(struct platform_device *_of_dev)
 	/* Get the port handles */
 	nph = of_count_phandle_with_args(mac_node, "fsl,fman-ports", NULL);
 	if (unlikely(nph < 0)) {
-		dev_err(dev, "of_count_phandle_with_args(%s, fsl,fman-ports) failed\n",
-			mac_node->full_name);
+		dev_err(dev, "of_count_phandle_with_args(%pOF, fsl,fman-ports) failed\n",
+			mac_node);
 		err = nph;
 		goto _return_dev_set_drvdata;
 	}

 	if (nph != ARRAY_SIZE(mac_dev->port)) {
-		dev_err(dev, "Not supported number of fman-ports handles of mac node %s from device tree\n",
-			mac_node->full_name);
+		dev_err(dev, "Not supported number of fman-ports handles of mac node %pOF from device tree\n",
+			mac_node);
 		err = -EINVAL;
 		goto _return_dev_set_drvdata;
 	}
@@ -821,24 +817,24 @@ static int mac_probe(struct platform_device *_of_dev)
 		/* Find the port node */
 		dev_node = of_parse_phandle(mac_node, "fsl,fman-ports", i);
 		if (!dev_node) {
-			dev_err(dev, "of_parse_phandle(%s, fsl,fman-ports) failed\n",
-				mac_node->full_name);
+			dev_err(dev, "of_parse_phandle(%pOF, fsl,fman-ports) failed\n",
+				mac_node);
 			err = -EINVAL;
 			goto _return_of_node_put;
 		}

 		of_dev = of_find_device_by_node(dev_node);
 		if (!of_dev) {
-			dev_err(dev, "of_find_device_by_node(%s) failed\n",
-				dev_node->full_name);
+			dev_err(dev, "of_find_device_by_node(%pOF) failed\n",
+				dev_node);
 			err = -EINVAL;
 			goto _return_of_node_put;
 		}

 		mac_dev->port[i] = fman_port_bind(&of_dev->dev);
 		if (!mac_dev->port[i]) {
-			dev_err(dev, "dev_get_drvdata(%s) failed\n",
-				dev_node->full_name);
+			dev_err(dev, "dev_get_drvdata(%pOF) failed\n",
+				dev_node);
 			err = -EINVAL;
 			goto _return_of_node_put;
 		}
@@ -849,8 +845,8 @@ static int mac_probe(struct platform_device *_of_dev)
 	phy_if = of_get_phy_mode(mac_node);
 	if (phy_if < 0) {
 		dev_warn(dev,
-			 "of_get_phy_mode() for %s failed. Defaulting to SGMII\n",
-			 mac_node->full_name);
+			 "of_get_phy_mode() for %pOF failed. Defaulting to SGMII\n",
+			 mac_node);
 		phy_if = PHY_INTERFACE_MODE_SGMII;
 	}
 	priv->phy_if = phy_if;
diff --git a/drivers/net/ethernet/freescale/fsl_pq_mdio.c b/drivers/net/ethernet/freescale/fsl_pq_mdio.c
index a10de1e9c157..80ad16acf0f1 100644
--- a/drivers/net/ethernet/freescale/fsl_pq_mdio.c
+++ b/drivers/net/ethernet/freescale/fsl_pq_mdio.c
@@ -267,8 +267,8 @@ static void ucc_configure(phys_addr_t start, phys_addr_t end)

 		ret = of_address_to_resource(np, 0, &res);
 		if (ret < 0) {
-			pr_debug("fsl-pq-mdio: no address range in node %s\n",
-				 np->full_name);
+			pr_debug("fsl-pq-mdio: no address range in node %pOF\n",
+				 np);
 			continue;
 		}

@@ -280,8 +280,8 @@ static void ucc_configure(phys_addr_t start, phys_addr_t end)
 		if (!iprop) {
 			iprop = of_get_property(np, "device-id", NULL);
 			if (!iprop) {
-				pr_debug("fsl-pq-mdio: no UCC ID in node %s\n",
-					 np->full_name);
+				pr_debug("fsl-pq-mdio: no UCC ID in node %pOF\n",
+					 np);
 				continue;
 			}
 		}
@@ -293,8 +293,8 @@ static void ucc_configure(phys_addr_t start, phys_addr_t end)
 		 * numbered from 1, not 0.
 		 */
 		if (ucc_set_qe_mux_mii_mng(id - 1) < 0) {
-			pr_debug("fsl-pq-mdio: invalid UCC ID in node %s\n",
-				 np->full_name);
+			pr_debug("fsl-pq-mdio: invalid UCC ID in node %pOF\n",
+				 np);
 			continue;
 		}

@@ -442,8 +442,8 @@ static int fsl_pq_mdio_probe(struct platform_device *pdev)
 	if (data->get_tbipa) {
 		for_each_child_of_node(np, tbi) {
 			if (strcmp(tbi->type, "tbi-phy") == 0) {
-				dev_dbg(&pdev->dev, "found TBI PHY node %s\n",
-					strrchr(tbi->full_name, '/') + 1);
+				dev_dbg(&pdev->dev, "found TBI PHY node %pOFP\n",
+					tbi);
 				break;
 			}
 		}
@@ -454,8 +454,8 @@ static int fsl_pq_mdio_probe(struct platform_device *pdev)

 			if (!prop) {
 				dev_err(&pdev->dev,
-					"missing 'reg' property in node %s\n",
-					tbi->full_name);
+					"missing 'reg' property in node %pOF\n",
+					tbi);
 				err = -EBUSY;
 				goto error;
 			}
diff --git a/drivers/net/ethernet/ibm/ehea/ehea_main.c b/drivers/net/ethernet/ibm/ehea/ehea_main.c
index b9d310f20bcc..4878b7169e0f 100644
--- a/drivers/net/ethernet/ibm/ehea/ehea_main.c
+++ b/drivers/net/ethernet/ibm/ehea/ehea_main.c
@@ -3102,8 +3102,7 @@ static int ehea_setup_ports(struct ehea_adapter *adapter)
 		dn_log_port_id = of_get_property(eth_dn, "ibm,hea-port-no",
 						 NULL);
 		if (!dn_log_port_id) {
-			pr_err("bad device node: eth_dn name=%s\n",
-			       eth_dn->full_name);
+			pr_err("bad device node: eth_dn name=%pOF\n", eth_dn);
 			continue;
 		}

@@ -3425,7 +3424,7 @@ static int ehea_probe_adapter(struct platform_device *dev)

 	if (!adapter->handle) {
 		dev_err(&dev->dev, "failed getting handle for adapter"
-			" '%s'\n", dev->dev.of_node->full_name);
+			" '%pOF'\n", dev->dev.of_node);
 		ret = -ENODEV;
 		goto out_free_ad;
 	}
diff --git a/drivers/net/ethernet/ibm/emac/core.c b/drivers/net/ethernet/ibm/emac/core.c
index 259e69a52ec5..95135d20458f 100644
--- a/drivers/net/ethernet/ibm/emac/core.c
+++ b/drivers/net/ethernet/ibm/emac/core.c
@@ -133,8 +133,7 @@ static inline void emac_report_timeout_error(struct emac_instance *dev,
 				  EMAC_FTR_440EP_PHY_CLK_FIX))
 		DBG(dev, "%s" NL, error);
 	else if (net_ratelimit())
-		printk(KERN_ERR "%s: %s\n", dev->ofdev->dev.of_node->full_name,
-			error);
+		printk(KERN_ERR "%pOF: %s\n", dev->ofdev->dev.of_node, error);
 }

 /* EMAC PHY clock workaround:
@@ -2258,8 +2257,8 @@ static void emac_ethtool_get_drvinfo(struct net_device *ndev,

 	strlcpy(info->driver, "ibm_emac", sizeof(info->driver));
 	strlcpy(info->version, DRV_VERSION, sizeof(info->version));
-	snprintf(info->bus_info, sizeof(info->bus_info), "PPC 4xx EMAC-%d %s",
-		 dev->cell_index, dev->ofdev->dev.of_node->full_name);
+	snprintf(info->bus_info, sizeof(info->bus_info), "PPC 4xx EMAC-%d %pOF",
+		 dev->cell_index, dev->ofdev->dev.of_node);
 }

 static const struct ethtool_ops emac_ethtool_ops = {
@@ -2431,8 +2430,8 @@ static int emac_read_uint_prop(struct device_node *np, const char *name,
 	const u32 *prop = of_get_property(np, name, &len);
 	if (prop == NULL || len < sizeof(u32)) {
 		if (fatal)
-			printk(KERN_ERR "%s: missing %s property\n",
-			       np->full_name, name);
+			printk(KERN_ERR "%pOF: missing %s property\n",
+			       np, name);
 		return -ENODEV;
 	}
 	*val = *prop;
@@ -2768,7 +2767,7 @@ static int emac_init_phy(struct emac_instance *dev)
 #endif
 	mutex_unlock(&emac_phy_map_lock);
 	if (i == 0x20) {
-		printk(KERN_WARNING "%s: can't find PHY!\n", np->full_name);
+		printk(KERN_WARNING "%pOF: can't find PHY!\n", np);
 		return -ENXIO;
 	}

@@ -2894,8 +2893,8 @@ static int emac_init_config(struct emac_instance *dev)
 #ifdef CONFIG_IBM_EMAC_NO_FLOW_CTRL
 			dev->features |= EMAC_FTR_NO_FLOW_CONTROL_40x;
 #else
-			printk(KERN_ERR "%s: Flow control not disabled!\n",
-					np->full_name);
+			printk(KERN_ERR "%pOF: Flow control not disabled!\n",
+					np);
 			return -ENXIO;
 #endif
 		}
@@ -2918,8 +2917,7 @@ static int emac_init_config(struct emac_instance *dev)
 #ifdef CONFIG_IBM_EMAC_TAH
 		dev->features |= EMAC_FTR_HAS_TAH;
 #else
-		printk(KERN_ERR "%s: TAH support not enabled !\n",
-		       np->full_name);
+		printk(KERN_ERR "%pOF: TAH support not enabled !\n", np);
 		return -ENXIO;
 #endif
 	}
@@ -2928,8 +2926,7 @@ static int emac_init_config(struct emac_instance *dev)
 #ifdef CONFIG_IBM_EMAC_ZMII
 		dev->features |= EMAC_FTR_HAS_ZMII;
 #else
-		printk(KERN_ERR "%s: ZMII support not enabled !\n",
-		       np->full_name);
+		printk(KERN_ERR "%pOF: ZMII support not enabled !\n", np);
 		return -ENXIO;
 #endif
 	}
@@ -2938,8 +2935,7 @@ static int emac_init_config(struct emac_instance *dev)
 #ifdef CONFIG_IBM_EMAC_RGMII
 		dev->features |= EMAC_FTR_HAS_RGMII;
 #else
-		printk(KERN_ERR "%s: RGMII support not enabled !\n",
-		       np->full_name);
+		printk(KERN_ERR "%pOF: RGMII support not enabled !\n", np);
 		return -ENXIO;
 #endif
 	}
@@ -2947,8 +2943,8 @@ static int emac_init_config(struct emac_instance *dev)
 	/* Read MAC-address */
 	p = of_get_property(np, "local-mac-address", NULL);
 	if (p == NULL) {
-		printk(KERN_ERR "%s: Can't find local-mac-address property\n",
-		       np->full_name);
+		printk(KERN_ERR "%pOF: Can't find local-mac-address property\n",
+		       np);
 		return -ENXIO;
 	}
 	memcpy(dev->ndev->dev_addr, p, ETH_ALEN);
@@ -3043,23 +3039,21 @@ static int emac_probe(struct platform_device *ofdev)
 	dev->emac_irq = irq_of_parse_and_map(np, 0);
 	dev->wol_irq = irq_of_parse_and_map(np, 1);
 	if (!dev->emac_irq) {
-		printk(KERN_ERR "%s: Can't map main interrupt\n", np->full_name);
+		printk(KERN_ERR "%pOF: Can't map main interrupt\n", np);
 		goto err_free;
 	}
 	ndev->irq = dev->emac_irq;

 	/* Map EMAC regs */
 	if (of_address_to_resource(np, 0, &dev->rsrc_regs)) {
-		printk(KERN_ERR "%s: Can't get registers address\n",
-		       np->full_name);
+		printk(KERN_ERR "%pOF: Can't get registers address\n", np);
 		goto err_irq_unmap;
 	}
 	// TODO : request_mem_region
 	dev->emacp = ioremap(dev->rsrc_regs.start,
 			     resource_size(&dev->rsrc_regs));
 	if (dev->emacp == NULL) {
-		printk(KERN_ERR "%s: Can't map device registers!\n",
-		       np->full_name);
+		printk(KERN_ERR "%pOF: Can't map device registers!\n", np);
 		err = -ENOMEM;
 		goto err_irq_unmap;
 	}
@@ -3068,8 +3062,7 @@ static int emac_probe(struct platform_device *ofdev)
 	err = emac_wait_deps(dev);
 	if (err) {
 		printk(KERN_ERR
-		       "%s: Timeout waiting for dependent devices\n",
-		       np->full_name);
+		       "%pOF: Timeout waiting for dependent devices\n", np);
 		/*  display more info about what's missing ? */
 		goto err_reg_unmap;
 	}
@@ -3084,8 +3077,8 @@ static int emac_probe(struct platform_device *ofdev)
 	dev->commac.rx_chan_mask = MAL_CHAN_MASK(dev->mal_rx_chan);
 	err = mal_register_commac(dev->mal, &dev->commac);
 	if (err) {
-		printk(KERN_ERR "%s: failed to register with mal %s!\n",
-		       np->full_name, dev->mal_dev->dev.of_node->full_name);
+		printk(KERN_ERR "%pOF: failed to register with mal %pOF!\n",
+		       np, dev->mal_dev->dev.of_node);
 		goto err_rel_deps;
 	}
 	dev->rx_skb_size = emac_rx_skb_size(ndev->mtu);
@@ -3161,8 +3154,8 @@ static int emac_probe(struct platform_device *ofdev)

 	err = register_netdev(ndev);
 	if (err) {
-		printk(KERN_ERR "%s: failed to register net device (%d)!\n",
-		       np->full_name, err);
+		printk(KERN_ERR "%pOF: failed to register net device (%d)!\n",
+		       np, err);
 		goto err_detach_tah;
 	}

@@ -3176,8 +3169,8 @@ static int emac_probe(struct platform_device *ofdev)
 	wake_up_all(&emac_probe_wait);


-	printk(KERN_INFO "%s: EMAC-%d %s, MAC %pM\n",
-	       ndev->name, dev->cell_index, np->full_name, ndev->dev_addr);
+	printk(KERN_INFO "%s: EMAC-%d %pOF, MAC %pM\n",
+	       ndev->name, dev->cell_index, np, ndev->dev_addr);

 	if (dev->phy_mode == PHY_MODE_SGMII)
 		printk(KERN_NOTICE "%s: in SGMII mode\n", ndev->name);
diff --git a/drivers/net/ethernet/ibm/emac/debug.h b/drivers/net/ethernet/ibm/emac/debug.h
index 5bdfc174a07e..9d06d3be3161 100644
--- a/drivers/net/ethernet/ibm/emac/debug.h
+++ b/drivers/net/ethernet/ibm/emac/debug.h
@@ -31,7 +31,7 @@
 #endif

 #define EMAC_DBG(d, name, fmt, arg...) \
-	printk(KERN_DEBUG #name "%s: " fmt, d->ofdev->dev.of_node->full_name, ## arg)
+	printk(KERN_DEBUG #name "%pOF: " fmt, d->ofdev->dev.of_node, ## arg)

 #if DBG_LEVEL > 0
 #  define DBG(d,f,x...)		EMAC_DBG(d, emac, f, ##x)
diff --git a/drivers/net/ethernet/ibm/emac/mal.c b/drivers/net/ethernet/ibm/emac/mal.c
index 91b1a558f37d..2c74baa2398a 100644
--- a/drivers/net/ethernet/ibm/emac/mal.c
+++ b/drivers/net/ethernet/ibm/emac/mal.c
@@ -579,8 +579,8 @@ static int mal_probe(struct platform_device *ofdev)
 		mal->features |= (MAL_FTR_CLEAR_ICINTSTAT |
 				MAL_FTR_COMMON_ERR_INT);
 #else
-		printk(KERN_ERR "%s: Support for 405EZ not enabled!\n",
-				ofdev->dev.of_node->full_name);
+		printk(KERN_ERR "%pOF: Support for 405EZ not enabled!\n",
+				ofdev->dev.of_node);
 		err = -ENODEV;
 		goto fail;
 #endif
@@ -687,8 +687,8 @@ static int mal_probe(struct platform_device *ofdev)
 	mal_enable_eob_irq(mal);

 	printk(KERN_INFO
-	       "MAL v%d %s, %d TX channels, %d RX channels\n",
-	       mal->version, ofdev->dev.of_node->full_name,
+	       "MAL v%d %pOF, %d TX channels, %d RX channels\n",
+	       mal->version, ofdev->dev.of_node,
 	       mal->num_tx_chans, mal->num_rx_chans);

 	/* Advertise this instance to the rest of the world */
diff --git a/drivers/net/ethernet/ibm/emac/rgmii.c b/drivers/net/ethernet/ibm/emac/rgmii.c
index 206ccbbae7bb..c4a1ac38bba8 100644
--- a/drivers/net/ethernet/ibm/emac/rgmii.c
+++ b/drivers/net/ethernet/ibm/emac/rgmii.c
@@ -104,8 +104,8 @@ int rgmii_attach(struct platform_device *ofdev, int input, int mode)

 	/* Check if we need to attach to a RGMII */
 	if (input < 0 || !rgmii_valid_mode(mode)) {
-		printk(KERN_ERR "%s: unsupported settings !\n",
-		       ofdev->dev.of_node->full_name);
+		printk(KERN_ERR "%pOF: unsupported settings !\n",
+		       ofdev->dev.of_node);
 		return -ENODEV;
 	}

@@ -114,8 +114,8 @@ int rgmii_attach(struct platform_device *ofdev, int input, int mode)
 	/* Enable this input */
 	out_be32(&p->fer, in_be32(&p->fer) | rgmii_mode_mask(mode, input));

-	printk(KERN_NOTICE "%s: input %d in %s mode\n",
-	       ofdev->dev.of_node->full_name, input, rgmii_mode_name(mode));
+	printk(KERN_NOTICE "%pOF: input %d in %s mode\n",
+	       ofdev->dev.of_node, input, rgmii_mode_name(mode));

 	++dev->users;

@@ -249,8 +249,7 @@ static int rgmii_probe(struct platform_device *ofdev)

 	rc = -ENXIO;
 	if (of_address_to_resource(np, 0, &regs)) {
-		printk(KERN_ERR "%s: Can't get registers address\n",
-		       np->full_name);
+		printk(KERN_ERR "%pOF: Can't get registers address\n", np);
 		goto err_free;
 	}

@@ -258,8 +257,7 @@ static int rgmii_probe(struct platform_device *ofdev)
 	dev->base = (struct rgmii_regs __iomem *)ioremap(regs.start,
 						 sizeof(struct rgmii_regs));
 	if (dev->base == NULL) {
-		printk(KERN_ERR "%s: Can't map device registers!\n",
-		       np->full_name);
+		printk(KERN_ERR "%pOF: Can't map device registers!\n", np);
 		goto err_free;
 	}

@@ -278,8 +276,8 @@ static int rgmii_probe(struct platform_device *ofdev)
 	out_be32(&dev->base->fer, 0);

 	printk(KERN_INFO
-	       "RGMII %s initialized with%s MDIO support\n",
-	       ofdev->dev.of_node->full_name,
+	       "RGMII %pOF initialized with%s MDIO support\n",
+	       ofdev->dev.of_node,
 	       (dev->flags & EMAC_RGMII_FLAG_HAS_MDIO) ? "" : "out");

 	wmb();
diff --git a/drivers/net/ethernet/ibm/emac/tah.c b/drivers/net/ethernet/ibm/emac/tah.c
index 32cb6c9007c5..9912456dca48 100644
--- a/drivers/net/ethernet/ibm/emac/tah.c
+++ b/drivers/net/ethernet/ibm/emac/tah.c
@@ -58,8 +58,7 @@ void tah_reset(struct platform_device *ofdev)
 		--n;

 	if (unlikely(!n))
-		printk(KERN_ERR "%s: reset timeout\n",
-			ofdev->dev.of_node->full_name);
+		printk(KERN_ERR "%pOF: reset timeout\n", ofdev->dev.of_node);

 	/* 10KB TAH TX FIFO accommodates the max MTU of 9000 */
 	out_be32(&p->mr,
@@ -105,8 +104,7 @@ static int tah_probe(struct platform_device *ofdev)

 	rc = -ENXIO;
 	if (of_address_to_resource(np, 0, &regs)) {
-		printk(KERN_ERR "%s: Can't get registers address\n",
-		       np->full_name);
+		printk(KERN_ERR "%pOF: Can't get registers address\n", np);
 		goto err_free;
 	}

@@ -114,8 +112,7 @@ static int tah_probe(struct platform_device *ofdev)
 	dev->base = (struct tah_regs __iomem *)ioremap(regs.start,
 					       sizeof(struct tah_regs));
 	if (dev->base == NULL) {
-		printk(KERN_ERR "%s: Can't map device registers!\n",
-		       np->full_name);
+		printk(KERN_ERR "%pOF: Can't map device registers!\n", np);
 		goto err_free;
 	}

@@ -124,8 +121,7 @@ static int tah_probe(struct platform_device *ofdev)
 	/* Initialize TAH and enable IPv4 checksum verification, no TSO yet */
 	tah_reset(ofdev);

-	printk(KERN_INFO
-	       "TAH %s initialized\n", ofdev->dev.of_node->full_name);
+	printk(KERN_INFO "TAH %pOF initialized\n", ofdev->dev.of_node);
 	wmb();

 	return 0;
diff --git a/drivers/net/ethernet/ibm/emac/zmii.c b/drivers/net/ethernet/ibm/emac/zmii.c
index 8727b865ea02..89c42d362292 100644
--- a/drivers/net/ethernet/ibm/emac/zmii.c
+++ b/drivers/net/ethernet/ibm/emac/zmii.c
@@ -121,15 +121,15 @@ int zmii_attach(struct platform_device *ofdev, int input, int *mode)
 		} else
 			dev->mode = *mode;

-		printk(KERN_NOTICE "%s: bridge in %s mode\n",
-		       ofdev->dev.of_node->full_name,
+		printk(KERN_NOTICE "%pOF: bridge in %s mode\n",
+		       ofdev->dev.of_node,
 		       zmii_mode_name(dev->mode));
 	} else {
 		/* All inputs must use the same mode */
 		if (*mode != PHY_MODE_NA && *mode != dev->mode) {
 			printk(KERN_ERR
-			       "%s: invalid mode %d specified for input %d\n",
-			       ofdev->dev.of_node->full_name, *mode, input);
+			       "%pOF: invalid mode %d specified for input %d\n",
+			       ofdev->dev.of_node, *mode, input);
 			mutex_unlock(&dev->lock);
 			return -EINVAL;
 		}
@@ -250,8 +250,7 @@ static int zmii_probe(struct platform_device *ofdev)

 	rc = -ENXIO;
 	if (of_address_to_resource(np, 0, &regs)) {
-		printk(KERN_ERR "%s: Can't get registers address\n",
-		       np->full_name);
+		printk(KERN_ERR "%pOF: Can't get registers address\n", np);
 		goto err_free;
 	}

@@ -259,8 +258,7 @@ static int zmii_probe(struct platform_device *ofdev)
 	dev->base = (struct zmii_regs __iomem *)ioremap(regs.start,
 						sizeof(struct zmii_regs));
 	if (dev->base == NULL) {
-		printk(KERN_ERR "%s: Can't map device registers!\n",
-		       np->full_name);
+		printk(KERN_ERR "%pOF: Can't map device registers!\n", np);
 		goto err_free;
 	}

@@ -270,8 +268,7 @@ static int zmii_probe(struct platform_device *ofdev)
 	/* Disable all inputs by default */
 	out_be32(&dev->base->fer, 0);

-	printk(KERN_INFO
-	       "ZMII %s initialized\n", ofdev->dev.of_node->full_name);
+	printk(KERN_INFO "ZMII %pOF initialized\n", ofdev->dev.of_node);
 	wmb();
 	platform_set_drvdata(ofdev, dev);

diff --git a/drivers/net/ethernet/sun/niu.c b/drivers/net/ethernet/sun/niu.c
index 46cb7f8955a2..d66949fdd27e 100644
--- a/drivers/net/ethernet/sun/niu.c
+++ b/drivers/net/ethernet/sun/niu.c
@@ -9221,8 +9221,7 @@ static int niu_get_of_props(struct niu *np)

 	phy_type = of_get_property(dp, "phy-type", &prop_len);
 	if (!phy_type) {
-		netdev_err(dev, "%s: OF node lacks phy-type property\n",
-			   dp->full_name);
+		netdev_err(dev, "%pOF: OF node lacks phy-type property\n", dp);
 		return -EINVAL;
 	}

@@ -9232,26 +9231,25 @@ static int niu_get_of_props(struct niu *np)
 	strcpy(np->vpd.phy_type, phy_type);

 	if (niu_phy_type_prop_decode(np, np->vpd.phy_type)) {
-		netdev_err(dev, "%s: Illegal phy string [%s]\n",
-			   dp->full_name, np->vpd.phy_type);
+		netdev_err(dev, "%pOF: Illegal phy string [%s]\n",
+			   dp, np->vpd.phy_type);
 		return -EINVAL;
 	}

 	mac_addr = of_get_property(dp, "local-mac-address", &prop_len);
 	if (!mac_addr) {
-		netdev_err(dev, "%s: OF node lacks local-mac-address property\n",
-			   dp->full_name);
+		netdev_err(dev, "%pOF: OF node lacks local-mac-address property\n",
+			   dp);
 		return -EINVAL;
 	}
 	if (prop_len != dev->addr_len) {
-		netdev_err(dev, "%s: OF MAC address prop len (%d) is wrong\n",
-			   dp->full_name, prop_len);
+		netdev_err(dev, "%pOF: OF MAC address prop len (%d) is wrong\n",
+			   dp, prop_len);
 	}
 	memcpy(dev->dev_addr, mac_addr, dev->addr_len);
 	if (!is_valid_ether_addr(&dev->dev_addr[0])) {
-		netdev_err(dev, "%s: OF MAC address is invalid\n",
-			   dp->full_name);
-		netdev_err(dev, "%s: [ %pM ]\n", dp->full_name, dev->dev_addr);
+		netdev_err(dev, "%pOF: OF MAC address is invalid\n", dp);
+		netdev_err(dev, "%pOF: [ %pM ]\n", dp, dev->dev_addr);
 		return -EINVAL;
 	}

@@ -10027,8 +10025,8 @@ static int niu_of_probe(struct platform_device *op)

 	reg = of_get_property(op->dev.of_node, "reg", NULL);
 	if (!reg) {
-		dev_err(&op->dev, "%s: No 'reg' property, aborting\n",
-			op->dev.of_node->full_name);
+		dev_err(&op->dev, "%pOF: No 'reg' property, aborting\n",
+			op->dev.of_node);
 		return -ENODEV;
 	}

diff --git a/drivers/net/ethernet/ti/cpsw.c b/drivers/net/ethernet/ti/cpsw.c
index 1850e348f555..1a76481ed023 100644
--- a/drivers/net/ethernet/ti/cpsw.c
+++ b/drivers/net/ethernet/ti/cpsw.c
@@ -1321,8 +1321,8 @@ static void cpsw_slave_open(struct cpsw_slave *slave, struct cpsw_priv *priv)
 		phy = of_phy_connect(priv->ndev, slave->data->phy_node,
 				 &cpsw_adjust_link, 0, slave->data->phy_if);
 		if (!phy) {
-			dev_err(priv->dev, "phy \"%s\" not found on slave %d\n",
-				slave->data->phy_node->full_name,
+			dev_err(priv->dev, "phy \"%pOF\" not found on slave %d\n",
+				slave->data->phy_node,
 				slave->slave_num);
 			return;
 		}
@@ -2670,8 +2670,8 @@ static int cpsw_probe_dt(struct cpsw_platform_data *data,
 		parp = of_get_property(slave_node, "phy_id", &lenp);
 		if (slave_data->phy_node) {
 			dev_dbg(&pdev->dev,
-				"slave[%d] using phy-handle=\"%s\"\n",
-				i, slave_data->phy_node->full_name);
+				"slave[%d] using phy-handle=\"%pOF\"\n",
+				i, slave_data->phy_node);
 		} else if (of_phy_is_fixed_link(slave_node)) {
 			/* In the case of a fixed PHY, the DT node associated
 			 * to the PHY is the Ethernet MAC DT node.
diff --git a/drivers/net/ethernet/ti/davinci_emac.c b/drivers/net/ethernet/ti/davinci_emac.c
index 64d5527feb2a..4bb561856af5 100644
--- a/drivers/net/ethernet/ti/davinci_emac.c
+++ b/drivers/net/ethernet/ti/davinci_emac.c
@@ -1480,8 +1480,8 @@ static int emac_dev_open(struct net_device *ndev)
 		phydev = of_phy_connect(ndev, priv->phy_node,
 					&emac_adjust_link, 0, 0);
 		if (!phydev) {
-			dev_err(emac_dev, "could not connect to phy %s\n",
-				priv->phy_node->full_name);
+			dev_err(emac_dev, "could not connect to phy %pOF\n",
+				priv->phy_node);
 			ret = -ENODEV;
 			goto err;
 		}
diff --git a/drivers/net/ethernet/xilinx/ll_temac_main.c b/drivers/net/ethernet/xilinx/ll_temac_main.c
index d73da8afe08e..60abc9250f56 100644
--- a/drivers/net/ethernet/xilinx/ll_temac_main.c
+++ b/drivers/net/ethernet/xilinx/ll_temac_main.c
@@ -1089,7 +1089,7 @@ static int temac_of_probe(struct platform_device *op)

 	lp->phy_node = of_parse_phandle(op->dev.of_node, "phy-handle", 0);
 	if (lp->phy_node)
-		dev_dbg(lp->dev, "using PHY node %s (%p)\n", np->full_name, np);
+		dev_dbg(lp->dev, "using PHY node %pOF (%p)\n", np, np);

 	/* Add the device attributes */
 	rc = sysfs_create_group(&lp->dev->kobj, &temac_attr_group);
diff --git a/drivers/net/phy/mdio-mux-mmioreg.c b/drivers/net/phy/mdio-mux-mmioreg.c
index 6a33646bdf05..c3825c7da038 100644
--- a/drivers/net/phy/mdio-mux-mmioreg.c
+++ b/drivers/net/phy/mdio-mux-mmioreg.c
@@ -105,7 +105,7 @@ static int mdio_mux_mmioreg_probe(struct platform_device *pdev)
 	const __be32 *iprop;
 	int len, ret;

-	dev_dbg(&pdev->dev, "probing node %s\n", np->full_name);
+	dev_dbg(&pdev->dev, "probing node %pOF\n", np);

 	s = devm_kzalloc(&pdev->dev, sizeof(*s), GFP_KERNEL);
 	if (!s)
@@ -113,8 +113,8 @@ static int mdio_mux_mmioreg_probe(struct platform_device *pdev)

 	ret = of_address_to_resource(np, 0, &res);
 	if (ret) {
-		dev_err(&pdev->dev, "could not obtain memory map for node %s\n",
-			np->full_name);
+		dev_err(&pdev->dev, "could not obtain memory map for node %pOF\n",
+			np);
 		return ret;
 	}
 	s->phys = res.start;
@@ -145,15 +145,15 @@ static int mdio_mux_mmioreg_probe(struct platform_device *pdev)
 	for_each_available_child_of_node(np, np2) {
 		iprop = of_get_property(np2, "reg", &len);
 		if (!iprop || len != sizeof(uint32_t)) {
-			dev_err(&pdev->dev, "mdio-mux child node %s is "
-				"missing a 'reg' property\n", np2->full_name);
+			dev_err(&pdev->dev, "mdio-mux child node %pOF is "
+				"missing a 'reg' property\n", np2);
 			of_node_put(np2);
 			return -ENODEV;
 		}
 		if (be32_to_cpup(iprop) & ~s->mask) {
-			dev_err(&pdev->dev, "mdio-mux child node %s has "
+			dev_err(&pdev->dev, "mdio-mux child node %pOF has "
 				"a 'reg' value with unmasked bits\n",
-				np2->full_name);
+				np2);
 			of_node_put(np2);
 			return -ENODEV;
 		}
@@ -162,8 +162,8 @@ static int mdio_mux_mmioreg_probe(struct platform_device *pdev)
 	ret = mdio_mux_init(&pdev->dev, mdio_mux_mmioreg_switch_fn,
 			    &s->mux_handle, s, NULL);
 	if (ret) {
-		dev_err(&pdev->dev, "failed to register mdio-mux bus %s\n",
-			np->full_name);
+		dev_err(&pdev->dev, "failed to register mdio-mux bus %pOF\n",
+			np);
 		return ret;
 	}

diff --git a/drivers/net/phy/mdio-mux.c b/drivers/net/phy/mdio-mux.c
index 00755b6a42cf..bb75116eb0c4 100644
--- a/drivers/net/phy/mdio-mux.c
+++ b/drivers/net/phy/mdio-mux.c
@@ -138,16 +138,16 @@ int mdio_mux_init(struct device *dev,
 		v = of_mdio_parse_addr(dev, child_bus_node);
 		if (v < 0) {
 			dev_err(dev,
-				"Error: Failed to find reg for child %s\n",
-				of_node_full_name(child_bus_node));
+				"Error: Failed to find reg for child %pOF\n",
+				child_bus_node);
 			continue;
 		}

 		cb = devm_kzalloc(dev, sizeof(*cb), GFP_KERNEL);
 		if (cb == NULL) {
 			dev_err(dev,
-				"Error: Failed to allocate memory for child %s\n",
-				of_node_full_name(child_bus_node));
+				"Error: Failed to allocate memory for child %pOF\n",
+				child_bus_node);
 			ret_val = -ENOMEM;
 			continue;
 		}
@@ -157,8 +157,8 @@ int mdio_mux_init(struct device *dev,
 		cb->mii_bus = mdiobus_alloc();
 		if (!cb->mii_bus) {
 			dev_err(dev,
-				"Error: Failed to allocate MDIO bus for child %s\n",
-				of_node_full_name(child_bus_node));
+				"Error: Failed to allocate MDIO bus for child %pOF\n",
+				child_bus_node);
 			ret_val = -ENOMEM;
 			devm_kfree(dev, cb);
 			continue;
@@ -174,8 +174,8 @@ int mdio_mux_init(struct device *dev,
 		r = of_mdiobus_register(cb->mii_bus, child_bus_node);
 		if (r) {
 			dev_err(dev,
-				"Error: Failed to register MDIO bus for child %s\n",
-				of_node_full_name(child_bus_node));
+				"Error: Failed to register MDIO bus for child %pOF\n",
+				child_bus_node);
 			mdiobus_free(cb->mii_bus);
 			devm_kfree(dev, cb);
 		} else {
--
2.11.0
