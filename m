From: Iyappan Subramanian <isubramanian@apm.com>
Subject: [PATCH v5 2/4] Documentation: dts: Add bindings for APM X-Gene SoC
 ethernet driver
Date: Mon,  2 Jun 2014 12:39:12 -0700
Message-ID: <1401737954-26152-3-git-send-email-isubramanian@apm.com>
References: <1401737954-26152-1-git-send-email-isubramanian@apm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: jcm@redhat.com, gregkh@linuxfoundation.org, patches@apm.com,
 linux-kernel@vger.kernel.org, Iyappan Subramanian <isubramanian@apm.com>,
 Keyur Chudgar <kchudgar@apm.com>, linux-arm-kernel@lists.infradead.org,
 Ravi Patel <rapatel@apm.com>
To: davem@davemloft.net,
	netdev@vger.kernel.org,
	devicetree@vger.kernel.org
Return-path: <linux-arm-kernel-bounces+linux-arm-kernel=m.gmane.org@lists.infradead.org>
In-Reply-To: <1401737954-26152-1-git-send-email-isubramanian@apm.com>
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

This patch adds documentation for APM X-Gene SoC ethernet DTS binding.

Signed-off-by: Iyappan Subramanian <isubramanian@apm.com>
Signed-off-by: Ravi Patel <rapatel@apm.com>
Signed-off-by: Keyur Chudgar <kchudgar@apm.com>
---
 .../devicetree/bindings/net/apm-xgene-enet.txt     |   72 ++++++++++++++++++++
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
1.7.9.5
