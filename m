From: Thomas Petazzoni <thomas.petazzoni@free-electrons.com>
Subject: [PATCH net-next 01/27] dt-bindings: net: update Marvell PPv2 binding
 for PPv2.2 support
Date: Wed, 21 Dec 2016 12:16:08 +0100
Message-ID: <1482318994-23488-2-git-send-email-thomas.petazzoni@free-electrons.com>
References: <1482318994-23488-1-git-send-email-thomas.petazzoni@free-electrons.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: Thomas Petazzoni <thomas.petazzoni@free-electrons.com>,
 Andrew Lunn <andrew@lunn.ch>, Yehuda Yitschak <yehuday@marvell.com>,
 Jason Cooper <jason@lakedaemon.net>, Hanna Hawa <hannah@marvell.com>,
 Nadav Haklai <nadavh@marvell.com>,
 Gregory Clement <gregory.clement@free-electrons.com>,
 Stefan Chulski <stefanc@marvell.com>, Marcin Wojtas <mw@semihalf.com>,
 linux-arm-kernel@lists.infradead.org,
 Sebastian Hesselbarth <sebastian.hesselbarth@gmail.com>
To: "David S. Miller" <davem@davemloft.net>,
	netdev@vger.kernel.org
Return-path: <linux-arm-kernel-bounces+linux-arm-kernel=m.gmane.org@lists.infradead.org>
In-Reply-To: <1482318994-23488-1-git-send-email-thomas.petazzoni@free-electrons.com>
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

The Marvell PPv2 Device Tree binding was so far only used to describe
the PPv2.1 network controller, used in the Marvell Armada 375.

A new version of this IP block, PPv2.2 is used in the Marvell Armada
7K/8K processor. This commit extends the existing binding so that it can
also be used to describe PPv2.2 hardware.

Signed-off-by: Thomas Petazzoni <thomas.petazzoni@free-electrons.com>
---
 .../devicetree/bindings/net/marvell-pp2.txt        | 66 ++++++++++++++++++----
 1 file changed, 55 insertions(+), 11 deletions(-)

diff --git a/Documentation/devicetree/bindings/net/marvell-pp2.txt b/Documentation/devicetree/bindings/net/marvell-pp2.txt
index aa4f423..76071f3 100644
--- a/Documentation/devicetree/bindings/net/marvell-pp2.txt
+++ b/Documentation/devicetree/bindings/net/marvell-pp2.txt
@@ -1,17 +1,28 @@
-* Marvell Armada 375 Ethernet Controller (PPv2)
+* Marvell Armada 375 Ethernet Controller (PPv2.1)
+  Marvell Armada 7K/8K Ethernet Controller (PPv2.2)
 
 Required properties:
 
-- compatible: should be "marvell,armada-375-pp2"
+- compatible: should be one of:
+    "marvell,armada-375-pp2"
+    "marvell,armada-7k-pp2"
 - reg: addresses and length of the register sets for the device.
-  Must contain the following register sets:
+  For "marvell,armada-375-pp2", must contain the following register
+  sets:
 	- common controller registers
 	- LMS registers
-  In addition, at least one port register set is required.
-- clocks: a pointer to the reference clocks for this device, consequently:
-	- main controller clock
-	- GOP clock
-- clock-names: names of used clocks, must be "pp_clk" and "gop_clk".
+	- one register area per Ethernet port
+  For "marvell,armda-7k-pp2", must contain the following register
+  sets:
+        - common controller registers
+	- per-port registers
+
+- clocks: pointers to the reference clocks for this device, consequently:
+	- main controller clock (for both armada-375-pp2 and armada-7k-pp2)
+	- GOP clock (for both armada-375-pp2 and armada-7k-pp2)
+	- MG clock (only for armada-7k-pp2)
+- clock-names: names of used clocks, must be "pp_clk", "gop_clk" and
+  "mg_clk" (the latter only for armada-7k-pp2).
 
 The ethernet ports are represented by subnodes. At least one port is
 required.
@@ -19,8 +30,9 @@ required.
 Required properties (port):
 
 - interrupts: interrupt for the port
-- port-id: should be '0' or '1' for ethernet ports, and '2' for the
-           loopback port
+- port-id: ID of the port from the MAC point of view
+- gop-port-id: only for marvell,armada-7k-pp2, ID of the port from the
+  GOP (Group Of Ports) point of view
 - phy-mode: See ethernet.txt file in the same directory
 
 Optional properties (port):
@@ -31,7 +43,7 @@ Optional properties (port):
   then fixed link is assumed, and the 'fixed-link' property is
   mandatory.
 
-Example:
+Example for marvell,armada-375-pp2:
 
 ethernet@f0000 {
 	compatible = "marvell,armada-375-pp2";
@@ -59,3 +71,35 @@ ethernet@f0000 {
 		phy-mode = "gmii";
 	};
 };
+
+Example for marvell,armada-7k-pp2:
+
+cpm_ethernet: ethernet@0 {
+	compatible = "marvell,armada-7k-pp22";
+	reg = <0x0 0x100000>,
+	      <0x100000 0x80000>;
+	clocks = <&cpm_syscon0 1 3>, <&cpm_syscon0 1 9>, <&cpm_syscon0 1 5>;
+	clock-names = "pp_clk", "gop_clk", "gp_clk";
+	status = "disabled";
+
+	eth0: eth@0 {
+		interrupts = <GIC_SPI 37 IRQ_TYPE_LEVEL_HIGH>;
+		port-id = <0>;
+		gop-port-id = <0>;
+		status = "disabled";
+	};
+
+	eth1: eth@1 {
+		interrupts = <GIC_SPI 38 IRQ_TYPE_LEVEL_HIGH>;
+		port-id = <1>;
+		gop-port-id = <2>;
+		status = "disabled";
+	};
+
+	eth2: eth@2 {
+		interrupts = <GIC_SPI 39 IRQ_TYPE_LEVEL_HIGH>;
+		port-id = <2>;
+		gop-port-id = <3>;
+		status = "disabled";
+	};
+};
-- 
2.7.4
