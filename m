From: Romain Perier <romain.perier@gmail.com>
Subject: [PATCH 3/4] ARM: dts: Add emac nodes to the rk3188 device tree
Date: Wed,  3 Sep 2014 10:27:15 +0000
Message-ID: <1409740036-8117-3-git-send-email-romain.perier@gmail.com>
References: <1409740036-8117-1-git-send-email-romain.perier@gmail.com>
Cc: linux-rockchip@lists.infradead.org,
	linux-arm-kernel@lists.infradead.org, netdev@vger.kernel.org,
	devicetree@vger.kernel.org, arnd@arndb.de
To: heiko@sntech.de
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-we0-f173.google.com ([74.125.82.173]:47206 "EHLO
	mail-we0-f173.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756224AbaICKZI (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 3 Sep 2014 06:25:08 -0400
In-Reply-To: <1409740036-8117-1-git-send-email-romain.perier@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This adds support for EMAC Rockchip driver on RK3188 SoCs.

Signed-off-by: Romain Perier <romain.perier@gmail.com>
---
 arch/arm/boot/dts/rk3188.dtsi | 18 ++++++++++++++++++
 arch/arm/boot/dts/rk3xxx.dtsi | 17 +++++++++++++++++
 2 files changed, 35 insertions(+)

diff --git a/arch/arm/boot/dts/rk3188.dtsi b/arch/arm/boot/dts/rk3188.dtsi
index ee801a9..a182713 100644
--- a/arch/arm/boot/dts/rk3188.dtsi
+++ b/arch/arm/boot/dts/rk3188.dtsi
@@ -147,6 +147,24 @@
 			bias-disable;
 		};
 
+		emac {
+			emac_xfer: emac-xfer {
+				rockchip,pins = <RK_GPIO3 16 RK_FUNC_2 &pcfg_pull_none>, //tx_en
+						<RK_GPIO3 17 RK_FUNC_2 &pcfg_pull_none>, //txd1
+						<RK_GPIO3 18 RK_FUNC_2 &pcfg_pull_none>, //txd0
+						<RK_GPIO3 19 RK_FUNC_2 &pcfg_pull_none>, //rxd0
+						<RK_GPIO3 20 RK_FUNC_2 &pcfg_pull_none>, //rxd1
+						<RK_GPIO3 21 RK_FUNC_2 &pcfg_pull_none>, //mac_clk
+						<RK_GPIO3 22 RK_FUNC_2 &pcfg_pull_none>, //rx_err
+						<RK_GPIO3 23 RK_FUNC_2 &pcfg_pull_none>; //crs_dvalid
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
