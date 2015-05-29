From: Mathieu Olivari <mathieu@codeaurora.org>
Subject: [PATCH 7/7] Documentation: devicetree: add ar8xxx binding
Date: Thu, 28 May 2015 18:42:22 -0700
Message-ID: <1432863742-18427-8-git-send-email-mathieu@codeaurora.org>
References: <1432863742-18427-1-git-send-email-mathieu@codeaurora.org>
Cc: devicetree@vger.kernel.org, linux-kernel@vger.kernel.org,
	netdev@vger.kernel.org
To: robh+dt@kernel.org, pawel.moll@arm.com, mark.rutland@arm.com,
	ijc+devicetree@hellion.org.uk, galak@codeaurora.org,
	davem@davemloft.net, mathieu@codeaurora.org, andrew@lunn.ch,
	f.fainelli@gmail.com, linux@roeck-us.net, gang.chen.5i5j@gmail.com,
	jiri@resnulli.us, leitec@staticky.com, fabf@skynet.be,
	alexander.h.duyck@intel.com, pavel.nakonechny@skitlab.ru,
	joe@perches.com, sfeldma@gmail.com, nbd@openwrt.org,
	juhosg@openwrt.org
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1432863742-18427-1-git-send-email-mathieu@codeaurora.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Add device-tree binding for ar8xxx switch families.

Signed-off-by: Mathieu Olivari <mathieu@codeaurora.org>
---
 .../devicetree/bindings/net/dsa/qca-ar8xxx.txt     | 70 ++++++++++++++++++++++
 1 file changed, 70 insertions(+)
 create mode 100644 Documentation/devicetree/bindings/net/dsa/qca-ar8xxx.txt

diff --git a/Documentation/devicetree/bindings/net/dsa/qca-ar8xxx.txt b/Documentation/devicetree/bindings/net/dsa/qca-ar8xxx.txt
new file mode 100644
index 0000000..f4fd3f1
--- /dev/null
+++ b/Documentation/devicetree/bindings/net/dsa/qca-ar8xxx.txt
@@ -0,0 +1,70 @@
+* Qualcomm Atheros AR8xxx switch family
+
+Required properties:
+
+- compatible: should be "qca,ar8xxx"
+- dsa,mii-bus: phandle to the MDIO bus controller, see dsa/dsa.txt
+- dsa,ethernet: phandle to the CPU network interface controller, see dsa/dsa.txt
+- #size-cells: must be 0
+- #address-cells: must be 2, see dsa/dsa.txt
+
+Subnodes:
+
+The integrated switch subnode should be specified according to the binding
+described in dsa/dsa.txt.
+
+Optional properties:
+
+- qca,port6-phy-mode: if specified, the driver will configure Port 6 in the
+  given phy-mode. See Documentation/devicetree/bindings/net/ethernet.txt for
+  the list of valid phy-mode.
+
+- qca,port6-phy-id: if specified, the driver will connect Port 6 to the PHY
+  given as a parameter. In this case, Port6 and the corresponding PHY will be
+  isolated from the rest of the switch. From a system perspective, they will
+  act as a regular PHY.
+
+Example:
+
+	dsa@0 {
+		compatible = "qca,ar8xxx";
+		#address-cells = <2>;
+		#size-cells = <0>;
+
+		dsa,ethernet = <&ethernet0>;
+		dsa,mii-bus = <&mii_bus0>;
+
+		switch@0 {
+			#address-cells = <1>;
+			#size-cells = <0>;
+			reg = <0 0>;	/* MDIO address 0, switch 0 in tree */
+
+			qca,port6-phy-mode = "sgmii";
+			qca,port6-phy-id = <4>;
+
+			port@0 {
+				reg = <11>;
+				label = "cpu";
+			};
+
+			port@1 {
+				reg = <0>;
+				label = "lan1";
+			};
+
+			port@2 {
+				reg = <1>;
+				label = "lan2";
+			};
+
+			port@3 {
+				reg = <2>;
+				label = "lan3";
+			};
+
+			port@4 {
+				reg = <3>;
+				label = "lan4";
+			};
+		};
+	};
-- 
2.1.4
