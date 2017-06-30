From: Maxime Ripard <maxime.ripard@free-electrons.com>
Subject: [PATCH] arm: sunxi: Revert changes merged through net-next.
Date: Fri, 30 Jun 2017 09:46:17 +0200
Message-ID: <20170630074617.20288-1-maxime.ripard@free-electrons.com>
Cc: Chen-Yu Tsai <wens@csie.org>,
        Maxime Ripard <maxime.ripard@free-electrons.com>,
        clabbe.montjoie@gmail.com, netdev@vger.kernel.org,
        linux-arm-kernel@lists.infradead.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.free-electrons.com ([62.4.15.54]:56772 "EHLO
        mail.free-electrons.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751494AbdF3Hqf (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 30 Jun 2017 03:46:35 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This reverts commits 2c0cba482e79 ("arm: sun8i: sunxi-h3-h5: Add dt node
for the syscon control module") to 2428fd0fe550 ("arm64: defconfig: Enable
dwmac-sun8i driver on defconfig") and 3432a86e641c ("arm: sun8i:
orangepipc: use internal phy-mode") to 5a79b4f2a5e7 ("arm: sun8i:
orangepi-2: use internal phy-mode") that should be merged
through the arm-soc tree, and end up in merge conflicts and build failures.

Signed-off-by: Maxime Ripard <maxime.ripard@free-electrons.com>
---
 arch/arm/boot/dts/sun8i-h2-plus-orangepi-zero.dts  |  8 -----
 arch/arm/boot/dts/sun8i-h3-nanopi-neo.dts          |  7 ----
 arch/arm/boot/dts/sun8i-h3-orangepi-2.dts          |  8 -----
 arch/arm/boot/dts/sun8i-h3-orangepi-one.dts        |  8 -----
 arch/arm/boot/dts/sun8i-h3-orangepi-pc-plus.dts    |  5 ---
 arch/arm/boot/dts/sun8i-h3-orangepi-pc.dts         |  8 -----
 arch/arm/boot/dts/sunxi-h3-h5.dtsi                 | 40 ---------------------
 arch/arm/configs/multi_v7_defconfig                |  1 -
 arch/arm/configs/sunxi_defconfig                   |  1 -
 .../boot/dts/allwinner/sun50i-a64-bananapi-m64.dts | 15 --------
 .../boot/dts/allwinner/sun50i-a64-pine64-plus.dts  | 17 +--------
 .../arm64/boot/dts/allwinner/sun50i-a64-pine64.dts | 16 ---------
 arch/arm64/boot/dts/allwinner/sun50i-a64.dtsi      | 41 ----------------------
 arch/arm64/configs/defconfig                       |  1 -
 14 files changed, 1 insertion(+), 175 deletions(-)

diff --git a/arch/arm/boot/dts/sun8i-h2-plus-orangepi-zero.dts b/arch/arm/boot/dts/sun8i-h2-plus-orangepi-zero.dts
index 9bd9a0e90034..9e8b082c134f 100644
--- a/arch/arm/boot/dts/sun8i-h2-plus-orangepi-zero.dts
+++ b/arch/arm/boot/dts/sun8i-h2-plus-orangepi-zero.dts
@@ -57,7 +57,6 @@
 	aliases {
 		serial0 = &uart0;
 		/* ethernet0 is the H3 emac, defined in sun8i-h3.dtsi */
-		ethernet0 = &emac;
 		ethernet1 = &xr819;
 	};
 
@@ -104,13 +103,6 @@
 	status = "okay";
 };
 
-&emac {
-	phy-handle = <&int_mii_phy>;
-	phy-mode = "internal";
-	allwinner,leds-active-low;
-	status = "okay";
-};
-
 &mmc0 {
 	pinctrl-names = "default";
 	pinctrl-0 = <&mmc0_pins_a>;
diff --git a/arch/arm/boot/dts/sun8i-h3-nanopi-neo.dts b/arch/arm/boot/dts/sun8i-h3-nanopi-neo.dts
index 5c5ba806e2f1..8d2cc6e9a03f 100644
--- a/arch/arm/boot/dts/sun8i-h3-nanopi-neo.dts
+++ b/arch/arm/boot/dts/sun8i-h3-nanopi-neo.dts
@@ -46,10 +46,3 @@
 	model = "FriendlyARM NanoPi NEO";
 	compatible = "friendlyarm,nanopi-neo", "allwinner,sun8i-h3";
 };
-
-&emac {
-	phy-handle = <&int_mii_phy>;
-	phy-mode = "internal";
-	allwinner,leds-active-low;
-	status = "okay";
-};
diff --git a/arch/arm/boot/dts/sun8i-h3-orangepi-2.dts b/arch/arm/boot/dts/sun8i-h3-orangepi-2.dts
index 77c861deb658..5b6d14555b7c 100644
--- a/arch/arm/boot/dts/sun8i-h3-orangepi-2.dts
+++ b/arch/arm/boot/dts/sun8i-h3-orangepi-2.dts
@@ -54,7 +54,6 @@
 	aliases {
 		serial0 = &uart0;
 		/* ethernet0 is the H3 emac, defined in sun8i-h3.dtsi */
-		ethernet0 = &emac;
 		ethernet1 = &rtl8189;
 	};
 
@@ -109,13 +108,6 @@
 	status = "okay";
 };
 
-&emac {
-	phy-handle = <&int_mii_phy>;
-	phy-mode = "internal";
-	allwinner,leds-active-low;
-	status = "okay";
-};
-
 &ir {
 	pinctrl-names = "default";
 	pinctrl-0 = <&ir_pins_a>;
diff --git a/arch/arm/boot/dts/sun8i-h3-orangepi-one.dts b/arch/arm/boot/dts/sun8i-h3-orangepi-one.dts
index 27e7ef4e42f2..5fea430e0eb1 100644
--- a/arch/arm/boot/dts/sun8i-h3-orangepi-one.dts
+++ b/arch/arm/boot/dts/sun8i-h3-orangepi-one.dts
@@ -52,7 +52,6 @@
 	compatible = "xunlong,orangepi-one", "allwinner,sun8i-h3";
 
 	aliases {
-		ethernet0 = &emac;
 		serial0 = &uart0;
 	};
 
@@ -98,13 +97,6 @@
 	status = "okay";
 };
 
-&emac {
-	phy-handle = <&int_mii_phy>;
-	phy-mode = "internal";
-	allwinner,leds-active-low;
-	status = "okay";
-};
-
 &mmc0 {
 	pinctrl-names = "default";
 	pinctrl-0 = <&mmc0_pins_a>, <&mmc0_cd_pin>;
diff --git a/arch/arm/boot/dts/sun8i-h3-orangepi-pc-plus.dts b/arch/arm/boot/dts/sun8i-h3-orangepi-pc-plus.dts
index a10281b455f5..8b93f5c781a7 100644
--- a/arch/arm/boot/dts/sun8i-h3-orangepi-pc-plus.dts
+++ b/arch/arm/boot/dts/sun8i-h3-orangepi-pc-plus.dts
@@ -53,11 +53,6 @@
 	};
 };
 
