From: Romain Perier <romain.perier@gmail.com>
Subject: [PATCH v2 3/4] ARM: dts: Add emac nodes to the rk3188 device tree
Date: Mon,  8 Sep 2014 17:14:49 +0000
Message-ID: <1410196490-5646-3-git-send-email-romain.perier@gmail.com>
References: <1410196490-5646-1-git-send-email-romain.perier@gmail.com>
Cc: linux-rockchip@lists.infradead.org,
	linux-arm-kernel@lists.infradead.org, netdev@vger.kernel.org,
	devicetree@vger.kernel.org, arnd@arndb.de
To: heiko@sntech.de
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wg0-f44.google.com ([74.125.82.44]:45138 "EHLO
	mail-wg0-f44.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754563AbaIHRMf (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 8 Sep 2014 13:12:35 -0400
In-Reply-To: <1410196490-5646-1-git-send-email-romain.perier@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This adds support for EMAC Rockchip driver on RK3188 SoCs.

Signed-off-by: Romain Perier <romain.perier@gmail.com>
---
 arch/arm/boot/dts/rk3188.dtsi | 22 ++++++++++++++++++++++
 arch/arm/boot/dts/rk3xxx.dtsi | 17 +++++++++++++++++
 2 files changed, 39 insertions(+)

diff --git a/arch/arm/boot/dts/rk3188.dtsi b/arch/arm/boot/dts/rk3188.dtsi
index ee801a9..7f25bc5 100644
--- a/arch/arm/boot/dts/rk3188.dtsi
+++ b/arch/arm/boot/dts/rk3188.dtsi
@@ -147,6 +147,24 @@
 			bias-disable;
 		};
 
+		emac {
+			emac_xfer: emac-xfer {
+				rockchip,pins = <RK_GPIO3 16 RK_FUNC_2 &pcfg_pull_none>, /* tx_en */
+						<RK_GPIO3 17 RK_FUNC_2 &pcfg_pull_none>, /* txd1 */
+						<RK_GPIO3 18 RK_FUNC_2 &pcfg_pull_none>, /* txd0 */
+						<RK_GPIO3 19 RK_FUNC_2 &pcfg_pull_none>, /* rxd0 */
+						<RK_GPIO3 20 RK_FUNC_2 &pcfg_pull_none>, /* rxd1 */
+						<RK_GPIO3 21 RK_FUNC_2 &pcfg_pull_none>, /* mac_clk */
+						<RK_GPIO3 22 RK_FUNC_2 &pcfg_pull_none>, /* rx_err */
+						<RK_GPIO3 23 RK_FUNC_2 &pcfg_pull_none>; /* crs_dvalid */
+			};
+
+			emac_mdio: emac-mdio {
+				rockchip,pins = <RK_GPIO3 24 RK_FUNC_2 &pcfg_pull_none>,
+						<RK_GPIO3 25 RK_FUNC_2 &pcfg_pull_none>;
+			};
+		};
+
 		i2c0 {
 			i2c0_xfer: i2c0-xfer {
 				rockchip,pins = <RK_GPIO1 24 RK_FUNC_1 &pcfg_pull_none>,
@@ -323,6 +341,10 @@
 	};
 };
 
+&emac {
+	compatible = "rockchip,rk3188-emac";
+};
+
 &global_timer {
 	interrupts = <GIC_PPI 11 0xf04>;
 };
diff --git a/arch/arm/boot/dts/rk3xxx.dtsi b/arch/arm/boot/dts/rk3xxx.dtsi
index 8caf85d..208b1df 100644
--- a/arch/arm/boot/dts/rk3xxx.dtsi
+++ b/arch/arm/boot/dts/rk3xxx.dtsi
@@ -91,6 +91,23 @@
 		status = "disabled";
 	};
 
+	emac: ethernet@10204000 {
+		compatible = "snps,arc-emac";
+		reg = <0x10204000 0x3c>;
+		interrupts = <GIC_SPI 19 IRQ_TYPE_LEVEL_HIGH>;
+		#address-cells = <1>;
+		#size-cells = <0>;
+
+		rockchip,grf = <&grf>;
+
+		clocks = <&cru HCLK_EMAC>, <&cru SCLK_MAC>;
+		clock-names = "hclk", "macref";
+		max-speed = <100>;
+		phy-mode = "rmii";
+
+		status = "disabled";
+	};
+
 	mmc0: dwmmc@10214000 {
 		compatible = "rockchip,rk2928-dw-mshc";
 		reg = <0x10214000 0x1000>;
-- 
1.9.1
