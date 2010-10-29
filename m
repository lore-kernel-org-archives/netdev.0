From: Paul Gortmaker <paul.gortmaker@windriver.com>
Subject: [PATCH 05/15] dec netdev: relocate DIGITAL based drivers to legacy
Date: Thu, 28 Oct 2010 21:19:09 -0400
Message-ID: <1288315159-1350-6-git-send-email-paul.gortmaker@windriver.com>
References: <1288315159-1350-1-git-send-email-paul.gortmaker@windriver.com>
Cc: netdev@vger.kernel.org
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.windriver.com ([147.11.1.11]:33972 "EHLO
	mail.windriver.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1758467Ab0J2BT2 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 28 Oct 2010 21:19:28 -0400
In-Reply-To: <1288315159-1350-1-git-send-email-paul.gortmaker@windriver.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

DEC as a name brand has been gone for over 10 years, and these
drivers represent technology from the 1990's like the venerable
ISA bus.  Hence relocate them to the legacy dir.

Signed-off-by: Paul Gortmaker <paul.gortmaker@windriver.com>
---
 drivers/net/Kconfig                 |   63 -----------------------------------
 drivers/net/Makefile                |    4 --
 drivers/net/legacy/Kconfig          |   63 +++++++++++++++++++++++++++++++++++
 drivers/net/legacy/Makefile         |    5 +++
 drivers/net/{ => legacy}/declance.c |    0
 drivers/net/{ => legacy}/defxx.c    |    0
 drivers/net/{ => legacy}/defxx.h    |    0
 drivers/net/{ => legacy}/depca.c    |    0
 drivers/net/{ => legacy}/depca.h    |    0
 drivers/net/{ => legacy}/ewrk3.c    |    0
 drivers/net/{ => legacy}/ewrk3.h    |    0
 11 files changed, 68 insertions(+), 67 deletions(-)
 rename drivers/net/{ => legacy}/declance.c (100%)
 rename drivers/net/{ => legacy}/defxx.c (100%)
 rename drivers/net/{ => legacy}/defxx.h (100%)
 rename drivers/net/{ => legacy}/depca.c (100%)
 rename drivers/net/{ => legacy}/depca.h (100%)
 rename drivers/net/{ => legacy}/ewrk3.c (100%)
 rename drivers/net/{ => legacy}/ewrk3.h (100%)

diff --git a/drivers/net/Kconfig b/drivers/net/Kconfig
index 511745d..fb58ea7 100644
--- a/drivers/net/Kconfig
+++ b/drivers/net/Kconfig
@@ -1104,19 +1104,6 @@ config AT1700
 	  To compile this driver as a module, choose M here. The module
 	  will be called at1700.
 
-config DEPCA
-	tristate "DEPCA, DE10x, DE200, DE201, DE202, DE422 support"
-	depends on ISA || EISA || MCA
-	select CRC32
-	---help---
-	  If you have a network (Ethernet) card of this type, say Y and read
-	  the Ethernet-HOWTO, available from
-	  <http://www.tldp.org/docs.html#howto> as well as
-	  <file:drivers/net/depca.c>.
-
-	  To compile this driver as a module, choose M here. The module
-	  will be called depca.
-
 config HP100
 	tristate "HP 10/100VG PCLAN (ISA, EISA, PCI) support"
 	depends on ISA || EISA || PCI
@@ -1157,20 +1144,6 @@ config E2100
 	  To compile this driver as a module, choose M here. The module
 	  will be called e2100.
 
-config EWRK3
-	tristate "EtherWORKS 3 (DE203, DE204, DE205) support"
-	depends on NET_ISA
-	select CRC32
-	---help---
-	  This driver supports the DE203, DE204 and DE205 network (Ethernet)
-	  cards. If this is for you, say Y and read
-	  <file:Documentation/networking/ewrk3.txt> in the kernel source as
-	  well as the Ethernet-HOWTO, available from
-	  <http://www.tldp.org/docs.html#howto>.
-
-	  To compile this driver as a module, choose M here. The module
-	  will be called ewrk3.
-
 config EEXPRESS
 	tristate "EtherExpress 16 support"
 	depends on NET_ISA
@@ -1852,15 +1825,6 @@ config SGISEEQ
 	  Say Y here if you have an Seeq based Ethernet network card. This is
 	  used in many Silicon Graphics machines.
 
-config DECLANCE
-	tristate "DEC LANCE ethernet controller support"
-	depends on MACH_DECSTATION
-	select CRC32
-	help
-	  This driver is for the series of Ethernet controllers produced by
-	  DEC (now Compaq) based on the AMD Lance chipset, including the
-	  DEPCA series.  (This chipset is better known via the NE2100 cards.)
-
 config 68360_ENET
 	bool "Motorola 68360 ethernet controller"
 	depends on M68360
@@ -2913,33 +2877,6 @@ config FDDI
 	  then also Y to the driver for your FDDI card, below). Most people
 	  will say N.
 
