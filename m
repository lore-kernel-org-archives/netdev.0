From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next 6/9] ixbmtr_cs: Move the IBM PCMCIA Token Ring driver
Date: Tue, 23 Aug 2011 01:45:46 -0700
Message-ID: <1314089149-27205-7-git-send-email-jeffrey.t.kirsher@intel.com>
References: <1314089149-27205-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: Jeff Kirsher <jeffrey.t.kirsher@intel.com>, netdev@vger.kernel.org,
	gospo@redhat.com, Mike Phillips <phillim@amtrak.com>,
	Burt Silverman <burts@us.ibm.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga02.intel.com ([134.134.136.20]:44503 "EHLO mga02.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754863Ab1HWIqZ (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 23 Aug 2011 04:46:25 -0400
In-Reply-To: <1314089149-27205-1-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Move the IBM PCMCIA Token Ring driver into drivers/net/tokenring/ with
the other Token Ring drivers.  Made the necessary Kconfig and Makefile
changes as well.

CC: Mike Phillips <phillim@amtrak.com>
CC: Burt Silverman <burts@us.ibm.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 drivers/net/pcmcia/Kconfig                   |   11 -----------
 drivers/net/pcmcia/Makefile                  |    2 --
 drivers/net/tokenring/Kconfig                |   13 ++++++++++++-
 drivers/net/tokenring/Makefile               |   21 +++++++++++----------
 drivers/net/{pcmcia => tokenring}/ibmtr_cs.c |    2 +-
 5 files changed, 24 insertions(+), 25 deletions(-)
 rename drivers/net/{pcmcia => tokenring}/ibmtr_cs.c (99%)

diff --git a/drivers/net/pcmcia/Kconfig b/drivers/net/pcmcia/Kconfig
index 12e7ae4..ff4deb0 100644
--- a/drivers/net/pcmcia/Kconfig
+++ b/drivers/net/pcmcia/Kconfig
@@ -31,15 +31,4 @@ config ARCNET_COM20020_CS
 	  To compile this driver as a module, choose M here: the module will be
 	  called com20020_cs.  If unsure, say N.
 
-config PCMCIA_IBMTR
-	tristate "IBM PCMCIA tokenring adapter support"
-	depends on IBMTR!=y && TR
-	help
-	  Say Y here if you intend to attach this type of Token Ring PCMCIA
-	  card to your computer. You then also need to say Y to "Token Ring
-	  driver support".
-
-	  To compile this driver as a module, choose M here: the module will be
-	  called ibmtr_cs.
-
 endif # NET_PCMCIA
diff --git a/drivers/net/pcmcia/Makefile b/drivers/net/pcmcia/Makefile
index 618e816..b98a0a4 100644
--- a/drivers/net/pcmcia/Makefile
+++ b/drivers/net/pcmcia/Makefile
@@ -4,5 +4,3 @@
 
 # 16-bit client drivers
 obj-$(CONFIG_ARCNET_COM20020_CS)+= com20020_cs.o
-
-obj-$(CONFIG_PCMCIA_IBMTR)	+= ibmtr_cs.o
diff --git a/drivers/net/tokenring/Kconfig b/drivers/net/tokenring/Kconfig
index c4137b0..0f70158 100644
--- a/drivers/net/tokenring/Kconfig
+++ b/drivers/net/tokenring/Kconfig
@@ -6,7 +6,7 @@
 menuconfig TR
 	tristate "Token Ring driver support"
 	depends on NETDEVICES && !UML
-	depends on (PCI || ISA || MCA || CCW)
+	depends on (PCI || ISA || MCA || CCW || PCMCIA)
 	select LLC
 	help
 	  Token Ring is IBM's way of communication on a local network; the
@@ -20,6 +20,17 @@ menuconfig TR
 
 if TR
 
+config PCMCIA_IBMTR
+	tristate "IBM PCMCIA tokenring adapter support"
+	depends on IBMTR!=y && PCMCIA
+	---help---
+	  Say Y here if you intend to attach this type of Token Ring PCMCIA
+	  card to your computer. You then also need to say Y to "Token Ring
+	  driver support".
+
+	  To compile this driver as a module, choose M here: the module will be
+	  called ibmtr_cs.
+
 config IBMTR
 	tristate "IBM Tropic chipset based adapter support"
 	depends on ISA || MCA
diff --git a/drivers/net/tokenring/Makefile b/drivers/net/tokenring/Makefile
index c88b0a5..f1be8d9 100644
--- a/drivers/net/tokenring/Makefile
+++ b/drivers/net/tokenring/Makefile
@@ -2,14 +2,15 @@
 # Makefile for drivers/net/tokenring
 #
 
-obj-$(CONFIG_IBMTR) 	+= ibmtr.o
-obj-$(CONFIG_IBMOL) 	+= olympic.o
-obj-$(CONFIG_IBMLS) 	+= lanstreamer.o
-obj-$(CONFIG_TMS380TR) 	+= tms380tr.o
-obj-$(CONFIG_ABYSS) 	+= abyss.o
-obj-$(CONFIG_MADGEMC) 	+= madgemc.o
-obj-$(CONFIG_PROTEON) 	+= proteon.o
-obj-$(CONFIG_TMSPCI) 	+= tmspci.o
-obj-$(CONFIG_SKISA) 	+= skisa.o
-obj-$(CONFIG_SMCTR) 	+= smctr.o
+obj-$(CONFIG_PCMCIA_IBMTR)	+= ibmtr_cs.o
+obj-$(CONFIG_IBMTR)	+= ibmtr.o
+obj-$(CONFIG_IBMOL)	+= olympic.o
+obj-$(CONFIG_IBMLS)	+= lanstreamer.o
+obj-$(CONFIG_TMS380TR)	+= tms380tr.o
+obj-$(CONFIG_ABYSS)	+= abyss.o
+obj-$(CONFIG_MADGEMC)	+= madgemc.o
+obj-$(CONFIG_PROTEON)	+= proteon.o
+obj-$(CONFIG_TMSPCI)	+= tmspci.o
+obj-$(CONFIG_SKISA)	+= skisa.o
+obj-$(CONFIG_SMCTR)	+= smctr.o
 obj-$(CONFIG_3C359)	+= 3c359.o
diff --git a/drivers/net/pcmcia/ibmtr_cs.c b/drivers/net/tokenring/ibmtr_cs.c
similarity index 99%
rename from drivers/net/pcmcia/ibmtr_cs.c
rename to drivers/net/tokenring/ibmtr_cs.c
index 6006d54..91b6846 100644
--- a/drivers/net/pcmcia/ibmtr_cs.c
+++ b/drivers/net/tokenring/ibmtr_cs.c
@@ -66,7 +66,7 @@
 #include <asm/system.h>
 
 #define PCMCIA
-#include "../tokenring/ibmtr.c"
+#include "ibmtr.c"
 
 
 /*====================================================================*/
-- 
1.7.6

