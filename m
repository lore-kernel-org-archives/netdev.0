From: Chen-Yu Tsai <wens-jdAy2FN1RRM@public.gmane.org>
Subject: [PATCH 03/10] net: stmmac: Use platform data tied with
 compatible strings
Date: Sat,  7 Dec 2013 01:29:36 +0800
Message-ID: <1386350983-13281-4-git-send-email-wens@csie.org>
References: <1386350983-13281-1-git-send-email-wens@csie.org>
Reply-To: linux-sunxi-/JYPxA39Uh5TLH3MbocFFw@public.gmane.org
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: Chen-Yu Tsai <wens-jdAy2FN1RRM@public.gmane.org>,
	Srinivas Kandagatla <srinivas.kandagatla-qxv4g6HH51o@public.gmane.org>,
	Maxime Ripard <maxime.ripard-wi1+55ScJUtKEb57/3fJTNBPR1lH4CV8@public.gmane.org>
To: Giuseppe Cavallaro <peppe.cavallaro-qxv4g6HH51o@public.gmane.org>,
	netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	Rob Herring <rob.herring-bsGFqQB8/DxBDgjK7y7TUQ@public.gmane.org>,
	devicetree-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	linux-arm-kernel-IAPFreCvJWM7uuMidbF8XUB+6BGkLq7r@public.gmane.org,
	linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	linux-sunxi-/JYPxA39Uh5TLH3MbocFFw@public.gmane.org
Return-path: <linux-sunxi+bncBCMILY6JWQBBBTUTRCKQKGQEKDUWW6I-/JYPxA39Uh5TLH3MbocFFw@public.gmane.org>
In-Reply-To: <1386350983-13281-1-git-send-email-wens-jdAy2FN1RRM@public.gmane.org>
List-Post: <http://groups.google.com/group/linux-sunxi/post>, <mailto:linux-sunxi-/JYPxA39Uh5TLH3MbocFFw@public.gmane.org>
List-Help: <http://groups.google.com/support/>, <mailto:linux-sunxi+help-/JYPxA39Uh5TLH3MbocFFw@public.gmane.org>
List-Archive: <http://groups.google.com/group/linux-sunxi>
Sender: linux-sunxi-/JYPxA39Uh5TLH3MbocFFw@public.gmane.org
List-Subscribe: <http://groups.google.com/group/linux-sunxi/subscribe>, <mailto:linux-sunxi+subscribe-/JYPxA39Uh5TLH3MbocFFw@public.gmane.org>
List-Unsubscribe: <http://groups.google.com/group/linux-sunxi/subscribe>, <mailto:googlegroups-manage+1076902468213+unsubscribe-/JYPxA39Uh5TLH3MbocFFw@public.gmane.org>
List-Id: netdev.vger.kernel.org

Signed-off-by: Chen-Yu Tsai <wens-jdAy2FN1RRM@public.gmane.org>
---
 .../net/ethernet/stmicro/stmmac/stmmac_platform.c  | 29 ++++++++++++++--------
 1 file changed, 19 insertions(+), 10 deletions(-)

diff --git a/drivers/net/ethernet/stmicro/stmmac/stmmac_platform.c b/drivers/net/ethernet/stmicro/stmmac/stmmac_platform.c
index 74c7aef..df3fd1c 100644
--- a/drivers/net/ethernet/stmicro/stmmac/stmmac_platform.c
+++ b/drivers/net/ethernet/stmicro/stmmac/stmmac_platform.c
@@ -26,8 +26,19 @@
 #include <linux/io.h>
 #include <linux/of.h>
 #include <linux/of_net.h>
+#include <linux/of_device.h>
 #include "stmmac.h"
 
+static const struct of_device_id stmmac_dt_ids[] = {
+	{ .compatible = "st,spear600-gmac"},
+	{ .compatible = "snps,dwmac-3.610"},
+	{ .compatible = "snps,dwmac-3.70a"},
+	{ .compatible = "snps,dwmac-3.710"},
+	{ .compatible = "snps,dwmac"},
+	{ /* sentinel */ }
+};
+MODULE_DEVICE_TABLE(of, stmmac_dt_ids);
+
 #ifdef CONFIG_OF
 static int stmmac_probe_config_dt(struct platform_device *pdev,
 				  struct plat_stmmacenet_data *plat,
@@ -35,10 +46,18 @@ static int stmmac_probe_config_dt(struct platform_device *pdev,
 {
 	struct device_node *np = pdev->dev.of_node;
 	struct stmmac_dma_cfg *dma_cfg;
+	const struct of_device_id *device;
 
 	if (!np)
 		return -ENODEV;
 
+	device = of_match_device(stmmac_dt_ids, &pdev->dev);
+	if (!device)
+		return -ENODEV;
+
+	if (device->data)
+	    memcpy(plat, device->data, sizeof(*plat));
+
 	*mac = of_get_mac_address(np);
 	plat->interface = of_get_phy_mode(np);
 
@@ -257,16 +276,6 @@ static const struct dev_pm_ops stmmac_pltfr_pm_ops = {
 static const struct dev_pm_ops stmmac_pltfr_pm_ops;
 #endif /* CONFIG_PM */
 
-static const struct of_device_id stmmac_dt_ids[] = {
-	{ .compatible = "st,spear600-gmac"},
-	{ .compatible = "snps,dwmac-3.610"},
-	{ .compatible = "snps,dwmac-3.70a"},
-	{ .compatible = "snps,dwmac-3.710"},
-	{ .compatible = "snps,dwmac"},
-	{ /* sentinel */ }
-};
-MODULE_DEVICE_TABLE(of, stmmac_dt_ids);
-
 struct platform_driver stmmac_pltfr_driver = {
 	.probe = stmmac_pltfr_probe,
 	.remove = stmmac_pltfr_remove,
-- 
1.8.5.1
