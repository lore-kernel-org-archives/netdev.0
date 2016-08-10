From: Kedareswara rao Appana <appana.durga.rao@xilinx.com>
Subject: [PATCH v6 2/3] Documentation: DT: net: Add Xilinx gmiitorgmii
 converter device tree binding documentation
Date: Wed, 10 Aug 2016 11:20:07 +0530
Message-ID: <1470808208-32133-3-git-send-email-appanad@xilinx.com>
References: <1470808208-32133-1-git-send-email-appanad@xilinx.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: devicetree@vger.kernel.org, linux-kernel@vger.kernel.org,
 linux-arm-kernel@lists.infradead.org, netdev@vger.kernel.org
To: <robh+dt@kernel.org>, <mark.rutland@arm.com>, <michal.simek@xilinx.com>,
 <soren.brinkmann@xilinx.com>, <appanad@xilinx.com>, <f.fainelli@gmail.com>,
 <andrew@lunn.ch>, <punnaia@xilinx.com>
Return-path: <linux-arm-kernel-bounces+linux-arm-kernel=m.gmane.org@lists.infradead.org>
In-Reply-To: <1470808208-32133-1-git-send-email-appanad@xilinx.com>
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

Device-tree binding documentation for xilinx gmiitorgmii converter.

Signed-off-by: Kedareswara rao Appana <appanad@xilinx.com>
---
Changes for v6:
---> Removed mdio description as suggested by Florian.
Changes for v5:
---> Fixed Indentation in the example as suggested by Michal.
Changes for v4:
--> Modified compatible as suggested by Rob.
--> Removed underscores from the converter node name as suggested by Rob.
Changes for v3:
--> None.
Changes for v2:
--> New patch

 .../devicetree/bindings/net/xilinx_gmii2rgmii.txt  | 35 ++++++++++++++++++++++
 1 file changed, 35 insertions(+)
 create mode 100644 Documentation/devicetree/bindings/net/xilinx_gmii2rgmii.txt

diff --git a/Documentation/devicetree/bindings/net/xilinx_gmii2rgmii.txt b/Documentation/devicetree/bindings/net/xilinx_gmii2rgmii.txt
new file mode 100644
index 0000000..038dda4
--- /dev/null
+++ b/Documentation/devicetree/bindings/net/xilinx_gmii2rgmii.txt
@@ -0,0 +1,35 @@
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
+This converter sits between the ethernet MAC and the external phy.
+MAC <==> GMII2RGMII <==> RGMII_PHY
+
+For more details about mdio please refer phy.txt file in the same directory.
+
+Required properties:
+- compatible	: Should be "xlnx,gmii-to-rgmii-1.0"
+- reg		: The ID number for the phy, usually a small integer
+- phy-handle	: Should point to the external phy device.
+		  See ethernet.txt file in the same directory.
+
+Example:
+	mdio {
+		#address-cells = <1>;
+		#size-cells = <0>;
+		phy: ethernet-phy@0 {
+			......
+		};
+		gmiitorgmii: gmiitorgmii@8 {
+			compatible = "xlnx,gmii-to-rgmii-1.0";
+			reg = <8>;
+			phy-handle = <&phy>;
+		};
+	};
-- 
2.1.2
