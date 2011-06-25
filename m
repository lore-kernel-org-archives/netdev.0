From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [RFC 29/72] de6*/dl2k: Move the D-Link drivers
Date: Sat, 25 Jun 2011 06:58:40 -0700
Message-ID: <1309010363-22750-30-git-send-email-jeffrey.t.kirsher@intel.com>
References: <1309010363-22750-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: Jeff Kirsher <jeffrey.t.kirsher@intel.com>, netdev@vger.kernel.org,
	Bjorn Ekwall <bj0rn@blox.se>, Donald Becker <becker@scyld.com>,
	Edward Peng <edward_peng@dlink.com.tw>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga14.intel.com ([143.182.124.37]:61256 "EHLO mga14.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752381Ab1FYOAY (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sat, 25 Jun 2011 10:00:24 -0400
In-Reply-To: <1309010363-22750-1-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Move the D-Link drivers into drivers/net/ethernet/dlink/ and
make the necessary Kconfig and Makefile changes.

CC: Bjorn Ekwall <bj0rn@blox.se>
CC: Donald Becker <becker@scyld.com>
CC: Edward Peng <edward_peng@dlink.com.tw>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 drivers/net/Kconfig                      |   44 ----------------------
 drivers/net/Makefile                     |    3 -
 drivers/net/ethernet/Kconfig             |    1 +
 drivers/net/ethernet/Makefile            |    1 +
 drivers/net/ethernet/dlink/Kconfig       |   60 ++++++++++++++++++++++++++++++
 drivers/net/ethernet/dlink/Makefile      |    7 +++
 drivers/net/{ => ethernet/dlink}/de600.c |    0
 drivers/net/{ => ethernet/dlink}/de600.h |    0
 drivers/net/{ => ethernet/dlink}/de620.c |    0
 drivers/net/{ => ethernet/dlink}/de620.h |    0
 drivers/net/{ => ethernet/dlink}/dl2k.c  |    0
 drivers/net/{ => ethernet/dlink}/dl2k.h  |    0
 12 files changed, 69 insertions(+), 47 deletions(-)
 create mode 100644 drivers/net/ethernet/dlink/Kconfig
 create mode 100644 drivers/net/ethernet/dlink/Makefile
 rename drivers/net/{ => ethernet/dlink}/de600.c (100%)
 rename drivers/net/{ => ethernet/dlink}/de600.h (100%)
 rename drivers/net/{ => ethernet/dlink}/de620.c (100%)
 rename drivers/net/{ => ethernet/dlink}/de620.h (100%)
 rename drivers/net/{ => ethernet/dlink}/dl2k.c (100%)
 rename drivers/net/{ => ethernet/dlink}/dl2k.h (100%)

diff --git a/drivers/net/Kconfig b/drivers/net/Kconfig
index 03bf50b..3961949 100644
--- a/drivers/net/Kconfig
+++ b/drivers/net/Kconfig
@@ -850,36 +850,6 @@ config NET_POCKET
 	  the questions about this class of network devices. If you say Y, you
 	  will be asked for your specific device in the following questions.
 
-config DE600
-	tristate "D-Link DE600 pocket adapter support"
-	depends on NET_POCKET && PARPORT
-	---help---
-	  This is a network (Ethernet) device which attaches to your parallel
-	  port. Read <file:Documentation/networking/DLINK.txt> as well as the
-	  Ethernet-HOWTO, available from
-	  <http://www.tldp.org/docs.html#howto>, if you want to use
-	  this. It is possible to have several devices share a single parallel
-	  port and it is safe to compile the corresponding drivers into the
-	  kernel.
-
-	  To compile this driver as a module, choose M here: the module
-	  will be called de600.
-
-config DE620
-	tristate "D-Link DE620 pocket adapter support"
-	depends on NET_POCKET && PARPORT
-	---help---
-	  This is a network (Ethernet) device which attaches to your parallel
-	  port. Read <file:Documentation/networking/DLINK.txt> as well as the
-	  Ethernet-HOWTO, available from
-	  <http://www.tldp.org/docs.html#howto>, if you want to use
-	  this. It is possible to have several devices share a single parallel
-	  port and it is safe to compile the corresponding drivers into the
-	  kernel.
-
-	  To compile this driver as a module, choose M here: the module
-	  will be called de620.
-
 config SGISEEQ
 	tristate "SGI Seeq ethernet controller support"
 	depends on SGI_HAS_SEEQ
@@ -979,20 +949,6 @@ menuconfig NETDEV_1000
 
 if NETDEV_1000
 
-config DL2K
-	tristate "DL2000/TC902x-based Gigabit Ethernet support"
-	depends on PCI
-	select CRC32
-	help
-	  This driver supports DL2000/TC902x-based Gigabit ethernet cards,
-	  which includes
-	  D-Link DGE-550T Gigabit Ethernet Adapter.
-	  D-Link DL2000-based Gigabit Ethernet Adapter.
-	  Sundance/Tamarack TC902x Gigabit Ethernet Adapter.
-
-	  To compile this driver as a module, choose M here: the
-	  module will be called dl2k.
-
 config IP1000
 	tristate "IP1000 Gigabit Ethernet support"
 	depends on PCI && EXPERIMENTAL
diff --git a/drivers/net/Makefile b/drivers/net/Makefile
index 74beb4a..8cdf289 100644
--- a/drivers/net/Makefile
+++ b/drivers/net/Makefile
@@ -104,8 +104,6 @@ obj-$(CONFIG_DUMMY) += dummy.o
 obj-$(CONFIG_IFB) += ifb.o
 obj-$(CONFIG_MACVLAN) += macvlan.o
 obj-$(CONFIG_MACVTAP) += macvtap.o
-obj-$(CONFIG_DE600) += de600.o
-obj-$(CONFIG_DE620) += de620.o
 obj-$(CONFIG_DEFXX) += defxx.o
 obj-$(CONFIG_SGISEEQ) += sgiseeq.o
 obj-$(CONFIG_SGI_O2MACE_ETH) += meth.o
@@ -137,7 +135,6 @@ obj-$(CONFIG_ARIADNE) += ariadne.o
 obj-$(CONFIG_TUN) += tun.o
 obj-$(CONFIG_VETH) += veth.o
 obj-$(CONFIG_NET_NETX) += netx-eth.o
-obj-$(CONFIG_DL2K) += dl2k.o
 obj-$(CONFIG_PXA168_ETH) += pxa168_eth.o
 obj-$(CONFIG_BFIN_MAC) += bfin_mac.o
 obj-$(CONFIG_DM9000) += dm9000.o
diff --git a/drivers/net/ethernet/Kconfig b/drivers/net/ethernet/Kconfig
index 3613d2d..b665c32 100644
--- a/drivers/net/ethernet/Kconfig
+++ b/drivers/net/ethernet/Kconfig
@@ -19,6 +19,7 @@ source "drivers/net/ethernet/broadcom/Kconfig"
 source "drivers/net/ethernet/brocade/Kconfig"
 source "drivers/net/ethernet/chelsio/Kconfig"
 source "drivers/net/ethernet/cisco/Kconfig"
+source "drivers/net/ethernet/dlink/Kconfig"
 source "drivers/net/ethernet/emulex/Kconfig"
 source "drivers/net/ethernet/neterion/Kconfig"
 source "drivers/net/ethernet/faraday/Kconfig"
diff --git a/drivers/net/ethernet/Makefile b/drivers/net/ethernet/Makefile
index c1b6275..e3c7243 100644
--- a/drivers/net/ethernet/Makefile
+++ b/drivers/net/ethernet/Makefile
@@ -11,6 +11,7 @@ obj-$(CONFIG_NET_VENDOR_BROADCOM) += broadcom/
 obj-$(CONFIG_NET_VENDOR_BROCADE) += brocade/
 obj-$(CONFIG_NET_VENDOR_CHELSIO) += chelsio/
 obj-$(CONFIG_NET_VENDOR_CISCO) += cisco/
+obj-$(CONFIG_NET_VENDOR_DLINK) += dlink/
 obj-$(CONFIG_NET_VENDOR_EMULEX) += emulex/
 obj-$(CONFIG_NET_VENDOR_EXAR) += neterion/
 obj-$(CONFIG_NET_VENDOR_FARADAY) += faraday/
diff --git a/drivers/net/ethernet/dlink/Kconfig b/drivers/net/ethernet/dlink/Kconfig
new file mode 100644
index 0000000..a4f51b7
--- /dev/null
+++ b/drivers/net/ethernet/dlink/Kconfig
@@ -0,0 +1,60 @@
+#
+# D-Link device configuration
+#
+
+config NET_VENDOR_DLINK
+	bool "D-Link devices"
+	depends on PCI || PARPORT
+	---help---
+	  If you have a network (Ethernet) card belonging to this class, say Y
+	  and read the Ethernet-HOWTO, available from
+	  <http://www.tldp.org/docs.html#howto>.
+
+	  Note that the answer to this question doesn't directly affect the
+	  kernel: saying N will just cause the configurator to skip all
+	  the questions about D-Link devices. If you say Y, you will be asked for
+	  your specific card in the following questions.
+
+config DE600
+	tristate "D-Link DE600 pocket adapter support"
+	depends on NET_VENDOR_DLINK && PARPORT
+	---help---
+	  This is a network (Ethernet) device which attaches to your parallel
+	  port. Read <file:Documentation/networking/DLINK.txt> as well as the
+	  Ethernet-HOWTO, available from
+	  <http://www.tldp.org/docs.html#howto>, if you want to use
+	  this. It is possible to have several devices share a single parallel
+	  port and it is safe to compile the corresponding drivers into the
+	  kernel.
+
+	  To compile this driver as a module, choose M here: the module
+	  will be called de600.
+
+config DE620
+	tristate "D-Link DE620 pocket adapter support"
+	depends on NET_VENDOR_DLINK && PARPORT
+	---help---
+	  This is a network (Ethernet) device which attaches to your parallel
+	  port. Read <file:Documentation/networking/DLINK.txt> as well as the
+	  Ethernet-HOWTO, available from
+	  <http://www.tldp.org/docs.html#howto>, if you want to use
+	  this. It is possible to have several devices share a single parallel
+	  port and it is safe to compile the corresponding drivers into the
+	  kernel.
+
+	  To compile this driver as a module, choose M here: the module
+	  will be called de620.
+
+config DL2K
+	tristate "DL2000/TC902x-based Gigabit Ethernet support"
+	depends on NET_VENDOR_DLINK && PCI
+	select CRC32
+	---help---
+	  This driver supports DL2000/TC902x-based Gigabit ethernet cards,
+	  which includes
+	  D-Link DGE-550T Gigabit Ethernet Adapter.
+	  D-Link DL2000-based Gigabit Ethernet Adapter.
+	  Sundance/Tamarack TC902x Gigabit Ethernet Adapter.
+
+	  To compile this driver as a module, choose M here: the
+	  module will be called dl2k.
diff --git a/drivers/net/ethernet/dlink/Makefile b/drivers/net/ethernet/dlink/Makefile
new file mode 100644
index 0000000..7ab33bc
--- /dev/null
+++ b/drivers/net/ethernet/dlink/Makefile
@@ -0,0 +1,7 @@
+#
+# Makefile for the D-Link network device drivers.
+#
+
+obj-$(CONFIG_DE600) += de600.o
+obj-$(CONFIG_DE620) += de620.o
+obj-$(CONFIG_DL2K) += dl2k.o
diff --git a/drivers/net/de600.c b/drivers/net/ethernet/dlink/de600.c
similarity index 100%
rename from drivers/net/de600.c
rename to drivers/net/ethernet/dlink/de600.c
diff --git a/drivers/net/de600.h b/drivers/net/ethernet/dlink/de600.h
similarity index 100%
rename from drivers/net/de600.h
rename to drivers/net/ethernet/dlink/de600.h
diff --git a/drivers/net/de620.c b/drivers/net/ethernet/dlink/de620.c
similarity index 100%
rename from drivers/net/de620.c
rename to drivers/net/ethernet/dlink/de620.c
diff --git a/drivers/net/de620.h b/drivers/net/ethernet/dlink/de620.h
similarity index 100%
rename from drivers/net/de620.h
rename to drivers/net/ethernet/dlink/de620.h
diff --git a/drivers/net/dl2k.c b/drivers/net/ethernet/dlink/dl2k.c
similarity index 100%
rename from drivers/net/dl2k.c
rename to drivers/net/ethernet/dlink/dl2k.c
diff --git a/drivers/net/dl2k.h b/drivers/net/ethernet/dlink/dl2k.h
similarity index 100%
rename from drivers/net/dl2k.h
rename to drivers/net/ethernet/dlink/dl2k.h
-- 
1.7.5.4

