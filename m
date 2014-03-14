From: Vince Bridgers <vbridgers2013@gmail.com>
Subject: [PATCH net-next V5 1/9] dts: Add bindings for the Altera Triple Speed Ethernet driver
Date: Fri, 14 Mar 2014 09:04:39 -0500
Message-ID: <1394805887-22030-2-git-send-email-vbridgers2013@gmail.com>
References: <1394805887-22030-1-git-send-email-vbridgers2013@gmail.com>
Cc: robh+dt@kernel.org, pawel.moll@arm.com, mark.rutland@arm.com,
	ijc+devicetree@hellion.org.uk, galak@codeaurora.org,
	rob@landley.net, vbridgers2013@gmail.com
To: devicetree@vger.kernel.org, netdev@vger.kernel.org,
	linux-doc@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-oa0-f51.google.com ([209.85.219.51]:53578 "EHLO
	mail-oa0-f51.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754713AbaCNOJe (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 14 Mar 2014 10:09:34 -0400
In-Reply-To: <1394805887-22030-1-git-send-email-vbridgers2013@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patch adds a bindings description for the Altera Triple Speed Ethernet
(TSE) driver. The bindings support the legacy SGDMA soft IP as well as the
preferred MSGDMA soft IP. The TSE can be configured and synthesized in soft
logic using Altera's Quartus toolchain. Please consult the bindings document
for supported options.

Signed-off-by: Vince Bridgers <vbridgers2013@gmail.com>
---
V5: - No changes for V5

V4: - No change to this file for V4

V3: - Change order of commits
    - Change names of enable-sup-addr and enable-hash to
      has-supplementary-unicast and has-hash-multicast-filter
      respectively, change interpretation to boolen/empty.
    - Update devicetree to include commas in unit addresses.
    - Bracket address lists for consistency
    - Bracket interrupt list for consistency
    - Drop unit address from mdio node

V2: - Update bindings to use standard Ethernet and Phy bindings.
      Use standard "phy-addr" instead of Altera's "phy-addr".
      Use "rx-fifo-depth" and "tx-fifo-depth" instead of versions
      prepended with "altr," in units of 32-bit quantities.
      Add missing bindings to describe "altr,enable-hash" and
      "altr,enable-sup-addr".
---
 .../devicetree/bindings/net/altera_tse.txt         |  114 ++++++++++++++++++++
 1 file changed, 114 insertions(+)
 create mode 100644 Documentation/devicetree/bindings/net/altera_tse.txt

diff --git a/Documentation/devicetree/bindings/net/altera_tse.txt b/Documentation/devicetree/bindings/net/altera_tse.txt
new file mode 100644
index 0000000..a706297
--- /dev/null
+++ b/Documentation/devicetree/bindings/net/altera_tse.txt
@@ -0,0 +1,114 @@
+* Altera Triple-Speed Ethernet MAC driver (TSE)
+
+Required properties:
+- compatible: Should be "altr,tse-1.0" for legacy SGDMA based TSE, and should
+		be "altr,tse-msgdma-1.0" for the preferred MSGDMA based TSE.
+		ALTR is supported for legacy device trees, but is deprecated.
+		altr should be used for all new designs.
+- reg: Address and length of the register set for the device. It contains
+  the information of registers in the same order as described by reg-names
+- reg-names: Should contain the reg names
+  "control_port": MAC configuration space region
+  "tx_csr":       xDMA Tx dispatcher control and status space region
+  "tx_desc":      MSGDMA Tx dispatcher descriptor space region
+  "rx_csr" :      xDMA Rx dispatcher control and status space region
+  "rx_desc":      MSGDMA Rx dispatcher descriptor space region
+  "rx_resp":      MSGDMA Rx dispatcher response space region
+  "s1":		  SGDMA descriptor memory
+- interrupts: Should contain the TSE interrupts and it's mode.
+- interrupt-names: Should contain the interrupt names
+  "rx_irq":       xDMA Rx dispatcher interrupt
+  "tx_irq":       xDMA Tx dispatcher interrupt
+- rx-fifo-depth: MAC receive FIFO buffer depth in bytes
+- tx-fifo-depth: MAC transmit FIFO buffer depth in bytes
+- phy-mode: See ethernet.txt in the same directory.
+- phy-handle: See ethernet.txt in the same directory.
+- phy-addr: See ethernet.txt in the same directory. A configuration should
+		include phy-handle or phy-addr.
+- altr,has-supplementary-unicast:
+		If present, TSE supports additional unicast addresses.
+		Otherwise additional unicast addresses are not supported.
+- altr,has-hash-multicast-filter:
+		If present, TSE supports a hash based multicast filter.
+		Otherwise, hash-based multicast filtering is not supported.
+
+- mdio device tree subnode: When the TSE has a phy connected to its local
+		mdio, there must be device tree subnode with the following
+		required properties:
+
+	- compatible: Must be "altr,tse-mdio".
+	- #address-cells: Must be <1>.
+	- #size-cells: Must be <0>.
+
+	For each phy on the mdio bus, there must be a node with the following
+	fields:
+
+	- reg: phy id used to communicate to phy.
+	- device_type: Must be "ethernet-phy".
+
+Optional properties:
+- local-mac-address: See ethernet.txt in the same directory.
+- max-frame-size: See ethernet.txt in the same directory.
+
+Example:
+
+	tse_sub_0_eth_tse_0: ethernet@0x1,00000000 {
+		compatible = "altr,tse-msgdma-1.0";
+		reg =	<0x00000001 0x00000000 0x00000400>,
+			<0x00000001 0x00000460 0x00000020>,
+			<0x00000001 0x00000480 0x00000020>,
+			<0x00000001 0x000004A0 0x00000008>,
+			<0x00000001 0x00000400 0x00000020>,
+			<0x00000001 0x00000420 0x00000020>;
+		reg-names = "control_port", "rx_csr", "rx_desc", "rx_resp", "tx_csr", "tx_desc";
+		interrupt-parent = <&hps_0_arm_gic_0>;
+		interrupts = <0 41 4>, <0 40 4>;
+		interrupt-names = "rx_irq", "tx_irq";
+		rx-fifo-depth = <2048>;
+		tx-fifo-depth = <2048>;
+		address-bits = <48>;
+		max-frame-size = <1500>;
+		local-mac-address = [ 00 00 00 00 00 00 ];
+		phy-mode = "gmii";
+		altr,has-supplementary-unicast;
+		altr,has-hash-multicast-filter;
+		phy-handle = <&phy0>;
+		mdio {
+			compatible = "altr,tse-mdio";
+			#address-cells = <1>;
+			#size-cells = <0>;
+			phy0: ethernet-phy@0 {
+				reg = <0x0>;
+				device_type = "ethernet-phy";
+			};
+
+			phy1: ethernet-phy@1 {
+				reg = <0x1>;
+				device_type = "ethernet-phy";
+			};
+
+		};
+	};
+
+	tse_sub_1_eth_tse_0: ethernet@0x1,00001000 {
+		compatible = "altr,tse-msgdma-1.0";
+		reg = 	<0x00000001 0x00001000 0x00000400>,
+			<0x00000001 0x00001460 0x00000020>,
+			<0x00000001 0x00001480 0x00000020>,
+			<0x00000001 0x000014A0 0x00000008>,
+			<0x00000001 0x00001400 0x00000020>,
+			<0x00000001 0x00001420 0x00000020>;
+		reg-names = "control_port", "rx_csr", "rx_desc", "rx_resp", "tx_csr", "tx_desc";
+		interrupt-parent = <&hps_0_arm_gic_0>;
+		interrupts = <0 43 4>, <0 42 4>;
+		interrupt-names = "rx_irq", "tx_irq";
+		rx-fifo-depth = <2048>;
+		tx-fifo-depth = <2048>;
+		address-bits = <48>;
+		max-frame-size = <1500>;
+		local-mac-address = [ 00 00 00 00 00 00 ];
+		phy-mode = "gmii";
+		altr,has-supplementary-unicast;
+		altr,has-hash-multicast-filter;
+		phy-handle = <&phy1>;
+	};
-- 
1.7.9.5
