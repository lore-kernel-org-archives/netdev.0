From: Maxime Ripard <maxime.ripard@free-electrons.com>
Subject: [PATCHv4 6/6] ARM: sunxi: Add EMAC Controller to Hackberry dt
Date: Thu, 30 May 2013 15:49:25 +0200
Message-ID: <1369921765-3367-7-git-send-email-maxime.ripard@free-electrons.com>
References: <1369921765-3367-1-git-send-email-maxime.ripard@free-electrons.com>
Cc: linux-arm-kernel@lists.infradead.org, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org, Stefan Roese <sr@denx.de>,
	Florian Fainelli <florian@openwrt.org>,
	Emilio Lopez <emilio@elopez.com.ar>, kevin@allwinnertech.com,
	sunny@allwinnertech.com, shuge@allwinnertech.com,
	Maxime Ripard <maxime.ripard@free-electrons.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.free-electrons.com ([94.23.35.102]:39075 "EHLO
	mail.free-electrons.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756661Ab3E3Nts (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 30 May 2013 09:49:48 -0400
In-Reply-To: <1369921765-3367-1-git-send-email-maxime.ripard@free-electrons.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The Hackberry has a PHY that needs to be powered up through a GPIO, so
we need to use a fixed regulator here.

Signed-off-by: Maxime Ripard <maxime.ripard@free-electrons.com>
Tested-by: Richard Genoud <richard.genoud@gmail.com>
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
1.8.2.3
