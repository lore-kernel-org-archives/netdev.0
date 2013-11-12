From: <srinivas.kandagatla@st.com>
Subject: [PATCH RFC 10/10] ARM: STi: Add STiH416 ethernet support.
Date: Tue, 12 Nov 2013 13:53:15 +0000
Message-ID: <1384264395-7738-1-git-send-email-srinivas.kandagatla@st.com>
References: <1384264311-7308-1-git-send-email-srinivas.kandagatla@st.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: Rob Herring <rob.herring@calxeda.com>,
	Pawel Moll <pawel.moll@arm.com>,
	Mark Rutland <mark.rutland@arm.com>,
	Stephen Warren <swarren@wwwdotorg.org>,
	Ian Campbell <ijc+devicetree@hellion.org.uk>,
	Rob Landley <rob@landley.net>,
	Russell King <linux@arm.linux.org.uk>,
	Srinivas Kandagatla <srinivas.kandagatla@st.com>,
	Stuart Menefy <stuart.menefy@st.com>,
	Pavel Machek <pavel@ucw.cz>,
	"Rafael J. Wysocki" <rjw@rjwysocki.net>,
	Len Brown <len.brown@intel.com>, <stephen.gallimore@st.com>,
	Greg Kroah-Hartman <gregkh@linuxfoundation.org>,
	Giuseppe Cavallaro <peppe.cavallaro@st.com>,
	Grant Likely <grant.likely@linaro.org>,
	<devicetree@vger.kernel.org>, <linux-doc@vger.kernel.org>,
	<linux-kernel@vger.kernel.org>, <kernel@stlinux.com>,
	<linux-pm@vger.kernel.org>
To: <linux-arm-kernel@lists.infradead.org>, <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from eu1sys200aog106.obsmtp.com ([207.126.144.121]:47628 "EHLO
	eu1sys200aog106.obsmtp.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1755272Ab3KLNyd (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 12 Nov 2013 08:54:33 -0500
In-Reply-To: <1384264311-7308-1-git-send-email-srinivas.kandagatla@st.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Srinivas Kandagatla <srinivas.kandagatla@st.com>

This patch adds support to STiH416 SOC, which has two ethernet
snps,dwmac controllers version 3.710. With this patch B2000 and B2020
boards can boot with ethernet in MII and RGMII modes.

Tested on both B2020 and B2000.

Signed-off-by: Srinivas Kandagatla <srinivas.kandagatla@st.com>
---
 arch/arm/boot/dts/stih416-clock.dtsi   |   14 ++++
 arch/arm/boot/dts/stih416-pinctrl.dtsi |  106 ++++++++++++++++++++++++++++++++
 arch/arm/boot/dts/stih416.dtsi         |   58 +++++++++++++++++
 3 files changed, 178 insertions(+), 0 deletions(-)

diff --git a/arch/arm/boot/dts/stih416-clock.dtsi b/arch/arm/boot/dts/stih416-clock.dtsi
index 7026bf1..a6942c7 100644
--- a/arch/arm/boot/dts/stih416-clock.dtsi
+++ b/arch/arm/boot/dts/stih416-clock.dtsi
@@ -37,5 +37,19 @@
 			clock-frequency = <100000000>;
 			clock-output-names = "CLK_S_ICN_REG_0";
 		};
+
+		CLK_S_GMAC0_PHY: clockgenA1@7 {
+			#clock-cells = <0>;
+			compatible = "fixed-clock";
+			clock-frequency = <25000000>;
+			clock-output-names = "CLK_S_GMAC0_PHY";
+		};
+
+		CLK_S_ETH1_PHY: clockgenA0@7 {
+			#clock-cells = <0>;
+			compatible = "fixed-clock";
+			clock-frequency = <25000000>;
+			clock-output-names = "CLK_S_ETH1_PHY";
+		};
 	};
 };
diff --git a/arch/arm/boot/dts/stih416-pinctrl.dtsi b/arch/arm/boot/dts/stih416-pinctrl.dtsi
index 0f246c9..216754f 100644
--- a/arch/arm/boot/dts/stih416-pinctrl.dtsi
+++ b/arch/arm/boot/dts/stih416-pinctrl.dtsi
@@ -97,6 +97,59 @@
 					};
 				};
 			};
