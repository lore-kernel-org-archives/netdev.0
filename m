From: Neil Armstrong <narmstrong@baylibre.com>
Subject: [PATCH v3 2/2] dt-bindings: net: Add OXNAS DWMAC Bindings
Date: Wed,  2 Nov 2016 15:02:37 +0100
Message-ID: <20161102140237.6955-3-narmstrong@baylibre.com>
References: <20161102140237.6955-1-narmstrong@baylibre.com>
Cc: Neil Armstrong <narmstrong@baylibre.com>, netdev@vger.kernel.org,
        linux-oxnas@lists.tuxfamily.org,
        linux-arm-kernel@lists.infradead.org, linux-kernel@vger.kernel.org,
        devicetree@vger.kernel.org
To: peppe.cavallaro@st.com, alexandre.torgue@st.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20161102140237.6955-1-narmstrong@baylibre.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Signed-off-by: Neil Armstrong <narmstrong@baylibre.com>
---
 .../devicetree/bindings/net/oxnas-dwmac.txt        | 39 ++++++++++++++++++++++
 1 file changed, 39 insertions(+)
 create mode 100644 Documentation/devicetree/bindings/net/oxnas-dwmac.txt

diff --git a/Documentation/devicetree/bindings/net/oxnas-dwmac.txt b/Documentation/devicetree/bindings/net/oxnas-dwmac.txt
new file mode 100644
index 0000000..df0534e
--- /dev/null
+++ b/Documentation/devicetree/bindings/net/oxnas-dwmac.txt
@@ -0,0 +1,39 @@
+* Oxford Semiconductor OXNAS DWMAC Ethernet controller
+
+The device inherits all the properties of the dwmac/stmmac devices
+described in the file stmmac.txt in the current directory with the
+following changes.
+
+Required properties on all platforms:
+
+- compatible:	For the OX820 SoC, it should be :
+		- "oxsemi,ox820-dwmac" to select glue
+		- "snps,dwmac-3.512" to select IP version.
+
+- clocks: Should contain phandles to the following clocks
+- clock-names:	Should contain the following:
+		- "stmmaceth" for the host clock - see stmmac.txt
+		- "gmac" for the peripheral gate clock
+
+- oxsemi,sys-ctrl: a phandle to the system controller syscon node
+
+Example :
+
+etha: ethernet@40400000 {
+	compatible = "oxsemi,ox820-dwmac", "snps,dwmac-3.512";
+	reg = <0x40400000 0x2000>;
+	interrupts = <GIC_SPI 8 IRQ_TYPE_LEVEL_HIGH>,
+		     <GIC_SPI 17 IRQ_TYPE_LEVEL_HIGH>;
+	interrupt-names = "macirq", "eth_wake_irq";
+	mac-address = [000000000000]; /* Filled in by U-Boot */
+	phy-mode = "rgmii";
+
+	clocks = <&stdclk CLK_820_ETHA>, <&gmacclk>;
+	clock-names = "gmac", "stmmaceth";
+	resets = <&reset RESET_MAC>;
+
+	/* Regmap for sys registers */
+	oxsemi,sys-ctrl = <&sys>;
+
+	status = "disabled";
+};
-- 
2.7.0
