From: Alexander Loktionov <Alexander.Loktionov@aquantia.com>
Subject: [PATCH v8 01/13] net: ethernet: aquantia: Make and configuration files.
Date: Mon, 23 Jan 2017 22:09:08 -0800
Message-ID: <665e17fb5a80e09a59f71e8264420c46810d0534.1485237861.git.vomlehn@texas.net>
References: <cover.1485237861.git.vomlehn@texas.net>
Cc: "David S . Miller" <davem@davemloft.net>,
        Simon Edelhaus <Simon.Edelhaus@aquantia.com>,
        Alexander Loktionov <Alexander.Loktionov@aquantia.com>,
        Dmitrii Tarakanov <Dmitrii.Tarakanov@aquantia.com>,
        Pavel Belous <Pavel.Belous@aquantia.com>,
        Dmitry Bezrukov <Dmitry.Bezrukov@aquantia.com>
To: netdev@vger.kernel.org, David VomLehn <vomlehn@texas.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from barracuda1.aus1.datafoundry.com ([209.99.124.132]:44747 "EHLO
        milter.aus.datafoundry.com" rhost-flags-OK-OK-OK-FAIL)
        by vger.kernel.org with ESMTP id S1750704AbdAXGJp (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 24 Jan 2017 01:09:45 -0500
In-Reply-To: <cover.1485237861.git.vomlehn@texas.net>
In-Reply-To: <cover.1485237861.git.vomlehn@texas.net>
References: <cover.1485237861.git.vomlehn@texas.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: David VomLehn <vomlehn@texas.net>

Patches to create the make and configuration files.

Signed-off-by: Alexander Loktionov <Alexander.Loktionov@aquantia.com>
Signed-off-by: Dmitrii Tarakanov <Dmitrii.Tarakanov@aquantia.com>
Signed-off-by: Pavel Belous <Pavel.Belous@aquantia.com>
Signed-off-by: Dmitry Bezrukov <Dmitry.Bezrukov@aquantia.com>
Signed-off-by: David M. VomLehn <vomlehn@texas.net>
---
 drivers/net/ethernet/aquantia/Kconfig           | 24 ++++++++++++++
 drivers/net/ethernet/aquantia/Makefile          |  5 +++
 drivers/net/ethernet/aquantia/atlantic/Makefile | 42 +++++++++++++++++++++++++
 drivers/net/ethernet/aquantia/atlantic/ver.h    | 18 +++++++++++
 4 files changed, 89 insertions(+)
 create mode 100644 drivers/net/ethernet/aquantia/Kconfig
 create mode 100644 drivers/net/ethernet/aquantia/Makefile
 create mode 100644 drivers/net/ethernet/aquantia/atlantic/Makefile
 create mode 100644 drivers/net/ethernet/aquantia/atlantic/ver.h

diff --git a/drivers/net/ethernet/aquantia/Kconfig b/drivers/net/ethernet/aquantia/Kconfig
new file mode 100644
index 0000000..cdf78e0
--- /dev/null
+++ b/drivers/net/ethernet/aquantia/Kconfig
@@ -0,0 +1,24 @@
+#
+# aQuantia device configuration
+#
+
+config NET_VENDOR_AQUANTIA
+	bool "aQuantia devices"
+	default y
+	---help---
+	  Set this to y if you have an Ethernet network cards that uses the aQuantia
+	  AQC107/AQC108 chipset.
+
+	  This option does not build any drivers; it casues the aQuantia
+	  drivers that can be built to appear in the list of Ethernet drivers.
+
+
+if NET_VENDOR_AQUANTIA
+
+config AQTION
+	tristate "aQuantia AQtion(tm) Support"
+	depends on PCI && X86_64
+	---help---
+	  This enables the support for the aQuantia AQtion(tm) Ethernet card.
+
+endif # NET_VENDOR_AQUANTIA
diff --git a/drivers/net/ethernet/aquantia/Makefile b/drivers/net/ethernet/aquantia/Makefile
new file mode 100644
index 0000000..4f4897b
--- /dev/null
+++ b/drivers/net/ethernet/aquantia/Makefile
@@ -0,0 +1,5 @@
+#
+# Makefile for the aQuantia device drivers.
+#
+
+obj-$(CONFIG_AQTION) += atlantic/
diff --git a/drivers/net/ethernet/aquantia/atlantic/Makefile b/drivers/net/ethernet/aquantia/atlantic/Makefile
new file mode 100644
index 0000000..e4ae696
--- /dev/null
+++ b/drivers/net/ethernet/aquantia/atlantic/Makefile
@@ -0,0 +1,42 @@
+################################################################################
+#
+# aQuantia Ethernet Controller AQtion Linux Driver
+# Copyright(c) 2014-2017 aQuantia Corporation.
+#
+# This program is free software; you can redistribute it and/or modify it
+# under the terms and conditions of the GNU General Public License,
+# version 2, as published by the Free Software Foundation.
+#
+# This program is distributed in the hope it will be useful, but WITHOUT
+# ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or
+# FITNESS FOR A PARTICULAR PURPOSE.  See the GNU General Public License for
+# more details.
+#
+# You should have received a copy of the GNU General Public License along
+# with this program. If not, see <http://www.gnu.org/licenses/>.
+#
+# The full GNU General Public License is included in this distribution in
+# the file called "COPYING".
+#
+# Contact Information: <rdc-drv@aquantia.com>
+# aQuantia Corporation, 105 E. Tasman Dr. San Jose, CA 95134, USA
+#
+################################################################################
+
+#
+# Makefile for the AQtion(tm) Ethernet driver
+#
+
+obj-$(CONFIG_AQTION) += atlantic.o
+
+atlantic-objs := aq_main.o \
+	aq_nic.o \
+	aq_pci_func.o \
+	aq_vec.o \
+	aq_ring.o \
+	aq_hw_utils.o \
+	aq_ethtool.o \
+	hw_atl/hw_atl_a0.o \
+	hw_atl/hw_atl_b0.o \
+	hw_atl/hw_atl_utils.o \
+	hw_atl/hw_atl_llh.o
diff --git a/drivers/net/ethernet/aquantia/atlantic/ver.h b/drivers/net/ethernet/aquantia/atlantic/ver.h
new file mode 100644
index 0000000..0de858d
--- /dev/null
+++ b/drivers/net/ethernet/aquantia/atlantic/ver.h
@@ -0,0 +1,18 @@
+/*
+ * aQuantia Corporation Network Driver
+ * Copyright (C) 2014-2017 aQuantia Corporation. All rights reserved
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
+#define NIC_MINOR_DRIVER_VERSION           5
+#define NIC_BUILD_DRIVER_VERSION           345
+#define NIC_REVISION_DRIVER_VERSION        0
+
+#endif /* VER_H */
-- 
2.9.3
