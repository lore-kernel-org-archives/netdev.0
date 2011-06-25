From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [RFC 57/72] sc92031: Move the Silan driver
Date: Sat, 25 Jun 2011 06:59:08 -0700
Message-ID: <1309010363-22750-58-git-send-email-jeffrey.t.kirsher@intel.com>
References: <1309010363-22750-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: Jeff Kirsher <jeffrey.t.kirsher@intel.com>, netdev@vger.kernel.org
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga03.intel.com ([143.182.124.21]:37764 "EHLO mga03.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752486Ab1FYOA3 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sat, 25 Jun 2011 10:00:29 -0400
In-Reply-To: <1309010363-22750-1-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Move the Silan driver into drivers/net/ethernet/ and made the
necessary Kconfig and Makefile changes.

Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 drivers/net/Kconfig                  |   12 ------------
 drivers/net/Makefile                 |    1 -
 drivers/net/ethernet/Kconfig         |   13 +++++++++++++
 drivers/net/ethernet/Makefile        |    1 +
 drivers/net/{ => ethernet}/sc92031.c |    0
 5 files changed, 14 insertions(+), 13 deletions(-)
 rename drivers/net/{ => ethernet}/sc92031.c (100%)

diff --git a/drivers/net/Kconfig b/drivers/net/Kconfig
index 7063b9c..20d1939 100644
--- a/drivers/net/Kconfig
+++ b/drivers/net/Kconfig
@@ -437,18 +437,6 @@ config SUNDANCE_MMIO
 
 	  If unsure, say N.
 
-config SC92031
-	tristate "Silan SC92031 PCI Fast Ethernet Adapter driver (EXPERIMENTAL)"
-	depends on NET_PCI && PCI && EXPERIMENTAL
-	select CRC32
-	---help---
-	  This is a driver for the Fast Ethernet PCI network cards based on
-	  the Silan SC92031 chip (sometimes also called Rsltek 8139D). If you
-	  have one of these, say Y here.
-
-	  To compile this driver as a module, choose M here: the module
-	  will be called sc92031.  This is recommended.
-
 config NET_POCKET
 	bool "Pocket and portable adapters"
 	depends on PARPORT
diff --git a/drivers/net/Makefile b/drivers/net/Makefile
index a2a1e0a..d75080d 100644
--- a/drivers/net/Makefile
+++ b/drivers/net/Makefile
@@ -57,7 +57,6 @@ obj-$(CONFIG_MACVTAP) += macvtap.o
 obj-$(CONFIG_DEFXX) += defxx.o
 obj-$(CONFIG_AT1700) += at1700.o
 obj-$(CONFIG_DEPCA) += depca.o
-obj-$(CONFIG_SC92031) += sc92031.o
 obj-$(CONFIG_EQUALIZER) += eql.o
 obj-$(CONFIG_TUN) += tun.o
 obj-$(CONFIG_VETH) += veth.o
diff --git a/drivers/net/ethernet/Kconfig b/drivers/net/ethernet/Kconfig
index e7c5f0b..aa5ded1 100644
--- a/drivers/net/ethernet/Kconfig
+++ b/drivers/net/ethernet/Kconfig
@@ -114,6 +114,19 @@ config S6GMAC
 source "drivers/net/ethernet/sis/Kconfig"
 source "drivers/net/ethernet/sfc/Kconfig"
 source "drivers/net/ethernet/sgi/Kconfig"
+
+config SC92031
+	tristate "Silan SC92031 PCI Fast Ethernet Adapter driver (EXPERIMENTAL)"
+	depends on PCI && EXPERIMENTAL
+	select CRC32
+	---help---
+	  This is a driver for the Fast Ethernet PCI network cards based on
+	  the Silan SC92031 chip (sometimes also called Rsltek 8139D). If you
+	  have one of these, say Y here.
+
+	  To compile this driver as a module, choose M here: the module
+	  will be called sc92031.  This is recommended.
+
 source "drivers/net/ethernet/smc/Kconfig"
 source "drivers/net/ethernet/smsc/Kconfig"
 source "drivers/net/ethernet/sony/Kconfig"
diff --git a/drivers/net/ethernet/Makefile b/drivers/net/ethernet/Makefile
index 6c69e98..0fe59f4 100644
--- a/drivers/net/ethernet/Makefile
+++ b/drivers/net/ethernet/Makefile
@@ -46,6 +46,7 @@ obj-$(CONFIG_S6GMAC) += s6gmac.o
 obj-$(CONFIG_NET_VENDOR_SIS) += sis/
 obj-$(CONFIG_SFC) += sfc/
 obj-$(CONFIG_NET_VENDOR_SGI) += sgi/
+obj-$(CONFIG_SC92031) += sc92031.o
 obj-$(CONFIG_NET_VENDOR_SMC) += smc/
 obj-$(CONFIG_NET_VENDOR_SMSC) += smsc/
 obj-$(CONFIG_NET_VENDOR_SONY) += sony/
diff --git a/drivers/net/sc92031.c b/drivers/net/ethernet/sc92031.c
similarity index 100%
rename from drivers/net/sc92031.c
rename to drivers/net/ethernet/sc92031.c
-- 
1.7.5.4

