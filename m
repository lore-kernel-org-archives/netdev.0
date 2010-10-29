From: Paul Gortmaker <paul.gortmaker@windriver.com>
Subject: [PATCH 13/15] netdev: kill off NET_ISA Kconfig option
Date: Thu, 28 Oct 2010 21:19:17 -0400
Message-ID: <1288315159-1350-14-git-send-email-paul.gortmaker@windriver.com>
References: <1288315159-1350-1-git-send-email-paul.gortmaker@windriver.com>
Cc: netdev@vger.kernel.org
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.windriver.com ([147.11.1.11]:33998 "EHLO
	mail.windriver.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754444Ab0J2BTf (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 28 Oct 2010 21:19:35 -0400
In-Reply-To: <1288315159-1350-1-git-send-email-paul.gortmaker@windriver.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The NET_ISA option was like the NET_VENDOR_<xyz> options in that it
just hid a bunch of config options from being presented.  For those
drivers that depended on it to provide the ISA dependency, just have
them depend on ISA directly.

The NETDEV_LEGACY option is used to hide all these NET_ISA options,
so that the end number of options presented is largely unchanged.

Signed-off-by: Paul Gortmaker <paul.gortmaker@windriver.com>
---
 drivers/net/Kconfig        |   17 -----------------
 drivers/net/legacy/Kconfig |   22 +++++++++++-----------
 2 files changed, 11 insertions(+), 28 deletions(-)

diff --git a/drivers/net/Kconfig b/drivers/net/Kconfig
index 707c9f8c..0433c35 100644
--- a/drivers/net/Kconfig
+++ b/drivers/net/Kconfig
@@ -701,23 +701,6 @@ config HP100
 	  To compile this driver as a module, choose M here. The module
 	  will be called hp100.
 
-config NET_ISA
-	bool "Other ISA cards"
-	depends on ISA
-	---help---
-	  If your network (Ethernet) card hasn't been mentioned yet and its
-	  bus system (that's the way the cards talks to the other components
-	  of your computer) is ISA (as opposed to EISA, VLB or PCI), say Y.
-	  Make sure you know the name of your card. Read the Ethernet-HOWTO,
-	  available from <http://www.tldp.org/docs.html#howto>.
-
-	  If unsure, say Y.
-
-	  Note that the answer to this question doesn't directly affect the
-	  kernel: saying N will just cause the configurator to skip all
-	  the remaining ISA network card questions. If you say Y, you will be
-	  asked for your specific card in the following questions.
-
 config IBMVETH
 	tristate "IBM LAN Virtual Ethernet support"
 	depends on PPC_PSERIES
diff --git a/drivers/net/legacy/Kconfig b/drivers/net/legacy/Kconfig
index b9ea8ed..5736338 100644
--- a/drivers/net/legacy/Kconfig
+++ b/drivers/net/legacy/Kconfig
@@ -108,7 +108,7 @@ config DEPCA
 
 config EWRK3
 	tristate "EtherWORKS 3 (DE203, DE204, DE205) support"
-	depends on NET_ISA
+	depends on ISA
 	select CRC32
 	---help---
 	  This driver supports the DE203, DE204 and DE205 network (Ethernet)
@@ -235,7 +235,7 @@ config ELMC_II
 
 config EEXPRESS
 	tristate "EtherExpress 16 support"
-	depends on NET_ISA
+	depends on ISA
 	---help---
 	  If you have an EtherExpress16 network (Ethernet) card, say Y and
 	  read the Ethernet-HOWTO, available from
@@ -249,7 +249,7 @@ config EEXPRESS
 
 config EEXPRESS_PRO
 	tristate "EtherExpressPro support/EtherExpress 10 (i82595) support"
-	depends on NET_ISA
+	depends on ISA
 	---help---
 	  If you have a network (Ethernet) card of this type, say Y. This
 	  driver supports Intel i82595{FX,TX} based boards. Note however
@@ -262,7 +262,7 @@ config EEXPRESS_PRO
 
 config LP486E
 	tristate "LP486E on board Ethernet"
-	depends on NET_ISA
+	depends on ISA
 	help
 	  Say Y here to support the 82596-based on-board Ethernet controller
 	  for the Panther motherboard, which is one of the two shipped in the
@@ -270,7 +270,7 @@ config LP486E
 
 config ZNET
 	tristate "Zenith Z-Note support (EXPERIMENTAL)"
-	depends on NET_ISA && EXPERIMENTAL && ISA_DMA_API
+	depends on ISA && EXPERIMENTAL && ISA_DMA_API
 	help
 	  The Zenith Z-Note notebook computer has a built-in network
 	  (Ethernet) card, and this is the Linux driver for it. Note that the
@@ -501,7 +501,7 @@ config ULTRA32
 
 config E2100
 	tristate "Cabletron E21xx support"
-	depends on NET_ISA
+	depends on ISA
 	select CRC32
 	help
 	  If you have a network (Ethernet) card of this type, say Y and read
@@ -513,7 +513,7 @@ config E2100
 
 config HPLAN_PLUS
 	tristate "HP PCLAN+ (27247B and 27252A) support"
-	depends on NET_ISA
+	depends on ISA
 	select CRC32
 	help
 	  If you have a network (Ethernet) card of this type, say Y and read
@@ -525,7 +525,7 @@ config HPLAN_PLUS
 
 config HPLAN
 	tristate "HP PCLAN (27245 and other 27xxx series) support"
-	depends on NET_ISA
+	depends on ISA
 	select CRC32
 	help
 	  If you have a network (Ethernet) card of this type, say Y and read
@@ -537,7 +537,7 @@ config HPLAN
 
 config NE2000
 	tristate "NE2000/NE1000 support"
-	depends on NET_ISA || (Q40 && m) || M32R || MACH_TX49XX
+	depends on ISA || (Q40 && m) || M32R || MACH_TX49XX
 	select CRC32
 	---help---
 	  If you have a network (Ethernet) card of this type, say Y and read
@@ -600,7 +600,7 @@ config AT1700
 
 config ETH16I
 	tristate "ICL EtherTeam 16i/32 support"
-	depends on NET_ISA
+	depends on ISA
 	help
 	  If you have a network (Ethernet) card of this type, say Y and read
 	  the Ethernet-HOWTO, available from
@@ -611,7 +611,7 @@ config ETH16I
  
 config SEEQ8005
 	tristate "SEEQ8005 support (EXPERIMENTAL)"
-	depends on NET_ISA && EXPERIMENTAL
+	depends on ISA && EXPERIMENTAL
 	help
 	  This is a driver for the SEEQ 8005 network (Ethernet) card.  If this
 	  is for you, read the Ethernet-HOWTO, available from
-- 
1.7.3.2.146.g2d444

