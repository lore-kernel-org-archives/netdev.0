From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [RFC 46/72] ixp2000: Move the Radisys driver
Date: Sat, 25 Jun 2011 06:58:57 -0700
Message-ID: <1309010363-22750-47-git-send-email-jeffrey.t.kirsher@intel.com>
References: <1309010363-22750-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: Jeff Kirsher <jeffrey.t.kirsher@intel.com>, netdev@vger.kernel.org,
	Lennert Buytenhek <kernel@wantstofly.org>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga03.intel.com ([143.182.124.21]:37770 "EHLO mga03.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752191Ab1FYOAM (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sat, 25 Jun 2011 10:00:12 -0400
In-Reply-To: <1309010363-22750-1-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Move the Radisys driver into drivers/net/ethernet/radisys/ and
make the necessary Kconfig and Makefile changes

CC: Lennert Buytenhek <kernel@wantstofly.org>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 MAINTAINERS                                        |    2 +-
 drivers/net/Kconfig                                |    2 --
 drivers/net/Makefile                               |    1 -
 drivers/net/ethernet/Kconfig                       |    1 +
 drivers/net/ethernet/Makefile                      |    1 +
 drivers/net/ethernet/radisys/Kconfig               |   16 ++++++++++++++++
 drivers/net/ethernet/radisys/Makefile              |    5 +++++
 drivers/net/{ => ethernet/radisys}/ixp2000/Kconfig |    2 +-
 .../net/{ => ethernet/radisys}/ixp2000/Makefile    |    0
 drivers/net/{ => ethernet/radisys}/ixp2000/caleb.c |    0
 drivers/net/{ => ethernet/radisys}/ixp2000/caleb.h |    0
 .../net/{ => ethernet/radisys}/ixp2000/enp2611.c   |    0
 .../{ => ethernet/radisys}/ixp2000/ixp2400-msf.c   |    0
 .../{ => ethernet/radisys}/ixp2000/ixp2400-msf.h   |    0
 .../{ => ethernet/radisys}/ixp2000/ixp2400_rx.uc   |    0
 .../radisys}/ixp2000/ixp2400_rx.ucode              |    0
 .../{ => ethernet/radisys}/ixp2000/ixp2400_tx.uc   |    0
 .../radisys}/ixp2000/ixp2400_tx.ucode              |    0
 .../net/{ => ethernet/radisys}/ixp2000/ixpdev.c    |    0
 .../net/{ => ethernet/radisys}/ixp2000/ixpdev.h    |    0
 .../{ => ethernet/radisys}/ixp2000/ixpdev_priv.h   |    0
 .../net/{ => ethernet/radisys}/ixp2000/pm3386.c    |    0
 .../net/{ => ethernet/radisys}/ixp2000/pm3386.h    |    0
 23 files changed, 25 insertions(+), 5 deletions(-)
 create mode 100644 drivers/net/ethernet/radisys/Kconfig
 create mode 100644 drivers/net/ethernet/radisys/Makefile
 rename drivers/net/{ => ethernet/radisys}/ixp2000/Kconfig (80%)
 rename drivers/net/{ => ethernet/radisys}/ixp2000/Makefile (100%)
 rename drivers/net/{ => ethernet/radisys}/ixp2000/caleb.c (100%)
 rename drivers/net/{ => ethernet/radisys}/ixp2000/caleb.h (100%)
 rename drivers/net/{ => ethernet/radisys}/ixp2000/enp2611.c (100%)
 rename drivers/net/{ => ethernet/radisys}/ixp2000/ixp2400-msf.c (100%)
 rename drivers/net/{ => ethernet/radisys}/ixp2000/ixp2400-msf.h (100%)
 rename drivers/net/{ => ethernet/radisys}/ixp2000/ixp2400_rx.uc (100%)
 rename drivers/net/{ => ethernet/radisys}/ixp2000/ixp2400_rx.ucode (100%)
 rename drivers/net/{ => ethernet/radisys}/ixp2000/ixp2400_tx.uc (100%)
 rename drivers/net/{ => ethernet/radisys}/ixp2000/ixp2400_tx.ucode (100%)
 rename drivers/net/{ => ethernet/radisys}/ixp2000/ixpdev.c (100%)
 rename drivers/net/{ => ethernet/radisys}/ixp2000/ixpdev.h (100%)
 rename drivers/net/{ => ethernet/radisys}/ixp2000/ixpdev_priv.h (100%)
 rename drivers/net/{ => ethernet/radisys}/ixp2000/pm3386.c (100%)
 rename drivers/net/{ => ethernet/radisys}/ixp2000/pm3386.h (100%)

diff --git a/MAINTAINERS b/MAINTAINERS
index cd97122..07ac87b 100644
--- a/MAINTAINERS
+++ b/MAINTAINERS
@@ -3299,7 +3299,7 @@ INTEL IXP2000 ETHERNET DRIVER
 M:	Lennert Buytenhek <kernel@wantstofly.org>
 L:	netdev@vger.kernel.org
 S:	Maintained
