From: Alexandre TORGUE <alexandre.torgue@gmail.com>
Subject: [RESEND PATCH v6 5/6] ARM: dts: stm32f429: Align Ethernet node with new bindings properties
Date: Mon,  9 May 2016 12:31:38 +0200
Message-ID: <1462789899-13153-6-git-send-email-alexandre.torgue@gmail.com>
References: <1462789899-13153-1-git-send-email-alexandre.torgue@gmail.com>
Cc: linux-arm-kernel@lists.infradead.org, linux-kernel@vger.kernel.org,
	robh@kernel.org, manabian@gmail.com, wens@csie.org
To: Maxime Coquelin <mcoquelin.stm32@gmail.com>,
	Giuseppe Cavallaro <peppe.cavallaro@st.com>,
	netdev@vger.kernel.org, devicetree@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f65.google.com ([74.125.82.65]:34197 "EHLO
	mail-wm0-f65.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752690AbcEIKcM (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 9 May 2016 06:32:12 -0400
In-Reply-To: <1462789899-13153-1-git-send-email-alexandre.torgue@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patch aligns clocks names and node reference according to new
stm32-dwmac glue binding. It also renames Ethernet pinctrl phandle
(indeed there is no need to add 0 as Ethernet instance as there is only
one IP in SOC).

Signed-off-by: Alexandre TORGUE <alexandre.torgue@gmail.com>

diff --git a/arch/arm/boot/dts/stm32f429.dtsi b/arch/arm/boot/dts/stm32f429.dtsi
index 35df462..5995998 100644
--- a/arch/arm/boot/dts/stm32f429.dtsi
+++ b/arch/arm/boot/dts/stm32f429.dtsi
@@ -304,7 +304,7 @@
 				};
 			};
 
-			ethernet0_mii: mii@0 {
+			ethernet_mii: mii@0 {
 				pins {
 					pinmux = <STM32F429_PG13_FUNC_ETH_MII_TXD0_ETH_RMII_TXD0>,
 						 <STM32F429_PG14_FUNC_ETH_MII_TXD1_ETH_RMII_TXD1>,
@@ -363,13 +363,13 @@
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
