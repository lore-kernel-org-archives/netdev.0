From: "Izumi, Taku" <izumi.taku@jp.fujitsu.com>
Subject: [PATCH 1/7] Introduce FUJITSU Extended Socket Network Device driver
Date: Wed, 20 May 2015 08:17:14 +0000
Message-ID: <E86EADE93E2D054CBCD4E708C38D364A5422D82D@G01JPEXMBYT01>
Mime-Version: 1.0
Content-Type: text/plain; charset="iso-2022-jp"
Cc: "Hart, Darren" <darren.hart@intel.com>,
	"rkhan@redhat.com" <rkhan@redhat.com>,
	"alexander.h.duyck@redhat.com" <alexander.h.duyck@redhat.com>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"linux-acpi@vger.kernel.org" <linux-acpi@vger.kernel.org>
To: "platform-driver-x86@vger.kernel.org"
	<platform-driver-x86@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mgwkm01.jp.fujitsu.com ([202.219.69.168]:63521 "EHLO
	mgwkm01.jp.fujitsu.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752014AbbETIRT (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 20 May 2015 04:17:19 -0400
Content-Language: ja-JP
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


This patch adds the skelton code of FUJITSU Extended Socket
Network Device driver.
At this stage, this driver just outputs its driver name at
loading time.

Signed-off-by: Taku Izumi <izumi.taku@jp.fujitsu.com>
---
 drivers/platform/x86/Kconfig          |  7 ++++
 drivers/platform/x86/Makefile         |  2 +
 drivers/platform/x86/fjes/Makefile    | 31 +++++++++++++++
 drivers/platform/x86/fjes/fjes.h      | 30 ++++++++++++++
 drivers/platform/x86/fjes/fjes_main.c | 74 +++++++++++++++++++++++++++++++++++
 5 files changed, 144 insertions(+)
 create mode 100644 drivers/platform/x86/fjes/Makefile
 create mode 100644 drivers/platform/x86/fjes/fjes.h
 create mode 100644 drivers/platform/x86/fjes/fjes_main.c

diff --git a/drivers/platform/x86/Kconfig b/drivers/platform/x86/Kconfig
index 9752761..353b613 100644
--- a/drivers/platform/x86/Kconfig
+++ b/drivers/platform/x86/Kconfig
@@ -884,4 +884,11 @@ config PVPANIC
 	  a paravirtualized device provided by QEMU; it lets a virtual machine
 	  (guest) communicate panic events to the host.
 
+config FUJITSU_ES
+	tristate "FUJITSU Extended Socket Network Device driver"
+	depends on ACPI
+	---help---
+	  This driver provides support for Extended Socket network device on
+	  Extended Partitioning of FUJITSU PRIMEQUEST 2000 series.
+
 endif # X86_PLATFORM_DEVICES
diff --git a/drivers/platform/x86/Makefile b/drivers/platform/x86/Makefile
index f82232b..a88516c 100644
--- a/drivers/platform/x86/Makefile
+++ b/drivers/platform/x86/Makefile
@@ -58,3 +58,5 @@ obj-$(CONFIG_INTEL_SMARTCONNECT)	+= intel-smartconnect.o
 
 obj-$(CONFIG_PVPANIC)           += pvpanic.o
 obj-$(CONFIG_ALIENWARE_WMI)	+= alienware-wmi.o
+
+obj-$(CONFIG_FUJITSU_ES)        += fjes/
diff --git a/drivers/platform/x86/fjes/Makefile b/drivers/platform/x86/fjes/Makefile
new file mode 100644
index 0000000..98e59cb
--- /dev/null
+++ b/drivers/platform/x86/fjes/Makefile
@@ -0,0 +1,31 @@
+################################################################################
+#
+# FUJITSU Extended Socket Network Device driver
+# Copyright (c) 2015 FUJITSU LIMITED
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
+# You should have received a copy of the GNU General Public License along with
+# this program; if not, see <http://www.gnu.org/licenses/>.
+#
+# The full GNU General Public License is included in this distribution in
+# the file called "COPYING".
+#
+################################################################################
+
+
+#
+# Makefile for the FUJITSU Extended Socket network device driver
+#
+
+obj-$(CONFIG_FUJITSU_ES) += fjes.o
+
+fjes-objs := fjes_main.o
+
diff --git a/drivers/platform/x86/fjes/fjes.h b/drivers/platform/x86/fjes/fjes.h
new file mode 100644
index 0000000..f12fe11
--- /dev/null
+++ b/drivers/platform/x86/fjes/fjes.h
@@ -0,0 +1,30 @@
+/*
+ *  FUJITSU Extended Socket Network Device driver
+ *  Copyright (c) 2015 FUJITSU LIMITED
+ *
+ * This program is free software; you can redistribute it and/or modify it
+ * under the terms and conditions of the GNU General Public License,
+ * version 2, as published by the Free Software Foundation.
+ *
+ * This program is distributed in the hope it will be useful, but WITHOUT
+ * ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or
+ * FITNESS FOR A PARTICULAR PURPOSE.  See the GNU General Public License for
+ * more details.
+ *
+ * You should have received a copy of the GNU General Public License along with
+ * this program; if not, see <http://www.gnu.org/licenses/>.
+ *
+ * The full GNU General Public License is included in this distribution in
+ * the file called "COPYING".
+ *
+ */
+
+
+#ifndef FJES_H_
+#define FJES_H_
+
+extern char fjes_driver_name[];
+extern char fjes_driver_version[];
+extern u32 fjes_support_mtu[];
+
+#endif /* FJES_H_ */
diff --git a/drivers/platform/x86/fjes/fjes_main.c b/drivers/platform/x86/fjes/fjes_main.c
new file mode 100644
index 0000000..f1e2fa0
--- /dev/null
+++ b/drivers/platform/x86/fjes/fjes_main.c
@@ -0,0 +1,74 @@
+/*
+ *  FUJITSU Extended Socket Network Device driver
+ *  Copyright (c) 2015 FUJITSU LIMITED
+ *
+ * This program is free software; you can redistribute it and/or modify it
+ * under the terms and conditions of the GNU General Public License,
+ * version 2, as published by the Free Software Foundation.
+ *
+ * This program is distributed in the hope it will be useful, but WITHOUT
+ * ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or
+ * FITNESS FOR A PARTICULAR PURPOSE.  See the GNU General Public License for
+ * more details.
+ *
+ * You should have received a copy of the GNU General Public License along with
+ * this program; if not, see <http://www.gnu.org/licenses/>.
+ *
+ * The full GNU General Public License is included in this distribution in
+ * the file called "COPYING".
+ *
+ */
+
+#include <linux/module.h>
+#include <linux/types.h>
+
+#include "fjes.h"
+
+#define MAJ 1
+#define MIN 0
+#define DRV_VERSION __stringify(MAJ) "." __stringify(MIN)
+#define DRV_NAME	"fjes"
+char fjes_driver_name[] = DRV_NAME;
+char fjes_driver_version[] = DRV_VERSION;
+static const char fjes_driver_string[] =
+		"FUJITSU Extended Socket Network Device Driver";
+static const char fjes_copyright[] =
+		"Copyright (c) 2015 FUJITSU LIMITED";
+
+
+MODULE_AUTHOR("Taku Izumi <izumi.taku@jp.fujitsu.com>");
+MODULE_DESCRIPTION("FUJITSU Extended Socket Network Device Driver");
+MODULE_LICENSE("GPL");
+MODULE_VERSION(DRV_VERSION);
+
+
+/*
+ *  fjes_init_module - Driver Registration Routine
+ *
+ *  fjes_init_module is the first routine called when the driver is
+ *  loaded.
+ */
+static int __init fjes_init_module(void)
+{
+	pr_info("%s - version %s\n",
+			fjes_driver_string, fjes_driver_version);
+	pr_info("%s\n", fjes_copyright);
+
+	return 0;
+}
+
+module_init(fjes_init_module);
+
+
+/*
+ *  fjes_exit_module - Driver Exit Cleanup Routine
+ *
+ *  fjes_exit_module is called just before the driver is removed from memory.
+ */
+static void __exit fjes_exit_module(void)
+{
+}
+
+module_exit(fjes_exit_module);
+
+
-- 
1.8.3.1
