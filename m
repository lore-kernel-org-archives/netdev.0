From: Alexandre TORGUE <alexandre.torgue@gmail.com>
Subject: [PATCH v4 2/4] Documentation: Bindings: Add STM32 DWMAC glue
Date: Fri,  4 Mar 2016 16:58:04 +0100
Message-ID: <1457107086-14764-3-git-send-email-alexandre.torgue@gmail.com>
References: <1457107086-14764-1-git-send-email-alexandre.torgue@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: devicetree@vger.kernel.org, manabian@gmail.com,
 linux-kernel@vger.kernel.org, linux-arm-kernel@lists.infradead.org
To: Maxime Coquelin <mcoquelin.stm32@gmail.com>,
 Giuseppe Cavallaro <peppe.cavallaro@st.com>, netdev@vger.kernel.org
Return-path: <linux-arm-kernel-bounces+linux-arm-kernel=m.gmane.org@lists.infradead.org>
In-Reply-To: <1457107086-14764-1-git-send-email-alexandre.torgue@gmail.com>
List-Unsubscribe: <http://lists.infradead.org/mailman/options/linux-arm-kernel>,
 <mailto:linux-arm-kernel-request@lists.infradead.org?subject=unsubscribe>
List-Archive: <http://lists.infradead.org/pipermail/linux-arm-kernel/>
List-Post: <mailto:linux-arm-kernel@lists.infradead.org>
List-Help: <mailto:linux-arm-kernel-request@lists.infradead.org?subject=help>
List-Subscribe: <http://lists.infradead.org/mailman/listinfo/linux-arm-kernel>,
 <mailto:linux-arm-kernel-request@lists.infradead.org?subject=subscribe>
Sender: "linux-arm-kernel" <linux-arm-kernel-bounces@lists.infradead.org>
Errors-To: linux-arm-kernel-bounces+linux-arm-kernel=m.gmane.org@lists.infradead.org
List-Id: netdev.vger.kernel.org

Signed-off-by: Alexandre TORGUE <alexandre.torgue@gmail.com>

diff --git a/Documentation/devicetree/bindings/net/stm32-dwmac.txt b/Documentation/devicetree/bindings/net/stm32-dwmac.txt
new file mode 100644
index 0000000..fd3566f
--- /dev/null
+++ b/Documentation/devicetree/bindings/net/stm32-dwmac.txt
@@ -0,0 +1,35 @@
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
+- clocks: Must contain an entry for each entry in clock-names.
+- clock-names: Should be "stmmaceth" for the host clock.
+	       Should be "tx-clk" for the MAC TX clock.
+	       Should be "rx-clk" for the MAC RX clock.
+- st,syscon : Should be phandle/offset pair. The phandle to the syscon node which
+	      encompases the glue register, and the offset of the control register.
+Example:
+
+		ethernet0: dwmac@40028000 {
+			compatible = "st,stm32-dwmac", "snps,dwmac-3.50a";
+			status = "disabled";
+			reg = <0x40028000 0x8000>;
+			reg-names = "stmmaceth";
+			interrupts = <0 61 0>, <0 62 0>;
+			interrupt-names = "macirq", "eth_wake_irq";
+			clock-names = "stmmaceth", "tx-clk", "rx-clk";
+			clocks = <&rcc 0 25>, <&rcc 0 26>, <&rcc 0 27>;
+			st,syscon = <&syscfg 0x4>;
+			snps,pbl = <8>;
+			snps,mixed-burst;
+			dma-ranges;
+		};
-- 
1.9.1
