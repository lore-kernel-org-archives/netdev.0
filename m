From: Martin Blumenstingl <martin.blumenstingl@googlemail.com>
Subject: [PATCH RFC 3/3] ARM64: dts: meson-gxbb: use the new meson8b DWMAC glue
Date: Sat, 25 Jun 2016 18:50:13 +0200
Message-ID: <20160625165013.15917-4-martin.blumenstingl@googlemail.com>
References: <20160625165013.15917-1-martin.blumenstingl@googlemail.com>
Cc: carlo@caione.org, khilman@baylibre.com, robh+dt@kernel.org,
	mark.rutland@arm.com, netdev@vger.kernel.org,
	peppe.cavallaro@st.com,
	Martin Blumenstingl <martin.blumenstingl@googlemail.com>
To: linux-amlogic@lists.infradead.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f65.google.com ([74.125.82.65]:34464 "EHLO
	mail-wm0-f65.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751573AbcFYQu0 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 25 Jun 2016 12:50:26 -0400
Received: by mail-wm0-f65.google.com with SMTP id 187so13358922wmz.1
        for <netdev@vger.kernel.org>; Sat, 25 Jun 2016 09:50:25 -0700 (PDT)
In-Reply-To: <20160625165013.15917-1-martin.blumenstingl@googlemail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The Amlogic reference driver uses the "mc_val" devicetree property to
configure the PRG_ETHERNET_ADDR0 register. Unfortunately it uses magic
values for this configuration.

According to the datasheet the PRG_ETHERNET_ADDR0 register is at address
0xc8834108. However, the reference driver uses 0xc8834540 instead.
According to my tests, the value from the reference driver is correct.

The updated examples are representing 0x1621 from the reference driver's
mc_val property, which is used when there is an external gbit PHY
connected.
For RMII mode PHYs mc_val 0x1800 is used in the reference driver, which
translates  would translate to "do not set any of the following
properties" (as the two bits are configured automatically):
- amlogic,enable-25mhz-phy-clk
- amlogic,mp2-clock
- amlogic,tx-delay

Signed-off-by: Martin Blumenstingl <martin.blumenstingl@googlemail.com>
---
 arch/arm64/boot/dts/amlogic/meson-gxbb-odroidc2.dts  |  4 ++++
 arch/arm64/boot/dts/amlogic/meson-gxbb-p20x.dtsi     |  4 ++++
 arch/arm64/boot/dts/amlogic/meson-gxbb-vega-s95.dtsi |  4 ++++
 arch/arm64/boot/dts/amlogic/meson-gxbb.dtsi          | 12 +++++++++---
 4 files changed, 21 insertions(+), 3 deletions(-)

diff --git a/arch/arm64/boot/dts/amlogic/meson-gxbb-odroidc2.dts b/arch/arm64/boot/dts/amlogic/meson-gxbb-odroidc2.dts
index b06bf8a..8d540ff 100644
--- a/arch/arm64/boot/dts/amlogic/meson-gxbb-odroidc2.dts
+++ b/arch/arm64/boot/dts/amlogic/meson-gxbb-odroidc2.dts
@@ -103,6 +103,10 @@
 	status = "okay";
 	pinctrl-0 = <&eth_pins>;
 	pinctrl-names = "default";
+
+	amlogic,enable-25mhz-phy-clk;
+	amlogic,mp2-clock = <MESON8B_DWMAC_MP2_CLOCK_1000MHZ>;
+	amlogic,tx-delay = <MESON8B_DWMAC_TX_CLK_DELAY_QUARTER_CYCLE>;
 };
 
 &sd_emmc_b {
diff --git a/arch/arm64/boot/dts/amlogic/meson-gxbb-p20x.dtsi b/arch/arm64/boot/dts/amlogic/meson-gxbb-p20x.dtsi
index 5dfd849..4574677 100644
--- a/arch/arm64/boot/dts/amlogic/meson-gxbb-p20x.dtsi
+++ b/arch/arm64/boot/dts/amlogic/meson-gxbb-p20x.dtsi
@@ -85,6 +85,10 @@
 	status = "okay";
 	pinctrl-0 = <&eth_pins>;
 	pinctrl-names = "default";
+
+	amlogic,enable-25mhz-phy-clk;
+	amlogic,mp2-clock = <MESON8B_DWMAC_MP2_CLOCK_1000MHZ>;
+	amlogic,tx-delay = <MESON8B_DWMAC_TX_CLK_DELAY_QUARTER_CYCLE>;
 };
 
 &sd_emmc_b {
diff --git a/arch/arm64/boot/dts/amlogic/meson-gxbb-vega-s95.dtsi b/arch/arm64/boot/dts/amlogic/meson-gxbb-vega-s95.dtsi
index 3a77829..31ae35e 100644
--- a/arch/arm64/boot/dts/amlogic/meson-gxbb-vega-s95.dtsi
+++ b/arch/arm64/boot/dts/amlogic/meson-gxbb-vega-s95.dtsi
@@ -83,6 +83,10 @@
 	status = "okay";
 	pinctrl-0 = <&eth_pins>;
 	pinctrl-names = "default";
+
+	amlogic,enable-25mhz-phy-clk;
+	amlogic,mp2-clock = <MESON8B_DWMAC_MP2_CLOCK_1000MHZ>;
+	amlogic,tx-delay = <MESON8B_DWMAC_TX_CLK_DELAY_QUARTER_CYCLE>;
 };
 
 &sd_emmc_b {
diff --git a/arch/arm64/boot/dts/amlogic/meson-gxbb.dtsi b/arch/arm64/boot/dts/amlogic/meson-gxbb.dtsi
index 6c23965..463c2cd 100644
--- a/arch/arm64/boot/dts/amlogic/meson-gxbb.dtsi
+++ b/arch/arm64/boot/dts/amlogic/meson-gxbb.dtsi
@@ -46,6 +46,7 @@
 #include <dt-bindings/gpio/meson-gxbb-gpio.h>
 #include <dt-bindings/reset/amlogic,meson-gxbb-reset.h>
 #include <dt-bindings/clock/gxbb-clkc.h>
+#include <dt-bindings/net/amlogic-meson8b-dwmac.h>
 
 / {
 	compatible = "amlogic,meson-gxbb";
@@ -308,6 +309,11 @@
 					};
 				};
 			};
+
+			prg_ethernet: prg_ethernet@540 {
+				compatible = "syscon";
+				reg = <0x0 0x00540 0x0 0x8>;
+			};
 		};
 
 		hiubus: hiubus@c883c000 {
@@ -354,14 +360,14 @@
 		};
 
 		ethmac: ethernet@c9410000 {
-			compatible = "amlogic,meson6-dwmac", "snps,dwmac";
-			reg = <0x0 0xc9410000 0x0 0x10000
-			       0x0 0xc8834540 0x0 0x4>;
+			compatible = "amlogic,meson8b-dwmac", "snps,dwmac";
+			reg = <0x0 0xc9410000 0x0 0x10000>;
 			interrupts = <0 8 1>;
 			interrupt-names = "macirq";
 			clocks = <&clkc CLKID_ETH>;
 			clock-names = "stmmaceth";
 			phy-mode = "rgmii";
+			amlogic,prg-ethernet = <&prg_ethernet>;
 			status = "disabled";
 		};
 	};
-- 
2.9.0
