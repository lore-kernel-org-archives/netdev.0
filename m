From: Maxime Ripard <maxime.ripard@free-electrons.com>
Subject: [PATCH 3/4] arm: dts: sunxi: Revert EMAC changes
Date: Fri, 25 Aug 2017 21:12:16 +0200
Message-ID: <20170825191217.10278-4-maxime.ripard@free-electrons.com>
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
 arch/arm/boot/dts/sun8i-h2-plus-orangepi-zero.dts |  9 --------
 arch/arm/boot/dts/sun8i-h3-bananapi-m2-plus.dts   | 19 -----------------
 arch/arm/boot/dts/sun8i-h3-beelink-x2.dts         |  8 -------
 arch/arm/boot/dts/sun8i-h3-nanopi-neo.dts         |  7 ------
 arch/arm/boot/dts/sun8i-h3-orangepi-2.dts         |  8 -------
 arch/arm/boot/dts/sun8i-h3-orangepi-one.dts       |  8 -------
 arch/arm/boot/dts/sun8i-h3-orangepi-pc-plus.dts   |  5 -----
 arch/arm/boot/dts/sun8i-h3-orangepi-pc.dts        |  8 -------
 arch/arm/boot/dts/sun8i-h3-orangepi-plus.dts      | 22 -------------------
 arch/arm/boot/dts/sun8i-h3-orangepi-plus2e.dts    | 16 --------------
 arch/arm/boot/dts/sunxi-h3-h5.dtsi                | 26 -----------------------
 11 files changed, 136 deletions(-)

diff --git a/arch/arm/boot/dts/sun8i-h2-plus-orangepi-zero.dts b/arch/arm/boot/dts/sun8i-h2-plus-orangepi-zero.dts
index 6713d0f2b3f4..b1502df7b509 100644
--- a/arch/arm/boot/dts/sun8i-h2-plus-orangepi-zero.dts
+++ b/arch/arm/boot/dts/sun8i-h2-plus-orangepi-zero.dts
@@ -56,8 +56,6 @@
 
 	aliases {
 		serial0 = &uart0;
-		/* ethernet0 is the H3 emac, defined in sun8i-h3.dtsi */
-		ethernet0 = &emac;
 		ethernet1 = &xr819;
 	};
 
@@ -104,13 +102,6 @@
 	status = "okay";
 };
 
-&emac {
-	phy-handle = <&int_mii_phy>;
-	phy-mode = "mii";
-	allwinner,leds-active-low;
-	status = "okay";
-};
-
 &mmc0 {
 	pinctrl-names = "default";
 	pinctrl-0 = <&mmc0_pins_a>;
diff --git a/arch/arm/boot/dts/sun8i-h3-bananapi-m2-plus.dts b/arch/arm/boot/dts/sun8i-h3-bananapi-m2-plus.dts
index d756ff825116..a337af1de322 100644
--- a/arch/arm/boot/dts/sun8i-h3-bananapi-m2-plus.dts
+++ b/arch/arm/boot/dts/sun8i-h3-bananapi-m2-plus.dts
@@ -52,7 +52,6 @@
 	compatible = "sinovoip,bpi-m2-plus", "allwinner,sun8i-h3";
 
 	aliases {
-		ethernet0 = &emac;
 		serial0 = &uart0;
 		serial1 = &uart1;
 	};
@@ -115,30 +114,12 @@
 	status = "okay";
 };
 
-&emac {
-	pinctrl-names = "default";
-	pinctrl-0 = <&emac_rgmii_pins>;
-	phy-supply = <&reg_gmac_3v3>;
-	phy-handle = <&ext_rgmii_phy>;
-	phy-mode = "rgmii";
-
-	allwinner,leds-active-low;
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
-		reg = <0>;
-	};
-};
-
 &mmc0 {
 	pinctrl-names = "default";
 	pinctrl-0 = <&mmc0_pins_a>, <&mmc0_cd_pin>;
diff --git a/arch/arm/boot/dts/sun8i-h3-beelink-x2.dts b/arch/arm/boot/dts/sun8i-h3-beelink-x2.dts
index 546837ccd8af..5cd3a391bfd9 100644
--- a/arch/arm/boot/dts/sun8i-h3-beelink-x2.dts
+++ b/arch/arm/boot/dts/sun8i-h3-beelink-x2.dts
@@ -53,7 +53,6 @@
 
 	aliases {
 		serial0 = &uart0;
-		ethernet0 = &emac;
 		ethernet1 = &sdiowifi;
 	};
 
@@ -108,13 +107,6 @@
 	status = "okay";
 };
 
-&emac {
-	phy-handle = <&int_mii_phy>;
-	phy-mode = "mii";
-	allwinner,leds-active-low;
-	status = "okay";
-};
-
 &ir {
 	pinctrl-names = "default";
 	pinctrl-0 = <&ir_pins_a>;
diff --git a/arch/arm/boot/dts/sun8i-h3-nanopi-neo.dts b/arch/arm/boot/dts/sun8i-h3-nanopi-neo.dts
index 78f6c24952dd..8d2cc6e9a03f 100644
--- a/arch/arm/boot/dts/sun8i-h3-nanopi-neo.dts
+++ b/arch/arm/boot/dts/sun8i-h3-nanopi-neo.dts
@@ -46,10 +46,3 @@
 	model = "FriendlyARM NanoPi NEO";
 	compatible = "friendlyarm,nanopi-neo", "allwinner,sun8i-h3";
 };
