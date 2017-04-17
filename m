From: Benjamin Herrenschmidt <benh@kernel.crashing.org>
Subject: [PATCH v3 9/9] ftgmac100: Document device-tree binding
Date: Tue, 18 Apr 2017 08:37:06 +1000
Message-ID: <20170417223706.16483-10-benh@kernel.crashing.org>
References: <20170417223706.16483-1-benh@kernel.crashing.org>
Cc: Benjamin Herrenschmidt <benh@kernel.crashing.org>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from gate.crashing.org ([63.228.1.57]:51421 "EHLO gate.crashing.org"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1755661AbdDQWlX (ORCPT <rfc822;netdev@vger.kernel.org>);
        Mon, 17 Apr 2017 18:41:23 -0400
In-Reply-To: <20170417223706.16483-1-benh@kernel.crashing.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Signed-off-by: Benjamin Herrenschmidt <benh@kernel.crashing.org>
--

v3. - Update supported values for phy-mode
---
 .../devicetree/bindings/net/ftgmac100.txt          | 37 ++++++++++++++++++++++
 1 file changed, 37 insertions(+)
 create mode 100644 Documentation/devicetree/bindings/net/ftgmac100.txt

diff --git a/Documentation/devicetree/bindings/net/ftgmac100.txt b/Documentation/devicetree/bindings/net/ftgmac100.txt
new file mode 100644
index 0000000..fceeede
--- /dev/null
+++ b/Documentation/devicetree/bindings/net/ftgmac100.txt
@@ -0,0 +1,37 @@
+* Faraday Technology FTGMAC100 gigabit ethernet controller
+
+Required properties:
+- compatible: "faraday,ftgmac100"
+
+  Must also contain one of these if used as part of an Aspeed AST2400
+  or 2500 family SoC as they have some subtle tweaks to the
+  implementation:
+
+     - "aspeed,ast2400-mac"
+     - "aspeed,ast2500-mac"
+
+- reg: Address and length of the register set for the device
+- interrupts: Should contain ethernet controller interrupt
+
+Optional properties:
+- phy-mode: See ethernet.txt file in the same directory. If the property is
+  absent, "rgmii" is assumed. Supported values are "rgmii*" and "rmii" for
+  aspeed parts. Other (unknown) parts will accept any value.
+- use-ncsi: Use the NC-SI stack instead of an MDIO PHY. Currently assumes
+  rmii (100bT) but kept as a separate property in case NC-SI grows support
+  for a gigabit link.
+- no-hw-checksum: Used to disable HW checksum support. Here for backward
+  compatibility as the driver now should have correct defaults based on
+  the SoC.
+
+Example:
+
+	mac0: ethernet@1e660000 {
+		compatible = "aspeed,ast2500-mac", "faraday,ftgmac100";
+		reg = <0x1e660000 0x180>;
+		interrupts = <2>;
+		status = "okay";
+		use-ncsi;
+	};
+
+
-- 
2.9.3
