From: Florian Fainelli <florian@openwrt.org>
Subject: [PATCH 4/4] ARM: dove: add gigabit device tree nodes to dove.dtsi
Date: Fri, 29 Mar 2013 19:14:39 +0100
Message-ID: <1364580879-4297-5-git-send-email-florian@openwrt.org>
References: <1364580879-4297-1-git-send-email-florian@openwrt.org>
Cc: netdev@vger.kernel.org, linux-arm-kernel@lists.infradead.org,
	devicetree-discuss@lists.ozlabs.org,
	thomas.petazzoni@free-electrons.com, jm@lentin.co.uk,
	moinejf@free.fr, sebastian.hesselbarth@gmail.com,
	buytenh@wantstofly.org, andrew@lunn.ch, jason@lakedaemon.net,
	grant.likely@secretlab.ca, rob.herring@calxeda.com,
	Florian Fainelli <florian@openwrt.org>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from zmc.proxad.net ([212.27.53.206]:34604 "EHLO zmc.proxad.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756268Ab3C2SOy (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 29 Mar 2013 14:14:54 -0400
In-Reply-To: <1364580879-4297-1-git-send-email-florian@openwrt.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patch adds the gigabit ethernet device tree nodes to dove.dtsi in a
disabled state. The gigabit ethernet device tree node must be enabled on
a per-board basis. For completeness and easier testing the MDIO node is
also added in a disabled state.

Signed-off-by: Florian Fainelli <florian@openwrt.org>
---
 arch/arm/boot/dts/dove.dtsi |   25 +++++++++++++++++++++++++
 1 file changed, 25 insertions(+)

diff --git a/arch/arm/boot/dts/dove.dtsi b/arch/arm/boot/dts/dove.dtsi
index f7509ca..8a24d6b 100644
--- a/arch/arm/boot/dts/dove.dtsi
+++ b/arch/arm/boot/dts/dove.dtsi
@@ -253,5 +253,30 @@
 				dmacap,xor;
 			};
 		};
+
+		mdio@72004 {
+			#address-cells = <1>;
+			#size-cells = <0>;
+			compatible = "marvell,orion-mdio";
+			reg = <0x72004 0x84>;
+			status = "disabled";
+		};
+
+		ethernet-group@70000 {
+			#address-cells = <1>;
+			#size-cells = <0>;
+			compatible = "marvell,mv643xx-eth-block";
+			reg = <0x70000 0x4000>;
+			tx-csum-limit = <1600>;
+			status = "disabled";
+
+			egiga0: ethernet@0 {
+				device_type = "network";
+				compatible = "marvell,mv643xx-eth";
+				reg = <0>;
+				interrupts = <29>;
+				clocks = <&gate_clk 2>;
+			};
+		};
 	};
 };
-- 
1.7.10.4
