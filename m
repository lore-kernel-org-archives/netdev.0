From: Bernhard Walle <bernhard@bwalle.de>
Subject: [PATCH] net: fec: Rename "phy-reset-active-low" property
Date: Thu,  3 Mar 2016 10:15:55 +0100
Message-ID: <1456996555-7500-1-git-send-email-bernhard@bwalle.de>
Cc: arnd@arndb.de, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org, Bernhard Walle <bernhard@bwalle.de>
To: davem@davemloft.net
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

>From the perspective of RESET, the meaning of the new property
is actually "active high". Thanks for Troy Kisky for pointing
that out.

Since the patch is in linux-next, this patch is incremental and doesn't
replace the original patch.

Signed-off-by: Bernhard Walle <bernhard@bwalle.de>
---
 Documentation/devicetree/bindings/net/fsl-fec.txt | 2 +-
 drivers/net/ethernet/freescale/fec_main.c         | 8 ++++----
 2 files changed, 5 insertions(+), 5 deletions(-)

diff --git a/Documentation/devicetree/bindings/net/fsl-fec.txt b/Documentation/devicetree/bindings/net/fsl-fec.txt
index a4799ff..b037a9d 100644
--- a/Documentation/devicetree/bindings/net/fsl-fec.txt
+++ b/Documentation/devicetree/bindings/net/fsl-fec.txt
@@ -12,7 +12,7 @@ Optional properties:
   only if property "phy-reset-gpios" is available.  Missing the property
   will have the duration be 1 millisecond.  Numbers greater than 1000 are
   invalid and 1 millisecond will be used instead.
-- phy-reset-active-low : If present then the reset sequence using the GPIO
+- phy-reset-active-high : If present then the reset sequence using the GPIO
   specified in the "phy-reset-gpios" property is reversed (H=reset state,
   L=operation state).
 - phy-supply : regulator that powers the Ethernet PHY.
diff --git a/drivers/net/ethernet/freescale/fec_main.c b/drivers/net/ethernet/freescale/fec_main.c
index bad0ba2..37c0815 100644
--- a/drivers/net/ethernet/freescale/fec_main.c
+++ b/drivers/net/ethernet/freescale/fec_main.c
@@ -3191,7 +3191,7 @@ static int fec_enet_init(struct net_device *ndev)
 static void fec_reset_phy(struct platform_device *pdev)
 {
 	int err, phy_reset;
-	bool active_low = false;
+	bool active_high = false;
 	int msec = 1;
 	struct device_node *np = pdev->dev.of_node;
 
@@ -3207,17 +3207,17 @@ static void fec_reset_phy(struct platform_device *pdev)
 	if (!gpio_is_valid(phy_reset))
 		return;
 
-	active_low = of_property_read_bool(np, "phy-reset-active-low");
+	active_high = of_property_read_bool(np, "phy-reset-active-high");
 
 	err = devm_gpio_request_one(&pdev->dev, phy_reset,
-			active_low ? GPIOF_OUT_INIT_HIGH : GPIOF_OUT_INIT_LOW,
+			active_high ? GPIOF_OUT_INIT_HIGH : GPIOF_OUT_INIT_LOW,
 			"phy-reset");
 	if (err) {
 		dev_err(&pdev->dev, "failed to get phy-reset-gpios: %d\n", err);
 		return;
 	}
 	msleep(msec);
-	gpio_set_value_cansleep(phy_reset, !active_low);
+	gpio_set_value_cansleep(phy_reset, !active_high);
 }
 #else /* CONFIG_OF */
 static void fec_reset_phy(struct platform_device *pdev)
-- 
2.7.2
