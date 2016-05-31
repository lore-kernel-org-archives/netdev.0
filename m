From: "George G. Davis" <george_davis@mentor.com>
Subject: [PATCH] net: fec: dt: convert phy-reset-gpios to use GPIOD API
Date: Tue, 31 May 2016 13:17:51 -0400
Message-ID: <1464715071-56012-1-git-send-email-george_davis@mentor.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: Fugang Duan <fugang.duan@nxp.com>,
	Rob Herring <robh+dt@kernel.org>,
	Pawel Moll <pawel.moll@arm.com>,
	Mark Rutland <mark.rutland@arm.com>,
	Ian Campbell <ijc+devicetree@hellion.org.uk>,
	Kumar Gala <galak@codeaurora.org>,
	Shawn Guo <shawnguo@kernel.org>,
	Sascha Hauer <kernel@pengutronix.de>,
	Russell King <linux@armlinux.org.uk>,
	Linus Walleij <linus.walleij@linaro.org>,
	Alexandre Courbot <gnurou@gmail.com>,
	"George G. Davis" <george_davis@mentor.com>
To: <linux-gpio@vger.kernel.org>, <linux-kernel@vger.kernel.org>,
	<devicetree@vger.kernel.org>, <netdev@vger.kernel.org>
Return-path: <linux-gpio-owner@vger.kernel.org>
Sender: linux-gpio-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Convert the i.MX FEC driver and DT files to use the GPIOD API
which automatically handles GPIO polarity.

Signed-off-by: George G. Davis <george_davis@mentor.com>
---
 Documentation/devicetree/bindings/net/fsl-fec.txt |  7 ++-----
 arch/arm/boot/dts/imx25-karo-tx25.dts             |  3 ++-
 arch/arm/boot/dts/imx25-pdk.dts                   |  2 +-
 arch/arm/boot/dts/imx28-cfa10037.dts              |  2 +-
 arch/arm/boot/dts/imx28-cfa10049.dts              |  2 +-
 arch/arm/boot/dts/imx28-cfa10057.dts              |  2 +-
 arch/arm/boot/dts/imx28-cfa10058.dts              |  2 +-
 arch/arm/boot/dts/imx28-evk.dts                   |  2 +-
 arch/arm/boot/dts/imx28-m28cu3.dts                |  2 +-
 arch/arm/boot/dts/imx50-evk.dts                   |  3 ++-
 arch/arm/boot/dts/imx53-mba53.dts                 |  2 +-
 arch/arm/boot/dts/imx53-qsb-common.dtsi           |  2 +-
 arch/arm/boot/dts/imx53-smd.dts                   |  2 +-
 arch/arm/boot/dts/imx53-voipac-dmm-668.dtsi       |  2 +-
 arch/arm/boot/dts/imx6dl-riotboard.dts            |  2 +-
 arch/arm/boot/dts/imx6q-dmo-edmqmx6.dts           |  2 +-
 arch/arm/boot/dts/imx6q-evi.dts                   |  2 +-
 arch/arm/boot/dts/imx6qdl-microsom-ar8035.dtsi    |  2 +-
 arch/arm/boot/dts/imx6qdl-nitrogen6x.dtsi         |  2 +-
 arch/arm/boot/dts/imx6qdl-sabresd.dtsi            |  2 +-
 arch/arm/boot/dts/imx6qdl-wandboard.dtsi          |  2 +-
 drivers/net/ethernet/freescale/fec_main.c         | 19 +++++--------------
 22 files changed, 29 insertions(+), 39 deletions(-)

diff --git a/Documentation/devicetree/bindings/net/fsl-fec.txt b/Documentation/devicetree/bindings/net/fsl-fec.txt
index b037a9d..3da6a4a 100644
--- a/Documentation/devicetree/bindings/net/fsl-fec.txt
+++ b/Documentation/devicetree/bindings/net/fsl-fec.txt
@@ -12,9 +12,6 @@ Optional properties:
   only if property "phy-reset-gpios" is available.  Missing the property
   will have the duration be 1 millisecond.  Numbers greater than 1000 are
   invalid and 1 millisecond will be used instead.
-- phy-reset-active-high : If present then the reset sequence using the GPIO
-  specified in the "phy-reset-gpios" property is reversed (H=reset state,
-  L=operation state).
 - phy-supply : regulator that powers the Ethernet PHY.
 - phy-handle : phandle to the PHY device connected to this device.
 - fixed-link : Assume a fixed link. See fixed-link.txt in the same directory.
