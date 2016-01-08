From: Xing Zheng <zhengxing@rock-chips.com>
Subject: [PATCH] ARM: dts: rockchip: Add support emac for RK3036
Date: Fri,  8 Jan 2016 09:37:06 +0800
Message-ID: <1452217026-21155-1-git-send-email-zhengxing@rock-chips.com>
Cc: keescook@google.com, leozwang@google.com, heiko@sntech.de,
	davem@davemloft.net, netdev@vger.kernel.org,
	Xing Zheng <zhengxing@rock-chips.com>,
	Rob Herring <robh+dt@kernel.org>,
	Pawel Moll <pawel.moll@arm.com>,
	Mark Rutland <mark.rutland@arm.com>,
	Ian Campbell <ijc+devicetree@hellion.org.uk>,
	Kumar Gala <galak@codeaurora.org>,
	Russell King <linux@arm.linux.org.uk>,
	linux-arm-kernel@lists.infradead.org, devicetree@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: linux-rockchip@lists.infradead.org
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This patch describe the emac, and we need to let mac clock under
the APLL which is able to provide the accurate 50MHz what mac_ref
need.

Signed-off-by: Xing Zheng <zhengxing@rock-chips.com>
---

 arch/arm/boot/dts/rk3036-evb.dts   |   23 +++++++++++++++++++++++
 arch/arm/boot/dts/rk3036-kylin.dts |   21 +++++++++++++++++++++
 arch/arm/boot/dts/rk3036.dtsi      |   32 ++++++++++++++++++++++++++++++++
 3 files changed, 76 insertions(+)

diff --git a/arch/arm/boot/dts/rk3036-evb.dts b/arch/arm/boot/dts/rk3036-evb.dts
index 0a2367e..2505b9a 100644
--- a/arch/arm/boot/dts/rk3036-evb.dts
+++ b/arch/arm/boot/dts/rk3036-evb.dts
@@ -74,3 +74,26 @@
 &uart2 {
 	status = "okay";
 };
+
+&emac {
+	pinctrl-names = "default";
+	pinctrl-0 = <&emac_xfer>, <&emac_mdio>, <&rmii_rst>;
+	phy = <&phy0>;
+	status = "okay";
+
+	phy0: ethernet-phy@0 {
+		reg = <0>;
+	};
+};
+
+&pinctrl {
+	pcfg_output_high: pcfg-output-high {
+		output-high;
+	};
+
+	emac {
+		rmii_rst: rmii-rst {
+			rockchip,pins = <2 22 RK_FUNC_GPIO &pcfg_output_high>;
+		};
+	};
+};
diff --git a/arch/arm/boot/dts/rk3036-kylin.dts b/arch/arm/boot/dts/rk3036-kylin.dts
index 992f9ca..b6ba852 100644
--- a/arch/arm/boot/dts/rk3036-kylin.dts
+++ b/arch/arm/boot/dts/rk3036-kylin.dts
@@ -285,7 +285,22 @@
 	status = "okay";
 };
 
+&emac {
+	pinctrl-names = "default";
+	pinctrl-0 = <&emac_xfer>, <&emac_mdio>, <&rmii_rst>;
+	phy = <&phy0>;
+	status = "okay";
+
+	phy0: ethernet-phy@0 {
+		reg = <0>;
+	};
+};
+
 &pinctrl {
+	pcfg_output_high: pcfg-output-high {
+		output-high;
+	};
+
 	pmic {
 		pmic_int: pmic-int {
 			rockchip,pins = <2 2 RK_FUNC_GPIO &pcfg_pull_default>;
@@ -297,4 +312,10 @@
 			rockchip,pins = <2 7 RK_FUNC_1 &pcfg_pull_none>;
 		};
 	};
+
+	emac {
+		rmii_rst: rmii-rst {
+			rockchip,pins = <2 22 RK_FUNC_GPIO &pcfg_output_high>;
+		};
+	};
 };
diff --git a/arch/arm/boot/dts/rk3036.dtsi b/arch/arm/boot/dts/rk3036.dtsi
index b9567c1..1cb5877 100644
--- a/arch/arm/boot/dts/rk3036.dtsi
+++ b/arch/arm/boot/dts/rk3036.dtsi
@@ -186,6 +186,20 @@
 		status = "disabled";
 	};
 
+	emac: ethernet@10200000 {
+		compatible = "rockchip,rk3036-emac", "snps,arc-emac";
+		reg = <0x10200000 0x4000>;
+		interrupts = <GIC_SPI 8 IRQ_TYPE_LEVEL_HIGH>;
+		#address-cells = <1>;
+		#size-cells = <0>;
+		rockchip,grf = <&grf>;
+		clocks = <&cru HCLK_MAC>, <&cru SCLK_MACREF>, <&cru SCLK_MAC>;
+		clock-names = "hclk", "macref", "macclk";
+		max-speed = <100>;
+		phy-mode = "rmii";
+		status = "disabled";
+	};
+
 	sdmmc: dwmmc@10214000 {
 		compatible = "rockchip,rk3036-dw-mshc", "rockchip,rk3288-dw-mshc";
 		reg = <0x10214000 0x4000>;
@@ -556,6 +570,24 @@
 			};
 		};
 
+		emac {
+			emac_xfer: emac-xfer {
+				rockchip,pins = <2 10 RK_FUNC_1 &pcfg_pull_default>, /* crs_dvalid */
+						<2 13 RK_FUNC_1 &pcfg_pull_default>, /* tx_en */
+						<2 14 RK_FUNC_1 &pcfg_pull_default>, /* mac_clk */
+						<2 15 RK_FUNC_1 &pcfg_pull_default>, /* rx_err */
+						<2 16 RK_FUNC_1 &pcfg_pull_default>, /* rxd1 */
+						<2 17 RK_FUNC_1 &pcfg_pull_default>, /* rxd0 */
+						<2 18 RK_FUNC_1 &pcfg_pull_default>, /* txd1 */
+						<2 19 RK_FUNC_1 &pcfg_pull_default>; /* txd0 */
+			};
+
+			emac_mdio: emac-mdio {
+				rockchip,pins = <2 12 RK_FUNC_1 &pcfg_pull_default>, /* mac_md */
+						<2 25 RK_FUNC_1 &pcfg_pull_default>; /* mac_mdclk */
+			};
+		};
+
 		i2c0 {
 			i2c0_xfer: i2c0-xfer {
 				rockchip,pins = <0 0 RK_FUNC_1 &pcfg_pull_none>,
-- 
1.7.9.5
