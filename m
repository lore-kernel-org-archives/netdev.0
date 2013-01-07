From: Paul Gortmaker <paul.gortmaker@windriver.com>
Subject: [PATCH net-next 1/1] drivers/net: delete 8390 based EISA drivers.
Date: Mon,  7 Jan 2013 13:16:58 -0500
Message-ID: <1357582618-17183-2-git-send-email-paul.gortmaker@windriver.com>
References: <1357582618-17183-1-git-send-email-paul.gortmaker@windriver.com>
Cc: netdev@vger.kernel.org,
	Paul Gortmaker <paul.gortmaker@windriver.com>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.windriver.com ([147.11.1.11]:54850 "EHLO
	mail.windriver.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753217Ab3AGSRO (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 7 Jan 2013 13:17:14 -0500
In-Reply-To: <1357582618-17183-1-git-send-email-paul.gortmaker@windriver.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The NS8390 chip was essentially the 1st widespread PC ethernet
chip, starting its life on 8 bit ISA cards in the late 1980s.
Even with better technologies available (bus mastering etc)
the 8390 managed to get used on a few rare EISA cards in the
early to mid 1990s.

The EISA bus in the x86 world was largely confined to systems
ranging from 486 to 586 (essentially 200MHz or lower, and less
than 100MB RAM) -- i.e. machines unlikely to be still in service,
and even less likely to be running a 3.9+ kernel.

On top of that, only one of the five really ever was considered
non-experimental; the smc-ultra32 was the one -- since it was
largely just an EISA version of the popular smc-ultra ISA card.
All the others had such a tiny user base that they simply never
could be considered anything more than experimental.

Signed-off-by: Paul Gortmaker <paul.gortmaker@windriver.com>
---
 drivers/net/ethernet/8390/Kconfig       |  66 +----
 drivers/net/ethernet/8390/Makefile      |   5 -
 drivers/net/ethernet/8390/ac3200.c      | 431 -----------------------------
 drivers/net/ethernet/8390/es3210.c      | 445 ------------------------------
 drivers/net/ethernet/8390/lne390.c      | 433 -----------------------------
 drivers/net/ethernet/8390/ne3210.c      | 346 ------------------------
 drivers/net/ethernet/8390/smc-ultra32.c | 463 --------------------------------
 7 files changed, 2 insertions(+), 2187 deletions(-)
 delete mode 100644 drivers/net/ethernet/8390/ac3200.c
 delete mode 100644 drivers/net/ethernet/8390/es3210.c
 delete mode 100644 drivers/net/ethernet/8390/lne390.c
 delete mode 100644 drivers/net/ethernet/8390/ne3210.c
 delete mode 100644 drivers/net/ethernet/8390/smc-ultra32.c

diff --git a/drivers/net/ethernet/8390/Kconfig b/drivers/net/ethernet/8390/Kconfig
index 8801217..e49a442 100644
--- a/drivers/net/ethernet/8390/Kconfig
+++ b/drivers/net/ethernet/8390/Kconfig
@@ -6,7 +6,7 @@ config NET_VENDOR_8390
 	bool "National Semi-conductor 8390 devices"
 	default y
 	depends on NET_VENDOR_NATSEMI && (AMIGA_PCMCIA || PCI || SUPERH || \
-		   ISA || EISA || MAC || M32R || MACH_TX49XX || \
+		   ISA || MAC || M32R || MACH_TX49XX || \
 		   H8300 || ARM || MIPS || ZORRO || PCMCIA || \
 		   EXPERIMENTAL)
 	---help---
@@ -33,18 +33,6 @@ config EL2
 	  To compile this driver as a module, choose M here. The module
 	  will be called 3c503.
 
-config AC3200
-	tristate "Ansel Communications EISA 3200 support (EXPERIMENTAL)"
-	depends on PCI && (ISA || EISA) && EXPERIMENTAL
-	select CRC32
-	---help---
-	  If you have a network (Ethernet) card of this type, say Y and read
-	  the Ethernet-HOWTO, available from
-	  <http://www.tldp.org/docs.html#howto>.
-
-	  To compile this driver as a module, choose M here. The module
-	  will be called ac3200.
-
 config PCMCIA_AXNET
 	tristate "Asix AX88190 PCMCIA support"
 	depends on PCMCIA
@@ -86,18 +74,6 @@ config E2100
 	  To compile this driver as a module, choose M here. The module
 	  will be called e2100.
 
-config ES3210
-	tristate "Racal-Interlan EISA ES3210 support (EXPERIMENTAL)"
-	depends on PCI && EISA && EXPERIMENTAL
-	select CRC32
-	---help---
-	  If you have a network (Ethernet) card of this type, say Y and read
-	  the Ethernet-HOWTO, available from
-	  <http://www.tldp.org/docs.html#howto>.
-
-	  To compile this driver as a module, choose M here. The module
-	  will be called es3210.
-
 config HPLAN_PLUS
 	tristate "HP PCLAN+ (27247B and 27252A) support"
 	depends on ISA
@@ -140,18 +116,6 @@ config ARM_ETHERH
 	  If you have an Acorn system with one of these network cards, you
 	  should say Y to this option if you wish to use it with Linux.
 
-config LNE390
-	tristate "Mylex EISA LNE390A/B support (EXPERIMENTAL)"
-	depends on PCI && EISA && EXPERIMENTAL
-	select CRC32
-	---help---
-	  If you have a network (Ethernet) card of this type, say Y and read
-	  the Ethernet-HOWTO, available from
-	  <http://www.tldp.org/docs.html#howto>.
-
-	  To compile this driver as a module, choose M here. The module
-	  will be called lne390.
-
 config MAC8390
 	bool "Macintosh NS 8390 based ethernet cards"
 	depends on MAC
@@ -187,8 +151,7 @@ config NE2000
 	  without a specific driver are compatible with NE2000.
 
 	  If you have a PCI NE2000 card however, say N here and Y to "PCI
-	  NE2000 and clone support" under "EISA, VLB, PCI and on board
-	  controllers" below.
+	  NE2000 and clone support" below.
 
 	  To compile this driver as a module, choose M here. The module
 	  will be called ne.
@@ -223,19 +186,6 @@ config APNE
 	  To compile this driver as a module, choose M here: the module
 	  will be called apne.
 
-config NE3210
-	tristate "Novell/Eagle/Microdyne NE3210 EISA support (EXPERIMENTAL)"
-	depends on PCI && EISA && EXPERIMENTAL
-	select CRC32
-	---help---
-	  If you have a network (Ethernet) card of this type, say Y and read
-	  the Ethernet-HOWTO, available from
-	  <http://www.tldp.org/docs.html#howto>.  Note that this driver
-	  will NOT WORK for NE3200 cards as they are completely different.
-
-	  To compile this driver as a module, choose M here. The module
-	  will be called ne3210.
-
 config PCMCIA_PCNET
 	tristate "NE2000 compatible PCMCIA support"
 	depends on PCMCIA
@@ -285,18 +235,6 @@ config ULTRA
 	  To compile this driver as a module, choose M here. The module
 	  will be called smc-ultra.
 
-config ULTRA32
-	tristate "SMC Ultra32 EISA support"
-	depends on EISA
-	select CRC32
-	---help---
-	  If you have a network (Ethernet) card of this type, say Y and read
-	  the Ethernet-HOWTO, available from
-	  <http://www.tldp.org/docs.html#howto>.
-
-	  To compile this driver as a module, choose M here. The module
-	  will be called smc-ultra32.
-
 config WD80x3
 	tristate "WD80*3 support"
 	depends on ISA
diff --git a/drivers/net/ethernet/8390/Makefile b/drivers/net/ethernet/8390/Makefile
index 8fb462c..e8bb97c 100644
--- a/drivers/net/ethernet/8390/Makefile
+++ b/drivers/net/ethernet/8390/Makefile
@@ -3,26 +3,21 @@
 #
 
 obj-$(CONFIG_MAC8390) += mac8390.o
-obj-$(CONFIG_AC3200) += ac3200.o 8390.o
 obj-$(CONFIG_APNE) += apne.o 8390.o
 obj-$(CONFIG_ARM_ETHERH) += etherh.o
 obj-$(CONFIG_AX88796) += ax88796.o
 obj-$(CONFIG_E2100) += e2100.o 8390.o
 obj-$(CONFIG_EL2) += 3c503.o 8390p.o
-obj-$(CONFIG_ES3210) += es3210.o 8390.o
 obj-$(CONFIG_HPLAN_PLUS) += hp-plus.o 8390p.o
 obj-$(CONFIG_HPLAN) += hp.o 8390p.o
 obj-$(CONFIG_HYDRA) += hydra.o 8390.o
-obj-$(CONFIG_LNE390) += lne390.o 8390.o
 obj-$(CONFIG_MCF8390) += mcf8390.o 8390.o
 obj-$(CONFIG_NE2000) += ne.o 8390p.o
 obj-$(CONFIG_NE2K_PCI) += ne2k-pci.o 8390.o
-obj-$(CONFIG_NE3210) += ne3210.o 8390.o
 obj-$(CONFIG_NE_H8300) += ne-h8300.o 8390.o
 obj-$(CONFIG_PCMCIA_AXNET) += axnet_cs.o 8390.o
 obj-$(CONFIG_PCMCIA_PCNET) += pcnet_cs.o 8390.o
 obj-$(CONFIG_STNIC) += stnic.o 8390.o
 obj-$(CONFIG_ULTRA) += smc-ultra.o 8390.o
-obj-$(CONFIG_ULTRA32) += smc-ultra32.o 8390.o
 obj-$(CONFIG_WD80x3) += wd.o 8390.o
 obj-$(CONFIG_ZORRO8390) += zorro8390.o 8390.o
diff --git a/drivers/net/ethernet/8390/ac3200.c b/drivers/net/ethernet/8390/ac3200.c
deleted file mode 100644
index ccf0794..0000000
diff --git a/drivers/net/ethernet/8390/es3210.c b/drivers/net/ethernet/8390/es3210.c
deleted file mode 100644
index ba1b5c9..0000000
diff --git a/drivers/net/ethernet/8390/lne390.c b/drivers/net/ethernet/8390/lne390.c
deleted file mode 100644
index 479409b..0000000
diff --git a/drivers/net/ethernet/8390/ne3210.c b/drivers/net/ethernet/8390/ne3210.c
deleted file mode 100644
index ebcdb52..0000000
diff --git a/drivers/net/ethernet/8390/smc-ultra32.c b/drivers/net/ethernet/8390/smc-ultra32.c
deleted file mode 100644
index 923e42a..0000000
-- 
1.8.1
