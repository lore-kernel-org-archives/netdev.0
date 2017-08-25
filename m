From: Maxime Ripard <maxime.ripard@free-electrons.com>
Subject: [PATCH 2/4] arm64: dts: allwinner: Revert EMAC changes
Date: Fri, 25 Aug 2017 21:12:15 +0200
Message-ID: <20170825191217.10278-3-maxime.ripard@free-electrons.com>
References: <20170825191217.10278-1-maxime.ripard@free-electrons.com>
Cc: linux-arm-kernel@lists.infradead.org, netdev@vger.kernel.org,
        f.fainelli@gmail.com, clabbe.montjoie@gmail.com, andrew@lunn.ch,
        linux-kernel@vger.kernel.org
To: arm@kernel.org, davem@davemloft.net, Chen-Yu Tsai <wens@csie.org>,
        Maxime Ripard <maxime.ripard@free-electrons.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20170825191217.10278-1-maxime.ripard@free-electrons.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Since the discussion is not settled yet for the EMAC, and that the release
in getting really close, let's revert the changes for now, and we'll
reintroduce them later.

Signed-off-by: Maxime Ripard <maxime.ripard@free-electrons.com>
---
 .../boot/dts/allwinner/sun50i-a64-bananapi-m64.dts   | 17 -----------------
 .../boot/dts/allwinner/sun50i-a64-pine64-plus.dts    | 15 ---------------
 arch/arm64/boot/dts/allwinner/sun50i-a64-pine64.dts  | 18 ------------------
 .../dts/allwinner/sun50i-a64-sopine-baseboard.dts    | 17 -----------------
 arch/arm64/boot/dts/allwinner/sun50i-a64.dtsi        | 20 --------------------
 .../boot/dts/allwinner/sun50i-h5-nanopi-neo2.dts     | 17 -----------------
 .../boot/dts/allwinner/sun50i-h5-orangepi-pc2.dts    | 17 -----------------
 .../boot/dts/allwinner/sun50i-h5-orangepi-prime.dts  | 17 -----------------
 8 files changed, 138 deletions(-)

diff --git a/arch/arm64/boot/dts/allwinner/sun50i-a64-bananapi-m64.dts b/arch/arm64/boot/dts/allwinner/sun50i-a64-bananapi-m64.dts
index 4a8d3f83a36e..d347f52e27f6 100644
--- a/arch/arm64/boot/dts/allwinner/sun50i-a64-bananapi-m64.dts
+++ b/arch/arm64/boot/dts/allwinner/sun50i-a64-bananapi-m64.dts
@@ -51,7 +51,6 @@
 	compatible = "sinovoip,bananapi-m64", "allwinner,sun50i-a64";
 
 	aliases {
-		ethernet0 = &emac;
 		serial0 = &uart0;
 		serial1 = &uart1;
 	};
@@ -70,15 +69,6 @@
 	status = "okay";
 };
 
-&emac {
-	pinctrl-names = "default";
-	pinctrl-0 = <&rgmii_pins>;
-	phy-mode = "rgmii";
-	phy-handle = <&ext_rgmii_phy>;
-	phy-supply = <&reg_dc1sw>;
-	status = "okay";
-};
-
 &i2c1 {
 	pinctrl-names = "default";
 	pinctrl-0 = <&i2c1_pins>;
@@ -89,13 +79,6 @@
 	bias-pull-up;
 };
 
-&mdio {
-	ext_rgmii_phy: ethernet-phy@1 {
-		compatible = "ethernet-phy-ieee802.3-c22";
-		reg = <1>;
-	};
-};
-
 &mmc0 {
 	pinctrl-names = "default";
 	pinctrl-0 = <&mmc0_pins>;
diff --git a/arch/arm64/boot/dts/allwinner/sun50i-a64-pine64-plus.dts b/arch/arm64/boot/dts/allwinner/sun50i-a64-pine64-plus.dts
index 24f1aac366d6..f82ccf332c0f 100644
--- a/arch/arm64/boot/dts/allwinner/sun50i-a64-pine64-plus.dts
+++ b/arch/arm64/boot/dts/allwinner/sun50i-a64-pine64-plus.dts
@@ -48,18 +48,3 @@
 
 	/* TODO: Camera, touchscreen, etc. */
 };
