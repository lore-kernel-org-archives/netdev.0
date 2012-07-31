From: Ian Molton <ian.molton@codethink.co.uk>
Subject: [PATCH v2 5/6] csb1724: Enable device tree based mv643xx ethernet support.
Date: Tue, 31 Jul 2012 16:45:28 +0100
Message-ID: <1343749529-17571-6-git-send-email-ian.molton@codethink.co.uk>
References: <1343749529-17571-1-git-send-email-ian.molton@codethink.co.uk>
Cc: andrew@lunn.ch, thomas.petazzoni@free-electrons.com,
	ben.dooks@codethink.co.uk, arnd@arndb.de, netdev@vger.kernel.org
To: linux-arm-kernel@lists.infradead.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from ducie-dc1.codethink.co.uk ([37.128.190.40]:59910 "EHLO
	ducie-dc1.codethink.co.uk" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754492Ab2GaPzM (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 31 Jul 2012 11:55:12 -0400
In-Reply-To: <1343749529-17571-1-git-send-email-ian.molton@codethink.co.uk>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

    This patch enables mv643xx based ethernet built into the SoM on the
    csb1724, via flattened device tree.

    Signed-off-by: Ian Molton <ian.molton@codethink.co.uk>
---
 arch/arm/boot/dts/kirkwood-csb1724.dts |   19 ++++++++++++++
 arch/arm/boot/dts/kirkwood.dtsi        |   33 +++++++++++++++++++++++
 arch/arm/configs/csb1724_defconfig     |   45 ++++++++++++++++++++++++++++++++
 arch/arm/mach-kirkwood/board-csb1724.c |    1 +
 4 files changed, 98 insertions(+)

diff --git a/arch/arm/boot/dts/kirkwood-csb1724.dts b/arch/arm/boot/dts/kirkwood-csb1724.dts
index 44dfe9a..f43f8dd 100644
--- a/arch/arm/boot/dts/kirkwood-csb1724.dts
+++ b/arch/arm/boot/dts/kirkwood-csb1724.dts
@@ -25,6 +25,25 @@
 			nr-ports = <2>;
 			status = "ok";
 		};
+
+		smi0: mdio@72000 {
+			status = "ok";
+		};
+
+		smi1: mdio@76000 {
+			status = "ok";
+		};
+
+		egiga0 {
+			phy_addr = <0>;
+			status = "ok";
+		};
+
+		egiga1 {
+			phy_addr = <1>;
+			status = "ok";
+		};
+
 	};
 
 };
diff --git a/arch/arm/boot/dts/kirkwood.dtsi b/arch/arm/boot/dts/kirkwood.dtsi
index cef9616..f5f1f92 100644
--- a/arch/arm/boot/dts/kirkwood.dtsi
+++ b/arch/arm/boot/dts/kirkwood.dtsi
@@ -76,6 +76,39 @@
 			status = "okay";
 		};
 
+		smi0: mdio@72000 {
+			compatible = "marvell,mdio-mv643xx";
+			reg = <0x72000 0x4000>;
+			interrupts = <46>;
+			tx_csum_limit = <1600>;
+			status = "disabled";
+		};
+
+		egiga0 {
+			compatible = "marvell,mv643xx-eth";
+			reg = <0x72000 0x4000>;
+			mdio = <&smi0>;
+			interrupts = <11>;
+			status = "disabled";
+		};
+
+		smi1: mdio@76000 {
+			compatible = "marvell,mdio-mv643xx";
+			reg = <0x76000 0x4000>;
+			interrupts = <47>;
+			shared_smi = <&smi0>;
+			tx_csum_limit = <1600>;
+			status = "disabled";
+		};
+
+		egiga1 {
+			compatible = "marvell,mv643xx-eth";
+			reg = <0x76000 0x4000>;
+			mdio = <&smi1>;
+			interrupts = <15>;
+			status = "disabled";
+		};
+
 		sata@80000 {
 			compatible = "marvell,orion-sata";
 			reg = <0x80000 0x5000>;
diff --git a/arch/arm/configs/csb1724_defconfig b/arch/arm/configs/csb1724_defconfig
index 927b269..fbea657 100644
--- a/arch/arm/configs/csb1724_defconfig
+++ b/arch/arm/configs/csb1724_defconfig
@@ -45,3 +45,48 @@ CONFIG_PROC_DEVICETREE=y
 CONFIG_BLK_DEV_LOOP=y
 CONFIG_BLK_DEV_LOOP_MIN_COUNT=8
 CONFIG_DYNAMIC_DEBUG=y
+CONFIG_NET=y
+CONFIG_INET=y
+CONFIG_NETDEVICES=y
+CONFIG_MV643XX_ETH=y
+CONFIG_PACKET=y
+CONFIG_UNIX=y
+CONFIG_IPV6=n
+CONFIG_NET_VENDOR_3COM=n
+CONFIG_NET_VENDOR_ADAPTEC=n
+CONFIG_NET_VENDOR_ALTEON=n
+CONFIG_NET_VENDOR_AMD=n
+CONFIG_NET_VENDOR_ATHEROS=n
+CONFIG_NET_VENDOR_BROADCOM=n
+CONFIG_NET_VENDOR_BROCADE=n
+CONFIG_NET_VENDOR_CHELSIO=n
+CONFIG_NET_VENDOR_CIRRUS=n
+CONFIG_NET_VENDOR_CISCO=n
+CONFIG_NET_VENDOR_DEC=n
+CONFIG_NET_VENDOR_HP=n
+CONFIG_NET_VENDOR_DLINK=n
+CONFIG_NET_VENDOR_EMULEX=n
+CONFIG_NET_VENDOR_EXAR=n
+CONFIG_NET_VENDOR_FARADAY=n
+CONFIG_NET_VENDOR_INTEL=n
+CONFIG_NET_VENDOR_MELLANOX=n
+CONFIG_NET_VENDOR_MICREL=n
+CONFIG_NET_VENDOR_MYRI=n
+CONFIG_NET_VENDOR_NATSEMI=n
+CONFIG_NET_VENDOR_NVIDIA=n
+CONFIG_NET_VENDOR_OKI=n
+CONFIG_NET_PACKET_ENGINE=n
+CONFIG_NET_VENDOR_QLOGIC=n
+CONFIG_NET_VENDOR_REALTEK=n
+CONFIG_NET_VENDOR_RDC=n
+CONFIG_NET_VENDOR_SEEQ=n
+CONFIG_NET_VENDOR_SILAN=n
+CONFIG_NET_VENDOR_SIS=n
+CONFIG_NET_VENDOR_SMSC=n
+CONFIG_NET_VENDOR_STMICRO=n
+CONFIG_NET_VENDOR_SUN=n
+CONFIG_NET_VENDOR_TEHUTI=n
+CONFIG_NET_VENDOR_TI=n
+CONFIG_NET_VENDOR_VIA=n
+CONFIG_NET_VENDOR_WIZNET=n
+
diff --git a/arch/arm/mach-kirkwood/board-csb1724.c b/arch/arm/mach-kirkwood/board-csb1724.c
index 979112d..9c58b92 100644
--- a/arch/arm/mach-kirkwood/board-csb1724.c
+++ b/arch/arm/mach-kirkwood/board-csb1724.c
@@ -13,6 +13,7 @@
 
 #include <linux/kernel.h>
 #include <linux/init.h>
+#include "common.h"
 #include "mpp.h"
 
 static unsigned int csb1724_mpp_config[] __initdata = {
-- 
1.7.9.5