+
+			gmac1 {
+				pinctrl_mii1: mii1 {
+					st,pins {
+						txd0 = <&PIO0 0 ALT1 OUT SE_NICLK_IO 0 CLK_A>;
+						txd1 = <&PIO0 1 ALT1 OUT SE_NICLK_IO 0 CLK_A>;
+						txd2 = <&PIO0 2 ALT1 OUT SE_NICLK_IO 0 CLK_A>;
+						txd3 = <&PIO0 3 ALT1 OUT SE_NICLK_IO 0 CLK_A>;
+						txer = <&PIO0 4 ALT1 OUT SE_NICLK_IO 0 CLK_A>;
+						txen = <&PIO0 5 ALT1 OUT SE_NICLK_IO 0 CLK_A>;
+						txclk = <&PIO0 6 ALT1 IN NICLK 0 CLK_A>;
+						col =   <&PIO0 7 ALT1 IN BYPASS 1000>;
+
+						mdio =  <&PIO1 0 ALT1 OUT BYPASS 1500>;
+						mdc =   <&PIO1 1 ALT1 OUT NICLK 0 CLK_A>;
+						crs =   <&PIO1 2 ALT1 IN BYPASS 1000>;
+						mdint = <&PIO1 3 ALT1 IN BYPASS 0>;
+						rxd0 =  <&PIO1 4 ALT1 IN SE_NICLK_IO 0 CLK_A>;
+						rxd1 =  <&PIO1 5 ALT1 IN SE_NICLK_IO 0 CLK_A>;
+						rxd2 =  <&PIO1 6 ALT1 IN SE_NICLK_IO 0 CLK_A>;
+						rxd3 =  <&PIO1 7 ALT1 IN SE_NICLK_IO 0 CLK_A>;
+
+						rxdv =  <&PIO2 0 ALT1 IN SE_NICLK_IO 0 CLK_A>;
+						rx_er = <&PIO2 1 ALT1 IN SE_NICLK_IO 0 CLK_A>;
+						rxclk = <&PIO2 2 ALT1 IN NICLK 0 CLK_A>;
+					 	phyclk = <&PIO2 3 ALT1 OUT NICLK 0 CLK_A>;
+					};
+				};
+				pinctrl_rgmii1: rgmii1-0 {
+					st,pins {
+						txd0 =  <&PIO0 0 ALT1 OUT DE_IO 500 CLK_A>;
+						txd1 =  <&PIO0 1 ALT1 OUT DE_IO 500 CLK_A>;
+						txd2 =  <&PIO0 2 ALT1 OUT DE_IO 500 CLK_A>;
+						txd3 =  <&PIO0 3 ALT1 OUT DE_IO 500 CLK_A>;
+						txen =  <&PIO0 5 ALT1 OUT DE_IO 0   CLK_A>;
+						txclk = <&PIO0 6 ALT1 IN  NICLK 0   CLK_A>;
+
+						mdio = <&PIO1 0 ALT1 OUT BYPASS 0>;
+						mdc  = <&PIO1 1 ALT1 OUT NICLK  0 CLK_A>;
+						rxd0 = <&PIO1 4 ALT1 IN DE_IO 500 CLK_A>;
+						rxd1 = <&PIO1 5 ALT1 IN DE_IO 500 CLK_A>;
+						rxd2 = <&PIO1 6 ALT1 IN DE_IO 500 CLK_A>;
+						rxd3 = <&PIO1 7 ALT1 IN DE_IO 500 CLK_A>;
+
+						rxdv   = <&PIO2 0 ALT1 IN  DE_IO 500 CLK_A>;
+						rxclk  = <&PIO2 2 ALT1 IN  NICLK 0   CLK_A>;
+						phyclk = <&PIO2 3 ALT4 OUT NICLK 0   CLK_B>;
+
+						clk125= <&PIO3 7 ALT4 IN NICLK 0 CLK_A>;
+					};
+				};
+			};
+
 		};
 
 		pin-controller-front {
@@ -230,6 +283,59 @@
 					};
 				};
 			};
