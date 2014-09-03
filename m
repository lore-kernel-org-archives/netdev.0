From: Romain Perier <romain.perier@gmail.com>
Subject: [PATCH 4/4] ARM: dts: Enable emac node on the rk3188-radxarock boards
Date: Wed,  3 Sep 2014 10:27:16 +0000
Message-ID: <1409740036-8117-4-git-send-email-romain.perier@gmail.com>
References: <1409740036-8117-1-git-send-email-romain.perier@gmail.com>
Cc: linux-rockchip@lists.infradead.org,
	linux-arm-kernel@lists.infradead.org, netdev@vger.kernel.org,
	devicetree@vger.kernel.org, arnd@arndb.de
To: heiko@sntech.de
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-we0-f173.google.com ([74.125.82.173]:44017 "EHLO
	mail-we0-f173.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756582AbaICKZK (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 3 Sep 2014 06:25:10 -0400
In-Reply-To: <1409740036-8117-1-git-send-email-romain.perier@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This enables EMAC Rockchip support on radxa rock boards.

Signed-off-by: Romain Perier <romain.perier@gmail.com>
---
 arch/arm/boot/dts/rk3188-radxarock.dts | 24 ++++++++++++++++++++++++
 1 file changed, 24 insertions(+)

diff --git a/arch/arm/boot/dts/rk3188-radxarock.dts b/arch/arm/boot/dts/rk3188-radxarock.dts
index 5e4e3c23..e1358d3 100644
--- a/arch/arm/boot/dts/rk3188-radxarock.dts
+++ b/arch/arm/boot/dts/rk3188-radxarock.dts
@@ -76,6 +76,24 @@
 	};
 };
 
+&emac {
+	status = "okay";
+	compatible = "rockchip,rk3188-emac";
+
+	pinctrl-names = "default";
+	pinctrl-0 = <&emac_xfer>, <&emac_mdio>, <&phy_int>;
+
+	mac-address = [ c6 ef 91 8e 60 4b ];
+	phy = <&phy0>;
+	phy-supply = <&vcc_rmii>;
+
+	phy0: ethernet-phy@0 {
+		reg = <0>;
+		interrupt-parent = <&gpio3>;
+		interrupts = <26 IRQ_TYPE_LEVEL_LOW>;
+	};
+};
+
 &i2c1 {
 	status = "okay";
 	clock-frequency = <400000>;
@@ -201,6 +219,12 @@
 		};
 	};
 
+	lan8720a  {
+		phy_int: phy-int {
+			rockchip,pins = <RK_GPIO3 26 RK_FUNC_GPIO &pcfg_pull_up>;
+		};
+	};
+
 	ir-receiver {
 		ir_recv_pin: ir-recv-pin {
 			rockchip,pins = <RK_GPIO0 10 RK_FUNC_GPIO &pcfg_pull_none>;
-- 
1.9.1
