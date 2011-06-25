From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [RFC 49/72] jme: Move the JME driver
Date: Sat, 25 Jun 2011 06:59:00 -0700
Message-ID: <1309010363-22750-50-git-send-email-jeffrey.t.kirsher@intel.com>
References: <1309010363-22750-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: Jeff Kirsher <jeffrey.t.kirsher@intel.com>, netdev@vger.kernel.org,
	Guo-Fu Tseng <cooldavid@cooldavid.org>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga03.intel.com ([143.182.124.21]:37764 "EHLO mga03.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752253Ab1FYOAR (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sat, 25 Jun 2011 10:00:17 -0400
In-Reply-To: <1309010363-22750-1-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Move the JME driver into drivers/net/ethernet/ and make the
necessary Kconfig and Makefile changes.

CC: Guo-Fu Tseng <cooldavid@cooldavid.org>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 MAINTAINERS                      |    2 +-
 drivers/net/Kconfig              |   12 ------------
 drivers/net/Makefile             |    1 -
 drivers/net/ethernet/Kconfig     |   13 +++++++++++++
 drivers/net/ethernet/Makefile    |    1 +
 drivers/net/{ => ethernet}/jme.c |    0
 drivers/net/{ => ethernet}/jme.h |    0
 7 files changed, 15 insertions(+), 14 deletions(-)
 rename drivers/net/{ => ethernet}/jme.c (100%)
 rename drivers/net/{ => ethernet}/jme.h (100%)

diff --git a/MAINTAINERS b/MAINTAINERS
index 07ac87b..a0759c4 100644
--- a/MAINTAINERS
+++ b/MAINTAINERS
@@ -3553,7 +3553,7 @@ JME NETWORK DRIVER
 M:	Guo-Fu Tseng <cooldavid@cooldavid.org>
 L:	netdev@vger.kernel.org
 S:	Maintained
-F:	drivers/net/jme.*
+F:	drivers/net/ethernet/jme.*
 
 JOURNALLING FLASH FILE SYSTEM V2 (JFFS2)
 M:	David Woodhouse <dwmw2@infradead.org>
diff --git a/drivers/net/Kconfig b/drivers/net/Kconfig
index f4708d4..0e13828 100644
--- a/drivers/net/Kconfig
+++ b/drivers/net/Kconfig
@@ -653,18 +653,6 @@ config XILINX_LL_TEMAC
 	  This driver supports the Xilinx 10/100/1000 LocalLink TEMAC
 	  core used in Xilinx Spartan and Virtex FPGAs
 
-config JME
-	tristate "JMicron(R) PCI-Express Gigabit Ethernet support"
-	depends on PCI
-	select CRC32
-	select MII
-	---help---
-	  This driver supports the PCI-Express gigabit ethernet adapters
-	  based on JMicron JMC250 chipset.
-
-	  To compile this driver as a module, choose M here. The module
-	  will be called jme.
-
 endif # NETDEV_1000
 
 #
diff --git a/drivers/net/Makefile b/drivers/net/Makefile
index a53f0b3..58d1c38 100644
--- a/drivers/net/Makefile
+++ b/drivers/net/Makefile
@@ -8,7 +8,6 @@ obj-$(CONFIG_PHYLIB) += phy/
 obj-$(CONFIG_IP1000) += ipg.o
 obj-$(CONFIG_CAN) += can/
 obj-$(CONFIG_BONDING) += bonding/
-obj-$(CONFIG_JME) += jme.o
 obj-$(CONFIG_VMXNET3) += vmxnet3/
 
 #
diff --git a/drivers/net/ethernet/Kconfig b/drivers/net/ethernet/Kconfig
index 7e83747..0ae98cb 100644
--- a/drivers/net/ethernet/Kconfig
+++ b/drivers/net/ethernet/Kconfig
@@ -50,6 +50,19 @@ source "drivers/net/ethernet/faraday/Kconfig"
 source "drivers/net/ethernet/freescale/Kconfig"
 source "drivers/net/ethernet/ibm/Kconfig"
 source "drivers/net/ethernet/intel/Kconfig"
+
+config JME
+	tristate "JMicron(R) PCI-Express Gigabit Ethernet support"
+	depends on PCI
+	select CRC32
+	select MII
+	---help---
+	  This driver supports the PCI-Express gigabit ethernet adapters
+	  based on JMicron JMC250 chipset.
+
+	  To compile this driver as a module, choose M here. The module
+	  will be called jme.
+
 source "drivers/net/ethernet/marvell/Kconfig"
 source "drivers/net/ethernet/mellanox/Kconfig"
 source "drivers/net/ethernet/micrel/Kconfig"
diff --git a/drivers/net/ethernet/Makefile b/drivers/net/ethernet/Makefile
index b2f51c5..9b5df9f 100644
--- a/drivers/net/ethernet/Makefile
+++ b/drivers/net/ethernet/Makefile
@@ -21,6 +21,7 @@ obj-$(CONFIG_NET_VENDOR_FARADAY) += faraday/
 obj-$(CONFIG_NET_VENDOR_FREESCALE) += freescale/
 obj-$(CONFIG_NET_VENDOR_IBM) += ibm/
 obj-$(CONFIG_NET_VENDOR_INTEL) += intel/
+obj-$(CONFIG_JME) += jme.o
 obj-$(CONFIG_NET_VENDOR_MARVELL) += marvell/
 obj-$(CONFIG_NET_VENDOR_MELLANOX) += mellanox/
 obj-$(CONFIG_NET_VENDOR_MICREL) += micrel/
diff --git a/drivers/net/jme.c b/drivers/net/ethernet/jme.c
similarity index 100%
rename from drivers/net/jme.c
rename to drivers/net/ethernet/jme.c
diff --git a/drivers/net/jme.h b/drivers/net/ethernet/jme.h
similarity index 100%
rename from drivers/net/jme.h
rename to drivers/net/ethernet/jme.h
-- 
1.7.5.4

