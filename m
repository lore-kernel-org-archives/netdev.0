From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [RFC 03/72] amd8111e/pcnet32/*lance/mvme147: Move AMD chipset drivers
Date: Sat, 25 Jun 2011 06:58:14 -0700
Message-ID: <1309010363-22750-4-git-send-email-jeffrey.t.kirsher@intel.com>
References: <1309010363-22750-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: Jeff Kirsher <jeffrey.t.kirsher@intel.com>, netdev@vger.kernel.org,
	Peter Maydell <pmaydell@chiark.greenend.org.uk>,
	Roman Hodek <Roman.Hodek@informatik.uni-erlangen.de>,
	"Maciej W. Rozycki" <macro@linux-mips.org>,
	Donald Becker <becker@scyld.com>,
	Sam Creasey <sammy@users.qual.net>,
	Miguel de Icaza <miguel@nuclecu.unam.mx>,
	Thomas Bogendoerfer <tsbogend@alpha.franken.de>,
	Don Fry <pcnet32@frontier.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga03.intel.com ([143.182.124.21]:44842 "EHLO mga03.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751713Ab1FYN7a (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sat, 25 Jun 2011 09:59:30 -0400
In-Reply-To: <1309010363-22750-1-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Moves the drivers for the AMD chipsets into drivers/net/ethernet/amd/
and the necessary Kconfig and Makfile changes.

CC: Peter Maydell <pmaydell@chiark.greenend.org.uk>
CC: Roman Hodek <Roman.Hodek@informatik.uni-erlangen.de>
CC: "Maciej W. Rozycki" <macro@linux-mips.org>
CC: Donald Becker <becker@scyld.com>
CC: Sam Creasey <sammy@users.qual.net>
CC: Miguel de Icaza <miguel@nuclecu.unam.mx>
CC: Thomas Bogendoerfer <tsbogend@alpha.franken.de>
CC: Don Fry <pcnet32@frontier.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 MAINTAINERS                                 |    2 +-
 drivers/net/Kconfig                         |   99 -----------------------
 drivers/net/Makefile                        |    9 --
 drivers/net/ethernet/Kconfig                |    1 +
 drivers/net/ethernet/Makefile               |    1 +
 drivers/net/{ => ethernet/amd}/7990.c       |    0
 drivers/net/{ => ethernet/amd}/7990.h       |    0
 drivers/net/ethernet/amd/Kconfig            |  115 +++++++++++++++++++++++++++
 drivers/net/ethernet/amd/Makefile           |   13 +++
 drivers/net/{ => ethernet/amd}/amd8111e.c   |    0
 drivers/net/{ => ethernet/amd}/amd8111e.h   |    0
 drivers/net/{ => ethernet/amd}/atarilance.c |    0
 drivers/net/{ => ethernet/amd}/declance.c   |    0
 drivers/net/{ => ethernet/amd}/hplance.c    |    0
 drivers/net/{ => ethernet/amd}/hplance.h    |    0
 drivers/net/{ => ethernet/amd}/lance.c      |    0
 drivers/net/{ => ethernet/amd}/mvme147.c    |    0
 drivers/net/{ => ethernet/amd}/pcnet32.c    |    0
 drivers/net/{ => ethernet/amd}/sun3lance.c  |    0
 drivers/net/{ => ethernet/amd}/sunlance.c   |    0
 20 files changed, 131 insertions(+), 109 deletions(-)
 rename drivers/net/{ => ethernet/amd}/7990.c (100%)
 rename drivers/net/{ => ethernet/amd}/7990.h (100%)
 create mode 100644 drivers/net/ethernet/amd/Kconfig
 create mode 100644 drivers/net/ethernet/amd/Makefile
 rename drivers/net/{ => ethernet/amd}/amd8111e.c (100%)
 rename drivers/net/{ => ethernet/amd}/amd8111e.h (100%)
 rename drivers/net/{ => ethernet/amd}/atarilance.c (100%)
 rename drivers/net/{ => ethernet/amd}/declance.c (100%)
 rename drivers/net/{ => ethernet/amd}/hplance.c (100%)
 rename drivers/net/{ => ethernet/amd}/hplance.h (100%)
 rename drivers/net/{ => ethernet/amd}/lance.c (100%)
 rename drivers/net/{ => ethernet/amd}/mvme147.c (100%)
 rename drivers/net/{ => ethernet/amd}/pcnet32.c (100%)
 rename drivers/net/{ => ethernet/amd}/sun3lance.c (100%)
 rename drivers/net/{ => ethernet/amd}/sunlance.c (100%)

diff --git a/MAINTAINERS b/MAINTAINERS
index e4ac504..e155522 100644
--- a/MAINTAINERS
+++ b/MAINTAINERS
@@ -4875,7 +4875,7 @@ PCNET32 NETWORK DRIVER
 M:	Don Fry <pcnet32@frontier.com>
 L:	netdev@vger.kernel.org
 S:	Maintained
-F:	drivers/net/pcnet32.c
+F:	drivers/net/ethernet/amd/pcnet32.c
 
 PCRYPT PARALLEL CRYPTO ENGINE
 M:	Steffen Klassert <steffen.klassert@secunet.com>
diff --git a/drivers/net/Kconfig b/drivers/net/Kconfig
index b5248ce..28abb09 100644
--- a/drivers/net/Kconfig
+++ b/drivers/net/Kconfig
@@ -387,16 +387,6 @@ config MACMACE
 	  say Y and read the Ethernet-HOWTO, available from
 	  <http://www.tldp.org/docs.html#howto>.
 
-config MVME147_NET
-	tristate "MVME147 (Lance) Ethernet support"
-	depends on MVME147
-	select CRC32
-	help
-	  Support for the on-board Ethernet interface on the Motorola MVME147
-	  single-board computer.  Say Y here to include the
-	  driver for this chip in your kernel.
-	  To compile this driver as a module, choose M here.
-
 config MVME16x_NET
 	tristate "MVME16x Ethernet support"
 	depends on MVME16x
@@ -415,27 +405,6 @@ config BVME6000_NET
 	  in your kernel.
 	  To compile this driver as a module, choose M here.
 
-config ATARILANCE
-	tristate "Atari Lance support"
-	depends on ATARI
-	help
-	  Say Y to include support for several Atari Ethernet adapters based
-	  on the AMD Lance chipset: RieblCard (with or without battery), or
-	  PAMCard VME (also the version by Rhotron, with different addresses).
-
-config SUN3LANCE
-	tristate "Sun3/Sun3x on-board LANCE support"
-	depends on SUN3 || SUN3X
-	help
-	  Most Sun3 and Sun3x motherboards (including the 3/50, 3/60 and 3/80)
-	  featured an AMD Lance 10Mbit Ethernet controller on board; say Y
-	  here to compile in the Linux driver for this and enable Ethernet.
-	  General Linux information on the Sun 3 and 3x series (now
-	  discontinued) is at
-	  <http://www.angelfire.com/ca2/tech68k/sun3.html>.
-
-	  If you're not building a kernel for a Sun 3, say N.
-
 config SUN3_82586
 	bool "Sun3 on-board Intel 82586 support"
 	depends on SUN3
@@ -445,14 +414,6 @@ config SUN3_82586
 	  that this driver does not support 82586-based adapters on additional
 	  VME boards.
 
-config HPLANCE
-	bool "HP on-board LANCE support"
-	depends on DIO
-	select CRC32
-	help
-	  If you want to use the builtin "LANCE" Ethernet controller on an
-	  HP300 machine, say Y here.
-
 config LASI_82596
 	tristate "Lasi ethernet"
 	depends on GSC
@@ -545,19 +506,6 @@ config SH_ETH
 	  This driver supporting CPUs are:
 		- SH7710, SH7712, SH7763, SH7619, SH7724, and SH7757.
 
-config SUNLANCE
-	tristate "Sun LANCE support"
-	depends on SBUS
-	select CRC32
-	help
-	  This driver supports the "le" interface present on all 32-bit Sparc
-	  systems, on some older Ultra systems and as an Sbus option.  These
-	  cards are based on the AMD Lance chipset, which is better known
-	  via the NE2100 cards.
-
-	  To compile this driver as a module, choose M here: the module
-	  will be called sunlance.
-
 config HAPPYMEAL
 	tristate "Sun Happy Meal 10/100baseT support"
 	depends on SBUS || PCI
@@ -616,18 +564,6 @@ config SUNVNET
 	help
 	  Support for virtual network devices under Sun Logical Domains.
 
-config LANCE
-	tristate "AMD LANCE and PCnet (AT1500 and NE2100) support"
-	depends on ISA && ISA_DMA_API
-	help
-	  If you have a network (Ethernet) card of this type, say Y and read
-	  the Ethernet-HOWTO, available from
-	  <http://www.tldp.org/docs.html#howto>. Some LinkSys cards are
-	  of this type.
-
-	  To compile this driver as a module, choose M here: the module
-	  will be called lance.  This is recommended.
-
 config NET_VENDOR_SMC
 	bool "Western Digital/SMC cards"
 	depends on ISA || MCA || EISA || MAC
@@ -1230,32 +1166,6 @@ config NET_PCI
 	  will be asked for your specific card in the following questions. If
 	  you are unsure, say Y.
 
-config PCNET32
-	tristate "AMD PCnet32 PCI support"
-	depends on NET_PCI && PCI
-	select CRC32
-	select MII
-	help
-	  If you have a PCnet32 or PCnetPCI based network (Ethernet) card,
-	  answer Y here and read the Ethernet-HOWTO, available from
-	  <http://www.tldp.org/docs.html#howto>.
-
-	  To compile this driver as a module, choose M here. The module
-	  will be called pcnet32.
-
-config AMD8111_ETH
-	tristate "AMD 8111 (new PCI lance) support"
-	depends on NET_PCI && PCI
-	select CRC32
-	select MII
-	help
-	  If you have an AMD 8111-based PCI lance ethernet card,
-	  answer Y here and read the Ethernet-HOWTO, available from
-	  <http://www.tldp.org/docs.html#howto>.
-
-	  To compile this driver as a module, choose M here. The module
-	  will be called amd8111e.
-
 config ADAPTEC_STARFIRE
 	tristate "Adaptec Starfire/DuraLAN support"
 	depends on NET_PCI && PCI
@@ -1777,15 +1687,6 @@ config SGISEEQ
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
diff --git a/drivers/net/Makefile b/drivers/net/Makefile
index 376a30d..f70087d 100644
--- a/drivers/net/Makefile
+++ b/drivers/net/Makefile
@@ -56,7 +56,6 @@ obj-$(CONFIG_PLIP) += plip.o
 obj-$(CONFIG_ROADRUNNER) += rrunner.o
 
 obj-$(CONFIG_HAPPYMEAL) += sunhme.o
-obj-$(CONFIG_SUNLANCE) += sunlance.o
 obj-$(CONFIG_SUNQE) += sunqe.o
 obj-$(CONFIG_SUNBMAC) += sunbmac.o
 obj-$(CONFIG_SUNGEM) += sungem.o sungem_phy.o
@@ -67,7 +66,6 @@ obj-$(CONFIG_MACE) += mace.o
 obj-$(CONFIG_BMAC) += bmac.o
 
 obj-$(CONFIG_NE2K_PCI) += ne2k-pci.o 8390.o
-obj-$(CONFIG_PCNET32) += pcnet32.o
 obj-$(CONFIG_E100) += e100.o
 obj-$(CONFIG_TLAN) += tlan.o
 obj-$(CONFIG_EPIC100) += epic100.o
@@ -177,9 +175,7 @@ obj-$(CONFIG_MACVLAN) += macvlan.o
 obj-$(CONFIG_MACVTAP) += macvtap.o
 obj-$(CONFIG_DE600) += de600.o
 obj-$(CONFIG_DE620) += de620.o
-obj-$(CONFIG_LANCE) += lance.o
 obj-$(CONFIG_SUN3_82586) += sun3_82586.o
-obj-$(CONFIG_SUN3LANCE) += sun3lance.o
 obj-$(CONFIG_DEFXX) += defxx.o
 obj-$(CONFIG_SGISEEQ) += sgiseeq.o
 obj-$(CONFIG_SGI_O2MACE_ETH) += meth.o
@@ -210,16 +206,12 @@ obj-$(CONFIG_LP486E) += lp486e.o
 
 obj-$(CONFIG_ETH16I) += eth16i.o
 obj-$(CONFIG_ZORRO8390) += zorro8390.o
-obj-$(CONFIG_HPLANCE) += hplance.o 7990.o
-obj-$(CONFIG_MVME147_NET) += mvme147.o 7990.o
 obj-$(CONFIG_EQUALIZER) += eql.o
 obj-$(CONFIG_KORINA) += korina.o
 obj-$(CONFIG_MIPS_JAZZ_SONIC) += jazzsonic.o
 obj-$(CONFIG_MIPS_AU1X00_ENET) += au1000_eth.o
 obj-$(CONFIG_MIPS_SIM_NET) += mipsnet.o
 obj-$(CONFIG_SGI_IOC3_ETH) += ioc3-eth.o
-obj-$(CONFIG_DECLANCE) += declance.o
-obj-$(CONFIG_ATARILANCE) += atarilance.o
 obj-$(CONFIG_A2065) += a2065.o
 obj-$(CONFIG_HYDRA) += hydra.o
 obj-$(CONFIG_ARIADNE) += ariadne.o
@@ -232,7 +224,6 @@ obj-$(CONFIG_VETH) += veth.o
 obj-$(CONFIG_NET_NETX) += netx-eth.o
 obj-$(CONFIG_DL2K) += dl2k.o
 obj-$(CONFIG_R8169) += r8169.o
-obj-$(CONFIG_AMD8111_ETH) += amd8111e.o
 obj-$(CONFIG_IBMVETH) += ibmveth.o
 obj-$(CONFIG_S2IO) += s2io.o
 obj-$(CONFIG_VXGE) += vxge/
diff --git a/drivers/net/ethernet/Kconfig b/drivers/net/ethernet/Kconfig
index 18193ec..5e62efd 100644
--- a/drivers/net/ethernet/Kconfig
+++ b/drivers/net/ethernet/Kconfig
@@ -12,5 +12,6 @@ menuconfig ETHERNET
 if ETHERNET
 
 source "drivers/net/ethernet/3com/Kconfig"
+source "drivers/net/ethernet/amd/Kconfig"
 
 endif # ETHERNET
diff --git a/drivers/net/ethernet/Makefile b/drivers/net/ethernet/Makefile
index 07766ba..1bc2ac2 100644
--- a/drivers/net/ethernet/Makefile
+++ b/drivers/net/ethernet/Makefile
@@ -3,3 +3,4 @@
 #
 
 obj-$(CONFIG_NET_VENDOR_3COM) += 3com/
+obj-$(CONFIG_NET_VENDOR_AMD) += amd/
diff --git a/drivers/net/7990.c b/drivers/net/ethernet/amd/7990.c
similarity index 100%
rename from drivers/net/7990.c
rename to drivers/net/ethernet/amd/7990.c
diff --git a/drivers/net/7990.h b/drivers/net/ethernet/amd/7990.h
similarity index 100%
rename from drivers/net/7990.h
rename to drivers/net/ethernet/amd/7990.h
diff --git a/drivers/net/ethernet/amd/Kconfig b/drivers/net/ethernet/amd/Kconfig
new file mode 100644
index 0000000..0b1e591
--- /dev/null
+++ b/drivers/net/ethernet/amd/Kconfig
@@ -0,0 +1,115 @@
+#
+# AMD network device configuration
+#
+
+config NET_VENDOR_AMD
+	bool "AMD devices"
+	depends on DIO || MACH_DECSTATION || MVME147 || ATARI || SUN3 || \
+		   SUN3X || SBUS || PCI || (ISA && ISA_DMA_API)
+	---help---
+	  If you have a network (Ethernet) chipset belonging to this class,
+	  say Y.
+
+	  Note that the answer to this question does not directly affect
+	  the kernel: saying N will just case the configurator to skip all
+	  the questions regarding AMD chipsets. If you say Y, you will be asked
+	  for your specific chipset/driver in the following questions.
+
+config AMD8111_ETH
+	tristate "AMD 8111 (new PCI LANCE) support"
+	depends on PCI && NET_VENDOR_AMD
+	select CRC32
+	select MII
+	---help---
+	  If you have an AMD 8111-based PCI LANCE ethernet card,
+	  answer Y here and read the Ethernet-HOWTO, available from
+	  <http://www.tldp.org/docs.html#howto>.
+
+	  To compile this driver as a module, choose M here. The module
+	  will be called amd8111e.
+
+config ATARILANCE
+	tristate "Atari LANCE support"
+	depends on ATARI && NET_VENDOR_AMD
+	---help---
+	  Say Y to include support for several Atari Ethernet adapters based
+	  on the AMD LANCE chipset: RieblCard (with or without battery), or
+	  PAMCard VME (also the version by Rhotron, with different addresses).
+
+config DECLANCE
+	tristate "DEC LANCE ethernet controller support"
+	depends on MACH_DECSTATION && NET_VENDOR_AMD
+	select CRC32
+	---help---
+	  This driver is for the series of Ethernet controllers produced by
+	  DEC (now Compaq) based on the AMD LANCE chipset, including the
+	  DEPCA series.  (This chipset is better known via the NE2100 cards.)
+
+config HPLANCE
+	bool "HP on-board LANCE support"
+	depends on DIO && NET_VENDOR_AMD
+	select CRC32
+	---help---
+	  If you want to use the builtin "LANCE" Ethernet controller on an
+	  HP300 machine, say Y here.
+
+config LANCE
+	tristate "AMD LANCE and PCnet (AT1500 and NE2100) support"
+	depends on ISA && ISA_DMA_API && NET_VENDOR_AMD
+	---help---
+	  If you have a network (Ethernet) card of this type, say Y and read
+	  the Ethernet-HOWTO, available from
+	  <http://www.tldp.org/docs.html#howto>. Some LinkSys cards are
+	  of this type.
+
+	  To compile this driver as a module, choose M here: the module
+	  will be called lance.  This is recommended.
+
+config MVME147_NET
+	tristate "MVME147 (LANCE) Ethernet support"
+	depends on MVME147 && NET_VENDOR_AMD
+	select CRC32
+	---help---
+	  Support for the on-board Ethernet interface on the Motorola MVME147
+	  single-board computer.  Say Y here to include the
+	  driver for this chip in your kernel.
+	  To compile this driver as a module, choose M here.
+
+config PCNET32
+	tristate "AMD PCnet32 PCI support"
+	depends on PCI && NET_VENDOR_AMD
+	select CRC32
+	select MII
+	---help---
+	  If you have a PCnet32 or PCnetPCI based network (Ethernet) card,
+	  answer Y here and read the Ethernet-HOWTO, available from
+	  <http://www.tldp.org/docs.html#howto>.
+
+	  To compile this driver as a module, choose M here. The module
+	  will be called pcnet32.
+
+config SUN3LANCE
+	tristate "Sun3/Sun3x on-board LANCE support"
+	depends on (SUN3 || SUN3X) && NET_VENDOR_AMD
+	---help---
+	  Most Sun3 and Sun3x motherboards (including the 3/50, 3/60 and 3/80)
+	  featured an AMD LANCE 10Mbit Ethernet controller on board; say Y
+	  here to compile in the Linux driver for this and enable Ethernet.
+	  General Linux information on the Sun 3 and 3x series (now
+	  discontinued) is at
+	  <http://www.angelfire.com/ca2/tech68k/sun3.html>.
+
+	  If you're not building a kernel for a Sun 3, say N.
+
+config SUNLANCE
+	tristate "Sun LANCE support"
+	depends on SBUS && NET_VENDOR_AMD
+	select CRC32
+	---help---
+	  This driver supports the "le" interface present on all 32-bit Sparc
+	  systems, on some older Ultra systems and as an Sbus option.  These
+	  cards are based on the AMD LANCE chipset, which is better known
+	  via the NE2100 cards.
+
+	  To compile this driver as a module, choose M here: the module
+	  will be called sunlance.
diff --git a/drivers/net/ethernet/amd/Makefile b/drivers/net/ethernet/amd/Makefile
new file mode 100644
index 0000000..54042f0
--- /dev/null
+++ b/drivers/net/ethernet/amd/Makefile
@@ -0,0 +1,13 @@
+#
+# Makefile for the AMD network device drivers.
+#
+
+obj-$(CONFIG_AMD8111_ETH) += amd8111e.o
+obj-$(CONFIG_ATARILANCE) += atarilance.o
+obj-$(CONFIG_DECLANCE) += declance.o
+obj-$(CONFIG_HPLANCE) += hplance.o 7990.o
+obj-$(CONFIG_LANCE) += lance.o
+obj-$(CONFIG_MVME147_NET) += mvme147.o 7990.o
+obj-$(CONFIG_PCNET32) += pcnet32.o
+obj-$(CONFIG_SUN3LANCE) += sun3lance.o
+obj-$(CONFIG_SUNLANCE) += sunlance.o
diff --git a/drivers/net/amd8111e.c b/drivers/net/ethernet/amd/amd8111e.c
similarity index 100%
rename from drivers/net/amd8111e.c
rename to drivers/net/ethernet/amd/amd8111e.c
diff --git a/drivers/net/amd8111e.h b/drivers/net/ethernet/amd/amd8111e.h
similarity index 100%
rename from drivers/net/amd8111e.h
rename to drivers/net/ethernet/amd/amd8111e.h
diff --git a/drivers/net/atarilance.c b/drivers/net/ethernet/amd/atarilance.c
similarity index 100%
rename from drivers/net/atarilance.c
rename to drivers/net/ethernet/amd/atarilance.c
diff --git a/drivers/net/declance.c b/drivers/net/ethernet/amd/declance.c
similarity index 100%
rename from drivers/net/declance.c
rename to drivers/net/ethernet/amd/declance.c
diff --git a/drivers/net/hplance.c b/drivers/net/ethernet/amd/hplance.c
similarity index 100%
rename from drivers/net/hplance.c
rename to drivers/net/ethernet/amd/hplance.c
diff --git a/drivers/net/hplance.h b/drivers/net/ethernet/amd/hplance.h
similarity index 100%
rename from drivers/net/hplance.h
rename to drivers/net/ethernet/amd/hplance.h
diff --git a/drivers/net/lance.c b/drivers/net/ethernet/amd/lance.c
similarity index 100%
rename from drivers/net/lance.c
rename to drivers/net/ethernet/amd/lance.c
diff --git a/drivers/net/mvme147.c b/drivers/net/ethernet/amd/mvme147.c
similarity index 100%
rename from drivers/net/mvme147.c
rename to drivers/net/ethernet/amd/mvme147.c
diff --git a/drivers/net/pcnet32.c b/drivers/net/ethernet/amd/pcnet32.c
similarity index 100%
rename from drivers/net/pcnet32.c
rename to drivers/net/ethernet/amd/pcnet32.c
diff --git a/drivers/net/sun3lance.c b/drivers/net/ethernet/amd/sun3lance.c
similarity index 100%
rename from drivers/net/sun3lance.c
rename to drivers/net/ethernet/amd/sun3lance.c
diff --git a/drivers/net/sunlance.c b/drivers/net/ethernet/amd/sunlance.c
similarity index 100%
rename from drivers/net/sunlance.c
rename to drivers/net/ethernet/amd/sunlance.c
-- 
1.7.5.4

