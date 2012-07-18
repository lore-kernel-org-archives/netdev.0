From: <dinguyen@altera.com>
Subject: [PATCHv1] net: stmmac: Add ip version to dts bindings
Date: Wed, 18 Jul 2012 17:28:26 -0600
Message-ID: <1342654106-8163-1-git-send-email-dinguyen@altera.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <dinh.linux@gmail.com>, <peppe.cavallaro@st.com>, <sr@denx.de>,
	<shiraz.hashim@st.com>, <deepak.sikri@st.com>, <pavel@denx.de>,
	<arnd@arndb.de>, Dinh Nguyen <dinguyen@altera.com>
To: <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from va3ehsobe006.messaging.microsoft.com ([216.32.180.16]:6002 "EHLO
	va3outboundpool.messaging.microsoft.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751347Ab2GRW3D (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 18 Jul 2012 18:29:03 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Dinh Nguyen <dinguyen@altera.com>

Because there are multiple variants to the stmmac/dwmac driver, the
dts bindings should be updated to include version of the IP used.

Signed-off-by: Dinh Nguyen <dinguyen@altera.com>
---
 Documentation/devicetree/bindings/net/stmmac.txt   |    3 ++-
 .../net/ethernet/stmicro/stmmac/stmmac_platform.c  |    8 ++++++--
 2 files changed, 8 insertions(+), 3 deletions(-)

diff --git a/Documentation/devicetree/bindings/net/stmmac.txt b/Documentation/devicetree/bindings/net/stmmac.txt
index 1f62623..060bbf0 100644
--- a/Documentation/devicetree/bindings/net/stmmac.txt
+++ b/Documentation/devicetree/bindings/net/stmmac.txt
@@ -1,7 +1,8 @@
 * STMicroelectronics 10/100/1000 Ethernet driver (GMAC)
 
 Required properties:
-- compatible: Should be "st,spear600-gmac"
+- compatible: Should be "snps,dwmac-<ip_version>" "snps,dwmac"
+	For backwards compatibility: "st,spear600-gmac" is also supported.
 - reg: Address and length of the register set for the device
 - interrupt-parent: Should be the phandle for the interrupt controller
   that services interrupts for this device
diff --git a/drivers/net/ethernet/stmicro/stmmac/stmmac_platform.c b/drivers/net/ethernet/stmicro/stmmac/stmmac_platform.c
index 680d2b8..87cadcf 100644
--- a/drivers/net/ethernet/stmicro/stmmac/stmmac_platform.c
+++ b/drivers/net/ethernet/stmicro/stmmac/stmmac_platform.c
@@ -49,7 +49,9 @@ static int __devinit stmmac_probe_config_dt(struct platform_device *pdev,
 	 * are provided. All other properties should be added
 	 * once needed on other platforms.
 	 */
-	if (of_device_is_compatible(np, "st,spear600-gmac")) {
+	if (of_device_is_compatible(np, "st,spear600-gmac") ||
+		of_device_is_compatible(np, "snps,dwmac-3.70a") ||
+		of_device_is_compatible(np, "snps,dwmac")) {
 		plat->has_gmac = 1;
 		plat->pmt = 1;
 	}
@@ -250,7 +252,9 @@ static const struct dev_pm_ops stmmac_pltfr_pm_ops;
 #endif /* CONFIG_PM */
 
 static const struct of_device_id stmmac_dt_ids[] = {
-	{ .compatible = "st,spear600-gmac", },
+	{ .compatible = "st,spear600-gmac"},
+	{ .compatible = "snps,dwmac-3.70a"},
+	{ .compatible = "snps,dwmac"},
 	{ /* sentinel */ }
 };
 MODULE_DEVICE_TABLE(of, stmmac_dt_ids);
-- 
1.7.9.5
