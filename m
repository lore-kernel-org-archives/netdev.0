From: Paul Gortmaker <paul.gortmaker@windriver.com>
Subject: [PATCH 06/15] netdev: relocate i8258x and i8259x based drivers to legacy
Date: Thu, 28 Oct 2010 21:19:10 -0400
Message-ID: <1288315159-1350-7-git-send-email-paul.gortmaker@windriver.com>
References: <1288315159-1350-1-git-send-email-paul.gortmaker@windriver.com>
Cc: netdev@vger.kernel.org
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.windriver.com ([147.11.1.11]:33974 "EHLO
	mail.windriver.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1758750Ab0J2BTa (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 28 Oct 2010 21:19:30 -0400
In-Reply-To: <1288315159-1350-1-git-send-email-paul.gortmaker@windriver.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This chipset was predominately deployed on hardware in the early
to mid 1990's -- on ISA bus hardware and similar.  Move these old
drivers to the legacy dir.

Signed-off-by: Paul Gortmaker <paul.gortmaker@windriver.com>
---
 drivers/net/Kconfig                   |  133 ---------------------------------
 drivers/net/Makefile                  |   16 ----
 drivers/net/{ => legacy}/3c505.c      |    0
 drivers/net/{ => legacy}/3c505.h      |    0
 drivers/net/{ => legacy}/3c507.c      |    0
 drivers/net/{ => legacy}/3c523.c      |    0
 drivers/net/{ => legacy}/3c523.h      |    0
 drivers/net/{ => legacy}/3c527.c      |    0
 drivers/net/{ => legacy}/3c527.h      |    0
 drivers/net/{ => legacy}/82596.c      |    0
 drivers/net/legacy/Kconfig            |  133 +++++++++++++++++++++++++++++++++
 drivers/net/legacy/Makefile           |   17 ++++
 drivers/net/{ => legacy}/eepro.c      |    0
 drivers/net/{ => legacy}/eexpress.c   |    0
 drivers/net/{ => legacy}/eexpress.h   |    0
 drivers/net/{ => legacy}/lasi_82596.c |    0
 drivers/net/{ => legacy}/lib82596.c   |    0
 drivers/net/{ => legacy}/lp486e.c     |    0
 drivers/net/{ => legacy}/ni52.c       |    0
 drivers/net/{ => legacy}/ni52.h       |    0
 drivers/net/{ => legacy}/sni_82596.c  |    0
 drivers/net/{ => legacy}/znet.c       |    0
 22 files changed, 150 insertions(+), 149 deletions(-)
 rename drivers/net/{ => legacy}/3c505.c (100%)
 rename drivers/net/{ => legacy}/3c505.h (100%)
 rename drivers/net/{ => legacy}/3c507.c (100%)
 rename drivers/net/{ => legacy}/3c523.c (100%)
 rename drivers/net/{ => legacy}/3c523.h (100%)
 rename drivers/net/{ => legacy}/3c527.c (100%)
 rename drivers/net/{ => legacy}/3c527.h (100%)
 rename drivers/net/{ => legacy}/82596.c (100%)
 rename drivers/net/{ => legacy}/eepro.c (100%)
 rename drivers/net/{ => legacy}/eexpress.c (100%)
 rename drivers/net/{ => legacy}/eexpress.h (100%)
 rename drivers/net/{ => legacy}/lasi_82596.c (100%)
 rename drivers/net/{ => legacy}/lib82596.c (100%)
 rename drivers/net/{ => legacy}/lp486e.c (100%)
 rename drivers/net/{ => legacy}/ni52.c (100%)
 rename drivers/net/{ => legacy}/ni52.h (100%)
 rename drivers/net/{ => legacy}/sni_82596.c (100%)
 rename drivers/net/{ => legacy}/znet.c (100%)

diff --git a/drivers/net/Kconfig b/drivers/net/Kconfig
index fb58ea7..db8261c 100644
--- a/drivers/net/Kconfig
+++ b/drivers/net/Kconfig
@@ -409,24 +409,6 @@ config MVME147_NET
 	  driver for this chip in your kernel.
 	  To compile this driver as a module, choose M here.
 
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
 config ATARILANCE
 	tristate "Atari Lance support"
 	depends on ATARI
@@ -443,20 +425,6 @@ config HPLANCE
 	  If you want to use the builtin "LANCE" Ethernet controller on an
 	  HP300 machine, say Y here.
 
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
@@ -631,29 +599,6 @@ config EL2
 	  To compile this driver as a module, choose M here. The module
 	  will be called 3c503.
 
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
 config EL3
 	tristate "3c509/3c529 (MCA)/3c579 \"EtherLink III\" support"
 	depends on NET_VENDOR_3COM && (ISA || EISA || MCA)
@@ -680,28 +625,6 @@ config 3C515
 	  To compile this driver as a module, choose M here. The module
 	  will be called 3c515.
 
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
 config VORTEX
 	tristate "3c590/3c900 series (592/595/597) \"Vortex/Boomerang\" support"
 	depends on NET_VENDOR_3COM && (PCI || EISA)
@@ -1057,17 +980,6 @@ config NI5010
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
 config NI65
 	tristate "NI6510 support"
 	depends on NET_VENDOR_RACAL && ISA && ISA_DMA_API
@@ -1144,33 +1056,6 @@ config E2100
 	  To compile this driver as a module, choose M here. The module
 	  will be called e2100.
 
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
 config HPLAN_PLUS
 	tristate "HP PCLAN+ (27247B and 27252A) support"
 	depends on NET_ISA
@@ -1195,14 +1080,6 @@ config HPLAN
 	  To compile this driver as a module, choose M here. The module
 	  will be called hp.
 
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
@@ -1234,16 +1111,6 @@ config NE2000
 	  To compile this driver as a module, choose M here. The module
 	  will be called ne.
 
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
diff --git a/drivers/net/Makefile b/drivers/net/Makefile
index f6536fe..3fd125e 100644
--- a/drivers/net/Makefile
+++ b/drivers/net/Makefile
@@ -178,34 +178,18 @@ obj-$(CONFIG_LANCE) += lance.o
 obj-$(CONFIG_SGISEEQ) += sgiseeq.o
 obj-$(CONFIG_SGI_O2MACE_ETH) += meth.o
 obj-$(CONFIG_AT1700) += at1700.o
-obj-$(CONFIG_EL16) += 3c507.o
-obj-$(CONFIG_ELMC) += 3c523.o
 obj-$(CONFIG_IBMLANA) += ibmlana.o
-obj-$(CONFIG_ELMC_II) += 3c527.o
 obj-$(CONFIG_EL3) += 3c509.o
 obj-$(CONFIG_3C515) += 3c515.o
-obj-$(CONFIG_EEXPRESS) += eexpress.o
-obj-$(CONFIG_EEXPRESS_PRO) += eepro.o
 obj-$(CONFIG_8139CP) += 8139cp.o
 obj-$(CONFIG_8139TOO) += 8139too.o
-obj-$(CONFIG_ZNET) += znet.o
 obj-$(CONFIG_CPMAC) += cpmac.o
 obj-$(CONFIG_ATP) += atp.o
 obj-$(CONFIG_NI5010) += ni5010.o
-obj-$(CONFIG_NI52) += ni52.o
 obj-$(CONFIG_NI65) += ni65.o
-obj-$(CONFIG_ELPLUS) += 3c505.o
 obj-$(CONFIG_AC3200) += ac3200.o 8390.o
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
 obj-$(CONFIG_ZORRO8390) += zorro8390.o 8390.o
 obj-$(CONFIG_HPLANCE) += hplance.o 7990.o
diff --git a/drivers/net/3c505.c b/drivers/net/legacy/3c505.c
similarity index 100%
rename from drivers/net/3c505.c
rename to drivers/net/legacy/3c505.c
diff --git a/drivers/net/3c505.h b/drivers/net/legacy/3c505.h
similarity index 100%
rename from drivers/net/3c505.h
rename to drivers/net/legacy/3c505.h
diff --git a/drivers/net/3c507.c b/drivers/net/legacy/3c507.c
similarity index 100%
rename from drivers/net/3c507.c
rename to drivers/net/legacy/3c507.c
diff --git a/drivers/net/3c523.c b/drivers/net/legacy/3c523.c
similarity index 100%
rename from drivers/net/3c523.c
rename to drivers/net/legacy/3c523.c
diff --git a/drivers/net/3c523.h b/drivers/net/legacy/3c523.h
similarity index 100%
rename from drivers/net/3c523.h
rename to drivers/net/legacy/3c523.h
diff --git a/drivers/net/3c527.c b/drivers/net/legacy/3c527.c
similarity index 100%
rename from drivers/net/3c527.c
rename to drivers/net/legacy/3c527.c
diff --git a/drivers/net/3c527.h b/drivers/net/legacy/3c527.h
similarity index 100%
rename from drivers/net/3c527.h
rename to drivers/net/legacy/3c527.h
diff --git a/drivers/net/82596.c b/drivers/net/legacy/82596.c
similarity index 100%
rename from drivers/net/82596.c
rename to drivers/net/legacy/82596.c
diff --git a/drivers/net/legacy/Kconfig b/drivers/net/legacy/Kconfig
index ac163cc..c84f87c 100644
--- a/drivers/net/legacy/Kconfig
+++ b/drivers/net/legacy/Kconfig
@@ -129,3 +129,136 @@ config DEFXX_MMIO
 	  so MMIO is always used for these (DEFTA) adapters.
 
 	  If unsure, say N.
+
+config MVME16x_NET
+	tristate "MVME16x Ethernet support"
+	depends on MVME16x
+	help
+	  This is the driver for the Ethernet interface on the Motorola
+	  MVME162, 166, 167, 172 and 177 boards.  Say Y here to include the
+	  driver for this chip in your kernel.
+	  To compile this driver as a module, choose M here.
+
+config BVME6000_NET
+	tristate "BVME6000 Ethernet support"
+	depends on BVME6000
+	help
+	  This is the driver for the Ethernet interface on BVME4000 and
+	  BVME6000 VME boards.  Say Y here to include the driver for this chip
+	  in your kernel.
+	  To compile this driver as a module, choose M here.
+
+config LASI_82596
+	tristate "Lasi ethernet"
+	depends on GSC
+	help
+	  Say Y here to support the builtin Intel 82596 ethernet controller
+	  found in Hewlett-Packard PA-RISC machines with 10Mbit ethernet.
+
+config SNI_82596
+	tristate "SNI RM ethernet"
+	depends on NET_ETHERNET && SNI_RM
+	help
+	  Say Y here to support the on-board Intel 82596 ethernet controller
+	  built into SNI RM machines.
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
+	help
+	  If you have a network (Ethernet) card of this type, say Y and read
+	  the Ethernet-HOWTO, available from
+	  <http://www.tldp.org/docs.html#howto>.
+
+	  To compile this driver as a module, choose M here. The module
+	  will be called 3c507.
+
+config ELMC
+	tristate "3c523 \"EtherLink/MC\" support"
+	depends on NET_VENDOR_3COM && MCA_LEGACY
+	help
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
+	help
+	  If you have a network (Ethernet) card of this type, say Y and read
+	  the Ethernet-HOWTO, available from
+	  <http://www.tldp.org/docs.html#howto>.
+
+	  To compile this driver as a module, choose M here. The module
+	  will be called 3c527.
+
+config EEXPRESS
+	tristate "EtherExpress 16 support"
+	depends on NET_ISA
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
+	depends on NET_ISA
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
+config LP486E
+	tristate "LP486E on board Ethernet"
+	depends on NET_ISA
+	help
+	  Say Y here to support the 82596-based on-board Ethernet controller
+	  for the Panther motherboard, which is one of the two shipped in the
+	  Intel Professional Workstation.
+
+config ZNET
+	tristate "Zenith Z-Note support (EXPERIMENTAL)"
+	depends on NET_ISA && EXPERIMENTAL && ISA_DMA_API
+	help
+	  The Zenith Z-Note notebook computer has a built-in network
+	  (Ethernet) card, and this is the Linux driver for it. Note that the
+	  IBM Thinkpad 300 is compatible with the Z-Note and is also supported
+	  by this driver. Read the Ethernet-HOWTO, available from
+	  <http://www.tldp.org/docs.html#howto>.
+
+config NI52
+	tristate "NI5210 support"
+	depends on NET_VENDOR_RACAL && ISA
+	help
+	  If you have a network (Ethernet) card of this type, say Y and read
+	  the Ethernet-HOWTO, available from
+	  <http://www.tldp.org/docs.html#howto>.
+
+	  To compile this driver as a module, choose M here. The module
+	  will be called ni52.
diff --git a/drivers/net/legacy/Makefile b/drivers/net/legacy/Makefile
index 7ab3669..b605648 100644
--- a/drivers/net/legacy/Makefile
+++ b/drivers/net/legacy/Makefile
@@ -13,3 +13,20 @@ obj-$(CONFIG_DEFXX) += defxx.o
 obj-$(CONFIG_DEPCA) += depca.o
 obj-$(CONFIG_EWRK3) += ewrk3.o
 obj-$(CONFIG_DECLANCE) += declance.o
+
+# 825xx based cards
+obj-$(CONFIG_APRICOT) += 82596.o
+obj-$(CONFIG_BVME6000_NET) += 82596.o
+obj-$(CONFIG_ELPLUS) += 3c505.o
+obj-$(CONFIG_EL16) += 3c507.o
+obj-$(CONFIG_ELMC) += 3c523.o
+obj-$(CONFIG_ELMC_II) += 3c527.o
+obj-$(CONFIG_EEXPRESS) += eexpress.o
+obj-$(CONFIG_EEXPRESS_PRO) += eepro.o
+obj-$(CONFIG_LASI_82596) += lasi_82596.o
+obj-$(CONFIG_LP486E) += lp486e.o
+obj-$(CONFIG_MVME16x_NET) += 82596.o
+obj-$(CONFIG_NI52) += ni52.o
+obj-$(CONFIG_SNI_82596) += sni_82596.o
+obj-$(CONFIG_ZNET) += znet.o
+
diff --git a/drivers/net/eepro.c b/drivers/net/legacy/eepro.c
similarity index 100%
rename from drivers/net/eepro.c
rename to drivers/net/legacy/eepro.c
diff --git a/drivers/net/eexpress.c b/drivers/net/legacy/eexpress.c
similarity index 100%
rename from drivers/net/eexpress.c
rename to drivers/net/legacy/eexpress.c
diff --git a/drivers/net/eexpress.h b/drivers/net/legacy/eexpress.h
similarity index 100%
rename from drivers/net/eexpress.h
rename to drivers/net/legacy/eexpress.h
diff --git a/drivers/net/lasi_82596.c b/drivers/net/legacy/lasi_82596.c
similarity index 100%
rename from drivers/net/lasi_82596.c
rename to drivers/net/legacy/lasi_82596.c
diff --git a/drivers/net/lib82596.c b/drivers/net/legacy/lib82596.c
similarity index 100%
rename from drivers/net/lib82596.c
rename to drivers/net/legacy/lib82596.c
diff --git a/drivers/net/lp486e.c b/drivers/net/legacy/lp486e.c
similarity index 100%
rename from drivers/net/lp486e.c
rename to drivers/net/legacy/lp486e.c
diff --git a/drivers/net/ni52.c b/drivers/net/legacy/ni52.c
similarity index 100%
rename from drivers/net/ni52.c
rename to drivers/net/legacy/ni52.c
diff --git a/drivers/net/ni52.h b/drivers/net/legacy/ni52.h
similarity index 100%
rename from drivers/net/ni52.h
rename to drivers/net/legacy/ni52.h
diff --git a/drivers/net/sni_82596.c b/drivers/net/legacy/sni_82596.c
similarity index 100%
rename from drivers/net/sni_82596.c
rename to drivers/net/legacy/sni_82596.c
diff --git a/drivers/net/znet.c b/drivers/net/legacy/znet.c
similarity index 100%
rename from drivers/net/znet.c
rename to drivers/net/legacy/znet.c
-- 
1.7.3.2.146.g2d444

