From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next 02/10] tehuti: Move the Tehuti driver
Date: Thu, 11 Aug 2011 16:39:50 -0700
Message-ID: <1313105998-2859-3-git-send-email-jeffrey.t.kirsher@intel.com>
References: <1313105998-2859-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: Jeff Kirsher <jeffrey.t.kirsher@intel.com>, netdev@vger.kernel.org,
	gospo@redhat.com, sassmann@redhat.com,
	Alexander Indenbaum <baum@tehutinetworks.net>,
	Andy Gospodarek <andy@greyhouse.net>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga01.intel.com ([192.55.52.88]:42195 "EHLO mga01.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753627Ab1HKXkD (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 11 Aug 2011 19:40:03 -0400
In-Reply-To: <1313105998-2859-1-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Move the Tehuti driver into drivers/net/ethernet/tehuti/ and
make the necessary Kconfig and Makefile changes.

CC: Alexander Indenbaum <baum@tehutinetworks.net>
CC: Andy Gospodarek <andy@greyhouse.net>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 MAINTAINERS                                |    2 +-
 drivers/net/Kconfig                        |    6 ------
 drivers/net/Makefile                       |    1 -
 drivers/net/ethernet/Kconfig               |    1 +
 drivers/net/ethernet/Makefile              |    1 +
 drivers/net/ethernet/tehuti/Kconfig        |   26 ++++++++++++++++++++++++++
 drivers/net/ethernet/tehuti/Makefile       |    5 +++++
 drivers/net/{ => ethernet/tehuti}/tehuti.c |    0
 drivers/net/{ => ethernet/tehuti}/tehuti.h |    0
 9 files changed, 34 insertions(+), 8 deletions(-)
 create mode 100644 drivers/net/ethernet/tehuti/Kconfig
 create mode 100644 drivers/net/ethernet/tehuti/Makefile
 rename drivers/net/{ => ethernet/tehuti}/tehuti.c (100%)
 rename drivers/net/{ => ethernet/tehuti}/tehuti.h (100%)

diff --git a/MAINTAINERS b/MAINTAINERS
index 51ac08b..c789b6f 100644
--- a/MAINTAINERS
+++ b/MAINTAINERS
@@ -6360,7 +6360,7 @@ M:	Alexander Indenbaum <baum@tehutinetworks.net>
 M:	Andy Gospodarek <andy@greyhouse.net>
 L:	netdev@vger.kernel.org
 S:	Supported
-F:	drivers/net/tehuti*
+F:	drivers/net/ethernet/tehuti/*
 
 Telecom Clock Driver for MCPL0010
 M:	Mark Gross <mark.gross@intel.com>
diff --git a/drivers/net/Kconfig b/drivers/net/Kconfig
index 69333fe..d3d2febe 100644
--- a/drivers/net/Kconfig
+++ b/drivers/net/Kconfig
@@ -1457,12 +1457,6 @@ if NETDEV_10000
 config MDIO
 	tristate
 
-config TEHUTI
-	tristate "Tehuti Networks 10G Ethernet"
-	depends on PCI
-	help
-	  Tehuti Networks 10G Ethernet NIC
-
 endif # NETDEV_10000
 
 source "drivers/net/tokenring/Kconfig"
diff --git a/drivers/net/Makefile b/drivers/net/Makefile
index 5dfa4c3..8d2d677 100644
--- a/drivers/net/Makefile
+++ b/drivers/net/Makefile
@@ -19,7 +19,6 @@ obj-$(CONFIG_ATL1E) += atl1e/
 obj-$(CONFIG_ATL1C) += atl1c/
 obj-$(CONFIG_GIANFAR) += gianfar_driver.o
 obj-$(CONFIG_PTP_1588_CLOCK_GIANFAR) += gianfar_ptp.o
-obj-$(CONFIG_TEHUTI) += tehuti.o
 obj-$(CONFIG_JME) += jme.o
 obj-$(CONFIG_VMXNET3) += vmxnet3/
 
diff --git a/drivers/net/ethernet/Kconfig b/drivers/net/ethernet/Kconfig
index 16c206e..8375b8b 100644
--- a/drivers/net/ethernet/Kconfig
+++ b/drivers/net/ethernet/Kconfig
@@ -31,5 +31,6 @@ source "drivers/net/ethernet/racal/Kconfig"
 source "drivers/net/ethernet/sfc/Kconfig"
 source "drivers/net/ethernet/smsc/Kconfig"
 source "drivers/net/ethernet/sun/Kconfig"
+source "drivers/net/ethernet/tehuti/Kconfig"
 
 endif # ETHERNET
diff --git a/drivers/net/ethernet/Makefile b/drivers/net/ethernet/Makefile
index a52dc26..26324a1 100644
--- a/drivers/net/ethernet/Makefile
+++ b/drivers/net/ethernet/Makefile
@@ -22,3 +22,4 @@ obj-$(CONFIG_NET_VENDOR_RACAL) += racal/
 obj-$(CONFIG_SFC) += sfc/
 obj-$(CONFIG_NET_VENDOR_SMSC) += smsc/
 obj-$(CONFIG_NET_VENDOR_SUN) += sun/
+obj-$(CONFIG_NET_VENDOR_TEHUTI) += tehuti/
diff --git a/drivers/net/ethernet/tehuti/Kconfig b/drivers/net/ethernet/tehuti/Kconfig
new file mode 100644
index 0000000..914ad4059
--- /dev/null
+++ b/drivers/net/ethernet/tehuti/Kconfig
@@ -0,0 +1,26 @@
+#
+# Tehuti network device configuration
+#
+
+config NET_VENDOR_TEHUTI
+	bool "Tehuti devices"
+	depends on PCI
+	---help---
+	  If you have a network (Ethernet) card belonging to this class, say Y
+	  and read the Ethernet-HOWTO, available from
+	  <http://www.tldp.org/docs.html#howto>.
+
+	  Note that the answer to this question doesn't directly affect the
+	  kernel: saying N will just cause the configurator to skip all
+	  the questions about Tehuti cards. If you say Y, you will be asked for
+	  your specific card in the following questions.
+
+if NET_VENDOR_TEHUTI
+
+config TEHUTI
+	tristate "Tehuti Networks 10G Ethernet"
+	depends on PCI
+	---help---
+	  Tehuti Networks 10G Ethernet NIC
+
+endif # NET_VENDOR_TEHUTI
diff --git a/drivers/net/ethernet/tehuti/Makefile b/drivers/net/ethernet/tehuti/Makefile
new file mode 100644
index 0000000..f995421
--- /dev/null
+++ b/drivers/net/ethernet/tehuti/Makefile
@@ -0,0 +1,5 @@
+#
+# Makefile for the Tehuti network device drivers.
+#
+
+obj-$(CONFIG_TEHUTI) += tehuti.o
diff --git a/drivers/net/tehuti.c b/drivers/net/ethernet/tehuti/tehuti.c
similarity index 100%
rename from drivers/net/tehuti.c
rename to drivers/net/ethernet/tehuti/tehuti.c
diff --git a/drivers/net/tehuti.h b/drivers/net/ethernet/tehuti/tehuti.h
similarity index 100%
rename from drivers/net/tehuti.h
rename to drivers/net/ethernet/tehuti/tehuti.h
-- 
1.7.6

