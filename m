From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [RFC 69/72] dm9000: Move the Davicom driver
Date: Sat, 25 Jun 2011 06:59:20 -0700
Message-ID: <1309010363-22750-70-git-send-email-jeffrey.t.kirsher@intel.com>
References: <1309010363-22750-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: Jeff Kirsher <jeffrey.t.kirsher@intel.com>, netdev@vger.kernel.org,
	Ben Dooks <ben@simtec.co.uk>,
	Sascha Hauer <s.hauer@pengutronix.de>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga03.intel.com ([143.182.124.21]:37764 "EHLO mga03.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752608Ab1FYOAi (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sat, 25 Jun 2011 10:00:38 -0400
In-Reply-To: <1309010363-22750-1-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Move the Davicom driver into drivers/net/ethernet/davicom/ and
make the necessary Kconfig and Makefile changes.

CC: Ben Dooks <ben@simtec.co.uk>
CC: Sascha Hauer <s.hauer@pengutronix.de>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 drivers/net/Kconfig                         |   28 ------------------------
 drivers/net/Makefile                        |    1 -
 drivers/net/ethernet/Kconfig                |    1 +
 drivers/net/ethernet/Makefile               |    1 +
 drivers/net/ethernet/davicom/Kconfig        |   31 +++++++++++++++++++++++++++
 drivers/net/ethernet/davicom/Makefile       |    5 ++++
 drivers/net/{ => ethernet/davicom}/dm9000.c |    0
 drivers/net/{ => ethernet/davicom}/dm9000.h |    0
 8 files changed, 38 insertions(+), 29 deletions(-)
 create mode 100644 drivers/net/ethernet/davicom/Kconfig
 create mode 100644 drivers/net/ethernet/davicom/Makefile
 rename drivers/net/{ => ethernet/davicom}/dm9000.c (100%)
 rename drivers/net/{ => ethernet/davicom}/dm9000.h (100%)

diff --git a/drivers/net/Kconfig b/drivers/net/Kconfig
index d1bcd23..4ddc389 100644
--- a/drivers/net/Kconfig
+++ b/drivers/net/Kconfig
@@ -246,34 +246,6 @@ config NET_NETX
 	  To compile this driver as a module, choose M here. The module
 	  will be called netx-eth.
 
-config DM9000
-	tristate "DM9000 support"
-	depends on ARM || BLACKFIN || MIPS
-	select CRC32
-	select MII
-	---help---
-	  Support for DM9000 chipset.
-
-	  To compile this driver as a module, choose M here.  The module
-	  will be called dm9000.
-
-config DM9000_DEBUGLEVEL
-	int "DM9000 maximum debug level"
-	depends on DM9000
-	default 4
-	help
-	  The maximum level of debugging code compiled into the DM9000
-	  driver.
-
-config DM9000_FORCE_SIMPLE_PHY_POLL
-	bool "Force simple NSR based PHY polling"
-	depends on DM9000
-	---help---
-	  This configuration forces the DM9000 to use the NSR's LinkStatus
-	  bit to determine if the link is up or down instead of the more
-	  costly MII PHY reads. Note, this will not work if the chip is
-	  operating with an external PHY.
-
 config NET_PCI
 	bool "EISA, VLB, PCI and on board controllers"
 	depends on ISA || EISA || PCI
diff --git a/drivers/net/Makefile b/drivers/net/Makefile
index b647529..83075d4 100644
--- a/drivers/net/Makefile
+++ b/drivers/net/Makefile
@@ -53,7 +53,6 @@ obj-$(CONFIG_EQUALIZER) += eql.o
 obj-$(CONFIG_TUN) += tun.o
 obj-$(CONFIG_VETH) += veth.o
 obj-$(CONFIG_NET_NETX) += netx-eth.o
-obj-$(CONFIG_DM9000) += dm9000.o
 
 obj-$(CONFIG_DEV_APPLETALK) += appletalk/
 obj-$(CONFIG_ETHERNET) += ethernet/
diff --git a/drivers/net/ethernet/Kconfig b/drivers/net/ethernet/Kconfig
index ac88e7c..3ec1903 100644
--- a/drivers/net/ethernet/Kconfig
+++ b/drivers/net/ethernet/Kconfig
@@ -73,6 +73,7 @@ source "drivers/net/ethernet/broadcom/Kconfig"
 source "drivers/net/ethernet/brocade/Kconfig"
 source "drivers/net/ethernet/chelsio/Kconfig"
 source "drivers/net/ethernet/cisco/Kconfig"
+source "drivers/net/ethernet/davicom/Kconfig"
 
 config DNET
 	tristate "Dave ethernet support (DNET)"
diff --git a/drivers/net/ethernet/Makefile b/drivers/net/ethernet/Makefile
index afbb0ff..3b2a35a 100644
--- a/drivers/net/ethernet/Makefile
+++ b/drivers/net/ethernet/Makefile
@@ -19,6 +19,7 @@ obj-$(CONFIG_NET_VENDOR_BROADCOM) += broadcom/
 obj-$(CONFIG_NET_VENDOR_BROCADE) += brocade/
 obj-$(CONFIG_NET_VENDOR_CHELSIO) += chelsio/
 obj-$(CONFIG_NET_VENDOR_CISCO) += cisco/
+obj-$(CONFIG_DM9000) += davicom/
 obj-$(CONFIG_DNET) += dnet.o
 obj-$(CONFIG_DEPCA) += depca.o
 obj-$(CONFIG_NET_VENDOR_DLINK) += dlink/
diff --git a/drivers/net/ethernet/davicom/Kconfig b/drivers/net/ethernet/davicom/Kconfig
new file mode 100644
index 0000000..0a03b0b
--- /dev/null
+++ b/drivers/net/ethernet/davicom/Kconfig
@@ -0,0 +1,31 @@
+#
+# Davicom device configuration
+#
+
+config DM9000
+	tristate "DM9000 support"
+	depends on ARM || BLACKFIN || MIPS
+	select CRC32
+	select MII
+	---help---
+	  Support for DM9000 chipset.
+
+	  To compile this driver as a module, choose M here.  The module
+	  will be called dm9000.
+
+config DM9000_DEBUGLEVEL
+	int "DM9000 maximum debug level"
+	depends on DM9000
+	default 4
+	help
+	  The maximum level of debugging code compiled into the DM9000
+	  driver.
+
+config DM9000_FORCE_SIMPLE_PHY_POLL
+	bool "Force simple NSR based PHY polling"
+	depends on DM9000
+	---help---
+	  This configuration forces the DM9000 to use the NSR's LinkStatus
+	  bit to determine if the link is up or down instead of the more
+	  costly MII PHY reads. Note, this will not work if the chip is
+	  operating with an external PHY.
diff --git a/drivers/net/ethernet/davicom/Makefile b/drivers/net/ethernet/davicom/Makefile
new file mode 100644
index 0000000..74b31f0
--- /dev/null
+++ b/drivers/net/ethernet/davicom/Makefile
@@ -0,0 +1,5 @@
+#
+# Makefile for the Davicom device drivers.
+#
+
+obj-$(CONFIG_DM9000) += dm9000.o
diff --git a/drivers/net/dm9000.c b/drivers/net/ethernet/davicom/dm9000.c
similarity index 100%
rename from drivers/net/dm9000.c
rename to drivers/net/ethernet/davicom/dm9000.c
diff --git a/drivers/net/dm9000.h b/drivers/net/ethernet/davicom/dm9000.h
similarity index 100%
rename from drivers/net/dm9000.h
rename to drivers/net/ethernet/davicom/dm9000.h
-- 
1.7.5.4

