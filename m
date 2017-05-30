From: John Crispin <john@phrozen.org>
Subject: [PATCH V2 1/3] Documentation: devicetree: add multiple cpu port DSA binding
Date: Tue, 30 May 2017 12:44:17 +0200
Message-ID: <20170530104419.6052-1-john@phrozen.org>
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
        John Crispin <john@phrozen.org>,
        Rob Herring <robh+dt@kernel.org>, devicetree@vger.kernel.org
To: Andrew Lunn <andrew@lunn.ch>,
        Vivien Didelot <vivien.didelot@savoirfairelinux.com>,
        Florian Fainelli <f.fainelli@gmail.com>,
        "David S . Miller" <davem@davemloft.net>,
        Sean Wang <sean.wang@mediatek.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Extend the DSA binding documentation, adding the new property required
when there is more than one CPU port attached to the switch.

Cc: Rob Herring <robh+dt@kernel.org>
Cc: devicetree@vger.kernel.org
Signed-off-by: John Crispin <john@phrozen.org>
---
 Documentation/devicetree/bindings/net/dsa/dsa.txt | 61 ++++++++++++++++++++++-
 1 file changed, 60 insertions(+), 1 deletion(-)

diff --git a/Documentation/devicetree/bindings/net/dsa/dsa.txt b/Documentation/devicetree/bindings/net/dsa/dsa.txt
index cfe8f64eca4f..c164eb38ccc5 100644
--- a/Documentation/devicetree/bindings/net/dsa/dsa.txt
+++ b/Documentation/devicetree/bindings/net/dsa/dsa.txt
@@ -55,6 +55,11 @@ A user port has the following optional property:
 - label			: Describes the label associated with this port, which
                           will become the netdev name.
 
+- cpu			: Option for non "cpu"/"dsa" ports. A phandle to a
+			  "cpu" port, which will be used for passing packets
+			  from this port to the host. If not present, the first
+			  "cpu" port will be used.
+
 Port child nodes may also contain the following optional standardised
 properties, described in binding documents:
 
@@ -71,7 +76,7 @@ properties, described in binding documents:
 			  Documentation/devicetree/bindings/net/fixed-link.txt
 			  for details.
 
-Example
+Examples
 
 The following example shows three switches on three MDIO busses,
 linked into one DSA cluster.
@@ -264,6 +269,60 @@ linked into one DSA cluster.
 	};
 };
 
+The following example shows a switch that has two cpu ports each connecting
+to a different MAC.
+
+&mdio0 {
+	switch@0 {
+		compatible = "mediatek,mt7530";
+		#address-cells = <1>;
+		#size-cells = <0>;
+		reg = <0>;
+
+		ports {
+			#address-cells = <1>;
+			#size-cells = <0>;
+			port@0 {
+				reg = <0>;
+				label = "lan0";
+				cpu = <&cpu_port1>;
+			};
+
+			port@1 {
+				reg = <1>;
+				label = "lan1";
+				cpu = <&cpu_port1>;
+			};
+
+			port@2 {
+				reg = <2>;
+				label = "lan2";
+				cpu = <&cpu_port1>;
+			};
+
+			port@3 {
+				reg = <3>;
+				label = "wan";
+				cpu = <&cpu_port2>;
+			};
+
+			cpu_port2: port@5 {
+				reg = <5>;
+				label = "cpu";
+				ethernet = <&gmac2>;
+				phy-mode = "trgmii";
+			};
+
+			cpu_port1: port@6 {
+				reg = <6>;
+				label = "cpu";
+				ethernet = <&gmac1>;
+				phy-mode = "trgmii";
+			};
+		};
+	};
+};
+
 Deprecated Binding
 ------------------
 
-- 
2.11.0
