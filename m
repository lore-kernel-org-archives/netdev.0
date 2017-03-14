From: Roger Quadros <rogerq@ti.com>
Subject: [PATCH v2 2/2] ARM: dts: am335x-icev2: Add CPSW ethernet0 and
 ethernet1
Date: Tue, 14 Mar 2017 14:50:21 +0200
Message-ID: <c14a51bf-ddee-2b74-e3d3-bc8d3e02ec98@ti.com>
References: <1489412554-2054-1-git-send-email-rogerq@ti.com>
 <1489412554-2054-3-git-send-email-rogerq@ti.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="windows-1252"
Content-Transfer-Encoding: 7bit
Cc: <grygorii.strashko@ti.com>, <nsekhar@ti.com>, <jsarha@ti.com>,
        <linux-omap@vger.kernel.org>, <netdev@vger.kernel.org>,
        <linux-kernel@vger.kernel.org>, <rogerq@ti.com>
To: <davem@davemloft.net>, <tony@atomide.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from fllnx210.ext.ti.com ([198.47.19.17]:33024 "EHLO
        fllnx210.ext.ti.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1750837AbdCNMub (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 14 Mar 2017 08:50:31 -0400
In-Reply-To: <1489412554-2054-3-git-send-email-rogerq@ti.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Enable the 2 ethernet ports as CPSW ports in dual-mac mode

Signed-off-by: Roger Quadros <rogerq@ti.com>
[nsekhar@ti.com: use AM33XX_IOPAD()]
Signed-off-by: Sekhar Nori <nsekhar@ti.com>
---
v2:
- use phy-handle instead of phy_id

 arch/arm/boot/dts/am335x-icev2.dts | 121 +++++++++++++++++++++++++++++++++++++
 1 file changed, 121 insertions(+)

diff --git a/arch/arm/boot/dts/am335x-icev2.dts b/arch/arm/boot/dts/am335x-icev2.dts
index a2ad076..415cd46 100644
--- a/arch/arm/boot/dts/am335x-icev2.dts
+++ b/arch/arm/boot/dts/am335x-icev2.dts
@@ -201,6 +201,69 @@
 			AM33XX_IOPAD(0x938, PIN_OUTPUT_PULLUP | MUX_MODE1) /* (L16) gmii1_rxd2.uart3_txd */
 		>;
 	};
+
+	cpsw_default: cpsw_default {
+		pinctrl-single,pins = <
+			/* Slave 1, RMII mode */
+			AM33XX_IOPAD(0x90c, (PIN_INPUT_PULLUP | MUX_MODE1))	/* mii1_crs.rmii1_crs_dv */
+			AM33XX_IOPAD(0x944, (PIN_INPUT_PULLUP | MUX_MODE0))	/* rmii1_refclk.rmii1_refclk */
+			AM33XX_IOPAD(0x940, (PIN_INPUT_PULLUP | MUX_MODE1))	/* mii1_rxd0.rmii1_rxd0 */
+			AM33XX_IOPAD(0x93c, (PIN_INPUT_PULLUP | MUX_MODE1))	/* mii1_rxd1.rmii1_rxd1 */
+			AM33XX_IOPAD(0x910, (PIN_INPUT_PULLUP | MUX_MODE1))	/* mii1_rxerr.rmii1_rxerr */
+			AM33XX_IOPAD(0x928, (PIN_OUTPUT_PULLDOWN | MUX_MODE1))	/* mii1_txd0.rmii1_txd0 */
+			AM33XX_IOPAD(0x924, (PIN_OUTPUT_PULLDOWN | MUX_MODE1))	/* mii1_txd1.rmii1_txd1 */
+			AM33XX_IOPAD(0x914, (PIN_OUTPUT_PULLDOWN | MUX_MODE1))	/* mii1_txen.rmii1_txen */
+			/* Slave 2, RMII mode */
+			AM33XX_IOPAD(0x870, (PIN_INPUT_PULLUP | MUX_MODE3))	/* gpmc_wait0.rmii2_crs_dv */
+			AM33XX_IOPAD(0x908, (PIN_INPUT_PULLUP | MUX_MODE1))	/* mii1_col.rmii2_refclk */
+			AM33XX_IOPAD(0x86c, (PIN_INPUT_PULLUP | MUX_MODE3))	/* gpmc_a11.rmii2_rxd0 */
+			AM33XX_IOPAD(0x868, (PIN_INPUT_PULLUP | MUX_MODE3))	/* gpmc_a10.rmii2_rxd1 */
+			AM33XX_IOPAD(0x874, (PIN_INPUT_PULLUP | MUX_MODE3))	/* gpmc_wpn.rmii2_rxerr */
+			AM33XX_IOPAD(0x854, (PIN_OUTPUT_PULLDOWN | MUX_MODE3))	/* gpmc_a5.rmii2_txd0 */
+			AM33XX_IOPAD(0x850, (PIN_OUTPUT_PULLDOWN | MUX_MODE3))	/* gpmc_a4.rmii2_txd1 */
+			AM33XX_IOPAD(0x840, (PIN_OUTPUT_PULLDOWN | MUX_MODE3))	/* gpmc_a0.rmii2_txen */
+		>;
+	};
+
+	cpsw_sleep: cpsw_sleep {
+		pinctrl-single,pins = <
+			/* Slave 1 reset value */
+			AM33XX_IOPAD(0x90c, (PIN_INPUT_PULLDOWN | MUX_MODE7))
+			AM33XX_IOPAD(0x944, (PIN_INPUT_PULLDOWN | MUX_MODE7))
+			AM33XX_IOPAD(0x940, (PIN_INPUT_PULLDOWN | MUX_MODE7))
+			AM33XX_IOPAD(0x93c, (PIN_INPUT_PULLDOWN | MUX_MODE7))
+			AM33XX_IOPAD(0x910, (PIN_INPUT_PULLDOWN | MUX_MODE7))
+			AM33XX_IOPAD(0x928, (PIN_INPUT_PULLDOWN | MUX_MODE7))
+			AM33XX_IOPAD(0x924, (PIN_INPUT_PULLDOWN | MUX_MODE7))
+			AM33XX_IOPAD(0x914, (PIN_INPUT_PULLDOWN | MUX_MODE7))
+
+			/* Slave 2 reset value */
+			AM33XX_IOPAD(0x870, (PIN_INPUT_PULLDOWN | MUX_MODE7))
+			AM33XX_IOPAD(0x908, (PIN_INPUT_PULLDOWN | MUX_MODE7))
+			AM33XX_IOPAD(0x86c, (PIN_INPUT_PULLDOWN | MUX_MODE7))
+			AM33XX_IOPAD(0x868, (PIN_INPUT_PULLDOWN | MUX_MODE7))
+			AM33XX_IOPAD(0x874, (PIN_INPUT_PULLDOWN | MUX_MODE7))
+			AM33XX_IOPAD(0x854, (PIN_INPUT_PULLDOWN | MUX_MODE7))
+			AM33XX_IOPAD(0x850, (PIN_INPUT_PULLDOWN | MUX_MODE7))
+			AM33XX_IOPAD(0x840, (PIN_INPUT_PULLDOWN | MUX_MODE7))
+		>;
+	};
+
+	davinci_mdio_default: davinci_mdio_default {
+		pinctrl-single,pins = <
+			/* MDIO */
+			AM33XX_IOPAD(0x948, (PIN_INPUT_PULLUP | SLEWCTRL_FAST | MUX_MODE0))	/* mdio_data.mdio_data */
+			AM33XX_IOPAD(0x94c, (PIN_OUTPUT_PULLUP | MUX_MODE0))			/* mdio_clk.mdio_clk */
+		>;
+	};
+
+	davinci_mdio_sleep: davinci_mdio_sleep {
+		pinctrl-single,pins = <
+			/* MDIO reset value */
+			AM33XX_IOPAD(0x948, (PIN_INPUT_PULLDOWN | MUX_MODE7))
+			AM33XX_IOPAD(0x94c, (PIN_INPUT_PULLDOWN | MUX_MODE7))
+		>;
+	};
 };
 
 &i2c0 {
@@ -350,3 +413,61 @@
 	pinctrl-0 = <&uart3_pins_default>;
 	status = "okay";
 };
