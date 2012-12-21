From: Greg Kroah-Hartman <gregkh@linuxfoundation.org>
Subject: [PATCH] Drivers: network: more __dev* removal
Date: Fri, 21 Dec 2012 15:42:15 -0800
Message-ID: <20121221234215.GA13447@kroah.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Bill Pemberton <wfp5p@virginia.edu>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f44.google.com ([209.85.220.44]:62650 "EHLO
	mail-pa0-f44.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751409Ab2LUXpU (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 21 Dec 2012 18:45:20 -0500
Received: by mail-pa0-f44.google.com with SMTP id hz11so3125251pad.17
        for <netdev@vger.kernel.org>; Fri, 21 Dec 2012 15:45:20 -0800 (PST)
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Remove some __dev* markings that snuck in the 3.8-rc1 merge window in
the drivers/net/* directory.

Cc: Bill Pemberton <wfp5p@virginia.edu>
Signed-off-by: Greg Kroah-Hartman <gregkh@linuxfoundation.org>

diff --git a/drivers/net/ethernet/marvell/mvmdio.c b/drivers/net/ethernet/marvell/mvmdio.c
index 6d6002b..74f1c15 100644
--- a/drivers/net/ethernet/marvell/mvmdio.c
+++ b/drivers/net/ethernet/marvell/mvmdio.c
@@ -141,7 +141,7 @@ static int orion_mdio_reset(struct mii_bus *bus)
 	return 0;
 }
 
-static int __devinit orion_mdio_probe(struct platform_device *pdev)
+static int orion_mdio_probe(struct platform_device *pdev)
 {
 	struct device_node *np = pdev->dev.of_node;
 	struct mii_bus *bus;
@@ -197,7 +197,7 @@ static int __devinit orion_mdio_probe(struct platform_device *pdev)
 	return 0;
 }
 
-static int __devexit orion_mdio_remove(struct platform_device *pdev)
+static int orion_mdio_remove(struct platform_device *pdev)
 {
 	struct mii_bus *bus = platform_get_drvdata(pdev);
 	mdiobus_unregister(bus);
@@ -214,7 +214,7 @@ MODULE_DEVICE_TABLE(of, orion_mdio_match);
 
 static struct platform_driver orion_mdio_driver = {
 	.probe = orion_mdio_probe,
-	.remove = __devexit_p(orion_mdio_remove),
+	.remove = orion_mdio_remove,
 	.driver = {
 		.name = "orion-mdio",
 		.of_match_table = orion_mdio_match,
diff --git a/drivers/net/ethernet/marvell/mvneta.c b/drivers/net/ethernet/marvell/mvneta.c
index 3f8086b..b6025c3 100644
--- a/drivers/net/ethernet/marvell/mvneta.c
+++ b/drivers/net/ethernet/marvell/mvneta.c
@@ -635,7 +635,7 @@ static void mvneta_rxq_bm_disable(struct mvneta_port *pp,
 
 
 /* Sets the RGMII Enable bit (RGMIIEn) in port MAC control register */
-static void __devinit mvneta_gmac_rgmii_set(struct mvneta_port *pp, int enable)
+static void mvneta_gmac_rgmii_set(struct mvneta_port *pp, int enable)
 {
 	u32  val;
 
@@ -650,7 +650,7 @@ static void __devinit mvneta_gmac_rgmii_set(struct mvneta_port *pp, int enable)
 }
 
 /* Config SGMII port */
-static void __devinit mvneta_port_sgmii_config(struct mvneta_port *pp)
+static void mvneta_port_sgmii_config(struct mvneta_port *pp)
 {
 	u32 val;
 
@@ -2564,7 +2564,7 @@ const struct ethtool_ops mvneta_eth_tool_ops = {
 };
 
 /* Initialize hw */
-static int __devinit mvneta_init(struct mvneta_port *pp, int phy_addr)
+static int mvneta_init(struct mvneta_port *pp, int phy_addr)
 {
 	int queue;
 
@@ -2613,9 +2613,8 @@ static void mvneta_deinit(struct mvneta_port *pp)
 }
 
 /* platform glue : initialize decoding windows */
-static void __devinit
-mvneta_conf_mbus_windows(struct mvneta_port *pp,
-			 const struct mbus_dram_target_info *dram)
+static void mvneta_conf_mbus_windows(struct mvneta_port *pp,
+				     const struct mbus_dram_target_info *dram)
 {
 	u32 win_enable;
 	u32 win_protect;
@@ -2648,7 +2647,7 @@ mvneta_conf_mbus_windows(struct mvneta_port *pp,
 }
 
 /* Power up the port */
-static void __devinit mvneta_port_power_up(struct mvneta_port *pp, int phy_mode)
+static void mvneta_port_power_up(struct mvneta_port *pp, int phy_mode)
 {
 	u32 val;
 
@@ -2671,7 +2670,7 @@ static void __devinit mvneta_port_power_up(struct mvneta_port *pp, int phy_mode)
 }
 
 /* Device initialization routine */
-static int __devinit mvneta_probe(struct platform_device *pdev)
+static int mvneta_probe(struct platform_device *pdev)
 {
 	const struct mbus_dram_target_info *dram_target_info;
 	struct device_node *dn = pdev->dev.of_node;
@@ -2803,7 +2802,7 @@ err_free_netdev:
 }
 
 /* Device removal routine */
-static int __devexit mvneta_remove(struct platform_device *pdev)
+static int mvneta_remove(struct platform_device *pdev)
 {
 	struct net_device  *dev = platform_get_drvdata(pdev);
 	struct mvneta_port *pp = netdev_priv(dev);
@@ -2828,7 +2827,7 @@ MODULE_DEVICE_TABLE(of, mvneta_match);
 
 static struct platform_driver mvneta_driver = {
 	.probe = mvneta_probe,
-	.remove = __devexit_p(mvneta_remove),
+	.remove = mvneta_remove,
 	.driver = {
 		.name = MVNETA_DRIVER_NAME,
 		.of_match_table = mvneta_match,
diff --git a/drivers/net/wireless/rtlwifi/rtl8723ae/sw.c b/drivers/net/wireless/rtlwifi/rtl8723ae/sw.c
index 18b0bc5..bb7cc90 100644
--- a/drivers/net/wireless/rtlwifi/rtl8723ae/sw.c
+++ b/drivers/net/wireless/rtlwifi/rtl8723ae/sw.c
@@ -341,7 +341,7 @@ static struct rtl_hal_cfg rtl8723ae_hal_cfg = {
 	.maps[RTL_RC_HT_RATEMCS15] = DESC92_RATEMCS15,
 };
 
-static struct pci_device_id rtl8723ae_pci_ids[] __devinitdata = {
+static struct pci_device_id rtl8723ae_pci_ids[] = {
 	{RTL_PCI_DEVICE(PCI_VENDOR_ID_REALTEK, 0x8723, rtl8723ae_hal_cfg)},
 	{},
 };
