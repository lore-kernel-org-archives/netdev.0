From: Domenico Andreoli <cavokz@gmail.com>
Subject: [PATCH v2 2/2] CS89x0: Add networking support for QQ2440
Date: Mon, 14 Mar 2011 13:47:07 +0000
Message-ID: <20110314134707.GC11935@dandreoli.com>
References: <20110314133302.137497490@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: linux-arm-kernel@lists.infradead.org, netdev@vger.kernel.org,
	Domenico Andreoli <cavokz@gmail.com>
To: "David S. Miller" <davem@davemloft.net>,
	Andrew Morton <akpm@linux-foundation.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ey0-f174.google.com ([209.85.215.174]:60251 "EHLO
	mail-ey0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752414Ab1CNMpD (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 14 Mar 2011 08:45:03 -0400
Received: by mail-ey0-f174.google.com with SMTP id 24so1596028eyx.19
        for <netdev@vger.kernel.org>; Mon, 14 Mar 2011 05:45:03 -0700 (PDT)
Content-Disposition: inline; filename=cs89x0-add-qq2440-support
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Domenico Andreoli <cavokz@gmail.com>

QQ2440 is only another non-ISA board using CS89x0. This patch adds the
minimum bits required to make QQ2440 work with CS89x0.

Signed-off-by: Domenico Andreoli <cavokz@gmail.com>

---

I'm working on another series that brings CS89x0 to the third millenium,
it properly uses the modern ISA and platform drivers model. That series
is a little more invasive and will require more testing than this one.

 arch/arm/mach-s3c2440/include/mach/qq2440.h |   22 ++++++++++++
 arch/arm/mach-s3c2440/mach-qq2440.c         |   16 ++++++++
 drivers/net/Kconfig                         |    4 +-
 drivers/net/cs89x0.c                        |   33 ++++++++++++------
 4 files changed, 61 insertions(+), 14 deletions(-)

Index: arm-2.6.git/drivers/net/cs89x0.c
===================================================================
--- arm-2.6.git.orig/drivers/net/cs89x0.c	2011-02-07 17:04:06.000000000 +0000
+++ arm-2.6.git/drivers/net/cs89x0.c	2011-02-07 17:07:36.000000000 +0000
@@ -95,6 +95,9 @@
   Dmitry Pervushin  : dpervushin@ru.mvista.com
                     : PNX010X platform support
 
+  Domenico Andreoli : cavokz@gmail.com
+                    : QQ2440 platform support
+
 */
 
 /* Always include 'config.h' first in case the user wants to turn on
@@ -176,6 +179,10 @@
 #elif defined(CONFIG_ARCH_IXDP2X01)
 static unsigned int netcard_portlist[] __used __initdata = {IXDP2X01_CS8900_VIRT_BASE, 0};
 static unsigned int cs8900_irq_map[] = {IRQ_IXDP2X01_CS8900, 0, 0, 0};
+#elif defined(CONFIG_MACH_QQ2440)
+#include <mach/qq2440.h>
+static unsigned int netcard_portlist[] __used __initdata = { QQ2440_CS8900_VIRT_BASE + 0x300, 0 };
+static unsigned int cs8900_irq_map[] = { QQ2440_CS8900_IRQ, 0, 0, 0 };
 #elif defined(CONFIG_MACH_MX31ADS)
 #include <mach/board-mx31ads.h>
 static unsigned int netcard_portlist[] __used __initdata = {
@@ -521,6 +528,10 @@
 #endif
 		lp->force = g_cs89x0_media__force;
 #endif
+
+#if defined(CONFIG_MACH_QQ2440)
+		lp->force |= FORCE_RJ45 | FORCE_FULL;
+#endif
         }
 
 	/* Grab the region so we can find another board if autoIRQ fails. */
Index: arm-2.6.git/drivers/net/Kconfig
===================================================================
--- arm-2.6.git.orig/drivers/net/Kconfig	2011-02-07 17:04:06.000000000 +0000
+++ arm-2.6.git/drivers/net/Kconfig	2011-02-07 17:04:42.000000000 +0000
@@ -1498,7 +1498,7 @@
 config CS89x0
 	tristate "CS89x0 support"
 	depends on NET_ETHERNET && (ISA || EISA || MACH_IXDP2351 \
-		|| ARCH_IXDP2X01 || MACH_MX31ADS)
+		|| ARCH_IXDP2X01 || MACH_MX31ADS || MACH_QQ2440)
 	---help---
 	  Support for CS89x0 chipset based Ethernet cards. If you have a
 	  network (Ethernet) card of this type, say Y and read the
@@ -1512,7 +1512,7 @@
 config CS89x0_NONISA_IRQ
 	def_bool y
 	depends on CS89x0 != n
-	depends on MACH_IXDP2351 || ARCH_IXDP2X01 || MACH_MX31ADS
+	depends on MACH_IXDP2351 || ARCH_IXDP2X01 || MACH_MX31ADS || MACH_QQ2440
 
 config TC35815
 	tristate "TOSHIBA TC35815 Ethernet support"