@@ -39,7 +36,7 @@ ethernet@83fec000 {
 	reg = <0x83fec000 0x4000>;
 	interrupts = <87>;
 	phy-mode = "mii";
-	phy-reset-gpios = <&gpio2 14 0>; /* GPIO2_14 */
+	phy-reset-gpios = <&gpio2 14 GPIO_ACTIVE_LOW>; /* GPIO2_14 */
 	local-mac-address = [00 04 9F 01 1B B9];
 	phy-supply = <&reg_fec_supply>;
 };
@@ -51,7 +48,7 @@ ethernet@83fec000 {
 	reg = <0x83fec000 0x4000>;
 	interrupts = <87>;
 	phy-mode = "mii";
-	phy-reset-gpios = <&gpio2 14 0>; /* GPIO2_14 */
+	phy-reset-gpios = <&gpio2 14 GPIO_ACTIVE_LOW>; /* GPIO2_14 */
 	local-mac-address = [00 04 9F 01 1B B9];
 	phy-supply = <&reg_fec_supply>;
 	phy-handle = <&ethphy>;
diff --git a/arch/arm/boot/dts/imx25-karo-tx25.dts b/arch/arm/boot/dts/imx25-karo-tx25.dts
index 9b31faa..e04272e 100644
--- a/arch/arm/boot/dts/imx25-karo-tx25.dts
+++ b/arch/arm/boot/dts/imx25-karo-tx25.dts
@@ -10,6 +10,7 @@
  */
 
 /dts-v1/;
+#include <dt-bindings/gpio/gpio.h>
 #include "imx25.dtsi"
 
 / {
@@ -97,7 +98,7 @@
 &fec {
 	pinctrl-names = "default";
 	pinctrl-0 = <&pinctrl_fec>;
-	phy-reset-gpios = <&gpio3 7 0>;
+	phy-reset-gpios = <&gpio3 7 GPIO_ACTIVE_LOW>;
 	phy-mode = "rmii";
 	phy-supply = <&reg_fec_phy>;
 	status = "okay";
diff --git a/arch/arm/boot/dts/imx25-pdk.dts b/arch/arm/boot/dts/imx25-pdk.dts
index 9351296..b690ce1 100644
--- a/arch/arm/boot/dts/imx25-pdk.dts
+++ b/arch/arm/boot/dts/imx25-pdk.dts
@@ -125,7 +125,7 @@
 	pinctrl-names = "default";
 	pinctrl-0 = <&pinctrl_fec>;
 	phy-supply = <&reg_fec_3v3>;
-	phy-reset-gpios = <&gpio4 8 0>;
+	phy-reset-gpios = <&gpio4 8 GPIO_ACTIVE_LOW>;
 	status = "okay";
 };
 
diff --git a/arch/arm/boot/dts/imx28-cfa10037.dts b/arch/arm/boot/dts/imx28-cfa10037.dts
index e5beaa5..3d13b32 100644
--- a/arch/arm/boot/dts/imx28-cfa10037.dts
+++ b/arch/arm/boot/dts/imx28-cfa10037.dts
@@ -64,7 +64,7 @@
 			pinctrl-names = "default";
 			pinctrl-0 = <&mac0_pins_a
 				&mac0_pins_cfa10037>;
-			phy-reset-gpios = <&gpio2 21 0>;
+			phy-reset-gpios = <&gpio2 21 GPIO_ACTIVE_LOW>;
 			phy-reset-duration = <100>;
 			status = "okay";
 		};
diff --git a/arch/arm/boot/dts/imx28-cfa10049.dts b/arch/arm/boot/dts/imx28-cfa10049.dts
index ef944b6..a78cc62 100644
--- a/arch/arm/boot/dts/imx28-cfa10049.dts
+++ b/arch/arm/boot/dts/imx28-cfa10049.dts
@@ -327,7 +327,7 @@
 			pinctrl-names = "default";
 			pinctrl-0 = <&mac0_pins_a
 				&mac0_pins_cfa10049>;
-			phy-reset-gpios = <&gpio2 21 0>;
+			phy-reset-gpios = <&gpio2 21 GPIO_ACTIVE_LOW>;
 			phy-reset-duration = <100>;
 			status = "okay";
 		};
diff --git a/arch/arm/boot/dts/imx28-cfa10057.dts b/arch/arm/boot/dts/imx28-cfa10057.dts
index 7a80bd6..c606791 100644
--- a/arch/arm/boot/dts/imx28-cfa10057.dts
+++ b/arch/arm/boot/dts/imx28-cfa10057.dts
@@ -162,7 +162,7 @@
 			phy-mode = "rmii";
 			pinctrl-names = "default";
 			pinctrl-0 = <&mac0_pins_a>;
