From: Florian Fainelli <florian@openwrt.org>
Subject: [PATCH 3/5 v2] ARM: kirkwood: add device node entries for the gigabit interfaces
Date: Thu,  4 Apr 2013 12:27:13 +0200
Message-ID: <1365071235-11611-4-git-send-email-florian@openwrt.org>
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
Received: from zmc.proxad.net ([212.27.53.206]:51601 "EHLO zmc.proxad.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1759071Ab3DDK1e (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 4 Apr 2013 06:27:34 -0400
In-Reply-To: <1365071235-11611-1-git-send-email-florian@openwrt.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patch modifies kirkwood.dtsi to specify the various gigabit
interfaces nodes available on kirkwood devices. They are disabled by
default and should be enabled on a per-board basis. egiga0 and egiga1
aliases are defined for convenience. The mdio node is also present and
should be enabled on a per-board basis as well.

Signed-off-by: Florian Fainelli <florian@openwrt.org>
---
Changes since v1:
- dropped change to arch/arm/mach-kirkwood/common.c to avoid merge conflicts
- fixed off-by 0x2000 ethernet-group nodes address

 arch/arm/boot/dts/kirkwood.dtsi |   46 +++++++++++++++++++++++++++++++++++++++
 1 file changed, 46 insertions(+)

diff --git a/arch/arm/boot/dts/kirkwood.dtsi b/arch/arm/boot/dts/kirkwood.dtsi
index fada7e6..254f5a8 100644
--- a/arch/arm/boot/dts/kirkwood.dtsi
+++ b/arch/arm/boot/dts/kirkwood.dtsi
@@ -7,6 +7,8 @@
 	aliases {
 	       gpio0 = &gpio0;
 	       gpio1 = &gpio1;
+	       egiga0 = &egiga0;
+	       egiga1 = &egiga1;
 	};
 	intc: interrupt-controller {
 		compatible = "marvell,orion-intc", "marvell,intc";
@@ -202,5 +204,49 @@
 			clocks = <&gate_clk 4>;
 			status = "disabled";
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
+			#address-cells = <1>;
+			#size-cells = <0>;
+			compatible = "marvell,mv643xx-eth-block";
+			reg = <0x72000 0x4000>;
+			tx-csum-limit = <1600>;
+			status = "disabled";
+
+			egiga0: egiga0@0 {
+				device_type = "network";
+				compatible = "marvell,mv643xx-eth";
+				reg = <0>;
+				interrupts = <11>;
+				clocks = <&gate_clk 0>;
+				clock-names = "0";
+			};
+		};
+
+		ethernet-group@76000 {
+			#address-cells = <1>;
+			#size-cells = <0>;
+			compatible = "marvell,mv643xx-eth-block";
+			reg = <0x76000 0x4000>;
+			tx-csum-limit = <1600>;
+			status = "disabled";
+
+			egiga1: egiga1@0 {
+				device_type = "network";
+				compatible = "marvell,mv643xx-eth";
+				reg = <0>;
+				interrupts = <15>;
+				clocks = <&gate_clk 19>;
+				clock-names = "1";
+			};
+		};
 	};
 };
-- 
1.7.10.4
