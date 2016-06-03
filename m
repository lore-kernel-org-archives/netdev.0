From: Andrew Lunn <andrew@lunn.ch>
Subject: [PATCH net-next 16/17] arm: dt: vf610-zii-devel-b: Make use of new DSA binding
Date: Fri,  3 Jun 2016 18:44:15 +0200
Message-ID: <1464972256-10408-17-git-send-email-andrew@lunn.ch>
References: <1464972256-10408-1-git-send-email-andrew@lunn.ch>
Cc: netdev <netdev@vger.kernel.org>, Andrew Lunn <andrew@lunn.ch>
To: David Miller <davem@davemloft.net>,
	Vivien Didelot <vivien.didelot@savoirfairelinux.com>,
	Florian Fainelli <f.fainelli@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from vps0.lunn.ch ([178.209.37.122]:58701 "EHLO vps0.lunn.ch"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1161087AbcFCQsx (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 3 Jun 2016 12:48:53 -0400
In-Reply-To: <1464972256-10408-1-git-send-email-andrew@lunn.ch>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hang the three switches of the three MDIO busses using the new DSA
binding. Also, make use of the mdio-bus and explicitly list the phys
on one device. This is not required, but good for testing.

Signed-off-by: Andrew Lunn <andrew@lunn.ch>
---
 arch/arm/boot/dts/vf610-zii-dev-rev-b.dts | 328 ++++++++++++++++--------------
 1 file changed, 170 insertions(+), 158 deletions(-)

diff --git a/arch/arm/boot/dts/vf610-zii-dev-rev-b.dts b/arch/arm/boot/dts/vf610-zii-dev-rev-b.dts
index 6c60b7f91104..5c1fcab4a6f7 100644
--- a/arch/arm/boot/dts/vf610-zii-dev-rev-b.dts
+++ b/arch/arm/boot/dts/vf610-zii-dev-rev-b.dts
@@ -85,187 +85,199 @@
 			reg = <1>;
 			#address-cells = <1>;
 			#size-cells = <0>;
+
+			switch0: switch0@0 {
+				compatible = "marvell,mv88e6085";
+				#address-cells = <1>;
+				#size-cells = <0>;
+				reg = <0>;
+				dsa,member = <0 0>;
+
+				ports {
+					#address-cells = <1>;
+					#size-cells = <0>;
+					port@0 {
+						reg = <0>;
+						label = "lan0";
+					};
+
+					port@1 {
+						reg = <1>;
+						label = "lan1";
+					};
+
+					port@2 {
+						reg = <2>;
+						label = "lan2";
+					};
+
+					switch0port5: port@5 {
+						reg = <5>;
+						label = "dsa";
+						phy-mode = "rgmii-txid";
+						link = <&switch1port6
+							&switch2port9>;
+						fixed-link {
+							speed = <1000>;
+							full-duplex;
+						};
+					};
+
+					port@6 {
+						reg = <6>;
+						label = "cpu";
+						ethernet = <&fec1>;
+						fixed-link {
+							speed = <100>;
+							full-duplex;
+						};
+					};
+				};
+			};
 		};
 
 		mdio_mux_2: mdio@2 {
 			reg = <2>;
 			#address-cells = <1>;
 			#size-cells = <0>;
-		};
-
-		mdio_mux_4: mdio@4 {
-			reg = <4>;
-			#address-cells = <1>;
-			#size-cells = <0>;
-		};
-
-		mdio_mux_8: mdio@8 {
-			reg = <8>;
-			#address-cells = <1>;
-			#size-cells = <0>;
-		};
-	};
-
-	dsa {
-		compatible = "marvell,dsa";
-		#address-cells = <2>;
-		#size-cells = <0>;
-		dsa,ethernet = <&fec1>;
-		dsa,mii-bus = <&mdio_mux_1>;
-
-		/* 6352 - Primary - 7 ports */
-		switch0: switch@0-0 {
-			#address-cells = <1>;
-			#size-cells = <0>;
-			reg = <0x00 0>;
-			eeprom-length = <512>;
 
-			port@0 {
+			switch1: switch1@0 {
+				compatible = "marvell,mv88e6085";
+				#address-cells = <1>;
+				#size-cells = <0>;
 				reg = <0>;
-				label = "lan0";
-			};
-
-			port@1 {
-				reg = <1>;
-				label = "lan1";
-			};
-
-			port@2 {
-				reg = <2>;
-				label = "lan2";
-			};
-
-			switch0port5: port@5 {
-				reg = <5>;
-				label = "dsa";
-				phy-mode = "rgmii-txid";
-				link = <&switch1port6
-					&switch2port9>;
-
-				fixed-link {
-					speed = <1000>;
-					full-duplex;
+				dsa,member = <0 1>;
+
+				ports {
+					#address-cells = <1>;
+					#size-cells = <0>;
+					port@0 {
+						reg = <0>;
+						label = "lan3";
+						phy-handle = <&switch1phy0>;
+					};
+
+					port@1 {
+						reg = <1>;
+						label = "lan4";
+						phy-handle = <&switch1phy1>;
+					};
+
+					port@2 {
+						reg = <2>;
+						label = "lan5";
+						phy-handle = <&switch1phy2>;
+					};
+
+					switch1port5: port@5 {
+						reg = <5>;
+						label = "dsa";
+						link = <&switch2port9>;
+						phy-mode = "rgmii-txid";
+						fixed-link {
+							speed = <1000>;
+							full-duplex;
+						};
+					};
+
+					switch1port6: port@6 {
+						reg = <6>;
+						label = "dsa";
+						phy-mode = "rgmii-txid";
+						link = <&switch0port5>;
+						fixed-link {
+							speed = <1000>;
+							full-duplex;
+						};
+					};
 				};
-			};
-
-			port@6 {
-				reg = <6>;
-				label = "cpu";
-
-				fixed-link {
-					speed = <100>;
-					full-duplex;
+				mdio {
+					#address-cells = <1>;
+					#size-cells = <0>;
+					switch1phy0: switch1phy0@0 {
+						reg = <0>;
+					};
+					switch1phy1: switch1phy0@1 {
+						reg = <1>;
+					};
+					switch1phy2: switch1phy0@2 {
+						reg = <2>;
+					};
 				};
 			};
-
 		};
 
-		/* 6352 - Secondary - 7 ports */
-		switch1: switch@0-1 {
+		mdio_mux_4: mdio@4 {
 			#address-cells = <1>;
 			#size-cells = <0>;
-			reg = <0x00 1>;
-			eeprom-length = <512>;
-			mii-bus = <&mdio_mux_2>;
+			reg = <4>;
 
-			port@0 {
+			switch2: switch2@0 {
+				compatible = "marvell,mv88e6085";
+				#address-cells = <1>;
+				#size-cells = <0>;
 				reg = <0>;
-				label = "lan3";
-			};
-
-			port@1 {
-				reg = <1>;
-				label = "lan4";
-			};
-
-			port@2 {
-				reg = <2>;
-				label = "lan5";
-			};
-
-			switch1port5: port@5 {
-				reg = <5>;
-				label = "dsa";
-				link = <&switch2port9>;
-				phy-mode = "rgmii-txid";
-
-				fixed-link {
-					speed = <1000>;
-					full-duplex;
-				};
-			};
-
-			switch1port6: port@6 {
-				reg = <6>;
-				label = "dsa";
-				phy-mode = "rgmii-txid";
-				link = <&switch0port5>;
-
-				fixed-link {
-					speed = <1000>;
-					full-duplex;
+				dsa,member = <0 2>;
+
+				ports {
+					#address-cells = <1>;
+					#size-cells = <0>;
+					port@0 {
+						reg = <0>;
+						label = "lan6";
+					};
+
+					port@1 {
+						reg = <1>;
+						label = "lan7";
+					};
+
+					port@2 {
+						reg = <2>;
+						label = "lan8";
+					};
+
+					port@3 {
+						reg = <3>;
+						label = "optical3";
+						fixed-link {
+							speed = <1000>;
+							full-duplex;
+							link-gpios = <&gpio6 2
+							      GPIO_ACTIVE_HIGH>;
+						};
+					};
+
+					port@4 {
+						reg = <4>;
+						label = "optical4";
+						fixed-link {
+							speed = <1000>;
+							full-duplex;
+							link-gpios = <&gpio6 3
+							      GPIO_ACTIVE_HIGH>;
+						};
+					};
+
+					switch2port9: port@9 {
+						reg = <9>;
+						label = "dsa";
+						phy-mode = "rgmii-txid";
+						link = <&switch1port5
+							&switch0port5>;
+						fixed-link {
+							speed = <1000>;
+							full-duplex;
+						};
+					};
 				};
 			};
 		};
 
-		/* 6185 - 10 ports */
-		switch2: switch@0-2 {
+		mdio_mux_8: mdio@8 {
+			reg = <8>;
 			#address-cells = <1>;
 			#size-cells = <0>;
-			reg = <0x00 2>;
-			mii-bus = <&mdio_mux_4>;
-
-			port@0 {
-				reg = <0>;
-				label = "lan6";
-			};
-
-			port@1 {
-				reg = <1>;
-				label = "lan7";
-			};
-
-			port@2 {
-				reg = <2>;
-				label = "lan8";
-			};
-
-			port@3 {
-				reg = <3>;
-				label = "optical3";
-
-				fixed-link {
-					speed = <1000>;
-					full-duplex;
-					link-gpios = <&gpio6 2
-						      GPIO_ACTIVE_HIGH>;
-				};
-			};
-
-			port@4 {
-				reg = <4>;
-				label = "optical4";
-
-				fixed-link {
-					speed = <1000>;
-					full-duplex;
-					link-gpios = <&gpio6 3
-						      GPIO_ACTIVE_HIGH>;
-				};
-			};
-
-			switch2port9: port@9 {
-				reg = <9>;
-				label = "dsa";
-				phy-mode = "rgmii-txid";
-				link = <&switch1port5
-					&switch0port5>;
-
-				fixed-link {
-					speed = <1000>;
-					full-duplex;
-				};
-			};
 		};
 	};
 
-- 
2.8.1
