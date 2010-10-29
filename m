From: Paul Gortmaker <paul.gortmaker@windriver.com>
Subject: [PATCH 07/15] lance: relocate legacy 7990 based drivers to legacy
Date: Thu, 28 Oct 2010 21:19:11 -0400
Message-ID: <1288315159-1350-8-git-send-email-paul.gortmaker@windriver.com>
References: <1288315159-1350-1-git-send-email-paul.gortmaker@windriver.com>
Cc: netdev@vger.kernel.org
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.windriver.com ([147.11.1.11]:33977 "EHLO
	mail.windriver.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1758769Ab0J2BTa (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 28 Oct 2010 21:19:30 -0400
In-Reply-To: <1288315159-1350-1-git-send-email-paul.gortmaker@windriver.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The original ISA 7990 chip was good for its day, given that it
had bus mastering capabilities instead of the PIO or shared memory
modes of the other hardware devices of the day.  However it is now
also no longer really relevant and so move the related drivers off
to the legacy directory.

I've left sunlance where it is, since it is still in both sparc
defconfig files.

Signed-off-by: Paul Gortmaker <paul.gortmaker@windriver.com>
---
 drivers/net/Kconfig                   |   59 ---------------------------------
 drivers/net/Makefile                  |    6 ---
 drivers/net/{ => legacy}/7990.c       |    0
 drivers/net/{ => legacy}/7990.h       |    0
 drivers/net/legacy/Kconfig            |   59 +++++++++++++++++++++++++++++++++
 drivers/net/legacy/Makefile           |    7 ++++
 drivers/net/{ => legacy}/ariadne.c    |    0
 drivers/net/{ => legacy}/ariadne.h    |    0
 drivers/net/{ => legacy}/atarilance.c |    0
 drivers/net/{ => legacy}/hplance.c    |    0
 drivers/net/{ => legacy}/hplance.h    |    0
 drivers/net/{ => legacy}/lance.c      |    0
 drivers/net/{ => legacy}/mvme147.c    |    0
 drivers/net/{ => legacy}/ni65.c       |    0
 drivers/net/{ => legacy}/ni65.h       |    0
 15 files changed, 66 insertions(+), 65 deletions(-)
 rename drivers/net/{ => legacy}/7990.c (100%)
 rename drivers/net/{ => legacy}/7990.h (100%)
 rename drivers/net/{ => legacy}/ariadne.c (100%)
 rename drivers/net/{ => legacy}/ariadne.h (100%)
 rename drivers/net/{ => legacy}/atarilance.c (100%)
 rename drivers/net/{ => legacy}/hplance.c (100%)
 rename drivers/net/{ => legacy}/hplance.h (100%)
 rename drivers/net/{ => legacy}/lance.c (100%)
 rename drivers/net/{ => legacy}/mvme147.c (100%)
 rename drivers/net/{ => legacy}/ni65.c (100%)
 rename drivers/net/{ => legacy}/ni65.h (100%)

diff --git a/drivers/net/Kconfig b/drivers/net/Kconfig
index db8261c..6ef5848 100644
--- a/drivers/net/Kconfig
+++ b/drivers/net/Kconfig
@@ -299,16 +299,6 @@ config BMAC
 	  To compile this driver as a module, choose M here: the module
 	  will be called bmac.
 
-config ARIADNE
-	tristate "Ariadne support"
-	depends on ZORRO
-	help
-	  If you have a Village Tronic Ariadne Ethernet adapter, say Y.
-	  Otherwise, say N.
-
-	  To compile this driver as a module, choose M here: the module
-	  will be called ariadne.
-
 config A2065
 	tristate "A2065 support"
 	depends on ZORRO
@@ -399,32 +389,6 @@ config MACMACE
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
-config ATARILANCE
-	tristate "Atari Lance support"
-	depends on ATARI
-	help
-	  Say Y to include support for several Atari Ethernet adapters based
-	  on the AMD Lance chipset: RieblCard (with or without battery), or
-	  PAMCard VME (also the version by Rhotron, with different addresses).
-
-config HPLANCE
-	bool "HP on-board LANCE support"
-	depends on DIO
-	select CRC32
-	help
-	  If you want to use the builtin "LANCE" Ethernet controller on an
-	  HP300 machine, say Y here.
-
 config KORINA
 	tristate "Korina (IDT RC32434) Ethernet support"
 	depends on NET_ETHERNET && MIKROTIK_RB532
@@ -665,18 +629,6 @@ config TYPHOON
 	  To compile this driver as a module, choose M here. The module
 	  will be called typhoon.
 
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
@@ -980,17 +932,6 @@ config NI5010
 	  To compile this driver as a module, choose M here. The module
 	  will be called ni5010.
 
-config NI65
-	tristate "NI6510 support"
-	depends on NET_VENDOR_RACAL && ISA && ISA_DMA_API
-	help
-	  If you have a network (Ethernet) card of this type, say Y and read
-	  the Ethernet-HOWTO, available from
-	  <http://www.tldp.org/docs.html#howto>.
-
-	  To compile this driver as a module, choose M here. The module
-	  will be called ni65.
-
 config DNET
 	tristate "Dave ethernet support (DNET)"
 	depends on NET_ETHERNET && HAS_IOMEM
diff --git a/drivers/net/Makefile b/drivers/net/Makefile
index 3fd125e..68c1eb9 100644
--- a/drivers/net/Makefile
+++ b/drivers/net/Makefile
@@ -174,7 +174,6 @@ obj-$(CONFIG_DUMMY) += dummy.o
 obj-$(CONFIG_IFB) += ifb.o
 obj-$(CONFIG_MACVLAN) += macvlan.o
 obj-$(CONFIG_MACVTAP) += macvtap.o
-obj-$(CONFIG_LANCE) += lance.o
 obj-$(CONFIG_SGISEEQ) += sgiseeq.o
 obj-$(CONFIG_SGI_O2MACE_ETH) += meth.o
 obj-$(CONFIG_AT1700) += at1700.o
@@ -186,24 +185,19 @@ obj-$(CONFIG_8139TOO) += 8139too.o
 obj-$(CONFIG_CPMAC) += cpmac.o
 obj-$(CONFIG_ATP) += atp.o
 obj-$(CONFIG_NI5010) += ni5010.o
-obj-$(CONFIG_NI65) += ni65.o
 obj-$(CONFIG_AC3200) += ac3200.o 8390.o
 obj-$(CONFIG_SC92031) += sc92031.o
 
 obj-$(CONFIG_ETH16I) += eth16i.o
 obj-$(CONFIG_ZORRO8390) += zorro8390.o 8390.o
-obj-$(CONFIG_HPLANCE) += hplance.o 7990.o
-obj-$(CONFIG_MVME147_NET) += mvme147.o 7990.o
 obj-$(CONFIG_EQUALIZER) += eql.o
 obj-$(CONFIG_KORINA) += korina.o
 obj-$(CONFIG_MIPS_JAZZ_SONIC) += jazzsonic.o
 obj-$(CONFIG_MIPS_AU1X00_ENET) += au1000_eth.o
 obj-$(CONFIG_MIPS_SIM_NET) += mipsnet.o
 obj-$(CONFIG_SGI_IOC3_ETH) += ioc3-eth.o
-obj-$(CONFIG_ATARILANCE) += atarilance.o
 obj-$(CONFIG_A2065) += a2065.o
 obj-$(CONFIG_HYDRA) += hydra.o 8390.o
-obj-$(CONFIG_ARIADNE) += ariadne.o
 obj-$(CONFIG_CS89x0) += cs89x0.o
 obj-$(CONFIG_MACSONIC) += macsonic.o
 obj-$(CONFIG_MACMACE) += macmace.o
diff --git a/drivers/net/7990.c b/drivers/net/legacy/7990.c
similarity index 100%
rename from drivers/net/7990.c
rename to drivers/net/legacy/7990.c
diff --git a/drivers/net/7990.h b/drivers/net/legacy/7990.h
similarity index 100%
rename from drivers/net/7990.h
rename to drivers/net/legacy/7990.h
diff --git a/drivers/net/legacy/Kconfig b/drivers/net/legacy/Kconfig
index c84f87c..32bd91a 100644
--- a/drivers/net/legacy/Kconfig
+++ b/drivers/net/legacy/Kconfig
@@ -262,3 +262,62 @@ config NI52
 
 	  To compile this driver as a module, choose M here. The module
 	  will be called ni52.
+
+config NI65
+	tristate "NI6510 support"
+	depends on NET_VENDOR_RACAL && ISA && ISA_DMA_API
+	help
+	  If you have a network (Ethernet) card of this type, say Y and read
+	  the Ethernet-HOWTO, available from
+	  <http://www.tldp.org/docs.html#howto>.
+
+	  To compile this driver as a module, choose M here. The module
+	  will be called ni65.
+
+config MVME147_NET
+	tristate "MVME147 (Lance) Ethernet support"
+	depends on MVME147
+	select CRC32
+	help
+	  Support for the on-board Ethernet interface on the Motorola MVME147
+	  single-board computer.  Say Y here to include the
+	  driver for this chip in your kernel.
+	  To compile this driver as a module, choose M here.
+
+config ATARILANCE
+	tristate "Atari Lance support"
+	depends on ATARI
+	help
+	  Say Y to include support for several Atari Ethernet adapters based
+	  on the AMD Lance chipset: RieblCard (with or without battery), or
+	  PAMCard VME (also the version by Rhotron, with different addresses).
+
+config ARIADNE
+	tristate "Ariadne support"
+	depends on ZORRO
+	help
+	  If you have a Village Tronic Ariadne Ethernet adapter, say Y.
+	  Otherwise, say N.
+
+	  To compile this driver as a module, choose M here: the module
+	  will be called ariadne.
+
+config HPLANCE
+	bool "HP on-board LANCE support"
+	depends on DIO
+	select CRC32
+	help
+	  If you want to use the builtin "LANCE" Ethernet controller on an
+	  HP300 machine, say Y here.
+
+config LANCE
+	tristate "AMD LANCE and PCnet (AT1500 and NE2100) support"
+	depends on ISA && ISA_DMA_API
+	help
+	  If you have a network (Ethernet) card of this type, say Y and read
+	  the Ethernet-HOWTO, available from
+	  <http://www.tldp.org/docs.html#howto>. Some LinkSys cards are
+	  of this type.
+
+	  To compile this driver as a module, choose M here: the module
+	  will be called lance.  This is recommended.
diff --git a/drivers/net/legacy/Makefile b/drivers/net/legacy/Makefile
index b605648..0eb679c 100644
--- a/drivers/net/legacy/Makefile
+++ b/drivers/net/legacy/Makefile
@@ -30,3 +30,10 @@ obj-$(CONFIG_NI52) += ni52.o
 obj-$(CONFIG_SNI_82596) += sni_82596.o
 obj-$(CONFIG_ZNET) += znet.o
 
+# Lance based cards
+obj-$(CONFIG_ATARILANCE) += atarilance.o
+obj-$(CONFIG_ARIADNE) += ariadne.o
+obj-$(CONFIG_HPLANCE) += hplance.o 7990.o
+obj-$(CONFIG_LANCE) += lance.o
+obj-$(CONFIG_MVME147_NET) += mvme147.o 7990.o
+obj-$(CONFIG_NI65) += ni65.o
diff --git a/drivers/net/ariadne.c b/drivers/net/legacy/ariadne.c
similarity index 100%
rename from drivers/net/ariadne.c
rename to drivers/net/legacy/ariadne.c
diff --git a/drivers/net/ariadne.h b/drivers/net/legacy/ariadne.h
similarity index 100%
rename from drivers/net/ariadne.h
rename to drivers/net/legacy/ariadne.h
diff --git a/drivers/net/atarilance.c b/drivers/net/legacy/atarilance.c
similarity index 100%
rename from drivers/net/atarilance.c
rename to drivers/net/legacy/atarilance.c
diff --git a/drivers/net/hplance.c b/drivers/net/legacy/hplance.c
similarity index 100%
rename from drivers/net/hplance.c
rename to drivers/net/legacy/hplance.c
diff --git a/drivers/net/hplance.h b/drivers/net/legacy/hplance.h
similarity index 100%
rename from drivers/net/hplance.h
rename to drivers/net/legacy/hplance.h
diff --git a/drivers/net/lance.c b/drivers/net/legacy/lance.c
similarity index 100%
rename from drivers/net/lance.c
rename to drivers/net/legacy/lance.c
diff --git a/drivers/net/mvme147.c b/drivers/net/legacy/mvme147.c
similarity index 100%
rename from drivers/net/mvme147.c
rename to drivers/net/legacy/mvme147.c
diff --git a/drivers/net/ni65.c b/drivers/net/legacy/ni65.c
similarity index 100%
rename from drivers/net/ni65.c
rename to drivers/net/legacy/ni65.c
diff --git a/drivers/net/ni65.h b/drivers/net/legacy/ni65.h
similarity index 100%
rename from drivers/net/ni65.h
rename to drivers/net/legacy/ni65.h
-- 
1.7.3.2.146.g2d444

