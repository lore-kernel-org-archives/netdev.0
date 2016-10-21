From: Neil Armstrong <narmstrong-rdvid1DuHRBWk0Htik3J/w@public.gmane.org>
Subject: [RFC PATCH 02/13] ARM64: dts: meson-gxbb: Move common nodes to meson-gx
Date: Fri, 21 Oct 2016 16:40:27 +0200
Message-ID: <1477060838-14164-3-git-send-email-narmstrong@baylibre.com>
References: <1477060838-14164-1-git-send-email-narmstrong@baylibre.com>
Cc: Neil Armstrong <narmstrong-rdvid1DuHRBWk0Htik3J/w@public.gmane.org>,
        linux-gpio-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, devicetree-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
        linux-arm-kernel-IAPFreCvJWM7uuMidbF8XUB+6BGkLq7r@public.gmane.org,
        linux-amlogic-IAPFreCvJWM7uuMidbF8XUB+6BGkLq7r@public.gmane.org, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
        netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: khilman-rdvid1DuHRBWk0Htik3J/w@public.gmane.org, carlo-KA+7E9HrN00dnm+yROfE0A@public.gmane.org, linus.walleij-QSEj5FYQhm4dnm+yROfE0A@public.gmane.org
Return-path: <devicetree-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <1477060838-14164-1-git-send-email-narmstrong-rdvid1DuHRBWk0Htik3J/w@public.gmane.org>
Sender: devicetree-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

Move common nodes between GXBB and GXL in to the common GX dtsi.
Leave the clock attributes in the GXBB dtsi for now.

Signed-off-by: Neil Armstrong <narmstrong-rdvid1DuHRBWk0Htik3J/w@public.gmane.org>
---
 arch/arm64/boot/dts/amlogic/meson-gx.dtsi   | 131 +++++++++++++++++++++++
 arch/arm64/boot/dts/amlogic/meson-gxbb.dtsi | 155 ++++------------------------
 2 files changed, 149 insertions(+), 137 deletions(-)

diff --git a/arch/arm64/boot/dts/amlogic/meson-gx.dtsi b/arch/arm64/boot/dts/amlogic/meson-gx.dtsi
index fd1d0de..91be4f2 100644
--- a/arch/arm64/boot/dts/amlogic/meson-gx.dtsi
+++ b/arch/arm64/boot/dts/amlogic/meson-gx.dtsi
@@ -129,6 +129,30 @@
 		#clock-cells = <0>;
 	};
 