-F:	drivers/net/ixp2000/
+F:	drivers/net/ethernet/ixp2000/
 
 INTEL ETHERNET DRIVERS (e100/e1000/e1000e/igb/igbvf/ixgb/ixgbe/ixgbevf)
 M:	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
diff --git a/drivers/net/Kconfig b/drivers/net/Kconfig
index 7aa7982..fd11a55 100644
--- a/drivers/net/Kconfig
+++ b/drivers/net/Kconfig
@@ -624,8 +624,6 @@ config IP1000
 	  To compile this driver as a module, choose M here: the module
 	  will be called ipg.  This is recommended.
 
-source "drivers/net/ixp2000/Kconfig"
-
 config HAMACHI
 	tristate "Packet Engines Hamachi GNIC-II support"
 	depends on PCI
diff --git a/drivers/net/Makefile b/drivers/net/Makefile
index 4893db5..7f63be8 100644
--- a/drivers/net/Makefile
+++ b/drivers/net/Makefile
@@ -109,7 +109,6 @@ obj-$(CONFIG_WLAN) += wireless/
 obj-$(CONFIG_HAMRADIO) += hamradio/
 obj-$(CONFIG_IRDA) += irda/
 obj-$(CONFIG_ETRAX_ETHERNET) += cris/
-obj-$(CONFIG_ENP2611_MSF_NET) += ixp2000/
 
 obj-$(CONFIG_NETCONSOLE) += netconsole.o
 
diff --git a/drivers/net/ethernet/Kconfig b/drivers/net/ethernet/Kconfig
index ed7b4a6..c000dc2 100644
--- a/drivers/net/ethernet/Kconfig
+++ b/drivers/net/ethernet/Kconfig
@@ -71,6 +71,7 @@ config PASEMI_MAC
 
 source "drivers/net/ethernet/qlogic/Kconfig"
 source "drivers/net/ethernet/racal/Kconfig"
+source "drivers/net/ethernet/radisys/Kconfig"
 source "drivers/net/ethernet/realtek/Kconfig"
 
 config S6GMAC
diff --git a/drivers/net/ethernet/Makefile b/drivers/net/ethernet/Makefile
index 444c988..d54eb3d 100644
--- a/drivers/net/ethernet/Makefile
+++ b/drivers/net/ethernet/Makefile
@@ -32,6 +32,7 @@ obj-$(CONFIG_NET_VENDOR_OKI) += oki/
 obj-$(CONFIG_PASEMI_MAC) += pasemi_mac.o pasemi_mac_ethtool.o
 obj-$(CONFIG_NET_VENDOR_QLOGIC) += qlogic/
 obj-$(CONFIG_NET_VENDOR_RACAL) += racal/
+obj-$(CONFIG_NET_VENDOR_RADISYS) += radisys/
 obj-$(CONFIG_NET_VENDOR_REALTEK) += realtek/
 obj-$(CONFIG_S6GMAC) += s6gmac.o
 obj-$(CONFIG_NET_VENDOR_SIS) += sis/
diff --git a/drivers/net/ethernet/radisys/Kconfig b/drivers/net/ethernet/radisys/Kconfig
new file mode 100644
index 0000000..bcbd604
--- /dev/null
+++ b/drivers/net/ethernet/radisys/Kconfig
@@ -0,0 +1,16 @@
+#
+# Radisys device configuration
+#
+
+config NET_VENDOR_RADISYS
+	bool "Radisys devices"
+	depends on ARCH_ENP2611
+	---help---
+	  If you have a network (Ethernet) card belonging to this class, say Y
+	  and read the Ethernet-HOWTO, available from
+	  <http://www.tldp.org/docs.html#howto>.
+
+	  Note that the answer to this question doesn't directly affect the
+	  kernel: saying N will just cause the configurator to skip all
+	  the questions about Radisys cards. If you say Y, you will be asked for
+	  your specific card in the following questions.
diff --git a/drivers/net/ethernet/radisys/Makefile b/drivers/net/ethernet/radisys/Makefile
new file mode 100644
index 0000000..c946cf2
--- /dev/null
+++ b/drivers/net/ethernet/radisys/Makefile
@@ -0,0 +1,5 @@
+#
+# Makefile for the Radisys device drivers.
+#
+
+obj-$(CONFIG_ENP2611_MSF_NET) += ixp2000/
diff --git a/drivers/net/ixp2000/Kconfig b/drivers/net/ethernet/radisys/ixp2000/Kconfig
similarity index 80%
rename from drivers/net/ixp2000/Kconfig
rename to drivers/net/ethernet/radisys/ixp2000/Kconfig
index 2fec241..3cd6ded 100644
--- a/drivers/net/ixp2000/Kconfig
+++ b/drivers/net/ethernet/radisys/ixp2000/Kconfig
@@ -1,6 +1,6 @@
 config ENP2611_MSF_NET
 	tristate "Radisys ENP2611 MSF network interface support"
