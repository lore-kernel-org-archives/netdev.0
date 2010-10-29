From: Paul Gortmaker <paul.gortmaker@windriver.com>
Subject: [PATCH 02/15] 3c501: relocate ancient 8 bit ISA driver to legacy dir
Date: Thu, 28 Oct 2010 21:19:06 -0400
Message-ID: <1288315159-1350-3-git-send-email-paul.gortmaker@windriver.com>
References: <1288315159-1350-1-git-send-email-paul.gortmaker@windriver.com>
Cc: netdev@vger.kernel.org
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.windriver.com ([147.11.1.11]:33962 "EHLO
	mail.windriver.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755214Ab0J2BT0 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 28 Oct 2010 21:19:26 -0400
In-Reply-To: <1288315159-1350-1-git-send-email-paul.gortmaker@windriver.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

As the oldest bit of "supported" hardware, this 8 bit relic from
the 1980's gets the dubious honour of being the 1st driver to
be relegated to the dark corners of the legacy dir.

It wasn't really a functional bit of kit back in the early 1990's
so don't be expecting it to work now either.  Sure it compiles,
but it is largely a historical artefact.

Signed-off-by: Paul Gortmaker <paul.gortmaker@windriver.com>
---
 drivers/net/Kconfig              |   14 --------------
 drivers/net/Makefile             |    1 -
 drivers/net/{ => legacy}/3c501.c |    0
 drivers/net/{ => legacy}/3c501.h |    0
 drivers/net/legacy/Kconfig       |   14 ++++++++++++++
 drivers/net/legacy/Makefile      |    2 ++
 6 files changed, 16 insertions(+), 15 deletions(-)
 rename drivers/net/{ => legacy}/3c501.c (100%)
 rename drivers/net/{ => legacy}/3c501.h (100%)

diff --git a/drivers/net/Kconfig b/drivers/net/Kconfig
index 9515f76..cb7f3f4 100644
--- a/drivers/net/Kconfig
+++ b/drivers/net/Kconfig
@@ -641,20 +641,6 @@ config NET_VENDOR_3COM
 	  the questions about 3COM cards. If you say Y, you will be asked for
 	  your specific card in the following questions.
 
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
 config EL2
 	tristate "3c503 \"EtherLink II\" support"
 	depends on NET_VENDOR_3COM && ISA
diff --git a/drivers/net/Makefile b/drivers/net/Makefile
index 8045271..eb99117 100644
--- a/drivers/net/Makefile
+++ b/drivers/net/Makefile
@@ -183,7 +183,6 @@ obj-$(CONFIG_DEFXX) += defxx.o
 obj-$(CONFIG_SGISEEQ) += sgiseeq.o
 obj-$(CONFIG_SGI_O2MACE_ETH) += meth.o
 obj-$(CONFIG_AT1700) += at1700.o
-obj-$(CONFIG_EL1) += 3c501.o
 obj-$(CONFIG_EL16) += 3c507.o
 obj-$(CONFIG_ELMC) += 3c523.o
 obj-$(CONFIG_IBMLANA) += ibmlana.o
diff --git a/drivers/net/3c501.c b/drivers/net/legacy/3c501.c
similarity index 100%
rename from drivers/net/3c501.c
rename to drivers/net/legacy/3c501.c
diff --git a/drivers/net/3c501.h b/drivers/net/legacy/3c501.h
similarity index 100%
rename from drivers/net/3c501.h
rename to drivers/net/legacy/3c501.h
diff --git a/drivers/net/legacy/Kconfig b/drivers/net/legacy/Kconfig
index 4c23adf..fa2d6f8 100644
--- a/drivers/net/legacy/Kconfig
+++ b/drivers/net/legacy/Kconfig
@@ -1,2 +1,16 @@
 
 # Legacy drivers for ancient ISA/EISA bus devices and the like.
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
diff --git a/drivers/net/legacy/Makefile b/drivers/net/legacy/Makefile
index 33fd752..acbf0b2 100644
--- a/drivers/net/legacy/Makefile
+++ b/drivers/net/legacy/Makefile
@@ -1,3 +1,5 @@
 #
 # Makefile for the Linux legacy network device drivers.
 #
+
+obj-$(CONFIG_EL1) += 3c501.o
-- 
1.7.3.2.146.g2d444

