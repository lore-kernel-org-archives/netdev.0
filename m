From: Antoine Tenart <antoine.tenart@free-electrons.com>
Subject: [PATCH net-next 03/13] Documentation/bindings: phy: document the Marvell comphy driver
Date: Thu, 24 Aug 2017 10:38:13 +0200
Message-ID: <20170824083823.16826-4-antoine.tenart@free-electrons.com>
References: <20170824083823.16826-1-antoine.tenart@free-electrons.com>
Cc: Antoine Tenart <antoine.tenart@free-electrons.com>,
        thomas.petazzoni@free-electrons.com, nadavh@marvell.com,
        linux@armlinux.org.uk, linux-kernel@vger.kernel.org,
        mw@semihalf.com, stefanc@marvell.com,
        miquel.raynal@free-electrons.com, netdev@vger.kernel.org
To: davem@davemloft.net, kishon@ti.com, andrew@lunn.ch,
        jason@lakedaemon.net, sebastian.hesselbarth@gmail.com,
        gregory.clement@free-electrons.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20170824083823.16826-1-antoine.tenart@free-electrons.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

The Marvell Armada 7K/8K SoCs contains an hardware block called COMPHY
that provides a number of shared PHYs used by various interfaces in the
SoC: network, SATA, PCIe, etc. This Device Tree binding allows to
describe this COMPHY hardware block.

Signed-off-by: Antoine Tenart <antoine.tenart@free-electrons.com>
---
 .../devicetree/bindings/phy/phy-mvebu-comphy.txt   | 42 ++++++++++++++++++++++
 1 file changed, 42 insertions(+)
 create mode 100644 Documentation/devicetree/bindings/phy/phy-mvebu-comphy.txt

diff --git a/Documentation/devicetree/bindings/phy/phy-mvebu-comphy.txt b/Documentation/devicetree/bindings/phy/phy-mvebu-comphy.txt
new file mode 100644
index 000000000000..dc3726269e1d
--- /dev/null
+++ b/Documentation/devicetree/bindings/phy/phy-mvebu-comphy.txt
@@ -0,0 +1,42 @@
+mvebu comphy driver
+-------------------
+
+A comphy controller can be found on Marvell Armada 7k/8k on the CP110. It
+provides a number of shared PHYs used by various interfaces (network, sata,
+usb, PCIe...).
+
+Required properties:
+
+- compatible: should be "marvell,comphy-cp110"
+- reg: should contain the comphy register location and length.
+- marvell,system-controller: should contain a phandle to the
+                             system controller node.
+- #address-cells: should be 1.
+- #size-cells: should be 0.
+
+A sub-node is required for each comphy lane provided by the comphy.
+
+Required properties (child nodes):
+
+- reg: comphy lane number.
+- #phy-cells : from the generic phy bindings, must be 1.
+
+Example:
+
+	cpm_comphy: phy@120000 {
+		compatible = "marvell,comphy-cp110";
+		reg = <0x120000 0x6000>;
+		marvell,system-controller = <&cpm_syscon0>;
+		#address-cells = <1>;
+		#size-cells = <0>;
+
+		cpm_comphy0: phy@0 {
+			reg = <0>;
+			#phy-cells = <1>;
+		};
+
+		cpm_comphy1: phy@1 {
+			reg = <1>;
+			#phy-cells = <1>;
+		};
+	};
-- 
2.13.5
