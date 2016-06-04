From: Andrew Lunn <andrew@lunn.ch>
Subject: [PATCHv2 net-next 17/17] net: dsa: Document new binding
Date: Sat,  4 Jun 2016 21:17:09 +0200
Message-ID: <1465067829-1875-20-git-send-email-andrew@lunn.ch>
References: <1465067829-1875-1-git-send-email-andrew@lunn.ch>
Cc: netdev <netdev@vger.kernel.org>, Shawn Guo <shawnguo@kernel.org>,
	Andrew Lunn <andrew@lunn.ch>
To: David Miller <davem@davemloft.net>,
	Vivien Didelot <vivien.didelot@savoirfairelinux.com>,
	Florian Fainelli <f.fainelli@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from vps0.lunn.ch ([178.209.37.122]:59483 "EHLO vps0.lunn.ch"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750896AbcFDTS1 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sat, 4 Jun 2016 15:18:27 -0400
In-Reply-To: <1465067829-1875-1-git-send-email-andrew@lunn.ch>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Add the new binding to the documentation of the existing binding.
Mark the old binding as deprecated.

Signed-off-by: Andrew Lunn <andrew@lunn.ch>
Signed-off-by: Florian Fainelli <f.fainelli@gmail.com>
Reviewed-by: Vivien Didelot <vivien.didelot@savoirfairelinux.com>
---
 Documentation/devicetree/bindings/net/dsa/dsa.txt | 278 +++++++++++++++++++++-
 1 file changed, 276 insertions(+), 2 deletions(-)

diff --git a/Documentation/devicetree/bindings/net/dsa/dsa.txt b/Documentation/devicetree/bindings/net/dsa/dsa.txt
index 9f4807f90c31..8c9e1b80cb65 100644
--- a/Documentation/devicetree/bindings/net/dsa/dsa.txt
+++ b/Documentation/devicetree/bindings/net/dsa/dsa.txt
@@ -1,5 +1,279 @@
-Marvell Distributed Switch Architecture Device Tree Bindings
-------------------------------------------------------------
+Distributed Switch Architecture Device Tree Bindings
+----------------------------------------------------
+
+Two bindings exist, one of which has been deprecated due to
+limitations.
+
+Current Binding
+---------------
+
+Switches are true Linux devices and can be probes by any means. Once
+probed, they register to the DSA framework, passing a node
+pointer. This node is expected to fulfil the following binding, and
+may contain additional properties as required by the device it is
+embedded within.
+
+Required properties:
+
+- ports		: A container for child nodes representing switch ports.
+
+Optional properties:
+
+- dsa,member	: A two element list indicates which DSA cluster, and position
+		  within the cluster a switch takes. <0 0> is cluster 0,
+		  switch 0. <0 1> is cluster 0, switch 1. <1 0> is cluster 1,
+		  switch 0. A switch not part of any cluster (single device
+		  hanging off a CPU port) must not specify this property
+
+The ports container has the following properties
+
+Required properties:
+
+- #address-cells	: Must be 1
+- #size-cells		: Must be 0
+
+Each port children node must have the following mandatory properties:
+- reg			: Describes the port address in the switch
+- label			: Describes the label associated with this port, which
+                          will become the netdev name. Special labels are
+			  "cpu" to indicate a CPU port and "dsa" to
+			  indicate an uplink/downlink port between switches in
+			  the cluster.
+
+A port labelled "dsa" has the following mandatory property:
+
+- link			: Should be a list of phandles to other switch's DSA
+  			  port. This port is used as the outgoing port
+			  towards the phandle ports. The full routing
+			  information must be given, not just the one hop
+			  routes to neighbouring switches.
+
+A port labelled "cpu" has the following mandatory property:
+
+- ethernet		: Should be a phandle to a valid Ethernet device node.
+                          This host device is what the switch port is
+			  connected to.
+
+Port child nodes may also contain the following optional standardised
+properties, described in binding documents:
+
+- phy-handle		: Phandle to a PHY on an MDIO bus. See
+			  Documentation/devicetree/bindings/net/ethernet.txt
+			  for details.
+
+- phy-mode		: See
+			  Documentation/devicetree/bindings/net/ethernet.txt
+			  for details.
+
+- fixed-link		: Fixed-link subnode describing a link to a non-MDIO
+			  managed entity. See
+			  Documentation/devicetree/bindings/net/fixed-link.txt
+			  for details.
+
+Example
+
+The following example shows three switches on three MDIO busses,
+linked into one DSA cluster.
+
+&mdio1 {
+	#address-cells = <1>;
+	#size-cells = <0>;
+
+	switch0: switch0@0 {
+		compatible = "marvell,mv88e6085";
+		#address-cells = <1>;
+		#size-cells = <0>;
+		reg = <0>;
+
+		dsa,member = <0 0>;
+
+		ports {
+			#address-cells = <1>;
+			#size-cells = <0>;
+			port@0 {
+				reg = <0>;
+				label = "lan0";
+			};
+
+			port@1 {
+				reg = <1>;
+				label = "lan1";
+			};
+
+			port@2 {
+				reg = <2>;
+				label = "lan2";
+			};
+
+			switch0port5: port@5 {
+				reg = <5>;
+				label = "dsa";
+				phy-mode = "rgmii-txid";
+				link = <&switch1port6
+					&switch2port9>;
+				fixed-link {
+					speed = <1000>;
+					full-duplex;
+				};
+			};
+
+			port@6 {
+				reg = <6>;
+				label = "cpu";
+				ethernet = <&fec1>;
+				fixed-link {
+					speed = <100>;
+					full-duplex;
+				};
+			};
+		};
+	};
+};
+
+&mdio2 {
+	#address-cells = <1>;
+	#size-cells = <0>;
+
+	switch1: switch1@0 {
+		compatible = "marvell,mv88e6085";
+		#address-cells = <1>;
+		#size-cells = <0>;
+		reg = <0>;
+
+		dsa,member = <0 1>;
+
+		ports {
+			#address-cells = <1>;
+			#size-cells = <0>;
+			port@0 {
+				reg = <0>;
+				label = "lan3";
+				phy-handle = <&switch1phy0>;
+			};
+
+			port@1 {
+				reg = <1>;
+				label = "lan4";
+				phy-handle = <&switch1phy1>;
+			};
+
+			port@2 {
+				reg = <2>;
+				label = "lan5";
+				phy-handle = <&switch1phy2>;
+			};
+
+			switch1port5: port@5 {
+				reg = <5>;
+				label = "dsa";
+				link = <&switch2port9>;
+				phy-mode = "rgmii-txid";
+				fixed-link {
+					speed = <1000>;
+					full-duplex;
+				};
+			};
+
+			switch1port6: port@6 {
+				reg = <6>;
+				label = "dsa";
+				phy-mode = "rgmii-txid";
+				link = <&switch0port5>;
+				fixed-link {
+					speed = <1000>;
+					full-duplex;
+				};
+			};
+		};
+		mdio-bus {
+			#address-cells = <1>;
+			#size-cells = <0>;
+			switch1phy0: switch1phy0@0 {
+				reg = <0>;
+			};
+			switch1phy1: switch1phy0@1 {
+				reg = <1>;
+			};
+			switch1phy2: switch1phy0@2 {
+				reg = <2>;
+			};
+		};
+	 };
+};
+
+&mdio4 {
+	#address-cells = <1>;
+	#size-cells = <0>;
+
+	switch2: switch2@0 {
+		compatible = "marvell,mv88e6085";
+		#address-cells = <1>;
+		#size-cells = <0>;
+		reg = <0>;
+
+		dsa,member = <0 2>;
+
+		ports {
+			#address-cells = <1>;
+			#size-cells = <0>;
+			port@0 {
+				reg = <0>;
+				label = "lan6";
+			};
+
+			port@1 {
+				reg = <1>;
+				label = "lan7";
+			};
+
+			port@2 {
+				reg = <2>;
+				label = "lan8";
+			};
+
+			port@3 {
+				reg = <3>;
+				label = "optical3";
+				fixed-link {
+					speed = <1000>;
+					full-duplex;
+					link-gpios = <&gpio6 2
+					      GPIO_ACTIVE_HIGH>;
+				};
+			};
+
+			port@4 {
+				reg = <4>;
+				label = "optical4";
+				fixed-link {
+					speed = <1000>;
+					full-duplex;
+					link-gpios = <&gpio6 3
+					      GPIO_ACTIVE_HIGH>;
+				};
+			};
+
+			switch2port9: port@9 {
+				reg = <9>;
+				label = "dsa";
+				phy-mode = "rgmii-txid";
+				link = <&switch1port5
+					&switch0port5>;
+				fixed-link {
+					speed = <1000>;
+					full-duplex;
+				};
+			};
+		};
+	};
+};
+
+Deprecated Binding
+------------------
+
+The deprecated binding makes use of a platform device to represent the
+switches. The switches themselves are not Linux devices, and make use
+of an MDIO bus for management.
 
 Required properties:
 - compatible		: Should be "marvell,dsa"
-- 
2.8.1
