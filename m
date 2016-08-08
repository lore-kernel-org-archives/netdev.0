From: Kedareswara rao Appana <appana.durga.rao@xilinx.com>
Subject: [RFC PATCH v4 1/2] Documentation: DT: net: Add Xilinx gmiitorgmii converter device tree binding documentation
Date: Mon, 8 Aug 2016 12:45:04 +0530
Message-ID: <1470640505-8279-1-git-send-email-appanad@xilinx.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <devicetree@vger.kernel.org>,
	<linux-arm-kernel@lists.infradead.org>,
	<linux-kernel@vger.kernel.org>, <netdev@vger.kernel.org>
To: <robh+dt@kernel.org>, <mark.rutland@arm.com>,
	<michal.simek@xilinx.com>, <soren.brinkmann@xilinx.com>,
	<appanad@xilinx.com>, <f.fainelli@gmail.com>, <andrew@lunn.ch>,
	<punnaia@xilinx.com>, <anirudh@xilinx.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Device-tree binding documentation for xilinx gmiitorgmii converter.

Signed-off-by: Kedareswara rao Appana <appanad@xilinx.com>
---
Changes for v4:
--> Modified compatible as suggested by Rob.
--> Removed underscores from the converter node name as suggested by Rob.
Changes for v3:
--> None.
Changes for v2:
--> New patch.

 .../devicetree/bindings/net/xilinx_gmii2rgmii.txt  | 38 ++++++++++++++++++++++
 1 file changed, 38 insertions(+)
 create mode 100644 Documentation/devicetree/bindings/net/xilinx_gmii2rgmii.txt

diff --git a/Documentation/devicetree/bindings/net/xilinx_gmii2rgmii.txt b/Documentation/devicetree/bindings/net/xilinx_gmii2rgmii.txt
new file mode 100644
index 0000000..453680d
--- /dev/null
+++ b/Documentation/devicetree/bindings/net/xilinx_gmii2rgmii.txt
@@ -0,0 +1,38 @@
+XILINX GMIITORGMII Converter Driver Device Tree Bindings
+--------------------------------------------------------
+
+The Gigabit Media Independent Interface (GMII) to Reduced Gigabit Media
+Independent Interface (RGMII) core provides the RGMII between RGMII-compliant
+Ethernet physical media devices (PHY) and the Gigabit Ethernet controller.
+This core can be used in all three modes of operation(10/100/1000 Mb/s).
+The Management Data Input/Output (MDIO) interface is used to configure the
+Speed of operation. This core can switch dynamically between the three
+Different speed modes by configuring the conveter register through mdio write.
+
+The MDIO is a bus to which the PHY devices are connected.  For each
+device that exists on this bus, a child node should be created.  See
+the definition of the PHY node in booting-without-of.txt for an example
+of how to define a PHY.
+
+This converter sits between the MAC and the external phy.
+MAC <==> GMII2RGMII <==> RGMII_PHY
+
+Required properties:
+  - compatible : Should be "xlnx,gmii-to-rgmii-1.0"
+  - reg : The ID number for the phy, usually a small integer
+  - phy-handle: Should point to the external phy device.
+		See ethernet.txt file in the same directory.
+
+Example:
+	mdio {
+                #address-cells = <1>;
+                #size-cells = <0>;
+		phy: ethernet-phy@0 {
+			......
+		};
+                gmiitorgmii: gmiitorgmii@8 {
+                        compatible = "xlnx,gmii-to-rgmii-1.0";
+                        reg = <8>;
+			phy-handle = <&phy>;
+                };
+        };
-- 
2.1.2
