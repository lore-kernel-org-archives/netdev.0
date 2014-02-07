From: <srinivas.kandagatla@st.com>
Subject: [PATCH v2 2/3] ARM: STi: Add STiH415 ethernet support.
Date: Fri, 7 Feb 2014 10:55:35 +0000
Message-ID: <1391770535-24390-1-git-send-email-srinivas.kandagatla@st.com>
References: <1391770455-24291-1-git-send-email-srinivas.kandagatla@st.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: Rob Herring <robh+dt@kernel.org>, Pawel Moll <pawel.moll@arm.com>,
	Mark Rutland <mark.rutland@arm.com>,
	Ian Campbell <ijc+devicetree@hellion.org.uk>,
	Kumar Gala <galak@codeaurora.org>,
	Rob Landley <rob@landley.net>,
	Russell King <linux@arm.linux.org.uk>,
	Srinivas Kandagatla <srinivas.kandagatla@st.com>,
	Stuart Menefy <stuart.menefy@st.com>,
	Giuseppe Cavallaro <peppe.cavallaro@st.com>,
	<devicetree@vger.kernel.org>, <linux-doc@vger.kernel.org>,
	<linux-kernel@vger.kernel.org>,
	<linux-arm-kernel@lists.infradead.org>, <kernel@stlinux.com>,
	<davem@davemloft.net>
To: <netdev@vger.kernel.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1391770455-24291-1-git-send-email-srinivas.kandagatla@st.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Srinivas Kandagatla <srinivas.kandagatla@st.com>

This patch adds support to STiH415 SOC, which has two ethernet
snps,dwmac controllers version 3.610. With this patch B2000 and B2020
boards can boot with ethernet in MII and RGMII modes.

Tested on both B2020 and B2000.

Signed-off-by: Srinivas Kandagatla <srinivas.kandagatla@st.com>
---
 arch/arm/boot/dts/stih415-clock.dtsi   |   14 ++++
 arch/arm/boot/dts/stih415-pinctrl.dtsi |  121 ++++++++++++++++++++++++++++++++
 arch/arm/boot/dts/stih415.dtsi         |   48 +++++++++++++
 arch/arm/boot/dts/stih41x-b2000.dtsi   |   22 ++++++
 arch/arm/boot/dts/stih41x-b2020.dtsi   |   26 +++++++
 5 files changed, 231 insertions(+)

diff --git a/arch/arm/boot/dts/stih415-clock.dtsi b/arch/arm/boot/dts/stih415-clock.dtsi
index 174c799..d047dbc 100644
--- a/arch/arm/boot/dts/stih415-clock.dtsi
+++ b/arch/arm/boot/dts/stih415-clock.dtsi
@@ -34,5 +34,19 @@
 			compatible = "fixed-clock";
 			clock-frequency = <100000000>;
 		};
+
+		CLKS_GMAC0_PHY: clockgenA1@7 {
+			#clock-cells = <0>;
+			compatible = "fixed-clock";
+			clock-frequency = <25000000>;
+			clock-output-names = "CLKS_GMAC0_PHY";
+		};
+
+		CLKS_ETH1_PHY: clockgenA0@7 {
+			#clock-cells = <0>;
+			compatible = "fixed-clock";
+			clock-frequency = <25000000>;
+			clock-output-names = "CLKS_ETH1_PHY";
+		};
 	};
 };
diff --git a/arch/arm/boot/dts/stih415-pinctrl.dtsi b/arch/arm/boot/dts/stih415-pinctrl.dtsi
index 887c5e5..9ca20aa 100644
--- a/arch/arm/boot/dts/stih415-pinctrl.dtsi
+++ b/arch/arm/boot/dts/stih415-pinctrl.dtsi
@@ -119,6 +119,56 @@
 					};
 				};
 			};