-&emac {
-	/* LEDs changed to active high on the plus */
-	/delete-property/ allwinner,leds-active-low;
-};
-
 &mmc1 {
 	pinctrl-names = "default";
 	pinctrl-0 = <&mmc1_pins_a>;
diff --git a/arch/arm/boot/dts/sun8i-h3-orangepi-pc.dts b/arch/arm/boot/dts/sun8i-h3-orangepi-pc.dts
index fecebb43506a..f148111c326d 100644
--- a/arch/arm/boot/dts/sun8i-h3-orangepi-pc.dts
+++ b/arch/arm/boot/dts/sun8i-h3-orangepi-pc.dts
@@ -52,7 +52,6 @@
 	compatible = "xunlong,orangepi-pc", "allwinner,sun8i-h3";
 
 	aliases {
-		ethernet0 = &emac;
 		serial0 = &uart0;
 	};
 
@@ -110,13 +109,6 @@
 	status = "okay";
 };
 
-&emac {
-	phy-handle = <&int_mii_phy>;
-	phy-mode = "internal";
-	allwinner,leds-active-low;
-	status = "okay";
-};
-
 &ir {
 	pinctrl-names = "default";
 	pinctrl-0 = <&ir_pins_a>;
diff --git a/arch/arm/boot/dts/sunxi-h3-h5.dtsi b/arch/arm/boot/dts/sunxi-h3-h5.dtsi
index a6d4fda544e1..d4f600dbb7eb 100644
--- a/arch/arm/boot/dts/sunxi-h3-h5.dtsi
+++ b/arch/arm/boot/dts/sunxi-h3-h5.dtsi
@@ -83,12 +83,6 @@
 		#size-cells = <1>;
 		ranges;
 
-		syscon: syscon@1c00000 {
-			compatible = "allwinner,sun8i-h3-system-controller",
-				"syscon";
-			reg = <0x01c00000 0x1000>;
-		};
-
 		dma: dma-controller@01c02000 {
 			compatible = "allwinner,sun8i-h3-dma";
 			reg = <0x01c02000 0x1000>;
@@ -285,14 +279,6 @@
 			interrupt-controller;
 			#interrupt-cells = <3>;
 
-			emac_rgmii_pins: emac0 {
-				pins = "PD0", "PD1", "PD2", "PD3", "PD4",
-				       "PD5", "PD7", "PD8", "PD9", "PD10",
-				       "PD12", "PD13", "PD15", "PD16", "PD17";
-				function = "emac";
-				drive-strength = <40>;
-			};
-
 			i2c0_pins: i2c0 {
 				pins = "PA11", "PA12";
 				function = "i2c0";
@@ -389,32 +375,6 @@
 			clocks = <&osc24M>;
 		};
 
-		emac: ethernet@1c30000 {
-			compatible = "allwinner,sun8i-h3-emac";
-			syscon = <&syscon>;
-			reg = <0x01c30000 0x104>;
-			interrupts = <GIC_SPI 82 IRQ_TYPE_LEVEL_HIGH>;
-			interrupt-names = "macirq";
-			resets = <&ccu RST_BUS_EMAC>;
-			reset-names = "stmmaceth";
-			clocks = <&ccu CLK_BUS_EMAC>;
-			clock-names = "stmmaceth";
-			#address-cells = <1>;
-			#size-cells = <0>;
-			status = "disabled";
-
-			mdio: mdio {
-				#address-cells = <1>;
-				#size-cells = <0>;
-				int_mii_phy: ethernet-phy@1 {
-					compatible = "ethernet-phy-ieee802.3-c22";
-					reg = <1>;
-					clocks = <&ccu CLK_BUS_EPHY>;
-					resets = <&ccu RST_BUS_EPHY>;
-				};
-			};
-		};
-
 		spi0: spi@01c68000 {
 			compatible = "allwinner,sun8i-h3-spi";
 			reg = <0x01c68000 0x1000>;
diff --git a/arch/arm/configs/multi_v7_defconfig b/arch/arm/configs/multi_v7_defconfig
index 6da6af8881f7..2685e03600b1 100644
--- a/arch/arm/configs/multi_v7_defconfig
+++ b/arch/arm/configs/multi_v7_defconfig
@@ -257,7 +257,6 @@ CONFIG_SMSC911X=y
 CONFIG_STMMAC_ETH=y
 CONFIG_STMMAC_PLATFORM=y
 CONFIG_DWMAC_DWC_QOS_ETH=y
-CONFIG_DWMAC_SUN8I=y
 CONFIG_TI_CPSW=y
 CONFIG_XILINX_EMACLITE=y
 CONFIG_AT803X_PHY=y
diff --git a/arch/arm/configs/sunxi_defconfig b/arch/arm/configs/sunxi_defconfig
index 504e02238031..5cd5dd70bc83 100644
--- a/arch/arm/configs/sunxi_defconfig
+++ b/arch/arm/configs/sunxi_defconfig
@@ -40,7 +40,6 @@ CONFIG_ATA=y
 CONFIG_AHCI_SUNXI=y
 CONFIG_NETDEVICES=y
 CONFIG_SUN4I_EMAC=y
-CONFIG_DWMAC_SUN8I=y
 # CONFIG_NET_VENDOR_ARC is not set
 # CONFIG_NET_CADENCE is not set
 # CONFIG_NET_VENDOR_BROADCOM is not set
diff --git a/arch/arm64/boot/dts/allwinner/sun50i-a64-bananapi-m64.dts b/arch/arm64/boot/dts/allwinner/sun50i-a64-bananapi-m64.dts
index 0d1f026d831a..6872135d7f84 100644
--- a/arch/arm64/boot/dts/allwinner/sun50i-a64-bananapi-m64.dts
+++ b/arch/arm64/boot/dts/allwinner/sun50i-a64-bananapi-m64.dts
@@ -67,14 +67,6 @@
 	};
 };
 
-&emac {
-	pinctrl-names = "default";
-	pinctrl-0 = <&rgmii_pins>;
-	phy-mode = "rgmii";
-	phy-handle = <&ext_rgmii_phy>;
-	status = "okay";
-};
-
 &i2c1 {
 	pinctrl-names = "default";
 	pinctrl-0 = <&i2c1_pins>;
@@ -85,13 +77,6 @@
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
index 24f1aac366d6..790d14daaa6a 100644
--- a/arch/arm64/boot/dts/allwinner/sun50i-a64-pine64-plus.dts
+++ b/arch/arm64/boot/dts/allwinner/sun50i-a64-pine64-plus.dts
@@ -46,20 +46,5 @@
 	model = "Pine64+";
 	compatible = "pine64,pine64-plus", "allwinner,sun50i-a64";
 
-	/* TODO: Camera, touchscreen, etc. */
-};
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
+	/* TODO: Camera, Ethernet PHY, touchscreen, etc. */
 };