-config DEFXX
-	tristate "Digital DEFTA/DEFEA/DEFPA adapter support"
-	depends on FDDI && (PCI || EISA || TC)
-	---help---
-	  This is support for the DIGITAL series of TURBOchannel (DEFTA),
-	  EISA (DEFEA) and PCI (DEFPA) controllers which can connect you
-	  to a local FDDI network.
-
-	  To compile this driver as a module, choose M here: the module
-	  will be called defxx.  If unsure, say N.
-
-config DEFXX_MMIO
-	bool
-	prompt "Use MMIO instead of PIO" if PCI || EISA
-	depends on DEFXX
-	default n if PCI || EISA
-	default y
-	---help---
-	  This instructs the driver to use EISA or PCI memory-mapped I/O
-	  (MMIO) as appropriate instead of programmed I/O ports (PIO).
-	  Enabling this gives an improvement in processing time in parts
-	  of the driver, but it may cause problems with EISA (DEFEA)
-	  adapters.  TURBOchannel does not have the concept of I/O ports,
-	  so MMIO is always used for these (DEFTA) adapters.
-
-	  If unsure, say N.
-
 config SKFP
 	tristate "SysKonnect FDDI PCI support"
 	depends on FDDI && PCI
diff --git a/drivers/net/Makefile b/drivers/net/Makefile
index 152f8b5..f6536fe 100644
--- a/drivers/net/Makefile
+++ b/drivers/net/Makefile
@@ -175,7 +175,6 @@ obj-$(CONFIG_IFB) += ifb.o
 obj-$(CONFIG_MACVLAN) += macvlan.o
 obj-$(CONFIG_MACVTAP) += macvtap.o
 obj-$(CONFIG_LANCE) += lance.o
-obj-$(CONFIG_DEFXX) += defxx.o
 obj-$(CONFIG_SGISEEQ) += sgiseeq.o
 obj-$(CONFIG_SGI_O2MACE_ETH) += meth.o
 obj-$(CONFIG_AT1700) += at1700.o
@@ -191,8 +190,6 @@ obj-$(CONFIG_8139CP) += 8139cp.o
 obj-$(CONFIG_8139TOO) += 8139too.o
 obj-$(CONFIG_ZNET) += znet.o
 obj-$(CONFIG_CPMAC) += cpmac.o
-obj-$(CONFIG_DEPCA) += depca.o
-obj-$(CONFIG_EWRK3) += ewrk3.o
 obj-$(CONFIG_ATP) += atp.o
 obj-$(CONFIG_NI5010) += ni5010.o
 obj-$(CONFIG_NI52) += ni52.o
@@ -219,7 +216,6 @@ obj-$(CONFIG_MIPS_JAZZ_SONIC) += jazzsonic.o
 obj-$(CONFIG_MIPS_AU1X00_ENET) += au1000_eth.o
 obj-$(CONFIG_MIPS_SIM_NET) += mipsnet.o
 obj-$(CONFIG_SGI_IOC3_ETH) += ioc3-eth.o
-obj-$(CONFIG_DECLANCE) += declance.o
 obj-$(CONFIG_ATARILANCE) += atarilance.o
 obj-$(CONFIG_A2065) += a2065.o
 obj-$(CONFIG_HYDRA) += hydra.o 8390.o
diff --git a/drivers/net/legacy/Kconfig b/drivers/net/legacy/Kconfig
index 1af0740..ac163cc 100644
--- a/drivers/net/legacy/Kconfig
+++ b/drivers/net/legacy/Kconfig
@@ -66,3 +66,66 @@ config SUN3_82586
 	  Ethernet adapter found on Sun 3/1xx and 3/2xx motherboards.  Note
 	  that this driver does not support 82586-based adapters on additional
 	  VME boards.
