From: Andrew Lunn <andrew@lunn.ch>
Subject: [PATCH RFC 3/3] kirkwood: dir665: Enable the second Ethernet to the Switch
Date: Fri, 29 May 2015 21:13:34 +0200
Message-ID: <1432926814-22648-4-git-send-email-andrew@lunn.ch>
References: <1432926814-22648-1-git-send-email-andrew@lunn.ch>
Cc: Florian Fainelli <f.fainelli@gmail.com>,
	Guenter Roeck <linux@roeck-us.net>, mathieu@codeaurora.org,
	Andrew Lunn <andrew@lunn.ch>
To: netdev <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from vps0.lunn.ch ([178.209.37.122]:48117 "EHLO vps0.lunn.ch"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756578AbbE2TS6 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 29 May 2015 15:18:58 -0400
In-Reply-To: <1432926814-22648-1-git-send-email-andrew@lunn.ch>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The Dlink DIR665 has two host Ethernet interfaces connected to the
switch. Now that the DSA core and mv88e6171 driver supports multiple
CPU ports, enable the second interface.

Signed-off-by: Andrew Lunn <andrew@lunn.ch>
---
 arch/arm/boot/dts/kirkwood-dir665.dts | 22 ++++++++++++++++++++--
 1 file changed, 20 insertions(+), 2 deletions(-)

diff --git a/arch/arm/boot/dts/kirkwood-dir665.dts b/arch/arm/boot/dts/kirkwood-dir665.dts
index 786959ee9cbe..2ecb6acb1905 100644
--- a/arch/arm/boot/dts/kirkwood-dir665.dts
+++ b/arch/arm/boot/dts/kirkwood-dir665.dts
@@ -219,31 +219,43 @@
 			port@0 {
 				reg = <0>;
 				label = "lan4";
+				cpu = <&cpu1>;
 			};
 
 			port@1 {
 			       reg = <1>;
 			       label = "lan3";
+			       cpu = <&cpu0>;
 			};
 
 			port@2 {
 			       reg = <2>;
 			       label = "lan2";
+			       cpu = <&cpu1>;
 			};
 
 			port@3 {
 			       reg = <3>;
 			       label = "lan1";
+			       cpu = <&cpu0>;
 			};
 
 			port@4 {
 				reg = <4>;
 				label = "wan";
+				cpu = <&cpu1>;
 			};
 
-			port@6 {
+			cpu0: port@5 {
+			       reg = <5>;
+			       label = "cpu";
+			       ethernet = <&eth1port>;
+			};
+
+			cpu1: port@6 {
 			       reg = <6>;
 			       label = "cpu";
+			       ethernet = <&eth0port>;
 			};
 		};
 	};
@@ -268,7 +280,13 @@
  * single CPU port. So leave this port disabled to avoid confusion. */
 
 &eth1 {
-	status = "disabled";
+	status = "okay";
+
+	ethernet1-port@0 {
+		speed = <1000>;
+		duplex = <1>;
+		local-mac-address = [c8 be 19 61 de 55];
+	};
 };
 
 /* There is no battery on the boards, so the RTC does not keep time
-- 
2.1.4
