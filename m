From: Haiying Wang <Haiying.Wang@freescale.com>
Subject: [PATCH 4/4] MPC85xx: Add UCC6 and UCC8 nodes in SGMII mode for MPC8569MDS
Date: Tue,  2 Jun 2009 10:04:16 -0400
Message-ID: <1243951456-4685-4-git-send-email-Haiying.Wang@freescale.com>
References: <1243951456-4685-1-git-send-email-Haiying.Wang@freescale.com>
 <1243951456-4685-2-git-send-email-Haiying.Wang@freescale.com>
 <1243951456-4685-3-git-send-email-Haiying.Wang@freescale.com>
Cc: linuxppc-dev@ozlabs.org, netdev@vger.kernel.org,
	Haiying Wang <Haiying.Wang@freescale.com>
To: davem@davemloft.net, galak@kernel.crashing.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from az33egw02.freescale.net ([192.88.158.103]:44598 "EHLO
	az33egw02.freescale.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756595AbZFBODw (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 2 Jun 2009 10:03:52 -0400
In-Reply-To: <1243951456-4685-3-git-send-email-Haiying.Wang@freescale.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Signed-off-by: Haiying Wang <Haiying.Wang@freescale.com>
---
 arch/powerpc/boot/dts/mpc8569mds.dts |   63 ++++++++++++++++++++++++++++++++++
 1 files changed, 63 insertions(+), 0 deletions(-)

diff --git a/arch/powerpc/boot/dts/mpc8569mds.dts b/arch/powerpc/boot/dts/mpc8569mds.dts
index 39c2927..4e95abd 100644
--- a/arch/powerpc/boot/dts/mpc8569mds.dts
+++ b/arch/powerpc/boot/dts/mpc8569mds.dts
@@ -24,6 +24,8 @@
 		ethernet1 = &enet1;
 		ethernet2 = &enet2;
 		ethernet3 = &enet3;
+		ethernet5 = &enet5;
+		ethernet7 = &enet7;
 		pci1 = &pci1;
 		rapidio0 = &rio0;
 	};
@@ -466,6 +468,37 @@
 				reg = <0x3>;
 				device_type = "ethernet-phy";
 			};
+			qe_phy5: ethernet-phy@04 {
+				interrupt-parent = <&mpic>;
+				reg = <0x04>;
+				device_type = "ethernet-phy";
+			};
+			qe_phy7: ethernet-phy@06 {
+				interrupt-parent = <&mpic>;
+				reg = <0x6>;
+				device_type = "ethernet-phy";
+			};
+		};
+		mdio@3520 {
+			#address-cells = <1>;
+			#size-cells = <0>;
+			reg = <0x3520 0x18>;
+			compatible = "fsl,ucc-mdio";
+
+			tbi0: tbi-phy@15 {
+			reg = <0x15>;
+			device_type = "tbi-phy";
+			};
+		};
+		mdio@3720 {
+			#address-cells = <1>;
+			#size-cells = <0>;
+			reg = <0x3720 0x38>;
+			compatible = "fsl,ucc-mdio";
+			tbi1: tbi-phy@17 {
+				reg = <0x17>;
+				device_type = "tbi-phy";
+			};
 		};
 
 		enet2: ucc@2200 {
@@ -513,6 +546,36 @@
 			phy-connection-type = "rgmii-id";
 		};
 
+		enet5: ucc@3400 {
+			device_type = "network";
+			compatible = "ucc_geth";
+			cell-index = <6>;
+			reg = <0x3400 0x200>;
+			interrupts = <41>;
+			interrupt-parent = <&qeic>;
+			local-mac-address = [ 00 00 00 00 00 00 ];
+			rx-clock-name = "none";
+			tx-clock-name = "none";
+			tbi-handle = <&tbi0>;
+			phy-handle = <&qe_phy5>;
+			phy-connection-type = "sgmii";
+		};
+
+		enet7: ucc@3600 {
+			device_type = "network";
+			compatible = "ucc_geth";
+			cell-index = <8>;
+			reg = <0x3600 0x200>;
+			interrupts = <43>;
+			interrupt-parent = <&qeic>;
+			local-mac-address = [ 00 00 00 00 00 00 ];
+			rx-clock-name = "none";
+			tx-clock-name = "none";
+			tbi-handle = <&tbi1>;
+			phy-handle = <&qe_phy7>;
+			phy-connection-type = "sgmii";
+		};
+
 		muram@10000 {
 			#address-cells = <1>;
 			#size-cells = <1>;
-- 
1.6.0.2

