From: Iyappan Subramanian <isubramanian@apm.com>
Subject: [PATCH v3 2/4] Documentation: dts: Add bindings for APM X-Gene SoC ethernet driver
Date: Wed, 16 Apr 2014 19:39:26 -0700
Message-ID: <1397702368-4846-3-git-send-email-isubramanian@apm.com>
References: <1397702368-4846-1-git-send-email-isubramanian@apm.com>
Cc: gregkh@linuxfoundation.org, linux-kernel@vger.kernel.org,
	linux-arm-kernel@lists.infradead.org, jcm@redhat.com,
	patches@apm.com, Iyappan Subramanian <isubramanian@apm.com>,
	Ravi Patel <rapatel@apm.com>, Keyur Chudgar <kchudgar@apm.com>
To: davem@davemloft.net, netdev@vger.kernel.org,
	devicetree@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1397702368-4846-1-git-send-email-isubramanian@apm.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This patch adds documentation for APM X-Gene SoC ethernet DTS binding.

Signed-off-by: Iyappan Subramanian <isubramanian@apm.com>
Signed-off-by: Ravi Patel <rapatel@apm.com>
Signed-off-by: Keyur Chudgar <kchudgar@apm.com>
---
 .../devicetree/bindings/net/apm-xgene-enet.txt     |   66 ++++++++++++++++++++
 1 file changed, 66 insertions(+)
 create mode 100644 Documentation/devicetree/bindings/net/apm-xgene-enet.txt

diff --git a/Documentation/devicetree/bindings/net/apm-xgene-enet.txt b/Documentation/devicetree/bindings/net/apm-xgene-enet.txt
new file mode 100644
index 0000000..9ad6fe1
--- /dev/null
+++ b/Documentation/devicetree/bindings/net/apm-xgene-enet.txt
@@ -0,0 +1,66 @@
+APM X-Gene SoC Ethernet nodes
+
+Ethernet nodes are defined to describe on-chip ethernet interfaces in
+APM X-Gene SoC.
+
+Required properties:
+- compatible:		Should be "apm,xgene-enet"
+- reg:			First resource is the ethernet base register set
+			Second resource is the ring base register set
+			Third resource is the ring command register set
+- interrupts:		Ethernet main interrupt
+- clocks:		Reference to the clock entry.
+- local-mac-address:	Ethernet MAC address.
+- phy-connection-type:	Ethernet MII mode.
+
+- mdio device tree subnode: When the X-Gene SoC has a phy connected to its local
+		mdio, there must be device tree subnode with the following
+		required properties:
+
+	- compatible: Must be "apm,xgene-mdio".
+	- #address-cells: Must be <1>.
+	- #size-cells: Must be <0>.
+
+	For the phy on the mdio bus, there must be a node with the following
+	fields:
+
+	- reg: phy id used to communicate to phy.
+
+Optional properties:
+- status		: Should be "ok" or "disabled" for enabled/disabled.
+			  Default is "ok".
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
+				reg = <0x3>;
+			};
+
+		};
+	};
+
+/* Board-specific peripheral configurations */
+
+&menet {
+        status = "ok";
+};
-- 
1.7.9.5
