From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next v2 10/71] i825xx: Move the Intel 82586/82593/82596 based drivers
Date: Sat, 30 Jul 2011 20:26:29 -0700
Message-ID: <1312082850-24914-11-git-send-email-jeffrey.t.kirsher@intel.com>
References: <1312082850-24914-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: Jeff Kirsher <jeffrey.t.kirsher@intel.com>, netdev@vger.kernel.org,
	gospo@redhat.com, sassmann@redhat.com,
	Philip Blundell <philb@gnu.org>,
	Russell King <linux@arm.linux.org.uk>,
	<aris@cathedrallabs.org>, Donald Becker <becker@scyld.com>,
	Chris Beauregard <cpbeaure@undergrad.math.uwaterloo.ca>,
	Richard Procter <rnp@paradise.net.nz>,
	Andries Brouwer <aeb@cwi.nl>,
	"M.Hipp" <hippm@informatik.uni-tuebingen.de>,
	Richard Hirst <richard@sleepie.demon.co.uk>,
	Sam Creasey <sammy@oh.verio.com>,
	Thomas Bogendoerfer <tsbogend@alpha.franken.de>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga03.intel.com ([143.182.124.21]:27579 "EHLO mga03.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753111Ab1GaD1o (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sat, 30 Jul 2011 23:27:44 -0400
In-Reply-To: <1312082850-24914-1-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Move the drivers that use the i82586/i82593/i82596 chipsets into
drivers/net/ethernet/i825xx/ and make the necessary Kconfig and
Makefile changes.  There were 4 3Com drivers which were initially
moved into 3com/, which now reside in i825xx since they all used
the i82586 chip.

CC: Philip Blundell <philb@gnu.org>
CC: Russell King <linux@arm.linux.org.uk>
CC: <aris@cathedrallabs.org>
CC: Donald Becker <becker@scyld.com>
CC: Chris Beauregard <cpbeaure@undergrad.math.uwaterloo.ca>
CC: Richard Procter <rnp@paradise.net.nz>
CC: Andries Brouwer <aeb@cwi.nl>
CC: "M.Hipp" <hippm@informatik.uni-tuebingen.de>
CC: Richard Hirst <richard@sleepie.demon.co.uk>
CC: Sam Creasey <sammy@oh.verio.com>
CC: Thomas Bogendoerfer <tsbogend@alpha.franken.de>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 MAINTAINERS                                    |    6 +-
 drivers/net/Kconfig                            |  110 +---------------
 drivers/net/Makefile                           |   13 --
 drivers/net/arm/Kconfig                        |    7 -
 drivers/net/arm/Makefile                       |    1 -
 drivers/net/ethernet/3com/Kconfig              |   45 ------
 drivers/net/ethernet/3com/Makefile             |    6 +-
 drivers/net/ethernet/Kconfig                   |    1 +
 drivers/net/ethernet/Makefile                  |    1 +
 drivers/net/ethernet/{3com => i825xx}/3c505.c  |    0
 drivers/net/ethernet/{3com => i825xx}/3c505.h  |    0
 drivers/net/ethernet/{3com => i825xx}/3c507.c  |    0
 drivers/net/ethernet/{3com => i825xx}/3c523.c  |    0
 drivers/net/ethernet/{3com => i825xx}/3c523.h  |    0
 drivers/net/ethernet/{3com => i825xx}/3c527.c  |    0
 drivers/net/ethernet/{3com => i825xx}/3c527.h  |    0
 drivers/net/{ => ethernet/i825xx}/82596.c      |    0
 drivers/net/ethernet/i825xx/Kconfig            |  178 ++++++++++++++++++++++++
 drivers/net/ethernet/i825xx/Makefile           |   20 +++
 drivers/net/{ => ethernet/i825xx}/eepro.c      |    0
 drivers/net/{ => ethernet/i825xx}/eexpress.c   |    0
 drivers/net/{ => ethernet/i825xx}/eexpress.h   |    0
 drivers/net/{arm => ethernet/i825xx}/ether1.c  |    0
 drivers/net/{arm => ethernet/i825xx}/ether1.h  |    0
 drivers/net/{ => ethernet/i825xx}/lasi_82596.c |    0
 drivers/net/{ => ethernet/i825xx}/lib82596.c   |    0
 drivers/net/{ => ethernet/i825xx}/lp486e.c     |    0
 drivers/net/{ => ethernet/i825xx}/ni52.c       |    0
 drivers/net/{ => ethernet/i825xx}/ni52.h       |    0
 drivers/net/{ => ethernet/i825xx}/sni_82596.c  |    0
 drivers/net/{ => ethernet/i825xx}/sun3_82586.c |    0
 drivers/net/{ => ethernet/i825xx}/sun3_82586.h |    0
 drivers/net/{ => ethernet/i825xx}/znet.c       |    0
 33 files changed, 205 insertions(+), 183 deletions(-)
 rename drivers/net/ethernet/{3com => i825xx}/3c505.c (100%)
 rename drivers/net/ethernet/{3com => i825xx}/3c505.h (100%)
 rename drivers/net/ethernet/{3com => i825xx}/3c507.c (100%)
 rename drivers/net/ethernet/{3com => i825xx}/3c523.c (100%)
 rename drivers/net/ethernet/{3com => i825xx}/3c523.h (100%)
 rename drivers/net/ethernet/{3com => i825xx}/3c527.c (100%)
 rename drivers/net/ethernet/{3com => i825xx}/3c527.h (100%)
 rename drivers/net/{ => ethernet/i825xx}/82596.c (100%)
 create mode 100644 drivers/net/ethernet/i825xx/Kconfig
 create mode 100644 drivers/net/ethernet/i825xx/Makefile
 rename drivers/net/{ => ethernet/i825xx}/eepro.c (100%)
 rename drivers/net/{ => ethernet/i825xx}/eexpress.c (100%)
 rename drivers/net/{ => ethernet/i825xx}/eexpress.h (100%)
 rename drivers/net/{arm => ethernet/i825xx}/ether1.c (100%)
 rename drivers/net/{arm => ethernet/i825xx}/ether1.h (100%)
 rename drivers/net/{ => ethernet/i825xx}/lasi_82596.c (100%)
 rename drivers/net/{ => ethernet/i825xx}/lib82596.c (100%)
 rename drivers/net/{ => ethernet/i825xx}/lp486e.c (100%)
 rename drivers/net/{ => ethernet/i825xx}/ni52.c (100%)
 rename drivers/net/{ => ethernet/i825xx}/ni52.h (100%)
 rename drivers/net/{ => ethernet/i825xx}/sni_82596.c (100%)
 rename drivers/net/{ => ethernet/i825xx}/sun3_82586.c (100%)
 rename drivers/net/{ => ethernet/i825xx}/sun3_82586.h (100%)
 rename drivers/net/{ => ethernet/i825xx}/znet.c (100%)

diff --git a/MAINTAINERS b/MAINTAINERS
index 31c76f4..b423be0 100644
--- a/MAINTAINERS
+++ b/MAINTAINERS
@@ -117,7 +117,7 @@ Maintainers List (try to look for most precise areas first)
 M:	Philip Blundell <philb@gnu.org>
 L:	netdev@vger.kernel.org
 S:	Maintained
-F:	drivers/net/ethernet/3com/3c505*
+F:	drivers/net/ethernet/i825xx/3c505*
 
 3C59X NETWORK DRIVER
 M:	Steffen Klassert <klassert@mathematik.tu-chemnitz.de>
@@ -1008,7 +1008,7 @@ F:	arch/arm/include/asm/hardware/ioc.h
 F:	arch/arm/include/asm/hardware/iomd.h
 F:	arch/arm/include/asm/hardware/memc.h
 F:	arch/arm/mach-rpc/
-F:	drivers/net/arm/ether*
+F:	drivers/net/arm/ether3*
 F:	drivers/scsi/arm/
 
 ARM/SHARK MACHINE SUPPORT
@@ -2497,7 +2497,7 @@ ETHEREXPRESS-16 NETWORK DRIVER
 M:	Philip Blundell <philb@gnu.org>
 L:	netdev@vger.kernel.org
 S:	Maintained
-F:	drivers/net/eexpress.*
+F:	drivers/net/ethernet/i825xx/eexpress.*
 
 ETHERNET BRIDGE
 M:	Stephen Hemminger <shemminger@linux-foundation.org>
diff --git a/drivers/net/Kconfig b/drivers/net/Kconfig
index c0aa2e3..d7d0b35 100644
--- a/drivers/net/Kconfig
+++ b/drivers/net/Kconfig
@@ -306,47 +306,6 @@ config MACMACE
 	  say Y and read the Ethernet-HOWTO, available from
 	  <http://www.tldp.org/docs.html#howto>.
 
-config MVME16x_NET
-	tristate "MVME16x Ethernet support"
-	depends on MVME16x
-	help
-	  This is the driver for the Ethernet interface on the Motorola
-	  MVME162, 166, 167, 172 and 177 boards.  Say Y here to include the
-	  driver for this chip in your kernel.
-	  To compile this driver as a module, choose M here.
-
-config BVME6000_NET
-	tristate "BVME6000 Ethernet support"
-	depends on BVME6000
-	help
-	  This is the driver for the Ethernet interface on BVME4000 and
-	  BVME6000 VME boards.  Say Y here to include the driver for this chip
-	  in your kernel.
-	  To compile this driver as a module, choose M here.
-
-config SUN3_82586
-	bool "Sun3 on-board Intel 82586 support"
-	depends on SUN3
-	help
-	  This driver enables support for the on-board Intel 82586 based
-	  Ethernet adapter found on Sun 3/1xx and 3/2xx motherboards.  Note
-	  that this driver does not support 82586-based adapters on additional
-	  VME boards.
-
-config LASI_82596
-	tristate "Lasi ethernet"
-	depends on GSC
-	help
-	  Say Y here to support the builtin Intel 82596 ethernet controller
-	  found in Hewlett-Packard PA-RISC machines with 10Mbit ethernet.
-
-config SNI_82596
-	tristate "SNI RM ethernet"
-	depends on NET_ETHERNET && SNI_RM
-	help
-	  Say Y here to support the on-board Intel 82596 ethernet controller
-	  built into SNI RM machines.
-
 config KORINA
 	tristate "Korina (IDT RC32434) Ethernet support"
 	depends on NET_ETHERNET && MIKROTIK_RB532
@@ -627,7 +586,7 @@ config NET_VENDOR_RACAL
 	depends on ISA
 	help
 	  If you have a network (Ethernet) card belonging to this class, such
-	  as the NI5010, NI5210 or NI6210, say Y and read the Ethernet-HOWTO,
+	  as the NI5010, say Y and read the Ethernet-HOWTO,
 	  available from <http://www.tldp.org/docs.html#howto>.
 
 	  Note that the answer to this question doesn't directly affect the
@@ -647,17 +606,6 @@ config NI5010
 	  To compile this driver as a module, choose M here. The module
 	  will be called ni5010.
 
-config NI52
-	tristate "NI5210 support"
-	depends on NET_VENDOR_RACAL && ISA
-	help
-	  If you have a network (Ethernet) card of this type, say Y and read
-	  the Ethernet-HOWTO, available from
-	  <http://www.tldp.org/docs.html#howto>.
-
-	  To compile this driver as a module, choose M here. The module
-	  will be called ni52.
-
 config DNET
 	tristate "Dave ethernet support (DNET)"
 	depends on NET_ETHERNET && HAS_IOMEM
@@ -725,41 +673,6 @@ config EWRK3
 	  To compile this driver as a module, choose M here. The module
 	  will be called ewrk3.
 
-config EEXPRESS
-	tristate "EtherExpress 16 support"
-	depends on NET_ISA
-	---help---
-	  If you have an EtherExpress16 network (Ethernet) card, say Y and
-	  read the Ethernet-HOWTO, available from
-	  <http://www.tldp.org/docs.html#howto>.  Note that the Intel
-	  EtherExpress16 card used to be regarded as a very poor choice
-	  because the driver was very unreliable. We now have a new driver
-	  that should do better.
-
-	  To compile this driver as a module, choose M here. The module
-	  will be called eexpress.
-
-config EEXPRESS_PRO
-	tristate "EtherExpressPro support/EtherExpress 10 (i82595) support"
-	depends on NET_ISA
-	---help---
-	  If you have a network (Ethernet) card of this type, say Y. This
-	  driver supports Intel i82595{FX,TX} based boards. Note however
-	  that the EtherExpress PRO/100 Ethernet card has its own separate
-	  driver.  Please read the Ethernet-HOWTO, available from
-	  <http://www.tldp.org/docs.html#howto>.
-
-	  To compile this driver as a module, choose M here. The module
-	  will be called eepro.
-
-config LP486E
-	tristate "LP486E on board Ethernet"
-	depends on NET_ISA
-	help
-	  Say Y here to support the 82596-based on-board Ethernet controller
-	  for the Panther motherboard, which is one of the two shipped in the
-	  Intel Professional Workstation.
-
 config ETH16I
 	tristate "ICL EtherTeam 16i/32 support"
 	depends on NET_ISA
@@ -771,16 +684,6 @@ config ETH16I
 	  To compile this driver as a module, choose M here. The module
 	  will be called eth16i.
 
-config ZNET
-	tristate "Zenith Z-Note support (EXPERIMENTAL)"
-	depends on NET_ISA && EXPERIMENTAL && ISA_DMA_API
-	help
-	  The Zenith Z-Note notebook computer has a built-in network
-	  (Ethernet) card, and this is the Linux driver for it. Note that the
-	  IBM Thinkpad 300 is compatible with the Z-Note and is also supported
-	  by this driver. Read the Ethernet-HOWTO, available from
-	  <http://www.tldp.org/docs.html#howto>.
-
 config SEEQ8005
 	tristate "SEEQ8005 support (EXPERIMENTAL)"
 	depends on NET_ISA && EXPERIMENTAL
@@ -858,17 +761,6 @@ config KSZ884X_PCI
 	  To compile this driver as a module, choose M here. The module
 	  will be called ksz884x.
 
-config APRICOT
-	tristate "Apricot Xen-II on board Ethernet"
-	depends on NET_PCI && ISA
-	help
-	  If you have a network (Ethernet) controller of this type, say Y and
-	  read the Ethernet-HOWTO, available from
-	  <http://www.tldp.org/docs.html#howto>.
-
-	  To compile this driver as a module, choose M here. The module
-	  will be called apricot.
-
 config FORCEDETH
 	tristate "nForce Ethernet support"
 	depends on NET_PCI && PCI
diff --git a/drivers/net/Makefile b/drivers/net/Makefile
index 4dfa35c..49b3e87 100644
--- a/drivers/net/Makefile
+++ b/drivers/net/Makefile
@@ -130,32 +130,19 @@ obj-$(CONFIG_MACVLAN) += macvlan.o
 obj-$(CONFIG_MACVTAP) += macvtap.o
 obj-$(CONFIG_DE600) += de600.o
 obj-$(CONFIG_DE620) += de620.o
-obj-$(CONFIG_SUN3_82586) += sun3_82586.o
 obj-$(CONFIG_DEFXX) += defxx.o
 obj-$(CONFIG_SGISEEQ) += sgiseeq.o
 obj-$(CONFIG_SGI_O2MACE_ETH) += meth.o
 obj-$(CONFIG_AT1700) += at1700.o
 obj-$(CONFIG_IBMLANA) += ibmlana.o
-obj-$(CONFIG_EEXPRESS) += eexpress.o
-obj-$(CONFIG_EEXPRESS_PRO) += eepro.o
 obj-$(CONFIG_8139CP) += 8139cp.o
 obj-$(CONFIG_8139TOO) += 8139too.o
-obj-$(CONFIG_ZNET) += znet.o
 obj-$(CONFIG_CPMAC) += cpmac.o
 obj-$(CONFIG_EWRK3) += ewrk3.o
 obj-$(CONFIG_ATP) += atp.o
 obj-$(CONFIG_NI5010) += ni5010.o
-obj-$(CONFIG_NI52) += ni52.o
-obj-$(CONFIG_APRICOT) += 82596.o
-obj-$(CONFIG_LASI_82596) += lasi_82596.o
-obj-$(CONFIG_SNI_82596) += sni_82596.o
-obj-$(CONFIG_MVME16x_NET) += 82596.o
-obj-$(CONFIG_BVME6000_NET) += 82596.o
 obj-$(CONFIG_SC92031) += sc92031.o
 
-# This is also a 82596 and should probably be merged
-obj-$(CONFIG_LP486E) += lp486e.o
-
 obj-$(CONFIG_ETH16I) += eth16i.o
 obj-$(CONFIG_EQUALIZER) += eql.o
 obj-$(CONFIG_KORINA) += korina.o
diff --git a/drivers/net/arm/Kconfig b/drivers/net/arm/Kconfig
index 715bf2a..7848b5f 100644
--- a/drivers/net/arm/Kconfig
+++ b/drivers/net/arm/Kconfig
@@ -3,13 +3,6 @@
 #  These are for Acorn's Expansion card network interfaces
 #
 
-config ARM_ETHER1
-	tristate "Acorn Ether1 support"
-	depends on ARM && ARCH_ACORN
-	help
-	  If you have an Acorn system with one of these (AKA25) network cards,
-	  you should say Y to this option if you wish to use it with Linux.
-
 config ARM_ETHER3
 	tristate "Acorn/ANT Ether3 support"
 	depends on ARM && ARCH_ACORN
diff --git a/drivers/net/arm/Makefile b/drivers/net/arm/Makefile
index f1e6150..6cca728 100644
--- a/drivers/net/arm/Makefile
+++ b/drivers/net/arm/Makefile
@@ -4,7 +4,6 @@
 #
 
 obj-$(CONFIG_ARM_ETHER3)	+= ether3.o
-obj-$(CONFIG_ARM_ETHER1)	+= ether1.o
 obj-$(CONFIG_ARM_AT91_ETHER)	+= at91_ether.o
 obj-$(CONFIG_ARM_KS8695_ETHER)	+= ks8695net.o
 obj-$(CONFIG_EP93XX_ETH)	+= ep93xx_eth.o
diff --git a/drivers/net/ethernet/3com/Kconfig b/drivers/net/ethernet/3com/Kconfig
index 7cbeae7..4d51e5b 100644
--- a/drivers/net/ethernet/3com/Kconfig
+++ b/drivers/net/ethernet/3com/Kconfig
@@ -29,29 +29,6 @@ config EL1
 	  To compile this driver as a module, choose M here. The module
 	  will be called 3c501.
 
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
-	---help---
-	  If you have a network (Ethernet) card of this type, say Y and read
-	  the Ethernet-HOWTO, available from
-	  <http://www.tldp.org/docs.html#howto>.
-
-	  To compile this driver as a module, choose M here. The module
-	  will be called 3c507.
-
 config EL3
 	tristate "3c509/3c529 (MCA)/3c579 \"EtherLink III\" support"
 	depends on NET_VENDOR_3COM && (ISA || EISA || MCA)
@@ -78,28 +55,6 @@ config 3C515
 	  To compile this driver as a module, choose M here. The module
 	  will be called 3c515.
 
-config ELMC
-	tristate "3c523 \"EtherLink/MC\" support"
-	depends on NET_VENDOR_3COM && MCA_LEGACY
-	---help---
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
-	---help---
-	  If you have a network (Ethernet) card of this type, say Y and read
-	  the Ethernet-HOWTO, available from
-	  <http://www.tldp.org/docs.html#howto>.
-
-	  To compile this driver as a module, choose M here. The module
-	  will be called 3c527.
-
 config PCMCIA_3C574
 	tristate "3Com 3c574 PCMCIA support"
 	depends on NET_VENDOR_3COM && PCMCIA
diff --git a/drivers/net/ethernet/3com/Makefile b/drivers/net/ethernet/3com/Makefile
index ba27c7e..6f241fe 100644
--- a/drivers/net/ethernet/3com/Makefile
+++ b/drivers/net/ethernet/3com/Makefile
@@ -3,14 +3,10 @@
 #
 
 obj-$(CONFIG_EL1) += 3c501.o
-obj-$(CONFIG_ELPLUS) += 3c505.o
-obj-$(CONFIG_EL16) += 3c507.o
 obj-$(CONFIG_EL3) += 3c509.o
 obj-$(CONFIG_3C515) += 3c515.o
-obj-$(CONFIG_ELMC) += 3c523.o
-obj-$(CONFIG_ELMC_II) += 3c527.o
-obj-$(CONFIG_PCMCIA_3C589) += 3c589_cs.o
 obj-$(CONFIG_PCMCIA_3C574) += 3c574_cs.o
+obj-$(CONFIG_PCMCIA_3C589) += 3c589_cs.o
 obj-$(CONFIG_VORTEX) += 3c59x.o
 obj-$(CONFIG_ACENIC) += acenic.o
 obj-$(CONFIG_TYPHOON) += typhoon.o
diff --git a/drivers/net/ethernet/Kconfig b/drivers/net/ethernet/Kconfig
index ed5836c..d0a8fa8 100644
--- a/drivers/net/ethernet/Kconfig
+++ b/drivers/net/ethernet/Kconfig
@@ -17,6 +17,7 @@ source "drivers/net/ethernet/amd/Kconfig"
 source "drivers/net/ethernet/broadcom/Kconfig"
 source "drivers/net/ethernet/chelsio/Kconfig"
 source "drivers/net/ethernet/intel/Kconfig"
+source "drivers/net/ethernet/i825xx/Kconfig"
 source "drivers/net/ethernet/qlogic/Kconfig"
 source "drivers/net/ethernet/smsc/Kconfig"
 
diff --git a/drivers/net/ethernet/Makefile b/drivers/net/ethernet/Makefile
index 983fd27..6d3276a 100644
--- a/drivers/net/ethernet/Makefile
+++ b/drivers/net/ethernet/Makefile
@@ -8,5 +8,6 @@ obj-$(CONFIG_NET_VENDOR_AMD) += amd/
 obj-$(CONFIG_NET_VENDOR_BROADCOM) += broadcom/
 obj-$(CONFIG_NET_VENDOR_CHELSIO) += chelsio/
 obj-$(CONFIG_NET_VENDOR_INTEL) += intel/
+obj-$(CONFIG_NET_VENDOR_I825XX) += i825xx/
 obj-$(CONFIG_NET_VENDOR_QLOGIC) += qlogic/
 obj-$(CONFIG_NET_VENDOR_SMSC) += smsc/
diff --git a/drivers/net/ethernet/3com/3c505.c b/drivers/net/ethernet/i825xx/3c505.c
similarity index 100%
rename from drivers/net/ethernet/3com/3c505.c
rename to drivers/net/ethernet/i825xx/3c505.c
diff --git a/drivers/net/ethernet/3com/3c505.h b/drivers/net/ethernet/i825xx/3c505.h
similarity index 100%
rename from drivers/net/ethernet/3com/3c505.h
rename to drivers/net/ethernet/i825xx/3c505.h
diff --git a/drivers/net/ethernet/3com/3c507.c b/drivers/net/ethernet/i825xx/3c507.c
similarity index 100%
rename from drivers/net/ethernet/3com/3c507.c
rename to drivers/net/ethernet/i825xx/3c507.c
diff --git a/drivers/net/ethernet/3com/3c523.c b/drivers/net/ethernet/i825xx/3c523.c
similarity index 100%
rename from drivers/net/ethernet/3com/3c523.c
rename to drivers/net/ethernet/i825xx/3c523.c
diff --git a/drivers/net/ethernet/3com/3c523.h b/drivers/net/ethernet/i825xx/3c523.h
similarity index 100%
rename from drivers/net/ethernet/3com/3c523.h
rename to drivers/net/ethernet/i825xx/3c523.h
diff --git a/drivers/net/ethernet/3com/3c527.c b/drivers/net/ethernet/i825xx/3c527.c
similarity index 100%
rename from drivers/net/ethernet/3com/3c527.c
rename to drivers/net/ethernet/i825xx/3c527.c
diff --git a/drivers/net/ethernet/3com/3c527.h b/drivers/net/ethernet/i825xx/3c527.h
similarity index 100%
rename from drivers/net/ethernet/3com/3c527.h
rename to drivers/net/ethernet/i825xx/3c527.h
diff --git a/drivers/net/82596.c b/drivers/net/ethernet/i825xx/82596.c
similarity index 100%
rename from drivers/net/82596.c
rename to drivers/net/ethernet/i825xx/82596.c
diff --git a/drivers/net/ethernet/i825xx/Kconfig b/drivers/net/ethernet/i825xx/Kconfig
new file mode 100644
index 0000000..e649be1
--- /dev/null
+++ b/drivers/net/ethernet/i825xx/Kconfig
@@ -0,0 +1,178 @@
+#
+# Intel 82596/82593/82596 network device configuration
+#
+
+config NET_VENDOR_I825XX
+	bool "Intel (82586/82593/82596) devices"
+	depends on NET_VENDOR_INTEL && (ISA || ISA_DMA_API || ARM || \
+		   ARCH_ACORN || MCA || MCA_LEGACY || SNI_RM || SUN3 || \
+		   GSC || BVME6000 || MVME16x || EXPERIMENTAL)
+	---help---
+	  If you have a network (Ethernet) card belonging to this class, say Y
+	  and read the Ethernet-HOWTO, available from
+	  <http://www.tldp.org/docs.html#howto>.
+
+	  Note that the answer to this question does not directly affect the
+	  kernel: saying N will just cause the configurator to skip all
+	  the questions about these devices. If you say Y, you will be asked for
+	  your specific card in the following questions.
+
+config ELPLUS
+	tristate "3c505 \"EtherLink Plus\" support"
+	depends on NET_VENDOR_I825XX && ISA && ISA_DMA_API
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
+	depends on NET_VENDOR_I825XX && ISA && EXPERIMENTAL
+	---help---
+	  If you have a network (Ethernet) card of this type, say Y and read
+	  the Ethernet-HOWTO, available from
+	  <http://www.tldp.org/docs.html#howto>.
+
+	  To compile this driver as a module, choose M here. The module
+	  will be called 3c507.
+
+config ELMC
+	tristate "3c523 \"EtherLink/MC\" support"
+	depends on NET_VENDOR_I825XX && MCA_LEGACY
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
+	depends on NET_VENDOR_I825XX && MCA && MCA_LEGACY
+	---help---
+	  If you have a network (Ethernet) card of this type, say Y and read
+	  the Ethernet-HOWTO, available from
+	  <http://www.tldp.org/docs.html#howto>.
+
+	  To compile this driver as a module, choose M here. The module
+	  will be called 3c527.
+
+config ARM_ETHER1
+	tristate "Acorn Ether1 support"
+	depends on NET_VENDOR_I825XX && ARM && ARCH_ACORN
+	---help---
+	  If you have an Acorn system with one of these (AKA25) network cards,
+	  you should say Y to this option if you wish to use it with Linux.
+
+config APRICOT
+	tristate "Apricot Xen-II on board Ethernet"
+	depends on NET_VENDOR_I825XX && ISA
+	---help---
+	  If you have a network (Ethernet) controller of this type, say Y and
+	  read the Ethernet-HOWTO, available from
+	  <http://www.tldp.org/docs.html#howto>.
+
+	  To compile this driver as a module, choose M here. The module
+	  will be called apricot.
+
+config BVME6000_NET
+	tristate "BVME6000 Ethernet support"
+	depends on NET_VENDOR_I825XX && BVME6000MVME16x
+	---help---
+	  This is the driver for the Ethernet interface on BVME4000 and
+	  BVME6000 VME boards.  Say Y here to include the driver for this chip
+	  in your kernel.
+	  To compile this driver as a module, choose M here.
+
+config EEXPRESS
+	tristate "EtherExpress 16 support"
+	depends on NET_VENDOR_I825XX
+	---help---
+	  If you have an EtherExpress16 network (Ethernet) card, say Y and
+	  read the Ethernet-HOWTO, available from
+	  <http://www.tldp.org/docs.html#howto>.  Note that the Intel
+	  EtherExpress16 card used to be regarded as a very poor choice
+	  because the driver was very unreliable. We now have a new driver
+	  that should do better.
+
+	  To compile this driver as a module, choose M here. The module
+	  will be called eexpress.
+
+config EEXPRESS_PRO
+	tristate "EtherExpressPro support/EtherExpress 10 (i82595) support"
+	depends on NET_VENDOR_I825XX
+	---help---
+	  If you have a network (Ethernet) card of this type, say Y. This
+	  driver supports Intel i82595{FX,TX} based boards. Note however
+	  that the EtherExpress PRO/100 Ethernet card has its own separate
+	  driver.  Please read the Ethernet-HOWTO, available from
+	  <http://www.tldp.org/docs.html#howto>.
+
+	  To compile this driver as a module, choose M here. The module
+	  will be called eepro.
+
+config LASI_82596
+	tristate "Lasi ethernet"
+	depends on NET_VENDOR_I825XX && GSC
+	---help---
+	  Say Y here to support the builtin Intel 82596 ethernet controller
+	  found in Hewlett-Packard PA-RISC machines with 10Mbit ethernet.
+
+config LP486E
+	tristate "LP486E on board Ethernet"
+	depends on NET_VENDOR_I825XX
+	---help---
+	  Say Y here to support the 82596-based on-board Ethernet controller
+	  for the Panther motherboard, which is one of the two shipped in the
+	  Intel Professional Workstation.
+
+config MVME16x_NET
+	tristate "MVME16x Ethernet support"
+	depends on NET_VENDOR_I825XX && MVME16x
+	---help---
+	  This is the driver for the Ethernet interface on the Motorola
+	  MVME162, 166, 167, 172 and 177 boards.  Say Y here to include the
+	  driver for this chip in your kernel.
+	  To compile this driver as a module, choose M here.
+
+config NI52
+	tristate "NI5210 support"
+	depends on NET_VENDOR_I825XX && ISA
+	---help---
+	  If you have a network (Ethernet) card of this type, say Y and read
+	  the Ethernet-HOWTO, available from
+	  <http://www.tldp.org/docs.html#howto>.
+
+	  To compile this driver as a module, choose M here. The module
+	  will be called ni52.
+
+config SNI_82596
+	tristate "SNI RM ethernet"
+	depends on NET_VENDOR_I825XX && SNI_RM
+	---help---
+	  Say Y here to support the on-board Intel 82596 ethernet controller
+	  built into SNI RM machines.
+
+config SUN3_82586
+	bool "Sun3 on-board Intel 82586 support"
+	depends on NET_VENDOR_I825XX && SUN3
+	---help---
+	  This driver enables support for the on-board Intel 82586 based
+	  Ethernet adapter found on Sun 3/1xx and 3/2xx motherboards.  Note
+	  that this driver does not support 82586-based adapters on additional
+	  VME boards.
+
+config ZNET
+	tristate "Zenith Z-Note support (EXPERIMENTAL)"
+	depends on NET_VENDOR_I825XX && EXPERIMENTAL && ISA_DMA_API
+	---help---
+	  The Zenith Z-Note notebook computer has a built-in network
+	  (Ethernet) card, and this is the Linux driver for it. Note that the
+	  IBM Thinkpad 300 is compatible with the Z-Note and is also supported
+	  by this driver. Read the Ethernet-HOWTO, available from
+	  <http://www.tldp.org/docs.html#howto>.
diff --git a/drivers/net/ethernet/i825xx/Makefile b/drivers/net/ethernet/i825xx/Makefile
new file mode 100644
index 0000000..f68a369
--- /dev/null
+++ b/drivers/net/ethernet/i825xx/Makefile
@@ -0,0 +1,20 @@
+#
+# Makefile for the Intel 82586/82593/82596 chipset device drivers.
+#
+
+obj-$(CONFIG_ARM_ETHER1) += ether1.o
+obj-$(CONFIG_EEXPRESS) += eexpress.o
+obj-$(CONFIG_EEXPRESS_PRO) += eepro.o
+obj-$(CONFIG_ELPLUS) += 3c505.o
+obj-$(CONFIG_EL16) += 3c507.o
+obj-$(CONFIG_ELMC) += 3c523.o
+obj-$(CONFIG_ELMC_II) += 3c527.o
+obj-$(CONFIG_LP486E) += lp486e.o
+obj-$(CONFIG_NI52) += ni52.o
+obj-$(CONFIG_SUN3_82586) += sun3_82586.o
+obj-$(CONFIG_ZNET) += znet.o
+obj-$(CONFIG_APRICOT) += 82596.o
+obj-$(CONFIG_LASI_82596) += lasi_82596.o
+obj-$(CONFIG_SNI_82596) += sni_82596.o
+obj-$(CONFIG_MVME16x_NET) += 82596.o
+obj-$(CONFIG_BVME6000_NET) += 82596.o
diff --git a/drivers/net/eepro.c b/drivers/net/ethernet/i825xx/eepro.c
similarity index 100%
rename from drivers/net/eepro.c
rename to drivers/net/ethernet/i825xx/eepro.c
diff --git a/drivers/net/eexpress.c b/drivers/net/ethernet/i825xx/eexpress.c
similarity index 100%
rename from drivers/net/eexpress.c
rename to drivers/net/ethernet/i825xx/eexpress.c
diff --git a/drivers/net/eexpress.h b/drivers/net/ethernet/i825xx/eexpress.h
similarity index 100%
rename from drivers/net/eexpress.h
rename to drivers/net/ethernet/i825xx/eexpress.h
diff --git a/drivers/net/arm/ether1.c b/drivers/net/ethernet/i825xx/ether1.c
similarity index 100%
rename from drivers/net/arm/ether1.c
rename to drivers/net/ethernet/i825xx/ether1.c
diff --git a/drivers/net/arm/ether1.h b/drivers/net/ethernet/i825xx/ether1.h
similarity index 100%
rename from drivers/net/arm/ether1.h
rename to drivers/net/ethernet/i825xx/ether1.h
diff --git a/drivers/net/lasi_82596.c b/drivers/net/ethernet/i825xx/lasi_82596.c
similarity index 100%
rename from drivers/net/lasi_82596.c
rename to drivers/net/ethernet/i825xx/lasi_82596.c
diff --git a/drivers/net/lib82596.c b/drivers/net/ethernet/i825xx/lib82596.c
similarity index 100%
rename from drivers/net/lib82596.c
rename to drivers/net/ethernet/i825xx/lib82596.c
diff --git a/drivers/net/lp486e.c b/drivers/net/ethernet/i825xx/lp486e.c
similarity index 100%
rename from drivers/net/lp486e.c
rename to drivers/net/ethernet/i825xx/lp486e.c
diff --git a/drivers/net/ni52.c b/drivers/net/ethernet/i825xx/ni52.c
similarity index 100%
rename from drivers/net/ni52.c
rename to drivers/net/ethernet/i825xx/ni52.c
diff --git a/drivers/net/ni52.h b/drivers/net/ethernet/i825xx/ni52.h
similarity index 100%
rename from drivers/net/ni52.h
rename to drivers/net/ethernet/i825xx/ni52.h
diff --git a/drivers/net/sni_82596.c b/drivers/net/ethernet/i825xx/sni_82596.c
similarity index 100%
rename from drivers/net/sni_82596.c
rename to drivers/net/ethernet/i825xx/sni_82596.c
diff --git a/drivers/net/sun3_82586.c b/drivers/net/ethernet/i825xx/sun3_82586.c
similarity index 100%
rename from drivers/net/sun3_82586.c
rename to drivers/net/ethernet/i825xx/sun3_82586.c
diff --git a/drivers/net/sun3_82586.h b/drivers/net/ethernet/i825xx/sun3_82586.h
similarity index 100%
rename from drivers/net/sun3_82586.h
rename to drivers/net/ethernet/i825xx/sun3_82586.h
diff --git a/drivers/net/znet.c b/drivers/net/ethernet/i825xx/znet.c
similarity index 100%
rename from drivers/net/znet.c
rename to drivers/net/ethernet/i825xx/znet.c
-- 
1.7.6

