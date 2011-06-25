From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [RFC 34/72] skge/sky2: Move the SysKonnect Ethernet drivers
Date: Sat, 25 Jun 2011 06:58:45 -0700
Message-ID: <1309010363-22750-35-git-send-email-jeffrey.t.kirsher@intel.com>
References: <1309010363-22750-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: Jeff Kirsher <jeffrey.t.kirsher@intel.com>, netdev@vger.kernel.org,
	Stephen Hemminger <shemminger@linux-foundation.org>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga14.intel.com ([143.182.124.37]:13697 "EHLO mga14.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751952Ab1FYOAX (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sat, 25 Jun 2011 10:00:23 -0400
In-Reply-To: <1309010363-22750-1-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Move the SysKonnect Ethernet drivers into drivers/net/ethernet/syskonnect/
and make the necessary Kconfig and Makefile changes.

CC: Stephen Hemminger <shemminger@linux-foundation.org>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 MAINTAINERS                                  |    3 +-
 drivers/net/Kconfig                          |   58 --------------------
 drivers/net/Makefile                         |    2 -
 drivers/net/ethernet/Kconfig                 |    1 +
 drivers/net/ethernet/Makefile                |    1 +
 drivers/net/ethernet/syskonnect/Kconfig      |   74 ++++++++++++++++++++++++++
 drivers/net/ethernet/syskonnect/Makefile     |    6 ++
 drivers/net/{ => ethernet/syskonnect}/skge.c |    0
 drivers/net/{ => ethernet/syskonnect}/skge.h |    0
 drivers/net/{ => ethernet/syskonnect}/sky2.c |    0
 drivers/net/{ => ethernet/syskonnect}/sky2.h |    0
 11 files changed, 83 insertions(+), 62 deletions(-)
 create mode 100644 drivers/net/ethernet/syskonnect/Kconfig
 create mode 100644 drivers/net/ethernet/syskonnect/Makefile
 rename drivers/net/{ => ethernet/syskonnect}/skge.c (100%)
 rename drivers/net/{ => ethernet/syskonnect}/skge.h (100%)
 rename drivers/net/{ => ethernet/syskonnect}/sky2.c (100%)
 rename drivers/net/{ => ethernet/syskonnect}/sky2.h (100%)

diff --git a/MAINTAINERS b/MAINTAINERS
index c9bf3b5..98b3caf 100644
--- a/MAINTAINERS
+++ b/MAINTAINERS
@@ -5762,8 +5762,7 @@ SKGE, SKY2 10/100/1000 GIGABIT ETHERNET DRIVERS
 M:	Stephen Hemminger <shemminger@linux-foundation.org>
 L:	netdev@vger.kernel.org
 S:	Maintained
-F:	drivers/net/skge.*
-F:	drivers/net/sky2.*
+F:	drivers/net/ethernet/syskonnect/
 
 SLAB ALLOCATOR
 M:	Christoph Lameter <cl@linux-foundation.org>
diff --git a/drivers/net/Kconfig b/drivers/net/Kconfig
index 27e18b9..1f0c3bf 100644
--- a/drivers/net/Kconfig
+++ b/drivers/net/Kconfig
@@ -967,64 +967,6 @@ config SIS190
 	  To compile this driver as a module, choose M here: the module
 	  will be called sis190.  This is recommended.
 
-config SKGE
-	tristate "New SysKonnect GigaEthernet support"
-	depends on PCI
-	select CRC32
-	---help---
-	  This driver support the Marvell Yukon or SysKonnect SK-98xx/SK-95xx
-	  and related Gigabit Ethernet adapters. It is a new smaller driver
-	  with better performance and more complete ethtool support.
-
-	  It does not support the link failover and network management 
-	  features that "portable" vendor supplied sk98lin driver does.
-
-	  This driver supports adapters based on the original Yukon chipset:
-	  Marvell 88E8001, Belkin F5D5005, CNet GigaCard, DLink DGE-530T,
-	  Linksys EG1032/EG1064, 3Com 3C940/3C940B, SysKonnect SK-9871/9872.
-
-	  It does not support the newer Yukon2 chipset: a separate driver,
-	  sky2, is provided for Yukon2-based adapters.
-
-	  To compile this driver as a module, choose M here: the module
-	  will be called skge.  This is recommended.
-
-config SKGE_DEBUG
-	bool "Debugging interface"
-	depends on SKGE && DEBUG_FS
-	help
-	  This option adds the ability to dump driver state for debugging.
-	  The file /sys/kernel/debug/skge/ethX displays the state of the internal
-	  transmit and receive rings.
-
-	  If unsure, say N.
-
-config SKY2
-	tristate "SysKonnect Yukon2 support"
-	depends on PCI
-	select CRC32
-	---help---
-	  This driver supports Gigabit Ethernet adapters based on the
-	  Marvell Yukon 2 chipset:
-	  Marvell 88E8021/88E8022/88E8035/88E8036/88E8038/88E8050/88E8052/
-	  88E8053/88E8055/88E8061/88E8062, SysKonnect SK-9E21D/SK-9S21
-
-	  There is companion driver for the older Marvell Yukon and
-	  Genesis based adapters: skge.
-
-	  To compile this driver as a module, choose M here: the module
-	  will be called sky2.  This is recommended.
-
-config SKY2_DEBUG
-	bool "Debugging interface"
-	depends on SKY2 && DEBUG_FS
-	help
-	  This option adds the ability to dump driver state for debugging.
-	  The file /sys/kernel/debug/sky2/ethX displays the state of the internal
-	  transmit and receive rings.
-
-	  If unsure, say N.
-
 config VIA_VELOCITY
 	tristate "VIA Velocity support"
 	depends on PCI
diff --git a/drivers/net/Makefile b/drivers/net/Makefile
index fee2851..f32b45c 100644
--- a/drivers/net/Makefile
+++ b/drivers/net/Makefile
@@ -43,8 +43,6 @@ obj-$(CONFIG_GELIC_NET) += ps3_gelic.o
 gelic_wireless-$(CONFIG_GELIC_WIRELESS) += ps3_gelic_wireless.o
 ps3_gelic-objs += ps3_gelic_net.o $(gelic_wireless-y)
 obj-$(CONFIG_TC35815) += tc35815.o
-obj-$(CONFIG_SKGE) += skge.o
-obj-$(CONFIG_SKY2) += sky2.o
 obj-$(CONFIG_SKFP) += skfp/
 obj-$(CONFIG_KS8842)	+= ks8842.o
 obj-$(CONFIG_KS8851)	+= ks8851.o
diff --git a/drivers/net/ethernet/Kconfig b/drivers/net/ethernet/Kconfig
index cd3fd17..2795982 100644
--- a/drivers/net/ethernet/Kconfig
+++ b/drivers/net/ethernet/Kconfig
@@ -50,6 +50,7 @@ source "drivers/net/ethernet/smc/Kconfig"
 source "drivers/net/ethernet/smsc/Kconfig"
 source "drivers/net/ethernet/stmicro/Kconfig"
 source "drivers/net/ethernet/sun/Kconfig"
+source "drivers/net/ethernet/syskonnect/Kconfig"
 
 config TEHUTI
 	tristate "Tehuti Networks 10G Ethernet"
diff --git a/drivers/net/ethernet/Makefile b/drivers/net/ethernet/Makefile
index f4b36b6..eb3d827 100644
--- a/drivers/net/ethernet/Makefile
+++ b/drivers/net/ethernet/Makefile
@@ -32,5 +32,6 @@ obj-$(CONFIG_NET_VENDOR_SMC) += smc/
 obj-$(CONFIG_NET_VENDOR_SMSC) += smsc/
 obj-$(CONFIG_NET_VENDOR_STMICRO) += stmicro/
 obj-$(CONFIG_NET_VENDOR_SUN) += sun/
+obj-$(CONFIG_NET_VENDOR_SYSKONNECT) += syskonnect/
 obj-$(CONFIG_TEHUTI) += tehuti.o
 obj-$(CONFIG_NET_TULIP) += tulip/
diff --git a/drivers/net/ethernet/syskonnect/Kconfig b/drivers/net/ethernet/syskonnect/Kconfig
new file mode 100644
index 0000000..85b21c5
--- /dev/null
+++ b/drivers/net/ethernet/syskonnect/Kconfig
@@ -0,0 +1,74 @@
+#
+# SysKonnect device configuration
+#
+
+config NET_VENDOR_SYSKONNECT
+	bool "SysKonnect devices"
+	depends on PCI
+	---help---
+	  If you have a network (Ethernet) card belonging to this class, say Y
+	  and read the Ethernet-HOWTO, available from
+	  <http://www.tldp.org/docs.html#howto>.
+
+	  Note that the answer to this question doesn't directly affect the
+	  kernel: saying N will just cause the configurator to skip all
+	  the questions about SysKonnect devices. If you say Y, you will be
+	  asked for your specific card in the following questions.
+
+config SKGE
+	tristate "New SysKonnect GigaEthernet support"
+	depends on NET_VENDOR_SYSKONNECT && PCI
+	select CRC32
+	---help---
+	  This driver support the Marvell Yukon or SysKonnect SK-98xx/SK-95xx
+	  and related Gigabit Ethernet adapters. It is a new smaller driver
+	  with better performance and more complete ethtool support.
+
+	  It does not support the link failover and network management
+	  features that "portable" vendor supplied sk98lin driver does.
+
+	  This driver supports adapters based on the original Yukon chipset:
+	  Marvell 88E8001, Belkin F5D5005, CNet GigaCard, DLink DGE-530T,
+	  Linksys EG1032/EG1064, 3Com 3C940/3C940B, SysKonnect SK-9871/9872.
+
+	  It does not support the newer Yukon2 chipset: a separate driver,
+	  sky2, is provided for Yukon2-based adapters.
+
+	  To compile this driver as a module, choose M here: the module
+	  will be called skge.  This is recommended.
+
+config SKGE_DEBUG
+	bool "Debugging interface"
+	depends on SKGE && DEBUG_FS
+	---help---
+	  This option adds the ability to dump driver state for debugging.
+	  The file /sys/kernel/debug/skge/ethX displays the state of the internal
+	  transmit and receive rings.
+
+	  If unsure, say N.
+
+config SKY2
+	tristate "SysKonnect Yukon2 support"
+	depends on NET_VENDOR_SYSKONNECT && PCI
+	select CRC32
+	---help---
+	  This driver supports Gigabit Ethernet adapters based on the
+	  Marvell Yukon 2 chipset:
+	  Marvell 88E8021/88E8022/88E8035/88E8036/88E8038/88E8050/88E8052/
+	  88E8053/88E8055/88E8061/88E8062, SysKonnect SK-9E21D/SK-9S21
+
+	  There is companion driver for the older Marvell Yukon and
+	  Genesis based adapters: skge.
+
+	  To compile this driver as a module, choose M here: the module
+	  will be called sky2.  This is recommended.
+
+config SKY2_DEBUG
+	bool "Debugging interface"
+	depends on SKY2 && DEBUG_FS
+	---help---
+	  This option adds the ability to dump driver state for debugging.
+	  The file /sys/kernel/debug/sky2/ethX displays the state of the internal
+	  transmit and receive rings.
+
+	  If unsure, say N.
diff --git a/drivers/net/ethernet/syskonnect/Makefile b/drivers/net/ethernet/syskonnect/Makefile
new file mode 100644
index 0000000..76cc7be
--- /dev/null
+++ b/drivers/net/ethernet/syskonnect/Makefile
@@ -0,0 +1,6 @@
+#
+# Makefile for the SysKonnect device drivers.
+#
+
+obj-$(CONFIG_SKGE) += skge.o
+obj-$(CONFIG_SKY2) += sky2.o
diff --git a/drivers/net/skge.c b/drivers/net/ethernet/syskonnect/skge.c
similarity index 100%
rename from drivers/net/skge.c
rename to drivers/net/ethernet/syskonnect/skge.c
diff --git a/drivers/net/skge.h b/drivers/net/ethernet/syskonnect/skge.h
similarity index 100%
rename from drivers/net/skge.h
rename to drivers/net/ethernet/syskonnect/skge.h
diff --git a/drivers/net/sky2.c b/drivers/net/ethernet/syskonnect/sky2.c
similarity index 100%
rename from drivers/net/sky2.c
rename to drivers/net/ethernet/syskonnect/sky2.c
diff --git a/drivers/net/sky2.h b/drivers/net/ethernet/syskonnect/sky2.h
similarity index 100%
rename from drivers/net/sky2.h
rename to drivers/net/ethernet/syskonnect/sky2.h
-- 
1.7.5.4

