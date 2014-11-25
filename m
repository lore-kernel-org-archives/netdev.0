From: Roger Chen <roger.chen@rock-chips.com>
Subject: [PATCH 3/4] GMAC: dts: add gmac info for rk3288
Date: Tue, 25 Nov 2014 17:08:56 +0800
Message-ID: <1416906536-26158-1-git-send-email-roger.chen@rock-chips.com>
Cc: peppe.cavallaro@st.com, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org, linux-rockchip@lists.infradead.org,
	kever.yang@rock-chips.com, mark.yao@rock-chips.com,
	eddie.cai@rock-chips.com, roger.chen@rock-chips.com
To: heiko@sntech.de
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

add gmac info in rk3288.dtsi for GMAC driver

Signed-off-by: Roger Chen <roger.chen@rock-chips.com>
---
 arch/arm/boot/dts/rk3288.dtsi |   59 +++++++++++++++++++++++++++++++++++++++++
 1 file changed, 59 insertions(+)

diff --git a/arch/arm/boot/dts/rk3288.dtsi b/arch/arm/boot/dts/rk3288.dtsi
index 0f50d5d..949675d 100644
--- a/arch/arm/boot/dts/rk3288.dtsi
+++ b/arch/arm/boot/dts/rk3288.dtsi
@@ -137,6 +137,13 @@
 		#clock-cells = <0>;
 	};
 
+	ext_gmac: external-gmac-clock {
+		compatible = "fixed-clock";
+		clock-frequency = <125000000>;
+		clock-output-names = "ext_gmac";
+		#clock-cells = <0>;
+	};
+
 	timer {
 		compatible = "arm,armv7-timer";
 		interrupts = <GIC_PPI 13 (GIC_CPU_MASK_SIMPLE(4) | IRQ_TYPE_LEVEL_HIGH)>,
@@ -490,6 +497,25 @@
 		reg = <0xff740000 0x1000>;
 	};
 
+	gmac: eth@ff290000 {
+		compatible = "rockchip,rk3288-gmac";
+		reg = <0xff290000 0x10000>;
+		interrupts = <GIC_SPI 27 IRQ_TYPE_LEVEL_HIGH>;  /*irq=59*/
+		interrupt-names = "macirq";
+		rockchip,grf = <&grf>;
+		clocks = <&cru SCLK_MAC>, <&cru SCLK_MAC_PLL>,
+			<&cru SCLK_MAC_RX>, <&cru SCLK_MAC_TX>,
+			<&cru SCLK_MACREF>, <&cru SCLK_MACREF_OUT>,
+			<&cru ACLK_GMAC>, <&cru PCLK_GMAC>;
+		clock-names = "stmmaceth", "clk_mac_pll",
+			"mac_clk_rx", "mac_clk_tx",
+			"clk_mac_ref", "clk_mac_refout",
+			"aclk_mac", "pclk_mac";
+		phy-mode = "rgmii";
+		pinctrl-names = "default";
+		pinctrl-0 = <&rgmii_pin /*&rmii_pin*/>;
+	};
+
 	cru: clock-controller@ff760000 {
 		compatible = "rockchip,rk3288-cru";
 		reg = <0xff760000 0x1000>;
@@ -1040,5 +1066,38 @@
 				rockchip,pins = <7 23 3 &pcfg_pull_none>;
 			};
 		};
+
+		gmac {
+			rgmii_pin: rgmii-pins {
+				rockchip,pins = <3 30 3 &pcfg_pull_none>,
+						<3 31 3 &pcfg_pull_none>,
+						<3 26 3 &pcfg_pull_none>,
+						<3 27 3 &pcfg_pull_none>,
+						<3 28 3 &pcfg_pull_none>,
+						<3 29 3 &pcfg_pull_none>,
+						<3 24 3 &pcfg_pull_none>,
+						<3 25 3 &pcfg_pull_none>,
+						<4 0 3 &pcfg_pull_none>,
+						<4 5 3 &pcfg_pull_none>,
+						<4 6 3 &pcfg_pull_none>,
+						<4 9 3 &pcfg_pull_none>,
+						<4 4 3 &pcfg_pull_none>,
+						<4 1 3 &pcfg_pull_none>,
+						<4 3 3 &pcfg_pull_none>;
+			};
+
+			rmii_pin: rmii-pins {
+				rockchip,pins = <3 30 3 &pcfg_pull_none>,
+						<3 31 3 &pcfg_pull_none>,
+						<3 28 3 &pcfg_pull_none>,
+						<3 29 3 &pcfg_pull_none>,
+						<4 0 3 &pcfg_pull_none>,
+						<4 5 3 &pcfg_pull_none>,
+						<4 4 3 &pcfg_pull_none>,
+						<4 1 3 &pcfg_pull_none>,
+						<4 2 3 &pcfg_pull_none>,
+						<4 3 3 &pcfg_pull_none>;
+			};
+		};
 	};
 };
-- 
1.7.9.5
