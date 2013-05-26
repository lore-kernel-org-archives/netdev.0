From: Mugunthan V N <mugunthanvnm@ti.com>
Subject: [net-next PATCH v3 3/6] ARM: dts: AM33XX: Add pinmux configuration for CPSW to beaglebone
Date: Sun, 26 May 2013 23:53:33 +0530
Message-ID: <1369592616-23972-4-git-send-email-mugunthanvnm@ti.com>
References: <1369592616-23972-1-git-send-email-mugunthanvnm@ti.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <davem@davemloft.net>, <devicetree-discuss@lists.ozlabs.org>,
	<linux-omap@vger.kernel.org>, <benoit.cousson@linaro.org>,
	<paul@pwsan.com>, Mugunthan V N <mugunthanvnm@ti.com>
To: <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from bear.ext.ti.com ([192.94.94.41]:46022 "EHLO bear.ext.ti.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754818Ab3EZSXA (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sun, 26 May 2013 14:23:00 -0400
In-Reply-To: <1369592616-23972-1-git-send-email-mugunthanvnm@ti.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Add pinmux configurations for MII based CPSW ethernet to am335x-bone.
In this patch, only single named mode/state is added and these pins
are configured during pinctrl driver initialization.

Default mode is nothing but the values required for the module during
active state. With this configurations module is functional as
expected.

Todo:
- if an idle state is available for pins, add support for it.

Signed-off-by: Mugunthan V N <mugunthanvnm@ti.com>
---
 arch/arm/boot/dts/am335x-bone.dts |   38 +++++++++++++++++++++++++++++++++++++
 1 file changed, 38 insertions(+)

diff --git a/arch/arm/boot/dts/am335x-bone.dts b/arch/arm/boot/dts/am335x-bone.dts
index 5302f79..97294a6 100644
--- a/arch/arm/boot/dts/am335x-bone.dts
+++ b/arch/arm/boot/dts/am335x-bone.dts
@@ -36,6 +36,33 @@
 				0x60 0x17	/* gpmc_a8.gpio1_24, OUTPUT_PULLUP | MODE7 */
 			>;
 		};
+
+		cpsw_default: cpsw_default {
+			pinctrl-single,pins = <
+				/* Slave 1 */
+				0x110 0x20	/* mii1_rxerr.mii1_rxerr, MODE0 | INPUT */
+				0x114 0x0	/* mii1_txen.mii1_txen, MODE0 | OUTPUT */
+				0x118 0x20	/* mii1_rxdv.mii1_rxdv, MODE0 | INPUT_PULLDOWN */
+				0x11c 0x0	/* mii1_txd3.mii1_txd3, MODE0 | OUTPUT */
+				0x120 0x0	/* mii1_txd2.mii1_txd2, MODE0 | OUTPUT */
+				0x124 0x0	/* mii1_txd1.mii1_txd1, MODE0 | OUTPUT */
+				0x128 0x0	/* mii1_txd0.mii1_txd0, MODE0 | OUTPUT */
+				0x12c 0x20	/* mii1_txclk.mii1_txclk, MODE0 | INPUT_PULLDOWN */
+				0x130 0x20	/* mii1_rxclk.mii1_rxclk, MODE0 | INPUT_PULLDOWN */
+				0x134 0x20	/* mii1_rxd3.mii1_rxd3, MODE0 | INPUT_PULLDOWN */
+				0x138 0x20	/* mii1_rxd2.mii1_rxd2, MODE0 | INPUT_PULLDOWN */
+				0x13c 0x20	/* mii1_rxd1.mii1_rxd1, MODE0 | INPUT_PULLDOWN */
+				0x140 0x20	/* mii1_rxd0.mii1_rxd0, MODE0 | INPUT_PULLDOWN */
+			>;
+		};
+
+		davinci_mdio_default: davinci_mdio_default {
+			pinctrl-single,pins = <
+				/* MDIO */
+				0x148 0x30	/* mdio_data.mdio_data, MODE0 | INPUT_PULLUP */
+				0x14c 0x10	/* mdio_clk.mdio_clk, MODE0 | OUTPUT_PULLUP */
+			>;
+		};
 	};
 
 	ocp {
@@ -136,3 +163,14 @@
 &cpsw_emac1 {
 	phy_id = <&davinci_mdio>, <1>;
 };
+
+&mac {
+	pinctrl-names = "default";
+	pinctrl-0 = <&cpsw_default>;
+
+};
+
+&davinci_mdio {
+	pinctrl-names = "default";
+	pinctrl-0 = <&davinci_mdio_default>;
+};
-- 
1.7.9.5
