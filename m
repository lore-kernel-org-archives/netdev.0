From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [RFC 58/72] sundance: Move the sundance driver
Date: Sat, 25 Jun 2011 06:59:09 -0700
Message-ID: <1309010363-22750-59-git-send-email-jeffrey.t.kirsher@intel.com>
References: <1309010363-22750-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: Jeff Kirsher <jeffrey.t.kirsher@intel.com>, netdev@vger.kernel.org,
	Donald Becker <becker@scyld.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga03.intel.com ([143.182.124.21]:37770 "EHLO mga03.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752488Ab1FYOA3 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sat, 25 Jun 2011 10:00:29 -0400
In-Reply-To: <1309010363-22750-1-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Move the sundance driver into drivers/net/ethernet/ and make
the necessary Kconfig and Makefile changes.

CC: Donald Becker <becker@scyld.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 drivers/net/Kconfig                   |   20 --------------------
 drivers/net/Makefile                  |    1 -
 drivers/net/ethernet/Kconfig          |   21 +++++++++++++++++++++
 drivers/net/ethernet/Makefile         |    1 +
 drivers/net/{ => ethernet}/sundance.c |    0
 5 files changed, 22 insertions(+), 21 deletions(-)
 rename drivers/net/{ => ethernet}/sundance.c (100%)

diff --git a/drivers/net/Kconfig b/drivers/net/Kconfig
index 20d1939..82da415 100644
--- a/drivers/net/Kconfig
+++ b/drivers/net/Kconfig
@@ -417,26 +417,6 @@ config R6040
 	  To compile this driver as a module, choose M here: the module
 	  will be called r6040. This is recommended.
 
-config SUNDANCE
-	tristate "Sundance Alta support"
-	depends on NET_PCI && PCI
-	select CRC32
-	select MII
-	help
-	  This driver is for the Sundance "Alta" chip.
-	  More specific information and updates are available from
-	  <http://www.scyld.com/network/sundance.html>.
-
-config SUNDANCE_MMIO
-	bool "Use MMIO instead of PIO"
-	depends on SUNDANCE
-	help
-	  Enable memory-mapped I/O for interaction with Sundance NIC registers.
-	  Do NOT enable this by default, PIO (enabled when MMIO is disabled)
-	  is known to solve bugs on certain chips.
-
-	  If unsure, say N.
-
 config NET_POCKET
 	bool "Pocket and portable adapters"
 	depends on PARPORT
diff --git a/drivers/net/Makefile b/drivers/net/Makefile
index d75080d..b7e875a 100644
--- a/drivers/net/Makefile
+++ b/drivers/net/Makefile
@@ -28,7 +28,6 @@ obj-$(CONFIG_SH_ETH) += sh_eth.o
 # end link order section
 #
 
-obj-$(CONFIG_SUNDANCE) += sundance.o
 obj-$(CONFIG_NET) += Space.o loopback.o
 obj-$(CONFIG_NET_SB1000) += sb1000.o
 obj-$(CONFIG_HP100) += hp100.o
diff --git a/drivers/net/ethernet/Kconfig b/drivers/net/ethernet/Kconfig
index aa5ded1..f5eb70e 100644
--- a/drivers/net/ethernet/Kconfig
+++ b/drivers/net/ethernet/Kconfig
@@ -132,6 +132,27 @@ source "drivers/net/ethernet/smsc/Kconfig"
 source "drivers/net/ethernet/sony/Kconfig"
 source "drivers/net/ethernet/stmicro/Kconfig"
 source "drivers/net/ethernet/sun/Kconfig"
+
+config SUNDANCE
+	tristate "Sundance Alta support"
+	depends on PCI
+	select CRC32
+	select MII
+	---help---
+	  This driver is for the Sundance "Alta" chip.
+	  More specific information and updates are available from
+	  <http://www.scyld.com/network/sundance.html>.
+
+config SUNDANCE_MMIO
+	bool "Use MMIO instead of PIO"
+	depends on SUNDANCE
+	---help---
+	  Enable memory-mapped I/O for interaction with Sundance NIC registers.
+	  Do NOT enable this by default, PIO (enabled when MMIO is disabled)
+	  is known to solve bugs on certain chips.
+
+	  If unsure, say N.
+
 source "drivers/net/ethernet/syskonnect/Kconfig"
 
 config TEHUTI
diff --git a/drivers/net/ethernet/Makefile b/drivers/net/ethernet/Makefile
index 0fe59f4..2ccb194 100644
--- a/drivers/net/ethernet/Makefile
+++ b/drivers/net/ethernet/Makefile
@@ -52,6 +52,7 @@ obj-$(CONFIG_NET_VENDOR_SMSC) += smsc/
 obj-$(CONFIG_NET_VENDOR_SONY) += sony/
 obj-$(CONFIG_NET_VENDOR_STMICRO) += stmicro/
 obj-$(CONFIG_NET_VENDOR_SUN) += sun/
+obj-$(CONFIG_SUNDANCE) += sundance.o
 obj-$(CONFIG_NET_VENDOR_SYSKONNECT) += syskonnect/
 obj-$(CONFIG_TEHUTI) += tehuti.o
 obj-$(CONFIG_NET_TI) += ti/
diff --git a/drivers/net/sundance.c b/drivers/net/ethernet/sundance.c
similarity index 100%
rename from drivers/net/sundance.c
rename to drivers/net/ethernet/sundance.c
-- 
1.7.5.4

