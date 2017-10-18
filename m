From: Corentin Labbe <clabbe.montjoie-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Subject: [PATCH v7 05/10] dt-bindings: net: dwmac-sun8i: update
 documentation about integrated PHY
Date: Wed, 18 Oct 2017 13:44:53 +0200
Message-ID: <20171018114458.17891-6-clabbe.montjoie@gmail.com>
References: <20171018114458.17891-1-clabbe.montjoie@gmail.com>
Reply-To: clabbe.montjoie-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Cc: netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	devicetree-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	linux-arm-kernel-IAPFreCvJWM7uuMidbF8XUB+6BGkLq7r@public.gmane.org,
	linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	linux-sunxi-/JYPxA39Uh5TLH3MbocFFw@public.gmane.org,
	Corentin Labbe <clabbe.montjoie-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
To: robh+dt-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org,
	mark.rutland-5wv7dgnIgG8@public.gmane.org,
	maxime.ripard-wi1+55ScJUtKEb57/3fJTNBPR1lH4CV8@public.gmane.org,
	wens-jdAy2FN1RRM@public.gmane.org,
	linux-I+IVW8TIWO2tmTQ+vhA3Yw@public.gmane.org,
	catalin.marinas-5wv7dgnIgG8@public.gmane.org,
	will.deacon-5wv7dgnIgG8@public.gmane.org,
	peppe.cavallaro-qxv4g6HH51o@public.gmane.org,
	alexandre.torgue-qxv4g6HH51o@public.gmane.org,
	andrew-g2DYL2Zd6BY@public.gmane.org,
	f.fainelli-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org,
	frowand.list-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org
Return-path: <linux-sunxi+bncBD7YLCN32UNBBRP6TTHQKGQEOC7QD7Q-/JYPxA39Uh5TLH3MbocFFw@public.gmane.org>
Sender: linux-sunxi-/JYPxA39Uh5TLH3MbocFFw@public.gmane.org
In-Reply-To: <20171018114458.17891-1-clabbe.montjoie-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
List-Post: <https://groups.google.com/group/linux-sunxi/post>, <mailto:linux-sunxi-/JYPxA39Uh5TLH3MbocFFw@public.gmane.org>
List-Help: <https://groups.google.com/support/>, <mailto:linux-sunxi+help-/JYPxA39Uh5TLH3MbocFFw@public.gmane.org>
List-Archive: <https://groups.google.com/group/linux-sunxi
List-Subscribe: <https://groups.google.com/group/linux-sunxi/subscribe>, <mailto:linux-sunxi+subscribe-/JYPxA39Uh5TLH3MbocFFw@public.gmane.org>
List-Unsubscribe: <mailto:googlegroups-manage+1076902468213+unsubscribe-/JYPxA39Uh5TLH3MbocFFw@public.gmane.org>,
 <https://groups.google.com/group/linux-sunxi/subscribe>
List-Id: netdev.vger.kernel.org

This patch add documentation about the MDIO switch used on sun8i-h3-emac
for integrated PHY.

Signed-off-by: Corentin Labbe <clabbe.montjoie-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
---
 .../devicetree/bindings/net/dwmac-sun8i.txt        | 139 +++++++++++++++++++--
 1 file changed, 127 insertions(+), 12 deletions(-)

diff --git a/Documentation/devicetree/bindings/net/dwmac-sun8i.txt b/Documentation/devicetree/bindings/net/dwmac-sun8i.txt
index 725f3b187886..0ae7d2096375 100644
--- a/Documentation/devicetree/bindings/net/dwmac-sun8i.txt
+++ b/Documentation/devicetree/bindings/net/dwmac-sun8i.txt
@@ -4,18 +4,18 @@ This device is a platform glue layer for stmmac.
 Please see stmmac.txt for the other unchanged properties.
 
 Required properties:
-- compatible: should be one of the following string:
+- compatible: must be one of the following string:
 		"allwinner,sun8i-a83t-emac"
 		"allwinner,sun8i-h3-emac"
 		"allwinner,sun8i-v3s-emac"
 		"allwinner,sun50i-a64-emac"
 - reg: address and length of the register for the device.
 - interrupts: interrupt for the device
-- interrupt-names: should be "macirq"
+- interrupt-names: must be "macirq"
 - clocks: A phandle to the reference clock for this device
-- clock-names: should be "stmmaceth"
+- clock-names: must be "stmmaceth"
 - resets: A phandle to the reset control for this device
-- reset-names: should be "stmmaceth"
+- reset-names: must be "stmmaceth"
 - phy-mode: See ethernet.txt
 - phy-handle: See ethernet.txt
 - #address-cells: shall be 1
@@ -39,23 +39,38 @@ Optional properties for the following compatibles:
 - allwinner,leds-active-low: EPHY LEDs are active low
 
 Required child node of emac:
-- mdio bus node: should be named mdio
+- mdio bus node: with compatible "snps,dwmac-mdio"
 
 Required properties of the mdio node:
 - #address-cells: shall be 1
 - #size-cells: shall be 0
 
-The device node referenced by "phy" or "phy-handle" should be a child node
+The device node referenced by "phy" or "phy-handle" must be a child node
 of the mdio node. See phy.txt for the generic PHY bindings.
 
