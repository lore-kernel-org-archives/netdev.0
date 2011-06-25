From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [RFC 33/72] pch_gbe: Move the OKI driver
Date: Sat, 25 Jun 2011 06:58:44 -0700
Message-ID: <1309010363-22750-34-git-send-email-jeffrey.t.kirsher@intel.com>
References: <1309010363-22750-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: Jeff Kirsher <jeffrey.t.kirsher@intel.com>, netdev@vger.kernel.org,
	Tomoya <tomoya-linux@dsn.okisemi.com>,
	Toshiharu Okada <toshiharu-linux@dsn.okisemi.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga03.intel.com ([143.182.124.21]:37764 "EHLO mga03.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752042Ab1FYN75 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sat, 25 Jun 2011 09:59:57 -0400
In-Reply-To: <1309010363-22750-1-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Move the OKI driver into driver/net/ethernet/oki/ and make the
necessary Kconfig and Makefile changes.

Note: there is no documented maintainer for this driver, so I CC'd
the last 2 major contributors.

CC: Tomoya <tomoya-linux@dsn.okisemi.com>
CC: Toshiharu Okada <toshiharu-linux@dsn.okisemi.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 drivers/net/Kconfig                                |   19 -------------------
 drivers/net/Makefile                               |    1 -
 drivers/net/ethernet/Kconfig                       |    1 +
 drivers/net/ethernet/Makefile                      |    1 +
 drivers/net/ethernet/oki/Kconfig                   |   18 ++++++++++++++++++
 drivers/net/ethernet/oki/Makefile                  |    5 +++++
 drivers/net/ethernet/oki/pch_gbe/Kconfig           |   20 ++++++++++++++++++++
 drivers/net/{ => ethernet/oki}/pch_gbe/Makefile    |    0
 drivers/net/{ => ethernet/oki}/pch_gbe/pch_gbe.h   |    0
 .../net/{ => ethernet/oki}/pch_gbe/pch_gbe_api.c   |    0
 .../net/{ => ethernet/oki}/pch_gbe/pch_gbe_api.h   |    0
 .../{ => ethernet/oki}/pch_gbe/pch_gbe_ethtool.c   |    0
 .../net/{ => ethernet/oki}/pch_gbe/pch_gbe_main.c  |    0
 .../net/{ => ethernet/oki}/pch_gbe/pch_gbe_param.c |    0
 .../net/{ => ethernet/oki}/pch_gbe/pch_gbe_phy.c   |    0
 .../net/{ => ethernet/oki}/pch_gbe/pch_gbe_phy.h   |    0
 16 files changed, 45 insertions(+), 20 deletions(-)
 create mode 100644 drivers/net/ethernet/oki/Kconfig
 create mode 100644 drivers/net/ethernet/oki/Makefile
 create mode 100644 drivers/net/ethernet/oki/pch_gbe/Kconfig
 rename drivers/net/{ => ethernet/oki}/pch_gbe/Makefile (100%)
 rename drivers/net/{ => ethernet/oki}/pch_gbe/pch_gbe.h (100%)
 rename drivers/net/{ => ethernet/oki}/pch_gbe/pch_gbe_api.c (100%)
 rename drivers/net/{ => ethernet/oki}/pch_gbe/pch_gbe_api.h (100%)
 rename drivers/net/{ => ethernet/oki}/pch_gbe/pch_gbe_ethtool.c (100%)
 rename drivers/net/{ => ethernet/oki}/pch_gbe/pch_gbe_main.c (100%)
 rename drivers/net/{ => ethernet/oki}/pch_gbe/pch_gbe_param.c (100%)
 rename drivers/net/{ => ethernet/oki}/pch_gbe/pch_gbe_phy.c (100%)
 rename drivers/net/{ => ethernet/oki}/pch_gbe/pch_gbe_phy.h (100%)

diff --git a/drivers/net/Kconfig b/drivers/net/Kconfig
index 17db195..27e18b9 100644
--- a/drivers/net/Kconfig
+++ b/drivers/net/Kconfig
@@ -1150,25 +1150,6 @@ config S6GMAC
 	  To compile this driver as a module, choose M here. The module
 	  will be called s6gmac.
 
-config PCH_GBE
-	tristate "Intel EG20T PCH / OKI SEMICONDUCTOR ML7223 IOH GbE"
-	depends on PCI
-	select MII
-	---help---
-	  This is a gigabit ethernet driver for EG20T PCH.
-	  EG20T PCH is the platform controller hub that is used in Intel's
-	  general embedded platform.
-	  EG20T PCH has Gigabit Ethernet interface.
-	  Using this interface, it is able to access system devices connected
-	  to Gigabit Ethernet.
-	  This driver enables Gigabit Ethernet function.
-
-	  This driver also can be used for OKI SEMICONDUCTOR IOH(Input/
-	  Output Hub), ML7223.
-	  ML7223 IOH is for MP(Media Phone) use.
-	  ML7223 is companion chip for Intel Atom E6xx series.
-	  ML7223 is completely compatible for Intel EG20T PCH.
-
 endif # NETDEV_1000
 
 #
diff --git a/drivers/net/Makefile b/drivers/net/Makefile
index 24d89c0..fee2851 100644
--- a/drivers/net/Makefile
+++ b/drivers/net/Makefile
@@ -172,5 +172,4 @@ obj-$(CONFIG_WIMAX) += wimax/
 obj-$(CONFIG_CAIF) += caif/
 
 obj-$(CONFIG_OCTEON_MGMT_ETHERNET) += octeon/
-obj-$(CONFIG_PCH_GBE) += pch_gbe/
 obj-$(CONFIG_TILE_NET) += tile/
diff --git a/drivers/net/ethernet/Kconfig b/drivers/net/ethernet/Kconfig
index 0c4ba94..cd3fd17 100644
--- a/drivers/net/ethernet/Kconfig
+++ b/drivers/net/ethernet/Kconfig
@@ -30,6 +30,7 @@ source "drivers/net/ethernet/mellanox/Kconfig"
 source "drivers/net/ethernet/myricom/Kconfig"
 source "drivers/net/ethernet/natsemi/Kconfig"
 source "drivers/net/ethernet/8390/Kconfig"
+source "drivers/net/ethernet/oki/Kconfig"
 
 config PASEMI_MAC
 	tristate "PA Semi 1/10Gbit MAC"
diff --git a/drivers/net/ethernet/Makefile b/drivers/net/ethernet/Makefile
index 5a27837..f4b36b6 100644
--- a/drivers/net/ethernet/Makefile
+++ b/drivers/net/ethernet/Makefile
@@ -21,6 +21,7 @@ obj-$(CONFIG_NET_VENDOR_INTEL) += intel/
 obj-$(CONFIG_NET_VENDOR_MELLANOX) += mellanox/
 obj-$(CONFIG_NET_VENDOR_MYRI) += myricom/
 obj-$(CONFIG_NET_VENDOR_NATSEMI) += natsemi/
+obj-$(CONFIG_NET_VENDOR_OKI) += oki/
 obj-$(CONFIG_PASEMI_MAC) += pasemi_mac.o pasemi_mac_ethtool.o
 obj-$(CONFIG_NET_VENDOR_QLOGIC) += qlogic/
 obj-$(CONFIG_NET_VENDOR_RACAL) += racal/
diff --git a/drivers/net/ethernet/oki/Kconfig b/drivers/net/ethernet/oki/Kconfig
new file mode 100644
index 0000000..a20f442
--- /dev/null
+++ b/drivers/net/ethernet/oki/Kconfig
@@ -0,0 +1,18 @@
+#
+# OKI Semiconductor device configuration
+#
+
+config NET_VENDOR_OKI
+	bool "OKI Semiconductor devices"
+	depends on PCI
+	---help---
+	  If you have a network (Ethernet) card belonging to this class, say Y
+	  and read the Ethernet-HOWTO, available from
+	  <http://www.tldp.org/docs.html#howto>.
+
+	  Note that the answer to this question doesn't directly affect the
+	  kernel: saying N will just cause the configurator to skip all
+	  the questions about OKI Semiconductor cards. If you say Y, you will
+	  be asked for your specific card in the following questions.
+
+source "drivers/net/ethernet/oki/pch_gbe/Kconfig"
diff --git a/drivers/net/ethernet/oki/Makefile b/drivers/net/ethernet/oki/Makefile
new file mode 100644
index 0000000..b6780c8
--- /dev/null
+++ b/drivers/net/ethernet/oki/Makefile
@@ -0,0 +1,5 @@
+#
+# Makefile for the OKI Semiconductor device drivers.
+#
+
+obj-$(CONFIG_PCH_GBE) += pch_gbe/
diff --git a/drivers/net/ethernet/oki/pch_gbe/Kconfig b/drivers/net/ethernet/oki/pch_gbe/Kconfig
new file mode 100644
index 0000000..f66fefa
--- /dev/null
+++ b/drivers/net/ethernet/oki/pch_gbe/Kconfig
@@ -0,0 +1,20 @@
+#
+# OKI Semiconductor device configuration
+#
+
+config PCH_GBE
+	tristate "OKI SEMICONDUCTOR ML7223 IOH GbE (Intel EG20T PCH)"
+	depends on NET_VENDOR_OKI && PCI
+	select MII
+	---help---
+	  This is a gigabit ethernet driver for EG20T PCH.
+	  EG20T PCH is the platform controller hub that is used in Intel's
+	  general embedded platform.  EG20T PCH has Gigabit Ethernet interface.
+	  Using this interface, it is able to access system devices connected
+	  to Gigabit Ethernet.  This driver enables Gigabit Ethernet function.
+
+	  This driver also can be used for OKI SEMICONDUCTOR IOH(Input/
+	  Output Hub), ML7223.
+	  ML7223 IOH is for MP(Media Phone) use.
+	  ML7223 is companion chip for Intel Atom E6xx series.
+	  ML7223 is completely compatible for Intel EG20T PCH.
diff --git a/drivers/net/pch_gbe/Makefile b/drivers/net/ethernet/oki/pch_gbe/Makefile
similarity index 100%
rename from drivers/net/pch_gbe/Makefile
rename to drivers/net/ethernet/oki/pch_gbe/Makefile
diff --git a/drivers/net/pch_gbe/pch_gbe.h b/drivers/net/ethernet/oki/pch_gbe/pch_gbe.h
similarity index 100%
rename from drivers/net/pch_gbe/pch_gbe.h
rename to drivers/net/ethernet/oki/pch_gbe/pch_gbe.h
diff --git a/drivers/net/pch_gbe/pch_gbe_api.c b/drivers/net/ethernet/oki/pch_gbe/pch_gbe_api.c
similarity index 100%
rename from drivers/net/pch_gbe/pch_gbe_api.c
rename to drivers/net/ethernet/oki/pch_gbe/pch_gbe_api.c
diff --git a/drivers/net/pch_gbe/pch_gbe_api.h b/drivers/net/ethernet/oki/pch_gbe/pch_gbe_api.h
similarity index 100%
rename from drivers/net/pch_gbe/pch_gbe_api.h
rename to drivers/net/ethernet/oki/pch_gbe/pch_gbe_api.h
diff --git a/drivers/net/pch_gbe/pch_gbe_ethtool.c b/drivers/net/ethernet/oki/pch_gbe/pch_gbe_ethtool.c
similarity index 100%
rename from drivers/net/pch_gbe/pch_gbe_ethtool.c
rename to drivers/net/ethernet/oki/pch_gbe/pch_gbe_ethtool.c
diff --git a/drivers/net/pch_gbe/pch_gbe_main.c b/drivers/net/ethernet/oki/pch_gbe/pch_gbe_main.c
similarity index 100%
rename from drivers/net/pch_gbe/pch_gbe_main.c
rename to drivers/net/ethernet/oki/pch_gbe/pch_gbe_main.c
diff --git a/drivers/net/pch_gbe/pch_gbe_param.c b/drivers/net/ethernet/oki/pch_gbe/pch_gbe_param.c
similarity index 100%
rename from drivers/net/pch_gbe/pch_gbe_param.c
rename to drivers/net/ethernet/oki/pch_gbe/pch_gbe_param.c
diff --git a/drivers/net/pch_gbe/pch_gbe_phy.c b/drivers/net/ethernet/oki/pch_gbe/pch_gbe_phy.c
similarity index 100%
rename from drivers/net/pch_gbe/pch_gbe_phy.c
rename to drivers/net/ethernet/oki/pch_gbe/pch_gbe_phy.c
diff --git a/drivers/net/pch_gbe/pch_gbe_phy.h b/drivers/net/ethernet/oki/pch_gbe/pch_gbe_phy.h
similarity index 100%
rename from drivers/net/pch_gbe/pch_gbe_phy.h
rename to drivers/net/ethernet/oki/pch_gbe/pch_gbe_phy.h
-- 
1.7.5.4

