From: Alexandre TORGUE <alexandre.torgue@st.com>
Subject: [RESEND PATCH v6 2/3] Documentation: Bindings: Add STM32 DWMAC glue
Date: Mon, 29 Aug 2016 18:23:39 +0200
Message-ID: <1472487820-5132-3-git-send-email-alexandre.torgue@st.com>
References: <1472487820-5132-1-git-send-email-alexandre.torgue@st.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <robh@kernel.org>, <manabian@gmail.com>
To: <netdev@vger.kernel.org>, <peppe.cavallaro@st.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx08-00178001.pphosted.com ([91.207.212.93]:47511 "EHLO
        mx07-00178001.pphosted.com" rhost-flags-OK-OK-OK-FAIL)
        by vger.kernel.org with ESMTP id S1754231AbcH2QYX (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 29 Aug 2016 12:24:23 -0400
In-Reply-To: <1472487820-5132-1-git-send-email-alexandre.torgue@st.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Alexandre TORGUE <alexandre.torgue@gmail.com>

Acked-by: Rob Herring <robh@kernel.org>
Signed-off-by: Alexandre TORGUE <alexandre.torgue@gmail.com>

diff --git a/Documentation/devicetree/bindings/net/stm32-dwmac.txt b/Documentation/devicetree/bindings/net/stm32-dwmac.txt
new file mode 100644
index 0000000..c35afb7
--- /dev/null
+++ b/Documentation/devicetree/bindings/net/stm32-dwmac.txt
@@ -0,0 +1,32 @@
+STMicroelectronics STM32 / MCU DWMAC glue layer controller
+
+This file documents platform glue layer for stmmac.
+Please see stmmac.txt for the other unchanged properties.
+
+The device node has following properties.
+
+Required properties:
+- compatible:  Should be "st,stm32-dwmac" to select glue, and
+	       "snps,dwmac-3.50a" to select IP version.
+- clocks: Must contain a phandle for each entry in clock-names.
+- clock-names: Should be "stmmaceth" for the host clock.
+	       Should be "mac-clk-tx" for the MAC TX clock.
+	       Should be "mac-clk-rx" for the MAC RX clock.
+- st,syscon : Should be phandle/offset pair. The phandle to the syscon node which
+	      encompases the glue register, and the offset of the control register.
+Example:
+
+	ethernet@40028000 {
+		compatible = "st,stm32-dwmac", "snps,dwmac-3.50a";
+		status = "disabled";
+		reg = <0x40028000 0x8000>;
+		reg-names = "stmmaceth";
+		interrupts = <0 61 0>, <0 62 0>;
+		interrupt-names = "macirq", "eth_wake_irq";
+		clock-names = "stmmaceth", "mac-clk-tx", "mac-clk-rx";
+		clocks = <&rcc 0 25>, <&rcc 0 26>, <&rcc 0 27>;
+		st,syscon = <&syscfg 0x4>;
+		snps,pbl = <8>;
+		snps,mixed-burst;
+		dma-ranges;
+	};
-- 
1.9.1
