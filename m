From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next 07/10] hamachi/yellowfin: Move the packet engine drivers
Date: Fri, 12 Aug 2011 03:52:48 -0700
Message-ID: <1313146371-6562-8-git-send-email-jeffrey.t.kirsher@intel.com>
References: <1313146371-6562-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: Jeff Kirsher <jeffrey.t.kirsher@intel.com>, netdev@vger.kernel.org,
	gospo@redhat.com, sassmann@redhat.com,
	Donald Becker <becker@scyld.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga03.intel.com ([143.182.124.21]:55857 "EHLO mga03.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752705Ab1HLKw7 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 12 Aug 2011 06:52:59 -0400
In-Reply-To: <1313146371-6562-1-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Move the packet engine drivers to drivers/net/ethernet/packetengines/
and the necessary Kconfig and Makefile changes.

CC: Donald Becker <becker@scyld.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 drivers/net/Kconfig                                |   26 -----------
 drivers/net/Makefile                               |    2 -
 drivers/net/ethernet/Kconfig                       |    1 +
 drivers/net/ethernet/Makefile                      |    1 +
 drivers/net/ethernet/packetengines/Kconfig         |   46 ++++++++++++++++++++
 drivers/net/ethernet/packetengines/Makefile        |    6 +++
 drivers/net/{ => ethernet/packetengines}/hamachi.c |    0
 .../net/{ => ethernet/packetengines}/yellowfin.c   |    0
 8 files changed, 54 insertions(+), 28 deletions(-)
 create mode 100644 drivers/net/ethernet/packetengines/Kconfig
 create mode 100644 drivers/net/ethernet/packetengines/Makefile
 rename drivers/net/{ => ethernet/packetengines}/hamachi.c (100%)
 rename drivers/net/{ => ethernet/packetengines}/yellowfin.c (100%)

diff --git a/drivers/net/Kconfig b/drivers/net/Kconfig
index e8d65fe..99b209e 100644
--- a/drivers/net/Kconfig
+++ b/drivers/net/Kconfig
@@ -541,32 +541,6 @@ config IP1000
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
 config XILINX_LL_TEMAC
 	tristate "Xilinx LL TEMAC (LocalLink Tri-mode Ethernet MAC) driver"
 	depends on PPC || MICROBLAZE
diff --git a/drivers/net/Makefile b/drivers/net/Makefile
index 96112dd..d8c286e 100644
--- a/drivers/net/Makefile
+++ b/drivers/net/Makefile
@@ -19,7 +19,6 @@ obj-$(CONFIG_PLIP) += plip.o
 obj-$(CONFIG_ROADRUNNER) += rrunner.o
 
 obj-$(CONFIG_R6040) += r6040.o
-obj-$(CONFIG_YELLOWFIN) += yellowfin.o
 obj-$(CONFIG_FEALNX) += fealnx.o
 obj-$(CONFIG_SKFP) += skfp/
 obj-$(CONFIG_ADAPTEC_STARFIRE) += starfire.o
@@ -30,7 +29,6 @@ obj-$(CONFIG_SH_ETH) += sh_eth.o
 # end link order section
 #
 
-obj-$(CONFIG_HAMACHI) += hamachi.o
 obj-$(CONFIG_NET) += Space.o loopback.o
 obj-$(CONFIG_NET_SB1000) += sb1000.o
 obj-$(CONFIG_HP100) += hp100.o
diff --git a/drivers/net/ethernet/Kconfig b/drivers/net/ethernet/Kconfig
index 3983e70..140dd73 100644
--- a/drivers/net/ethernet/Kconfig
+++ b/drivers/net/ethernet/Kconfig
@@ -39,6 +39,7 @@ source "drivers/net/ethernet/natsemi/Kconfig"
 source "drivers/net/ethernet/8390/Kconfig"
 source "drivers/net/ethernet/nuvoton/Kconfig"
 source "drivers/net/ethernet/oki-semi/Kconfig"
+source "drivers/net/ethernet/packetengines/Kconfig"
 source "drivers/net/ethernet/pasemi/Kconfig"
 source "drivers/net/ethernet/qlogic/Kconfig"
 source "drivers/net/ethernet/racal/Kconfig"
diff --git a/drivers/net/ethernet/Makefile b/drivers/net/ethernet/Makefile
index 873d275..8a97b19 100644
--- a/drivers/net/ethernet/Makefile
+++ b/drivers/net/ethernet/Makefile
@@ -30,6 +30,7 @@ obj-$(CONFIG_NET_VENDOR_MYRI) += myricom/
 obj-$(CONFIG_NET_VENDOR_NATSEMI) += natsemi/
 obj-$(CONFIG_NET_VENDOR_NUVOTON) += nuvoton/
 obj-$(CONFIG_NET_VENDOR_OKI) += oki-semi/
+obj-$(CONFIG_NET_PACKET_ENGINE) += packetengines/
 obj-$(CONFIG_NET_VENDOR_PASEMI) += pasemi/
 obj-$(CONFIG_NET_VENDOR_QLOGIC) += qlogic/
 obj-$(CONFIG_NET_VENDOR_RACAL) += racal/
diff --git a/drivers/net/ethernet/packetengines/Kconfig b/drivers/net/ethernet/packetengines/Kconfig
new file mode 100644
index 0000000..4add1db
--- /dev/null
+++ b/drivers/net/ethernet/packetengines/Kconfig
@@ -0,0 +1,46 @@
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
+if NET_PACKET_ENGINE
+
+config HAMACHI
+	tristate "Packet Engines Hamachi GNIC-II support"
+	depends on PCI
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
+	depends on PCI && EXPERIMENTAL
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
+
+endif # NET_PACKET_ENGINE
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
1.7.6