-			phy-reset-gpios = <&gpio2 21 0>;
+			phy-reset-gpios = <&gpio2 21 GPIO_ACTIVE_LOW>;
 			phy-reset-duration = <100>;
 			status = "okay";
 		};
diff --git a/arch/arm/boot/dts/imx28-cfa10058.dts b/arch/arm/boot/dts/imx28-cfa10058.dts
index f5c6dce..70c7bb4 100644
--- a/arch/arm/boot/dts/imx28-cfa10058.dts
+++ b/arch/arm/boot/dts/imx28-cfa10058.dts
@@ -129,7 +129,7 @@
 			phy-mode = "rmii";
 			pinctrl-names = "default";
 			pinctrl-0 = <&mac0_pins_a>;
-			phy-reset-gpios = <&gpio2 21 0>;
+			phy-reset-gpios = <&gpio2 21 GPIO_ACTIVE_LOW>;
 			phy-reset-duration = <100>;
 			status = "okay";
 		};
diff --git a/arch/arm/boot/dts/imx28-evk.dts b/arch/arm/boot/dts/imx28-evk.dts
index e3ef94ac..98b8eb3 100644
--- a/arch/arm/boot/dts/imx28-evk.dts
+++ b/arch/arm/boot/dts/imx28-evk.dts
@@ -262,7 +262,7 @@
 			pinctrl-names = "default";
 			pinctrl-0 = <&mac0_pins_a>;
 			phy-supply = <&reg_fec_3v3>;
-			phy-reset-gpios = <&gpio4 13 0>;
+			phy-reset-gpios = <&gpio4 13 GPIO_ACTIVE_LOW>;
 			phy-reset-duration = <100>;
 			status = "okay";
 		};
diff --git a/arch/arm/boot/dts/imx28-m28cu3.dts b/arch/arm/boot/dts/imx28-m28cu3.dts
index 2df63be..54cd558 100644
--- a/arch/arm/boot/dts/imx28-m28cu3.dts
+++ b/arch/arm/boot/dts/imx28-m28cu3.dts
@@ -188,7 +188,7 @@
 			phy-mode = "rmii";
 			pinctrl-names = "default";
 			pinctrl-0 = <&mac0_pins_a>;
-			phy-reset-gpios = <&gpio4 13 0>;
+			phy-reset-gpios = <&gpio4 13 GPIO_ACTIVE_LOW>;
 			phy-reset-duration = <100>;
 			status = "okay";
 		};
diff --git a/arch/arm/boot/dts/imx50-evk.dts b/arch/arm/boot/dts/imx50-evk.dts
index 27d763c..54d20e6 100644
--- a/arch/arm/boot/dts/imx50-evk.dts
+++ b/arch/arm/boot/dts/imx50-evk.dts
@@ -12,6 +12,7 @@
  */
 
 /dts-v1/;
+#include <dt-bindings/gpio/gpio.h>
 #include "imx50.dtsi"
 
 / {
@@ -54,7 +55,7 @@
 	pinctrl-names = "default";
 	pinctrl-0 = <&pinctrl_fec>;
 	phy-mode = "rmii";
-	phy-reset-gpios = <&gpio4 12 0>;
+	phy-reset-gpios = <&gpio4 12 GPIO_ACTIVE_LOW>;
 	status = "okay";
 };
 
diff --git a/arch/arm/boot/dts/imx53-mba53.dts b/arch/arm/boot/dts/imx53-mba53.dts
index 2e44d2a..df705ba 100644
--- a/arch/arm/boot/dts/imx53-mba53.dts
+++ b/arch/arm/boot/dts/imx53-mba53.dts
@@ -195,7 +195,7 @@
 };
 
 &fec {
-	phy-reset-gpios = <&gpio7 6 0>;
+	phy-reset-gpios = <&gpio7 6 GPIO_ACTIVE_LOW>;
 	status = "okay";
 };
 
diff --git a/arch/arm/boot/dts/imx53-qsb-common.dtsi b/arch/arm/boot/dts/imx53-qsb-common.dtsi
index c05e7cf..d0d273d 100644
--- a/arch/arm/boot/dts/imx53-qsb-common.dtsi
+++ b/arch/arm/boot/dts/imx53-qsb-common.dtsi
@@ -344,7 +344,7 @@
 	pinctrl-names = "default";
 	pinctrl-0 = <&pinctrl_fec>;
 	phy-mode = "rmii";
-	phy-reset-gpios = <&gpio7 6 0>;
+	phy-reset-gpios = <&gpio7 6 GPIO_ACTIVE_LOW>;
 	status = "okay";
 };
 
