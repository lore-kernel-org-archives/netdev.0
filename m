From: Peter Griffin <peter.griffin@linaro.org>
Subject: [PATCH v2 7/7] stmmac: dwmac-sti: Pass sysconfig register offset via syscon dt property.
Date: Wed,  7 Jan 2015 15:04:12 +0000
Message-ID: <1420643052-4506-8-git-send-email-peter.griffin@linaro.org>
References: <1420643052-4506-1-git-send-email-peter.griffin@linaro.org>
Cc: peter.griffin@linaro.org, lee.jones@linaro.org,
	devicetree@vger.kernel.org, netdev@vger.kernel.org
To: linux-arm-kernel@lists.infradead.org, linux-kernel@vger.kernel.org,
	srinivas.kandagatla@gmail.com, maxime.coquelin@st.com,
	patrice.chotard@st.com, peppe.cavallaro@st.com, kishon@ti.com,
	arnd@arndb.de
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1420643052-4506-1-git-send-email-peter.griffin@linaro.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Based on Arnds review comments here https://lkml.org/lkml/2014/11/13/161,
we should not be mixing address spaces in the reg property like this driver
currently does. This patch updates the driver, dt docs and also the existing
dt nodes to pass the sysconfig offset in the syscon dt property.

This patch breaks DT compatibility! But this platform is considered WIP,
and is only used by a few developers who are upstreaming support for it.
This change has been done as a single atomic commit to ensure it is
bisectable.

Signed-off-by: Peter Griffin <peter.griffin@linaro.org>
Reviewed-by: Arnd Bergmann <arnd@arndb.de>
---
 Documentation/devicetree/bindings/net/sti-dwmac.txt | 14 +++++---------
 arch/arm/boot/dts/stih415.dtsi                      | 12 ++++++------
 arch/arm/boot/dts/stih416.dtsi                      | 12 ++++++------
 drivers/net/ethernet/stmicro/stmmac/dwmac-sti.c     | 13 +++++++------
 4 files changed, 24 insertions(+), 27 deletions(-)

diff --git a/Documentation/devicetree/bindings/net/sti-dwmac.txt b/Documentation/devicetree/bindings/net/sti-dwmac.txt
index 6762a6b..d05c1e1 100644
--- a/Documentation/devicetree/bindings/net/sti-dwmac.txt
+++ b/Documentation/devicetree/bindings/net/sti-dwmac.txt
@@ -9,14 +9,10 @@ The device node has following properties.
 Required properties:
  - compatible	: Can be "st,stih415-dwmac", "st,stih416-dwmac",
    "st,stih407-dwmac", "st,stid127-dwmac".
- - reg : Offset of the glue configuration register map in system
-   configuration regmap pointed by st,syscon property and size.
- - st,syscon : Should be phandle to system configuration node which
-   encompases this glue registers.
+ - st,syscon : Should be phandle/offset pair. The phandle to the syscon node which
+   encompases the glue register, and the offset of the control register.
  - st,gmac_en: this is to enable the gmac into a dedicated sysctl control
    register available on STiH407 SoC.
- - sti-ethconf: this is the gmac glue logic register to enable the GMAC,
-   select among the different modes and program the clk retiming.
  - pinctrl-0: pin-control for all the MII mode supported.
 
 Optional properties:
@@ -40,10 +36,10 @@ ethernet0: dwmac@9630000 {
 	device_type = "network";
 	status = "disabled";
 	compatible = "st,stih407-dwmac", "snps,dwmac", "snps,dwmac-3.710";
-	reg = <0x9630000 0x8000>, <0x80 0x4>;
-	reg-names = "stmmaceth", "sti-ethconf";
+	reg = <0x9630000 0x8000>;
+	reg-names = "stmmaceth";
 
-	st,syscon = <&syscfg_sbc_reg>;
+	st,syscon = <&syscfg_sbc_reg 0x80>;
 	st,gmac_en;
 	resets = <&softreset STIH407_ETH1_SOFTRESET>;
 	reset-names = "stmmaceth";
diff --git a/arch/arm/boot/dts/stih415.dtsi b/arch/arm/boot/dts/stih415.dtsi
index 9198c12..19b019b 100644
--- a/arch/arm/boot/dts/stih415.dtsi
+++ b/arch/arm/boot/dts/stih415.dtsi
@@ -153,8 +153,8 @@
 			compatible	= "st,stih415-dwmac", "snps,dwmac", "snps,dwmac-3.610";
 			status 		= "disabled";
 
-			reg 		= <0xfe810000 0x8000>, <0x148 0x4>;
-			reg-names	= "stmmaceth", "sti-ethconf";
+			reg		= <0xfe810000 0x8000>;
+			reg-names	= "stmmaceth";
 
 			interrupts 	= <0 147 0>, <0 148 0>, <0 149 0>;
 			interrupt-names = "macirq", "eth_wake_irq", "eth_lpi";
@@ -165,7 +165,7 @@
 			snps,mixed-burst;
 			snps,force_sf_dma_mode;
 
-			st,syscon	= <&syscfg_rear>;
+			st,syscon	= <&syscfg_rear 0x148>;
 
 			pinctrl-names 	= "default";
 			pinctrl-0	= <&pinctrl_mii0>;
@@ -177,8 +177,8 @@
 			device_type = "network";
 			compatible	= "st,stih415-dwmac", "snps,dwmac", "snps,dwmac-3.610";
 			status 		= "disabled";
-			reg		= <0xfef08000 0x8000>, <0x74 0x4>;
-			reg-names	= "stmmaceth", "sti-ethconf";
+			reg		= <0xfef08000 0x8000>;
+			reg-names	= "stmmaceth";
 			interrupts 	= <0 150 0>, <0 151 0>, <0 152 0>;
 			interrupt-names = "macirq", "eth_wake_irq", "eth_lpi";
 
@@ -186,7 +186,7 @@
 			snps,mixed-burst;
 			snps,force_sf_dma_mode;
 
-			st,syscon		= <&syscfg_sbc>;
+			st,syscon		= <&syscfg_sbc 0x74>;
 
 			resets			= <&softreset STIH415_ETH1_SOFTRESET>;
 			reset-names		= "stmmaceth";
diff --git a/arch/arm/boot/dts/stih416.dtsi b/arch/arm/boot/dts/stih416.dtsi
index 85afe01..ea28eba 100644
--- a/arch/arm/boot/dts/stih416.dtsi
+++ b/arch/arm/boot/dts/stih416.dtsi
@@ -163,8 +163,8 @@
 			device_type 	= "network";
 			compatible	= "st,stih416-dwmac", "snps,dwmac", "snps,dwmac-3.710";
 			status 		= "disabled";
-			reg 		= <0xfe810000 0x8000>, <0x8bc 0x4>;
-			reg-names	= "stmmaceth", "sti-ethconf";
+			reg		= <0xfe810000 0x8000>;
+			reg-names	= "stmmaceth";
 
 			interrupts = <0 133 0>, <0 134 0>, <0 135 0>;
 			interrupt-names = "macirq", "eth_wake_irq", "eth_lpi";
@@ -172,7 +172,7 @@
 			snps,pbl 	= <32>;
 			snps,mixed-burst;
 
-			st,syscon		= <&syscfg_rear>;
+			st,syscon		= <&syscfg_rear 0x8bc>;
 			resets			= <&softreset STIH416_ETH0_SOFTRESET>;
 			reset-names		= "stmmaceth";
 			pinctrl-names 	= "default";
@@ -185,15 +185,15 @@
 			device_type = "network";
 			compatible		= "st,stih416-dwmac", "snps,dwmac", "snps,dwmac-3.710";
 			status 		= "disabled";
-			reg		= <0xfef08000 0x8000>, <0x7f0 0x4>;
-			reg-names	= "stmmaceth", "sti-ethconf";
+			reg		= <0xfef08000 0x8000>;
+			reg-names	= "stmmaceth";
 			interrupts = <0 136 0>, <0 137 0>, <0 138 0>;
 			interrupt-names = "macirq", "eth_wake_irq", "eth_lpi";
 
 			snps,pbl	= <32>;
 			snps,mixed-burst;
 
-			st,syscon	= <&syscfg_sbc>;
+			st,syscon	= <&syscfg_sbc 0x7f0>;
 
 			resets		= <&softreset STIH416_ETH1_SOFTRESET>;
 			reset-names	= "stmmaceth";
diff --git a/drivers/net/ethernet/stmicro/stmmac/dwmac-sti.c b/drivers/net/ethernet/stmicro/stmmac/dwmac-sti.c
index 056b358..bb6e2dc 100644
--- a/drivers/net/ethernet/stmicro/stmmac/dwmac-sti.c
+++ b/drivers/net/ethernet/stmicro/stmmac/dwmac-sti.c
@@ -122,7 +122,7 @@ struct sti_dwmac {
 	bool ext_phyclk;	/* Clock from external PHY */
 	u32 tx_retime_src;	/* TXCLK Retiming*/
 	struct clk *clk;	/* PHY clock */
-	int ctrl_reg;		/* GMAC glue-logic control register */
+	u32 ctrl_reg;		/* GMAC glue-logic control register */
 	int clk_sel_reg;	/* GMAC ext clk selection register */
 	struct device *dev;
 	struct regmap *regmap;
@@ -285,11 +285,6 @@ static int sti_dwmac_parse_data(struct sti_dwmac *dwmac,
 	if (!np)
 		return -EINVAL;
 
-	res = platform_get_resource_byname(pdev, IORESOURCE_MEM, "sti-ethconf");
-	if (!res)
-		return -ENODATA;
-	dwmac->ctrl_reg = res->start;
-
 	/* clk selection from extra syscfg register */
 	dwmac->clk_sel_reg = -ENXIO;
 	res = platform_get_resource_byname(pdev, IORESOURCE_MEM, "sti-clkconf");
@@ -300,6 +295,12 @@ static int sti_dwmac_parse_data(struct sti_dwmac *dwmac,
 	if (IS_ERR(regmap))
 		return PTR_ERR(regmap);
 
+	err = of_property_read_u32_index(np, "st,syscon", 1, &dwmac->ctrl_reg);
+	if (err) {
+		dev_err(dev, "Can't get sysconfig ctrl offset (%d)\n", err);
+		return err;
+	}
+
 	dwmac->dev = dev;
 	dwmac->interface = of_get_phy_mode(np);
 	dwmac->regmap = regmap;
-- 
1.9.1