+
+config DEPCA
+	tristate "DEPCA, DE10x, DE200, DE201, DE202, DE422 support"
+	depends on ISA || EISA || MCA
+	select CRC32
+	---help---
+	  If you have a network (Ethernet) card of this type, say Y and read
+	  the Ethernet-HOWTO, available from
+	  <http://www.tldp.org/docs.html#howto> as well as
+	  <file:drivers/net/depca.c>.
+
+	  To compile this driver as a module, choose M here. The module
+	  will be called depca.
+
+config EWRK3
+	tristate "EtherWORKS 3 (DE203, DE204, DE205) support"
+	depends on NET_ISA
+	select CRC32
+	---help---
+	  This driver supports the DE203, DE204 and DE205 network (Ethernet)
+	  cards. If this is for you, say Y and read
+	  <file:Documentation/networking/ewrk3.txt> in the kernel source as
+	  well as the Ethernet-HOWTO, available from
+	  <http://www.tldp.org/docs.html#howto>.
+
+	  To compile this driver as a module, choose M here. The module
+	  will be called ewrk3.
+
+config DECLANCE
+	tristate "DEC LANCE ethernet controller support"
+	depends on MACH_DECSTATION
+	select CRC32
+	help
+	  This driver is for the series of Ethernet controllers produced by
+	  DEC (now Compaq) based on the AMD Lance chipset, including the
+	  DEPCA series.  (This chipset is better known via the NE2100 cards.)
+
+config DEFXX
+	tristate "Digital DEFTA/DEFEA/DEFPA adapter support"
+	depends on FDDI && (PCI || EISA || TC)
+	---help---
+	  This is support for the DIGITAL series of TURBOchannel (DEFTA),
+	  EISA (DEFEA) and PCI (DEFPA) controllers which can connect you
+	  to a local FDDI network.
+
+	  To compile this driver as a module, choose M here: the module
+	  will be called defxx.  If unsure, say N.
+
+config DEFXX_MMIO
+	bool
+	prompt "Use MMIO instead of PIO" if PCI || EISA
+	depends on DEFXX
+	default n if PCI || EISA
+	default y
+	---help---
+	  This instructs the driver to use EISA or PCI memory-mapped I/O
+	  (MMIO) as appropriate instead of programmed I/O ports (PIO).
+	  Enabling this gives an improvement in processing time in parts
+	  of the driver, but it may cause problems with EISA (DEFEA)
+	  adapters.  TURBOchannel does not have the concept of I/O ports,
+	  so MMIO is always used for these (DEFTA) adapters.
+
+	  If unsure, say N.
diff --git a/drivers/net/legacy/Makefile b/drivers/net/legacy/Makefile
index f552c77..7ab3669 100644
--- a/drivers/net/legacy/Makefile
+++ b/drivers/net/legacy/Makefile
@@ -8,3 +8,8 @@ obj-$(CONFIG_DE620) += de620.o
 
 obj-$(CONFIG_SUN3_82586) += sun3_82586.o
 obj-$(CONFIG_SUN3LANCE) += sun3lance.o
+
+obj-$(CONFIG_DEFXX) += defxx.o
+obj-$(CONFIG_DEPCA) += depca.o
+obj-$(CONFIG_EWRK3) += ewrk3.o
+obj-$(CONFIG_DECLANCE) += declance.o
diff --git a/drivers/net/declance.c b/drivers/net/legacy/declance.c
similarity index 100%
rename from drivers/net/declance.c
rename to drivers/net/legacy/declance.c
diff --git a/drivers/net/defxx.c b/drivers/net/legacy/defxx.c
similarity index 100%
rename from drivers/net/defxx.c
rename to drivers/net/legacy/defxx.c
diff --git a/drivers/net/defxx.h b/drivers/net/legacy/defxx.h
similarity index 100%
rename from drivers/net/defxx.h
rename to drivers/net/legacy/defxx.h
diff --git a/drivers/net/depca.c b/drivers/net/legacy/depca.c
similarity index 100%
rename from drivers/net/depca.c
rename to drivers/net/legacy/depca.c
diff --git a/drivers/net/depca.h b/drivers/net/legacy/depca.h
similarity index 100%
rename from drivers/net/depca.h
rename to drivers/net/legacy/depca.h
diff --git a/drivers/net/ewrk3.c b/drivers/net/legacy/ewrk3.c
similarity index 100%
rename from drivers/net/ewrk3.c
rename to drivers/net/legacy/ewrk3.c
diff --git a/drivers/net/ewrk3.h b/drivers/net/legacy/ewrk3.h
similarity index 100%
rename from drivers/net/ewrk3.h
rename to drivers/net/legacy/ewrk3.h
-- 
1.7.3.2.146.g2d444

