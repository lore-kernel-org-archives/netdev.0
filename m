From: Paul Gortmaker <paul.gortmaker@windriver.com>
Subject: [PATCH 11/15] netdev: kill off the concept of NET_VENDOR_FOO
Date: Thu, 28 Oct 2010 21:19:15 -0400
Message-ID: <1288315159-1350-12-git-send-email-paul.gortmaker@windriver.com>
References: <1288315159-1350-1-git-send-email-paul.gortmaker@windriver.com>
Cc: netdev@vger.kernel.org
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.windriver.com ([147.11.1.11]:33989 "EHLO
	mail.windriver.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1759597Ab0J2BTd (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 28 Oct 2010 21:19:33 -0400
In-Reply-To: <1288315159-1350-1-git-send-email-paul.gortmaker@windriver.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Back when all the Kconfig options were in one flat list, there
were vendor specific Kconfig options which did nothing other
than hide or display the list of vendor specific Kconfig options.

With all the old driver options all squirreled away in the legacy
dir, we can simply drop these in place of the single new option
NETDEVICES_LEGACY.

Signed-off-by: Paul Gortmaker <paul.gortmaker@windriver.com>
---
 drivers/net/Kconfig        |   43 ++-----------------------------------------
 drivers/net/legacy/Kconfig |   22 +++++++++++-----------
 2 files changed, 13 insertions(+), 52 deletions(-)

diff --git a/drivers/net/Kconfig b/drivers/net/Kconfig
index b5adf52..7a0912e 100644
--- a/drivers/net/Kconfig
+++ b/drivers/net/Kconfig
@@ -466,22 +466,9 @@ config SUNVNET
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
 config VORTEX
 	tristate "3c590/3c900 series (592/595/597) \"Vortex/Boomerang\" support"
-	depends on NET_VENDOR_3COM && (PCI || EISA)
+	depends on (PCI || EISA)
 	select MII
 	---help---
 	  This option enables driver support for a large number of 10Mbps and
@@ -503,7 +490,7 @@ config VORTEX
 
 config TYPHOON
 	tristate "3cr990 series \"Typhoon\" support"
-	depends on NET_VENDOR_3COM && PCI
+	depends on PCI
 	select CRC32
 	---help---
 	  This option enables driver support for the 3cr990 series of cards:
@@ -519,19 +506,6 @@ config TYPHOON
 	  To compile this driver as a module, choose M here. The module
 	  will be called typhoon.
 
-config NET_VENDOR_SMC
-	bool "Western Digital/SMC cards"
-	depends on ISA || MCA || EISA || MAC
-	help
-	  If you have a network (Ethernet) card belonging to this class, say Y
-	  and read the Ethernet-HOWTO, available from
-	  <http://www.tldp.org/docs.html#howto>.
-
-	  Note that the answer to this question doesn't directly affect the
-	  kernel: saying N will just cause the configurator to skip all
-	  the questions about Western Digital cards. If you say Y, you will be
-	  asked for your specific card in the following questions.
-
 config BFIN_MAC
 	tristate "Blackfin on-chip MAC support"
 	depends on NET_ETHERNET && (BF516 || BF518 || BF526 || BF527 || BF536 || BF537)
@@ -727,19 +701,6 @@ config SMSC911X
 	  <file:Documentation/networking/net-modules.txt>. The module
 	  will be called smsc911x.
 
-config NET_VENDOR_RACAL
-	bool "Racal-Interlan (Micom) NI cards"
-	depends on ISA
-	help
-	  If you have a network (Ethernet) card belonging to this class, such
-	  as the NI5010, NI5210 or NI6210, say Y and read the Ethernet-HOWTO,
-	  available from <http://www.tldp.org/docs.html#howto>.
-
-	  Note that the answer to this question doesn't directly affect the
-	  kernel: saying N will just cause the configurator to skip all
-	  the questions about NI cards. If you say Y, you will be asked for
-	  your specific card in the following questions.
-
 config DNET
 	tristate "Dave ethernet support (DNET)"
 	depends on NET_ETHERNET && HAS_IOMEM
diff --git a/drivers/net/legacy/Kconfig b/drivers/net/legacy/Kconfig
index 2da3ac7..96d667e 100644
--- a/drivers/net/legacy/Kconfig
+++ b/drivers/net/legacy/Kconfig
@@ -3,7 +3,7 @@
 
 config EL1
 	tristate "3c501 \"EtherLink\" support"
-	depends on NET_VENDOR_3COM && ISA
+	depends on ISA
 	---help---
 	  If you have a network (Ethernet) card of this type, say Y and read
 	  the Ethernet-HOWTO, available from
@@ -17,7 +17,7 @@ config EL1
 
 config EL3
 	tristate "3c509/3c529 (MCA)/3c579 \"EtherLink III\" support"
-	depends on NET_VENDOR_3COM && (ISA || EISA || MCA)
+	depends on (ISA || EISA || MCA)
 	---help---
 	  If you have a network (Ethernet) card belonging to the 3Com
 	  EtherLinkIII series, say Y and read the Ethernet-HOWTO, available
@@ -32,7 +32,7 @@ config EL3
 
 config 3C515
 	tristate "3c515 ISA \"Fast EtherLink\""
-	depends on NET_VENDOR_3COM && (ISA || EISA) && ISA_DMA_API
+	depends on (ISA || EISA) && ISA_DMA_API
 	help
 	  If you have a 3Com ISA EtherLink XL "Corkscrew" 3c515 Fast Ethernet
 	  network card, say Y and read the Ethernet-HOWTO, available from
@@ -190,7 +190,7 @@ config SNI_82596
 
 config ELPLUS
 	tristate "3c505 \"EtherLink Plus\" support"
-	depends on NET_VENDOR_3COM && ISA && ISA_DMA_API
+	depends on ISA && ISA_DMA_API
 	---help---
 	  Information about this network (Ethernet) card can be found in
 	  <file:Documentation/networking/3c505.txt>.  If you have a card of
@@ -202,7 +202,7 @@ config ELPLUS
 
 config EL16
 	tristate "3c507 \"EtherLink 16\" support (EXPERIMENTAL)"
-	depends on NET_VENDOR_3COM && ISA && EXPERIMENTAL
+	depends on ISA && EXPERIMENTAL
 	help
 	  If you have a network (Ethernet) card of this type, say Y and read
 	  the Ethernet-HOWTO, available from
@@ -213,7 +213,7 @@ config EL16
 
 config ELMC
 	tristate "3c523 \"EtherLink/MC\" support"
-	depends on NET_VENDOR_3COM && MCA_LEGACY
+	depends on MCA_LEGACY
 	help
 	  If you have a network (Ethernet) card of this type, say Y and read
 	  the Ethernet-HOWTO, available from
@@ -224,7 +224,7 @@ config ELMC
 
 config ELMC_II
 	tristate "3c527 \"EtherLink/MC 32\" support (EXPERIMENTAL)"
-	depends on NET_VENDOR_3COM && MCA && MCA_LEGACY
+	depends on MCA && MCA_LEGACY
 	help
 	  If you have a network (Ethernet) card of this type, say Y and read
 	  the Ethernet-HOWTO, available from
@@ -280,7 +280,7 @@ config ZNET
 
 config NI5010
 	tristate "NI5010 support (EXPERIMENTAL)"
-	depends on NET_VENDOR_RACAL && ISA && EXPERIMENTAL && BROKEN_ON_SMP
+	depends on ISA && EXPERIMENTAL && BROKEN_ON_SMP
 	---help---
 	  If you have a network (Ethernet) card of this type, say Y and read
 	  the Ethernet-HOWTO, available from
@@ -292,7 +292,7 @@ config NI5010
 
 config NI52
 	tristate "NI5210 support"
-	depends on NET_VENDOR_RACAL && ISA
+	depends on ISA
 	help
 	  If you have a network (Ethernet) card of this type, say Y and read
 	  the Ethernet-HOWTO, available from
@@ -303,7 +303,7 @@ config NI52
 
 config NI65
 	tristate "NI6510 support"
-	depends on NET_VENDOR_RACAL && ISA && ISA_DMA_API
+	depends on ISA && ISA_DMA_API
 	help
 	  If you have a network (Ethernet) card of this type, say Y and read
 	  the Ethernet-HOWTO, available from
@@ -637,7 +637,7 @@ config IBMLANA
 
 config SMC9194
 	tristate "SMC 9194 support"
-	depends on NET_VENDOR_SMC && (ISA || MAC && BROKEN)
+	depends on ISA || MAC && BROKEN
 	select CRC32
 	---help---
 	  This is support for the SMC9xxx based Ethernet cards. Choose this
-- 
1.7.3.2.146.g2d444

