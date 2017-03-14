From: Corentin Labbe <clabbe.montjoie@gmail.com>
Subject: [PATCH v2 07/20] ARM: dts: sunxi-h3-h5: add dwmac-sun8i ethernet driver
Date: Tue, 14 Mar 2017 15:18:43 +0100
Message-ID: <20170314141856.24560-8-clabbe.montjoie@gmail.com>
References: <20170314141856.24560-1-clabbe.montjoie@gmail.com>
Cc: f.fainelli@gmail.com, devicetree@vger.kernel.org,
        linux-kernel@vger.kernel.org, netdev@vger.kernel.org,
        linux-arm-kernel@lists.infradead.org,
        Corentin Labbe <clabbe.montjoie@gmail.com>
To: robh+dt@kernel.org, mark.rutland@arm.com,
        maxime.ripard@free-electrons.com, wens@csie.org,
        linux@armlinux.org.uk, catalin.marinas@arm.com,
        will.deacon@arm.com, peppe.cavallaro@st.com,
        alexandre.torgue@st.com, davem@davemloft.net
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20170314141856.24560-1-clabbe.montjoie@gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

The dwmac-sun8i is an ethernet MAC hardware that support 10/100/1000
speed.

This patch enable the dwmac-sun8i on Allwinner H3/H5 SoC Device-tree.
SoC H3/H5 have an internal PHY, so optionals syscon and ephy are set.

Signed-off-by: Corentin Labbe <clabbe.montjoie@gmail.com>
---
 arch/arm/boot/dts/sunxi-h3-h5.dtsi | 33 +++++++++++++++++++++++++++++++++
 1 file changed, 33 insertions(+)

diff --git a/arch/arm/boot/dts/sunxi-h3-h5.dtsi b/arch/arm/boot/dts/sunxi-h3-h5.dtsi
index 07e4f36..c35af5e 100644
--- a/arch/arm/boot/dts/sunxi-h3-h5.dtsi
+++ b/arch/arm/boot/dts/sunxi-h3-h5.dtsi
@@ -272,6 +272,14 @@
 			interrupt-controller;
 			#interrupt-cells = <3>;
 
+			emac_rgmii_pins: emac0@0 {
+				pins = "PD0", "PD1", "PD2", "PD3", "PD4",
+					"PD5", "PD7", "PD8", "PD9", "PD10",
+					"PD12", "PD13", "PD15", "PD16", "PD17";
+				function = "emac";
+				drive-strength = <40>;
+			};
+
 			i2c0_pins: i2c0 {
 				pins = "PA11", "PA12";
 				function = "i2c0";
@@ -368,6 +376,31 @@
 			clocks = <&osc24M>;
 		};
 
+		emac: ethernet@1c30000 {
+			compatible = "allwinner,sun8i-h3-emac";
+			syscon = <&syscon>;
+			reg = <0x01c30000 0x104>;
+			interrupts = <GIC_SPI 82 IRQ_TYPE_LEVEL_HIGH>;
+			interrupt-names = "macirq";
+			resets = <&ccu RST_BUS_EMAC>;
+			reset-names = "stmmaceth";
+			clocks = <&ccu CLK_BUS_EMAC>;
+			clock-names = "stmmaceth";
+			#address-cells = <1>;
+			#size-cells = <0>;
+			status = "disabled";
+
+			mdio: mdio {
+				#address-cells = <1>;
+				#size-cells = <0>;
+				int_mii_phy: ethernet-phy@1 {
+				reg = <1>;
+				clocks = <&ccu CLK_BUS_EPHY>;
+				resets = <&ccu RST_BUS_EPHY>;
+				};
+			};
+		};
+
 		spi0: spi@01c68000 {
 			compatible = "allwinner,sun8i-h3-spi";
 			reg = <0x01c68000 0x1000>;
-- 
2.10.2