-Required properties of the phy node with the following compatibles:
+The following compatibles require that the mdio node have a mdio-mux child
+node called "mdio-mux":
+  - "allwinner,sun8i-h3-emac"
+  - "allwinner,sun8i-v3s-emac":
+Required properties for the mdio-mux node:
+  - compatible = "mdio-mux", "allwinner,sun8i-h3-mdio-mux"
+  - one child mdio for the integrated mdio with the compatible
+    "allwinner,sun8i-h3-mdio-internal"
+  - one child mdio for the external mdio if present (V3s have none)
+Required properties for the mdio-mux children node:
+  - reg: 1 for internal MDIO bus, 2 for external MDIO bus
+
+The following compatibles require a PHY node representing the integrated
+PHY, under the integrated MDIO bus node if an mdio-mux node is used:
   - "allwinner,sun8i-h3-emac",
   - "allwinner,sun8i-v3s-emac":
+
+Required properties of the integrated phy node:
 - clocks: a phandle to the reference clock for the EPHY
 - resets: a phandle to the reset control for the EPHY
+- Must be a child of the integrated mdio
 
-Example:
-
+Example with integrated PHY:
 emac: ethernet@1c0b000 {
 	compatible = "allwinner,sun8i-h3-emac";
 	syscon = <&syscon>;
@@ -72,13 +87,113 @@ emac: ethernet@1c0b000 {
 	phy-handle = <&int_mii_phy>;
 	phy-mode = "mii";
 	allwinner,leds-active-low;
+
+	mdio0: mdio {
+		#address-cells = <1>;
+		#size-cells = <0>;
+		compatible = "snps,dwmac-mdio";
+
+		mdio-mux {
+			compatible = "mdio-mux", "allwinner,sun8i-h3-mdio-mux";
+			#address-cells = <1>;
+			#size-cells = <0>;
+
+			int_mdio: mdio@1 {
+				compatible = "allwinner,sun8i-h3-mdio-internal";
+				reg = <1>;
+				#address-cells = <1>;
+				#size-cells = <0>;
+				int_mii_phy: ethernet-phy@1 {
+					reg = <1>;
+					clocks = <&ccu CLK_BUS_EPHY>;
+					resets = <&ccu RST_BUS_EPHY>;
+					phy-is-integrated;
+				};
+			};
+			ext_mdio: mdio@2 {
+				reg = <2>;
+				#address-cells = <1>;
+				#size-cells = <0>;
+			};
+		};
+	};
+};
+
+Example with external PHY:
+emac: ethernet@1c0b000 {
+	compatible = "allwinner,sun8i-h3-emac";
+	syscon = <&syscon>;
+	reg = <0x01c0b000 0x104>;
+	interrupts = <GIC_SPI 82 IRQ_TYPE_LEVEL_HIGH>;
+	interrupt-names = "macirq";
+	resets = <&ccu RST_BUS_EMAC>;
+	reset-names = "stmmaceth";
+	clocks = <&ccu CLK_BUS_EMAC>;
+	clock-names = "stmmaceth";
+	#address-cells = <1>;
+	#size-cells = <0>;
+
+	phy-handle = <&ext_rgmii_phy>;
+	phy-mode = "rgmii";
+	allwinner,leds-active-low;
+
+	mdio0: mdio {
+		#address-cells = <1>;
+		#size-cells = <0>;
+		compatible = "snps,dwmac-mdio";
+
+		mdio-mux {
+			compatible = "mdio-mux", "allwinner,sun8i-h3-mdio-mux";
+			#address-cells = <1>;
+			#size-cells = <0>;
+
+			int_mdio: mdio@1 {
+				compatible = "allwinner,sun8i-h3-mdio-internal";
+				reg = <1>;
+				#address-cells = <1>;
+				#size-cells = <0>;
+				int_mii_phy: ethernet-phy@1 {
+					reg = <1>;
+					clocks = <&ccu CLK_BUS_EPHY>;
+					resets = <&ccu RST_BUS_EPHY>;
+				};
+			};
+			ext_mdio: mdio@2 {
+				reg = <2>;
+				#address-cells = <1>;
+				#size-cells = <0>;
+				ext_rgmii_phy: ethernet-phy@1 {
+					reg = <1>;
+				};
+			}:
+		};
+	};
+};
+
+Example with SoC without integrated PHY
+
+emac: ethernet@1c0b000 {
+	compatible = "allwinner,sun8i-a83t-emac";
+	syscon = <&syscon>;
+	reg = <0x01c0b000 0x104>;
+	interrupts = <GIC_SPI 82 IRQ_TYPE_LEVEL_HIGH>;
+	interrupt-names = "macirq";
+	resets = <&ccu RST_BUS_EMAC>;
+	reset-names = "stmmaceth";
+	clocks = <&ccu CLK_BUS_EMAC>;
+	clock-names = "stmmaceth";
+	#address-cells = <1>;
+	#size-cells = <0>;
+
+	phy-handle = <&ext_rgmii_phy>;
+	phy-mode = "rgmii";
+
 	mdio: mdio {
+		compatible = "snps,dwmac-mdio";
 		#address-cells = <1>;
 		#size-cells = <0>;
-		int_mii_phy: ethernet-phy@1 {
+		ext_rgmii_phy: ethernet-phy@1 {
 			reg = <1>;
-			clocks = <&ccu CLK_BUS_EPHY>;
-			resets = <&ccu RST_BUS_EPHY>;
 		};
 	};
 };
-- 
2.13.6
