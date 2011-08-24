From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next 7/9] com20020_cs: Move the PCMCIA Arcnet driver
Date: Tue, 23 Aug 2011 21:39:32 -0700
Message-ID: <1314160774-6980-8-git-send-email-jeffrey.t.kirsher@intel.com>
References: <1314160774-6980-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: Jeff Kirsher <jeffrey.t.kirsher@intel.com>, netdev@vger.kernel.org,
	gospo@redhat.com,
	Arnaldo Carvalho de Melo <acme@ghostprotocols.net>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga02.intel.com ([134.134.136.20]:2828 "EHLO mga02.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752901Ab1HXEjo (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 24 Aug 2011 00:39:44 -0400
In-Reply-To: <1314160774-6980-1-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Move the COM20020 PCMICA Arcnet driver into drivers/net/arcnet/ with
the other Arcnet drivers.  Made the necessary Kconfig and Makefile
changes as well.

Since this was the "last" PCMCIA driver in drivers/net/pcmcia/, this patch
also cleans up the references to drivers/net/pcmcia.

CC: Arnaldo Carvalho de Melo <acme@ghostprotocols.net>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 drivers/net/Kconfig                          |    2 -
 drivers/net/Makefile                         |    1 -
 drivers/net/arcnet/Kconfig                   |   12 ++++++++-
 drivers/net/arcnet/Makefile                  |    1 +
 drivers/net/{pcmcia => arcnet}/com20020_cs.c |    0
 drivers/net/pcmcia/Kconfig                   |   34 --------------------------
 drivers/net/pcmcia/Makefile                  |    6 ----
 7 files changed, 12 insertions(+), 44 deletions(-)
 rename drivers/net/{pcmcia => arcnet}/com20020_cs.c (100%)
 delete mode 100644 drivers/net/pcmcia/Kconfig
 delete mode 100644 drivers/net/pcmcia/Makefile

diff --git a/drivers/net/Kconfig b/drivers/net/Kconfig
index b3206c9..5762370 100644
--- a/drivers/net/Kconfig
+++ b/drivers/net/Kconfig
@@ -209,8 +209,6 @@ source "drivers/net/wimax/Kconfig"
 
 source "drivers/net/usb/Kconfig"
 
-source "drivers/net/pcmcia/Kconfig"
-
 source "drivers/net/ppp/Kconfig"
 
 source "drivers/net/wan/Kconfig"
diff --git a/drivers/net/Makefile b/drivers/net/Makefile
index 23ea83c..d04d0ce 100644
--- a/drivers/net/Makefile
+++ b/drivers/net/Makefile
@@ -42,7 +42,6 @@ onj-$(CONFIG_SLIP) += slip/
 obj-$(CONFIG_TR) += tokenring/
 obj-$(CONFIG_WAN) += wan/
 obj-$(CONFIG_ARCNET) += arcnet/
-obj-$(CONFIG_NET_PCMCIA) += pcmcia/
 
 obj-$(CONFIG_USB_CATC)          += usb/
 obj-$(CONFIG_USB_KAWETH)        += usb/
diff --git a/drivers/net/arcnet/Kconfig b/drivers/net/arcnet/Kconfig
index 3b2f7f1..84fb634 100644
--- a/drivers/net/arcnet/Kconfig
+++ b/drivers/net/arcnet/Kconfig
@@ -3,7 +3,7 @@
 #
 
 menuconfig ARCNET
-	depends on NETDEVICES && (ISA || PCI)
+	depends on NETDEVICES && (ISA || PCI || PCMCIA)
 	tristate "ARCnet support"
 	---help---
 	  If you have a network card of this type, say Y and check out the
@@ -123,4 +123,14 @@ config ARCNET_COM20020_PCI
 	tristate "Support for COM20020 on PCI"
 	depends on ARCNET_COM20020 && PCI
 
+config ARCNET_COM20020_CS
+	tristate "COM20020 ARCnet PCMCIA support"
+	depends on ARCNET_COM20020 && PCMCIA
+	help
+	  Say Y here if you intend to attach this type of ARCnet PCMCIA card
+	  to your computer.
+
+	  To compile this driver as a module, choose M here: the module will be
+	  called com20020_cs.  If unsure, say N.
+
 endif # ARCNET
diff --git a/drivers/net/arcnet/Makefile b/drivers/net/arcnet/Makefile
index 5861af5..5ce8ee6 100644
--- a/drivers/net/arcnet/Makefile
+++ b/drivers/net/arcnet/Makefile
@@ -12,3 +12,4 @@ obj-$(CONFIG_ARCNET_RIM_I) += arc-rimi.o
 obj-$(CONFIG_ARCNET_COM20020) += com20020.o
 obj-$(CONFIG_ARCNET_COM20020_ISA) += com20020-isa.o
 obj-$(CONFIG_ARCNET_COM20020_PCI) += com20020-pci.o
+obj-$(CONFIG_ARCNET_COM20020_CS) += com20020_cs.o
diff --git a/drivers/net/pcmcia/com20020_cs.c b/drivers/net/arcnet/com20020_cs.c
similarity index 100%
rename from drivers/net/pcmcia/com20020_cs.c
rename to drivers/net/arcnet/com20020_cs.c
diff --git a/drivers/net/pcmcia/Kconfig b/drivers/net/pcmcia/Kconfig
deleted file mode 100644
index ff4deb0..0000000
--- a/drivers/net/pcmcia/Kconfig
+++ /dev/null
@@ -1,34 +0,0 @@
-#
-# PCMCIA Network device configuration
-#
-
-menuconfig NET_PCMCIA
-	bool "PCMCIA network device support"
-	depends on PCMCIA
-	---help---
-	  Say Y if you would like to include support for any PCMCIA or CardBus
-	  network adapters, then say Y to the driver for your particular card
-	  below.  PCMCIA- or PC-cards are credit-card size devices often used
-	  with laptops computers; CardBus is the newer and faster version of
-	  PCMCIA.
-
-	  To use your PC-cards, you will need supporting software from David
-	  Hinds' pcmcia-cs package (see the file <file:Documentation/Changes>
-	  for location).  You also want to check out the PCMCIA-HOWTO,
-	  available from <http://www.tldp.org/docs.html#howto>.
-
-	  If unsure, say N.
-
-if NET_PCMCIA && PCMCIA
-
-config ARCNET_COM20020_CS
-	tristate "COM20020 ARCnet PCMCIA support"
-	depends on ARCNET_COM20020
-	help
-	  Say Y here if you intend to attach this type of ARCnet PCMCIA card
-	  to your computer.
-
-	  To compile this driver as a module, choose M here: the module will be
-	  called com20020_cs.  If unsure, say N.
-
-endif # NET_PCMCIA
diff --git a/drivers/net/pcmcia/Makefile b/drivers/net/pcmcia/Makefile
deleted file mode 100644
index b98a0a4..0000000
--- a/drivers/net/pcmcia/Makefile
+++ /dev/null
@@ -1,6 +0,0 @@
-#
-# Makefile for the Linux PCMCIA network device drivers.
-#
-
-# 16-bit client drivers
-obj-$(CONFIG_ARCNET_COM20020_CS)+= com20020_cs.o
-- 
1.7.6
