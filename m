From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [RFC 47/72] hamachi/yellowfin: Move the packet engine drivers
Date: Sat, 25 Jun 2011 06:58:58 -0700
Message-ID: <1309010363-22750-48-git-send-email-jeffrey.t.kirsher@intel.com>
References: <1309010363-22750-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: Jeff Kirsher <jeffrey.t.kirsher@intel.com>, netdev@vger.kernel.org,
	Donald Becker <becker@scyld.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga03.intel.com ([143.182.124.21]:37787 "EHLO mga03.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752242Ab1FYOAQ (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sat, 25 Jun 2011 10:00:16 -0400
In-Reply-To: <1309010363-22750-1-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Move the packet engine drivers to drivers/net/ethernet/pktgen/ and
the necessary Kconfig and Makefile changes.

CC: Donald Becker <becker@scyld.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 drivers/net/Kconfig                                |   26 ------------
 drivers/net/Makefile                               |    2 -
 drivers/net/ethernet/Kconfig                       |    1 +
 drivers/net/ethernet/Makefile                      |    1 +
 drivers/net/ethernet/packetengines/Kconfig         |   42 ++++++++++++++++++++
 drivers/net/ethernet/packetengines/Makefile        |    6 +++
 drivers/net/{ => ethernet/packetengines}/hamachi.c |    0
 .../net/{ => ethernet/packetengines}/yellowfin.c   |    0
 8 files changed, 50 insertions(+), 28 deletions(-)
 create mode 100644 drivers/net/ethernet/packetengines/Kconfig
 create mode 100644 drivers/net/ethernet/packetengines/Makefile
 rename drivers/net/{ => ethernet/packetengines}/hamachi.c (100%)
 rename drivers/net/{ => ethernet/packetengines}/yellowfin.c (100%)

diff --git a/drivers/net/Kconfig b/drivers/net/Kconfig
index fd11a55..fb16747 100644
--- a/drivers/net/Kconfig
+++ b/drivers/net/Kconfig
@@ -624,32 +624,6 @@ config IP1000
 	  To compile this driver as a module, choose M here: the module
 	  will be called ipg.  This is recommended.
 
-config HAMACHI
-	tristate "Packet Engines Hamachi GNIC-II support"
-	depends on PCI
-	select MII
-	help
-	  If you have a Gigabit Ethernet card of this type, say Y and read
-	  the Ethernet-HOWTO, available from
-	  <http://www.tldp.org/docs.html#howto>.
-
-	  To compile this driver as a module, choose M here. The module will be
-	  called hamachi.
-
-config YELLOWFIN
-	tristate "Packet Engines Yellowfin Gigabit-NIC support (EXPERIMENTAL)"
-	depends on PCI && EXPERIMENTAL
-	select CRC32
-	---help---
-	  Say Y here if you have a Packet Engines G-NIC PCI Gigabit Ethernet
-	  adapter or the SYM53C885 Ethernet controller. The Gigabit adapter is
-	  used by the Beowulf Linux cluster project.  See
-	  <http://cesdis.gsfc.nasa.gov/linux/drivers/yellowfin.html> for more
-	  information about this driver in particular and Beowulf in general.
-
-	  To compile this driver as a module, choose M here: the module
-	  will be called yellowfin.  This is recommended.
-
 config GELIC_NET
 	tristate "PS3 Gigabit Ethernet driver"
 	depends on PPC_PS3
diff --git a/drivers/net/Makefile b/drivers/net/Makefile
index 7f63be8..f473c26 100644
--- a/drivers/net/Makefile
+++ b/drivers/net/Makefile
@@ -19,7 +19,6 @@ obj-$(CONFIG_PLIP) += plip.o
 obj-$(CONFIG_ROADRUNNER) += rrunner.o
 
 obj-$(CONFIG_R6040) += r6040.o
-obj-$(CONFIG_YELLOWFIN) += yellowfin.o
 obj-$(CONFIG_ISERIES_VETH) += iseries_veth.o
 obj-$(CONFIG_FEALNX) += fealnx.o
 obj-$(CONFIG_GELIC_NET) += ps3_gelic.o
@@ -36,7 +35,6 @@ obj-$(CONFIG_SH_ETH) += sh_eth.o
 #
 
 obj-$(CONFIG_SUNDANCE) += sundance.o
-obj-$(CONFIG_HAMACHI) += hamachi.o
 obj-$(CONFIG_NET) += Space.o loopback.o
 obj-$(CONFIG_NET_SB1000) += sb1000.o
 obj-$(CONFIG_HP100) += hp100.o
diff --git a/drivers/net/ethernet/Kconfig b/drivers/net/ethernet/Kconfig
index c000dc2..cf3da85 100644
--- a/drivers/net/ethernet/Kconfig
+++ b/drivers/net/ethernet/Kconfig
@@ -59,6 +59,7 @@ source "drivers/net/ethernet/natsemi/Kconfig"
 source "drivers/net/ethernet/8390/Kconfig"
 source "drivers/net/ethernet/isa/Kconfig"
 source "drivers/net/ethernet/oki/Kconfig"
+source "drivers/net/ethernet/packetengines/Kconfig"
 
 config PASEMI_MAC
 	tristate "PA Semi 1/10Gbit MAC"
diff --git a/drivers/net/ethernet/Makefile b/drivers/net/ethernet/Makefile
index d54eb3d..0c6c7a5 100644
--- a/drivers/net/ethernet/Makefile
+++ b/drivers/net/ethernet/Makefile
@@ -28,6 +28,7 @@ obj-$(CONFIG_NET_VENDOR_MOTOROLA) += motorola/
 obj-$(CONFIG_NET_VENDOR_MYRI) += myricom/
 obj-$(CONFIG_NET_VENDOR_NATSEMI) += natsemi/
 obj-$(CONFIG_NET_ISA) += isa/
+obj-$(CONFIG_NET_PACKET_ENGINE) += packetengines/
 obj-$(CONFIG_NET_VENDOR_OKI) += oki/
 obj-$(CONFIG_PASEMI_MAC) += pasemi_mac.o pasemi_mac_ethtool.o
 obj-$(CONFIG_NET_VENDOR_QLOGIC) += qlogic/
diff --git a/drivers/net/ethernet/packetengines/Kconfig b/drivers/net/ethernet/packetengines/Kconfig
new file mode 100644
index 0000000..3fa8d39
--- /dev/null
+++ b/drivers/net/ethernet/packetengines/Kconfig
@@ -0,0 +1,42 @@
+#
+# Packet engine device configuration
+#
+
+config NET_PACKET_ENGINE
+	bool "Packet Engine devices"
+	depends on PCI
+	---help---
+	  If you have a network (Ethernet) card belonging to this class, say Y
+	  and read the Ethernet-HOWTO, available from
+	  <http://www.tldp.org/docs.html#howto>.
+
+	  Note that the answer to this question doesn't directly affect the
+	  kernel: saying N will just cause the configurator to skip all
+	  the questions about packet engine devices. If you say Y, you will
+	  be asked for your specific card in the following questions.
+
+config HAMACHI
+	tristate "Packet Engines Hamachi GNIC-II support"
+	depends on NET_PACKET_ENGINE && PCI
+	select MII
+	---help---
+	  If you have a Gigabit Ethernet card of this type, say Y and read
+	  the Ethernet-HOWTO, available from
+	  <http://www.tldp.org/docs.html#howto>.
+
+	  To compile this driver as a module, choose M here. The module will be
+	  called hamachi.
+
+config YELLOWFIN
+	tristate "Packet Engines Yellowfin Gigabit-NIC support (EXPERIMENTAL)"
+	depends on NET_PACKET_ENGINE && PCI && EXPERIMENTAL
+	select CRC32
+	---help---
+	  Say Y here if you have a Packet Engines G-NIC PCI Gigabit Ethernet
+	  adapter or the SYM53C885 Ethernet controller. The Gigabit adapter is
+	  used by the Beowulf Linux cluster project.  See
+	  <http://cesdis.gsfc.nasa.gov/linux/drivers/yellowfin.html> for more
+	  information about this driver in particular and Beowulf in general.
+
+	  To compile this driver as a module, choose M here: the module
+	  will be called yellowfin.  This is recommended.
diff --git a/drivers/net/ethernet/packetengines/Makefile b/drivers/net/ethernet/packetengines/Makefile
new file mode 100644
index 0000000..995ccd0
--- /dev/null
+++ b/drivers/net/ethernet/packetengines/Makefile
@@ -0,0 +1,6 @@
+#
+# Makefile for the Packet Engine network device drivers.
+#
+
+obj-$(CONFIG_HAMACHI) += hamachi.o
+obj-$(CONFIG_YELLOWFIN) += yellowfin.o
diff --git a/drivers/net/hamachi.c b/drivers/net/ethernet/packetengines/hamachi.c
similarity index 100%
rename from drivers/net/hamachi.c
rename to drivers/net/ethernet/packetengines/hamachi.c
diff --git a/drivers/net/yellowfin.c b/drivers/net/ethernet/packetengines/yellowfin.c
similarity index 100%
rename from drivers/net/yellowfin.c
rename to drivers/net/ethernet/packetengines/yellowfin.c
-- 
1.7.5.4

