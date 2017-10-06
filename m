From: <Tristram.Ha@microchip.com>
Subject: [PATCH RFC] Add other KSZ switch support so that patch check does not complain
Date: Fri, 6 Oct 2017 13:33:29 -0700
Message-ID: <1507322009-15142-1-git-send-email-Tristram.Ha@microchip.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: Tristram Ha <Tristram.Ha@microchip.com>, <muvarov@gmail.com>,
        <nathan.leigh.conrad@gmail.com>,
        <vivien.didelot@savoirfairelinux.com>,
        <UNGLinuxDriver@microchip.com>, <netdev@vger.kernel.org>,
        <linux-kernel@vger.kernel.org>
To: Andrew Lunn <andrew@lunn.ch>,
        Florian Fainelli <f.fainelli@gmail.com>,
        Pavel Machek <pavel@ucw.cz>,
        Ruediger Schmitt <ruediger.schmitt@philips.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Tristram Ha <Tristram.Ha@microchip.com>

Add other KSZ switch support so that patch check does not complain.

Signed-off-by: Tristram Ha <Tristram.Ha@microchip.com>
---
 Documentation/devicetree/bindings/net/dsa/ksz.txt | 189 ++++++++++++++++------
 1 file changed, 136 insertions(+), 53 deletions(-)

diff --git a/Documentation/devicetree/bindings/net/dsa/ksz.txt b/Documentation/devicetree/bindings/net/dsa/ksz.txt
index fd23904..705f9d9 100644
--- a/Documentation/devicetree/bindings/net/dsa/ksz.txt
+++ b/Documentation/devicetree/bindings/net/dsa/ksz.txt
@@ -3,8 +3,15 @@ Microchip KSZ Series Ethernet switches
 
 Required properties:
 
-- compatible: For external switch chips, compatible string must be exactly one
-  of: "microchip,ksz9477"
+- compatible: "microchip,ksz9477",
+	      "microchip,ksz8795",
+	      "microchip,ksz8794",
+	      "microchip,ksz8765",
+	      "microchip,ksz8895",
+	      "microchip,ksz8864",
+	      "microchip,ksz8873",
+	      "microchip,ksz8863",
+	      "microchip,ksz8463"
 
 See Documentation/devicetree/bindings/dsa/dsa.txt for a list of additional
 required and optional properties.
@@ -13,58 +20,134 @@ Examples:
 
 Ethernet switch connected via SPI to the host, CPU port wired to eth0:
 
-                             eth0: ethernet@10001000 {
-                                             fixed-link {
-                                                             speed = <1000>;
-                                                             full-duplex;
-                                             };
-                             };
+	eth0: ethernet@10001000 {
+		fixed-link {
+			speed = <1000>;
+			full-duplex;
+		};
+	};
 
-                             spi1: spi@f8008000 {
-                                             pinctrl-0 = <&pinctrl_spi_ksz>;
-                                             cs-gpios = <&pioC 25 0>;
-                                             id = <1>;
+	spi1: spi@f8008000 {
+		cs-gpios = <&pioC 25 0>;
+		id = <1>;
 
-                                             ksz9477: ksz9477@0 {
-                                                             compatible = "microchip,ksz9477";
-                                                             reg = <0>;
+		ksz9477: ksz9477@0 {
+			compatible = "microchip,ksz9477";
+			reg = <0>;
 
-                                                             spi-max-frequency = <44000000>;
-                                                             spi-cpha;
-                                                             spi-cpol;
+			spi-max-frequency = <44000000>;
+			spi-cpha;
+			spi-cpol;
+
+			ports {
+				#address-cells = <1>;
+				#size-cells = <0>;
+				port@0 {
+					reg = <0>;
+					label = "lan1";
+				};
+				port@1 {
+					reg = <1>;
+					label = "lan2";
+				};
+				port@2 {
+					reg = <2>;
+					label = "lan3";
+				};
+				port@3 {
+					reg = <3>;
+					label = "lan4";
+				};
+				port@4 {
+					reg = <4>;
+					label = "lan5";
+				};
+				port@5 {
+					reg = <5>;
+					label = "cpu";
+					ethernet = <&eth0>;
+					fixed-link {
+						speed = <1000>;
+						full-duplex;
+					};
+				};
+				port@6 {
+					reg = <6>;
+					label = "lan6";
+					fixed-link {
+						speed = <1000>;
+						full-duplex;
+					};
+				};
+			};
+		};
+		ksz8794: ksz8794@0 {
+			compatible = "microchip,ksz8794";
+			reg = <0>;
+
+			spi-max-frequency = <30000000>;
+			spi-cpha;
+			spi-cpol;
+
+			ports {
+				#address-cells = <1>;
+				#size-cells = <0>;
+				port@0 {
+					reg = <0>;
+					label = "lan1";
+				};
+				port@1 {
+					reg = <1>;
+					label = "lan2";
+				};
+				port@2 {
+					reg = <2>;
+					label = "lan3";
+				};
+				port@3 {
+					reg = <4>;
+					label = "cpu";
+					ethernet = <&eth0>;
+					fixed-link {
+						speed = <100>;
+						full-duplex;
+					};
+				};
+			};
+		};
+		ksz8864: ksz8864@0 {
+			compatible = "microchip,ksz8864";
+			reg = <0>;
+
+			spi-max-frequency = <12000000>;
+			spi-cpha;
+			spi-cpol;
+
+			ports {
+				#address-cells = <1>;
+				#size-cells = <0>;
+				port@0 {
+					reg = <1>;
+					label = "lan1";
+				};
+				port@1 {
+					reg = <2>;
+					label = "lan2";
+				};
+				port@2 {
+					reg = <3>;
+					label = "lan3";
+				};
+				port@3 {
+					reg = <4>;
+					label = "cpu";
+					ethernet = <&eth0>;
+					fixed-link {
+						speed = <100>;
+						full-duplex;
+					};
+				};
+			};
+		};
+	};
 
-                                                             ports {
-                                                                             #address-cells = <1>;
-                                                                             #size-cells = <0>;
-                                                                             port@0 {
-                                                                                             reg = <0>;
-                                                                                             label = "lan1";
-                                                                             };
-                                                                             port@1 {
-                                                                                             reg = <1>;
-                                                                                             label = "lan2";
-                                                                             };
-                                                                             port@2 {
-                                                                                             reg = <2>;
-                                                                                             label = "lan3";
-                                                                             };
-                                                                             port@3 {
-                                                                                             reg = <3>;
-                                                                                             label = "lan4";
-                                                                             };
-                                                                             port@4 {
-                                                                                             reg = <4>;
-                                                                                             label = "lan5";
-                                                                             };
-                                                                             port@5 {
-                                                                                             reg = <5>;
-                                                                                             label = "cpu";
-                                                                                             ethernet = <&eth0>;
-                                                                                             fixed-link {
-                                                                                                             speed = <1000>;
-                                                                                                             full-duplex;
-                                                                                             };
-                                                                             };
-                                                             };
-                                             };
-                             };
-- 
1.9.1
