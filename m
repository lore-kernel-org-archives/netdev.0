From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next 04/10] pch_gbe: Move the OKI Semiconductor driver
Date: Fri, 12 Aug 2011 00:32:58 -0700
Message-ID: <1313134384-7287-5-git-send-email-jeffrey.t.kirsher@intel.com>
References: <1313134384-7287-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: Jeff Kirsher <jeffrey.t.kirsher@intel.com>, netdev@vger.kernel.org,
	gospo@redhat.com, sassmann@redhat.com,
	Tomoya <tomoya-linux@dsn.okisemi.com>,
	Toshiharu Okada <toshiharu-linux@dsn.okisemi.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga09.intel.com ([134.134.136.24]:58636 "EHLO mga09.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750890Ab1HLHdK (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 12 Aug 2011 03:33:10 -0400
In-Reply-To: <1313134384-7287-1-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Move the OKI Semiconductor driver into driver/net/ethernet/oki-semi/
and make the necessary Kconfig and Makefile changes.

Note: there is no documented maintainer for this driver, so I CC'd
the last 2 major contributors.

CC: Tomoya <tomoya-linux@dsn.okisemi.com>
CC: Toshiharu Okada <toshiharu-linux@dsn.okisemi.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 drivers/net/Kconfig                                |   19 -----------------
 drivers/net/Makefile                               |    1 -
 drivers/net/ethernet/Kconfig                       |    1 +
 drivers/net/ethernet/Makefile                      |    1 +
 drivers/net/ethernet/oki-semi/Kconfig              |   22 ++++++++++++++++++++
 drivers/net/ethernet/oki-semi/Makefile             |    5 ++++
 drivers/net/ethernet/oki-semi/pch_gbe/Kconfig      |   20 ++++++++++++++++++
 .../net/{ => ethernet/oki-semi}/pch_gbe/Makefile   |    0
 .../net/{ => ethernet/oki-semi}/pch_gbe/pch_gbe.h  |    0
 .../{ => ethernet/oki-semi}/pch_gbe/pch_gbe_api.c  |    0
 .../{ => ethernet/oki-semi}/pch_gbe/pch_gbe_api.h  |    0
 .../oki-semi}/pch_gbe/pch_gbe_ethtool.c            |    0
 .../{ => ethernet/oki-semi}/pch_gbe/pch_gbe_main.c |    0
 .../oki-semi}/pch_gbe/pch_gbe_param.c              |    0
 .../{ => ethernet/oki-semi}/pch_gbe/pch_gbe_phy.c  |    0
 .../{ => ethernet/oki-semi}/pch_gbe/pch_gbe_phy.h  |    0
 16 files changed, 49 insertions(+), 20 deletions(-)
 create mode 100644 drivers/net/ethernet/oki-semi/Kconfig
 create mode 100644 drivers/net/ethernet/oki-semi/Makefile
 create mode 100644 drivers/net/ethernet/oki-semi/pch_gbe/Kconfig
 rename drivers/net/{ => ethernet/oki-semi}/pch_gbe/Makefile (100%)
 rename drivers/net/{ => ethernet/oki-semi}/pch_gbe/pch_gbe.h (100%)
 rename drivers/net/{ => ethernet/oki-semi}/pch_gbe/pch_gbe_api.c (100%)
 rename drivers/net/{ => ethernet/oki-semi}/pch_gbe/pch_gbe_api.h (100%)
 rename drivers/net/{ => ethernet/oki-semi}/pch_gbe/pch_gbe_ethtool.c (100%)
 rename drivers/net/{ => ethernet/oki-semi}/pch_gbe/pch_gbe_main.c (100%)
 rename drivers/net/{ => ethernet/oki-semi}/pch_gbe/pch_gbe_param.c (100%)
 rename drivers/net/{ => ethernet/oki-semi}/pch_gbe/pch_gbe_phy.c (100%)
 rename drivers/net/{ => ethernet/oki-semi}/pch_gbe/pch_gbe_phy.h (100%)

diff --git a/drivers/net/Kconfig b/drivers/net/Kconfig
index 696464c..87e7a12 100644
--- a/drivers/net/Kconfig
+++ b/drivers/net/Kconfig
@@ -996,25 +996,6 @@ config S6GMAC
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
index b1ead87..141ed25 100644
--- a/drivers/net/Makefile
+++ b/drivers/net/Makefile
@@ -156,5 +156,4 @@ obj-$(CONFIG_WIMAX) += wimax/
 obj-$(CONFIG_CAIF) += caif/
 
 obj-$(CONFIG_OCTEON_MGMT_ETHERNET) += octeon/
-obj-$(CONFIG_PCH_GBE) += pch_gbe/
 obj-$(CONFIG_TILE_NET) += tile/
diff --git a/drivers/net/ethernet/Kconfig b/drivers/net/ethernet/Kconfig
index 35ed4c2..0eaf957 100644
--- a/drivers/net/ethernet/Kconfig
+++ b/drivers/net/ethernet/Kconfig
@@ -32,6 +32,7 @@ source "drivers/net/ethernet/mellanox/Kconfig"
 source "drivers/net/ethernet/myricom/Kconfig"
 source "drivers/net/ethernet/natsemi/Kconfig"
 source "drivers/net/ethernet/8390/Kconfig"
+source "drivers/net/ethernet/oki-semi/Kconfig"
 source "drivers/net/ethernet/pasemi/Kconfig"
 source "drivers/net/ethernet/qlogic/Kconfig"
 source "drivers/net/ethernet/racal/Kconfig"
