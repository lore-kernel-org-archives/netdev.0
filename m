From: Wolfram Sang <wsa@the-dreams.de>
Subject: [PATCH] net: can: use kbuild magic to inherit debug settings
Date: Sun, 17 Aug 2014 17:38:24 -0500
Message-ID: <1408315120-8422-1-git-send-email-wsa@the-dreams.de>
Cc: Wolfram Sang <wsa@the-dreams.de>,
	Wolfgang Grandegger <wg@grandegger.com>,
	Marc Kleine-Budde <mkl@pengutronix.de>, netdev@vger.kernel.org
To: linux-can@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from sauhun.de ([89.238.76.85]:46318 "EHLO pokefinder.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751671AbaHQWi5 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sun, 17 Aug 2014 18:38:57 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

No need to manually copy debug settings into subdir Makefiles. kbuild
has a mechanism for inheriting, so let's use it.

Signed-off-by: Wolfram Sang <wsa@the-dreams.de>
---
 drivers/net/can/Makefile         | 2 +-
 drivers/net/can/c_can/Makefile   | 2 --
 drivers/net/can/cc770/Makefile   | 2 --
 drivers/net/can/mscan/Makefile   | 2 --
 drivers/net/can/sja1000/Makefile | 2 --
 drivers/net/can/softing/Makefile | 2 --
 drivers/net/can/spi/Makefile     | 2 --
 drivers/net/can/usb/Makefile     | 2 --
 8 files changed, 1 insertion(+), 15 deletions(-)

diff --git a/drivers/net/can/Makefile b/drivers/net/can/Makefile
index 1697f22353a9..14b4c2af1e5d 100644
--- a/drivers/net/can/Makefile
+++ b/drivers/net/can/Makefile
@@ -28,4 +28,4 @@ obj-$(CONFIG_CAN_GRCAN)		+= grcan.o
 obj-$(CONFIG_CAN_RCAR)		+= rcar_can.o
 obj-$(CONFIG_CAN_XILINXCAN)	+= xilinx_can.o
 
-ccflags-$(CONFIG_CAN_DEBUG_DEVICES) := -DDEBUG
+subdir-ccflags-$(CONFIG_CAN_DEBUG_DEVICES) := -DDEBUG
diff --git a/drivers/net/can/c_can/Makefile b/drivers/net/can/c_can/Makefile
index ad1cc842170a..9fdc678b5b37 100644
--- a/drivers/net/can/c_can/Makefile
+++ b/drivers/net/can/c_can/Makefile
@@ -5,5 +5,3 @@
 obj-$(CONFIG_CAN_C_CAN) += c_can.o
 obj-$(CONFIG_CAN_C_CAN_PLATFORM) += c_can_platform.o
 obj-$(CONFIG_CAN_C_CAN_PCI) += c_can_pci.o
-
-ccflags-$(CONFIG_CAN_DEBUG_DEVICES) := -DDEBUG
diff --git a/drivers/net/can/cc770/Makefile b/drivers/net/can/cc770/Makefile
index 9fb8321b33eb..8657f879ae19 100644
--- a/drivers/net/can/cc770/Makefile
+++ b/drivers/net/can/cc770/Makefile
@@ -5,5 +5,3 @@
 obj-$(CONFIG_CAN_CC770) += cc770.o
 obj-$(CONFIG_CAN_CC770_ISA) += cc770_isa.o
 obj-$(CONFIG_CAN_CC770_PLATFORM) += cc770_platform.o
-
-ccflags-$(CONFIG_CAN_DEBUG_DEVICES) := -DDEBUG
diff --git a/drivers/net/can/mscan/Makefile b/drivers/net/can/mscan/Makefile
index c9fab17cd8b4..58903b45f5fb 100644
--- a/drivers/net/can/mscan/Makefile
+++ b/drivers/net/can/mscan/Makefile
@@ -1,5 +1,3 @@
 
 obj-$(CONFIG_CAN_MPC5XXX)	+= mscan-mpc5xxx.o
 mscan-mpc5xxx-objs		:= mscan.o mpc5xxx_can.o
-
-ccflags-$(CONFIG_CAN_DEBUG_DEVICES) := -DDEBUG
diff --git a/drivers/net/can/sja1000/Makefile b/drivers/net/can/sja1000/Makefile
index 531d5fcc97e5..be11ddd11b87 100644
--- a/drivers/net/can/sja1000/Makefile
+++ b/drivers/net/can/sja1000/Makefile
@@ -12,5 +12,3 @@ obj-$(CONFIG_CAN_PEAK_PCMCIA) += peak_pcmcia.o
 obj-$(CONFIG_CAN_PEAK_PCI) += peak_pci.o
 obj-$(CONFIG_CAN_PLX_PCI) += plx_pci.o
 obj-$(CONFIG_CAN_TSCAN1) += tscan1.o
-
-ccflags-$(CONFIG_CAN_DEBUG_DEVICES) := -DDEBUG
diff --git a/drivers/net/can/softing/Makefile b/drivers/net/can/softing/Makefile
index c5e5016c742e..a23da492dad5 100644
--- a/drivers/net/can/softing/Makefile
+++ b/drivers/net/can/softing/Makefile
@@ -2,5 +2,3 @@
 softing-y := softing_main.o softing_fw.o
 obj-$(CONFIG_CAN_SOFTING) += softing.o
 obj-$(CONFIG_CAN_SOFTING_CS) += softing_cs.o
-
-ccflags-$(CONFIG_CAN_DEBUG_DEVICES) := -DDEBUG
diff --git a/drivers/net/can/spi/Makefile b/drivers/net/can/spi/Makefile
index 90bcacffbc65..0e86040cdd8c 100644
--- a/drivers/net/can/spi/Makefile
+++ b/drivers/net/can/spi/Makefile
@@ -4,5 +4,3 @@
 
 
 obj-$(CONFIG_CAN_MCP251X)	+= mcp251x.o
-
-ccflags-$(CONFIG_CAN_DEBUG_DEVICES) := -DDEBUG
diff --git a/drivers/net/can/usb/Makefile b/drivers/net/can/usb/Makefile
index 7b9a393b1ac8..a64cf983fb87 100644
--- a/drivers/net/can/usb/Makefile
+++ b/drivers/net/can/usb/Makefile
@@ -8,5 +8,3 @@ obj-$(CONFIG_CAN_GS_USB) += gs_usb.o
 obj-$(CONFIG_CAN_KVASER_USB) += kvaser_usb.o
 obj-$(CONFIG_CAN_PEAK_USB) += peak_usb/
 obj-$(CONFIG_CAN_8DEV_USB) += usb_8dev.o
-
-ccflags-$(CONFIG_CAN_DEBUG_DEVICES) := -DDEBUG
-- 
2.0.0
