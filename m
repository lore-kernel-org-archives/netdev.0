From: Roger Chen <roger.chen@rock-chips.com>
Subject: [PATCH v3 5/6] ARM: dts: rockchip: enable gmac on RK3288 evb board
Date: Mon, 29 Dec 2014 17:44:25 +0800
Message-ID: <1419846265-14711-1-git-send-email-roger.chen@rock-chips.com>
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

enable gmac in rk3288-evb-rk808.dts

changes since v2:
1. add fixed regulator for PHY
2. remove power-gpio, reset-gpio, phyirq-gpio, pmu_regulator setting
3. add "snps,reset-gpio", "snps,reset-active-low;" "snps,reset-delays-us"

Signed-off-by: Roger Chen <roger.chen@rock-chips.com>
---
 arch/arm/boot/dts/rk3288-evb-rk808.dts |   23 +++++++++++++++++++++++
 arch/arm/boot/dts/rk3288-evb.dtsi      |   17 +++++++++++++++++
 2 files changed, 40 insertions(+)

diff --git a/arch/arm/boot/dts/rk3288-evb-rk808.dts b/arch/arm/boot/dts/rk3288-evb-rk808.dts
index d8c775e6..831a7aa 100644
--- a/arch/arm/boot/dts/rk3288-evb-rk808.dts
+++ b/arch/arm/boot/dts/rk3288-evb-rk808.dts
@@ -15,6 +15,13 @@
 
 / {
 	compatible = "rockchip,rk3288-evb-rk808", "rockchip,rk3288";
+
+	ext_gmac: external-gmac-clock {
+		compatible = "fixed-clock";
+		clock-frequency = <125000000>;
+		clock-output-names = "ext_gmac";
+		#clock-cells = <0>;
+	};
 };
 
 &cpu0 {
@@ -152,3 +159,19 @@
 		};
 	};
 };
+
+&gmac {
+	phy_regulator = "vcc_phy";
+	phy-mode = "rgmii";
+	clock_in_out = "input";
+	snps,reset-gpio = <&gpio4 7 0>;
+	snps,reset-active-low;
+	snps,reset-delays-us = <0 10000 1000000>;
+	assigned-clocks = <&cru SCLK_MAC>;
+	assigned-clock-parents = <&ext_gmac>;
+	pinctrl-names = "default";
+	pinctrl-0 = <&rgmii_pins>;
+	tx_delay = <0x30>;
+	rx_delay = <0x10>;
+	status = "ok";
+};
diff --git a/arch/arm/boot/dts/rk3288-evb.dtsi b/arch/arm/boot/dts/rk3288-evb.dtsi
index cb83cea..fe1d13c 100644
--- a/arch/arm/boot/dts/rk3288-evb.dtsi
+++ b/arch/arm/boot/dts/rk3288-evb.dtsi
@@ -90,6 +90,17 @@
 		regulator-always-on;
 		regulator-boot-on;
 	};
+
+	vcc_phy: vcc-phy-regulator {
+		compatible = "regulator-fixed";
+		enable-active-high;
+		gpio = <&gpio0 6 GPIO_ACTIVE_HIGH>;
+		pinctrl-names = "default";
+		pinctrl-0 = <&eth_phy_pwr>;
+		regulator-name = "vcc_phy";
+		regulator-always-on;
+		regulator-boot-on;
+	};
 };
 
 &emmc {
@@ -172,6 +183,12 @@
 			rockchip,pins = <0 14 RK_FUNC_GPIO &pcfg_pull_none>;
 		};
 	};
+
+	eth_phy {
+		eth_phy_pwr: eth-phy-pwr {
+			rockchip,pins = <0 6 RK_FUNC_GPIO &pcfg_pull_none>;
+		};
+	};
 };
 
 &usb_host0_ehci {
-- 
1.7.9.5
