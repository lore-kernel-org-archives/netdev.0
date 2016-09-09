From: Corentin Labbe <clabbe.montjoie@gmail.com>
Subject: [PATCH v3 3/9] ARM: sun8i: dt: Add DT bindings documentation for Allwinner sun8i-emac
Date: Fri,  9 Sep 2016 14:45:11 +0200
Message-ID: <1473425117-18645-4-git-send-email-clabbe.montjoie@gmail.com>
References: <1473425117-18645-1-git-send-email-clabbe.montjoie@gmail.com>
Cc: netdev@vger.kernel.org, devicetree@vger.kernel.org,
        linux-arm-kernel@lists.infradead.org, linux-kernel@vger.kernel.org,
        Corentin Labbe <clabbe.montjoie@gmail.com>
To: robh+dt@kernel.org, mark.rutland@arm.com,
        maxime.ripard@free-electrons.com, wens@csie.org,
        linux@armlinux.org.uk, davem@davemloft.net
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1473425117-18645-1-git-send-email-clabbe.montjoie@gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This patch adds documentation for Device-Tree bindings for the
Allwinner sun8i-emac driver.

Signed-off-by: Corentin Labbe <clabbe.montjoie@gmail.com>
---
 .../bindings/net/allwinner,sun8i-emac.txt          | 64 ++++++++++++++++++++++
 1 file changed, 64 insertions(+)
 create mode 100644 Documentation/devicetree/bindings/net/allwinner,sun8i-emac.txt

diff --git a/Documentation/devicetree/bindings/net/allwinner,sun8i-emac.txt b/Documentation/devicetree/bindings/net/allwinner,sun8i-emac.txt
new file mode 100644
index 0000000..4968ee3
--- /dev/null
+++ b/Documentation/devicetree/bindings/net/allwinner,sun8i-emac.txt
@@ -0,0 +1,64 @@
+* Allwinner sun8i EMAC ethernet controller
+
+Required properties:
+- compatible: should be one of the following string:
+		"allwinner,sun8i-a83t-emac"
+		"allwinner,sun8i-h3-emac"
+		"allwinner,sun50i-a64-emac"
+- reg: address and length of the register for the device.
+- reg-names: should be "emac"
+- syscon: A phandle to the syscon of the SoC
+- interrupts: interrupt for the device
+- clocks: A phandle to the reference clock for this device
+- clock-names: should be "ahb"
+- resets: A phandle to the reset control for this device
+- reset-names: should be "ahb"
+- phy-mode: See ethernet.txt
+- phy or phy-handle: See ethernet.txt
+- #address-cells: shall be 1
+- #size-cells: shall be 0
+
+"allwinner,sun8i-h3-emac" also requires:
+- clocks: an extra phandle to the reference clock for the EPHY
+- clock-names: an extra "ephy" entry matching the clocks property
+- resets: an extra phandle to the reset control for the EPHY
+- resets-names: an extra "ephy" entry matching the resets property
+
+See ethernet.txt in the same directory for generic bindings for ethernet
+controllers.
+
+The device node referenced by "phy" or "phy-handle" should be a child node
+of this node. See phy.txt for the generic PHY bindings.
+
+Optional properties:
+- allwinner,tx-delay: TX clock delay chain value. Range value is 0-0x07. Default is 0)
+- allwinner,rx-delay: RX clock delay chain value. Range value is 0-0x1F. Default is 0)
+
+The TX/RX clock delay chain settings are board specific.
+
+Optional properties for "allwinner,sun8i-h3-emac":
+- allwinner,leds-active-low: EPHY LEDs are active low
+
+Example:
+
+emac: ethernet@01c0b000 {
+	compatible = "allwinner,sun8i-h3-emac";
+	syscon = <&syscon>;
+	reg = <0x01c0b000 0x104>;
+	reg-names = "emac";
+	interrupts = <GIC_SPI 82 IRQ_TYPE_LEVEL_HIGH>;
+	resets = <&ccu RST_BUS_EMAC>, <<&ccu RST_BUS_EPHY>;
+	reset-names = "ahb", "ephy";
+	clocks = <&ccu CLK_BUS_EMAC>, <&ccu CLK_BUS_EPHY>;
+	clock-names = "ahb", "ephy";
+	#address-cells = <1>;
+	#size-cells = <0>;
+
+	phy = <&phy1>;
+	phy-mode = "mii";
+	allwinner,leds-active-low;
+
+	phy1: ethernet-phy@1 {
+		reg = <1>;
+	};
+};
-- 
2.7.3
