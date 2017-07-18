From: Icenowy Zheng <icenowy@aosc.io>
Subject: [PATCH] dt-bindings: add device tree binding for Allwinner XR819 SDIO Wi-Fi
Date: Tue, 18 Jul 2017 15:29:40 +0800
Message-ID: <20170718072940.17872-1-icenowy@aosc.io>
Cc: linux-wireless@vger.kernel.org, netdev@vger.kernel.org,
        devicetree@vger.kernel.org, linux-kernel@vger.kernel.org,
        linux-sunxi@googlegroups.com, Icenowy Zheng <icenowy@aosc.io>
To: Kalle Valo <kvalo@codeaurora.org>,
        Rob Herring <robh+dt@kernel.org>,
        Maxime Ripard <maxime.ripard@free-electrons.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Allwinner XR819 is a SDIO Wi-Fi chip, which has the functionality to use
an out-of-band interrupt pin instead of SDIO in-band interrupt.

Add the device tree binding of this chip, in order to make it possible
to add this interrupt pin to device trees.

Signed-off-by: Icenowy Zheng <icenowy@aosc.io>
---
 .../bindings/net/wireless/allwinner,xr819.txt      | 37 ++++++++++++++++++++++
 1 file changed, 37 insertions(+)
 create mode 100644 Documentation/devicetree/bindings/net/wireless/allwinner,xr819.txt

diff --git a/Documentation/devicetree/bindings/net/wireless/allwinner,xr819.txt b/Documentation/devicetree/bindings/net/wireless/allwinner,xr819.txt
new file mode 100644
index 000000000000..64dd9c1c0584
--- /dev/null
+++ b/Documentation/devicetree/bindings/net/wireless/allwinner,xr819.txt
@@ -0,0 +1,37 @@
+Allwinner XRadio wireless SDIO devices
+
+This node provides properties for controlling the XRadio wireless device. The
+node is expected to be specified as a child node to the SDIO controller that
+connects the device to the system.
+
+Required properties:
+
+ - compatible : Should be "allwinner,xr819".
+
+Optional properties:
+ - interrupt-parent : the phandle for the interrupt controller to which the
+	device interrupts are connected.
+ - interrupts : specifies attributes for the out-of-band interrupt (host-wake).
+	When not specified the device will use in-band SDIO interrupts.
+
+Example:
+
+mmc1: mmc@01c10000 {
+	#address-cells = <1>;
+	#size-cells = <0>;
+
+	pinctrl-names = "default";
+	pinctrl-0 = <&mmc1_pins_a>;
+	vmmc-supply = <&reg_vcc_wifi>;
+	mmc-pwrseq = <&wifi_pwrseq>;
+	bus-width = <4>;
+	non-removable;
+	status = "okay";
+
+	xr819: sdio_wifi@1 {
+		reg = <1>;
+		compatible = "allwinner,xr819";
+		interrupt-parent = <&pio>;
+		interrupts = <6 10 IRQ_TYPE_EDGE_RISING>;
+	};
+};
-- 
2.13.0
