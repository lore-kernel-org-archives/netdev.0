From: Gerhard Bertelsmann <info@gerhard-bertelsmann.de>
Subject: [PATCH v8 1/3] can: Allwinner A10/A20 CAN Controller support - Devicetree bindings
Date: Wed, 16 Sep 2015 13:21:19 +0200
Message-ID: <1442402482-7118-2-git-send-email-info@gerhard-bertelsmann.de>
References: <1442402482-7118-1-git-send-email-info@gerhard-bertelsmann.de>
Cc: Gerhard Bertelsmann <info@gerhard-bertelsmann.de>
To: wg@grandegger.com, mkl@pengutronix.de,
	maxime.ripard@free-electrons.com, linux-can@vger.kernel.org,
	netdev@vger.kernel.org, linux-arm-kernel@lists.infradead.org,
	linux-kernel@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1442402482-7118-1-git-send-email-info@gerhard-bertelsmann.de>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Devicetree bindings for Allwinner A10/A20 CAN

Signed-off-by: Gerhard Bertelsmann <info@gerhard-bertelsmann.de>
---

 .../devicetree/bindings/net/can/sun4i_can.txt      |  38 +
 1 files changed, 389 insertions(+)


diff --git a/Documentation/devicetree/bindings/net/can/sun4i_can.txt b/Documentation/devicetree/bindings/net/can/sun4i_can.txt
new file mode 100644
index 0000000..cd0f50c
--- /dev/null
+++ b/Documentation/devicetree/bindings/net/can/sun4i_can.txt
@@ -0,0 +1,38 @@
+Allwinner A10/A20 CAN controller Device Tree Bindings
+-----------------------------------------------------
+
+Required properties:
+- compatible: "allwinner,sun4i-a10-can"
+- reg: physical base address and size of the Allwinner A10/A20 CAN register map.
+- interrupts: interrupt specifier for the sole interrupt.
+- clock: phandle and clock specifier.
+
+
+Example
+-------
+
+SoC common .dtsi file:
+
+	can0_pins_a: can0@0 {
+		allwinner,pins = "PH20","PH21";
+		allwinner,function = "can";
+		allwinner,drive = <0>;
+		allwinner,pull = <0>;
+	};
+...
+	can0: can@01c2bc00 {
+		compatible = "allwinner,sun4i-a10-can";
+		reg = <0x01c2bc00 0x400>;
+		interrupts = <0 26 4>;
+		clocks = <&apb1_gates 4>;
+		status = "disabled";
+	};
+
+Board specific .dts file:
+
+	can0: can@01c2bc00 {
+		pinctrl-names = "default";
+		pinctrl-0 = <&can0_pins_a>;
+		status = "okay";
+	};
+