+
+			gmac1 {
+				pinctrl_mii1: mii1 {
+						st,pins {
+						 txd0   = <&PIO0 0 ALT1 OUT  SE_NICLK_IO	0	CLK_A>;
+						 txd1   = <&PIO0 1 ALT1 OUT  SE_NICLK_IO	0	CLK_A>;
+						 txd2   = <&PIO0 2 ALT1 OUT  SE_NICLK_IO	0	CLK_A>;
+						 txd3   = <&PIO0 3 ALT1 OUT  SE_NICLK_IO	0	CLK_A>;
+						 txer   = <&PIO0 4 ALT1 OUT  SE_NICLK_IO	0	CLK_A>;
+						 txen   = <&PIO0 5 ALT1 OUT  SE_NICLK_IO	0	CLK_A>;
+						 txclk  = <&PIO0 6 ALT1 IN   NICLK	0	CLK_A>;
+						 col    = <&PIO0 7 ALT1 IN   BYPASS	1000>;
+						 mdio   = <&PIO1 0 ALT1 OUT  BYPASS	0>;
+						 mdc    = <&PIO1 1 ALT1 OUT  NICLK	0	CLK_A>;
+						 crs    = <&PIO1 2 ALT1 IN   BYPASS	1000>;
+						 mdint  = <&PIO1 3 ALT1 IN   BYPASS	0>;
+						 rxd0   = <&PIO1 4 ALT1 IN   SE_NICLK_IO	0	CLK_A>;
+						 rxd1   = <&PIO1 5 ALT1 IN   SE_NICLK_IO	0	CLK_A>;
+						 rxd2   = <&PIO1 6 ALT1 IN   SE_NICLK_IO	0	CLK_A>;
+						 rxd3   = <&PIO1 7 ALT1 IN   SE_NICLK_IO	0	CLK_A>;
+						 rxdv   = <&PIO2 0 ALT1 IN   SE_NICLK_IO	0	CLK_A>;
+						 rx_er  = <&PIO2 1 ALT1 IN   SE_NICLK_IO	0	CLK_A>;
+						 rxclk  = <&PIO2 2 ALT1 IN   NICLK	0	CLK_A>;
+						 phyclk = <&PIO2 3 ALT1 IN   NICLK	1000	CLK_A>;
+					};
+				};
+
+				pinctrl_rgmii1: rgmii1-0 {
+					st,pins {
+						 txd0 =	 <&PIO0 0 ALT1 OUT DE_IO	1000	CLK_A>;
+						 txd1 =	 <&PIO0 1 ALT1 OUT DE_IO	1000	CLK_A>;
+						 txd2 =	 <&PIO0 2 ALT1 OUT DE_IO	1000	CLK_A>;
+						 txd3 =	 <&PIO0 3 ALT1 OUT DE_IO	1000	CLK_A>;
+						 txen =	 <&PIO0 5 ALT1 OUT DE_IO	0	CLK_A>;
+						 txclk = <&PIO0 6 ALT1 IN	NICLK	0	CLK_A>;
+						 mdio =	 <&PIO1 0 ALT1 OUT	BYPASS	0>;
+						 mdc =	 <&PIO1 1 ALT1 OUT	NICLK	0	CLK_A>;
+						 rxd0 =	 <&PIO1 4 ALT1 IN DE_IO	0	CLK_A>;
+						 rxd1 =	 <&PIO1 5 ALT1 IN DE_IO	0	CLK_A>;
+						 rxd2 =	 <&PIO1 6 ALT1 IN DE_IO	0	CLK_A>;
+						 rxd3 =	 <&PIO1 7 ALT1 IN DE_IO	0	CLK_A>;
+
+						 rxdv =	  <&PIO2 0 ALT1 IN DE_IO	500	CLK_A>;
+						 rxclk =  <&PIO2 2 ALT1 IN	NICLK	0	CLK_A>;
+						 phyclk = <&PIO2 3 ALT4 OUT	NICLK	0	CLK_B>;
+
+						 clk125= <&PIO3 7 ALT4 IN 	NICLK	0	CLK_A>;
+					};
+				};
+			};
 		};
 
 		pin-controller-front {
@@ -284,6 +334,77 @@
 					};
 				};
 			};
