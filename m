From: Zubair Lutfullah Kakakhel <Zubair.Kakakhel@imgtec.com>
Subject: [PATCH V2 06/10] MIPS: Xilfpga: Add DT node for AXI I2C
Date: Thu, 18 Aug 2016 14:43:20 +0100
Message-ID: <1471527804-26175-7-git-send-email-Zubair.Kakakhel@imgtec.com>
References: <1471527804-26175-1-git-send-email-Zubair.Kakakhel@imgtec.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <jason@lakedaemon.net>, <marc.zyngier@arm.com>,
        <linux-mips@linux-mips.org>, <linux-kernel@vger.kernel.org>,
        <netdev@vger.kernel.org>, <Zubair.Kakakhel@imgtec.com>
To: <monstr@monstr.eu>, <ralf@linux-mips.org>, <tglx@linutronix.de>
Return-path: <linux-mips-bounce@linux-mips.org>
In-Reply-To: <1471527804-26175-1-git-send-email-Zubair.Kakakhel@imgtec.com>
Sender: linux-mips-bounce@linux-mips.org
Errors-to: linux-mips-bounce@linux-mips.org
List-help: <mailto:ecartis@linux-mips.org?Subject=help>
List-unsubscribe: <mailto:ecartis@linux-mips.org?subject=unsubscribe%20linux-mips>
List-software: Ecartis version 1.0.0
List-subscribe: <mailto:ecartis@linux-mips.org?subject=subscribe%20linux-mips>
List-owner: <mailto:ralf@linux-mips.org>
List-post: <mailto:linux-mips@linux-mips.org>
List-archive: <http://www.linux-mips.org/archives/linux-mips/>
List-Id: netdev.vger.kernel.org

The xilfpga platform has an AXI I2C Bus master with a temperature
sensor connected to it.

Add the device tree node to use them.

Signed-off-by: Zubair Lutfullah Kakakhel <Zubair.Kakakhel@imgtec.com>

---
V1 -> V2

No change
---
 arch/mips/boot/dts/xilfpga/nexys4ddr.dts | 22 ++++++++++++++++++++++
 1 file changed, 22 insertions(+)

diff --git a/arch/mips/boot/dts/xilfpga/nexys4ddr.dts b/arch/mips/boot/dts/xilfpga/nexys4ddr.dts
index d285c8d..3658e21 100644
--- a/arch/mips/boot/dts/xilfpga/nexys4ddr.dts
+++ b/arch/mips/boot/dts/xilfpga/nexys4ddr.dts
@@ -54,6 +54,28 @@
 		interrupt-parent = <&axi_intc>;
 		interrupts = <0>;
 	};
+
+	axi_i2c: i2c@10A00000 {
+	    compatible = "xlnx,xps-iic-2.00.a";
+	    interrupt-parent = <&axi_intc>;
+	    interrupts = <4>;
+	    reg = < 0x10A00000 0x10000 >;
+	    clocks = <&ext>;
+	    xlnx,clk-freq = <0x5f5e100>;
+	    xlnx,family = "Artix7";
+	    xlnx,gpo-width = <0x1>;
+	    xlnx,iic-freq = <0x186a0>;
+	    xlnx,scl-inertial-delay = <0x0>;
+	    xlnx,sda-inertial-delay = <0x0>;
+	    xlnx,ten-bit-adr = <0x0>;
+	    #address-cells = <1>;
+	    #size-cells = <0>;
+
+	    ad7420@4B {
+		compatible = "adt7420";
+		reg = <0x4B>;
+	    };
+	} ;
 };
 
 &ext {
-- 
1.9.1