diff --git a/arch/arm/boot/dts/imx53-smd.dts b/arch/arm/boot/dts/imx53-smd.dts
index 542ab9e..9205e32 100644
--- a/arch/arm/boot/dts/imx53-smd.dts
+++ b/arch/arm/boot/dts/imx53-smd.dts
@@ -274,6 +274,6 @@
 	pinctrl-names = "default";
 	pinctrl-0 = <&pinctrl_fec>;
 	phy-mode = "rmii";
-	phy-reset-gpios = <&gpio7 6 0>;
+	phy-reset-gpios = <&gpio7 6 GPIO_ACTIVE_LOW>;
 	status = "okay";
 };
diff --git a/arch/arm/boot/dts/imx53-voipac-dmm-668.dtsi b/arch/arm/boot/dts/imx53-voipac-dmm-668.dtsi
index ba689fb..774f041 100644
--- a/arch/arm/boot/dts/imx53-voipac-dmm-668.dtsi
+++ b/arch/arm/boot/dts/imx53-voipac-dmm-668.dtsi
@@ -138,7 +138,7 @@
 	pinctrl-names = "default";
 	pinctrl-0 = <&pinctrl_fec>;
 	phy-mode = "rmii";
-	phy-reset-gpios = <&gpio4 2 0>;
+	phy-reset-gpios = <&gpio4 2 GPIO_ACTIVE_LOW>;
 	status = "okay";
 };
 
diff --git a/arch/arm/boot/dts/imx6dl-riotboard.dts b/arch/arm/boot/dts/imx6dl-riotboard.dts
index bfbed52..5ea616a 100644
--- a/arch/arm/boot/dts/imx6dl-riotboard.dts
+++ b/arch/arm/boot/dts/imx6dl-riotboard.dts
@@ -94,7 +94,7 @@
 	pinctrl-names = "default";
 	pinctrl-0 = <&pinctrl_enet>;
 	phy-mode = "rgmii";
-	phy-reset-gpios = <&gpio3 31 0>;
+	phy-reset-gpios = <&gpio3 31 GPIO_ACTIVE_LOW>;
 	interrupts-extended = <&gpio1 6 IRQ_TYPE_LEVEL_HIGH>,
 			      <&intc 0 119 IRQ_TYPE_LEVEL_HIGH>;
 	status = "okay";
diff --git a/arch/arm/boot/dts/imx6q-dmo-edmqmx6.dts b/arch/arm/boot/dts/imx6q-dmo-edmqmx6.dts
index 364578d..55b639f 100644
--- a/arch/arm/boot/dts/imx6q-dmo-edmqmx6.dts
+++ b/arch/arm/boot/dts/imx6q-dmo-edmqmx6.dts
@@ -119,7 +119,7 @@
 	pinctrl-names = "default";
 	pinctrl-0 = <&pinctrl_enet>;
 	phy-mode = "rgmii";
-	phy-reset-gpios = <&gpio1 25 0>;
+	phy-reset-gpios = <&gpio1 25 GPIO_ACTIVE_LOW>;
 	phy-supply = <&vgen2_1v2_eth>;
 	status = "okay";
 };
diff --git a/arch/arm/boot/dts/imx6q-evi.dts b/arch/arm/boot/dts/imx6q-evi.dts
index 4fa56019..a18f67f 100644
--- a/arch/arm/boot/dts/imx6q-evi.dts
+++ b/arch/arm/boot/dts/imx6q-evi.dts
@@ -138,7 +138,7 @@
 	pinctrl-names = "default";
 	pinctrl-0 = <&pinctrl_enet>;
 	phy-mode = "rgmii";
-	phy-reset-gpios = <&gpio1 25 0>;
+	phy-reset-gpios = <&gpio1 25 GPIO_ACTIVE_LOW>;
 	status = "okay";
 };
 
diff --git a/arch/arm/boot/dts/imx6qdl-microsom-ar8035.dtsi b/arch/arm/boot/dts/imx6qdl-microsom-ar8035.dtsi
index 469ef58..dbe3552 100644
--- a/arch/arm/boot/dts/imx6qdl-microsom-ar8035.dtsi
+++ b/arch/arm/boot/dts/imx6qdl-microsom-ar8035.dtsi
@@ -46,7 +46,7 @@
 	pinctrl-0 = <&pinctrl_microsom_enet_ar8035>;
 	phy-mode = "rgmii";
 	phy-reset-duration = <2>;
