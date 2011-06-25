From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [RFC 52/72] ps3_gelic*: Move the Sony (PS3) drivers
Date: Sat, 25 Jun 2011 06:59:03 -0700
Message-ID: <1309010363-22750-53-git-send-email-jeffrey.t.kirsher@intel.com>
References: <1309010363-22750-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: Jeff Kirsher <jeffrey.t.kirsher@intel.com>, netdev@vger.kernel.org,
	Geoff Levand <geoff@infradead.org>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga03.intel.com ([143.182.124.21]:41778 "EHLO mga03.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752329Ab1FYOAV (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sat, 25 Jun 2011 10:00:21 -0400
In-Reply-To: <1309010363-22750-1-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Move the Sony drivers into drivers/net/ethernet/sony/ and
make the necessary Kconfig and Makefile changes.

TODO: separate the wired and wireless drivers and relocate the wireless
dirver into drivers/net/wireless/

CC: Geoff Levand <geoff@infradead.org>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 MAINTAINERS                                        |    2 +-
 drivers/net/Kconfig                                |   23 ------------
 drivers/net/Makefile                               |    3 --
 drivers/net/ethernet/Kconfig                       |    1 +
 drivers/net/ethernet/Makefile                      |    1 +
 drivers/net/ethernet/sony/Kconfig                  |   38 ++++++++++++++++++++
 drivers/net/ethernet/sony/Makefile                 |    7 ++++
 drivers/net/{ => ethernet/sony}/ps3_gelic_net.c    |    0
 drivers/net/{ => ethernet/sony}/ps3_gelic_net.h    |    0
 .../net/{ => ethernet/sony}/ps3_gelic_wireless.c   |    0
 .../net/{ => ethernet/sony}/ps3_gelic_wireless.h   |    0
 11 files changed, 48 insertions(+), 27 deletions(-)
 create mode 100644 drivers/net/ethernet/sony/Kconfig
 create mode 100644 drivers/net/ethernet/sony/Makefile
 rename drivers/net/{ => ethernet/sony}/ps3_gelic_net.c (100%)
 rename drivers/net/{ => ethernet/sony}/ps3_gelic_net.h (100%)
 rename drivers/net/{ => ethernet/sony}/ps3_gelic_wireless.c (100%)
 rename drivers/net/{ => ethernet/sony}/ps3_gelic_wireless.h (100%)

diff --git a/MAINTAINERS b/MAINTAINERS
index a59a17a..53e2d11 100644
--- a/MAINTAINERS
+++ b/MAINTAINERS
@@ -5049,7 +5049,7 @@ M:	Geoff Levand <geoff@infradead.org>
 L:	netdev@vger.kernel.org
 L:	cbe-oss-dev@lists.ozlabs.org
 S:	Maintained
-F:	drivers/net/ps3_gelic_net.*
+F:	drivers/net/ethernet/sony/ps3_gelic_net.*
 
 PS3 PLATFORM SUPPORT
 M:	Geoff Levand <geoff@infradead.org>
diff --git a/drivers/net/Kconfig b/drivers/net/Kconfig
index 366538b..211679e 100644
--- a/drivers/net/Kconfig
+++ b/drivers/net/Kconfig
@@ -605,29 +605,6 @@ menuconfig NETDEV_1000
 
 if NETDEV_1000
 
-config GELIC_NET
-	tristate "PS3 Gigabit Ethernet driver"
-	depends on PPC_PS3
-	select PS3_SYS_MANAGER
-	help
-	  This driver supports the network device on the PS3 game
-	  console.  This driver has built-in support for Ethernet.
-
-	  To compile this driver as a module, choose M here: the
-	  module will be called ps3_gelic.
-
-config GELIC_WIRELESS
-	bool "PS3 Wireless support"
-	depends on WLAN
-	depends on GELIC_NET
-	select WIRELESS_EXT
-	help
-	  This option adds the support for the wireless feature of PS3.
-	  If you have the wireless-less model of PS3 or have no plan to
-	  use wireless feature, disabling this option saves memory.  As
-	  the driver automatically distinguishes the models, you can
-	  safely enable this option even if you have a wireless-less model.
-
 endif # NETDEV_1000
 
 #
diff --git a/drivers/net/Makefile b/drivers/net/Makefile
index b5e25f1..5413c17 100644
--- a/drivers/net/Makefile
+++ b/drivers/net/Makefile
@@ -19,9 +19,6 @@ obj-$(CONFIG_ROADRUNNER) += rrunner.o
 obj-$(CONFIG_R6040) += r6040.o
 obj-$(CONFIG_ISERIES_VETH) += iseries_veth.o
 obj-$(CONFIG_FEALNX) += fealnx.o
-obj-$(CONFIG_GELIC_NET) += ps3_gelic.o
-gelic_wireless-$(CONFIG_GELIC_WIRELESS) += ps3_gelic_wireless.o
-ps3_gelic-objs += ps3_gelic_net.o $(gelic_wireless-y)
 obj-$(CONFIG_TC35815) += tc35815.o
 obj-$(CONFIG_SKFP) += skfp/
 obj-$(CONFIG_ADAPTEC_STARFIRE) += starfire.o
diff --git a/drivers/net/ethernet/Kconfig b/drivers/net/ethernet/Kconfig
index 4bafe48..fda90fc 100644
--- a/drivers/net/ethernet/Kconfig
+++ b/drivers/net/ethernet/Kconfig
@@ -106,6 +106,7 @@ source "drivers/net/ethernet/sfc/Kconfig"
 source "drivers/net/ethernet/sgi/Kconfig"
 source "drivers/net/ethernet/smc/Kconfig"
 source "drivers/net/ethernet/smsc/Kconfig"
+source "drivers/net/ethernet/sony/Kconfig"
 source "drivers/net/ethernet/stmicro/Kconfig"
 source "drivers/net/ethernet/sun/Kconfig"
 source "drivers/net/ethernet/syskonnect/Kconfig"
diff --git a/drivers/net/ethernet/Makefile b/drivers/net/ethernet/Makefile
index 0b6ffde..3588c50 100644
--- a/drivers/net/ethernet/Makefile
+++ b/drivers/net/ethernet/Makefile
@@ -44,6 +44,7 @@ obj-$(CONFIG_SFC) += sfc/
 obj-$(CONFIG_NET_VENDOR_SGI) += sgi/
 obj-$(CONFIG_NET_VENDOR_SMC) += smc/
 obj-$(CONFIG_NET_VENDOR_SMSC) += smsc/
+obj-$(CONFIG_NET_VENDOR_SONY) += sony/
 obj-$(CONFIG_NET_VENDOR_STMICRO) += stmicro/
 obj-$(CONFIG_NET_VENDOR_SUN) += sun/
 obj-$(CONFIG_NET_VENDOR_SYSKONNECT) += syskonnect/
diff --git a/drivers/net/ethernet/sony/Kconfig b/drivers/net/ethernet/sony/Kconfig
new file mode 100644
index 0000000..183ddf0
--- /dev/null
+++ b/drivers/net/ethernet/sony/Kconfig
@@ -0,0 +1,38 @@
+#
+# Sony (PS3) device configuration
+#
+
+config NET_VENDOR_SONY
+	bool "Sony (PS3) devices"
+	depends on PPC_PS3
+	---help---
+	  If you have a network (Ethernet) card belonging to this class, say Y
+	  and read the Ethernet-HOWTO, available from
+	  <http://www.tldp.org/docs.html#howto>.
+
+	  Note that the answer to this question doesn't directly affect the
+	  kernel: saying N will just cause the configurator to skip all
+	  the questions about Sony devices. If you say Y, you will be asked for
+	  your specific card in the following questions.
+
+config GELIC_NET
+	tristate "PS3 Gigabit Ethernet driver"
+	depends on NET_VENDOR_SONY && PPC_PS3
+	select PS3_SYS_MANAGER
+	---help---
+	  This driver supports the network device on the PS3 game
+	  console.  This driver has built-in support for Ethernet.
+
+	  To compile this driver as a module, choose M here: the
+	  module will be called ps3_gelic.
+
+config GELIC_WIRELESS
+	bool "PS3 Wireless support"
+	depends on NET_VENDOR_SONY && GELIC_NET && WLAN
+	select WIRELESS_EXT
+	---help---
+	  This option adds the support for the wireless feature of PS3.
+	  If you have the wireless-less model of PS3 or have no plan to
+	  use wireless feature, disabling this option saves memory.  As
+	  the driver automatically distinguishes the models, you can
+	  safely enable this option even if you have a wireless-less model.
diff --git a/drivers/net/ethernet/sony/Makefile b/drivers/net/ethernet/sony/Makefile
new file mode 100644
index 0000000..2c6f934
--- /dev/null
+++ b/drivers/net/ethernet/sony/Makefile
@@ -0,0 +1,7 @@
+#
+# Makefile for the Sony (PS3) network devices.
+#
+
+obj-$(CONFIG_GELIC_NET) += ps3_gelic.o
+gelic_wireless-$(CONFIG_GELIC_WIRELESS) += ps3_gelic_wireless.o
+ps3_gelic-objs += ps3_gelic_net.o $(gelic_wireless-y)
diff --git a/drivers/net/ps3_gelic_net.c b/drivers/net/ethernet/sony/ps3_gelic_net.c
similarity index 100%
rename from drivers/net/ps3_gelic_net.c
rename to drivers/net/ethernet/sony/ps3_gelic_net.c
diff --git a/drivers/net/ps3_gelic_net.h b/drivers/net/ethernet/sony/ps3_gelic_net.h
similarity index 100%
rename from drivers/net/ps3_gelic_net.h
rename to drivers/net/ethernet/sony/ps3_gelic_net.h
diff --git a/drivers/net/ps3_gelic_wireless.c b/drivers/net/ethernet/sony/ps3_gelic_wireless.c
similarity index 100%
rename from drivers/net/ps3_gelic_wireless.c
rename to drivers/net/ethernet/sony/ps3_gelic_wireless.c
diff --git a/drivers/net/ps3_gelic_wireless.h b/drivers/net/ethernet/sony/ps3_gelic_wireless.h
similarity index 100%
rename from drivers/net/ps3_gelic_wireless.h
rename to drivers/net/ethernet/sony/ps3_gelic_wireless.h
-- 
1.7.5.4

