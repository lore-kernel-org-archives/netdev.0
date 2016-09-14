From: John Crispin <john@phrozen.org>
Subject: [PATCH V2 1/3] Documentation: devicetree: add qca8k binding
Date: Wed, 14 Sep 2016 12:39:00 +0200
Message-ID: <1473849542-3298-2-git-send-email-john@phrozen.org>
References: <1473849542-3298-1-git-send-email-john@phrozen.org>
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
        qsdk-review@qca.qualcomm.com, John Crispin <john@phrozen.org>,
        devicetree@vger.kernel.org
To: "David S. Miller" <davem@davemloft.net>,
        Andrew Lunn <andrew@lunn.ch>,
        Florian Fainelli <f.fainelli@gmail.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1473849542-3298-1-git-send-email-john@phrozen.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Add device-tree binding for ar8xxx switch families.

Cc: devicetree@vger.kernel.org
Signed-off-by: John Crispin <john@phrozen.org>
---
Changes in V2
* fixup ecample to include phy nodes and corresponding phandles
* add a note explaining why we need to phy nodes

 .../devicetree/bindings/net/dsa/qca8k.txt          |   88 ++++++++++++++++++++
 1 file changed, 88 insertions(+)
 create mode 100644 Documentation/devicetree/bindings/net/dsa/qca8k.txt

diff --git a/Documentation/devicetree/bindings/net/dsa/qca8k.txt b/Documentation/devicetree/bindings/net/dsa/qca8k.txt
new file mode 100644
index 0000000..2c1582a
--- /dev/null
+++ b/Documentation/devicetree/bindings/net/dsa/qca8k.txt
@@ -0,0 +1,88 @@
+* Qualcomm Atheros QCA8xxx switch family
+
+Required properties:
+
+- compatible: should be "qca,qca8337"
+- #size-cells: must be 0
+- #address-cells: must be 1
+
+Subnodes:
+
+The integrated switch subnode should be specified according to the binding
+described in dsa/dsa.txt. As the QCA8K switches do not have a N:N mapping of
+port and PHY id, each subnode describing a port needs to have a valid phandle
+referencing the internal PHY connected to it.
+
+Example:
+
+
+	&mdio0 {
+		phy_port1: phy@0 {
+			reg = <0>;
+		};
+
+		phy_port2: phy@1 {
+			reg = <1>;
+		};
+
+		phy_port3: phy@2 {
+			reg = <2>;
+		};
+
+		phy_port4: phy@3 {
+			reg = <3>;
+		};
+
+		phy_port5: phy@4 {
+			reg = <4>;
+		};
+
+		switch0@0 {
+			compatible = "qca,qca8337";
+			#address-cells = <1>;
+			#size-cells = <0>;
+
+			reg = <0>;
+
+			ports {
+				#address-cells = <1>;
+				#size-cells = <0>;
+				port@0 {
+					reg = <0>;
+					label = "cpu";
+					ethernet = <&gmac1>;
+					phy-mode = "rgmii";
+				};
+
+				port@1 {
+					reg = <1>;
+					label = "lan1";
+					phy-handle = <&phy_port1>;
+				};
+
+				port@2 {
+					reg = <2>;
+					label = "lan2";
+					phy-handle = <&phy_port2>;
+				};
+
+				port@3 {
+					reg = <3>;
+					label = "lan3";
+					phy-handle = <&phy_port3>;
+				};
+
+				port@4 {
+					reg = <4>;
+					label = "lan4";
+					phy-handle = <&phy_port4>;
+				};
+
+				port@5 {
+					reg = <5>;
+					label = "wan";
+					phy-handle = <&phy_port5>;
+				};
+			};
+		};
+	};
-- 
1.7.10.4
