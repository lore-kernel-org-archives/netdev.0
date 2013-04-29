From: Maxime Ripard <maxime.ripard@free-electrons.com>
Subject: [PATCH 6/6] ARM: sunxi: Add EMAC Controller to Hackberry dt
Date: Mon, 29 Apr 2013 21:36:58 +0200
Message-ID: <1367264218-15235-7-git-send-email-maxime.ripard@free-electrons.com>
References: <1367264218-15235-1-git-send-email-maxime.ripard@free-electrons.com>
Cc: kevin@allwinnertech.com, sunny@allwinnertech.com,
	shuge@allwinnertech.com, netdev@vger.kernel.org,
	Alejandro Mery <amery@geeks.cl>,
	Emilio Lopez <emilio@elopez.com.ar>, Stefan Roese <sr@denx.de>,
	Florian Fainelly <florian@openwrt.org>,
	Maxime Ripard <maxime.ripard@free-electrons.com>,
	Russell King <linux@arm.linux.org.uk>,
	linux-kernel@vger.kernel.org
To: linux-arm-kernel@lists.infradead.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.free-electrons.com ([94.23.35.102]:50799 "EHLO
	mail.free-electrons.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1759795Ab3D2ThI (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 29 Apr 2013 15:37:08 -0400
In-Reply-To: <1367264218-15235-1-git-send-email-maxime.ripard@free-electrons.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The Hackberry has a PHY that needs to be powered up through a GPIO, so
we need to use a fixed regulator here.

Signed-off-by: Maxime Ripard <maxime.ripard@free-electrons.com>
---
 arch/arm/boot/dts/sun4i-a10-hackberry.dts | 41 +++++++++++++++++++++++++++++++
 1 file changed, 41 insertions(+)

diff --git a/arch/arm/boot/dts/sun4i-a10-hackberry.dts b/arch/arm/boot/dts/sun4i-a10-hackberry.dts
index b9efac1..3514b37 100644
--- a/arch/arm/boot/dts/sun4i-a10-hackberry.dts
+++ b/arch/arm/boot/dts/sun4i-a10-hackberry.dts
@@ -23,10 +23,51 @@
 	};
 
 	soc@01c20000 {
+		emac: ethernet@01c0b000 {
+			pinctrl-names = "default";
+			pinctrl-0 = <&emac_pins_a>;
+			phy = <&phy0>;
+			status = "okay";
+		};
+
+		mdio@01c0b080 {
+			phy-supply = <&reg_emac_3v3>;
+			status = "okay";
+
+			phy0: ethernet-phy@0 {
+				reg = <0>;
+			};
+		};
+
+		pio: pinctrl@01c20800 {
+			pinctrl-names = "default";
+			pinctrl-0 = <&hackberry_hogs>;
+
+			hackberry_hogs: hogs@0 {
+				allwinner,pins = "PH19";
+				allwinner,function = "gpio_out";
+				allwinner,drive = <0>;
+				allwinner,pull = <0>;
+			};
+		};
+
 		uart0: serial@01c28000 {
 			pinctrl-names = "default";
 			pinctrl-0 = <&uart0_pins_a>;
 			status = "okay";
 		};
 	};
+
+	regulators {
+		compatible = "simple-bus";
+
+		reg_emac_3v3: emac-3v3 {
+			compatible = "regulator-fixed";
+			regulator-name = "emac-3v3";
+			regulator-min-microvolt = <3300000>;
+			regulator-max-microvolt = <3300000>;
+			enable-active-high;
+			gpio = <&pio 7 19 0>;
+		};
+	};
 };
-- 
1.8.1.2
