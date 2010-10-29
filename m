From: Paul Gortmaker <paul.gortmaker@windriver.com>
Subject: [PATCH 09/15] netdev: relocate remaining ISA 3Com cards to legacy dir
Date: Thu, 28 Oct 2010 21:19:13 -0400
Message-ID: <1288315159-1350-10-git-send-email-paul.gortmaker@windriver.com>
References: <1288315159-1350-1-git-send-email-paul.gortmaker@windriver.com>
Cc: netdev@vger.kernel.org
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.windriver.com ([147.11.1.11]:33983 "EHLO
	mail.windriver.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1759242Ab0J2BTb (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 28 Oct 2010 21:19:31 -0400
In-Reply-To: <1288315159-1350-1-git-send-email-paul.gortmaker@windriver.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The last mainstream motherboards produced with ISA slots were
some P3 Coppermine socket370 platforms with a single ISA slot
from around the turn of the century.

Signed-off-by: Paul Gortmaker <paul.gortmaker@windriver.com>
---
 drivers/net/Kconfig              |   26 --------------------------
 drivers/net/Makefile             |    2 --
 drivers/net/{ => legacy}/3c509.c |    0
 drivers/net/{ => legacy}/3c515.c |    0
 drivers/net/legacy/Kconfig       |   26 ++++++++++++++++++++++++++
 drivers/net/legacy/Makefile      |    4 ++++
 6 files changed, 30 insertions(+), 28 deletions(-)
 rename drivers/net/{ => legacy}/3c509.c (100%)
 rename drivers/net/{ => legacy}/3c515.c (100%)

diff --git a/drivers/net/Kconfig b/drivers/net/Kconfig
index 9f6315c..5b6c3e9 100644
--- a/drivers/net/Kconfig
+++ b/drivers/net/Kconfig
@@ -479,32 +479,6 @@ config NET_VENDOR_3COM
 	  the questions about 3COM cards. If you say Y, you will be asked for
 	  your specific card in the following questions.
 
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
 config VORTEX
 	tristate "3c590/3c900 series (592/595/597) \"Vortex/Boomerang\" support"
 	depends on NET_VENDOR_3COM && (PCI || EISA)
diff --git a/drivers/net/Makefile b/drivers/net/Makefile
index e5015c6..790bb6c 100644
--- a/drivers/net/Makefile
+++ b/drivers/net/Makefile
@@ -158,8 +158,6 @@ obj-$(CONFIG_SGISEEQ) += sgiseeq.o
 obj-$(CONFIG_SGI_O2MACE_ETH) += meth.o
 obj-$(CONFIG_AT1700) += at1700.o
 obj-$(CONFIG_IBMLANA) += ibmlana.o
-obj-$(CONFIG_EL3) += 3c509.o
-obj-$(CONFIG_3C515) += 3c515.o
 obj-$(CONFIG_8139CP) += 8139cp.o
 obj-$(CONFIG_8139TOO) += 8139too.o
 obj-$(CONFIG_CPMAC) += cpmac.o
diff --git a/drivers/net/3c509.c b/drivers/net/legacy/3c509.c
similarity index 100%
rename from drivers/net/3c509.c
rename to drivers/net/legacy/3c509.c
diff --git a/drivers/net/3c515.c b/drivers/net/legacy/3c515.c
similarity index 100%
rename from drivers/net/3c515.c
rename to drivers/net/legacy/3c515.c
diff --git a/drivers/net/legacy/Kconfig b/drivers/net/legacy/Kconfig
index 74644b8..c4cdc99 100644
--- a/drivers/net/legacy/Kconfig
+++ b/drivers/net/legacy/Kconfig
@@ -15,6 +15,32 @@ config EL1
 	  To compile this driver as a module, choose M here. The module
 	  will be called 3c501.
 
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
+	help
+	  If you have a 3Com ISA EtherLink XL "Corkscrew" 3c515 Fast Ethernet
+	  network card, say Y and read the Ethernet-HOWTO, available from
+	  <http://www.tldp.org/docs.html#howto>.
+
+	  To compile this driver as a module, choose M here. The module
+	  will be called 3c515.
+
 config DE600
 	tristate "D-Link DE600 pocket adapter support"
 	depends on NET_POCKET && PARPORT
diff --git a/drivers/net/legacy/Makefile b/drivers/net/legacy/Makefile
index eefacda..5341a1d 100644
--- a/drivers/net/legacy/Makefile
+++ b/drivers/net/legacy/Makefile
@@ -66,3 +66,7 @@ obj-$(CONFIG_PCMCIA_PCNET) += 8390.o
 obj-$(CONFIG_ULTRAMCA) += smc-mca.o 8390.o
 obj-$(CONFIG_STNIC) += stnic.o 8390.o
 obj-$(CONFIG_ZORRO8390) += zorro8390.o 8390.o
+
+# Other random one-off cards
+obj-$(CONFIG_EL3) += 3c509.o
+obj-$(CONFIG_3C515) += 3c515.o
-- 
1.7.3.2.146.g2d444

