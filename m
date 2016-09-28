From: Andrew Lunn <andrew@lunn.ch>
Subject: [PATCH RFC 6/6] arm: vf610: zii devel b: Add support for switch interrupts
Date: Wed, 28 Sep 2016 10:32:24 +0200
Message-ID: <1475051544-18561-7-git-send-email-andrew@lunn.ch>
References: <1475051544-18561-1-git-send-email-andrew@lunn.ch>
Cc: netdev <netdev@vger.kernel.org>, Andrew Lunn <andrew@lunn.ch>
To: Florian Fainelli <f.fainelli@gmail.com>,
        Vivien Didelot <vivien.didelot@savoirfairelinux.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from vps0.lunn.ch ([178.209.37.122]:34926 "EHLO vps0.lunn.ch"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1751573AbcI1IdD (ORCPT <rfc822;netdev@vger.kernel.org>);
        Wed, 28 Sep 2016 04:33:03 -0400
In-Reply-To: <1475051544-18561-1-git-send-email-andrew@lunn.ch>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The Switches use GPIO lines to indicate interrupts from two of the
switches.

With these interrupts in place, we can make use of the interrupt
controllers within the switch to indicate when the internal PHYs
generate an interrupt. Use standard PHY properties to do this.

Signed-off-by: Andrew Lunn <andrew@lunn.ch>
---
 arch/arm/boot/dts/vf610-zii-dev-rev-b.dts | 51 +++++++++++++++++++++++++++++++
 1 file changed, 51 insertions(+)

diff --git a/arch/arm/boot/dts/vf610-zii-dev-rev-b.dts b/arch/arm/boot/dts/vf610-zii-dev-rev-b.dts
index 5c1fcab4a6f7..1a9b4ad138f6 100644
--- a/arch/arm/boot/dts/vf610-zii-dev-rev-b.dts
+++ b/arch/arm/boot/dts/vf610-zii-dev-rev-b.dts
@@ -88,10 +88,16 @@
 
 			switch0: switch0@0 {
 				compatible = "marvell,mv88e6085";
+				pinctrl-0 = <&pinctrl_gpio_switch0>;
+				pinctrl-names = "default";
 				#address-cells = <1>;
 				#size-cells = <0>;
 				reg = <0>;
 				dsa,member = <0 0>;
+				interrupt-parent = <&gpio0>;
+				interrupts = <27 IRQ_TYPE_LEVEL_LOW>;
+				interrupt-controller;
+				#interrupt-cells = <2>;
 
 				ports {
 					#address-cells = <1>;
@@ -99,16 +105,19 @@
 					port@0 {
 						reg = <0>;
 						label = "lan0";
+						phy-handle = <&switch0phy0>;
 					};
 
 					port@1 {
 						reg = <1>;
 						label = "lan1";
+						phy-handle = <&switch0phy1>;
 					};
 
 					port@2 {
 						reg = <2>;
 						label = "lan2";
+						phy-handle = <&switch0phy2>;
 					};
 
 					switch0port5: port@5 {
@@ -133,6 +142,24 @@
 						};
 					};
 				};
+				mdio {
+					#address-cells = <1>;
+					#size-cells = <0>;
+					switch0phy0: switch0phy0@0 {
+						reg = <0>;
+						interrupt-parent = <&switch0>;
+						interrupts = <0 IRQ_TYPE_LEVEL_HIGH>;
+					};
+					switch0phy1: switch1phy0@1 {
+						reg = <1>;
+						interrupt-parent = <&switch0>;
+						interrupts = <1 IRQ_TYPE_LEVEL_HIGH>;					};
+					switch0phy2: switch1phy0@2 {
+						reg = <2>;
+						interrupt-parent = <&switch0>;
+						interrupts = <2 IRQ_TYPE_LEVEL_HIGH>;
+					};
+				};
 			};
 		};
 
@@ -143,10 +170,16 @@
 
 			switch1: switch1@0 {
 				compatible = "marvell,mv88e6085";
+				pinctrl-0 = <&pinctrl_gpio_switch1>;
+				pinctrl-names = "default";
 				#address-cells = <1>;
 				#size-cells = <0>;
 				reg = <0>;
 				dsa,member = <0 1>;
+				interrupt-parent = <&gpio0>;
+				interrupts = <26 IRQ_TYPE_LEVEL_LOW>;
+				interrupt-controller;
+				#interrupt-cells = <2>;
 
 				ports {
 					#address-cells = <1>;
@@ -196,12 +229,18 @@
 					#size-cells = <0>;
 					switch1phy0: switch1phy0@0 {
 						reg = <0>;
+						interrupt-parent = <&switch1>;
+						interrupts = <0 IRQ_TYPE_LEVEL_HIGH>;
 					};
 					switch1phy1: switch1phy0@1 {
 						reg = <1>;
+						interrupt-parent = <&switch1>;
+						interrupts = <2 IRQ_TYPE_LEVEL_HIGH>;
 					};
 					switch1phy2: switch1phy0@2 {
 						reg = <2>;
+						interrupt-parent = <&switch1>;
+						interrupts = <2 IRQ_TYPE_LEVEL_HIGH>;
 					};
 				};
 			};
@@ -636,6 +675,18 @@
 		>;
 	};
 
+	pinctrl_gpio_switch0: pinctrl-gpio-switch0 {
+		fsl,pins = <
+			VF610_PAD_PTB5__GPIO_27		0x219d
+		>;
+	};
+
+	pinctrl_gpio_switch1: pinctrl-gpio-switch1 {
+		fsl,pins = <
+			VF610_PAD_PTB4__GPIO_26		0x219d
+		>;
+	};
+
 	pinctrl_i2c_mux_reset: pinctrl-i2c-mux-reset {
 		fsl,pins = <
 			 VF610_PAD_PTE14__GPIO_119	0x31c2
-- 
2.9.3