+
+			gmac0{
+				pinctrl_mii0: mii0 {
+					st,pins {
+					 mdint =	<&PIO13 6 ALT2	IN	BYPASS		0>;
+					 txen =		<&PIO13 7 ALT2	OUT	SE_NICLK_IO	0	CLK_A>;
+
+					 txd0 =		<&PIO14 0 ALT2	OUT	SE_NICLK_IO	0	CLK_A>;
+					 txd1 =		<&PIO14 1 ALT2	OUT	SE_NICLK_IO	0	CLK_A>;
+					 txd2 =		<&PIO14 2 ALT2	OUT	SE_NICLK_IO	0	CLK_B>;
+					 txd3 =		<&PIO14 3 ALT2	OUT	SE_NICLK_IO	0	CLK_B>;
+
+					 txclk =	<&PIO15 0 ALT2	IN	NICLK		0	CLK_A>;
+					 txer =		<&PIO15 1 ALT2	OUT	SE_NICLK_IO	0	CLK_A>;
+					 crs =		<&PIO15 2 ALT2	IN	BYPASS		1000>;
+					 col =		<&PIO15 3 ALT2	IN	BYPASS		1000>;
+					 mdio  =        <&PIO15 4 ALT2	OUT	BYPASS 	3000>;
+					 mdc   =        <&PIO15 5 ALT2	OUT     NICLK  	0    	CLK_B>;
+
+					 rxd0 =		<&PIO16 0 ALT2	IN	SE_NICLK_IO	0	CLK_A>;
+					 rxd1 =		<&PIO16 1 ALT2	IN	SE_NICLK_IO	0	CLK_A>;
+					 rxd2 =		<&PIO16 2 ALT2	IN	SE_NICLK_IO	0	CLK_A>;
+					 rxd3 =		<&PIO16 3 ALT2	IN	SE_NICLK_IO	0	CLK_A>;
+					 rxdv =		<&PIO15 6 ALT2	IN	SE_NICLK_IO	0	CLK_A>;
+					 rx_er =	<&PIO15 7 ALT2	IN	SE_NICLK_IO	0	CLK_A>;
+					 rxclk =	<&PIO17 0 ALT2	IN	NICLK		0	CLK_A>;
+					 phyclk =	<&PIO13 5 ALT2	OUT	NICLK	1000	CLK_A>;
+
+					};
+				};
+
+			pinctrl_gmii0: gmii0 {
+				st,pins {
+					 mdint =	<&PIO13 6	ALT2 IN		BYPASS	0>;
+					 mdio  =        <&PIO15 4 	ALT2 OUT	BYPASS 	3000>;
+					 mdc   =        <&PIO15 5 	ALT2 OUT    	NICLK  	0    	CLK_B>;
+					 txen =		<&PIO13 7	ALT2 OUT	SE_NICLK_IO	3000	CLK_A>;
+
+					 txd0 =		<&PIO14 0	ALT2 OUT	SE_NICLK_IO	3000	CLK_A>;
+					 txd1 =		<&PIO14 1	ALT2 OUT	SE_NICLK_IO	3000	CLK_A>;
+					 txd2 =		<&PIO14 2	ALT2 OUT	SE_NICLK_IO	3000	CLK_B>;
+					 txd3 =		<&PIO14 3	ALT2 OUT	SE_NICLK_IO	3000	CLK_B>;
+					 txd4 =		<&PIO14 4	ALT2 OUT	SE_NICLK_IO	3000	CLK_B>;
+					 txd5 =		<&PIO14 5	ALT2 OUT	SE_NICLK_IO	3000	CLK_B>;
+					 txd6 =		<&PIO14 6	ALT2 OUT	SE_NICLK_IO	3000	CLK_B>;
+					 txd7 =		<&PIO14 7	ALT2 OUT	SE_NICLK_IO	3000	CLK_B>;
+
+					 txclk =	<&PIO15 0	ALT2 IN		NICLK	0	CLK_A>;
+					 txer =		<&PIO15 1	ALT2 OUT 	SE_NICLK_IO	3000	CLK_A>;
+					 crs =		<&PIO15 2	ALT2 IN		BYPASS	1000>;
+					 col =		<&PIO15 3	ALT2 IN		BYPASS	1000>;
+					 rxdv =		<&PIO15 6	ALT2 IN		SE_NICLK_IO	1500	CLK_A>;
+					 rx_er =	<&PIO15 7	ALT2 IN		SE_NICLK_IO	1500	CLK_A>;
+
+					 rxd0 =		<&PIO16 0	ALT2 IN		SE_NICLK_IO	1500	CLK_A>;
+					 rxd1 =		<&PIO16 1	ALT2 IN		SE_NICLK_IO	1500	CLK_A>;
+					 rxd2 =		<&PIO16 2	ALT2 IN		SE_NICLK_IO	1500	CLK_A>;
+					 rxd3 =		<&PIO16 3	ALT2 IN		SE_NICLK_IO	1500	CLK_A>;
+					 rxd4 =		<&PIO16 4	ALT2 IN		SE_NICLK_IO	1500	CLK_A>;
+					 rxd5 =		<&PIO16 5	ALT2 IN		SE_NICLK_IO	1500	CLK_A>;
+					 rxd6 =		<&PIO16 6	ALT2 IN		SE_NICLK_IO	1500	CLK_A>;
+					 rxd7 =		<&PIO16 7	ALT2 IN		SE_NICLK_IO	1500	CLK_A>;
+
+					 rxclk =	<&PIO17 0	ALT2 IN	NICLK	0	CLK_A>;
+					 clk125 =	<&PIO17 6	ALT1 IN	NICLK	0	CLK_A>;
+                                         phyclk =       <&PIO13 5       ALT4 OUT NICLK   0       CLK_B>;
+
+
+					};
+				};
+			};
 		};
 
 		pin-controller-left {
diff --git a/arch/arm/boot/dts/stih415.dtsi b/arch/arm/boot/dts/stih415.dtsi
index d52207c..cc9b22b 100644
--- a/arch/arm/boot/dts/stih415.dtsi
+++ b/arch/arm/boot/dts/stih415.dtsi
@@ -147,5 +147,53 @@
 
 			status		= "disabled";
 		};