-
-&emac {
-	pinctrl-names = "default";
-	pinctrl-0 = <&rgmii_pins>;
-	phy-mode = "rgmii";
-	phy-handle = <&ext_rgmii_phy>;
-	status = "okay";
-};
-
-&mdio {
-	ext_rgmii_phy: ethernet-phy@1 {
-		compatible = "ethernet-phy-ieee802.3-c22";
-		reg = <1>;
-	};
-};
diff --git a/arch/arm64/boot/dts/allwinner/sun50i-a64-pine64.dts b/arch/arm64/boot/dts/allwinner/sun50i-a64-pine64.dts
index 122b5d8e5438..caf8b6fbe5e3 100644
--- a/arch/arm64/boot/dts/allwinner/sun50i-a64-pine64.dts
+++ b/arch/arm64/boot/dts/allwinner/sun50i-a64-pine64.dts
@@ -51,7 +51,6 @@
 	compatible = "pine64,pine64", "allwinner,sun50i-a64";
 
 	aliases {
-		ethernet0 = &emac;
 		serial0 = &uart0;
 		serial1 = &uart1;
 		serial2 = &uart2;
@@ -79,16 +78,6 @@
 	status = "okay";
 };
 
-&emac {
-	pinctrl-names = "default";
-	pinctrl-0 = <&rmii_pins>;
-	phy-mode = "rmii";
-	phy-handle = <&ext_rmii_phy1>;
-	phy-supply = <&reg_dc1sw>;
-	status = "okay";
-
-};
-
 &i2c1 {
 	pinctrl-names = "default";
 	pinctrl-0 = <&i2c1_pins>;
@@ -99,13 +88,6 @@
 	bias-pull-up;
 };
 
-&mdio {
-	ext_rmii_phy1: ethernet-phy@1 {
-		compatible = "ethernet-phy-ieee802.3-c22";
-		reg = <1>;
-	};
-};
-
 &mmc0 {
 	pinctrl-names = "default";
 	pinctrl-0 = <&mmc0_pins>;
diff --git a/arch/arm64/boot/dts/allwinner/sun50i-a64-sopine-baseboard.dts b/arch/arm64/boot/dts/allwinner/sun50i-a64-sopine-baseboard.dts
index a053a6ac5267..17ccc12b58df 100644
--- a/arch/arm64/boot/dts/allwinner/sun50i-a64-sopine-baseboard.dts
+++ b/arch/arm64/boot/dts/allwinner/sun50i-a64-sopine-baseboard.dts
@@ -53,7 +53,6 @@
 		     "allwinner,sun50i-a64";
 
 	aliases {
-		ethernet0 = &emac;
 		serial0 = &uart0;
 	};
 
@@ -77,22 +76,6 @@
 	status = "okay";
 };
 
-&emac {
-	pinctrl-names = "default";
-	pinctrl-0 = <&rgmii_pins>;
-	phy-mode = "rgmii";
-	phy-handle = <&ext_rgmii_phy>;
-	phy-supply = <&reg_dc1sw>;
-	status = "okay";
-};
-
-&mdio {
-	ext_rgmii_phy: ethernet-phy@1 {
-		compatible = "ethernet-phy-ieee802.3-c22";
-		reg = <1>;
-	};
-};
-
 &mmc2 {
 	pinctrl-names = "default";
 	pinctrl-0 = <&mmc2_pins>;
diff --git a/arch/arm64/boot/dts/allwinner/sun50i-a64.dtsi b/arch/arm64/boot/dts/allwinner/sun50i-a64.dtsi
index 50f17bab0c07..8c8db1b057df 100644
--- a/arch/arm64/boot/dts/allwinner/sun50i-a64.dtsi
+++ b/arch/arm64/boot/dts/allwinner/sun50i-a64.dtsi
@@ -449,26 +449,6 @@
 			#size-cells = <0>;
 		};
 
-		emac: ethernet@1c30000 {
-			compatible = "allwinner,sun50i-a64-emac";
-			syscon = <&syscon>;
-			reg = <0x01c30000 0x10000>;
-			interrupts = <GIC_SPI 82 IRQ_TYPE_LEVEL_HIGH>;
-			interrupt-names = "macirq";
-			resets = <&ccu RST_BUS_EMAC>;
-			reset-names = "stmmaceth";
-			clocks = <&ccu CLK_BUS_EMAC>;
-			clock-names = "stmmaceth";
-			status = "disabled";
-			#address-cells = <1>;
-			#size-cells = <0>;
-
-			mdio: mdio {
-				#address-cells = <1>;
-				#size-cells = <0>;
-			};
-		};
-
 		gic: interrupt-controller@1c81000 {
 			compatible = "arm,gic-400";
 			reg = <0x01c81000 0x1000>,
diff --git a/arch/arm64/boot/dts/allwinner/sun50i-h5-nanopi-neo2.dts b/arch/arm64/boot/dts/allwinner/sun50i-h5-nanopi-neo2.dts
index 968908761194..1c2387bd5df6 100644
--- a/arch/arm64/boot/dts/allwinner/sun50i-h5-nanopi-neo2.dts
+++ b/arch/arm64/boot/dts/allwinner/sun50i-h5-nanopi-neo2.dts
@@ -50,7 +50,6 @@
 	compatible = "friendlyarm,nanopi-neo2", "allwinner,sun50i-h5";
 
 	aliases {
-		ethernet0 = &emac;
 		serial0 = &uart0;
 	};
 
@@ -109,22 +108,6 @@
 	status = "okay";
 };
 