diff --git a/drivers/net/ethernet/Makefile b/drivers/net/ethernet/Makefile
index ea0999f..b5ca872 100644
--- a/drivers/net/ethernet/Makefile
+++ b/drivers/net/ethernet/Makefile
@@ -23,6 +23,7 @@ obj-$(CONFIG_NET_VENDOR_XSCALE) += xscale/
 obj-$(CONFIG_NET_VENDOR_MELLANOX) += mellanox/
 obj-$(CONFIG_NET_VENDOR_MYRI) += myricom/
 obj-$(CONFIG_NET_VENDOR_NATSEMI) += natsemi/
+obj-$(CONFIG_NET_VENDOR_OKI) += oki-semi/
 obj-$(CONFIG_NET_VENDOR_PASEMI) += pasemi/
 obj-$(CONFIG_NET_VENDOR_QLOGIC) += qlogic/
 obj-$(CONFIG_NET_VENDOR_RACAL) += racal/
diff --git a/drivers/net/ethernet/oki-semi/Kconfig b/drivers/net/ethernet/oki-semi/Kconfig
new file mode 100644
index 0000000..97f5e72
--- /dev/null
+++ b/drivers/net/ethernet/oki-semi/Kconfig
@@ -0,0 +1,22 @@
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
+if NET_VENDOR_OKI
+
+source "drivers/net/ethernet/oki-semi/pch_gbe/Kconfig"
+
+endif # NET_VENDOR_OKI
diff --git a/drivers/net/ethernet/oki-semi/Makefile b/drivers/net/ethernet/oki-semi/Makefile
new file mode 100644
index 0000000..b6780c8
--- /dev/null
+++ b/drivers/net/ethernet/oki-semi/Makefile
@@ -0,0 +1,5 @@
+#
+# Makefile for the OKI Semiconductor device drivers.
+#
+
+obj-$(CONFIG_PCH_GBE) += pch_gbe/
diff --git a/drivers/net/ethernet/oki-semi/pch_gbe/Kconfig b/drivers/net/ethernet/oki-semi/pch_gbe/Kconfig
new file mode 100644
index 0000000..c85709d
--- /dev/null
+++ b/drivers/net/ethernet/oki-semi/pch_gbe/Kconfig
@@ -0,0 +1,20 @@
+#
+# OKI Semiconductor device configuration
+#
+
+config PCH_GBE
+	tristate "OKI SEMICONDUCTOR ML7223 IOH GbE (Intel EG20T PCH)"
+	depends on PCI
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
diff --git a/drivers/net/pch_gbe/Makefile b/drivers/net/ethernet/oki-semi/pch_gbe/Makefile
similarity index 100%
rename from drivers/net/pch_gbe/Makefile
rename to drivers/net/ethernet/oki-semi/pch_gbe/Makefile
diff --git a/drivers/net/pch_gbe/pch_gbe.h b/drivers/net/ethernet/oki-semi/pch_gbe/pch_gbe.h
similarity index 100%
rename from drivers/net/pch_gbe/pch_gbe.h
rename to drivers/net/ethernet/oki-semi/pch_gbe/pch_gbe.h
diff --git a/drivers/net/pch_gbe/pch_gbe_api.c b/drivers/net/ethernet/oki-semi/pch_gbe/pch_gbe_api.c
similarity index 100%
rename from drivers/net/pch_gbe/pch_gbe_api.c
rename to drivers/net/ethernet/oki-semi/pch_gbe/pch_gbe_api.c
diff --git a/drivers/net/pch_gbe/pch_gbe_api.h b/drivers/net/ethernet/oki-semi/pch_gbe/pch_gbe_api.h
similarity index 100%
rename from drivers/net/pch_gbe/pch_gbe_api.h
rename to drivers/net/ethernet/oki-semi/pch_gbe/pch_gbe_api.h
diff --git a/drivers/net/pch_gbe/pch_gbe_ethtool.c b/drivers/net/ethernet/oki-semi/pch_gbe/pch_gbe_ethtool.c
similarity index 100%
rename from drivers/net/pch_gbe/pch_gbe_ethtool.c
rename to drivers/net/ethernet/oki-semi/pch_gbe/pch_gbe_ethtool.c
diff --git a/drivers/net/pch_gbe/pch_gbe_main.c b/drivers/net/ethernet/oki-semi/pch_gbe/pch_gbe_main.c
similarity index 100%
rename from drivers/net/pch_gbe/pch_gbe_main.c
rename to drivers/net/ethernet/oki-semi/pch_gbe/pch_gbe_main.c
diff --git a/drivers/net/pch_gbe/pch_gbe_param.c b/drivers/net/ethernet/oki-semi/pch_gbe/pch_gbe_param.c
similarity index 100%
rename from drivers/net/pch_gbe/pch_gbe_param.c
rename to drivers/net/ethernet/oki-semi/pch_gbe/pch_gbe_param.c
diff --git a/drivers/net/pch_gbe/pch_gbe_phy.c b/drivers/net/ethernet/oki-semi/pch_gbe/pch_gbe_phy.c
similarity index 100%
rename from drivers/net/pch_gbe/pch_gbe_phy.c
rename to drivers/net/ethernet/oki-semi/pch_gbe/pch_gbe_phy.c
diff --git a/drivers/net/pch_gbe/pch_gbe_phy.h b/drivers/net/ethernet/oki-semi/pch_gbe/pch_gbe_phy.h
similarity index 100%
rename from drivers/net/pch_gbe/pch_gbe_phy.h
rename to drivers/net/ethernet/oki-semi/pch_gbe/pch_gbe_phy.h
-- 
1.7.6