+
+		ethernet0: dwmac@fe810000 {
+			device_type 	= "network";
+			compatible	= "st,stih415-dwmac", "snps,dwmac", "snps,dwmac-3.610";
+			status 		= "disabled";
+
+			reg 		= <0xfe810000 0x8000>, <0x148 0x4>;
+			reg-names	= "stmmaceth", "sti-ethconf";
+
+			interrupts 	= <0 147 0>, <0 148 0>, <0 149 0>;
+			interrupt-names = "macirq", "eth_wake_irq", "eth_lpi";
+			resets			= <&softreset STIH415_ETH0_SOFTRESET>;
+			reset-names		= "stmmaceth";
+
+			snps,pbl 	= <32>;
+			snps,mixed-burst;
+			snps,force_sf_dma_mode;
+
+			st,syscon	= <&syscfg_rear>;
+
+			pinctrl-names 	= "default";
+			pinctrl-0	= <&pinctrl_mii0>;
+			clock-names	= "stmmaceth";
+			clocks		= <&CLKS_GMAC0_PHY>;
+		};
+
+		ethernet1: dwmac@fef08000 {
+			device_type = "network";
+			compatible	= "st,stih415-dwmac", "snps,dwmac", "snps,dwmac-3.610";
+			status 		= "disabled";
+			reg		= <0xfef08000 0x8000>, <0x74 0x4>;
+			reg-names	= "stmmaceth", "sti-ethconf";
+			interrupts 	= <0 150 0>, <0 151 0>, <0 152 0>;
+			interrupt-names = "macirq", "eth_wake_irq", "eth_lpi";
+
+			snps,pbl	= <32>;
+			snps,mixed-burst;
+			snps,force_sf_dma_mode;
+
+			st,syscon		= <&syscfg_sbc>;
+
+			resets			= <&softreset STIH415_ETH1_SOFTRESET>;
+			reset-names		= "stmmaceth";
+			pinctrl-names 	= "default";
+			pinctrl-0	= <&pinctrl_mii1>;
+			clock-names	= "stmmaceth";
+			clocks		= <&CLKS_ETH1_PHY>;
+		};
 	};
 };
diff --git a/arch/arm/boot/dts/stih41x-b2000.dtsi b/arch/arm/boot/dts/stih41x-b2000.dtsi
index 1e6aa92..bf65c49 100644
--- a/arch/arm/boot/dts/stih41x-b2000.dtsi
+++ b/arch/arm/boot/dts/stih41x-b2000.dtsi
@@ -20,6 +20,8 @@
 
 	aliases {
 		ttyAS0 = &serial2;
+		ethernet0 = &ethernet0;
+		ethernet1 = &ethernet1;
 	};
 
 	soc {
@@ -46,5 +48,25 @@
 
 			status = "okay";
 		};
+
+		ethernet0: dwmac@fe810000 {
+			status			= "okay";
+			phy-mode		= "mii";
+			pinctrl-0		= <&pinctrl_mii0>;
+
+			snps,reset-gpio 	= <&PIO106 2>;
+			snps,reset-active-low;
+			snps,reset-delays-us 	= <0 10000 10000>;
+		};
+
+		ethernet1: dwmac@fef08000 {
+			status			= "disabled";
+			phy-mode		= "mii";
+			st,tx-retime-src	= "txclk";
+
+			snps,reset-gpio 	= <&PIO4 7>;
+			snps,reset-active-low;
+			snps,reset-delays-us 	= <0 10000 10000>;
+		};
 	};
 };
diff --git a/arch/arm/boot/dts/stih41x-b2020.dtsi b/arch/arm/boot/dts/stih41x-b2020.dtsi
index 0ef0a69..6c9a2ab 100644
--- a/arch/arm/boot/dts/stih41x-b2020.dtsi
+++ b/arch/arm/boot/dts/stih41x-b2020.dtsi
@@ -19,6 +19,7 @@
 
 	aliases {
 		ttyAS0 = &sbc_serial1;
+		ethernet1 = &ethernet1;
 	};
 	soc {
 		sbc_serial1: serial@fe531000 {
@@ -60,5 +61,30 @@
 		i2c@fe541000 {
 			status = "okay";
 		};
+
+		/**
+		* ethernet clk routing:
+		* for
+		* 	max-speed = <1000>;
+		* set
+		* 	st,tx-retime-src	= "clk_125";
+		*
+		* for
+		*	max-speed = <100>;
+		* set
+		*	st,tx-retime-src	= "clkgen";
+		*/
+
+		ethernet1: dwmac@fef08000 {
+			status			= "okay";
+			phy-mode		= "rgmii-id";
+			max-speed		= <1000>;
+			st,tx-retime-src	= "clk_125";
+			snps,reset-gpio 	= <&PIO3 0>;
+			snps,reset-active-low;
+			snps,reset-delays-us 	= <0 10000 10000>;
+
+			pinctrl-0	= <&pinctrl_rgmii1>;
+		};
 	};
 };
-- 
1.7.9.5