-	phy-reset-gpios = <&gpio4 15 0>;
+	phy-reset-gpios = <&gpio4 15 GPIO_ACTIVE_LOW>;
 	status = "okay";
 };
 
diff --git a/arch/arm/boot/dts/imx6qdl-nitrogen6x.dtsi b/arch/arm/boot/dts/imx6qdl-nitrogen6x.dtsi
index 73915db..b3853f4 100644
--- a/arch/arm/boot/dts/imx6qdl-nitrogen6x.dtsi
+++ b/arch/arm/boot/dts/imx6qdl-nitrogen6x.dtsi
@@ -272,7 +272,7 @@
 	pinctrl-names = "default";
 	pinctrl-0 = <&pinctrl_enet>;
 	phy-mode = "rgmii";
-	phy-reset-gpios = <&gpio1 27 0>;
+	phy-reset-gpios = <&gpio1 27 GPIO_ACTIVE_LOW>;
 	txen-skew-ps = <0>;
 	txc-skew-ps = <3000>;
 	rxdv-skew-ps = <0>;
diff --git a/arch/arm/boot/dts/imx6qdl-sabresd.dtsi b/arch/arm/boot/dts/imx6qdl-sabresd.dtsi
index 5248e7bd..0834e31 100644
--- a/arch/arm/boot/dts/imx6qdl-sabresd.dtsi
+++ b/arch/arm/boot/dts/imx6qdl-sabresd.dtsi
@@ -179,7 +179,7 @@
 	pinctrl-names = "default";
 	pinctrl-0 = <&pinctrl_enet>;
 	phy-mode = "rgmii";
-	phy-reset-gpios = <&gpio1 25 0>;
+	phy-reset-gpios = <&gpio1 25 GPIO_ACTIVE_LOW>;
 	status = "okay";
 };
 
diff --git a/arch/arm/boot/dts/imx6qdl-wandboard.dtsi b/arch/arm/boot/dts/imx6qdl-wandboard.dtsi
index 8e7c40e..1855799 100644
--- a/arch/arm/boot/dts/imx6qdl-wandboard.dtsi
+++ b/arch/arm/boot/dts/imx6qdl-wandboard.dtsi
@@ -208,7 +208,7 @@
 	pinctrl-names = "default";
 	pinctrl-0 = <&pinctrl_enet>;
 	phy-mode = "rgmii";
-	phy-reset-gpios = <&gpio3 29 0>;
+	phy-reset-gpios = <&gpio3 29 GPIO_ACTIVE_LOW>;
 	interrupts-extended = <&gpio1 6 IRQ_TYPE_LEVEL_HIGH>,
 			      <&intc 0 119 IRQ_TYPE_LEVEL_HIGH>;
 	status = "okay";
diff --git a/drivers/net/ethernet/freescale/fec_main.c b/drivers/net/ethernet/freescale/fec_main.c
index ca2cccc..f08b922 100644
--- a/drivers/net/ethernet/freescale/fec_main.c
+++ b/drivers/net/ethernet/freescale/fec_main.c
@@ -3167,8 +3167,7 @@ static int fec_enet_init(struct net_device *ndev)
 #ifdef CONFIG_OF
 static void fec_reset_phy(struct platform_device *pdev)
 {
-	int err, phy_reset;
-	bool active_high = false;
+	struct gpio_desc *phy_reset;
 	int msec = 1;
 	struct device_node *np = pdev->dev.of_node;
 
@@ -3180,21 +3179,13 @@ static void fec_reset_phy(struct platform_device *pdev)
 	if (msec > 1000)
 		msec = 1;
 
-	phy_reset = of_get_named_gpio(np, "phy-reset-gpios", 0);
-	if (!gpio_is_valid(phy_reset))
+	phy_reset = devm_gpiod_get_optional(&pdev->dev, "phy-reset",
+					    GPIOD_OUT_HIGH);
+	if (IS_ERR(phy_reset))
 		return;
 
-	active_high = of_property_read_bool(np, "phy-reset-active-high");
-
-	err = devm_gpio_request_one(&pdev->dev, phy_reset,
-			active_high ? GPIOF_OUT_INIT_HIGH : GPIOF_OUT_INIT_LOW,
-			"phy-reset");
-	if (err) {
-		dev_err(&pdev->dev, "failed to get phy-reset-gpios: %d\n", err);
-		return;
-	}
 	msleep(msec);
-	gpio_set_value_cansleep(phy_reset, !active_high);
+	gpiod_set_value(phy_reset, 0);
 }
 #else /* CONFIG_OF */
 static void fec_reset_phy(struct platform_device *pdev)
-- 
1.9.3

