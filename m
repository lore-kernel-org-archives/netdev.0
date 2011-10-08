From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next v2] cs89x0: Move the driver into the Cirrus dir
Date: Sat,  8 Oct 2011 01:07:44 -0700
Message-ID: <1318061264-25310-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: Jeff Kirsher <jeffrey.t.kirsher@intel.com>, netdev@vger.kernel.org,
	gospo@redhat.com, sassmann@redhat.com,
	Russell Nelson <nelson@crynwr.com>,
	Andrew Morton <akpm@linux-foundation.org>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga01.intel.com ([192.55.52.88]:30744 "EHLO mga01.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751604Ab1JHIHq (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sat, 8 Oct 2011 04:07:46 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The cs89x0 driver was initial placed in the apple/ when it
should have been placed in the cirrus/.  This resolves the
issue by moving the dirver and fixing up the respective
Kconfig(s) and Makefile(s).

Thanks to Sascha for reporting the issue.

-v2 Fix a config error that was introduced with v1 by removing
    the dependency on MACE for NET_VENDOR_APPLE.

CC: Russell Nelson <nelson@crynwr.com>
CC: Andrew Morton <akpm@linux-foundation.org>
Reported-by: Sascha Hauer <s.hauer@pengutronix.de>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 drivers/net/ethernet/apple/Kconfig              |   22 +---------------------
 drivers/net/ethernet/apple/Makefile             |    1 -
 drivers/net/ethernet/cirrus/Kconfig             |   22 +++++++++++++++++++++-
 drivers/net/ethernet/cirrus/Makefile            |    1 +
 drivers/net/ethernet/{apple => cirrus}/cs89x0.c |    0
 drivers/net/ethernet/{apple => cirrus}/cs89x0.h |    0
 6 files changed, 23 insertions(+), 23 deletions(-)
 rename drivers/net/ethernet/{apple => cirrus}/cs89x0.c (100%)
 rename drivers/net/ethernet/{apple => cirrus}/cs89x0.h (100%)

diff --git a/drivers/net/ethernet/apple/Kconfig b/drivers/net/ethernet/apple/Kconfig
index 59d5c26..a759d54 100644
--- a/drivers/net/ethernet/apple/Kconfig
+++ b/drivers/net/ethernet/apple/Kconfig
@@ -5,8 +5,7 @@
 config NET_VENDOR_APPLE
 	bool "Apple devices"
 	default y
-	depends on (PPC_PMAC && PPC32) || MAC || ISA || EISA || MACH_IXDP2351 \
-		   || ARCH_IXDP2X01 || MACH_MX31ADS || MACH_QQ2440
+	depends on (PPC_PMAC && PPC32) || MAC
 	---help---
 	  If you have a network (Ethernet) card belonging to this class, say Y
 	  and read the Ethernet-HOWTO, available from
@@ -75,23 +74,4 @@ config MACMACE
 	  say Y and read the Ethernet-HOWTO, available from
 	  <http://www.tldp.org/docs.html#howto>.
 
-config CS89x0
-	tristate "CS89x0 support"
-	depends on (ISA || EISA || MACH_IXDP2351 \
-		|| ARCH_IXDP2X01 || MACH_MX31ADS || MACH_QQ2440)
-	---help---
-	  Support for CS89x0 chipset based Ethernet cards. If you have a
-	  network (Ethernet) card of this type, say Y and read the
-	  Ethernet-HOWTO, available from
-	  <http://www.tldp.org/docs.html#howto> as well as
-	  <file:Documentation/networking/cs89x0.txt>.
-
-	  To compile this driver as a module, choose M here. The module
-	  will be called cs89x0.
-
-config CS89x0_NONISA_IRQ
-	def_bool y
-	depends on CS89x0 != n
-	depends on MACH_IXDP2351 || ARCH_IXDP2X01 || MACH_MX31ADS || MACH_QQ2440
-
 endif # NET_VENDOR_APPLE
diff --git a/drivers/net/ethernet/apple/Makefile b/drivers/net/ethernet/apple/Makefile
index 9d30086..0d3a591 100644
--- a/drivers/net/ethernet/apple/Makefile
+++ b/drivers/net/ethernet/apple/Makefile
@@ -5,5 +5,4 @@
 obj-$(CONFIG_MACE) += mace.o
 obj-$(CONFIG_BMAC) += bmac.o
 obj-$(CONFIG_MAC89x0) += mac89x0.o
-obj-$(CONFIG_CS89x0) += cs89x0.o
 obj-$(CONFIG_MACMACE) += macmace.o
diff --git a/drivers/net/ethernet/cirrus/Kconfig b/drivers/net/ethernet/cirrus/Kconfig
index e9386ef..6cbb81c 100644
--- a/drivers/net/ethernet/cirrus/Kconfig
+++ b/drivers/net/ethernet/cirrus/Kconfig
@@ -5,7 +5,8 @@
 config NET_VENDOR_CIRRUS
 	bool "Cirrus devices"
 	default y
-	depends on ARM && ARCH_EP93XX
+	depends on ISA || EISA || MACH_IXDP2351 || ARCH_IXDP2X01 \
+		|| MACH_MX31ADS || MACH_QQ2440 || (ARM && ARCH_EP93XX)
 	---help---
 	  If you have a network (Ethernet) card belonging to this class, say Y
 	  and read the Ethernet-HOWTO, available from
@@ -18,6 +19,25 @@ config NET_VENDOR_CIRRUS
 
 if NET_VENDOR_CIRRUS
 
+config CS89x0
+	tristate "CS89x0 support"
+	depends on (ISA || EISA || MACH_IXDP2351 \
+		|| ARCH_IXDP2X01 || MACH_MX31ADS || MACH_QQ2440)
+	---help---
+	  Support for CS89x0 chipset based Ethernet cards. If you have a
+	  network (Ethernet) card of this type, say Y and read the
+	  Ethernet-HOWTO, available from
+	  <http://www.tldp.org/docs.html#howto> as well as
+	  <file:Documentation/networking/cs89x0.txt>.
+
+	  To compile this driver as a module, choose M here. The module
+	  will be called cs89x0.
+
+config CS89x0_NONISA_IRQ
+	def_bool y
+	depends on CS89x0 != n
+	depends on MACH_IXDP2351 || ARCH_IXDP2X01 || MACH_MX31ADS || MACH_QQ2440
+
 config EP93XX_ETH
 	tristate "EP93xx Ethernet support"
 	depends on ARM && ARCH_EP93XX
diff --git a/drivers/net/ethernet/cirrus/Makefile b/drivers/net/ethernet/cirrus/Makefile
index 9905ea2..14bd77e 100644
--- a/drivers/net/ethernet/cirrus/Makefile
+++ b/drivers/net/ethernet/cirrus/Makefile
@@ -2,4 +2,5 @@
 # Makefile for the Cirrus network device drivers.
 #
 
+obj-$(CONFIG_CS89x0) += cs89x0.o
 obj-$(CONFIG_EP93XX_ETH) += ep93xx_eth.o
diff --git a/drivers/net/ethernet/apple/cs89x0.c b/drivers/net/ethernet/cirrus/cs89x0.c
similarity index 100%
rename from drivers/net/ethernet/apple/cs89x0.c
rename to drivers/net/ethernet/cirrus/cs89x0.c
diff --git a/drivers/net/ethernet/apple/cs89x0.h b/drivers/net/ethernet/cirrus/cs89x0.h
similarity index 100%
rename from drivers/net/ethernet/apple/cs89x0.h
rename to drivers/net/ethernet/cirrus/cs89x0.h
-- 
1.7.6.4
