From: Mugunthan V N <mugunthanvnm@ti.com>
Subject: [net-next PATCH v3 6/6] ARM: dts: AM33XX: Add pinmux configuration for CPSW to am335x EVM
Date: Sun, 26 May 2013 23:53:36 +0530
Message-ID: <1369592616-23972-7-git-send-email-mugunthanvnm@ti.com>
References: <1369592616-23972-1-git-send-email-mugunthanvnm@ti.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <davem@davemloft.net>, <devicetree-discuss@lists.ozlabs.org>,
	<linux-omap@vger.kernel.org>, <benoit.cousson@linaro.org>,
	<paul@pwsan.com>, Mugunthan V N <mugunthanvnm@ti.com>
To: <netdev@vger.kernel.org>
Return-path: <linux-omap-owner@vger.kernel.org>
In-Reply-To: <1369592616-23972-1-git-send-email-mugunthanvnm@ti.com>
Sender: linux-omap-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Add pinmux configurations for RGMII based CPSW ethernet to am335x-evm.
In this patch, only single named mode/state is added and these pins
are configured during pinctrl driver initialization.

Default mode is nothing but the values required for the module during
active state. With this configurations module is functional as
expected.

Todo:
- if an idle state is available for pins, add support for it.

Signed-off-by: Mugunthan V N <mugunthanvnm@ti.com>
---
 arch/arm/boot/dts/am335x-evm.dts |   36 ++++++++++++++++++++++++++++++++++++
 1 file changed, 36 insertions(+)

diff --git a/arch/arm/boot/dts/am335x-evm.dts b/arch/arm/boot/dts/am335x-evm.dts
index 0423298..beb2fbf 100644
--- a/arch/arm/boot/dts/am335x-evm.dts
+++ b/arch/arm/boot/dts/am335x-evm.dts
@@ -44,6 +44,32 @@
 				0x154 0x27	/* spi0_d0.gpio0_3, INPUT | MODE7 */
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
@@ -237,6 +263,16 @@
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

