From: Mark Einon <mark.einon@gmail.com>
Subject: [RFC PATCH v3 linux-next] et131x: Promote staging et131x driver to drivers/net
Date: Wed, 23 Jan 2013 12:45:30 +0000
Message-ID: <1358945130-3101-1-git-send-email-mark.einon@gmail.com>
References: <1358935859-29525-1-git-send-email-mark.einon@gmail.com>
Cc: netdev@vger.kernel.org, devel@driverdev.osuosl.org,
	linux-kernel@vger.kernel.org, dan.carpenter@oracle.com,
	Mark Einon <mark.einon@gmail.com>
To: davem@davemloft.net, gregkh@linuxfoundation.org,
	sfr@canb.auug.org.au
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1358935859-29525-1-git-send-email-mark.einon@gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This patch moves the et131x gigabit ethernet driver from drivers/staging
to drivers/net/ethernet/agere.

All the existing issues noted for this driver have been resolved, apart
from one performance issue where some fragmented packets suffer from
frame receive errors.

Signed-off-by: Mark Einon <mark.einon@gmail.com>
---

Changes from V2 - vendor name changed from Atheros to Agere in drivers/net/ethernet/agere/Kconfig

 MAINTAINERS                                        |   11 ++++---
 drivers/net/ethernet/Kconfig                       |    1 +
 drivers/net/ethernet/Makefile                      |    1 +
 drivers/net/ethernet/agere/Kconfig                 |   32 ++++++++++++++++++++
 .../et131x => net/ethernet/agere}/Makefile         |    1 +
 .../et131x => net/ethernet/agere}/et131x.c         |    0
 .../et131x => net/ethernet/agere}/et131x.h         |    0
 drivers/staging/Kconfig                            |    2 --
 drivers/staging/Makefile                           |    1 -
 drivers/staging/et131x/Kconfig                     |   10 ------
 drivers/staging/et131x/README                      |   16 ----------
 11 files changed, 41 insertions(+), 34 deletions(-)
 create mode 100644 drivers/net/ethernet/agere/Kconfig
 rename drivers/{staging/et131x => net/ethernet/agere}/Makefile (98%)
 rename drivers/{staging/et131x => net/ethernet/agere}/et131x.c (100%)
 rename drivers/{staging/et131x => net/ethernet/agere}/et131x.h (100%)
 delete mode 100644 drivers/staging/et131x/Kconfig
 delete mode 100644 drivers/staging/et131x/README

diff --git a/MAINTAINERS b/MAINTAINERS
index e80447a..cb09e9e 100644
--- a/MAINTAINERS
+++ b/MAINTAINERS
@@ -3029,6 +3029,12 @@ T:	git git://git.kernel.org/pub/scm/linux/kernel/git/kristoffer/linux-hpc.git
 F:	drivers/video/s1d13xxxfb.c
 F:	include/video/s1d13xxxfb.h
 
+ET131X NETWORK DRIVER
+M:	Mark Einon <mark.einon@gmail.com>
+L:	netdev@vger.kernel.org
+S:	Maintained
+F:	drivers/net/ethernet/agere
+
 ETHEREXPRESS-16 NETWORK DRIVER
 M:	Philip Blundell <philb@gnu.org>
 L:	netdev@vger.kernel.org
@@ -7473,11 +7479,6 @@ M:	David Rowe <david@rowetel.com>
 S:	Odd Fixes
 F:	drivers/staging/echo/
 
-STAGING - ET131X NETWORK DRIVER
-M:	Mark Einon <mark.einon@gmail.com>
-S:	Odd Fixes
-F:	drivers/staging/et131x/
-
 STAGING - FLARION FT1000 DRIVERS
 M:	Marek Belisko <marek.belisko@gmail.com>
 S:	Odd Fixes
diff --git a/drivers/net/ethernet/Kconfig b/drivers/net/ethernet/Kconfig
index ed956e0..4b4edbb 100644
--- a/drivers/net/ethernet/Kconfig
+++ b/drivers/net/ethernet/Kconfig
@@ -20,6 +20,7 @@ config SUNGEM_PHY
 source "drivers/net/ethernet/3com/Kconfig"
 source "drivers/net/ethernet/adaptec/Kconfig"
 source "drivers/net/ethernet/aeroflex/Kconfig"
+source "drivers/net/ethernet/agere/Kconfig"
 source "drivers/net/ethernet/alteon/Kconfig"
 source "drivers/net/ethernet/amd/Kconfig"
 source "drivers/net/ethernet/apple/Kconfig"
diff --git a/drivers/net/ethernet/Makefile b/drivers/net/ethernet/Makefile
index 8268d85..7a96adb 100644
--- a/drivers/net/ethernet/Makefile
+++ b/drivers/net/ethernet/Makefile
@@ -6,6 +6,7 @@ obj-$(CONFIG_NET_VENDOR_3COM) += 3com/
 obj-$(CONFIG_NET_VENDOR_8390) += 8390/
 obj-$(CONFIG_NET_VENDOR_ADAPTEC) += adaptec/
 obj-$(CONFIG_GRETH) += aeroflex/
