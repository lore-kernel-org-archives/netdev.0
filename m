From: Roger Chen <roger.chen@rock-chips.com>
Subject: [PATCH 3/3] arm64: dts: rockchip: add GMAC dt nodes for RK3399 evb
Date: Thu, 11 Aug 2016 15:24:48 +0800
Message-ID: <1470900288-10109-4-git-send-email-roger.chen@rock-chips.com>
References: <1470900288-10109-1-git-send-email-roger.chen@rock-chips.com>
Cc: linux-rockchip@lists.infradead.org, zhengxing@rock-chips.com,
	robh+dt@kernel.org, pawel.moll@arm.com, mark.rutland@arm.com,
	ijc+devicetree@hellion.org.uk, galak@codeaurora.org,
	peppe.cavallaro@st.com, alexandre.torgue@st.com,
	davem@davemloft.net, devicetree@vger.kernel.org,
	linux-arm-kernel@lists.infradead.org, linux-kernel@vger.kernel.org,
	netdev@vger.kernel.org, roger.chen@rock-chips.com
To: heiko@sntech.de
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1470900288-10109-1-git-send-email-roger.chen@rock-chips.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This patch add ethernet GMAC dt nodes for RK3399 evaluation board.

Signed-off-by: Roger Chen <roger.chen@rock-chips.com>
---
 arch/arm64/boot/dts/rockchip/rk3399-evb.dts | 23 +++++++++++++++++++++++
 1 file changed, 23 insertions(+)

diff --git a/arch/arm64/boot/dts/rockchip/rk3399-evb.dts b/arch/arm64/boot/dts/rockchip/rk3399-evb.dts
index d33aa06..5a076e0 100644
--- a/arch/arm64/boot/dts/rockchip/rk3399-evb.dts
+++ b/arch/arm64/boot/dts/rockchip/rk3399-evb.dts
@@ -69,6 +69,13 @@
 		regulator-max-microvolt = <3300000>;
 	};
 
+	clkin_gmac: external-gmac-clock {
+		compatible = "fixed-clock";
+		clock-frequency = <125000000>;
+		clock-output-names = "clkin_gmac";
+		#clock-cells = <0>;
+	};
+
 	vcc_phy: vcc-phy-regulator {
 		compatible = "regulator-fixed";
 		regulator-name = "vcc_phy";
@@ -134,3 +141,19 @@
 		};
 	};
 };
+
+&gmac {
+	phy-supply = <&vcc_phy>;
+	phy-mode = "rgmii";
+	clock_in_out = "input";
+	snps,reset-gpio = <&gpio3 15 GPIO_ACTIVE_LOW>;
+	snps,reset-active-low;
+	snps,reset-delays-us = <0 10000 50000>;
+	assigned-clocks = <&cru SCLK_RMII_SRC>;
+	assigned-clock-parents = <&clkin_gmac>;
+	pinctrl-names = "default";
+	pinctrl-0 = <&rgmii_pins>;
+	tx_delay = <0x28>;
+	rx_delay = <0x11>;
+	status = "okay";
+};
-- 
1.9.1