+	firmware {
+		sm: secure-monitor {
+			compatible = "amlogic,meson-gx-sm", "amlogic,meson-gxbb-sm";
+		};
+	};
+
+	efuse: efuse {
+		compatible = "amlogic,meson-gx-efuse", "amlogic,meson-gxbb-efuse";
+		#address-cells = <1>;
+		#size-cells = <1>;
+
+		sn: sn@14 {
+			reg = <0x14 0x10>;
+		};
+
+		eth_mac: eth_mac@34 {
+			reg = <0x34 0x10>;
+		};
+
+		bid: bid@46 {
+			reg = <0x46 0x30>;
+		};
+	};
+
 	soc {
 		compatible = "simple-bus";
 		#address-cells = <2>;
@@ -142,6 +166,12 @@
 			#size-cells = <2>;
 			ranges = <0x0 0x0 0x0 0xc1100000 0x0 0x100000>;
 
+			reset: reset-controller@4404 {
+				compatible = "amlogic,meson-gx-reset", "amlogic,meson-gxbb-reset";
+				reg = <0x0 0x04404 0x0 0x20>;
+				#reset-cells = <1>;
+			};
+
 			uart_A: serial@84c0 {
 				compatible = "amlogic,meson-uart";
 				reg = <0x0 0x84c0 0x0 0x14>;
@@ -149,6 +179,76 @@
 				clocks = <&xtal>;
 				status = "disabled";
 			};
+
+			uart_B: serial@84dc {
+				compatible = "amlogic,meson-uart";
+				reg = <0x0 0x84dc 0x0 0x14>;
+				interrupts = <GIC_SPI 75 IRQ_TYPE_EDGE_RISING>;
+				clocks = <&xtal>;
+				status = "disabled";
+			};
+
+			i2c_A: i2c@8500 {
+				compatible = "amlogic,meson-gxbb-i2c";
+				reg = <0x0 0x08500 0x0 0x20>;
+				interrupts = <GIC_SPI 21 IRQ_TYPE_EDGE_RISING>;
+				#address-cells = <1>;
+				#size-cells = <0>;
+				status = "disabled";
+			};
+
+			pwm_ab: pwm@8550 {
+				compatible = "amlogic,meson-gx-pwm", "amlogic,meson-gxbb-pwm";
+				reg = <0x0 0x08550 0x0 0x10>;
+				#pwm-cells = <3>;
+				status = "disabled";
+			};
+
+			pwm_cd: pwm@8650 {
+				compatible = "amlogic,meson-gx-pwm", "amlogic,meson-gxbb-pwm";
+				reg = <0x0 0x08650 0x0 0x10>;
+				#pwm-cells = <3>;
+				status = "disabled";
+			};
+
+			pwm_ef: pwm@86c0 {
+				compatible = "amlogic,meson-gx-pwm", "amlogic,meson-gxbb-pwm";
+				reg = <0x0 0x086c0 0x0 0x10>;
+				#pwm-cells = <3>;
+				status = "disabled";
+			};
+
+			uart_C: serial@8700 {
+				compatible = "amlogic,meson-uart";
+				reg = <0x0 0x8700 0x0 0x14>;
+				interrupts = <GIC_SPI 93 IRQ_TYPE_EDGE_RISING>;
+				clocks = <&xtal>;
+				status = "disabled";
+			};
+
+			i2c_B: i2c@87c0 {
+				compatible = "amlogic,meson-gxbb-i2c";
+				reg = <0x0 0x087c0 0x0 0x20>;
+				interrupts = <GIC_SPI 214 IRQ_TYPE_EDGE_RISING>;
+				#address-cells = <1>;
+				#size-cells = <0>;
+				status = "disabled";
+			};
+
+			i2c_C: i2c@87e0 {
+				compatible = "amlogic,meson-gxbb-i2c";
+				reg = <0x0 0x087e0 0x0 0x20>;
+				interrupts = <GIC_SPI 215 IRQ_TYPE_EDGE_RISING>;
+				#address-cells = <1>;
+				#size-cells = <0>;
+				status = "disabled";
+			};
+
+			watchdog@98d0 {
+				compatible = "amlogic,meson-gx-wdt", "amlogic,meson-gxbb-wdt";
+				reg = <0x0 0x098d0 0x0 0x10>;
+				clocks = <&xtal>;
+			};
 		};
 
 		gic: interrupt-controller@c4301000 {
@@ -178,6 +278,13 @@
 				clocks = <&xtal>;
 				status = "disabled";
 			};
+
+			ir: ir@580 {
+				compatible = "amlogic,meson-gxbb-ir";
+				reg = <0x0 0x00580 0x0 0x40>;
+				interrupts = <GIC_SPI 196 IRQ_TYPE_EDGE_RISING>;
+				status = "disabled";
+			};
 		};
 
 		periphs: periphs@c8834000 {
@@ -186,6 +293,11 @@
 			#address-cells = <2>;
 			#size-cells = <2>;
 			ranges = <0x0 0x0 0x0 0xc8834000 0x0 0x2000>;
+
+			rng {
+				compatible = "amlogic,meson-rng";
+				reg = <0x0 0x0 0x0 0x4>;
+			};
 		};
 
 
@@ -195,6 +307,25 @@
 			#address-cells = <2>;
 			#size-cells = <2>;
 			ranges = <0x0 0x0 0x0 0xc883c000 0x0 0x2000>;
