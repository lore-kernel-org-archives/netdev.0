From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [RFC 23/72] bmac/mace/macmace/mac89x0/cs89x0: Move the Macintosh (Apple) drivers
Date: Sat, 25 Jun 2011 06:58:34 -0700
Message-ID: <1309010363-22750-24-git-send-email-jeffrey.t.kirsher@intel.com>
References: <1309010363-22750-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: Jeff Kirsher <jeffrey.t.kirsher@intel.com>, netdev@vger.kernel.org,
	Paul Mackerras <paulus@samba.org>,
	Paul Mackerras <paulus@au.ibm.com>,
	Russell Nelson <nelson@crynwr.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga14.intel.com ([143.182.124.37]:2034 "EHLO mga14.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752205Ab1FYOAO (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sat, 25 Jun 2011 10:00:14 -0400
In-Reply-To: <1309010363-22750-1-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Move the Apple drivers into driver/net/ethernet/apple/ and make the
necessary Kconfig and Makefile changes.

CC: Paul Mackerras <paulus@samba.org>
CC: Paul Mackerras <paulus@au.ibm.com>
CC: Russell Nelson <nelson@crynwr.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 drivers/net/Kconfig                        |   75 ----------------------
 drivers/net/Makefile                       |    6 --
 drivers/net/ethernet/Kconfig               |    1 +
 drivers/net/ethernet/Makefile              |    1 +
 drivers/net/ethernet/apple/Kconfig         |   92 ++++++++++++++++++++++++++++
 drivers/net/ethernet/apple/Makefile        |    9 +++
 drivers/net/{ => ethernet/apple}/bmac.c    |    0
 drivers/net/{ => ethernet/apple}/bmac.h    |    0
 drivers/net/{ => ethernet/apple}/cs89x0.c  |    0
 drivers/net/{ => ethernet/apple}/cs89x0.h  |    0
 drivers/net/{ => ethernet/apple}/mac89x0.c |    0
 drivers/net/{ => ethernet/apple}/mace.c    |    0
 drivers/net/{ => ethernet/apple}/mace.h    |    0
 drivers/net/{ => ethernet/apple}/macmace.c |    0
 14 files changed, 103 insertions(+), 81 deletions(-)
 create mode 100644 drivers/net/ethernet/apple/Kconfig
 create mode 100644 drivers/net/ethernet/apple/Makefile
 rename drivers/net/{ => ethernet/apple}/bmac.c (100%)
 rename drivers/net/{ => ethernet/apple}/bmac.h (100%)
 rename drivers/net/{ => ethernet/apple}/cs89x0.c (100%)
 rename drivers/net/{ => ethernet/apple}/cs89x0.h (100%)
 rename drivers/net/{ => ethernet/apple}/mac89x0.c (100%)
 rename drivers/net/{ => ethernet/apple}/mace.c (100%)
 rename drivers/net/{ => ethernet/apple}/mace.h (100%)
 rename drivers/net/{ => ethernet/apple}/macmace.c (100%)

diff --git a/drivers/net/Kconfig b/drivers/net/Kconfig
index 4be1bcf..56c963a 100644
--- a/drivers/net/Kconfig
+++ b/drivers/net/Kconfig
@@ -237,40 +237,6 @@ config MACB
 
 source "drivers/net/arm/Kconfig"
 
-config MACE
-	tristate "MACE (Power Mac ethernet) support"
-	depends on PPC_PMAC && PPC32
-	select CRC32
-	help
-	  Power Macintoshes and clones with Ethernet built-in on the
-	  motherboard will usually use a MACE (Medium Access Control for
-	  Ethernet) interface. Say Y to include support for the MACE chip.
-
-	  To compile this driver as a module, choose M here: the module
-	  will be called mace.
-
-config MACE_AAUI_PORT
-	bool "Use AAUI port instead of TP by default"
-	depends on MACE
-	help
-	  Some Apple machines (notably the Apple Network Server) which use the
-	  MACE ethernet chip have an Apple AUI port (small 15-pin connector),
-	  instead of an 8-pin RJ45 connector for twisted-pair ethernet.  Say
-	  Y here if you have such a machine.  If unsure, say N.
-	  The driver will default to AAUI on ANS anyway, and if you use it as
-	  a module, you can provide the port_aaui=0|1 to force the driver.
-
-config BMAC
-	tristate "BMAC (G3 ethernet) support"
-	depends on PPC_PMAC && PPC32
-	select CRC32
-	help
-	  Say Y for support of BMAC Ethernet interfaces. These are used on G3
-	  computers.
-
-	  To compile this driver as a module, choose M here: the module
-	  will be called bmac.
-
 config ARIADNE
 	tristate "Ariadne support"
 	depends on ZORRO
@@ -292,18 +258,6 @@ config A2065
 	  To compile this driver as a module, choose M here: the module
 	  will be called a2065.
 
-config MAC89x0
-	tristate "Macintosh CS89x0 based ethernet cards"
-	depends on MAC
-	---help---
-	  Support for CS89x0 chipset based Ethernet cards.  If you have a
-	  Nubus or LC-PDS network (Ethernet) card of this type, say Y and
-	  read the Ethernet-HOWTO, available from
-	  <http://www.tldp.org/docs.html#howto>.
-
-	  To compile this driver as a module, choose M here. This module will
-	  be called mac89x0.
-
 config MACSONIC
 	tristate "Macintosh SONIC based ethernet (onboard, NuBus, LC, CS)"
 	depends on MAC
@@ -317,16 +271,6 @@ config MACSONIC
 	  To compile this driver as a module, choose M here. This module will
 	  be called macsonic.
 
-config MACMACE
-	bool "Macintosh (AV) onboard MACE ethernet"
-	depends on MAC
-	select CRC32
-	help
-	  Support for the onboard AMD 79C940 MACE Ethernet controller used in
-	  the 660AV and 840AV Macintosh.  If you have one of these Macintoshes
-	  say Y and read the Ethernet-HOWTO, available from
-	  <http://www.tldp.org/docs.html#howto>.
-
 config MVME16x_NET
 	tristate "MVME16x Ethernet support"
 	depends on MVME16x
@@ -831,25 +775,6 @@ config FORCEDETH
 	  To compile this driver as a module, choose M here. The module
 	  will be called forcedeth.
 
-config CS89x0
-	tristate "CS89x0 support"
-	depends on NET_ETHERNET && (ISA || EISA || MACH_IXDP2351 \
-		|| ARCH_IXDP2X01 || MACH_MX31ADS || MACH_QQ2440)
-	---help---
-	  Support for CS89x0 chipset based Ethernet cards. If you have a
-	  network (Ethernet) card of this type, say Y and read the
-	  Ethernet-HOWTO, available from
-	  <http://www.tldp.org/docs.html#howto> as well as
-	  <file:Documentation/networking/cs89x0.txt>.
-
-	  To compile this driver as a module, choose M here. The module
-	  will be called cs89x0.
-
-config CS89x0_NONISA_IRQ
-	def_bool y
-	depends on CS89x0 != n
-	depends on MACH_IXDP2351 || ARCH_IXDP2X01 || MACH_MX31ADS || MACH_QQ2440
-
 config TC35815
 	tristate "TOSHIBA TC35815 Ethernet support"
 	depends on NET_PCI && PCI && MIPS
diff --git a/drivers/net/Makefile b/drivers/net/Makefile
index 9a73e0f..9ac99cd 100644
--- a/drivers/net/Makefile
+++ b/drivers/net/Makefile
@@ -38,9 +38,6 @@ obj-$(CONFIG_PLIP) += plip.o
 
 obj-$(CONFIG_ROADRUNNER) += rrunner.o
 
-obj-$(CONFIG_MACE) += mace.o
-obj-$(CONFIG_BMAC) += bmac.o
-
 obj-$(CONFIG_TLAN) += tlan.o
 obj-$(CONFIG_SMSC9420) += smsc9420.o
 obj-$(CONFIG_SIS190) += sis190.o
@@ -150,10 +147,7 @@ obj-$(CONFIG_MIPS_SIM_NET) += mipsnet.o
 obj-$(CONFIG_SGI_IOC3_ETH) += ioc3-eth.o
 obj-$(CONFIG_A2065) += a2065.o
 obj-$(CONFIG_ARIADNE) += ariadne.o
-obj-$(CONFIG_CS89x0) += cs89x0.o
 obj-$(CONFIG_MACSONIC) += macsonic.o
-obj-$(CONFIG_MACMACE) += macmace.o
-obj-$(CONFIG_MAC89x0) += mac89x0.o
 obj-$(CONFIG_TUN) += tun.o
 obj-$(CONFIG_VETH) += veth.o
 obj-$(CONFIG_NET_NETX) += netx-eth.o
diff --git a/drivers/net/ethernet/Kconfig b/drivers/net/ethernet/Kconfig
index 4714825..28b473b 100644
--- a/drivers/net/ethernet/Kconfig
+++ b/drivers/net/ethernet/Kconfig
@@ -14,6 +14,7 @@ if ETHERNET
 source "drivers/net/ethernet/3com/Kconfig"
 source "drivers/net/ethernet/8390/Kconfig"
 source "drivers/net/ethernet/amd/Kconfig"
+source "drivers/net/ethernet/apple/Kconfig"
 source "drivers/net/ethernet/broadcom/Kconfig"
 source "drivers/net/ethernet/brocade/Kconfig"
 source "drivers/net/ethernet/chelsio/Kconfig"
diff --git a/drivers/net/ethernet/Makefile b/drivers/net/ethernet/Makefile
index 76ea04b..40dded7 100644
--- a/drivers/net/ethernet/Makefile
+++ b/drivers/net/ethernet/Makefile
@@ -5,6 +5,7 @@
 obj-$(CONFIG_NET_VENDOR_3COM) += 3com/
 obj-$(CONFIG_NET_VENDOR_8390) += 8390/
 obj-$(CONFIG_NET_VENDOR_AMD) += amd/
+obj-$(CONFIG_NET_VENDOR_APPLE) += apple/
 obj-$(CONFIG_NET_VENDOR_BROADCOM) += broadcom/
 obj-$(CONFIG_NET_VENDOR_BROCADE) += brocade/
 obj-$(CONFIG_NET_VENDOR_CHELSIO) += chelsio/
diff --git a/drivers/net/ethernet/apple/Kconfig b/drivers/net/ethernet/apple/Kconfig
new file mode 100644
index 0000000..018fab6
--- /dev/null
+++ b/drivers/net/ethernet/apple/Kconfig
@@ -0,0 +1,92 @@
+#
+# Apple device configuration
+#
+
+config NET_VENDOR_APPLE
+	bool "Apple devices"
+	depends on PPC_PMAC || PPC32 || MAC || ISA || EISA || MACH_IXDP2351 \
+		|| ARCH_IXDP2X01 || MACH_MX31ADS || MACH_QQ2440
+	---help---
+	  If you have a network (Ethernet) card belonging to this class, say Y
+	  and read the Ethernet-HOWTO, available from
+	  <http://www.tldp.org/docs.html#howto>.
+
+	  Note that the answer to this question doesn't directly affect the
+	  kernel: saying N will just cause the configurator to skip all
+	  the questions about IBM devices. If you say Y, you will be asked for
+	  your specific card in the following questions.
+
+config MACE
+	tristate "MACE (Power Mac ethernet) support"
+	depends on NET_VENDOR_APPLE && PPC_PMAC && PPC32
+	select CRC32
+	---help---
+	  Power Macintoshes and clones with Ethernet built-in on the
+	  motherboard will usually use a MACE (Medium Access Control for
+	  Ethernet) interface. Say Y to include support for the MACE chip.
+
+	  To compile this driver as a module, choose M here: the module
+	  will be called mace.
+
+config MACE_AAUI_PORT
+	bool "Use AAUI port instead of TP by default"
+	depends on MACE
+	---help---
+	  Some Apple machines (notably the Apple Network Server) which use the
+	  MACE ethernet chip have an Apple AUI port (small 15-pin connector),
+	  instead of an 8-pin RJ45 connector for twisted-pair ethernet.  Say
+	  Y here if you have such a machine.  If unsure, say N.
+	  The driver will default to AAUI on ANS anyway, and if you use it as
+	  a module, you can provide the port_aaui=0|1 to force the driver.
+
+config BMAC
+	tristate "BMAC (G3 ethernet) support"
+	depends on NET_VENDOR_APPLE && PPC_PMAC && PPC32
+	select CRC32
+	---help---
+	  Say Y for support of BMAC Ethernet interfaces. These are used on G3
+	  computers.
+
+	  To compile this driver as a module, choose M here: the module
+	  will be called bmac.
+
+config MAC89x0
+	tristate "Macintosh CS89x0 based ethernet cards"
+	depends on NET_VENDOR_APPLE && MAC
+	---help---
+	  Support for CS89x0 chipset based Ethernet cards.  If you have a
+	  Nubus or LC-PDS network (Ethernet) card of this type, say Y and
+	  read the Ethernet-HOWTO, available from
+	  <http://www.tldp.org/docs.html#howto>.
+
+	  To compile this driver as a module, choose M here. This module will
+	  be called mac89x0.
+
+config MACMACE
+	bool "Macintosh (AV) onboard MACE ethernet"
+	depends on NET_VENDOR_APPLE && MAC
+	select CRC32
+	---help---
+	  Support for the onboard AMD 79C940 MACE Ethernet controller used in
+	  the 660AV and 840AV Macintosh.  If you have one of these Macintoshes
+	  say Y and read the Ethernet-HOWTO, available from
+	  <http://www.tldp.org/docs.html#howto>.
+
+config CS89x0
+	tristate "CS89x0 support"
+	depends on NET_VENDOR_APPLE && (ISA || EISA || MACH_IXDP2351 \
+		|| ARCH_IXDP2X01 || MACH_MX31ADS || MACH_QQ2440)
+	---help---
+	  Support for CS89x0 chipset based Ethernet cards. If you have a
+	  network (Ethernet) card of this type, say Y and read the
+	  Ethernet-HOWTO, available from
+	  <http://www.tldp.org/docs.html#howto> as well as
+	  <file:Documentation/networking/cs89x0.txt>.
+
+	  To compile this driver as a module, choose M here. The module
+	  will be called cs89x0.
+
+config CS89x0_NONISA_IRQ
+	def_bool y
+	depends on CS89x0 != n
+	depends on MACH_IXDP2351 || ARCH_IXDP2X01 || MACH_MX31ADS || MACH_QQ2440
diff --git a/drivers/net/ethernet/apple/Makefile b/drivers/net/ethernet/apple/Makefile
new file mode 100644
index 0000000..9d30086
--- /dev/null
+++ b/drivers/net/ethernet/apple/Makefile
@@ -0,0 +1,9 @@
+#
+# Makefile for the Apple network device drivers.
+#
+
+obj-$(CONFIG_MACE) += mace.o
+obj-$(CONFIG_BMAC) += bmac.o
+obj-$(CONFIG_MAC89x0) += mac89x0.o
+obj-$(CONFIG_CS89x0) += cs89x0.o
+obj-$(CONFIG_MACMACE) += macmace.o
diff --git a/drivers/net/bmac.c b/drivers/net/ethernet/apple/bmac.c
similarity index 100%
rename from drivers/net/bmac.c
rename to drivers/net/ethernet/apple/bmac.c
diff --git a/drivers/net/bmac.h b/drivers/net/ethernet/apple/bmac.h
similarity index 100%
rename from drivers/net/bmac.h
rename to drivers/net/ethernet/apple/bmac.h
diff --git a/drivers/net/cs89x0.c b/drivers/net/ethernet/apple/cs89x0.c
similarity index 100%
rename from drivers/net/cs89x0.c
rename to drivers/net/ethernet/apple/cs89x0.c
diff --git a/drivers/net/cs89x0.h b/drivers/net/ethernet/apple/cs89x0.h
similarity index 100%
rename from drivers/net/cs89x0.h
rename to drivers/net/ethernet/apple/cs89x0.h
diff --git a/drivers/net/mac89x0.c b/drivers/net/ethernet/apple/mac89x0.c
similarity index 100%
rename from drivers/net/mac89x0.c
rename to drivers/net/ethernet/apple/mac89x0.c
diff --git a/drivers/net/mace.c b/drivers/net/ethernet/apple/mace.c
similarity index 100%
rename from drivers/net/mace.c
rename to drivers/net/ethernet/apple/mace.c
diff --git a/drivers/net/mace.h b/drivers/net/ethernet/apple/mace.h
similarity index 100%
rename from drivers/net/mace.h
rename to drivers/net/ethernet/apple/mace.h
diff --git a/drivers/net/macmace.c b/drivers/net/ethernet/apple/macmace.c
similarity index 100%
rename from drivers/net/macmace.c
rename to drivers/net/ethernet/apple/macmace.c
-- 
1.7.5.4

