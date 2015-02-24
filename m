From: Stathis Voukelatos <stathis.voukelatos@linn.co.uk>
Subject: [PATCH net-next v4 1/3] Linn Ethernet packet sniffer: device tree binding and vendor prefix
Date: Tue, 24 Feb 2015 16:48:09 +0000
Message-ID: <38762690771e8cf3ab721b37b6af20c72e45be32.1424796018.git.stathis.voukelatos@linn.co.uk>
References: <cover.1424796018.git.stathis.voukelatos@linn.co.uk>
Mime-Version: 1.0
Content-Type: text/plain
Cc: Stathis Voukelatos <stathis.voukelatos@linn.co.uk>
To: <linux-kernel@vger.kernel.org>, <netdev@vger.kernel.org>,
	<devicetree@vger.kernel.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <cover.1424796018.git.stathis.voukelatos@linn.co.uk>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Signed-off-by: Stathis Voukelatos <stathis.voukelatos@linn.co.uk>
---
 .../bindings/net/linn-ether-packet-sniffer.txt     | 39 ++++++++++++++++++++++
 .../devicetree/bindings/vendor-prefixes.txt        |  1 +
 2 files changed, 40 insertions(+)
 create mode 100644 Documentation/devicetree/bindings/net/linn-ether-packet-sniffer.txt

diff --git a/Documentation/devicetree/bindings/net/linn-ether-packet-sniffer.txt b/Documentation/devicetree/bindings/net/linn-ether-packet-sniffer.txt
new file mode 100644
index 0000000..66bfc48
--- /dev/null
+++ b/Documentation/devicetree/bindings/net/linn-ether-packet-sniffer.txt
@@ -0,0 +1,39 @@
+* Linn Products Ethernet Packet Sniffer
+The module allows Ethernet packets to be parsed, matched against
+a user-defined pattern and timestamped. It sits between a 100M
+Ethernet MAC and PHY and is completely passive with respect to
+Ethernet frames.
+Matched packet bytes and timestamp values are returned through a
+FIFO. Timestamps are provided to the module through an externally
+generated Gray-encoded counter.
+
+Required properties:
+- compatible : must be "linn,eth-packet-sniffer"
+- reg : a list of physical address and size pairs corresponding to
+	each entry in 'reg-names'
+- reg-names : must contain:
+		"regs"   : control registers
+		"tx-ram" : TX command string memory
+		"rx-ram" : RX command string memory
+- interrupts : sniffer interrupt specifier
+- clocks : list of clocks corresponding to each entry in 'clock-names'
+- clock-names : must contain:
+		"sys"    : system clock for the peripheral
+		"tstamp" : timestamp counter clock
+- fifo-block-words : number of words in one data FIFO entry
+- tstamp-bits : width in bits of the timestamp counter
+
+Example:
+
+sniffer@1814a000 {
+	compatible = "linn,eth-sniffer";
+	reg = <0x1814a000 0x100>, <0x1814a400 0x400>,
+	      <0x1814a800 0x400>;
+	reg-names = "regs", "tx-ram", "rx-ram";
+	interrupts = <GIC_SHARED 58 IRQ_TYPE_LEVEL_HIGH>;
+	clocks = <&cr_periph SYS_CLK_ENET>,
+		 <&clk_core CLK_AUDIO>;
+	clock-names = "sys", "tstamp";
+	fifo-block-words = <4>;
+	tstamp-bits = <30>;
+};
diff --git a/Documentation/devicetree/bindings/vendor-prefixes.txt b/Documentation/devicetree/bindings/vendor-prefixes.txt
index 389ca13..f685707 100644
--- a/Documentation/devicetree/bindings/vendor-prefixes.txt
+++ b/Documentation/devicetree/bindings/vendor-prefixes.txt
@@ -102,6 +102,7 @@ lacie	LaCie
 lantiq	Lantiq Semiconductor
 lenovo	Lenovo Group Ltd.
 lg	LG Corporation
+linn	Linn Products Ltd.
 linux	Linux-specific binding
 lsi	LSI Corp. (LSI Logic)
 lltc	Linear Technology Corporation
-- 
1.9.1
