From: <Woojung.Huh@microchip.com>
Subject: [PATCH v4 net-next 4/5] net: dsa: Add Microchip KSZ switches binding
Date: Tue, 30 May 2017 15:44:52 +0000
Message-ID: <9235D6609DB808459E95D78E17F2E43D40AA45AB@CHN-SV-EXMX02.mchp-main.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 8BIT
Cc: <netdev@vger.kernel.org>, <davem@davemloft.net>,
        <UNGLinuxDriver@microchip.com>
To: <andrew@lunn.ch>, <f.fainelli@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from esa4.microchip.iphmx.com ([68.232.154.123]:35472 "EHLO
        esa4.microchip.iphmx.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1750996AbdE3Poy (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 30 May 2017 11:44:54 -0400
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Woojung Huh <Woojung.Huh@microchip.com>

A sample SPI configuration for Microchip KSZ switches.

Signed-off-by: Woojung Huh <Woojung.Huh@microchip.com>
Reviewed-by: Andrew Lunn <andrew@lunn.ch>
Reviewed-by: Florian Fainelli <f.fainelli@gmail.com>
---
 Documentation/devicetree/bindings/net/dsa/ksz.txt | 72 +++++++++++++++++++++++
 1 file changed, 72 insertions(+)
 create mode 100644 Documentation/devicetree/bindings/net/dsa/ksz.txt

diff --git a/Documentation/devicetree/bindings/net/dsa/ksz.txt b/Documentation/devicetree/bindings/net/dsa/ksz.txt
new file mode 100644
index 0000000..9acdb6c
--- /dev/null
+++ b/Documentation/devicetree/bindings/net/dsa/ksz.txt
@@ -0,0 +1,72 @@
+Microchip KSZ Series Ethernet switches
+==================================
+
+Required properties:
+
+- compatible: For external switch chips, compatible string must be exactly one
+  of: "microchip,ksz9477"
+
+See Documentation/devicetree/bindings/dsa/dsa.txt for a list of additional
+required and optional properties.
+
+Examples:
+
+Ethernet switch connected via SPI to the host, CPU port wired to eth0:
+
+		eth0: ethernet@10001000 {
+			fixed-link {
+				speed = <1000>;
+				full-duplex;
+			};
+		};
+
+		spi1: spi@f8008000 {
+			pinctrl-0 = <&pinctrl_spi_ksz>;
+			cs-gpios = <&pioC 25 0>;
+			id = <1>;
+			status = "okay";
+
+			ksz9477: ksz9477@0 {
+				compatible = "microchip,ksz9477";
+				reg = <0>;
+
+				spi-max-frequency = <44000000>;
+				spi-cpha;
+				spi-cpol;
+
+				status = "okay";
+				ports {
+					#address-cells = <1>;
+					#size-cells = <0>;
+					port@0 {
+						reg = <0>;
+						label = "lan1";
+					};
+					port@1 {
+						reg = <1>;
+						label = "lan2";
+					};
+					port@2 {
+						reg = <2>;
+						label = "lan3";
+					};
+					port@3 {
+						reg = <3>;
+						label = "lan4";
+					};
+					port@4 {
+						reg = <4>;
+						label = "lan5";
+					};
+					port@5 {
+						reg = <5>;
+						label = "cpu";
+						ethernet = <&eth0>;
+						fixed-link {
+							speed = <1000>;
+							full-duplex;
+						};
+					};
+				};
+			};
+		};
-- 
2.7.4
