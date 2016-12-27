From: David VomLehn <vomlehn@texas.net>
Subject: [PATCH 01/12] Make and configuration files.
Date: Tue, 27 Dec 2016 05:15:45 -0800
Message-ID: <9cc1565a3a398b4f70248ca98d12991071142682.1482844556.git.vomlehn@texas.net>
Cc: Simon Edelhaus <Simon.Edelhaus@aquantia.com>,
        David VomLehn <vomlehn@texas.net>,
        Dmitrii Tarakanov <Dmitrii.Tarakanov@aquantia.com>,
        Alexander Loktionov <Alexander.Loktionov@aquantia.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from barracuda3.aus1.datafoundry.com ([209.99.124.134]:42404 "EHLO
        milter.aus.datafoundry.com" rhost-flags-OK-OK-OK-FAIL)
        by vger.kernel.org with ESMTP id S1754500AbcL0NgS (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 27 Dec 2016 08:36:18 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Patches to create the make and configuration files.

Signed-off-by: Dmitrii Tarakanov <Dmitrii.Tarakanov@aquantia.com>
Signed-off-by: Alexander Loktionov <Alexander.Loktionov@aquantia.com>
Signed-off-by: David M. VomLehn <vomlehn@texas.net>
---
 drivers/net/ethernet/aquantia/atlantic/Kconfig  |  9 ++++++
 drivers/net/ethernet/aquantia/atlantic/Makefile | 40 +++++++++++++++++++++++++
 drivers/net/ethernet/aquantia/atlantic/ver.h    | 18 +++++++++++
 3 files changed, 67 insertions(+)
 create mode 100644 drivers/net/ethernet/aquantia/atlantic/Kconfig
 create mode 100644 drivers/net/ethernet/aquantia/atlantic/Makefile
 create mode 100644 drivers/net/ethernet/aquantia/atlantic/ver.h

diff --git a/drivers/net/ethernet/aquantia/atlantic/Kconfig b/drivers/net/ethernet/aquantia/atlantic/Kconfig
new file mode 100644
index 0000000..33f1eb6
--- /dev/null
+++ b/drivers/net/ethernet/aquantia/atlantic/Kconfig
@@ -0,0 +1,9 @@
+#
+# Aquantia device configuration
+#
+
+config AQTION
+	tristate "Aquantia AQtion Support"
+	depends on PCI
+	---help---
+	  This enables the support for the Aquantia AQtion Ethernet card.
\ No newline at end of file
diff --git a/drivers/net/ethernet/aquantia/atlantic/Makefile b/drivers/net/ethernet/aquantia/atlantic/Makefile
new file mode 100644
index 0000000..f0d961f
--- /dev/null
+++ b/drivers/net/ethernet/aquantia/atlantic/Makefile
@@ -0,0 +1,40 @@
+TARGET:=atlantic
+
+CC = gcc
+
+ifeq "$(CC)" "gcc"
+	ccflags-y := -Wall
+endif
+
+ifneq ($(KERNELRELEASE),)
+	$(TARGET)-objs:=aq_main.o aq_nic.o aq_pci_func.o aq_nic.o aq_vec.o \
+	aq_ring.o aq_hw_utils.o aq_ethtool.o hw_atl/hw_atl_a0.o \
+	hw_atl/hw_atl_utils.o hw_atl/hw_atl_llh.o
+
+	obj-m:=$(TARGET).o
+else
+	ifndef KDIR
+		BUILD_DIR:=/lib/modules/$(shell uname -r)/build
+	else
+		BUILD_DIR:=$(KDIR)
+	endif
+
+	PWD:=$(shell pwd)
+
+all:
+	$(MAKE) -j4 CC=$(CC) -C $(BUILD_DIR) M=$(PWD) modules
+
+dox:	.doxygen
+	@doxygen $<
+
+clean:
+	$(MAKE) -j4 -C $(BUILD_DIR) M=$(PWD) clean
+	@-rm -rdf doc/html 2 > /dev/null
+
+load:
+	insmod ./$(TARGET).ko
+
+unload:
+	rmmod ./$(TARGET).ko
+
+endif
diff --git a/drivers/net/ethernet/aquantia/atlantic/ver.h b/drivers/net/ethernet/aquantia/atlantic/ver.h
new file mode 100644
index 0000000..225f561
--- /dev/null
+++ b/drivers/net/ethernet/aquantia/atlantic/ver.h
@@ -0,0 +1,18 @@
+/*
+ * Aquantia Corporation Network Driver
+ * Copyright (C) 2014-2016 Aquantia Corporation. All rights reserved
+ *
+ * This program is free software; you can redistribute it and/or modify it
+ * under the terms and conditions of the GNU General Public License,
+ * version 2, as published by the Free Software Foundation.
+ */
+
+#ifndef VER_H
+#define VER_H
+
+#define NIC_MAJOR_DRIVER_VERSION           1
+#define NIC_MINOR_DRIVER_VERSION           4
+#define NIC_BUILD_DRIVER_VERSION           1671
+#define NIC_REVISION_DRIVER_VERSION        0
+
+#endif				/* VER_H */
-- 
2.7.4
