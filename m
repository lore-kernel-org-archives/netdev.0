From: "Glenn Grundstrom" <ggrundstrom@NetEffect.com>
Subject: [PATCH 1/9] NetEffect 10Gb RNIC Driver: kernel Kconfig and makefiles
Date: Thu, 26 Oct 2006 18:45:39 -0500
Message-ID: <5E701717F2B2ED4EA60F87C8AA57B7CC064C9EAF@venom2>
Reply-To: <glenng@neteffect.com>
Mime-Version: 1.0
Content-Type: text/plain;
	charset="us-ascii"
Content-Transfer-Encoding: 8BIT
Cc: <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail2.neteffect.com ([204.57.75.68]:26332 "EHLO
	mail2.neteffect.com") by vger.kernel.org with ESMTP
	id S1946024AbWJZXpn convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 26 Oct 2006 19:45:43 -0400
Content-class: urn:content-classes:message
To: <openib-general@openib.org>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

The following set of patches contain the source code for the NetEffect
NE010 iWarp adapter running under the OpenFabrics Alliance software
stack.  This is a repost.

Signed-off-by: Glenn Grundstrom <glenng@neteffect.com>

======================================================

diff -ruNp old/drivers/infiniband/Kconfig new/drivers/infiniband/Kconfig
--- old/drivers/infiniband/Kconfig	2006-10-25 09:57:43.000000000
-0500
+++ new/drivers/infiniband/Kconfig	2006-10-25 10:48:40.000000000
-0500
@@ -41,6 +41,8 @@ source "drivers/infiniband/hw/ehca/Kconf
 
 source "drivers/infiniband/hw/amso1100/Kconfig"
 
+source "drivers/infiniband/hw/nes/Kconfig"
+
 source "drivers/infiniband/hw/cxgb3/Kconfig"
 
 source "drivers/infiniband/ulp/ipoib/Kconfig"
diff -ruNp old/drivers/infiniband/hw/nes/Kconfig
new/drivers/infiniband/hw/nes/Kconfig
--- old/drivers/infiniband/hw/nes/Kconfig	1969-12-31
18:00:00.000000000 -0600
+++ new/drivers/infiniband/hw/nes/Kconfig	2006-10-25
10:50:18.000000000 -0500
@@ -0,0 +1,15 @@
+config INFINIBAND_NES
+	tristate "NetEffect RNIC support"
+	depends on PCI && INET && INFINIBAND
+	---help---
+	  This is a low-level driver for NetEffect RDMA enabled
+	  Network Interface Cards (RNIC).
+
+config INFINIBAND_NES_DEBUG
+	bool "Verbose debugging output"
+	depends on INFINIBAND_NES
+	default n
+	---help---
+	  This option causes the NetEffect RNIC driver to produce debug
+	  messages.  Select this if you are developing the driver
+	  or trying to diagnose a problem.
diff -ruNp old/drivers/infiniband/hw/nes/Makefile
new/drivers/infiniband/hw/nes/Makefile
--- old/drivers/infiniband/hw/nes/Makefile	1969-12-31
18:00:00.000000000 -0600
+++ new/drivers/infiniband/hw/nes/Makefile	2006-10-25
11:10:26.000000000 -0500
@@ -0,0 +1,27 @@
+EXTRA_CFLAGS += -Idrivers/infiniband/include
-Idrivers/infiniband/hw/nes/nes_tcpip/include
+
+ifdef CONFIG_INFINIBAND_NES_DEBUG
+EXTRA_CFLAGS += -DNES_DEBUG
+endif
+
+ifneq ($(KERNELRELEASE),)
+	obj-$(CONFIG_INFINIBAND_NES) += iw_nes.o	
+
+	iw_nes-objs := \
+		nes.o \
+		nes_hw.o \
+		nes_nic.o \
+		nes_cm.o \
+		nes_utils.o \
+		nes_verbs.o 
+else
+	KERNELDIR ?= /usr/src/linux
+	PWD := $(shell pwd)
+
+default:
+	$(MAKE) -C $(KERNELDIR) M=$(PWD) modules
+
+clean:
+	$(MAKE) -C $(KERNELDIR) M=$(PWD) clean
+
+endif

