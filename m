From: Alexandre TORGUE <alexandre.torgue-qxv4g6HH51o@public.gmane.org>
Subject: [PATCH v2 1/3] ARM: dts: stm32f429: Align Ethernet node with new bindings properties
Date: Mon, 24 Oct 2016 10:40:04 +0200
Message-ID: <1477298406-22805-2-git-send-email-alexandre.torgue@st.com>
References: <1477298406-22805-1-git-send-email-alexandre.torgue@st.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>, <linux-arm-kernel-IAPFreCvJWM7uuMidbF8XUB+6BGkLq7r@public.gmane.org>,
        <devicetree-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
To: <peppe.cavallaro-qxv4g6HH51o@public.gmane.org>,
        Maxime Coquelin <mcoquelin.stm32-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>, <arnd-r2nGTMty4D4@public.gmane.org>,
        <robh-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>
Return-path: <devicetree-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <1477298406-22805-1-git-send-email-alexandre.torgue-qxv4g6HH51o@public.gmane.org>
Sender: devicetree-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

This patch aligns clocks names and node reference according to new
stm32-dwmac glue binding. It also renames Ethernet pinctrl phandle
(indeed there is no need to add 0 as Ethernet instance as there is only
one IP in SOC).

Signed-off-by: Alexandre TORGUE <alexandre.torgue-qxv4g6HH51o@public.gmane.org>

diff --git a/arch/arm/boot/dts/stm32429i-eval.dts b/arch/arm/boot/dts/stm32429i-eval.dts
index 13c7cd2..fa30bf1 100644
--- a/arch/arm/boot/dts/stm32429i-eval.dts
+++ b/arch/arm/boot/dts/stm32429i-eval.dts
@@ -94,11 +94,12 @@
 	clock-frequency = <25000000>;
 };
 
-&ethernet0 {
+&mac {
 	status = "okay";
-	pinctrl-0	= <&ethernet0_mii>;
+	pinctrl-0	= <&ethernet_mii>;
 	pinctrl-names	= "default";
-	phy-mode	= "mii-id";
+	phy-mode	= "mii";
+
 	mdio0 {
 		#address-cells = <1>;
 		#size-cells = <0>;
diff --git a/arch/arm/boot/dts/stm32f429.dtsi b/arch/arm/boot/dts/stm32f429.dtsi
index 336ee4f..6350117b 100644
--- a/arch/arm/boot/dts/stm32f429.dtsi
+++ b/arch/arm/boot/dts/stm32f429.dtsi
@@ -313,7 +313,7 @@
 				};
 			};
 
-			ethernet0_mii: mii@0 {
+			ethernet_mii: mii@0 {
 				pins {
 					pinmux = <STM32F429_PG13_FUNC_ETH_MII_TXD0_ETH_RMII_TXD0>,
 						 <STM32F429_PG14_FUNC_ETH_MII_TXD1_ETH_RMII_TXD1>,
@@ -373,13 +373,13 @@
 			st,mem2mem;
 		};
 
-		ethernet0: dwmac@40028000 {
+		mac: ethernet@40028000 {
 			compatible = "st,stm32-dwmac", "snps,dwmac-3.50a";
 			reg = <0x40028000 0x8000>;
 			reg-names = "stmmaceth";
 			interrupts = <61>, <62>;
 			interrupt-names = "macirq", "eth_wake_irq";
-			clock-names = "stmmaceth", "tx-clk", "rx-clk";
+			clock-names = "stmmaceth", "mac-clk-tx", "mac-clk-rx";
 			clocks = <&rcc 0 25>, <&rcc 0 26>, <&rcc 0 27>;
 			st,syscon = <&syscfg 0x4>;
 			snps,pbl = <8>;
-- 
1.9.1

--
To unsubscribe from this list: send the line "unsubscribe devicetree" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
