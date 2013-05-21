From: Mugunthan V N <mugunthanvnm@ti.com>
Subject: [net-next resend PATCH 5/6] ARM: dts: AM33XX: Add pinmux configuration for CPSW to EVMsk
Date: Tue, 21 May 2013 15:25:02 +0530
Message-ID: <1369130103-743-6-git-send-email-mugunthanvnm@ti.com>
References: <1369130103-743-1-git-send-email-mugunthanvnm@ti.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <davem@davemloft.net>, <devicetree-discuss@lists.ozlabs.org>,
	<linux-omap@vger.kernel.org>, <benoit.cousson@linaro.orgm>,
	<paul@pwsan.com>, Mugunthan V N <mugunthanvnm@ti.com>
To: <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from comal.ext.ti.com ([198.47.26.152]:56371 "EHLO comal.ext.ti.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753061Ab3EUJz2 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 21 May 2013 05:55:28 -0400
In-Reply-To: <1369130103-743-1-git-send-email-mugunthanvnm@ti.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Add pinmux configurations for MII based CPSW ethernet to AM335x EVMsk.
In this patch, only single named mode/state is added and these pins
are configured during pinctrl driver initialization.

Default mode is nothing but the values required for the module during
active state. With this configurations module is functional as
expected.

Todo:
- if an idle state is available for pins, add support for it.

Signed-off-by: Mugunthan V N <mugunthanvnm@ti.com>
---
 arch/arm/boot/dts/am335x-evmsk.dts |   50 ++++++++++++++++++++++++++++++++++++
 1 file changed, 50 insertions(+)

diff --git a/arch/arm/boot/dts/am335x-evmsk.dts b/arch/arm/boot/dts/am335x-evmsk.dts
index acbcac3..12cbe4e 100644
--- a/arch/arm/boot/dts/am335x-evmsk.dts
+++ b/arch/arm/boot/dts/am335x-evmsk.dts
@@ -51,6 +51,46 @@
 				0x9c 0x27	/* gpmc_ben0_cle.gpio2_5, INPUT | MODE7 */
 			>;
 		};
+
+		cpsw_default: cpsw_default {
+			pinctrl-single,pins = <
+				/* Slave 1 */
+				0x114 0x2	/* mii1_txen.rgmii1_tctl, MODE2 | OUTPUT */
+				0x118 0x22	/* mii1_rxdv.rgmii1_rctl, MODE2 | INPUT_PULLDOWN */
+				0x11c 0x2	/* mii1_txd3.rgmii1_td3, MODE2 | OUTPUT */
+				0x120 0x2	/* mii1_txd2.rgmii1_td2, MODE2 | OUTPUT */
+				0x124 0x2	/* mii1_txd1.rgmii1_td1, MODE2 | OUTPUT */
+				0x128 0x2	/* mii1_txd0.rgmii1_td0, MODE2 | OUTPUT */
+				0x12c 0x2	/* mii1_txclk.rgmii1_tclk, MODE2 | OUTPUT */
+				0x130 0x22	/* mii1_rxclk.rgmii1_rclk, MODE2 | INPUT_PULLDOWN */
+				0x134 0x22	/* mii1_rxd3.rgmii1_rd3, MODE2 | INPUT_PULLDOWN */
+				0x138 0x22	/* mii1_rxd2.rgmii1_rd2, MODE2 | INPUT_PULLDOWN */
+				0x13c 0x22	/* mii1_rxd1.rgmii1_rd1, MODE2 | INPUT_PULLDOWN */
+				0x140 0x22	/* mii1_rxd0.rgmii1_rd0, MODE2 | INPUT_PULLDOWN */
+
+				/* Slave 2 */
+				0x40 0x2	/* gpmc_a0.rgmii2_tctl", MODE2 | OUTPUT */
+				0x44 0x22	/* gpmc_a1.rgmii2_rctl", MODE2 | INPUT_PULLDOWN */
+				0x48 0x2	/* gpmc_a2.rgmii2_td3", MODE2 | OUTPUT */
+				0x4c 0x2	/* gpmc_a3.rgmii2_td2", MODE2 | OUTPUT */
+				0x50 0x2	/* gpmc_a4.rgmii2_td1", MODE2 | OUTPUT */
+				0x54 0x2	/* gpmc_a5.rgmii2_td0", MODE2 | OUTPUT */
+				0x58 0x2	/* gpmc_a6.rgmii2_tclk", MODE2 | OUTPUT */
+				0x5c 0x22	/* gpmc_a7.rgmii2_rclk", MODE2 | INPUT_PULLDOWN */
+				0x60 0x22	/* gpmc_a8.rgmii2_rd3", MODE2 | INPUT_PULLDOWN */
+				0x64 0x22	/* gpmc_a9.rgmii2_rd2", MODE2 | INPUT_PULLDOWN */
+				0x68 0x22	/* gpmc_a10.rgmii2_rd1", MODE2 | INPUT_PULLDOWN */
+				0x6c 0x22	/* gpmc_a11.rgmii2_rd0", MODE2 | INPUT_PULLDOWN */
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
@@ -249,6 +289,16 @@
 	};
 };
 
+&mac {
+	pinctrl-names = "default";
+	pinctrl-0 = <&cpsw_default>;
+};
+
+&davinci_mdio {
+	pinctrl-names = "default";
+	pinctrl-0 = <&davinci_mdio_default>;
+};
+
 &cpsw_emac0 {
 	phy_id = <&davinci_mdio>, <0>;
 };
-- 
1.7.9.5
