From: Roger Chen <roger.chen@rock-chips.com>
Subject: [PATCH v3 4/6] ARM: dts: rockchip: add gmac info for rk3288
Date: Mon, 29 Dec 2014 17:44:16 +0800
Message-ID: <1419846256-14675-1-git-send-email-roger.chen@rock-chips.com>
References: <1419846152-14531-1-git-send-email-roger.chen@rock-chips.com>
Cc: peppe.cavallaro@st.com, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org, linux-rockchip@lists.infradead.org,
	kever.yang@rock-chips.com, eddie.cai@rock-chips.com,
	roger.chen@rock-chips.com
To: heiko@sntech.de
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1419846152-14531-1-git-send-email-roger.chen@rock-chips.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

add gmac info in rk3288.dtsi for GMAC driver

changes since v2:
1. add drive-strength in the pinctrl settings

Signed-off-by: Roger Chen <roger.chen@rock-chips.com>
---
 arch/arm/boot/dts/rk3288.dtsi |   54 +++++++++++++++++++++++++++++++++++++++++
 1 file changed, 54 insertions(+)

diff --git a/arch/arm/boot/dts/rk3288.dtsi b/arch/arm/boot/dts/rk3288.dtsi
index 0f50d5d..5a26db0 100644
--- a/arch/arm/boot/dts/rk3288.dtsi
+++ b/arch/arm/boot/dts/rk3288.dtsi
@@ -358,6 +358,22 @@
 		status = "disabled";
 	};
 
+	gmac: ethernet@ff290000 {
+		compatible = "rockchip,rk3288-gmac";
+		reg = <0xff290000 0x10000>;
+		interrupts = <GIC_SPI 27 IRQ_TYPE_LEVEL_HIGH>;
+		interrupt-names = "macirq";
+		rockchip,grf = <&grf>;
+		clocks = <&cru SCLK_MAC>,
+			<&cru SCLK_MAC_RX>, <&cru SCLK_MAC_TX>,
+			<&cru SCLK_MACREF>, <&cru SCLK_MACREF_OUT>,
+			<&cru ACLK_GMAC>, <&cru PCLK_GMAC>;
+		clock-names = "stmmaceth",
+			"mac_clk_rx", "mac_clk_tx",
+			"clk_mac_ref", "clk_mac_refout",
+			"aclk_mac", "pclk_mac";
+	};
+
 	usb_host0_ehci: usb@ff500000 {
 		compatible = "generic-ehci";
 		reg = <0xff500000 0x100>;
@@ -703,6 +719,11 @@
 			bias-disable;
 		};
 
+		pcfg_pull_none_12ma: pcfg-pull-none-12ma {
+			bias-disable;
+			drive-strength = <12>;
+		};
+
 		i2c0 {
 			i2c0_xfer: i2c0-xfer {
 				rockchip,pins = <0 15 RK_FUNC_1 &pcfg_pull_none>,
@@ -1040,5 +1061,38 @@
 				rockchip,pins = <7 23 3 &pcfg_pull_none>;
 			};
 		};
+
+		gmac {
+			rgmii_pins: rgmii-pins {
+				rockchip,pins = <3 30 3 &pcfg_pull_none>,
+						<3 31 3 &pcfg_pull_none>,
+						<3 26 3 &pcfg_pull_none>,
+						<3 27 3 &pcfg_pull_none>,
+						<3 28 3 &pcfg_pull_none_12ma>,
+						<3 29 3 &pcfg_pull_none_12ma>,
+						<3 24 3 &pcfg_pull_none_12ma>,
+						<3 25 3 &pcfg_pull_none_12ma>,
+						<4 0 3 &pcfg_pull_none>,
+						<4 5 3 &pcfg_pull_none>,
+						<4 6 3 &pcfg_pull_none>,
+						<4 9 3 &pcfg_pull_none_12ma>,
+						<4 4 3 &pcfg_pull_none_12ma>,
+						<4 1 3 &pcfg_pull_none>,
+						<4 3 3 &pcfg_pull_none>;
+			};
+
+			rmii_pins: rmii-pins {
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
