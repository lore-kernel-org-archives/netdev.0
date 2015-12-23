From: Andrew Lunn <andrew@lunn.ch>
Subject: [PATCH RFC 20/28] vf610: Zii: Convert rev b to switches as individual devices
Date: Wed, 23 Dec 2015 13:56:34 +0100
Message-ID: <1450875402-20740-21-git-send-email-andrew@lunn.ch>
References: <1450875402-20740-1-git-send-email-andrew@lunn.ch>
Cc: netdev <netdev@vger.kernel.org>, Andrew Lunn <andrew@lunn.ch>
To: Florian Fainelli <f.fainelli@gmail.com>, narmstrong@baylibre.com,
	vivien.didelot@savoirfairelinux.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from vps0.lunn.ch ([178.209.37.122]:48695 "EHLO vps0.lunn.ch"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1757095AbbLWM5e (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 23 Dec 2015 07:57:34 -0500
In-Reply-To: <1450875402-20740-1-git-send-email-andrew@lunn.ch>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

DSA now expects switches to be true devices with a phandle pointing to
them. Adapt the DT file to this new scheme.
---
 arch/arm/boot/dts/vf610-zii-dev-rev-b.dts | 34 ++++++++++++++++++++++++-------
 1 file changed, 27 insertions(+), 7 deletions(-)

diff --git a/arch/arm/boot/dts/vf610-zii-dev-rev-b.dts b/arch/arm/boot/dts/vf610-zii-dev-rev-b.dts
index 6e657a9312ce..87dc17adb894 100644
--- a/arch/arm/boot/dts/vf610-zii-dev-rev-b.dts
+++ b/arch/arm/boot/dts/vf610-zii-dev-rev-b.dts
@@ -77,13 +77,13 @@
 		#size-cells = <0>;
 
 		dsa,ethernet = <&fec1>;
-		dsa,mii-bus = <&mdio_mux_1>;
 
 		/* 6352 - Primary - 7 ports */
 		switch0: switch@2 {
 			#address-cells = <1>;
 			#size-cells = <0>;
-			reg = <0x00 0>;
+			reg = <0 0>;
+			switch = <&switchdev0>;
 			eeprom-length = <512>;
 
 			port@0 {
@@ -121,16 +121,15 @@
 					full-duplex;
 				};
 			};
-
 		};
 
 		/* 6352 - Secondary - 7 ports */
 		switch1: switch@0 {
 			#address-cells = <1>;
 			#size-cells = <0>;
-			reg = <0x00 1>;
+			switch = <&switchdev1>;
+			reg = <0 1>;
 			eeprom-length = <512>;
-			mii-bus = <&mdio_mux_2>;
 
 			port@0 {
 				reg = <0>;
@@ -174,8 +173,8 @@
 		switch2: switch@6 {
 			#address-cells = <1>;
 			#size-cells = <0>;
-			reg = <0x00 2>;
-			mii-bus = <&mdio_mux_4>;
+			switch = <&switchdev2>;
+			reg = <0 2>;
 
 			port@0 {
 				reg = <0>;
@@ -226,6 +225,27 @@
 			};
 		};
 	};
+
+	/* Primary switch */
+	switchdev0: switchdev0 {
+		compatible = "marvell,mv88e6352";
+		mii-bus = <&mdio_mux_1>;
+		addr = <0>;
+	};
+
+	/* Secondary switch */
+	switchdev1: switchdev1 {
+		compatible = "marvell,mv88e6352";
+		mii-bus = <&mdio_mux_2>;
+		addr = <0>;
+	};
+
+	/* 6185 10-port switch */
+	switchdev2: switchdev2 {
+		compatible = "marvell,mv88e6131";
+		mii-bus = <&mdio_mux_4>;
+		addr = <0>;
+	};
 };
 
 &iomuxc {
-- 
2.6.3