+
+			gmac0 {
+				pinctrl_mii0: mii0 {
+					st,pins {
+						mdint = <&PIO13 6 ALT2 IN  BYPASS      0>;
+						txen =  <&PIO13 7 ALT2 OUT SE_NICLK_IO 0 CLK_A>;
+						txd0 =  <&PIO14 0 ALT2 OUT SE_NICLK_IO 0 CLK_A>;
+						txd1 =  <&PIO14 1 ALT2 OUT SE_NICLK_IO 0 CLK_A>;
+						txd2 =  <&PIO14 2 ALT2 OUT SE_NICLK_IO 0 CLK_B>;
+						txd3 =  <&PIO14 3 ALT2 OUT SE_NICLK_IO 0 CLK_B>;
+
+						txclk = <&PIO15 0 ALT2 IN  NICLK       0 CLK_A>;
+						txer =  <&PIO15 1 ALT2 OUT SE_NICLK_IO 0 CLK_A>;
+						crs = <&PIO15 2 ALT2 IN  BYPASS 1000>;
+						col = <&PIO15 3 ALT2 IN  BYPASS 1000>;
+						mdio= <&PIO15 4 ALT2 OUT BYPASS 1500>;
+						mdc = <&PIO15 5 ALT2 OUT NICLK  0    CLK_B>;
+
+						rxd0 =  <&PIO16 0 ALT2 IN SE_NICLK_IO 0 CLK_A>;
+						rxd1 =  <&PIO16 1 ALT2 IN SE_NICLK_IO 0 CLK_A>;
+						rxd2 =  <&PIO16 2 ALT2 IN SE_NICLK_IO 0 CLK_A>;
+						rxd3 =  <&PIO16 3 ALT2 IN SE_NICLK_IO 0 CLK_A>;
+						rxdv =  <&PIO15 6 ALT2 IN SE_NICLK_IO 0 CLK_A>;
+						rx_er = <&PIO15 7 ALT2 IN SE_NICLK_IO 0 CLK_A>;
+						rxclk = <&PIO17 0 ALT2 IN NICLK 0 CLK_A>;
+					 	phyclk = <&PIO13 5 ALT2 OUT NICLK 0 CLK_B>;
+					};
+				};
+
+				pinctrl_rgmii0: rgmii0 {
+					st,pins {
+						 phyclk = <&PIO13  5 ALT4 OUT NICLK 0 CLK_B>;
+						 txen = <&PIO13 7 ALT2 OUT DE_IO 0 CLK_A>;
+						 txd0  = <&PIO14 0 ALT2 OUT DE_IO 500 CLK_A>;
+						 txd1  = <&PIO14 1 ALT2 OUT DE_IO 500 CLK_A>;
+						 txd2  = <&PIO14 2 ALT2 OUT DE_IO 500 CLK_B>;
+						 txd3  = <&PIO14 3 ALT2 OUT DE_IO 500 CLK_B>;
+						 txclk = <&PIO15 0 ALT2 IN NICLK 0 CLK_A>;
+
+						 mdio = <&PIO15 4 ALT2 OUT BYPASS 0>;
+						 mdc = <&PIO15 5 ALT2 OUT NICLK 0 CLK_B>;
+
+						 rxdv = <&PIO15 6 ALT2 IN DE_IO 500 CLK_A>;
+						 rxd0 =<&PIO16 0 ALT2 IN DE_IO	500 CLK_A>;
+						 rxd1 =<&PIO16 1 ALT2 IN DE_IO	500 CLK_A>;
+						 rxd2 =<&PIO16 2 ALT2 IN DE_IO	500 CLK_A>;
+						 rxd3  =<&PIO16 3 ALT2 IN DE_IO 500 CLK_A>;
+						 rxclk =<&PIO17 0 ALT2 IN NICLK 0 CLK_A>;
+
+						 clk125=<&PIO17 6 ALT1 IN NICLK 0 CLK_A>;
+					};
+				};
+			};
 		};
 
 		pin-controller-fvdp-fe {
diff --git a/arch/arm/boot/dts/stih416.dtsi b/arch/arm/boot/dts/stih416.dtsi
index a3831a3..bf052fb 100644
--- a/arch/arm/boot/dts/stih416.dtsi
+++ b/arch/arm/boot/dts/stih416.dtsi
@@ -103,5 +103,63 @@
 			pinctrl-0 	= <&pinctrl_sbc_serial1>;
 			clocks          = <&CLK_SYSIN>;
 		};
+
+		ethernet0: ethernet0{
+			#address-cells = <1>;
+			#size-cells = <1>;
+			status 		= "disabled";
+			compatible		= "st,stih416-dwmac";
+			reg			= <0x8bc 0x4>;
+			st,syscon		= <&syscfg_rear>;
+			resets			= <&softreset STIH416_ETH0_SOFTRESET>;
+			ranges;
+
+			dwmac@fe810000 {
+				device_type 	= "network";
+				compatible	= "snps,dwmac", "snps,dwmac-3.710";
+				status 		= "disabled";
+				reg 		= <0xfe810000 0x8000>;
+
+				interrupts = <0 133 0>, <0 134 0>, <0 135 0>;
+				interrupt-names = "macirq", "eth_wake_irq", "eth_lpi";
+
+				snps,pbl 	= <32>;
+				snps,mixed-burst;
+
+				pinctrl-names 	= "default";
+				pinctrl-0	= <&pinctrl_mii0>;
+				clock-names	= "stmmaceth";
+				clocks		= <&CLK_S_GMAC0_PHY>;
+			};
+		};
+
+		ethernet1: ethernet1 {
+			#address-cells = <1>;
+			#size-cells = <1>;
+			status 		= "disabled";
+			compatible		= "st,stih416-dwmac";
+			reg			= <0x7f0 0x4>;
+			st,syscon		= <&syscfg_sbc>;
+			resets			= <&softreset STIH416_ETH1_SOFTRESET>;
+			ranges;
+
+			dwmac@fef08000 {
+				device_type = "network";
+				compatible	= "snps,dwmac", "snps,dwmac-3.710";
+				status 		= "disabled";
+				reg		= <0xfef08000 0x8000>;
+				interrupts = <0 136 0>, <0 137 0>, <0 138 0>;
+				interrupt-names = "macirq", "eth_wake_irq", "eth_lpi";
+
+				snps,pbl	= <32>;
+				snps,mixed-burst;
+
+				pinctrl-names 	= "default";
+				pinctrl-0	= <&pinctrl_mii1>;
+				clock-names	= "stmmaceth";
+				clocks		= <&CLK_S_ETH1_PHY>;
+			};
+		};
+
 	};
 };
-- 
1.7.6.5
