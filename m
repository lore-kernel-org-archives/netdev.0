From: Paul Gortmaker <paul.gortmaker@windriver.com>
Subject: [PATCH 04/15] sun3: Relocate the sun3 specific lance/83596 drivers to legacy
Date: Thu, 28 Oct 2010 21:19:08 -0400
Message-ID: <1288315159-1350-5-git-send-email-paul.gortmaker@windriver.com>
References: <1288315159-1350-1-git-send-email-paul.gortmaker@windriver.com>
Cc: netdev@vger.kernel.org
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.windriver.com ([147.11.1.11]:33968 "EHLO
	mail.windriver.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754444Ab0J2BT2 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 28 Oct 2010 21:19:28 -0400
In-Reply-To: <1288315159-1350-1-git-send-email-paul.gortmaker@windriver.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Relocate these old drivers for really old Sun3 hardware to the
legacy dir.

Signed-off-by: Paul Gortmaker <paul.gortmaker@windriver.com>
---
 drivers/net/Kconfig                   |   22 ----------------------
 drivers/net/Makefile                  |    2 --
 drivers/net/legacy/Kconfig            |   22 ++++++++++++++++++++++
 drivers/net/legacy/Makefile           |    3 +++
 drivers/net/{ => legacy}/sun3_82586.c |    0
 drivers/net/{ => legacy}/sun3_82586.h |    0
 drivers/net/{ => legacy}/sun3lance.c  |    0
 7 files changed, 25 insertions(+), 24 deletions(-)
 rename drivers/net/{ => legacy}/sun3_82586.c (100%)
 rename drivers/net/{ => legacy}/sun3_82586.h (100%)
 rename drivers/net/{ => legacy}/sun3lance.c (100%)

diff --git a/drivers/net/Kconfig b/drivers/net/Kconfig
index eb65a3a..511745d 100644
--- a/drivers/net/Kconfig
+++ b/drivers/net/Kconfig
@@ -435,28 +435,6 @@ config ATARILANCE
 	  on the AMD Lance chipset: RieblCard (with or without battery), or
 	  PAMCard VME (also the version by Rhotron, with different addresses).
 
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
-config SUN3_82586
-	bool "Sun3 on-board Intel 82586 support"
-	depends on SUN3
-	help
-	  This driver enables support for the on-board Intel 82586 based
-	  Ethernet adapter found on Sun 3/1xx and 3/2xx motherboards.  Note
-	  that this driver does not support 82586-based adapters on additional
-	  VME boards.
-
 config HPLANCE
 	bool "HP on-board LANCE support"
 	depends on DIO
diff --git a/drivers/net/Makefile b/drivers/net/Makefile
index 41594da..152f8b5 100644
--- a/drivers/net/Makefile
+++ b/drivers/net/Makefile
@@ -175,8 +175,6 @@ obj-$(CONFIG_IFB) += ifb.o
 obj-$(CONFIG_MACVLAN) += macvlan.o
 obj-$(CONFIG_MACVTAP) += macvtap.o
 obj-$(CONFIG_LANCE) += lance.o
-obj-$(CONFIG_SUN3_82586) += sun3_82586.o
-obj-$(CONFIG_SUN3LANCE) += sun3lance.o
 obj-$(CONFIG_DEFXX) += defxx.o
 obj-$(CONFIG_SGISEEQ) += sgiseeq.o
 obj-$(CONFIG_SGI_O2MACE_ETH) += meth.o
diff --git a/drivers/net/legacy/Kconfig b/drivers/net/legacy/Kconfig
index ef6fa1f..1af0740 100644
--- a/drivers/net/legacy/Kconfig
+++ b/drivers/net/legacy/Kconfig
@@ -44,3 +44,25 @@ config DE620
 
 	  To compile this driver as a module, choose M here: the module
 	  will be called de620.
+
+config SUN3LANCE
+	tristate "Sun3/Sun3x on-board LANCE support"
+	depends on SUN3 || SUN3X
+	help
+	  Most Sun3 and Sun3x motherboards (including the 3/50, 3/60 and 3/80)
+	  featured an AMD Lance 10Mbit Ethernet controller on board; say Y
+	  here to compile in the Linux driver for this and enable Ethernet.
+	  General Linux information on the Sun 3 and 3x series (now
+	  discontinued) is at
+	  <http://www.angelfire.com/ca2/tech68k/sun3.html>.
+
+	  If you're not building a kernel for a Sun 3, say N.
+
+config SUN3_82586
+	bool "Sun3 on-board Intel 82586 support"
+	depends on SUN3
+	help
+	  This driver enables support for the on-board Intel 82586 based
+	  Ethernet adapter found on Sun 3/1xx and 3/2xx motherboards.  Note
+	  that this driver does not support 82586-based adapters on additional
+	  VME boards.
diff --git a/drivers/net/legacy/Makefile b/drivers/net/legacy/Makefile
index e82ca16..f552c77 100644
--- a/drivers/net/legacy/Makefile
+++ b/drivers/net/legacy/Makefile
@@ -5,3 +5,6 @@
 obj-$(CONFIG_EL1) += 3c501.o
 obj-$(CONFIG_DE600) += de600.o
 obj-$(CONFIG_DE620) += de620.o
+
+obj-$(CONFIG_SUN3_82586) += sun3_82586.o
+obj-$(CONFIG_SUN3LANCE) += sun3lance.o
diff --git a/drivers/net/sun3_82586.c b/drivers/net/legacy/sun3_82586.c
similarity index 100%
rename from drivers/net/sun3_82586.c
rename to drivers/net/legacy/sun3_82586.c
diff --git a/drivers/net/sun3_82586.h b/drivers/net/legacy/sun3_82586.h
similarity index 100%
rename from drivers/net/sun3_82586.h
rename to drivers/net/legacy/sun3_82586.h
diff --git a/drivers/net/sun3lance.c b/drivers/net/legacy/sun3lance.c
similarity index 100%
rename from drivers/net/sun3lance.c
rename to drivers/net/legacy/sun3lance.c
-- 
1.7.3.2.146.g2d444

