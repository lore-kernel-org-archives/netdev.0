From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next 01/10] ipg: Move the IC Plus driver
Date: Fri, 12 Aug 2011 12:45:35 -0700
Message-ID: <1313178344-8168-2-git-send-email-jeffrey.t.kirsher@intel.com>
References: <1313178344-8168-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: Jeff Kirsher <jeffrey.t.kirsher@intel.com>, netdev@vger.kernel.org,
	gospo@redhat.com, sassmann@redhat.com, <craig_rich@sundanceti.com>,
	<sorbica@icplus.com.tw>, <jesse@icplus.com.tw>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga14.intel.com ([143.182.124.37]:63200 "EHLO mga14.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751912Ab1HLTps (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 12 Aug 2011 15:45:48 -0400
In-Reply-To: <1313178344-8168-1-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Move the IC Plus driver into drivers/net/ethernet/icplus/ and
make the necessary Kconfig and Makefile changes.

CC: <craig_rich@sundanceti.com>
CC: <sorbica@icplus.com.tw>
CC: <jesse@icplus.com.tw>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 MAINTAINERS                             |    2 +-
 drivers/net/Kconfig                     |   10 ----------
 drivers/net/Makefile                    |    1 -
 drivers/net/ethernet/Kconfig            |    1 +
 drivers/net/ethernet/Makefile           |    1 +
 drivers/net/ethernet/icplus/Kconfig     |   13 +++++++++++++
 drivers/net/ethernet/icplus/Makefile    |    5 +++++
 drivers/net/{ => ethernet/icplus}/ipg.c |    0
 drivers/net/{ => ethernet/icplus}/ipg.h |    0
 9 files changed, 21 insertions(+), 12 deletions(-)
 create mode 100644 drivers/net/ethernet/icplus/Kconfig
 create mode 100644 drivers/net/ethernet/icplus/Makefile
 rename drivers/net/{ => ethernet/icplus}/ipg.c (100%)
 rename drivers/net/{ => ethernet/icplus}/ipg.h (100%)

diff --git a/MAINTAINERS b/MAINTAINERS
index 37cbe14..879c17e 100644
--- a/MAINTAINERS
+++ b/MAINTAINERS
@@ -3443,7 +3443,7 @@ M:	Francois Romieu <romieu@fr.zoreil.com>
 M:	Sorbica Shieh <sorbica@icplus.com.tw>
 L:	netdev@vger.kernel.org
 S:	Maintained
-F:	drivers/net/ipg.*
+F:	drivers/net/ethernet/icplus/ipg.*
 
 IPATH DRIVER
 M:	Mike Marciniszyn <infinipath@qlogic.com>
diff --git a/drivers/net/Kconfig b/drivers/net/Kconfig
index 2607a44..bcf7368 100644
--- a/drivers/net/Kconfig
+++ b/drivers/net/Kconfig
@@ -522,16 +522,6 @@ menuconfig NETDEV_1000
 
 if NETDEV_1000
 
-config IP1000
-	tristate "IP1000 Gigabit Ethernet support"
-	depends on PCI && EXPERIMENTAL
-	select MII
-	---help---
-	  This driver supports IP1000 gigabit Ethernet cards.
-
-	  To compile this driver as a module, choose M here: the module
-	  will be called ipg.  This is recommended.
-
 endif # NETDEV_1000
 
 #
diff --git a/drivers/net/Makefile b/drivers/net/Makefile
index 4c7af02..2fb039b 100644
--- a/drivers/net/Makefile
+++ b/drivers/net/Makefile
@@ -5,7 +5,6 @@
 obj-$(CONFIG_MII) += mii.o
 obj-$(CONFIG_MDIO) += mdio.o
 obj-$(CONFIG_PHYLIB) += phy/
-obj-$(CONFIG_IP1000) += ipg.o
 obj-$(CONFIG_CAN) += can/
 obj-$(CONFIG_BONDING) += bonding/
 obj-$(CONFIG_VMXNET3) += vmxnet3/
diff --git a/drivers/net/ethernet/Kconfig b/drivers/net/ethernet/Kconfig
index 922f4d1..72d0f5e 100644
--- a/drivers/net/ethernet/Kconfig
+++ b/drivers/net/ethernet/Kconfig
@@ -31,6 +31,7 @@ source "drivers/net/ethernet/ibm/Kconfig"
 source "drivers/net/ethernet/intel/Kconfig"
 source "drivers/net/ethernet/i825xx/Kconfig"
 source "drivers/net/ethernet/xscale/Kconfig"
+source "drivers/net/ethernet/icplus/Kconfig"
 
 config JME
 	tristate "JMicron(R) PCI-Express Gigabit Ethernet support"
diff --git a/drivers/net/ethernet/Makefile b/drivers/net/ethernet/Makefile
index fcecd5f..a8d8913 100644
--- a/drivers/net/ethernet/Makefile
+++ b/drivers/net/ethernet/Makefile
@@ -23,6 +23,7 @@ obj-$(CONFIG_NET_VENDOR_IBM) += ibm/
 obj-$(CONFIG_NET_VENDOR_INTEL) += intel/
 obj-$(CONFIG_NET_VENDOR_I825XX) += i825xx/
 obj-$(CONFIG_NET_VENDOR_XSCALE) += xscale/
+obj-$(CONFIG_IP1000) += icplus/
 obj-$(CONFIG_JME) += jme.o
 obj-$(CONFIG_NET_VENDOR_MARVELL) += marvell/
 obj-$(CONFIG_NET_VENDOR_MELLANOX) += mellanox/
diff --git a/drivers/net/ethernet/icplus/Kconfig b/drivers/net/ethernet/icplus/Kconfig
new file mode 100644
index 0000000..e888222
--- /dev/null
+++ b/drivers/net/ethernet/icplus/Kconfig
@@ -0,0 +1,13 @@
+#
+# IC Plus device configuration
+#
+
+config IP1000
+	tristate "IP1000 Gigabit Ethernet support"
+	depends on PCI && EXPERIMENTAL
+	select MII
+	---help---
+	  This driver supports IP1000 gigabit Ethernet cards.
+
+	  To compile this driver as a module, choose M here: the module
+	  will be called ipg.  This is recommended.
diff --git a/drivers/net/ethernet/icplus/Makefile b/drivers/net/ethernet/icplus/Makefile
new file mode 100644
index 0000000..5bc87c1
--- /dev/null
+++ b/drivers/net/ethernet/icplus/Makefile
@@ -0,0 +1,5 @@
+#
+# Makefile for the IC Plus device drivers
+#
+
+obj-$(CONFIG_IP1000) += ipg.o
diff --git a/drivers/net/ipg.c b/drivers/net/ethernet/icplus/ipg.c
similarity index 100%
rename from drivers/net/ipg.c
rename to drivers/net/ethernet/icplus/ipg.c
diff --git a/drivers/net/ipg.h b/drivers/net/ethernet/icplus/ipg.h
similarity index 100%
rename from drivers/net/ipg.h
rename to drivers/net/ethernet/icplus/ipg.h
-- 
1.7.6

