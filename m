From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next v2 49/71] jme: Move the JME driver
Date: Sat, 30 Jul 2011 20:27:08 -0700
Message-ID: <1312082850-24914-50-git-send-email-jeffrey.t.kirsher@intel.com>
References: <1312082850-24914-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: Jeff Kirsher <jeffrey.t.kirsher@intel.com>, netdev@vger.kernel.org,
	gospo@redhat.com, sassmann@redhat.com,
	Guo-Fu Tseng <cooldavid@cooldavid.org>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga03.intel.com ([143.182.124.21]:38846 "EHLO mga03.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753175Ab1GaD2Y (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sat, 30 Jul 2011 23:28:24 -0400
In-Reply-To: <1312082850-24914-1-git-send-email-jeffrey.t.kirsher@intel.com>
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
index ae204ed..940df7b 100644
--- a/MAINTAINERS
+++ b/MAINTAINERS
@@ -3573,7 +3573,7 @@ JME NETWORK DRIVER
 M:	Guo-Fu Tseng <cooldavid@cooldavid.org>
 L:	netdev@vger.kernel.org
 S:	Maintained
-F:	drivers/net/jme.*
+F:	drivers/net/ethernet/jme.*
 
 JOURNALLING FLASH FILE SYSTEM V2 (JFFS2)
 M:	David Woodhouse <dwmw2@infradead.org>
diff --git a/drivers/net/Kconfig b/drivers/net/Kconfig
index 2ad05a8..60e850d 100644
--- a/drivers/net/Kconfig
+++ b/drivers/net/Kconfig
@@ -547,18 +547,6 @@ config XILINX_LL_TEMAC
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
index 648fa5c..271fc52 100644
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
index 70c60ef..c29c145 100644
--- a/drivers/net/ethernet/Kconfig
+++ b/drivers/net/ethernet/Kconfig
@@ -31,6 +31,19 @@ source "drivers/net/ethernet/ibm/Kconfig"
 source "drivers/net/ethernet/intel/Kconfig"
 source "drivers/net/ethernet/i825xx/Kconfig"
 source "drivers/net/ethernet/xscale/Kconfig"
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
index 929ee29..8495c50 100644
--- a/drivers/net/ethernet/Makefile
+++ b/drivers/net/ethernet/Makefile
@@ -23,6 +23,7 @@ obj-$(CONFIG_NET_VENDOR_IBM) += ibm/
 obj-$(CONFIG_NET_VENDOR_INTEL) += intel/
 obj-$(CONFIG_NET_VENDOR_I825XX) += i825xx/
 obj-$(CONFIG_NET_VENDOR_XSCALE) += xscale/
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
1.7.6

