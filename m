From: Corentin Labbe <clabbe.montjoie@gmail.com>
Subject: [PATCH v5 02/10] dt-bindings: net: Restore sun8i dwmac binding
Date: Fri,  8 Sep 2017 09:11:48 +0200
Message-ID: <20170908071156.5115-3-clabbe.montjoie@gmail.com>
References: <20170908071156.5115-1-clabbe.montjoie@gmail.com>
Cc: netdev@vger.kernel.org, devicetree@vger.kernel.org,
        linux-arm-kernel@lists.infradead.org, linux-kernel@vger.kernel.org,
        Corentin Labbe <clabbe.montjoie@gmail.com>
To: robh+dt@kernel.org, mark.rutland@arm.com,
        maxime.ripard@free-electrons.com, wens@csie.org,
        linux@armlinux.org.uk, catalin.marinas@arm.com,
        will.deacon@arm.com, peppe.cavallaro@st.com,
        alexandre.torgue@st.com, andrew@lunn.ch, f.fainelli@gmail.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20170908071156.5115-1-clabbe.montjoie@gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This patch restore dt-bindings documentation about dwmac-sun8i
This reverts commit 8aa33ec2f481 ("dt-bindings: net: Revert sun8i dwmac binding")

Signed-off-by: Corentin Labbe <clabbe.montjoie@gmail.com>
---
 .../devicetree/bindings/net/dwmac-sun8i.txt        | 84 ++++++++++++++++++++++
 1 file changed, 84 insertions(+)
 create mode 100644 Documentation/devicetree/bindings/net/dwmac-sun8i.txt

diff --git a/Documentation/devicetree/bindings/net/dwmac-sun8i.txt b/Documentation/devicetree/bindings/net/dwmac-sun8i.txt
new file mode 100644
index 000000000000..725f3b187886
--- /dev/null
+++ b/Documentation/devicetree/bindings/net/dwmac-sun8i.txt
@@ -0,0 +1,84 @@
+* Allwinner sun8i GMAC ethernet controller
+
+This device is a platform glue layer for stmmac.
+Please see stmmac.txt for the other unchanged properties.
+
+Required properties:
+- compatible: should be one of the following string:
+		"allwinner,sun8i-a83t-emac"
+		"allwinner,sun8i-h3-emac"
+		"allwinner,sun8i-v3s-emac"
+		"allwinner,sun50i-a64-emac"
+- reg: address and length of the register for the device.
+- interrupts: interrupt for the device
+- interrupt-names: should be "macirq"
+- clocks: A phandle to the reference clock for this device
+- clock-names: should be "stmmaceth"
+- resets: A phandle to the reset control for this device
+- reset-names: should be "stmmaceth"
+- phy-mode: See ethernet.txt
+- phy-handle: See ethernet.txt
+- #address-cells: shall be 1
+- #size-cells: shall be 0
+- syscon: A phandle to the syscon of the SoC with one of the following
+ compatible string:
+  - allwinner,sun8i-h3-system-controller
+  - allwinner,sun8i-v3s-system-controller
+  - allwinner,sun50i-a64-system-controller
+  - allwinner,sun8i-a83t-system-controller
+
+Optional properties:
+- allwinner,tx-delay-ps: TX clock delay chain value in ps. Range value is 0-700. Default is 0)
+- allwinner,rx-delay-ps: RX clock delay chain value in ps. Range value is 0-3100. Default is 0)
+Both delay properties need to be a multiple of 100. They control the delay for
+external PHY.
+
+Optional properties for the following compatibles:
+  - "allwinner,sun8i-h3-emac",
+  - "allwinner,sun8i-v3s-emac":
+- allwinner,leds-active-low: EPHY LEDs are active low
+
+Required child node of emac:
+- mdio bus node: should be named mdio
+
+Required properties of the mdio node:
+- #address-cells: shall be 1
+- #size-cells: shall be 0
+
+The device node referenced by "phy" or "phy-handle" should be a child node
+of the mdio node. See phy.txt for the generic PHY bindings.
+
+Required properties of the phy node with the following compatibles:
+  - "allwinner,sun8i-h3-emac",
+  - "allwinner,sun8i-v3s-emac":
+- clocks: a phandle to the reference clock for the EPHY
+- resets: a phandle to the reset control for the EPHY
+
+Example:
+
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
+	phy-handle = <&int_mii_phy>;
+	phy-mode = "mii";
+	allwinner,leds-active-low;
+	mdio: mdio {
+		#address-cells = <1>;
+		#size-cells = <0>;
+		int_mii_phy: ethernet-phy@1 {
+			reg = <1>;
+			clocks = <&ccu CLK_BUS_EPHY>;
+			resets = <&ccu RST_BUS_EPHY>;
+		};
+	};
+};
-- 
2.13.5