diff --git a/arch/arm64/boot/dts/allwinner/sun50i-a64-pine64.dts b/arch/arm64/boot/dts/allwinner/sun50i-a64-pine64.dts
index 3b491c0e3b0d..c680ed385da3 100644
--- a/arch/arm64/boot/dts/allwinner/sun50i-a64-pine64.dts
+++ b/arch/arm64/boot/dts/allwinner/sun50i-a64-pine64.dts
@@ -70,15 +70,6 @@
 	status = "okay";
 };
 
-&emac {
-	pinctrl-names = "default";
-	pinctrl-0 = <&rmii_pins>;
-	phy-mode = "rmii";
-	phy-handle = <&ext_rmii_phy1>;
-	status = "okay";
-
-};
-
 &i2c1 {
 	pinctrl-names = "default";
 	pinctrl-0 = <&i2c1_pins>;
@@ -89,13 +80,6 @@
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
diff --git a/arch/arm64/boot/dts/allwinner/sun50i-a64.dtsi b/arch/arm64/boot/dts/allwinner/sun50i-a64.dtsi
index 769ced01a998..166c9ef884dc 100644
--- a/arch/arm64/boot/dts/allwinner/sun50i-a64.dtsi
+++ b/arch/arm64/boot/dts/allwinner/sun50i-a64.dtsi
@@ -129,12 +129,6 @@
 		#size-cells = <1>;
 		ranges;
 
-		syscon: syscon@1c00000 {
-			compatible = "allwinner,sun50i-a64-system-controller",
-				"syscon";
-			reg = <0x01c00000 0x1000>;
-		};
-
 		mmc0: mmc@1c0f000 {
 			compatible = "allwinner,sun50i-a64-mmc";
 			reg = <0x01c0f000 0x1000>;
@@ -287,21 +281,6 @@
 				bias-pull-up;
 			};
 
-			rmii_pins: rmii_pins {
-				pins = "PD10", "PD11", "PD13", "PD14", "PD17",
-				       "PD18", "PD19", "PD20", "PD22", "PD23";
-				function = "emac";
-				drive-strength = <40>;
-			};
-
-			rgmii_pins: rgmii_pins {
-				pins = "PD8", "PD9", "PD10", "PD11", "PD12",
-				       "PD13", "PD15", "PD16", "PD17", "PD18",
-				       "PD19", "PD20", "PD21", "PD22", "PD23";
-				function = "emac";
-				drive-strength = <40>;
-			};
-
 			uart0_pins_a: uart0@0 {
 				pins = "PB8", "PB9";
 				function = "uart0";
@@ -406,26 +385,6 @@
 			#size-cells = <0>;
 		};
 
-		emac: ethernet@1c30000 {
-			compatible = "allwinner,sun50i-a64-emac";
-			syscon = <&syscon>;
-			reg = <0x01c30000 0x100>;
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
diff --git a/arch/arm64/configs/defconfig b/arch/arm64/configs/defconfig
index d789858c4f1b..97c123e09e45 100644
--- a/arch/arm64/configs/defconfig
+++ b/arch/arm64/configs/defconfig
@@ -191,7 +191,6 @@ CONFIG_RAVB=y
 CONFIG_SMC91X=y
 CONFIG_SMSC911X=y
 CONFIG_STMMAC_ETH=m
-CONFIG_DWMAC_SUN8I=m
 CONFIG_MDIO_BUS_MUX_MMIOREG=y
 CONFIG_MESON_GXL_PHY=m
 CONFIG_MICREL_PHY=y
-- 
2.9.4