-	depends on ARCH_ENP2611
+	depends on NET_VENDOR_RADISYS && ARCH_ENP2611
 	help
 	  This is a driver for the MSF network interface unit in
 	  the IXP2400 on the Radisys ENP2611 platform.
diff --git a/drivers/net/ixp2000/Makefile b/drivers/net/ethernet/radisys/ixp2000/Makefile
similarity index 100%
rename from drivers/net/ixp2000/Makefile
rename to drivers/net/ethernet/radisys/ixp2000/Makefile
diff --git a/drivers/net/ixp2000/caleb.c b/drivers/net/ethernet/radisys/ixp2000/caleb.c
similarity index 100%
rename from drivers/net/ixp2000/caleb.c
rename to drivers/net/ethernet/radisys/ixp2000/caleb.c
diff --git a/drivers/net/ixp2000/caleb.h b/drivers/net/ethernet/radisys/ixp2000/caleb.h
similarity index 100%
rename from drivers/net/ixp2000/caleb.h
rename to drivers/net/ethernet/radisys/ixp2000/caleb.h
diff --git a/drivers/net/ixp2000/enp2611.c b/drivers/net/ethernet/radisys/ixp2000/enp2611.c
similarity index 100%
rename from drivers/net/ixp2000/enp2611.c
rename to drivers/net/ethernet/radisys/ixp2000/enp2611.c
diff --git a/drivers/net/ixp2000/ixp2400-msf.c b/drivers/net/ethernet/radisys/ixp2000/ixp2400-msf.c
similarity index 100%
rename from drivers/net/ixp2000/ixp2400-msf.c
rename to drivers/net/ethernet/radisys/ixp2000/ixp2400-msf.c
diff --git a/drivers/net/ixp2000/ixp2400-msf.h b/drivers/net/ethernet/radisys/ixp2000/ixp2400-msf.h
similarity index 100%
rename from drivers/net/ixp2000/ixp2400-msf.h
rename to drivers/net/ethernet/radisys/ixp2000/ixp2400-msf.h
diff --git a/drivers/net/ixp2000/ixp2400_rx.uc b/drivers/net/ethernet/radisys/ixp2000/ixp2400_rx.uc
similarity index 100%
rename from drivers/net/ixp2000/ixp2400_rx.uc
rename to drivers/net/ethernet/radisys/ixp2000/ixp2400_rx.uc
diff --git a/drivers/net/ixp2000/ixp2400_rx.ucode b/drivers/net/ethernet/radisys/ixp2000/ixp2400_rx.ucode
similarity index 100%
rename from drivers/net/ixp2000/ixp2400_rx.ucode
rename to drivers/net/ethernet/radisys/ixp2000/ixp2400_rx.ucode
diff --git a/drivers/net/ixp2000/ixp2400_tx.uc b/drivers/net/ethernet/radisys/ixp2000/ixp2400_tx.uc
similarity index 100%
rename from drivers/net/ixp2000/ixp2400_tx.uc
rename to drivers/net/ethernet/radisys/ixp2000/ixp2400_tx.uc
diff --git a/drivers/net/ixp2000/ixp2400_tx.ucode b/drivers/net/ethernet/radisys/ixp2000/ixp2400_tx.ucode
similarity index 100%
rename from drivers/net/ixp2000/ixp2400_tx.ucode
rename to drivers/net/ethernet/radisys/ixp2000/ixp2400_tx.ucode
diff --git a/drivers/net/ixp2000/ixpdev.c b/drivers/net/ethernet/radisys/ixp2000/ixpdev.c
similarity index 100%
rename from drivers/net/ixp2000/ixpdev.c
rename to drivers/net/ethernet/radisys/ixp2000/ixpdev.c
diff --git a/drivers/net/ixp2000/ixpdev.h b/drivers/net/ethernet/radisys/ixp2000/ixpdev.h
similarity index 100%
rename from drivers/net/ixp2000/ixpdev.h
rename to drivers/net/ethernet/radisys/ixp2000/ixpdev.h
diff --git a/drivers/net/ixp2000/ixpdev_priv.h b/drivers/net/ethernet/radisys/ixp2000/ixpdev_priv.h
similarity index 100%
rename from drivers/net/ixp2000/ixpdev_priv.h
rename to drivers/net/ethernet/radisys/ixp2000/ixpdev_priv.h
diff --git a/drivers/net/ixp2000/pm3386.c b/drivers/net/ethernet/radisys/ixp2000/pm3386.c
similarity index 100%
rename from drivers/net/ixp2000/pm3386.c
rename to drivers/net/ethernet/radisys/ixp2000/pm3386.c
diff --git a/drivers/net/ixp2000/pm3386.h b/drivers/net/ethernet/radisys/ixp2000/pm3386.h
similarity index 100%
rename from drivers/net/ixp2000/pm3386.h
rename to drivers/net/ethernet/radisys/ixp2000/pm3386.h
-- 
1.7.5.4