+obj-$(CONFIG_NET_VENDOR_AGERE) += agere/
 obj-$(CONFIG_NET_VENDOR_ALTEON) += alteon/
 obj-$(CONFIG_NET_VENDOR_AMD) += amd/
 obj-$(CONFIG_NET_VENDOR_APPLE) += apple/
diff --git a/drivers/net/ethernet/agere/Kconfig b/drivers/net/ethernet/agere/Kconfig
new file mode 100644
index 0000000..efe0b90
--- /dev/null
+++ b/drivers/net/ethernet/agere/Kconfig
@@ -0,0 +1,32 @@
+#
+# Agere device configuration
+#
+
+config NET_VENDOR_AGERE
+       bool "Agere devices"
+       default y
+       depends on PCI
+       ---help---
+         If you have a network (Ethernet) card belonging to this class, say Y
+         and read the Ethernet-HOWTO, available from
+         <http://www.tldp.org/docs.html#howto>.
+
+         Note that the answer to this question doesn't directly affect the
+         kernel: saying N will just cause the configurator to skip all
+         the questions about Agere devices. If you say Y, you will be asked
+         for your specific card in the following questions.
+
+if NET_VENDOR_AGERE
+
+config ET131X
+       tristate "Agere ET-1310 Gigabit Ethernet support"
+       depends on PCI
+       select PHYLIB
+       ---help---
+         This driver supports Agere ET-1310 ethernet adapters.
+
+         To compile this driver as a module, choose M here. The module
+         will be called et131x.
+
+endif # NET_VENDOR_AGERE
+
diff --git a/drivers/staging/et131x/Makefile b/drivers/net/ethernet/agere/Makefile
similarity index 98%
rename from drivers/staging/et131x/Makefile
rename to drivers/net/ethernet/agere/Makefile
index 027ff94..740f413 100644
--- a/drivers/staging/et131x/Makefile
+++ b/drivers/net/ethernet/agere/Makefile
@@ -3,3 +3,4 @@
 #
 
 obj-$(CONFIG_ET131X) += et131x.o
+
diff --git a/drivers/staging/et131x/et131x.c b/drivers/net/ethernet/agere/et131x.c
similarity index 100%
rename from drivers/staging/et131x/et131x.c
rename to drivers/net/ethernet/agere/et131x.c
diff --git a/drivers/staging/et131x/et131x.h b/drivers/net/ethernet/agere/et131x.h
similarity index 100%
rename from drivers/staging/et131x/et131x.h
rename to drivers/net/ethernet/agere/et131x.h
diff --git a/drivers/staging/Kconfig b/drivers/staging/Kconfig
index 0b47a06..5dee726 100644
--- a/drivers/staging/Kconfig
+++ b/drivers/staging/Kconfig
@@ -24,8 +24,6 @@ menuconfig STAGING
 
 if STAGING
 
-source "drivers/staging/et131x/Kconfig"
-
 source "drivers/staging/slicoss/Kconfig"
 
 source "drivers/staging/usbip/Kconfig"
diff --git a/drivers/staging/Makefile b/drivers/staging/Makefile
index b026ea3..6983d77 100644
--- a/drivers/staging/Makefile
+++ b/drivers/staging/Makefile
@@ -5,7 +5,6 @@ obj-$(CONFIG_STAGING)		+= staging.o
 
 obj-y				+= media/
 obj-y				+= net/
-obj-$(CONFIG_ET131X)		+= et131x/
 obj-$(CONFIG_SLICOSS)		+= slicoss/
 obj-$(CONFIG_USBIP_CORE)	+= usbip/
 obj-$(CONFIG_W35UND)		+= winbond/
diff --git a/drivers/staging/et131x/Kconfig b/drivers/staging/et131x/Kconfig
deleted file mode 100644
index 8190f2a..0000000
--- a/drivers/staging/et131x/Kconfig
+++ /dev/null
@@ -1,10 +0,0 @@
-config ET131X
-	tristate "Agere ET-1310 Gigabit Ethernet support"
-	depends on PCI && NET && NETDEVICES
-	select PHYLIB
-	default n
-	---help---
-	  This driver supports Agere ET-1310 ethernet adapters.
-
-	  To compile this driver as a module, choose M here. The module
-	  will be called et131x.
diff --git a/drivers/staging/et131x/README b/drivers/staging/et131x/README
deleted file mode 100644
index 38537d4..0000000
--- a/drivers/staging/et131x/README
+++ /dev/null
@@ -1,16 +0,0 @@
-This is a driver for the ET1310 network device.
-
-Based on the driver found at https://sourceforge.net/projects/et131x/
-
-Cleaned up immensely by Olaf Hartman and Christoph Hellwig <hch@infradead.org>
-
-Note, the powermanagement options were removed from the vendor provided
-driver as they did not build properly at the time.
-
-TODO:
-	- some rx packets have CRC/code/frame errors
-
-Please send patches to:
-	Greg Kroah-Hartman <gregkh@linuxfoundation.org>
-	Mark Einon <mark.einon@gmail.com>
-
-- 
1.7.10.4
