From: Florian Fainelli <florian@openwrt.org>
Subject: [PATCH 4/5 v2] ARM: orion5x: add gigabit ethernet device tree node
Date: Thu,  4 Apr 2013 12:27:14 +0200
Message-ID: <1365071235-11611-5-git-send-email-florian@openwrt.org>
References: <1365071235-11611-1-git-send-email-florian@openwrt.org>
Cc: netdev@vger.kernel.org, linux-arm-kernel@lists.infradead.org,
	devicetree-discuss@lists.ozlabs.org,
	thomas.petazzoni@free-electrons.com, jm@lentin.co.uk,
	moinejf@free.fr, sebastian.hesselbarth@gmail.com,
	buytenh@wantstofly.org, andrew@lunn.ch, jason@lakedaemon.net,
	grant.likely@secretlab.ca, rob.herring@calxeda.com,
	jogo@openwrt.org, Florian Fainelli <florian@openwrt.org>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from zmc.proxad.net ([212.27.53.206]:51607 "EHLO zmc.proxad.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1759079Ab3DDK1e (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 4 Apr 2013 06:27:34 -0400
In-Reply-To: <1365071235-11611-1-git-send-email-florian@openwrt.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patch adds the gigabit ethernet device tree node to orion5x.dtsi.
This node is disabled by default and must be enabled on a per-board
basis. For completeness and easier testing the MDIO node is also added
and disabled by default.

Signed-off-by: Florian Fainelli <florian@openwrt.org>
---
Changes since v1:
- fixed off-by 0x2000 address of the ethernet-group node

 arch/arm/boot/dts/orion5x.dtsi |   23 +++++++++++++++++++++++
 1 file changed, 23 insertions(+)

diff --git a/arch/arm/boot/dts/orion5x.dtsi b/arch/arm/boot/dts/orion5x.dtsi
index f7bec3b..c49503e 100644
--- a/arch/arm/boot/dts/orion5x.dtsi
+++ b/arch/arm/boot/dts/orion5x.dtsi
@@ -99,5 +99,28 @@
 			interrupts = <28>;
 			status = "okay";
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
+		ethernet-group@72000 {
+			#address-cells = <1>.
+			#size-cells = <0>;
+			compatible = "marvell,mv643xx-eth-block";
+			reg = <0x72000 0x4000>;
+			status = "disabled";
+
+			egiga0: ethernet@0 {
+				device_type = "network";
+				compatible = "marvell,mv643xx-eth";
+				reg = <0>;
+				interrupts = <21>;
+			};
+		};
 	};
 };
-- 
1.7.10.4
