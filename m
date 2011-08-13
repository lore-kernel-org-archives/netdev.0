From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next 10/12] tile: Move the Tilera driver
Date: Sat, 13 Aug 2011 00:56:34 -0700
Message-ID: <1313222196-10074-11-git-send-email-jeffrey.t.kirsher@intel.com>
References: <1313222196-10074-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: Jeff Kirsher <jeffrey.t.kirsher@intel.com>, netdev@vger.kernel.org,
	gospo@redhat.com, sassmann@redhat.com,
	Chris Metcalf <cmetcalf@tilera.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga09.intel.com ([134.134.136.24]:8913 "EHLO mga09.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751736Ab1HMH4o (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sat, 13 Aug 2011 03:56:44 -0400
In-Reply-To: <1313222196-10074-1-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Move the Tilera driver into drivers/net/ethernet/tile and
make the necessary Kconfig and Makefile changes.

Updated the Kconfig so that the options defualt to y if TILE kernel.

CC: Chris Metcalf <cmetcalf@tilera.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 MAINTAINERS                               |    2 +-
 drivers/net/Kconfig                       |   12 ------------
 drivers/net/Makefile                      |    2 --
 drivers/net/ethernet/Kconfig              |    1 +
 drivers/net/ethernet/Makefile             |    1 +
 drivers/net/ethernet/tile/Kconfig         |   15 +++++++++++++++
 drivers/net/{ => ethernet}/tile/Makefile  |    0
 drivers/net/{ => ethernet}/tile/tilepro.c |    0
 8 files changed, 18 insertions(+), 15 deletions(-)
 create mode 100644 drivers/net/ethernet/tile/Kconfig
 rename drivers/net/{ => ethernet}/tile/Makefile (100%)
 rename drivers/net/{ => ethernet}/tile/tilepro.c (100%)

diff --git a/MAINTAINERS b/MAINTAINERS
index dfa4269..3d8a6a6 100644
--- a/MAINTAINERS
+++ b/MAINTAINERS
@@ -6411,7 +6411,7 @@ W:	http://www.tilera.com/scm/
 S:	Supported
 F:	arch/tile/
 F:	drivers/tty/hvc/hvc_tile.c
-F:	drivers/net/tile/
+F:	drivers/net/ethernet/tile/
 F:	drivers/edac/tile_edac.c
 
 TLAN NETWORK DRIVER
diff --git a/drivers/net/Kconfig b/drivers/net/Kconfig
index c83a1c0..3a1fd2c 100644
--- a/drivers/net/Kconfig
+++ b/drivers/net/Kconfig
@@ -328,18 +328,6 @@ source "drivers/s390/net/Kconfig"
 
 source "drivers/net/caif/Kconfig"
 
-config TILE_NET
-	tristate "Tilera GBE/XGBE network driver support"
-	depends on TILE
-	default y
-	select CRC32
-	help
-	  This is a standard Linux network device driver for the
-	  on-chip Tilera Gigabit Ethernet and XAUI interfaces.
-
-	  To compile this driver as a module, choose M here: the module
-	  will be called tile_net.
-
 config XEN_NETDEV_FRONTEND
 	tristate "Xen network device frontend driver"
 	depends on XEN
diff --git a/drivers/net/Makefile b/drivers/net/Makefile
index 620abd7..fcc62e6 100644
--- a/drivers/net/Makefile
+++ b/drivers/net/Makefile
@@ -79,5 +79,3 @@ obj-$(CONFIG_VIRTIO_NET) += virtio_net.o
 
 obj-$(CONFIG_WIMAX) += wimax/
 obj-$(CONFIG_CAIF) += caif/
-
-obj-$(CONFIG_TILE_NET) += tile/
diff --git a/drivers/net/ethernet/Kconfig b/drivers/net/ethernet/Kconfig
index f011665..cff6ef5 100644
--- a/drivers/net/ethernet/Kconfig
+++ b/drivers/net/ethernet/Kconfig
@@ -156,6 +156,7 @@ source "drivers/net/ethernet/stmicro/Kconfig"
 source "drivers/net/ethernet/sun/Kconfig"
 source "drivers/net/ethernet/tehuti/Kconfig"
 source "drivers/net/ethernet/ti/Kconfig"
+source "drivers/net/ethernet/tile/Kconfig"
 source "drivers/net/ethernet/toshiba/Kconfig"
 source "drivers/net/ethernet/tundra/Kconfig"
 source "drivers/net/ethernet/via/Kconfig"
diff --git a/drivers/net/ethernet/Makefile b/drivers/net/ethernet/Makefile
index 7f3b73c..986def7 100644
--- a/drivers/net/ethernet/Makefile
+++ b/drivers/net/ethernet/Makefile
@@ -65,6 +65,7 @@ obj-$(CONFIG_NET_VENDOR_STMICRO) += stmicro/
 obj-$(CONFIG_NET_VENDOR_SUN) += sun/
 obj-$(CONFIG_NET_VENDOR_TEHUTI) += tehuti/
 obj-$(CONFIG_NET_VENDOR_TI) += ti/
+obj-$(CONFIG_TILE_NET) += tile/
 obj-$(CONFIG_NET_VENDOR_TOSHIBA) += toshiba/
 obj-$(CONFIG_NET_VENDOR_TUNDRA) += tundra/
 obj-$(CONFIG_NET_VENDOR_VIA) += via/
diff --git a/drivers/net/ethernet/tile/Kconfig b/drivers/net/ethernet/tile/Kconfig
new file mode 100644
index 0000000..2d9218f
--- /dev/null
+++ b/drivers/net/ethernet/tile/Kconfig
@@ -0,0 +1,15 @@
+#
+# Tilera network device configuration
+#
+
+config TILE_NET
+	tristate "Tilera GBE/XGBE network driver support"
+	depends on TILE
+	default y
+	select CRC32
+	---help---
+	  This is a standard Linux network device driver for the
+	  on-chip Tilera Gigabit Ethernet and XAUI interfaces.
+
+	  To compile this driver as a module, choose M here: the module
+	  will be called tile_net.
diff --git a/drivers/net/tile/Makefile b/drivers/net/ethernet/tile/Makefile
similarity index 100%
rename from drivers/net/tile/Makefile
rename to drivers/net/ethernet/tile/Makefile
diff --git a/drivers/net/tile/tilepro.c b/drivers/net/ethernet/tile/tilepro.c
similarity index 100%
rename from drivers/net/tile/tilepro.c
rename to drivers/net/ethernet/tile/tilepro.c
-- 
1.7.6

