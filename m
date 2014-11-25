From: Roger Chen <roger.chen@rock-chips.com>
Subject: [PATCH 4/4] GMAC: dts: enable gmac on RK3288 evb board
Date: Tue, 25 Nov 2014 17:09:09 +0800
Message-ID: <1416906549-26196-1-git-send-email-roger.chen@rock-chips.com>
Cc: peppe.cavallaro@st.com, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org, linux-rockchip@lists.infradead.org,
	kever.yang@rock-chips.com, mark.yao@rock-chips.com,
	eddie.cai@rock-chips.com, roger.chen@rock-chips.com
To: heiko@sntech.de
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

enable gmac in rk3288-evb-rk808.dts

Signed-off-by: Roger Chen <roger.chen@rock-chips.com>
---
 arch/arm/boot/dts/rk3288-evb-rk808.dts |   22 ++++++++++++++++++++++
 1 file changed, 22 insertions(+)

diff --git a/arch/arm/boot/dts/rk3288-evb-rk808.dts b/arch/arm/boot/dts/rk3288-evb-rk808.dts
index d8c775e6..168b4fa 100644
--- a/arch/arm/boot/dts/rk3288-evb-rk808.dts
+++ b/arch/arm/boot/dts/rk3288-evb-rk808.dts
@@ -152,3 +152,25 @@
 		};
 	};
 };
+
+&ext_gmac {
+	clock-frequency = <125000000>;
+	clock-output-names = "ext_gmac";
+};
+
+&gmac {
+	//pmu_regulator = "act_ldo5";
+	//pmu_enable_level = <1>; //1->HIGH, 0->LOW
+	power-gpio = <&gpio0 6 GPIO_ACTIVE_HIGH>;
+	reset-gpio = <&gpio4 7 GPIO_ACTIVE_LOW>;
+	//phyirq-gpio = <&gpio4 2 GPIO_ACTIVE_LOW>;
+	phy-mode = "rgmii";
+	clock_in_out = "input";
+	assigned-clocks = <&cru SCLK_MAC>;
+	assigned-clock-parents = <&ext_gmac>;
+	pinctrl-names = "default";
+	pinctrl-0 = <&rgmii_pin>; /*&rmii_pin*/
+	tx_delay = <0x30>;
+	rx_delay = <0x10>;
+	status = "ok";
+};
-- 
1.7.9.5