-
-&emac {
-	phy-handle = <&int_mii_phy>;
-	phy-mode = "mii";
-	allwinner,leds-active-low;
-	status = "okay";
-};
diff --git a/arch/arm/boot/dts/sun8i-h3-orangepi-2.dts b/arch/arm/boot/dts/sun8i-h3-orangepi-2.dts
index 17cdeae19c6f..8ff71b1bb45b 100644
--- a/arch/arm/boot/dts/sun8i-h3-orangepi-2.dts
+++ b/arch/arm/boot/dts/sun8i-h3-orangepi-2.dts
@@ -54,7 +54,6 @@
 	aliases {
 		serial0 = &uart0;
 		/* ethernet0 is the H3 emac, defined in sun8i-h3.dtsi */
-		ethernet0 = &emac;
 		ethernet1 = &rtl8189;
 	};
 
@@ -118,13 +117,6 @@
 	status = "okay";
 };
 
-&emac {
-	phy-handle = <&int_mii_phy>;
-	phy-mode = "mii";
-	allwinner,leds-active-low;
-	status = "okay";
-};
-
 &ir {
 	pinctrl-names = "default";
 	pinctrl-0 = <&ir_pins_a>;
diff --git a/arch/arm/boot/dts/sun8i-h3-orangepi-one.dts b/arch/arm/boot/dts/sun8i-h3-orangepi-one.dts
index 6880268e8b87..5fea430e0eb1 100644
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
-	phy-mode = "mii";
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
index 998b60f8d295..1a044b17d6c6 100644
--- a/arch/arm/boot/dts/sun8i-h3-orangepi-pc.dts
+++ b/arch/arm/boot/dts/sun8i-h3-orangepi-pc.dts
@@ -52,7 +52,6 @@
 	compatible = "xunlong,orangepi-pc", "allwinner,sun8i-h3";
 
 	aliases {
-		ethernet0 = &emac;
 		serial0 = &uart0;
 	};
 
@@ -114,13 +113,6 @@
 	status = "okay";
 };
 
-&emac {
-	phy-handle = <&int_mii_phy>;
-	phy-mode = "mii";
-	allwinner,leds-active-low;
-	status = "okay";
-};
-
 &ir {
 	pinctrl-names = "default";
 	pinctrl-0 = <&ir_pins_a>;
diff --git a/arch/arm/boot/dts/sun8i-h3-orangepi-plus.dts b/arch/arm/boot/dts/sun8i-h3-orangepi-plus.dts
index 331ed683ac62..828ae7a526d9 100644
--- a/arch/arm/boot/dts/sun8i-h3-orangepi-plus.dts
+++ b/arch/arm/boot/dts/sun8i-h3-orangepi-plus.dts
@@ -47,10 +47,6 @@
 	model = "Xunlong Orange Pi Plus / Plus 2";
 	compatible = "xunlong,orangepi-plus", "allwinner,sun8i-h3";
 
-	aliases {
-		ethernet0 = &emac;
-	};
-
 	reg_gmac_3v3: gmac-3v3 {
 		compatible = "regulator-fixed";
 		regulator-name = "gmac-3v3";
@@ -78,24 +74,6 @@
 	status = "okay";
 };
 
-&emac {
-	pinctrl-names = "default";
-	pinctrl-0 = <&emac_rgmii_pins>;
-	phy-supply = <&reg_gmac_3v3>;
-	phy-handle = <&ext_rgmii_phy>;
-	phy-mode = "rgmii";
-
-	allwinner,leds-active-low;
-	status = "okay";
-};
-
-&mdio {
-	ext_rgmii_phy: ethernet-phy@1 {
-		compatible = "ethernet-phy-ieee802.3-c22";
-		reg = <0>;
-	};
-};
-
 &mmc2 {
 	pinctrl-names = "default";
 	pinctrl-0 = <&mmc2_8bit_pins>;
diff --git a/arch/arm/boot/dts/sun8i-h3-orangepi-plus2e.dts b/arch/arm/boot/dts/sun8i-h3-orangepi-plus2e.dts
index 80026f3caafc..97920b12a944 100644
--- a/arch/arm/boot/dts/sun8i-h3-orangepi-plus2e.dts
+++ b/arch/arm/boot/dts/sun8i-h3-orangepi-plus2e.dts
@@ -61,19 +61,3 @@
 		gpio = <&pio 3 6 GPIO_ACTIVE_HIGH>; /* PD6 */
 	};
 };
-
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
-	ext_rgmii_phy: ethernet-phy@1 {
-		compatible = "ethernet-phy-ieee802.3-c22";
-		reg = <1>;
-	};
-};
diff --git a/arch/arm/boot/dts/sunxi-h3-h5.dtsi b/arch/arm/boot/dts/sunxi-h3-h5.dtsi
index d38282b9e5d4..11240a8313c2 100644
--- a/arch/arm/boot/dts/sunxi-h3-h5.dtsi
+++ b/arch/arm/boot/dts/sunxi-h3-h5.dtsi
@@ -391,32 +391,6 @@
 			clocks = <&osc24M>;
 		};
 
-		emac: ethernet@1c30000 {
-			compatible = "allwinner,sun8i-h3-emac";
-			syscon = <&syscon>;
-			reg = <0x01c30000 0x10000>;
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
-- 
2.13.5
