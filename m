From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [RFC 02/72] 3c*/acenic/typhoon: Move 3Com Ethernet drivers
Date: Sat, 25 Jun 2011 06:58:13 -0700
Message-ID: <1309010363-22750-3-git-send-email-jeffrey.t.kirsher@intel.com>
References: <1309010363-22750-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: Jeff Kirsher <jeffrey.t.kirsher@intel.com>, netdev@vger.kernel.org,
	Philip Blundell <philb@gnu.org>,
	Steffen Klassert <klassert@mathematik.tu-chemnitz.de>,
	David Dillow <dave@thedillows.org>,
	Jes Sorensen <jes@trained-monkey.org>,
	Alan Cox <alan@linux.intel.com>,
	Donald Becker <becker@scyld.com>,
	Craig Southeren <craigs@ineluki.apana.org.au>,
	David Hinds <dahinds@users.sourceforge.net>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga03.intel.com ([143.182.124.21]:46933 "EHLO mga03.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751701Ab1FYN7a (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sat, 25 Jun 2011 09:59:30 -0400
In-Reply-To: <1309010363-22750-1-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Moves the 3Com drivers into drivers/net/ethernet/3com/ and the necessary
Kconfig and Makefile changes.

CC: Philip Blundell <philb@gnu.org>
CC: Steffen Klassert <klassert@mathematik.tu-chemnitz.de>
CC: David Dillow <dave@thedillows.org>
CC: Jes Sorensen <jes@trained-monkey.org>
CC: Alan Cox <alan@linux.intel.com>
CC: Donald Becker <becker@scyld.com>
CC: Craig Southeren <craigs@ineluki.apana.org.au>
CC: David Hinds <dahinds@users.sourceforge.net>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 MAINTAINERS                                      |    8 +-
 drivers/net/Kconfig                              |  177 -------------------
 drivers/net/Makefile                             |   12 +--
 drivers/net/{ => ethernet/3com}/3c501.c          |    0
 drivers/net/{ => ethernet/3com}/3c501.h          |    0
 drivers/net/{ => ethernet/3com}/3c503.c          |    0
 drivers/net/{ => ethernet/3com}/3c503.h          |    0
 drivers/net/{ => ethernet/3com}/3c505.c          |    0
 drivers/net/{ => ethernet/3com}/3c505.h          |    0
 drivers/net/{ => ethernet/3com}/3c507.c          |    0
 drivers/net/{ => ethernet/3com}/3c509.c          |    0
 drivers/net/{ => ethernet/3com}/3c515.c          |    0
 drivers/net/{ => ethernet/3com}/3c523.c          |    0
 drivers/net/{ => ethernet/3com}/3c523.h          |    0
 drivers/net/{ => ethernet/3com}/3c527.c          |    0
 drivers/net/{ => ethernet/3com}/3c527.h          |    0
 drivers/net/{pcmcia => ethernet/3com}/3c574_cs.c |    0
 drivers/net/{pcmcia => ethernet/3com}/3c589_cs.c |    0
 drivers/net/{ => ethernet/3com}/3c59x.c          |    0
 drivers/net/ethernet/3com/Kconfig                |  200 ++++++++++++++++++++++
 drivers/net/ethernet/3com/Makefile               |   17 ++
 drivers/net/{ => ethernet/3com}/acenic.c         |    0
 drivers/net/{ => ethernet/3com}/acenic.h         |    0
 drivers/net/{ => ethernet/3com}/typhoon.c        |    0
 drivers/net/{ => ethernet/3com}/typhoon.h        |    0
 drivers/net/ethernet/Kconfig                     |    2 +
 drivers/net/ethernet/Makefile                    |    1 +
 drivers/net/pcmcia/Kconfig                       |   18 --
 drivers/net/pcmcia/Makefile                      |    2 -
 29 files changed, 225 insertions(+), 212 deletions(-)
 rename drivers/net/{ => ethernet/3com}/3c501.c (100%)
 rename drivers/net/{ => ethernet/3com}/3c501.h (100%)
 rename drivers/net/{ => ethernet/3com}/3c503.c (100%)
 rename drivers/net/{ => ethernet/3com}/3c503.h (100%)
 rename drivers/net/{ => ethernet/3com}/3c505.c (100%)
 rename drivers/net/{ => ethernet/3com}/3c505.h (100%)
 rename drivers/net/{ => ethernet/3com}/3c507.c (100%)
 rename drivers/net/{ => ethernet/3com}/3c509.c (100%)
 rename drivers/net/{ => ethernet/3com}/3c515.c (100%)
 rename drivers/net/{ => ethernet/3com}/3c523.c (100%)
 rename drivers/net/{ => ethernet/3com}/3c523.h (100%)
 rename drivers/net/{ => ethernet/3com}/3c527.c (100%)
 rename drivers/net/{ => ethernet/3com}/3c527.h (100%)
 rename drivers/net/{pcmcia => ethernet/3com}/3c574_cs.c (100%)
 rename drivers/net/{pcmcia => ethernet/3com}/3c589_cs.c (100%)
 rename drivers/net/{ => ethernet/3com}/3c59x.c (100%)
 create mode 100644 drivers/net/ethernet/3com/Kconfig
 create mode 100644 drivers/net/ethernet/3com/Makefile
 rename drivers/net/{ => ethernet/3com}/acenic.c (100%)
 rename drivers/net/{ => ethernet/3com}/acenic.h (100%)
 rename drivers/net/{ => ethernet/3com}/typhoon.c (100%)
 rename drivers/net/{ => ethernet/3com}/typhoon.h (100%)

diff --git a/MAINTAINERS b/MAINTAINERS
index f0358cd..e4ac504 100644
--- a/MAINTAINERS
+++ b/MAINTAINERS
@@ -116,20 +116,20 @@ Maintainers List (try to look for most precise areas first)
 M:	Philip Blundell <philb@gnu.org>
 L:	netdev@vger.kernel.org
 S:	Maintained
-F:	drivers/net/3c505*
+F:	drivers/net/ethernet/3com/3c505*
 
 3C59X NETWORK DRIVER
 M:	Steffen Klassert <klassert@mathematik.tu-chemnitz.de>
 L:	netdev@vger.kernel.org
 S:	Maintained
 F:	Documentation/networking/vortex.txt
-F:	drivers/net/3c59x.c
+F:	drivers/net/ethernet/3com/3c59x.c
 
 3CR990 NETWORK DRIVER
 M:	David Dillow <dave@thedillows.org>
 L:	netdev@vger.kernel.org
 S:	Maintained
-F:	drivers/net/typhoon*
+F:	drivers/net/ethernet/3com/typhoon*
 
 3WARE SAS/SATA-RAID SCSI DRIVERS (3W-XXXX, 3W-9XXX, 3W-SAS)
 M:	Adam Radford <linuxraid@lsi.com>
@@ -213,7 +213,7 @@ ACENIC DRIVER
 M:	Jes Sorensen <jes@trained-monkey.org>
 L:	linux-acenic@sunsite.dk
 S:	Maintained
-F:	drivers/net/acenic*
+F:	drivers/net/ethernet/3com/acenic*
 
 ACER ASPIRE ONE TEMPERATURE AND FAN DRIVER
 M:	Peter Feuerer <peter@piie.net>
diff --git a/drivers/net/Kconfig b/drivers/net/Kconfig
index 32aa191..b5248ce 100644
--- a/drivers/net/Kconfig
+++ b/drivers/net/Kconfig
@@ -616,156 +616,6 @@ config SUNVNET
 	help
 	  Support for virtual network devices under Sun Logical Domains.
 
-config NET_VENDOR_3COM
-	bool "3COM cards"
-	depends on ISA || EISA || MCA || PCI
-	help
-	  If you have a network (Ethernet) card belonging to this class, say Y
-	  and read the Ethernet-HOWTO, available from
-	  <http://www.tldp.org/docs.html#howto>.
-
-	  Note that the answer to this question doesn't directly affect the
-	  kernel: saying N will just cause the configurator to skip all
-	  the questions about 3COM cards. If you say Y, you will be asked for
-	  your specific card in the following questions.
-
-config EL1
-	tristate "3c501 \"EtherLink\" support"
-	depends on NET_VENDOR_3COM && ISA
-	---help---
-	  If you have a network (Ethernet) card of this type, say Y and read
-	  the Ethernet-HOWTO, available from
-	  <http://www.tldp.org/docs.html#howto>.  Also, consider buying a
-	  new card, since the 3c501 is slow, broken, and obsolete: you will
-	  have problems.  Some people suggest to ping ("man ping") a nearby
-	  machine every minute ("man cron") when using this card.
-
-	  To compile this driver as a module, choose M here. The module
-	  will be called 3c501.
-
-config EL2
-	tristate "3c503 \"EtherLink II\" support"
-	depends on NET_VENDOR_3COM && ISA
-	select CRC32
-	help
-	  If you have a network (Ethernet) card of this type, say Y and read
-	  the Ethernet-HOWTO, available from
-	  <http://www.tldp.org/docs.html#howto>.
-
-	  To compile this driver as a module, choose M here. The module
-	  will be called 3c503.
-
-config ELPLUS
-	tristate "3c505 \"EtherLink Plus\" support"
-	depends on NET_VENDOR_3COM && ISA && ISA_DMA_API
-	---help---
-	  Information about this network (Ethernet) card can be found in
-	  <file:Documentation/networking/3c505.txt>.  If you have a card of
-	  this type, say Y and read the Ethernet-HOWTO, available from
-	  <http://www.tldp.org/docs.html#howto>.
-
-	  To compile this driver as a module, choose M here. The module
-	  will be called 3c505.
-
-config EL16
-	tristate "3c507 \"EtherLink 16\" support (EXPERIMENTAL)"
-	depends on NET_VENDOR_3COM && ISA && EXPERIMENTAL
-	help
-	  If you have a network (Ethernet) card of this type, say Y and read
-	  the Ethernet-HOWTO, available from
-	  <http://www.tldp.org/docs.html#howto>.
-
-	  To compile this driver as a module, choose M here. The module
-	  will be called 3c507.
-
-config EL3
-	tristate "3c509/3c529 (MCA)/3c579 \"EtherLink III\" support"
-	depends on NET_VENDOR_3COM && (ISA || EISA || MCA)
-	---help---
-	  If you have a network (Ethernet) card belonging to the 3Com
-	  EtherLinkIII series, say Y and read the Ethernet-HOWTO, available
-	  from <http://www.tldp.org/docs.html#howto>.
-
-	  If your card is not working you may need to use the DOS
-	  setup disk to disable Plug & Play mode, and to select the default
-	  media type.
-
-	  To compile this driver as a module, choose M here. The module
-	  will be called 3c509.
-
-config 3C515
-	tristate "3c515 ISA \"Fast EtherLink\""
-	depends on NET_VENDOR_3COM && (ISA || EISA) && ISA_DMA_API
-	help
-	  If you have a 3Com ISA EtherLink XL "Corkscrew" 3c515 Fast Ethernet
-	  network card, say Y and read the Ethernet-HOWTO, available from
-	  <http://www.tldp.org/docs.html#howto>.
-
-	  To compile this driver as a module, choose M here. The module
-	  will be called 3c515.
-
-config ELMC
-	tristate "3c523 \"EtherLink/MC\" support"
-	depends on NET_VENDOR_3COM && MCA_LEGACY
-	help
-	  If you have a network (Ethernet) card of this type, say Y and read
-	  the Ethernet-HOWTO, available from
-	  <http://www.tldp.org/docs.html#howto>.
-
-	  To compile this driver as a module, choose M here. The module
-	  will be called 3c523.
-
-config ELMC_II
-	tristate "3c527 \"EtherLink/MC 32\" support (EXPERIMENTAL)"
-	depends on NET_VENDOR_3COM && MCA && MCA_LEGACY
-	help
-	  If you have a network (Ethernet) card of this type, say Y and read
-	  the Ethernet-HOWTO, available from
-	  <http://www.tldp.org/docs.html#howto>.
-
-	  To compile this driver as a module, choose M here. The module
-	  will be called 3c527.
-
-config VORTEX
-	tristate "3c590/3c900 series (592/595/597) \"Vortex/Boomerang\" support"
-	depends on NET_VENDOR_3COM && (PCI || EISA)
-	select MII
-	---help---
-	  This option enables driver support for a large number of 10Mbps and
-	  10/100Mbps EISA, PCI and PCMCIA 3Com network cards:
-
-	  "Vortex"    (Fast EtherLink 3c590/3c592/3c595/3c597) EISA and PCI
-	  "Boomerang" (EtherLink XL 3c900 or 3c905)            PCI
-	  "Cyclone"   (3c540/3c900/3c905/3c980/3c575/3c656)    PCI and Cardbus
-	  "Tornado"   (3c905)                                  PCI
-	  "Hurricane" (3c555/3cSOHO)                           PCI
-
-	  If you have such a card, say Y and read the Ethernet-HOWTO,
-	  available from <http://www.tldp.org/docs.html#howto>. More
-	  specific information is in
-	  <file:Documentation/networking/vortex.txt> and in the comments at
-	  the beginning of <file:drivers/net/3c59x.c>.
-
-	  To compile this support as a module, choose M here.
-
-config TYPHOON
-	tristate "3cr990 series \"Typhoon\" support"
-	depends on NET_VENDOR_3COM && PCI
-	select CRC32
-	---help---
-	  This option enables driver support for the 3cr990 series of cards:
-
-	  3C990-TX, 3CR990-TX-95, 3CR990-TX-97, 3CR990-FX-95, 3CR990-FX-97,
-	  3CR990SVR, 3CR990SVR95, 3CR990SVR97, 3CR990-FX-95 Server,
-	  3CR990-FX-97 Server, 3C990B-TX-M, 3C990BSVR
-
-	  If you have a network (Ethernet) card of this type, say Y and read
-	  the Ethernet-HOWTO, available from
-	  <http://www.tldp.org/docs.html#howto>.
-
-	  To compile this driver as a module, choose M here. The module
-	  will be called typhoon.
-
 config LANCE
 	tristate "AMD LANCE and PCnet (AT1500 and NE2100) support"
 	depends on ISA && ISA_DMA_API
@@ -2053,33 +1903,6 @@ menuconfig NETDEV_1000
 
 if NETDEV_1000
 
-config ACENIC
-	tristate "Alteon AceNIC/3Com 3C985/NetGear GA620 Gigabit support"
-	depends on PCI
-	---help---
-	  Say Y here if you have an Alteon AceNIC, 3Com 3C985(B), NetGear
-	  GA620, SGI Gigabit or Farallon PN9000-SX PCI Gigabit Ethernet
-	  adapter. The driver allows for using the Jumbo Frame option (9000
-	  bytes/frame) however it requires that your switches can handle this
-	  as well. To enable Jumbo Frames, add `mtu 9000' to your ifconfig
-	  line.
-
-	  To compile this driver as a module, choose M here: the
-	  module will be called acenic.
-
-config ACENIC_OMIT_TIGON_I
-	bool "Omit support for old Tigon I based AceNICs"
-	depends on ACENIC
-	help
-	  Say Y here if you only have Tigon II based AceNICs and want to leave
-	  out support for the older Tigon I based cards which are no longer
-	  being sold (ie. the original Alteon AceNIC and 3Com 3C985 (non B
-	  version)).  This will reduce the size of the driver object by
-	  app. 100KB.  If you are not sure whether your card is a Tigon I or a
-	  Tigon II, say N here.
-
-	  The safe and default value for this is N.
-
 config DL2K
 	tristate "DL2000/TC902x-based Gigabit Ethernet support"
 	depends on PCI
diff --git a/drivers/net/Makefile b/drivers/net/Makefile
index 848f95a..376a30d 100644
--- a/drivers/net/Makefile
+++ b/drivers/net/Makefile
@@ -66,8 +66,6 @@ obj-$(CONFIG_SUNVNET) += sunvnet.o
 obj-$(CONFIG_MACE) += mace.o
 obj-$(CONFIG_BMAC) += bmac.o
 
-obj-$(CONFIG_VORTEX) += 3c59x.o
-obj-$(CONFIG_TYPHOON) += typhoon.o
 obj-$(CONFIG_NE2K_PCI) += ne2k-pci.o 8390.o
 obj-$(CONFIG_PCNET32) += pcnet32.o
 obj-$(CONFIG_E100) += e100.o
@@ -78,7 +76,6 @@ obj-$(CONFIG_SIS190) += sis190.o
 obj-$(CONFIG_SIS900) += sis900.o
 obj-$(CONFIG_R6040) += r6040.o
 obj-$(CONFIG_YELLOWFIN) += yellowfin.o
-obj-$(CONFIG_ACENIC) += acenic.o
 obj-$(CONFIG_ISERIES_VETH) += iseries_veth.o
 obj-$(CONFIG_NATSEMI) += natsemi.o
 obj-$(CONFIG_NS83820) += ns83820.o
@@ -129,7 +126,6 @@ ifeq ($(CONFIG_FEC_MPC52xx_MDIO),y)
 endif
 obj-$(CONFIG_68360_ENET) += 68360enet.o
 obj-$(CONFIG_WD80x3) += wd.o 8390.o
-obj-$(CONFIG_EL2) += 3c503.o 8390p.o
 obj-$(CONFIG_NE2000) += ne.o 8390p.o
 obj-$(CONFIG_NE2_MCA) += ne2.o 8390p.o
 obj-$(CONFIG_HPLAN) += hp.o 8390p.o
@@ -188,13 +184,7 @@ obj-$(CONFIG_DEFXX) += defxx.o
 obj-$(CONFIG_SGISEEQ) += sgiseeq.o
 obj-$(CONFIG_SGI_O2MACE_ETH) += meth.o
 obj-$(CONFIG_AT1700) += at1700.o
-obj-$(CONFIG_EL1) += 3c501.o
-obj-$(CONFIG_EL16) += 3c507.o
-obj-$(CONFIG_ELMC) += 3c523.o
 obj-$(CONFIG_IBMLANA) += ibmlana.o
-obj-$(CONFIG_ELMC_II) += 3c527.o
-obj-$(CONFIG_EL3) += 3c509.o
-obj-$(CONFIG_3C515) += 3c515.o
 obj-$(CONFIG_EEXPRESS) += eexpress.o
 obj-$(CONFIG_EEXPRESS_PRO) += eepro.o
 obj-$(CONFIG_8139CP) += 8139cp.o
@@ -207,7 +197,6 @@ obj-$(CONFIG_ATP) += atp.o
 obj-$(CONFIG_NI5010) += ni5010.o
 obj-$(CONFIG_NI52) += ni52.o
 obj-$(CONFIG_NI65) += ni65.o
-obj-$(CONFIG_ELPLUS) += 3c505.o
 obj-$(CONFIG_AC3200) += ac3200.o 8390.o
 obj-$(CONFIG_APRICOT) += 82596.o
 obj-$(CONFIG_LASI_82596) += lasi_82596.o
@@ -270,6 +259,7 @@ obj-$(CONFIG_S6GMAC) += s6gmac.o
 
 obj-$(CONFIG_ARM) += arm/
 obj-$(CONFIG_DEV_APPLETALK) += appletalk/
+obj-$(CONFIG_ETHERNET) += ethernet/
 obj-$(CONFIG_TR) += tokenring/
 obj-$(CONFIG_WAN) += wan/
 obj-$(CONFIG_ARCNET) += arcnet/
diff --git a/drivers/net/3c501.c b/drivers/net/ethernet/3com/3c501.c
similarity index 100%
rename from drivers/net/3c501.c
rename to drivers/net/ethernet/3com/3c501.c
diff --git a/drivers/net/3c501.h b/drivers/net/ethernet/3com/3c501.h
similarity index 100%
rename from drivers/net/3c501.h
rename to drivers/net/ethernet/3com/3c501.h
diff --git a/drivers/net/3c503.c b/drivers/net/ethernet/3com/3c503.c
similarity index 100%
rename from drivers/net/3c503.c
rename to drivers/net/ethernet/3com/3c503.c
diff --git a/drivers/net/3c503.h b/drivers/net/ethernet/3com/3c503.h
similarity index 100%
rename from drivers/net/3c503.h
rename to drivers/net/ethernet/3com/3c503.h
diff --git a/drivers/net/3c505.c b/drivers/net/ethernet/3com/3c505.c
similarity index 100%
rename from drivers/net/3c505.c
rename to drivers/net/ethernet/3com/3c505.c
diff --git a/drivers/net/3c505.h b/drivers/net/ethernet/3com/3c505.h
similarity index 100%
rename from drivers/net/3c505.h
rename to drivers/net/ethernet/3com/3c505.h
diff --git a/drivers/net/3c507.c b/drivers/net/ethernet/3com/3c507.c
similarity index 100%
rename from drivers/net/3c507.c
rename to drivers/net/ethernet/3com/3c507.c
diff --git a/drivers/net/3c509.c b/drivers/net/ethernet/3com/3c509.c
similarity index 100%
rename from drivers/net/3c509.c
rename to drivers/net/ethernet/3com/3c509.c
diff --git a/drivers/net/3c515.c b/drivers/net/ethernet/3com/3c515.c
similarity index 100%
rename from drivers/net/3c515.c
rename to drivers/net/ethernet/3com/3c515.c
diff --git a/drivers/net/3c523.c b/drivers/net/ethernet/3com/3c523.c
similarity index 100%
rename from drivers/net/3c523.c
rename to drivers/net/ethernet/3com/3c523.c
diff --git a/drivers/net/3c523.h b/drivers/net/ethernet/3com/3c523.h
similarity index 100%
rename from drivers/net/3c523.h
rename to drivers/net/ethernet/3com/3c523.h
diff --git a/drivers/net/3c527.c b/drivers/net/ethernet/3com/3c527.c
similarity index 100%
rename from drivers/net/3c527.c
rename to drivers/net/ethernet/3com/3c527.c
diff --git a/drivers/net/3c527.h b/drivers/net/ethernet/3com/3c527.h
similarity index 100%
rename from drivers/net/3c527.h
rename to drivers/net/ethernet/3com/3c527.h
diff --git a/drivers/net/pcmcia/3c574_cs.c b/drivers/net/ethernet/3com/3c574_cs.c
similarity index 100%
rename from drivers/net/pcmcia/3c574_cs.c
rename to drivers/net/ethernet/3com/3c574_cs.c
diff --git a/drivers/net/pcmcia/3c589_cs.c b/drivers/net/ethernet/3com/3c589_cs.c
similarity index 100%
rename from drivers/net/pcmcia/3c589_cs.c
rename to drivers/net/ethernet/3com/3c589_cs.c
diff --git a/drivers/net/3c59x.c b/drivers/net/ethernet/3com/3c59x.c
similarity index 100%
rename from drivers/net/3c59x.c
rename to drivers/net/ethernet/3com/3c59x.c
diff --git a/drivers/net/ethernet/3com/Kconfig b/drivers/net/ethernet/3com/Kconfig
new file mode 100644
index 0000000..9b343d9
--- /dev/null
+++ b/drivers/net/ethernet/3com/Kconfig
@@ -0,0 +1,200 @@
+#
+# 3Com Ethernet device configuration
+#
+
+config NET_VENDOR_3COM
+	bool "3Com devices"
+	depends on ISA || EISA || MCA || PCI || PCMCIA
+	---help---
+	  If you have a network (Ethernet) card belonging to this class, say Y
+	  and read the Ethernet-HOWTO, available from
+	  <http://www.tldp.org/docs.html#howto>.
+
+	  Note that the answer to this question doesn't directly affect the
+	  kernel: saying N will just cause the configurator to skip all
+	  the questions about 3COM cards. If you say Y, you will be asked for
+	  your specific card in the following questions.
+
+config EL1
+	tristate "3c501 \"EtherLink\" support"
+	depends on NET_VENDOR_3COM && ISA
+	---help---
+	  If you have a network (Ethernet) card of this type, say Y and read
+	  the Ethernet-HOWTO, available from
+	  <http://www.tldp.org/docs.html#howto>.  Also, consider buying a
+	  new card, since the 3c501 is slow, broken, and obsolete: you will
+	  have problems.  Some people suggest to ping ("man ping") a nearby
+	  machine every minute ("man cron") when using this card.
+
+	  To compile this driver as a module, choose M here. The module
+	  will be called 3c501.
+
+config EL2
+	tristate "3c503 \"EtherLink II\" support"
+	depends on NET_VENDOR_3COM && ISA
+	select CRC32
+	---help---
+	  If you have a network (Ethernet) card of this type, say Y and read
+	  the Ethernet-HOWTO, available from
+	  <http://www.tldp.org/docs.html#howto>.
+
+	  To compile this driver as a module, choose M here. The module
+	  will be called 3c503.
+
+config ELPLUS
+	tristate "3c505 \"EtherLink Plus\" support"
+	depends on NET_VENDOR_3COM && ISA && ISA_DMA_API
+	---help---
+	  Information about this network (Ethernet) card can be found in
+	  <file:Documentation/networking/3c505.txt>.  If you have a card of
+	  this type, say Y and read the Ethernet-HOWTO, available from
+	  <http://www.tldp.org/docs.html#howto>.
+
+	  To compile this driver as a module, choose M here. The module
+	  will be called 3c505.
+
+config EL16
+	tristate "3c507 \"EtherLink 16\" support (EXPERIMENTAL)"
+	depends on NET_VENDOR_3COM && ISA && EXPERIMENTAL
+	---help---
+	  If you have a network (Ethernet) card of this type, say Y and read
+	  the Ethernet-HOWTO, available from
+	  <http://www.tldp.org/docs.html#howto>.
+
+	  To compile this driver as a module, choose M here. The module
+	  will be called 3c507.
+
+config EL3
+	tristate "3c509/3c529 (MCA)/3c579 \"EtherLink III\" support"
+	depends on NET_VENDOR_3COM && (ISA || EISA || MCA)
+	---help---
+	  If you have a network (Ethernet) card belonging to the 3Com
+	  EtherLinkIII series, say Y and read the Ethernet-HOWTO, available
+	  from <http://www.tldp.org/docs.html#howto>.
+
+	  If your card is not working you may need to use the DOS
+	  setup disk to disable Plug & Play mode, and to select the default
+	  media type.
+
+	  To compile this driver as a module, choose M here. The module
+	  will be called 3c509.
+
+config 3C515
+	tristate "3c515 ISA \"Fast EtherLink\""
+	depends on NET_VENDOR_3COM && (ISA || EISA) && ISA_DMA_API
+	---help---
+	  If you have a 3Com ISA EtherLink XL "Corkscrew" 3c515 Fast Ethernet
+	  network card, say Y and read the Ethernet-HOWTO, available from
+	  <http://www.tldp.org/docs.html#howto>.
+
+	  To compile this driver as a module, choose M here. The module
+	  will be called 3c515.
+
+config ELMC
+	tristate "3c523 \"EtherLink/MC\" support"
+	depends on NET_VENDOR_3COM && MCA_LEGACY
+	---help---
+	  If you have a network (Ethernet) card of this type, say Y and read
+	  the Ethernet-HOWTO, available from
+	  <http://www.tldp.org/docs.html#howto>.
+
+	  To compile this driver as a module, choose M here. The module
+	  will be called 3c523.
+
+config ELMC_II
+	tristate "3c527 \"EtherLink/MC 32\" support (EXPERIMENTAL)"
+	depends on NET_VENDOR_3COM && MCA && MCA_LEGACY
+	---help---
+	  If you have a network (Ethernet) card of this type, say Y and read
+	  the Ethernet-HOWTO, available from
+	  <http://www.tldp.org/docs.html#howto>.
+
+	  To compile this driver as a module, choose M here. The module
+	  will be called 3c527.
+
+config PCMCIA_3C574
+	tristate "3Com 3c574 PCMCIA support"
+	depends on NET_VENDOR_3COM && PCMCIA
+	---help---
+	  Say Y here if you intend to attach a 3Com 3c574 or compatible PCMCIA
+	  (PC-card) Fast Ethernet card to your computer.
+
+	  To compile this driver as a module, choose M here: the module will be
+	  called 3c574_cs.  If unsure, say N.
+
+config PCMCIA_3C589
+	tristate "3Com 3c589 PCMCIA support"
+	depends on NET_VENDOR_3COM && PCMCIA
+	---help---
+	  Say Y here if you intend to attach a 3Com 3c589 or compatible PCMCIA
+	  (PC-card) Ethernet card to your computer.
+
+	  To compile this driver as a module, choose M here: the module will be
+	  called 3c589_cs.  If unsure, say N.
+
+config VORTEX
+	tristate "3c590/3c900 series (592/595/597) \"Vortex/Boomerang\" support"
+	depends on NET_VENDOR_3COM && (PCI || EISA)
+	select MII
+	---help---
+	  This option enables driver support for a large number of 10Mbps and
+	  10/100Mbps EISA, PCI and PCMCIA 3Com network cards:
+
+	  "Vortex"    (Fast EtherLink 3c590/3c592/3c595/3c597) EISA and PCI
+	  "Boomerang" (EtherLink XL 3c900 or 3c905)            PCI
+	  "Cyclone"   (3c540/3c900/3c905/3c980/3c575/3c656)    PCI and Cardbus
+	  "Tornado"   (3c905)                                  PCI
+	  "Hurricane" (3c555/3cSOHO)                           PCI
+
+	  If you have such a card, say Y and read the Ethernet-HOWTO,
+	  available from <http://www.tldp.org/docs.html#howto>. More
+	  specific information is in
+	  <file:Documentation/networking/vortex.txt> and in the comments at
+	  the beginning of <file:drivers/net/3c59x.c>.
+
+	  To compile this support as a module, choose M here.
+
+config TYPHOON
+	tristate "3cr990 series \"Typhoon\" support"
+	depends on NET_VENDOR_3COM && PCI
+	select CRC32
+	---help---
+	  This option enables driver support for the 3cr990 series of cards:
+
+	  3C990-TX, 3CR990-TX-95, 3CR990-TX-97, 3CR990-FX-95, 3CR990-FX-97,
+	  3CR990SVR, 3CR990SVR95, 3CR990SVR97, 3CR990-FX-95 Server,
+	  3CR990-FX-97 Server, 3C990B-TX-M, 3C990BSVR
+
+	  If you have a network (Ethernet) card of this type, say Y and read
+	  the Ethernet-HOWTO, available from
+	  <http://www.tldp.org/docs.html#howto>.
+
+	  To compile this driver as a module, choose M here. The module
+	  will be called typhoon.
+
+config ACENIC
+	tristate "Alteon AceNIC/3Com 3C985/NetGear GA620 Gigabit support"
+	depends on NET_VENDOR_3COM && PCI
+	---help---
+	  Say Y here if you have an Alteon AceNIC, 3Com 3C985(B), NetGear
+	  GA620, SGI Gigabit or Farallon PN9000-SX PCI Gigabit Ethernet
+	  adapter. The driver allows for using the Jumbo Frame option (9000
+	  bytes/frame) however it requires that your switches can handle this
+	  as well. To enable Jumbo Frames, add `mtu 9000' to your ifconfig
+	  line.
+
+	  To compile this driver as a module, choose M here: the
+	  module will be called acenic.
+
+config ACENIC_OMIT_TIGON_I
+	bool "Omit support for old Tigon I based AceNICs"
+	depends on ACENIC
+	---help---
+	  Say Y here if you only have Tigon II based AceNICs and want to leave
+	  out support for the older Tigon I based cards which are no longer
+	  being sold (ie. the original Alteon AceNIC and 3Com 3C985 (non B
+	  version)).  This will reduce the size of the driver object by
+	  app. 100KB.  If you are not sure whether your card is a Tigon I or a
+	  Tigon II, say N here.
+
+	  The safe and default value for this is N.
diff --git a/drivers/net/ethernet/3com/Makefile b/drivers/net/ethernet/3com/Makefile
new file mode 100644
index 0000000..a86fdac
--- /dev/null
+++ b/drivers/net/ethernet/3com/Makefile
@@ -0,0 +1,17 @@
+#
+# Makefile for the 3Com Ethernet device drivers
+#
+
+obj-$(CONFIG_EL1) += 3c501.o
+obj-$(CONFIG_EL2) += 3c503.o ../../8390p.o
+obj-$(CONFIG_ELPLUS) += 3c505.o
+obj-$(CONFIG_EL16) += 3c507.o
+obj-$(CONFIG_EL3) += 3c509.o
+obj-$(CONFIG_3C515) += 3c515.o
+obj-$(CONFIG_ELMC) += 3c523.o
+obj-$(CONFIG_ELMC_II) += 3c527.o
+obj-$(CONFIG_PCMCIA_3C589) += 3c589_cs.o
+obj-$(CONFIG_PCMCIA_3C574) += 3c574_cs.o
+obj-$(CONFIG_VORTEX) += 3c59x.o
+obj-$(CONFIG_ACENIC) += acenic.o
+obj-$(CONFIG_TYPHOON) += typhoon.o
diff --git a/drivers/net/acenic.c b/drivers/net/ethernet/3com/acenic.c
similarity index 100%
rename from drivers/net/acenic.c
rename to drivers/net/ethernet/3com/acenic.c
diff --git a/drivers/net/acenic.h b/drivers/net/ethernet/3com/acenic.h
similarity index 100%
rename from drivers/net/acenic.h
rename to drivers/net/ethernet/3com/acenic.h
diff --git a/drivers/net/typhoon.c b/drivers/net/ethernet/3com/typhoon.c
similarity index 100%
rename from drivers/net/typhoon.c
rename to drivers/net/ethernet/3com/typhoon.c
diff --git a/drivers/net/typhoon.h b/drivers/net/ethernet/3com/typhoon.h
similarity index 100%
rename from drivers/net/typhoon.h
rename to drivers/net/ethernet/3com/typhoon.h
diff --git a/drivers/net/ethernet/Kconfig b/drivers/net/ethernet/Kconfig
index d59e4f2..18193ec 100644
--- a/drivers/net/ethernet/Kconfig
+++ b/drivers/net/ethernet/Kconfig
@@ -11,4 +11,6 @@ menuconfig ETHERNET
 
 if ETHERNET
 
+source "drivers/net/ethernet/3com/Kconfig"
+
 endif # ETHERNET
diff --git a/drivers/net/ethernet/Makefile b/drivers/net/ethernet/Makefile
index d52694b..07766ba 100644
--- a/drivers/net/ethernet/Makefile
+++ b/drivers/net/ethernet/Makefile
@@ -2,3 +2,4 @@
 # Makefile for the Linux network Ethernet device drivers.
 #
 
+obj-$(CONFIG_NET_VENDOR_3COM) += 3com/
diff --git a/drivers/net/pcmcia/Kconfig b/drivers/net/pcmcia/Kconfig
index 9b8f793..b67c5ed 100644
--- a/drivers/net/pcmcia/Kconfig
+++ b/drivers/net/pcmcia/Kconfig
@@ -21,24 +21,6 @@ menuconfig NET_PCMCIA
 
 if NET_PCMCIA && PCMCIA
 
-config PCMCIA_3C589
-	tristate "3Com 3c589 PCMCIA support"
-	help
-	  Say Y here if you intend to attach a 3Com 3c589 or compatible PCMCIA
-	  (PC-card) Ethernet card to your computer.
-
-	  To compile this driver as a module, choose M here: the module will be
-	  called 3c589_cs.  If unsure, say N.
-
-config PCMCIA_3C574
-	tristate "3Com 3c574 PCMCIA support"
-	help
-	  Say Y here if you intend to attach a 3Com 3c574 or compatible PCMCIA
-	  (PC-card) Fast Ethernet card to your computer.
-
-	  To compile this driver as a module, choose M here: the module will be
-	  called 3c574_cs.  If unsure, say N.
-
 config PCMCIA_FMVJ18X
 	tristate "Fujitsu FMV-J18x PCMCIA support"
 	select CRC32
diff --git a/drivers/net/pcmcia/Makefile b/drivers/net/pcmcia/Makefile
index 87d2d99..2f2ab3b 100644
--- a/drivers/net/pcmcia/Makefile
+++ b/drivers/net/pcmcia/Makefile
@@ -3,8 +3,6 @@
 #
 
 # 16-bit client drivers
-obj-$(CONFIG_PCMCIA_3C589)	+= 3c589_cs.o
-obj-$(CONFIG_PCMCIA_3C574)	+= 3c574_cs.o
 obj-$(CONFIG_PCMCIA_FMVJ18X)	+= fmvj18x_cs.o
 obj-$(CONFIG_PCMCIA_NMCLAN)	+= nmclan_cs.o
 obj-$(CONFIG_PCMCIA_PCNET)	+= pcnet_cs.o
-- 
1.7.5.4