-&emac {
-	pinctrl-names = "default";
-	pinctrl-0 = <&emac_rgmii_pins>;
-	phy-supply = <&reg_gmac_3v3>;
-	phy-handle = <&ext_rgmii_phy>;
-	phy-mode = "rgmii";
-	status = "okay";
-};
-
-&mdio {
-	ext_rgmii_phy: ethernet-phy@7 {
-		compatible = "ethernet-phy-ieee802.3-c22";
-		reg = <7>;
-	};
-};
-
 &mmc0 {
 	pinctrl-names = "default";
 	pinctrl-0 = <&mmc0_pins_a>, <&mmc0_cd_pin>;
diff --git a/arch/arm64/boot/dts/allwinner/sun50i-h5-orangepi-pc2.dts b/arch/arm64/boot/dts/allwinner/sun50i-h5-orangepi-pc2.dts
index a8296feee884..4f77c8470f6c 100644
--- a/arch/arm64/boot/dts/allwinner/sun50i-h5-orangepi-pc2.dts
+++ b/arch/arm64/boot/dts/allwinner/sun50i-h5-orangepi-pc2.dts
@@ -59,7 +59,6 @@
 	};
 
 	aliases {
-		ethernet0 = &emac;
 		serial0 = &uart0;
 	};
 
@@ -137,28 +136,12 @@
 	status = "okay";
 };
 
-&emac {
-	pinctrl-names = "default";
-	pinctrl-0 = <&emac_rgmii_pins>;
-	phy-supply = <&reg_gmac_3v3>;
-	phy-handle = <&ext_rgmii_phy>;
-	phy-mode = "rgmii";
-	status = "okay";
-};
-
 &ir {
 	pinctrl-names = "default";
 	pinctrl-0 = <&ir_pins_a>;
 	status = "okay";
 };
 
-&mdio {
-	ext_rgmii_phy: ethernet-phy@1 {
-		compatible = "ethernet-phy-ieee802.3-c22";
-		reg = <1>;
-	};
-};
-
 &mmc0 {
 	pinctrl-names = "default";
 	pinctrl-0 = <&mmc0_pins_a>, <&mmc0_cd_pin>;
diff --git a/arch/arm64/boot/dts/allwinner/sun50i-h5-orangepi-prime.dts b/arch/arm64/boot/dts/allwinner/sun50i-h5-orangepi-prime.dts
index d906b302cbcd..6be06873e5af 100644
--- a/arch/arm64/boot/dts/allwinner/sun50i-h5-orangepi-prime.dts
+++ b/arch/arm64/boot/dts/allwinner/sun50i-h5-orangepi-prime.dts
@@ -54,7 +54,6 @@
 	compatible = "xunlong,orangepi-prime", "allwinner,sun50i-h5";
 
 	aliases {
-		ethernet0 = &emac;
 		serial0 = &uart0;
 	};
 
@@ -144,28 +143,12 @@
 	status = "okay";
 };
 
-&emac {
-	pinctrl-names = "default";
-	pinctrl-0 = <&emac_rgmii_pins>;
-	phy-supply = <&reg_gmac_3v3>;
-	phy-handle = <&ext_rgmii_phy>;
-	phy-mode = "rgmii";
-	status = "okay";
-};
-
 &ir {
 	pinctrl-names = "default";
 	pinctrl-0 = <&ir_pins_a>;
 	status = "okay";
 };
 
-&mdio {
-	ext_rgmii_phy: ethernet-phy@1 {
-		compatible = "ethernet-phy-ieee802.3-c22";
-		reg = <1>;
-	};
-};
-
 &mmc0 {
 	pinctrl-names = "default";
 	pinctrl-0 = <&mmc0_pins_a>, <&mmc0_cd_pin>;
-- 
2.13.5
