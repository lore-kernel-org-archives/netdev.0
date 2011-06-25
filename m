From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [RFC 41/72] sis*: Move the Silicon Integrated Systems (SiS) drivers
Date: Sat, 25 Jun 2011 06:58:52 -0700
Message-ID: <1309010363-22750-42-git-send-email-jeffrey.t.kirsher@intel.com>
References: <1309010363-22750-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: Jeff Kirsher <jeffrey.t.kirsher@intel.com>, netdev@vger.kernel.org,
	Daniele Venzano <venza@brownhat.org>,
	Francois Romieu <romieu@fr.zoreil.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga03.intel.com ([143.182.124.21]:37764 "EHLO mga03.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751933Ab1FYOAG (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sat, 25 Jun 2011 10:00:06 -0400
In-Reply-To: <1309010363-22750-1-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Move the SiS drivers into drivers/net/ethernet/sis/ and make the
necessary Kconfig and Makefile changes

CC: Daniele Venzano <venza@brownhat.org>
CC: Francois Romieu <romieu@fr.zoreil.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 MAINTAINERS                             |    4 +-
 drivers/net/Kconfig                     |   30 --------------------
 drivers/net/Makefile                    |    2 -
 drivers/net/ethernet/Kconfig            |    1 +
 drivers/net/ethernet/Makefile           |    1 +
 drivers/net/ethernet/sis/Kconfig        |   46 +++++++++++++++++++++++++++++++
 drivers/net/ethernet/sis/Makefile       |    6 ++++
 drivers/net/{ => ethernet/sis}/sis190.c |    0
 drivers/net/{ => ethernet/sis}/sis900.c |    0
 drivers/net/{ => ethernet/sis}/sis900.h |    0
 10 files changed, 56 insertions(+), 34 deletions(-)
 create mode 100644 drivers/net/ethernet/sis/Kconfig
 create mode 100644 drivers/net/ethernet/sis/Makefile
 rename drivers/net/{ => ethernet/sis}/sis190.c (100%)
 rename drivers/net/{ => ethernet/sis}/sis900.c (100%)
 rename drivers/net/{ => ethernet/sis}/sis900.h (100%)

diff --git a/MAINTAINERS b/MAINTAINERS
index 7fa33bd..fa2f1bb 100644
--- a/MAINTAINERS
+++ b/MAINTAINERS
@@ -5728,14 +5728,14 @@ SIS 190 ETHERNET DRIVER
 M:	Francois Romieu <romieu@fr.zoreil.com>
 L:	netdev@vger.kernel.org
 S:	Maintained
-F:	drivers/net/sis190.c
+F:	drivers/net/ethernet/sis/sis190.c
 
 SIS 900/7016 FAST ETHERNET DRIVER
 M:	Daniele Venzano <venza@brownhat.org>
 W:	http://www.brownhat.org/sis900.html
 L:	netdev@vger.kernel.org
 S:	Maintained
-F:	drivers/net/sis900.*
+F:	drivers/net/ethernet/sis/sis900.*
 
 SIS 96X I2C/SMBUS DRIVER
 M:	"Mark M. Hoffman" <mhoffman@lightlink.com>
diff --git a/drivers/net/Kconfig b/drivers/net/Kconfig
index b8894ad..37e06ae 100644
--- a/drivers/net/Kconfig
+++ b/drivers/net/Kconfig
@@ -570,22 +570,6 @@ config R6040
 	  To compile this driver as a module, choose M here: the module
 	  will be called r6040. This is recommended.
 
-config SIS900
-	tristate "SiS 900/7016 PCI Fast Ethernet Adapter support"
-	depends on NET_PCI && PCI
-	select CRC32
-	select MII
-	---help---
-	  This is a driver for the Fast Ethernet PCI network cards based on
-	  the SiS 900 and SiS 7016 chips. The SiS 900 core is also embedded in
-	  SiS 630 and SiS 540 chipsets.
-
-	  This driver also supports AMD 79C901 HomePNA so that you can use
-	  your phone line as a network cable.
-
-	  To compile this driver as a module, choose M here: the module
-	  will be called sis900.  This is recommended.
-
 config SUNDANCE
 	tristate "Sundance Alta support"
 	depends on NET_PCI && PCI
@@ -783,20 +767,6 @@ config YELLOWFIN
 	  To compile this driver as a module, choose M here: the module
 	  will be called yellowfin.  This is recommended.
 
-config SIS190
-	tristate "SiS190/SiS191 gigabit ethernet support"
-	depends on PCI
-	select CRC32
-	select MII
-	---help---
-	  Say Y here if you have a SiS 190 PCI Fast Ethernet adapter or
-	  a SiS 191 PCI Gigabit Ethernet adapter. Both are expected to
-	  appear in lan on motherboard designs which are based on SiS 965
-	  and SiS 966 south bridge.
-
-	  To compile this driver as a module, choose M here: the module
-	  will be called sis190.  This is recommended.
-
 config TSI108_ETH
 	tristate "Tundra TSI108 gigabit Ethernet support"
 	depends on TSI108_BRIDGE
diff --git a/drivers/net/Makefile b/drivers/net/Makefile
index fe9b44c..d1724fa 100644
--- a/drivers/net/Makefile
+++ b/drivers/net/Makefile
@@ -19,8 +19,6 @@ obj-$(CONFIG_PLIP) += plip.o
 obj-$(CONFIG_ROADRUNNER) += rrunner.o
 
 obj-$(CONFIG_TLAN) += tlan.o
-obj-$(CONFIG_SIS190) += sis190.o
-obj-$(CONFIG_SIS900) += sis900.o
 obj-$(CONFIG_R6040) += r6040.o
 obj-$(CONFIG_YELLOWFIN) += yellowfin.o
 obj-$(CONFIG_ISERIES_VETH) += iseries_veth.o
diff --git a/drivers/net/ethernet/Kconfig b/drivers/net/ethernet/Kconfig
index 9b5eca3..276a19d 100644
--- a/drivers/net/ethernet/Kconfig
+++ b/drivers/net/ethernet/Kconfig
@@ -48,6 +48,7 @@ config PASEMI_MAC
 source "drivers/net/ethernet/qlogic/Kconfig"
 source "drivers/net/ethernet/racal/Kconfig"
 source "drivers/net/ethernet/realtek/Kconfig"
+source "drivers/net/ethernet/sis/Kconfig"
 source "drivers/net/ethernet/sfc/Kconfig"
 source "drivers/net/ethernet/sgi/Kconfig"
 source "drivers/net/ethernet/smc/Kconfig"
diff --git a/drivers/net/ethernet/Makefile b/drivers/net/ethernet/Makefile
index 23ebc6e..dd94351 100644
--- a/drivers/net/ethernet/Makefile
+++ b/drivers/net/ethernet/Makefile
@@ -30,6 +30,7 @@ obj-$(CONFIG_PASEMI_MAC) += pasemi_mac.o pasemi_mac_ethtool.o
 obj-$(CONFIG_NET_VENDOR_QLOGIC) += qlogic/
 obj-$(CONFIG_NET_VENDOR_RACAL) += racal/
 obj-$(CONFIG_NET_VENDOR_REALTEK) += realtek/
+obj-$(CONFIG_NET_VENDOR_SIS) += sis/
 obj-$(CONFIG_SFC) += sfc/
 obj-$(CONFIG_NET_VENDOR_SGI) += sgi/
 obj-$(CONFIG_NET_VENDOR_SMC) += smc/
diff --git a/drivers/net/ethernet/sis/Kconfig b/drivers/net/ethernet/sis/Kconfig
new file mode 100644
index 0000000..cf40fe6
--- /dev/null
+++ b/drivers/net/ethernet/sis/Kconfig
@@ -0,0 +1,46 @@
+#
+# Silicon Integrated Systems (SiS) device configuration
+#
+
+config NET_VENDOR_SIS
+	bool "Silicon Integrated Systems (SiS) devices"
+	depends on PCI
+	---help---
+	  If you have a network (Ethernet) card belonging to this class, say Y
+	  and read the Ethernet-HOWTO, available from
+	  <http://www.tldp.org/docs.html#howto>.
+
+	  Note that the answer to this question doesn't directly affect the
+	  kernel: saying N will just cause the configurator to skip all
+	  the questions about SiS devices. If you say Y, you will be asked for
+	  your specific card in the following questions.
+
+config SIS900
+	tristate "SiS 900/7016 PCI Fast Ethernet Adapter support"
+	depends on NET_VENDOR_SIS && PCI
+	select CRC32
+	select MII
+	---help---
+	  This is a driver for the Fast Ethernet PCI network cards based on
+	  the SiS 900 and SiS 7016 chips. The SiS 900 core is also embedded in
+	  SiS 630 and SiS 540 chipsets.
+
+	  This driver also supports AMD 79C901 HomePNA so that you can use
+	  your phone line as a network cable.
+
+	  To compile this driver as a module, choose M here: the module
+	  will be called sis900.  This is recommended.
+
+config SIS190
+	tristate "SiS190/SiS191 gigabit ethernet support"
+	depends on NET_VENDOR_SIS && PCI
+	select CRC32
+	select MII
+	---help---
+	  Say Y here if you have a SiS 190 PCI Fast Ethernet adapter or
+	  a SiS 191 PCI Gigabit Ethernet adapter. Both are expected to
+	  appear in lan on motherboard designs which are based on SiS 965
+	  and SiS 966 south bridge.
+
+	  To compile this driver as a module, choose M here: the module
+	  will be called sis190.  This is recommended.
diff --git a/drivers/net/ethernet/sis/Makefile b/drivers/net/ethernet/sis/Makefile
new file mode 100644
index 0000000..58d3ac1
--- /dev/null
+++ b/drivers/net/ethernet/sis/Makefile
@@ -0,0 +1,6 @@
+#
+# Makefile for Silicon Integrated Systems (SiS) network device drivers.
+#
+
+obj-$(CONFIG_SIS190) += sis190.o
+obj-$(CONFIG_SIS900) += sis900.o
diff --git a/drivers/net/sis190.c b/drivers/net/ethernet/sis/sis190.c
similarity index 100%
rename from drivers/net/sis190.c
rename to drivers/net/ethernet/sis/sis190.c
diff --git a/drivers/net/sis900.c b/drivers/net/ethernet/sis/sis900.c
similarity index 100%
rename from drivers/net/sis900.c
rename to drivers/net/ethernet/sis/sis900.c
diff --git a/drivers/net/sis900.h b/drivers/net/ethernet/sis/sis900.h
similarity index 100%
rename from drivers/net/sis900.h
rename to drivers/net/ethernet/sis/sis900.h
-- 
1.7.5.4

