From: Alexandre TORGUE <alexandre.torgue@gmail.com>
Subject: [PATCH v2 2/4] Documentation: Bindings: Add STM32 DWMAC glue
Date: Tue, 23 Feb 2016 16:10:42 +0100
Message-ID: <1456240244-10275-3-git-send-email-alexandre.torgue@gmail.com>
References: <1456240244-10275-1-git-send-email-alexandre.torgue@gmail.com>
Cc: linux-arm-kernel@lists.infradead.org, linux-kernel@vger.kernel.org
To: Maxime Coquelin <mcoquelin.stm32@gmail.com>,
	Giuseppe Cavallaro <peppe.cavallaro@st.com>,
	netdev@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1456240244-10275-1-git-send-email-alexandre.torgue@gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Signed-off-by: Alexandre TORGUE <alexandre.torgue@gmail.com>

diff --git a/Documentation/devicetree/bindings/net/stm32-dwmac.txt b/Documentation/devicetree/bindings/net/stm32-dwmac.txt
new file mode 100644
index 0000000..18734b3
--- /dev/null
+++ b/Documentation/devicetree/bindings/net/stm32-dwmac.txt
@@ -0,0 +1,41 @@
+STMicroelectronics STM32 / MCU DWMAC glue layer controller
+
+This file documents platform glue layer for stmmac.
+Please see stmmac.txt for the other unchanged properties.
+
+The device node has following properties.
+
+Required properties:
+- compatible:  Should be "st,stm32-dwmac" to select glue, and
+	       "snps,dwmac-3.50a" to select IP vesrion.
+- clocks: Should contain the GMAC main clock, and tx clock
+- compatible:  Should be "st,stm32-dwmac" to select glue and
+	       "snps,dwmac-3.50a" to select IP version.
+- clocks: Should contain the MAC main clock
+- clock-names: Should contain the clock names "stmmaceth".
+- st,syscon : Should be phandle/offset pair. The phandle to the syscon node which
+	      encompases the glue register, and the offset of the control register.
+
+Optional properties:
+- clocks: Could contain:
+	- the tx clock,
+	- the rx clock
+- clock-names: Could contain the clock names "tx-clk", "rx-clk"
+
+Example:
+
+		ethernet0: dwmac@40028000 {
+			device_type = "network";
+			compatible = "st,stm32-dwmac", "snps,dwmac-3.50a";
+			status = "disabled";
+			reg = <0x40028000 0x8000>;
+			reg-names = "stmmaceth";
+			interrupts = <0 61 0>, <0 62 0>;
+			interrupt-names = "macirq", "eth_wake_irq";
+			clock-names = "stmmaceth", "tx-clk", "rx-clk";
+			clocks = <&rcc 0 25>, <&rcc 0 26>, <&rcc 0 27>;
+			st,syscon = <&syscfg 0x4>;
+			snps,pbl = <32>;
+			snps,mixed-burst;
+			dma-ranges;
+		};
-- 
1.9.1
