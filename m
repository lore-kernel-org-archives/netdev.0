From: Corentin Labbe <clabbe.montjoie-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Subject: [PATCH v3 07/20] ARM: dts: sunxi-h3-h5: add dwmac-sun8i ethernet driver
Date: Mon,  3 Apr 2017 11:14:31 +0200
Message-ID: <20170403091444.29876-8-clabbe.montjoie@gmail.com>
References: <20170403091444.29876-1-clabbe.montjoie@gmail.com>
Cc: devicetree-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
        netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linux-arm-kernel-IAPFreCvJWM7uuMidbF8XUB+6BGkLq7r@public.gmane.org,
        Corentin Labbe <clabbe.montjoie-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
To: robh+dt-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org, mark.rutland-5wv7dgnIgG8@public.gmane.org,
        maxime.ripard-wi1+55ScJUtKEb57/3fJTNBPR1lH4CV8@public.gmane.org, wens-jdAy2FN1RRM@public.gmane.org,
        linux-I+IVW8TIWO2tmTQ+vhA3Yw@public.gmane.org, catalin.marinas-5wv7dgnIgG8@public.gmane.org,
        will.deacon-5wv7dgnIgG8@public.gmane.org, peppe.cavallaro-qxv4g6HH51o@public.gmane.org,
        alexandre.torgue-qxv4g6HH51o@public.gmane.org
Return-path: <devicetree-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <20170403091444.29876-1-clabbe.montjoie-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Sender: devicetree-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

The dwmac-sun8i is an ethernet MAC hardware that support 10/100/1000
speed.

This patch enable the dwmac-sun8i on Allwinner H3/H5 SoC Device-tree.
SoC H3/H5 have an internal PHY, so optionals syscon and ephy are set.

Signed-off-by: Corentin Labbe <clabbe.montjoie-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
---
 arch/arm/boot/dts/sunxi-h3-h5.dtsi | 34 ++++++++++++++++++++++++++++++++++
 1 file changed, 34 insertions(+)

diff --git a/arch/arm/boot/dts/sunxi-h3-h5.dtsi b/arch/arm/boot/dts/sunxi-h3-h5.dtsi
index 0815c00..c55e8b0 100644
--- a/arch/arm/boot/dts/sunxi-h3-h5.dtsi
+++ b/arch/arm/boot/dts/sunxi-h3-h5.dtsi
@@ -304,6 +304,14 @@
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
@@ -400,6 +408,32 @@
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
+					compatible = "ethernet-phy-ieee802.3-c22";
+					reg = <1>;
+					clocks = <&ccu CLK_BUS_EPHY>;
+					resets = <&ccu RST_BUS_EPHY>;
+				};
+			};
+		};
+
 		spi0: spi@01c68000 {
 			compatible = "allwinner,sun8i-h3-spi";
 			reg = <0x01c68000 0x1000>;
-- 
2.10.2

--
To unsubscribe from this list: send the line "unsubscribe devicetree" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