+
+&gpio3 {
+	p4 {
+		gpio-hog;
+		gpios = <4 GPIO_ACTIVE_HIGH>;
+		output-high;
+		line-name = "PR1_MII_CTRL";
+	};
+
+	p10 {
+		gpio-hog;
+		gpios = <10 GPIO_ACTIVE_HIGH>;
+		/* ETH1 mux: Low for MII-PRU, high for RMII-CPSW */
+		output-high;
+		line-name = "MUX_MII_CTL1";
+	};
+};
+
+&cpsw_emac0 {
+	phy-handle = <&ethphy0>;
+	phy-mode = "rmii";
+	dual_emac_res_vlan = <1>;
+};
+
+&cpsw_emac1 {
+	phy-handle = <&ethphy1>;
+	phy-mode = "rmii";
+	dual_emac_res_vlan = <2>;
+};
+
+&mac {
+	pinctrl-names = "default", "sleep";
+	pinctrl-0 = <&cpsw_default>;
+	pinctrl-1 = <&cpsw_sleep>;
+	status = "okay";
+	dual_emac;
+};
+
+&phy_sel {
+	rmii-clock-ext;
+};
+
+&davinci_mdio {
+	pinctrl-names = "default", "sleep";
+	pinctrl-0 = <&davinci_mdio_default>;
+	pinctrl-1 = <&davinci_mdio_sleep>;
+	status = "okay";
+	reset-gpios = <&gpio2 5 GPIO_ACTIVE_LOW>;
+	reset-delay-us = <2>;   /* PHY datasheet states 1uS min */
+
+	ethphy0: ethernet-phy@1 {
+		reg = <1>;
+	};
+
+	ethphy1: ethernet-phy@3 {
+		reg = <3>;
+	};
+};
-- 
2.7.4
