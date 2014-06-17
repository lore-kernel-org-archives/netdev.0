From: Iyappan Subramanian <isubramanian@apm.com>
Subject: [PATCH v6 2/4] Documentation: dts: Add bindings for APM X-Gene SoC ethernet driver
Date: Mon, 16 Jun 2014 17:18:44 -0700
Message-ID: <1402964326-11147-3-git-send-email-isubramanian@apm.com>
References: <1402964326-11147-1-git-send-email-isubramanian@apm.com>
Cc: gregkh@linuxfoundation.org, linux-kernel@vger.kernel.org,
	linux-arm-kernel@lists.infradead.org, jcm@redhat.com,
	patches@apm.com, Iyappan Subramanian <isubramanian@apm.com>,
	Ravi Patel <rapatel@apm.com>, Keyur Chudgar <kchudgar@apm.com>
To: davem@davemloft.net, netdev@vger.kernel.org,
	devicetree@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from exprod5og105.obsmtp.com ([64.18.0.180]:34196 "HELO
	exprod5og105.obsmtp.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with SMTP id S1753086AbaFQATZ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 16 Jun 2014 20:19:25 -0400
Received: by mail-pb0-f49.google.com with SMTP id rr13so1932600pbb.22
        for <netdev@vger.kernel.org>; Mon, 16 Jun 2014 17:19:24 -0700 (PDT)
In-Reply-To: <1402964326-11147-1-git-send-email-isubramanian@apm.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patch adds documentation for APM X-Gene SoC ethernet DTS binding.

Signed-off-by: Iyappan Subramanian <isubramanian@apm.com>
Signed-off-by: Ravi Patel <rapatel@apm.com>
Signed-off-by: Keyur Chudgar <kchudgar@apm.com>
---
 .../devicetree/bindings/net/apm-xgene-enet.txt     | 72 ++++++++++++++++++++++
 1 file changed, 72 insertions(+)
 create mode 100644 Documentation/devicetree/bindings/net/apm-xgene-enet.txt

diff --git a/Documentation/devicetree/bindings/net/apm-xgene-enet.txt b/Documentation/devicetree/bindings/net/apm-xgene-enet.txt
new file mode 100644
index 0000000..3e2a295
--- /dev/null
+++ b/Documentation/devicetree/bindings/net/apm-xgene-enet.txt
@@ -0,0 +1,72 @@
+APM X-Gene SoC Ethernet nodes
+
+Ethernet nodes are defined to describe on-chip ethernet interfaces in
+APM X-Gene SoC.
+
+Required properties:
+- compatible:		Should be "apm,xgene-enet"
+- reg: Address and length of the register set for the device. It contains the
+       information of registers in the same order as described by reg-names
+- reg-names: Should contain the register set names
+  "enet_csr":		Ethernet control and status register address space
+  "ring_csr":		Descriptor ring control and status register address space
+  "ring_cmd":		Descriptor ring command register address space
+- interrupts:		Ethernet main interrupt
+- clocks:		Reference to the clock entry.
+- local-mac-address:	MAC address assigned to this device
+- phy-connection-type:	Interface type between ethernet device and PHY device
+- phy-handle:		Reference to a PHY node connected to this device
+
+- mdio: 		Device tree subnode with the following required
+			properties:
+
+	- compatible: Must be "apm,xgene-mdio".
+	- #address-cells: Must be <1>.
+	- #size-cells: Must be <0>.
+
+	For the phy on the mdio bus, there must be a node with the following
+	fields:
+
+	- compatible: PHY identifier.  Please refer ./phy.txt for the format.
+	- reg: The ID number for the phy.
+
+Optional properties:
+- status		: Should be "ok" or "disabled" for enabled/disabled.
+			  Default is "ok".
+
+
+Example:
+	menetclk: menetclk {
+		compatible = "apm,xgene-device-clock";
+		clock-output-names = "menetclk";
+		status = "ok";
+	};
+
+	menet: ethernet@17020000 {
+		compatible = "apm,xgene-enet";
+		status = "disabled";
+		reg = <0x0 0x17020000 0x0 0xd100>,
+		      <0x0 0X17030000 0x0 0X400>,
+		      <0x0 0X10000000 0x0 0X200>;
+		reg-names = "enet_csr", "ring_csr", "ring_cmd";
+		interrupts = <0x0 0x3c 0x4>;
+		clocks = <&menetclk 0>;
+		local-mac-address = [00 01 73 00 00 01];
+		phy-connection-type = "rgmii";
+		phy-handle = <&menetphy>;
+		mdio {
+			compatible = "apm,xgene-mdio";
+			#address-cells = <1>;
+			#size-cells = <0>;
+			menetphy: menetphy@3 {
+				compatible = "ethernet-phy-id001c.c915";
+				reg = <0x3>;
+			};
+
+		};
+	};
+
+/* Board-specific peripheral configurations */
+&menet {
+        status = "ok";
+};
-- 
1.9.1
