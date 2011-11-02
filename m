From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net] i825xx:xscale:8390:freescale: Fix Kconfig dependancies
Date: Wed,  2 Nov 2011 03:30:52 -0700
Message-ID: <1320229852-18161-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: Jeff Kirsher <jeffrey.t.kirsher@intel.com>, netdev@vger.kernel.org,
	gospo@redhat.com, sassmann@redhat.com
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga02.intel.com ([134.134.136.20]:35712 "EHLO mga02.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751777Ab1KBKbK (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 2 Nov 2011 06:31:10 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

i825xx and xscale are "sub" Kconfigs to NET_VENDOR_INTEL, so
NET_VENDOR_INTEL should contain ALL the dependencies of the
"sub" Kconfigs.

Same with 8390 is a "sub" Kconfig to NET_VENDOR_NATSEMI, so
NET_VENDOR_NATSEMI needs to contains ALL the dependencies.

Freescale Kconfig only had fs_enet as a sub Kconfig, and already
contained the needed dependencies, just cleaned up the dependencies.

Reported-by: Geert Uytterhoeven <geert@linux-m68k.org>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 drivers/net/ethernet/freescale/Kconfig |    3 +--
 drivers/net/ethernet/intel/Kconfig     |    6 +++++-
 drivers/net/ethernet/natsemi/Kconfig   |    6 +++++-
 3 files changed, 11 insertions(+), 4 deletions(-)

diff --git a/drivers/net/ethernet/freescale/Kconfig b/drivers/net/ethernet/freescale/Kconfig
index 1cf6716..c520cfd 100644
--- a/drivers/net/ethernet/freescale/Kconfig
+++ b/drivers/net/ethernet/freescale/Kconfig
@@ -7,8 +7,7 @@ config NET_VENDOR_FREESCALE
 	default y
 	depends on FSL_SOC || QUICC_ENGINE || CPM1 || CPM2 || PPC_MPC512x || \
 		   M523x || M527x || M5272 || M528x || M520x || M532x || \
-		   ARCH_MXC || ARCH_MXS || \
-		   (PPC_MPC52xx && PPC_BESTCOMM)
+		   ARCH_MXC || ARCH_MXS || (PPC_MPC52xx && PPC_BESTCOMM)
 	---help---
 	  If you have a network (Ethernet) card belonging to this class, say Y
 	  and read the Ethernet-HOWTO, available from
diff --git a/drivers/net/ethernet/intel/Kconfig b/drivers/net/ethernet/intel/Kconfig
index 61029dc..7621316 100644
--- a/drivers/net/ethernet/intel/Kconfig
+++ b/drivers/net/ethernet/intel/Kconfig
@@ -5,7 +5,11 @@
 config NET_VENDOR_INTEL
 	bool "Intel devices"
 	default y
-	depends on PCI || PCI_MSI
+	depends on PCI || PCI_MSI || ISA || ISA_DMA_API || ARM || \
+		   ARCH_ACORN || MCA || MCA_LEGACY || SNI_RM || SUN3 || \
+		   GSC || BVME6000 || MVME16x || ARCH_ENP2611 || \
+		   (ARM && ARCH_IXP4XX && IXP4XX_NPE && IXP4XX_QMGR) || \
+		   EXPERIMENTAL
 	---help---
 	  If you have a network (Ethernet) card belonging to this class, say Y
 	  and read the Ethernet-HOWTO, available from
diff --git a/drivers/net/ethernet/natsemi/Kconfig b/drivers/net/ethernet/natsemi/Kconfig
index 4a6b9fd..c708bc3 100644
--- a/drivers/net/ethernet/natsemi/Kconfig
+++ b/drivers/net/ethernet/natsemi/Kconfig
@@ -5,7 +5,11 @@
 config NET_VENDOR_NATSEMI
 	bool "National Semi-conductor devices"
 	default y
-	depends on MCA || MAC || MACH_JAZZ || PCI || XTENSA_PLATFORM_XT2000
+	depends on AMIGA_PCMCIA || ARM || EISA || EXPERIMENTAL || H8300 || \
+		   ISA || M32R || MAC || MACH_JAZZ || MACH_TX49XX || MCA || \
+		   MCA_LEGACY || MIPS || PCI || PCMCIA || SUPERH || \
+		   XTENSA_PLATFORM_XT2000 || ZORRO
+		   
 	---help---
 	  If you have a network (Ethernet) card belonging to this class, say Y
 	  and read the Ethernet-HOWTO, available from
-- 
1.7.6.4
