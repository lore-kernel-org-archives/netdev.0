From: Chen-Yu Tsai <wens@csie.org>
Subject: [PATCH RFC 1/5] net: phy: sun8i-h3-ephy: Add bindings for Allwinner H3 Ethernet PHY
Date: Tue,  5 Apr 2016 00:22:30 +0800
Message-ID: <1459786954-12649-2-git-send-email-wens@csie.org>
References: <1459786954-12649-1-git-send-email-wens@csie.org>
Cc: Chen-Yu Tsai <wens@csie.org>, netdev@vger.kernel.org,
	linux-arm-kernel@lists.infradead.org, linux-kernel@vger.kernel.org,
	devicetree@vger.kernel.org,
	LABBE Corentin <clabbe.montjoie@gmail.com>
To: Maxime Ripard <maxime.ripard@free-electrons.com>,
	Florian Fainelli <f.fainelli@gmail.com>,
	Rob Herring <robh+dt@kernel.org>,
	Pawel Moll <pawel.moll@arm.com>,
	Mark Rutland <mark.rutland@arm.com>,
	Ian Campbell <ijc+devicetree@hellion.org.uk>,
	Kumar Gala <galak@codeaurora.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1459786954-12649-1-git-send-email-wens@csie.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

The Allwinner H3 SoC incorporates an Ethernet PHY. This is enabled and
configured through a memory mapped hardware register.

This same register also configures the MAC interface mode and TX clock
source. Also covered by the register, but not supported in these bindings,
are TX/RX clock delay chains and inverters, and an RMII module.

Signed-off-by: Chen-Yu Tsai <wens@csie.org>
---
 .../bindings/net/allwinner,sun8i-h3-ephy.txt       | 44 ++++++++++++++++++++++
 1 file changed, 44 insertions(+)
 create mode 100644 Documentation/devicetree/bindings/net/allwinner,sun8i-h3-ephy.txt

diff --git a/Documentation/devicetree/bindings/net/allwinner,sun8i-h3-ephy.txt b/Documentation/devicetree/bindings/net/allwinner,sun8i-h3-ephy.txt
new file mode 100644
index 000000000000..146f227e6d88
--- /dev/null
+++ b/Documentation/devicetree/bindings/net/allwinner,sun8i-h3-ephy.txt
@@ -0,0 +1,44 @@
+* Allwinner H3 E(thernet) PHY
+
+The Allwinner H3 integrates an MII ethernet PHY. As with external PHYs,
+before it can be configured over the MDIO bus and used, certain hardware
+features must be configured, such as the PHY address and LED polarity.
+The PHY must also be powered on and brought out of reset.
+
+This is accomplished with regulators and pull-up/downs for external PHYs.
+For this internal PHY, a hardware register is programmed.
+
+The same hardware register also contains clock and interface controls
+for the MAC. This is also present in earlier SoCs, and is covered by
+"allwinner,sun7i-a20-gmac-clk". The controls in the H3 are slightly
+different due to the inclusion of what appears to be an RMII-MII
+bridge.
+
+Required properties:
+- compatible: should be "allwinner,sun8i-h3-ephy"
+- reg: address and length of the register set for the device
+- clocks: A phandle to the reference clock for this device
+- resets: A phandle to the reset control for this device
+
+Ethernet PHY related properties:
+- allwinner,ephy-addr: the MDIO bus address the PHY should respond to.
+		       If this is not set, the external PHY is used, and
+		       everything else in this section is ignored.
+- allwinner,leds-active-low: LEDs are active low. Without this, LEDs are
+			     active high.
+
+Ethernet MAC clock related properties:
+- #clock-cells: should be 0
+- clock-output-names: "mac_tx"
+
+Example:
+
+ethernet-phy@01c00030 {
+	compatible = "allwinner,sun8i-h3-ephy";
+	reg = <0x01c00030 0x4>;
+	clocks = <&bus_gates 128>;
+	resets = <&ahb_rst 66>;
+	allwinner,ephy-addr = <0x1>;
+	#clock-cells = <0>;
+	clock-output-names = "mac_tx";
+};
-- 
2.7.0
