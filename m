From: Zubair Lutfullah Kakakhel <Zubair.Kakakhel@imgtec.com>
Subject: [Patch v3 10/11] MIPS: xilfpga: Add DT node for AXI emaclite
Date: Wed, 31 Aug 2016 17:35:51 +0100
Message-ID: <1472661352-11983-11-git-send-email-Zubair.Kakakhel@imgtec.com>
References: <1472661352-11983-1-git-send-email-Zubair.Kakakhel@imgtec.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <soren.brinkmann@xilinx.com>, <Zubair.Kakakhel@imgtec.com>,
        <linux-kernel@vger.kernel.org>, <linux-mips@linux-mips.org>,
        <michal.simek@xilinx.com>, <netdev@vger.kernel.org>
To: <monstr@monstr.eu>, <ralf@linux-mips.org>, <tglx@linutronix.de>,
        <jason@lakedaemon.net>, <marc.zyngier@arm.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mailapp01.imgtec.com ([195.59.15.196]:44858 "EHLO
        mailapp01.imgtec.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S965127AbcHaQhH (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 31 Aug 2016 12:37:07 -0400
In-Reply-To: <1472661352-11983-1-git-send-email-Zubair.Kakakhel@imgtec.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The xilfpga platform has a Xilinx AXI emaclite block.

Add the DT node to use it.

Signed-off-by: Zubair Lutfullah Kakakhel <Zubair.Kakakhel@imgtec.com>

---
V2 -> V3
No change

V1 -> V2

Removed accidental local-mac-address entry
---
 arch/mips/boot/dts/xilfpga/nexys4ddr.dts | 26 ++++++++++++++++++++++++++
 1 file changed, 26 insertions(+)

diff --git a/arch/mips/boot/dts/xilfpga/nexys4ddr.dts b/arch/mips/boot/dts/xilfpga/nexys4ddr.dts
index 3658e21..1f25d0a 100644
--- a/arch/mips/boot/dts/xilfpga/nexys4ddr.dts
+++ b/arch/mips/boot/dts/xilfpga/nexys4ddr.dts
@@ -42,6 +42,32 @@
 		xlnx,tri-default = <0xffffffff>;
 	} ;
 
+	axi_ethernetlite: ethernet@10e00000 {
+		compatible = "xlnx,xps-ethernetlite-3.00.a";
+		device_type = "network";
+		interrupt-parent = <&axi_intc>;
+		interrupts = <1>;
+		phy-handle = <&phy0>;
+		reg = <0x10e00000 0x10000>;
+		xlnx,duplex = <0x1>;
+		xlnx,include-global-buffers = <0x1>;
+		xlnx,include-internal-loopback = <0x0>;
+		xlnx,include-mdio = <0x1>;
+		xlnx,instance = "axi_ethernetlite_inst";
+		xlnx,rx-ping-pong = <0x1>;
+		xlnx,s-axi-id-width = <0x1>;
+		xlnx,tx-ping-pong = <0x1>;
+		xlnx,use-internal = <0x0>;
+		mdio {
+			#address-cells = <1>;
+			#size-cells = <0>;
+			phy0: phy@1 {
+				device_type = "ethernet-phy";
+				reg = <1>;
+			};
+		};
+	};
+
 	axi_uart16550: serial@10400000 {
 		compatible = "ns16550a";
 		reg = <0x10400000 0x10000>;
-- 
1.9.1
