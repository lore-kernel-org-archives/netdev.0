From: Roger Chen <roger.chen@rock-chips.com>
Subject: [PATCH v2 6/6] GMAC: add document for Rockchip RK3288 GMAC
Date: Thu, 27 Nov 2014 10:53:30 +0800
Message-ID: <1417056810-3825-1-git-send-email-roger.chen@rock-chips.com>
References: <1417056591-3570-1-git-send-email-roger.chen@rock-chips.com>
Cc: peppe.cavallaro@st.com, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org, linux-rockchip@lists.infradead.org,
	kever.yang@rock-chips.com, eddie.cai@rock-chips.com,
	roger.chen@rock-chips.com
To: heiko@sntech.de
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1417056591-3570-1-git-send-email-roger.chen@rock-chips.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

The document descripts how to add properties for GMAC in device tree.

Signed-off-by: Roger Chen <roger.chen@rock-chips.com>
---
 .../devicetree/bindings/net/rockchip-dwmac.txt     |   71 ++++++++++++++++++++
 1 file changed, 71 insertions(+)
 create mode 100644 Documentation/devicetree/bindings/net/rockchip-dwmac.txt

diff --git a/Documentation/devicetree/bindings/net/rockchip-dwmac.txt b/Documentation/devicetree/bindings/net/rockchip-dwmac.txt
new file mode 100644
index 0000000..237442b
--- /dev/null
+++ b/Documentation/devicetree/bindings/net/rockchip-dwmac.txt
@@ -0,0 +1,71 @@
+Rockchip SoC RK3288 10/100/1000 Ethernet driver(GMAC)
+
+The device node has following properties.
+
+Required properties:
+ - compatible: Can be "rockchip,rk3288-gmac".
+ - reg: addresses and length of the register sets for the device.
+ - interrupts: Should contain the GMAC interrupts.
+ - interrupt-names: Should contain the interrupt names "macirq".
+ - rockchip,grf: phandle to the syscon grf used to control speed and mode.
+ - clocks: <&cru SCLK_MAC>: clock selector for main clock, from PLL or PHY.
+	   <&cru SCLK_MAC_PLL>: PLL clock for SCLK_MAC
+	   <&cru SCLK_MAC_RX>: clock gate for RX
+	   <&cru SCLK_MAC_TX>: clock gate for TX
+	   <&cru SCLK_MACREF>: clock gate for RMII referce clock
+	   <&cru SCLK_MACREF_OUT> clock gate for RMII reference clock output
+	   <&cru ACLK_GMAC>: AXI clock gate for GMAC 
+	   <&cru PCLK_GMAC>: APB clock gate for GMAC 
+ - clock-names: One name for each entry in the clocks property.
+ - phy-mode: See ethernet.txt file in the same directory.
+ - pinctrl-names: Names corresponding to the numbered pinctrl states.
+ - pinctrl-0: pin-control mode. can be <&rgmii_pins> or <&rmii_pins>.
+ - clock_in_out: For RGMII, it must be "input", means main clock(125MHz)
+   is not sourced from SoC's PLL, but input from PHY; For RMII, "input" means
+   PHY provides the reference clock(50MHz), "output" means GMAC provides the
+   reference clock. 
+ - assigned-clocks: main clock, should be <&cru SCLK_MAC>;
+ - assigned-clock-parents = parent of main clock.
+   can be <&ext_gmac> or <&cru SCLK_MAC_PLL>.
+ - reset-gpio: GPIO for reset
+
+Optional properties:
+ - tx_delay: Delay value for TXD timing. Range value is 0~0x7F, 0x30 as default.
+ - rx_delay: Delay value for RXD timing. Range value is 0~0x7F, 0x10 as default.
+ - pmu_regulator: PMIC's integrated LDO power for PHY. Can be "act_ldo5".
+ - pmu_enable_level: Enable level of LDO. Can be <1> or <0>. 1->HIGH, 0->LOW.
+ - power-gpio: GPIO used to control PHY power. Normally,
+   power-gpio and pmu_regulator can not be used at the same time.
+ - phyirq-gpio: GPIO used as PHY irq.
+
+Example:
+
+gmac: ethernet@ff290000 {
+	compatible = "rockchip,rk3288-gmac";
+	reg = <0xff290000 0x10000>;
+	interrupts = <GIC_SPI 27 IRQ_TYPE_LEVEL_HIGH>;
+	interrupt-names = "macirq";
+	rockchip,grf = <&grf>;
+	clocks = <&cru SCLK_MAC>, <&cru SCLK_MAC_PLL>,
+		<&cru SCLK_MAC_RX>, <&cru SCLK_MAC_TX>,
+		<&cru SCLK_MACREF>, <&cru SCLK_MACREF_OUT>,
+		<&cru ACLK_GMAC>, <&cru PCLK_GMAC>;
+	clock-names = "stmmaceth", "clk_mac_pll",
+		"mac_clk_rx", "mac_clk_tx",
+		"clk_mac_ref", "clk_mac_refout",
+		"aclk_mac", "pclk_mac";
+	phy-mode = "rgmii";
+	pinctrl-names = "default";
+	pinctrl-0 = <&rgmii_pins /*&rmii_pins*/>;
+
+	clock_in_out = "input";
+	assigned-clocks = <&cru SCLK_MAC>;
+	assigned-clock-parents = <&ext_gmac>;
+	tx_delay = <0x30>;
+	rx_delay = <0x10>;
+
+        power-gpio = <&gpio0 6 GPIO_ACTIVE_HIGH>;
+        reset-gpio = <&gpio4 7 GPIO_ACTIVE_LOW>;
+
+	status = "ok";
+};
-- 
1.7.9.5
