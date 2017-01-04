From: John Crispin <john@phrozen.org>
Subject: [RFC 1/4] Documentation: devicetree: add multiple cpu port DSA binding
Date: Wed,  4 Jan 2017 08:38:01 +0100
Message-ID: <1483515484-21793-2-git-send-email-john@phrozen.org>
References: <1483515484-21793-1-git-send-email-john@phrozen.org>
Cc: netdev@vger.kernel.org, Rob Herring <robh+dt@kernel.org>,
        devicetree@vger.kernel.org
To: Andrew Lunn <andrew@lunn.ch>,
        "David S. Miller" <davem@davemloft.net>,
        Florian Fainelli <f.fainelli@gmail.com>,
        Vivien Didelot <vivien.didelot@savoirfairelinux.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from nbd.name ([46.4.11.11]:60157 "EHLO nbd.name"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S934929AbdADHiS (ORCPT <rfc822;netdev@vger.kernel.org>);
        Wed, 4 Jan 2017 02:38:18 -0500
In-Reply-To: <1483515484-21793-1-git-send-email-john@phrozen.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Andrew Lunn <andrew@lunn.ch>

Extend the DSA binding documentation, adding the new properties required
when there is more than one CPU port attached to the switch.

Cc: Rob Herring <robh+dt@kernel.org>
Cc: devicetree@vger.kernel.org
Signed-off-by: Andrew Lunn <andrew@lunn.ch>
---
 Documentation/devicetree/bindings/net/dsa/dsa.txt |   67 ++++++++++++++++++++-
 1 file changed, 66 insertions(+), 1 deletion(-)

diff --git a/Documentation/devicetree/bindings/net/dsa/dsa.txt b/Documentation/devicetree/bindings/net/dsa/dsa.txt
index a4a570f..fc901cf 100644
--- a/Documentation/devicetree/bindings/net/dsa/dsa.txt
+++ b/Documentation/devicetree/bindings/net/dsa/dsa.txt
@@ -337,13 +337,25 @@ Optional property:
 			  This mii-bus will be used in preference to the
 			  global dsa,mii-bus defined above, for this switch.
 
+- ethernet		: Optional for "cpu" ports. A phandle to an ethernet
+                          device which will be used by this CPU port for
+			  passing packets to/from the host. If not present,
+			  the port will use the "dsa,ethernet" property
+			  defined above.
+
+- cpu			: Option for non "cpu"/"dsa" ports. A phandle to a
+			  "cpu" port, which will be used for passing packets
+			  from this port to the host. If not present, the first
+			  "cpu" port will be used.
+
+
 Optional subnodes:
 - fixed-link		: Fixed-link subnode describing a link to a non-MDIO
 			  managed entity. See
 			  Documentation/devicetree/bindings/net/fixed-link.txt
 			  for details.
 
-Example:
+Examples:
 
 	dsa@0 {
 		compatible = "marvell,dsa";
@@ -416,3 +428,56 @@ Example:
 			};
 		};
 	};
+
+	dsa@1 {
+		compatible = "marvell,dsa";
+		#address-cells = <2>;
+		#size-cells = <0>;
+
+		dsa,ethernet = <&eth0port>;
+		dsa,mii-bus = <&mdio>;
+
+		switch@0 {
+			#address-cells = <1>;
+			#size-cells = <0>;
+			reg = <0 0>;	/* MDIO address 0, switch 0 in tree */
+
+			port@0 {
+				reg = <0>;
+				label = "lan4";
+			};
+
+			port@1 {
+				reg = <1>;
+				label = "lan3";
+				cpu = <&cpu1>;
+			};
+
+			port@2 {
+				reg = <2>;
+				label = "lan2";
+			};
+
+			port@3 {
+				reg = <3>;
+				label = "lan1";
+				cpu = <&cpu1>;
+			};
+
+			port@4 {
+				reg = <4>;
+				label = "wan";
+			};
+
+			port@5 {
+				reg = <5>;
+				label = "cpu";
+			};
+
+			cpu1: port@6 {
+				reg = <6>;
+				label = "cpu";
+				ethernet = <&eth1port>;
+			};
+		};
+	};
-- 
1.7.10.4
