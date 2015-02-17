From: Stathis Voukelatos <stathis.voukelatos@linn.co.uk>
Subject: [PATCH v2 1/3] Ethernet packet sniffer: Device tree binding and vendor prefix
Date: Tue, 17 Feb 2015 14:03:31 +0000
Message-ID: <0a86907642a97e5bd880f69299664232fcffaf9d.1424181053.git.stathis.voukelatos@linn.co.uk>
References: <cover.1424181053.git.stathis.voukelatos@linn.co.uk>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <abrestic@chromium.org>,
	Stathis Voukelatos <stathis.voukelatos@linn.co.uk>
To: <linux-kernel@vger.kernel.org>, <devicetree@vger.kernel.org>,
	<netdev@vger.kernel.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <cover.1424181053.git.stathis.voukelatos@linn.co.uk>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Signed-off-by: Stathis Voukelatos <stathis.voukelatos@linn.co.uk>
---
 .../bindings/net/linn-ether-packet-sniffer.txt     | 42 ++++++++++++++++++++++
 .../devicetree/bindings/vendor-prefixes.txt        |  1 +
 2 files changed, 43 insertions(+)
 create mode 100644 Documentation/devicetree/bindings/net/linn-ether-packet-sniffer.txt

diff --git a/Documentation/devicetree/bindings/net/linn-ether-packet-sniffer.txt b/Documentation/devicetree/bindings/net/linn-ether-packet-sniffer.txt
new file mode 100644
index 0000000..74bac5e
--- /dev/null
+++ b/Documentation/devicetree/bindings/net/linn-ether-packet-sniffer.txt
@@ -0,0 +1,42 @@
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
+- compatible : must be "linn,eth-sniffer"
+- reg : physical addresses and sizes of registers. Must contain 3 entries:
+          - registers memory space
+          - TX command string memory
+          - RX command string memory
+- reg-names : must contain the following 3 entries:
+                  "regs", "tx-ram", "rx-ram"
+- interrupts : sniffer interrupt specifier
+- clocks : specify the system clock for the peripheral and
+	   the enable clock for the timestamp counter
+- clock-names : must contain the "sys" and "tstamp" entries
+- fifo-block-words : number of words in one data FIFO entry
+- tstamp-hz : frequency of the timestamp counter
+- tstamp-shift : shift value for the timestamp cyclecounter struct
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
+	clocks = <&clk_core CLK_AUDIO>,
+		 <&cr_periph SYS_CLK_EVENT_TIMER>;
+	clock-names = "sys", "tstamp";
+	fifo-block-words = <4>;
+	tstamp-hz = <52000000>;
+	tstamp-shift = <27>;
+	tstamp-bits = <30>;
+};
diff --git a/Documentation/devicetree/bindings/vendor-prefixes.txt b/Documentation/devicetree/bindings/vendor-prefixes.txt
index d443279..891c224 100644
--- a/Documentation/devicetree/bindings/vendor-prefixes.txt
+++ b/Documentation/devicetree/bindings/vendor-prefixes.txt
@@ -90,6 +90,7 @@ lacie	LaCie
 lantiq	Lantiq Semiconductor
 lenovo	Lenovo Group Ltd.
 lg	LG Corporation
+linn    Linn Products Ltd.
 linux	Linux-specific binding
 lsi	LSI Corp. (LSI Logic)
 lltc	Linear Technology Corporation
-- 
1.9.1
