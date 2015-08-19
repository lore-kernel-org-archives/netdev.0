From: Fugang Duan <b38611@freescale.com>
Subject: [PATCH v1 6/6] ARM: dts: imx7d-sdb: add fec1 and fec2 support
Date: Wed, 19 Aug 2015 13:34:04 +0800
Message-ID: <1439962444-27486-7-git-send-email-b38611@freescale.com>
References: <1439962444-27486-1-git-send-email-b38611@freescale.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <linux-arm-kernel@lists.infradead.org>, <netdev@vger.kernel.org>,
	<b38611@freescale.com>
To: <shawnguo@kernel.org>, <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-bn1bon0146.outbound.protection.outlook.com ([157.56.111.146]:29184
	"EHLO na01-bn1-obe.outbound.protection.outlook.com"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1752433AbbHSFep (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 19 Aug 2015 01:34:45 -0400
In-Reply-To: <1439962444-27486-1-git-send-email-b38611@freescale.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Enable fec1 and fec2 for i.MX7d-sdb board.

Signed-off-by: Fugang Duan <B38611@freescale.com>
---
 arch/arm/boot/dts/imx7d-sdb.dts | 76 ++++++++++++++++++++++++++++++++++++++++-
 1 file changed, 75 insertions(+), 1 deletion(-)

diff --git a/arch/arm/boot/dts/imx7d-sdb.dts b/arch/arm/boot/dts/imx7d-sdb.dts
index 4d1a4b9..7d3e980 100644
--- a/arch/arm/boot/dts/imx7d-sdb.dts
+++ b/arch/arm/boot/dts/imx7d-sdb.dts
@@ -101,6 +101,45 @@
 	arm-supply = <&sw1a_reg>;
 };
 
+&fec1 {
+	pinctrl-names = "default";
+	pinctrl-0 = <&pinctrl_enet1>;
+	assigned-clocks = <&clks IMX7D_ENET1_TIME_ROOT_SRC>,
+			  <&clks IMX7D_ENET1_TIME_ROOT_CLK>;
+	assigned-clock-parents = <&clks IMX7D_PLL_ENET_MAIN_100M_CLK>;
+	assigned-clock-rates = <0>, <100000000>;
+	phy-mode = "rgmii";
+	phy-handle = <&ethphy0>;
+	fsl,magic-packet;
+	status = "okay";
+
+	mdio {
+		#address-cells = <1>;
+		#size-cells = <0>;
+
+		ethphy0: ethernet-phy@0 {
+			reg = <0>;
+		};
+
+		ethphy1: ethernet-phy@1 {
+			reg = <1>;
+		};
+	};
+};
+
+&fec2 {
+	pinctrl-names = "default";
+	pinctrl-0 = <&pinctrl_enet2>;
+	assigned-clocks = <&clks IMX7D_ENET2_TIME_ROOT_SRC>,
+			  <&clks IMX7D_ENET2_TIME_ROOT_CLK>;
+	assigned-clock-parents = <&clks IMX7D_PLL_ENET_MAIN_100M_CLK>;
+	assigned-clock-rates = <0>, <100000000>;
+	phy-mode = "rgmii";
+	phy-handle = <&ethphy1>;
+	fsl,magic-packet;
+	status = "okay";
+};
+
 &i2c1 {
 	pinctrl-names = "default";
 	pinctrl-0 = <&pinctrl_i2c1>;
@@ -246,6 +285,42 @@
 	pinctrl-0 = <&pinctrl_hog>;
 
 	imx7d-sdb {
+		pinctrl_enet1: enet1grp {
+			fsl,pins = <
+				MX7D_PAD_GPIO1_IO10__ENET1_MDIO			0x3
+				MX7D_PAD_GPIO1_IO11__ENET1_MDC			0x3
+				MX7D_PAD_ENET1_RGMII_TXC__ENET1_RGMII_TXC	0x1
+				MX7D_PAD_ENET1_RGMII_TD0__ENET1_RGMII_TD0	0x1
+				MX7D_PAD_ENET1_RGMII_TD1__ENET1_RGMII_TD1	0x1
+				MX7D_PAD_ENET1_RGMII_TD2__ENET1_RGMII_TD2	0x1
+				MX7D_PAD_ENET1_RGMII_TD3__ENET1_RGMII_TD3	0x1
+				MX7D_PAD_ENET1_RGMII_TX_CTL__ENET1_RGMII_TX_CTL	0x1
+				MX7D_PAD_ENET1_RGMII_RXC__ENET1_RGMII_RXC	0x1
+				MX7D_PAD_ENET1_RGMII_RD0__ENET1_RGMII_RD0	0x1
+				MX7D_PAD_ENET1_RGMII_RD1__ENET1_RGMII_RD1	0x1
+				MX7D_PAD_ENET1_RGMII_RD2__ENET1_RGMII_RD2	0x1
+				MX7D_PAD_ENET1_RGMII_RD3__ENET1_RGMII_RD3	0x1
+				MX7D_PAD_ENET1_RGMII_RX_CTL__ENET1_RGMII_RX_CTL	0x1
+			>;
+		};
+
+		pinctrl_enet2: enet2grp {
+			fsl,pins = <
+				MX7D_PAD_EPDC_GDSP__ENET2_RGMII_TXC		0x1
+				MX7D_PAD_EPDC_SDCE2__ENET2_RGMII_TD0		0x1
+				MX7D_PAD_EPDC_SDCE3__ENET2_RGMII_TD1		0x1
+				MX7D_PAD_EPDC_GDCLK__ENET2_RGMII_TD2		0x1
+				MX7D_PAD_EPDC_GDOE__ENET2_RGMII_TD3		0x1
+				MX7D_PAD_EPDC_GDRL__ENET2_RGMII_TX_CTL		0x1
+				MX7D_PAD_EPDC_SDCE1__ENET2_RGMII_RXC		0x1
+				MX7D_PAD_EPDC_SDCLK__ENET2_RGMII_RD0		0x1
+				MX7D_PAD_EPDC_SDLE__ENET2_RGMII_RD1		0x1
+				MX7D_PAD_EPDC_SDOE__ENET2_RGMII_RD2		0x1
+				MX7D_PAD_EPDC_SDSHR__ENET2_RGMII_RD3		0x1
+				MX7D_PAD_EPDC_SDCE0__ENET2_RGMII_RX_CTL		0x1
+			>;
+		};
+
 		pinctrl_hog: hoggrp {
 			fsl,pins = <
 				MX7D_PAD_UART3_CTS_B__GPIO4_IO7		0x14
@@ -281,7 +356,6 @@
 			>;
 		};
 
-
 		pinctrl_uart1: uart1grp {
 			fsl,pins = <
 				MX7D_PAD_UART1_TX_DATA__UART1_DCE_TX	0x79
-- 
1.9.1
