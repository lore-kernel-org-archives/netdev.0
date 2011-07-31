From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next v2 64/71] greth: Move the Aeroflex Gaisler driver
Date: Sat, 30 Jul 2011 20:27:23 -0700
Message-ID: <1312082850-24914-65-git-send-email-jeffrey.t.kirsher@intel.com>
References: <1312082850-24914-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: Jeff Kirsher <jeffrey.t.kirsher@intel.com>, netdev@vger.kernel.org,
	gospo@redhat.com, sassmann@redhat.com,
	Kristoffer Glembo <kristoffer@gaisler.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga03.intel.com ([143.182.124.21]:63626 "EHLO mga03.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753427Ab1GaD2u (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sat, 30 Jul 2011 23:28:50 -0400
In-Reply-To: <1312082850-24914-1-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Move the Aeroflex Gaisler driver into drivers/net/ethernet/aeroflex/
and make the necessary Kconfig and Makefile changes.

CC: Kristoffer Glembo <kristoffer@gaisler.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 drivers/net/Kconfig                         |    8 --------
 drivers/net/Makefile                        |    1 -
 drivers/net/ethernet/Kconfig                |    1 +
 drivers/net/ethernet/Makefile               |    1 +
 drivers/net/ethernet/aeroflex/Kconfig       |   11 +++++++++++
 drivers/net/ethernet/aeroflex/Makefile      |    5 +++++
 drivers/net/{ => ethernet/aeroflex}/greth.c |    0
 drivers/net/{ => ethernet/aeroflex}/greth.h |    0
 8 files changed, 18 insertions(+), 9 deletions(-)
 create mode 100644 drivers/net/ethernet/aeroflex/Kconfig
 create mode 100644 drivers/net/ethernet/aeroflex/Makefile
 rename drivers/net/{ => ethernet/aeroflex}/greth.c (100%)
 rename drivers/net/{ => ethernet/aeroflex}/greth.h (100%)

diff --git a/drivers/net/Kconfig b/drivers/net/Kconfig
index c77a1b9..0a20a35 100644
--- a/drivers/net/Kconfig
+++ b/drivers/net/Kconfig
@@ -291,14 +291,6 @@ config ENC28J60_WRITEVERIFY
 	  Enable the verify after the buffer write useful for debugging purpose.
 	  If unsure, say N.
 
-config GRETH
-	tristate "Aeroflex Gaisler GRETH Ethernet MAC support"
-	depends on SPARC
-	select PHYLIB
-	select CRC32
-	help
-	  Say Y here if you want to use the Aeroflex Gaisler GRETH Ethernet MAC.
-
 config NET_PCI
 	bool "EISA, VLB, PCI and on board controllers"
 	depends on ISA || EISA || PCI
diff --git a/drivers/net/Makefile b/drivers/net/Makefile
index 4e74d93..e2f1f55 100644
--- a/drivers/net/Makefile
+++ b/drivers/net/Makefile
@@ -54,7 +54,6 @@ obj-$(CONFIG_VETH) += veth.o
 obj-$(CONFIG_NET_NETX) += netx-eth.o
 obj-$(CONFIG_DM9000) += dm9000.o
 obj-$(CONFIG_ENC28J60) += enc28j60.o
-obj-$(CONFIG_GRETH) += greth.o
 
 obj-$(CONFIG_DEV_APPLETALK) += appletalk/
 obj-$(CONFIG_ETHERNET) += ethernet/
diff --git a/drivers/net/ethernet/Kconfig b/drivers/net/ethernet/Kconfig
index e89bb27..32561c7 100644
--- a/drivers/net/ethernet/Kconfig
+++ b/drivers/net/ethernet/Kconfig
@@ -13,6 +13,7 @@ if ETHERNET
 
 source "drivers/net/ethernet/3com/Kconfig"
 source "drivers/net/ethernet/adaptec/Kconfig"
+source "drivers/net/ethernet/aeroflex/Kconfig"
 source "drivers/net/ethernet/amd/Kconfig"
 source "drivers/net/ethernet/apple/Kconfig"
 source "drivers/net/ethernet/atheros/Kconfig"
diff --git a/drivers/net/ethernet/Makefile b/drivers/net/ethernet/Makefile
index 5ef1218..94f1be8 100644
--- a/drivers/net/ethernet/Makefile
+++ b/drivers/net/ethernet/Makefile
@@ -5,6 +5,7 @@
 obj-$(CONFIG_NET_VENDOR_3COM) += 3com/
 obj-$(CONFIG_NET_VENDOR_8390) += 8390/
 obj-$(CONFIG_NET_VENDOR_ADAPTEC) += adaptec/
+obj-$(CONFIG_GRETH) += aeroflex/
 obj-$(CONFIG_NET_VENDOR_AMD) += amd/
 obj-$(CONFIG_NET_VENDOR_APPLE) += apple/
 obj-$(CONFIG_NET_VENDOR_ATHEROS) += atheros/
diff --git a/drivers/net/ethernet/aeroflex/Kconfig b/drivers/net/ethernet/aeroflex/Kconfig
new file mode 100644
index 0000000..4f4a8d7
--- /dev/null
+++ b/drivers/net/ethernet/aeroflex/Kconfig
@@ -0,0 +1,11 @@
+#
+# Aeroflex Gaisler network device configuration
+#
+
+config GRETH
+	tristate "Aeroflex Gaisler GRETH Ethernet MAC support"
+	depends on SPARC
+	select PHYLIB
+	select CRC32
+	---help---
+	  Say Y here if you want to use the Aeroflex Gaisler GRETH Ethernet MAC.
diff --git a/drivers/net/ethernet/aeroflex/Makefile b/drivers/net/ethernet/aeroflex/Makefile
new file mode 100644
index 0000000..6e62a67
--- /dev/null
+++ b/drivers/net/ethernet/aeroflex/Makefile
@@ -0,0 +1,5 @@
+#
+# Makefile for the Aeroflex Gaisler network device drivers.
+#
+
+obj-$(CONFIG_GRETH) += greth.o
diff --git a/drivers/net/greth.c b/drivers/net/ethernet/aeroflex/greth.c
similarity index 100%
rename from drivers/net/greth.c
rename to drivers/net/ethernet/aeroflex/greth.c
diff --git a/drivers/net/greth.h b/drivers/net/ethernet/aeroflex/greth.h
similarity index 100%
rename from drivers/net/greth.h
rename to drivers/net/ethernet/aeroflex/greth.h
-- 
1.7.6

