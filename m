From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [RFC 67/72] greth: Move the Aeroflex Gaisler driver
Date: Sat, 25 Jun 2011 06:59:18 -0700
Message-ID: <1309010363-22750-68-git-send-email-jeffrey.t.kirsher@intel.com>
References: <1309010363-22750-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: Jeff Kirsher <jeffrey.t.kirsher@intel.com>, netdev@vger.kernel.org,
	Kristoffer Glembo <kristoffer@gaisler.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga03.intel.com ([143.182.124.21]:37787 "EHLO mga03.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752583Ab1FYOAi (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sat, 25 Jun 2011 10:00:38 -0400
In-Reply-To: <1309010363-22750-1-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Mover the Aeroflex Gaisler driver into drivers/net/ethernet/aeroflex/
and make the necessary Kconfig and Makefile changes.

CC: Kristoffer Glembo <kristoffer@gaisler.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 MAINTAINERS                                 |    2 +-
 drivers/net/Kconfig                         |    8 --------
 drivers/net/Makefile                        |    1 -
 drivers/net/ethernet/Kconfig                |    1 +
 drivers/net/ethernet/Makefile               |    1 +
 drivers/net/ethernet/aeroflex/Kconfig       |   11 +++++++++++
 drivers/net/ethernet/aeroflex/Makefile      |    5 +++++
 drivers/net/{ => ethernet/aeroflex}/greth.c |    0
 drivers/net/{ => ethernet/aeroflex}/greth.h |    0
 9 files changed, 19 insertions(+), 10 deletions(-)
 create mode 100644 drivers/net/ethernet/aeroflex/Kconfig
 create mode 100644 drivers/net/ethernet/aeroflex/Makefile
 rename drivers/net/{ => ethernet/aeroflex}/greth.c (100%)
 rename drivers/net/{ => ethernet/aeroflex}/greth.h (100%)

diff --git a/MAINTAINERS b/MAINTAINERS
index f4a46ef..b86d518 100644
--- a/MAINTAINERS
+++ b/MAINTAINERS
@@ -2828,7 +2828,7 @@ GRETH 10/100/1G Ethernet MAC device driver
 M:	Kristoffer Glembo <kristoffer@gaisler.com>
 L:	netdev@vger.kernel.org
 S:	Maintained
-F:	drivers/net/greth*
+F:	drivers/net/ethernet/aeroflex/greth*
 
 GSPCA FINEPIX SUBDRIVER
 M:	Frank Zago <frank@zago.net>
diff --git a/drivers/net/Kconfig b/drivers/net/Kconfig
index 043bbf5..70ff9cc 100644
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
index 67e25a4..9c9b2ea 100644
--- a/drivers/net/Makefile
+++ b/drivers/net/Makefile
@@ -55,7 +55,6 @@ obj-$(CONFIG_VETH) += veth.o
 obj-$(CONFIG_NET_NETX) += netx-eth.o
 obj-$(CONFIG_DM9000) += dm9000.o
 obj-$(CONFIG_ENC28J60) += enc28j60.o
-obj-$(CONFIG_GRETH) += greth.o
 
 obj-$(CONFIG_DEV_APPLETALK) += appletalk/
 obj-$(CONFIG_ETHERNET) += ethernet/
diff --git a/drivers/net/ethernet/Kconfig b/drivers/net/ethernet/Kconfig
index 5645609..4c18328 100644
--- a/drivers/net/ethernet/Kconfig
+++ b/drivers/net/ethernet/Kconfig
@@ -38,6 +38,7 @@ config ADAPTEC_STARFIRE
 	  To compile this driver as a module, choose M here: the module
 	  will be called starfire.  This is recommended.
 
+source "drivers/net/ethernet/aeroflex/Kconfig"
 source "drivers/net/ethernet/amd/Kconfig"
 source "drivers/net/ethernet/apple/Kconfig"
 
diff --git a/drivers/net/ethernet/Makefile b/drivers/net/ethernet/Makefile
index 47d19fc..f2e36ba 100644
--- a/drivers/net/ethernet/Makefile
+++ b/drivers/net/ethernet/Makefile
@@ -6,6 +6,7 @@ obj-$(CONFIG_NET_VENDOR_3COM) += 3com/
 obj-$(CONFIG_NET_VENDOR_8390) += 8390/
 obj-$(CONFIG_A2065) += a2065.o
 obj-$(CONFIG_ADAPTEC_STARFIRE) += starfire.o
+obj-$(CONFIG_GRETH) += aeroflex/
 obj-$(CONFIG_AT1700) += at1700.o
 obj-$(CONFIG_NET_VENDOR_AMD) += amd/
 obj-$(CONFIG_NET_VENDOR_APPLE) += apple/
diff --git a/drivers/net/ethernet/aeroflex/Kconfig b/drivers/net/ethernet/aeroflex/Kconfig
new file mode 100644
index 0000000..f109c8c
--- /dev/null
+++ b/drivers/net/ethernet/aeroflex/Kconfig
@@ -0,0 +1,11 @@
+#
+# Aeroflex Gaisler device configuration
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
index 0000000..701fcd0
--- /dev/null
+++ b/drivers/net/ethernet/aeroflex/Makefile
@@ -0,0 +1,5 @@
+#
+# Makefile for the Aeroflex Gaisler device drivers.
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
1.7.5.4

