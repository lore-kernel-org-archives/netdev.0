From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next v2 70/71] tile: Move the Tilera driver
Date: Sat, 30 Jul 2011 20:27:29 -0700
Message-ID: <1312082850-24914-71-git-send-email-jeffrey.t.kirsher@intel.com>
References: <1312082850-24914-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: Jeff Kirsher <jeffrey.t.kirsher@intel.com>, netdev@vger.kernel.org,
	gospo@redhat.com, sassmann@redhat.com,
	Chris Metcalf <cmetcalf@tilera.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga03.intel.com ([143.182.124.21]:39387 "EHLO mga03.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753449Ab1GaD27 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sat, 30 Jul 2011 23:28:59 -0400
In-Reply-To: <1312082850-24914-1-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Move the Tilera driver into drivers/net/ethernet/tile and
make the necessary Kconfig and Makefile changes.

CC: Chris Metcalf <cmetcalf@tilera.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 MAINTAINERS                               |    2 +-
 drivers/net/Kconfig                       |   12 ------------
 drivers/net/Makefile                      |    2 --
 drivers/net/ethernet/Kconfig              |    1 +
 drivers/net/ethernet/Makefile             |    1 +
 drivers/net/ethernet/tile/Kconfig         |   28 ++++++++++++++++++++++++++++
 drivers/net/{ => ethernet}/tile/Makefile  |    0
 drivers/net/{ => ethernet}/tile/tilepro.c |    0
 8 files changed, 31 insertions(+), 15 deletions(-)
 create mode 100644 drivers/net/ethernet/tile/Kconfig
 rename drivers/net/{ => ethernet}/tile/Makefile (100%)
 rename drivers/net/{ => ethernet}/tile/tilepro.c (100%)

diff --git a/MAINTAINERS b/MAINTAINERS
index d3a0a99..b7cf059 100644
--- a/MAINTAINERS
+++ b/MAINTAINERS
@@ -6233,7 +6233,7 @@ W:	http://www.tilera.com/scm/
 S:	Supported
 F:	arch/tile/
 F:	drivers/tty/hvc/hvc_tile.c
-F:	drivers/net/tile/
+F:	drivers/net/ethernet/tile/
 F:	drivers/edac/tile_edac.c
 
 TLAN NETWORK DRIVER
diff --git a/drivers/net/Kconfig b/drivers/net/Kconfig
index a4d2704..6fce41b 100644
--- a/drivers/net/Kconfig
+++ b/drivers/net/Kconfig
@@ -325,18 +325,6 @@ source "drivers/s390/net/Kconfig"
 
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
index 7f3b73c..fdf11aa 100644
--- a/drivers/net/ethernet/Makefile
+++ b/drivers/net/ethernet/Makefile
@@ -65,6 +65,7 @@ obj-$(CONFIG_NET_VENDOR_STMICRO) += stmicro/
 obj-$(CONFIG_NET_VENDOR_SUN) += sun/
 obj-$(CONFIG_NET_VENDOR_TEHUTI) += tehuti/
 obj-$(CONFIG_NET_VENDOR_TI) += ti/
+obj-$(CONFIG_NET_VENDOR_TILERA) += tile/
 obj-$(CONFIG_NET_VENDOR_TOSHIBA) += toshiba/
 obj-$(CONFIG_NET_VENDOR_TUNDRA) += tundra/
 obj-$(CONFIG_NET_VENDOR_VIA) += via/
diff --git a/drivers/net/ethernet/tile/Kconfig b/drivers/net/ethernet/tile/Kconfig
new file mode 100644
index 0000000..e344353
--- /dev/null
+++ b/drivers/net/ethernet/tile/Kconfig
@@ -0,0 +1,28 @@
+#
+# Tilera network device configuration
+#
+
+config NET_VENDOR_TILERA
+	bool "Tilera devices"
+	depends on TILE
+	---help---
+	  If you have a network (Ethernet) card belonging to this class, say Y
+	  and read the Ethernet-HOWTO, available from
+	  <http://www.tldp.org/docs.html#howto>.
+
+	  Note that the answer to this question doesn't directly affect the
+	  kernel: saying N will just cause the configurator to skip all
+	  the questions about Tilera cards. If you say Y, you will be asked for
+	  your specific card in the following questions.
+
+config TILE_NET
+	tristate "Tilera GBE/XGBE network driver support"
+	depends on NET_VENDOR_TILERA && TILE
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