+
+			mailbox: mailbox@404 {
+				compatible = "amlogic,meson-gx-mhu", "amlogic,meson-gxbb-mhu";
+				reg = <0 0x404 0 0x4c>;
+				interrupts = <0 208 IRQ_TYPE_EDGE_RISING>,
+					     <0 209 IRQ_TYPE_EDGE_RISING>,
+					     <0 210 IRQ_TYPE_EDGE_RISING>;
+				#mbox-cells = <1>;
+			};
+		};
+
+		ethmac: ethernet@c9410000 {
+			compatible = "amlogic,meson-gx-dwmac", "amlogic,meson-gxbb-dwmac", "snps,dwmac";
+			reg = <0x0 0xc9410000 0x0 0x10000
+			       0x0 0xc8834540 0x0 0x4>;
+			interrupts = <0 8 1>;
+			interrupt-names = "macirq";
+			phy-mode = "rgmii";
+			status = "disabled";
 		};
 
 		apb: apb@d0000000 {
diff --git a/arch/arm64/boot/dts/amlogic/meson-gxbb.dtsi b/arch/arm64/boot/dts/amlogic/meson-gxbb.dtsi
index 22940bb..7c5bf14 100644
--- a/arch/arm64/boot/dts/amlogic/meson-gxbb.dtsi
+++ b/arch/arm64/boot/dts/amlogic/meson-gxbb.dtsi
@@ -50,30 +50,6 @@
 / {
 	compatible = "amlogic,meson-gxbb";
 
-	firmware {
-		sm: secure-monitor {
-			compatible = "amlogic,meson-gxbb-sm";
-		};
-	};
-
-	efuse: efuse {
-		compatible = "amlogic,meson-gxbb-efuse";
-		#address-cells = <1>;
-		#size-cells = <1>;
-
-		sn: sn@14 {
-			reg = <0x14 0x10>;
-		};
-
-		eth_mac: eth_mac@34 {
-			reg = <0x34 0x10>;
-		};
-
-		bid: bid@46 {
-			reg = <0x46 0x30>;
-		};
-	};
-
 	soc {
 		usb0_phy: phy@c0000000 {
 			compatible = "amlogic,meson-gxbb-usb2-phy";
@@ -117,73 +93,17 @@
 			dr_mode = "host";
 			status = "disabled";
 		};
-
-		ethmac: ethernet@c9410000 {
-			compatible = "amlogic,meson-gxbb-dwmac", "snps,dwmac";
-			reg = <0x0 0xc9410000 0x0 0x10000
-			       0x0 0xc8834540 0x0 0x4>;
-			interrupts = <0 8 1>;
-			interrupt-names = "macirq";
-			clocks = <&clkc CLKID_ETH>,
-				 <&clkc CLKID_FCLK_DIV2>,
-				 <&clkc CLKID_MPLL2>;
-			clock-names = "stmmaceth", "clkin0", "clkin1";
-			phy-mode = "rgmii";
-			status = "disabled";
-		};
 	};
 };
 
-&cbus {
-	reset: reset-controller@4404 {
-		compatible = "amlogic,meson-gxbb-reset";
-		reg = <0x0 0x04404 0x0 0x20>;
-		#reset-cells = <1>;
-	};
-
-	uart_B: serial@84dc {
-		compatible = "amlogic,meson-uart";
-		reg = <0x0 0x84dc 0x0 0x14>;
-		interrupts = <GIC_SPI 75 IRQ_TYPE_EDGE_RISING>;
-		clocks = <&xtal>;
-		status = "disabled";
-	};
-
-	pwm_ab: pwm@8550 {
-		compatible = "amlogic,meson-gxbb-pwm";
-		reg = <0x0 0x08550 0x0 0x10>;
-		#pwm-cells = <3>;
-		status = "disabled";
-	};
-
-	pwm_cd: pwm@8650 {
-		compatible = "amlogic,meson-gxbb-pwm";
-		reg = <0x0 0x08650 0x0 0x10>;
-		#pwm-cells = <3>;
-		status = "disabled";
-	};
-
-	pwm_ef: pwm@86c0 {
-		compatible = "amlogic,meson-gxbb-pwm";
-		reg = <0x0 0x086c0 0x0 0x10>;
-		#pwm-cells = <3>;
-		status = "disabled";
-	};
-
-	uart_C: serial@8700 {
-		compatible = "amlogic,meson-uart";
-		reg = <0x0 0x8700 0x0 0x14>;
-		interrupts = <GIC_SPI 93 IRQ_TYPE_EDGE_RISING>;
-		clocks = <&xtal>;
-		status = "disabled";
-	};
-
-	watchdog@98d0 {
-		compatible = "amlogic,meson-gxbb-wdt";
-		reg = <0x0 0x098d0 0x0 0x10>;
-		clocks = <&xtal>;
-	};
+&ethmac {
+	clocks = <&clkc CLKID_ETH>,
+		 <&clkc CLKID_FCLK_DIV2>,
+		 <&clkc CLKID_MPLL2>;
+	clock-names = "stmmaceth", "clkin0", "clkin1";
+};
 
+&cbus {
 	spifc: spi@8c80 {
 		compatible = "amlogic,meson-gxbb-spifc";
 		reg = <0x0 0x08c80 0x0 0x80>;
@@ -192,36 +112,6 @@
 		clocks = <&clkc CLKID_SPI>;
 		status = "disabled";
 	};
-
-	i2c_A: i2c@8500 {
-		compatible = "amlogic,meson-gxbb-i2c";
-		reg = <0x0 0x08500 0x0 0x20>;
-		interrupts = <GIC_SPI 21 IRQ_TYPE_EDGE_RISING>;
-		clocks = <&clkc CLKID_I2C>;
-		#address-cells = <1>;
-		#size-cells = <0>;
-		status = "disabled";
-	};
-
-	i2c_B: i2c@87c0 {
-		compatible = "amlogic,meson-gxbb-i2c";
-		reg = <0x0 0x087c0 0x0 0x20>;
-		interrupts = <GIC_SPI 214 IRQ_TYPE_EDGE_RISING>;
-		clocks = <&clkc CLKID_I2C>;
-		#address-cells = <1>;
-		#size-cells = <0>;
-		status = "disabled";
-	};
-
-	i2c_C: i2c@87e0 {
-		compatible = "amlogic,meson-gxbb-i2c";
-		reg = <0x0 0x087e0 0x0 0x20>;
-		interrupts = <GIC_SPI 215 IRQ_TYPE_EDGE_RISING>;
-		clocks = <&clkc CLKID_I2C>;
-		#address-cells = <1>;
-		#size-cells = <0>;
-		status = "disabled";
-	};
 };
 
 &aobus {
@@ -298,13 +188,6 @@
 		#reset-cells = <1>;
 	};
 
-	ir: ir@580 {
-		compatible = "amlogic,meson-gxbb-ir";
-		reg = <0x0 0x00580 0x0 0x40>;
-		interrupts = <GIC_SPI 196 IRQ_TYPE_EDGE_RISING>;
-		status = "disabled";
-	};
-
 	pwm_ab_AO: pwm@550 {
 		compatible = "amlogic,meson-gxbb-pwm";
 		reg = <0x0 0x0550 0x0 0x10>;
@@ -324,11 +207,6 @@
 };
 
 &periphs {
-	rng {
-		compatible = "amlogic,meson-rng";
-		reg = <0x0 0x0 0x0 0x4>;
-	};
-
 	pinctrl_periphs: pinctrl@4b0 {
 		compatible = "amlogic,meson-gxbb-periphs-pinctrl";
 		#address-cells = <2>;
@@ -536,15 +414,18 @@
 		#clock-cells = <1>;
 		reg = <0x0 0x0 0x0 0x3db>;
 	};
+};
 
-	mailbox: mailbox@404 {
-		compatible = "amlogic,meson-gxbb-mhu";
-		reg = <0 0x404 0 0x4c>;
-		interrupts = <0 208 IRQ_TYPE_EDGE_RISING>,
-			     <0 209 IRQ_TYPE_EDGE_RISING>,
-			     <0 210 IRQ_TYPE_EDGE_RISING>;
-		#mbox-cells = <1>;
-	};
+&i2c_A {
+	clocks = <&clkc CLKID_I2C>;
+};
+
+&i2c_B {
+	clocks = <&clkc CLKID_I2C>;
+};
+
+&i2c_C {
+	clocks = <&clkc CLKID_I2C>;
 };
 
 &sd_emmc_a {
-- 
1.9.1

--
To unsubscribe from this list: send the line "unsubscribe devicetree" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
