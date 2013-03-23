From: Maxime Ripard <maxime.ripard@free-electrons.com>
Subject: [PATCH 5/5] ARM: hackberry: dt: Add Ethernet controller to the Hackberry device tree
Date: Sat, 23 Mar 2013 23:30:14 +0100
Message-ID: <1364077814-2233-6-git-send-email-maxime.ripard@free-electrons.com>
References: <1364077814-2233-1-git-send-email-maxime.ripard@free-electrons.com>
Cc: kevin@allwinnertech.com, sunny@allwinnertech.com,
	shuge@allwinnertech.com, netdev@vger.kernel.org,
	Stefan Roese <sr@denx.de>, Alejandro Mery <amery@geeks.cl>,
	Russell King <linux@arm.linux.org.uk>,
	linux-kernel@vger.kernel.org
To: linux-arm-kernel@lists.infradead.org
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1364077814-2233-1-git-send-email-maxime.ripard@free-electrons.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

The Hackberry has a PHY that needs to be powered up through a GPIO, so
we need to use a fixed regulator here.

Signed-off-by: Maxime Ripard <maxime.ripard@free-electrons.com>
---
 arch/arm/boot/dts/sun4i-a10-hackberry.dts |   32 +++++++++++++++++++++++++++++
 1 file changed, 32 insertions(+)

diff --git a/arch/arm/boot/dts/sun4i-a10-hackberry.dts b/arch/arm/boot/dts/sun4i-a10-hackberry.dts
index f84549a..072d51f 100644
--- a/arch/arm/boot/dts/sun4i-a10-hackberry.dts
+++ b/arch/arm/boot/dts/sun4i-a10-hackberry.dts
@@ -23,8 +23,40 @@
 	};
 
 	soc {
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
 		uart0: uart@01c28000 {
 			status = "okay";
 		};
+
+		emac: ethernet@01c0b000 {
+			pinctrl-names = "default";
+			pinctrl-0 = <&emac_pins_a>;
+			phy-supply = <&reg_emac_3v3>;
+			status = "okay";
+		};
+	};
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
 	};
 };
-- 
1.7.10.4
