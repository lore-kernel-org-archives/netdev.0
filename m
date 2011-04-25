From: dykmanj@linux.vnet.ibm.com
Subject: [PATCH v4 01/27] HFI: skeleton driver
Date: Mon, 25 Apr 2011 17:23:41 -0400
Message-ID: <1303766647-30156-2-git-send-email-dykmanj@linux.vnet.ibm.com>
References: <1303766647-30156-1-git-send-email-dykmanj@linux.vnet.ibm.com>
Cc: Jim Dykman <dykmanj@linux.vnet.ibm.com>,
	Piyush Chaudhary <piyushc@linux.vnet.ibm.com>,
	Fu-Chung Chang <fcchang@linux.vnet.ibm.com>,
	" William S. Cadden" <wscadden@linux.vnet.ibm.com>,
	" Wen C. Chen" <winstonc@linux.vnet.ibm.com>,
	Scot Sakolish <sakolish@linux.vnet.ibm.com>,
	Jian Xiao <jian@linux.vnet.ibm.com>,
	" Carol L. Soto" <clsoto@linux.vnet.ibm.com>,
	" Sarah J. Sheppard" <sjsheppa@linux.vnet.ibm.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from e33.co.us.ibm.com ([32.97.110.151]:41763 "EHLO
	e33.co.us.ibm.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752668Ab1DYVYS (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 25 Apr 2011 17:24:18 -0400
Received: from d03relay02.boulder.ibm.com (d03relay02.boulder.ibm.com [9.17.195.227])
	by e33.co.us.ibm.com (8.14.4/8.13.1) with ESMTP id p3PLHKcF005146
	for <netdev@vger.kernel.org>; Mon, 25 Apr 2011 15:17:20 -0600
Received: from d03av05.boulder.ibm.com (d03av05.boulder.ibm.com [9.17.195.85])
	by d03relay02.boulder.ibm.com (8.13.8/8.13.8/NCO v9.1) with ESMTP id p3PLOE8M116732
	for <netdev@vger.kernel.org>; Mon, 25 Apr 2011 15:24:14 -0600
Received: from d03av05.boulder.ibm.com (loopback [127.0.0.1])
	by d03av05.boulder.ibm.com (8.14.4/8.13.1/NCO v10.0 AVout) with ESMTP id p3PLODaW032125
	for <netdev@vger.kernel.org>; Mon, 25 Apr 2011 15:24:14 -0600
In-Reply-To: <1303766647-30156-1-git-send-email-dykmanj@linux.vnet.ibm.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jim Dykman <dykmanj@linux.vnet.ibm.com>

Device driver Makefile & Kconfig plumbing plus simple mod_init and mod_exit

Signed-off-by:  Piyush Chaudhary <piyushc@linux.vnet.ibm.com>
Signed-off-by:  Jim Dykman <dykmanj@linux.vnet.ibm.com>
Signed-off-by:  Fu-Chung Chang <fcchang@linux.vnet.ibm.com>
Signed-off-by:  William S. Cadden <wscadden@linux.vnet.ibm.com>
Signed-off-by:  Wen C. Chen <winstonc@linux.vnet.ibm.com>
Signed-off-by:  Scot Sakolish <sakolish@linux.vnet.ibm.com>
Signed-off-by:  Jian Xiao <jian@linux.vnet.ibm.com>
Signed-off-by:  Carol L. Soto <clsoto@linux.vnet.ibm.com>
Signed-off-by:  Sarah J. Sheppard <sjsheppa@linux.vnet.ibm.com>
---
 drivers/net/Kconfig                |    2 +
 drivers/net/Makefile               |    2 +
 drivers/net/hfi/Makefile           |    1 +
 drivers/net/hfi/core/Kconfig       |    8 ++
 drivers/net/hfi/core/Makefile      |    5 ++
 drivers/net/hfi/core/hfidd_init.c  |  141 ++++++++++++++++++++++++++++++++++++
 include/linux/Kbuild               |    1 +
 include/linux/hfi/Kbuild           |    1 +
 include/linux/hfi/hfidd_client.h   |   40 ++++++++++
 include/linux/hfi/hfidd_internal.h |   53 ++++++++++++++
 10 files changed, 254 insertions(+), 0 deletions(-)
 create mode 100644 drivers/net/hfi/Makefile
 create mode 100644 drivers/net/hfi/core/Kconfig
 create mode 100644 drivers/net/hfi/core/Makefile
 create mode 100644 drivers/net/hfi/core/hfidd_init.c
 create mode 100644 include/linux/hfi/Kbuild
 create mode 100644 include/linux/hfi/hfidd_client.h
 create mode 100644 include/linux/hfi/hfidd_internal.h

diff --git a/drivers/net/Kconfig b/drivers/net/Kconfig
index dc280bc..1abbfd9 100644
--- a/drivers/net/Kconfig
+++ b/drivers/net/Kconfig
@@ -3436,4 +3436,6 @@ config VMXNET3
 	  To compile this driver as a module, choose M here: the
 	  module will be called vmxnet3.
 
+source "drivers/net/hfi/core/Kconfig"
+
 endif # NETDEVICES
diff --git a/drivers/net/Makefile b/drivers/net/Makefile
index 01b604a..e9ea418 100644
--- a/drivers/net/Makefile
+++ b/drivers/net/Makefile
@@ -304,3 +304,5 @@ obj-$(CONFIG_CAIF) += caif/
 obj-$(CONFIG_OCTEON_MGMT_ETHERNET) += octeon/
 obj-$(CONFIG_PCH_GBE) += pch_gbe/
 obj-$(CONFIG_TILE_NET) += tile/
+
+obj-$(CONFIG_HFI) += hfi/
diff --git a/drivers/net/hfi/Makefile b/drivers/net/hfi/Makefile
new file mode 100644
index 0000000..0440cbe
--- /dev/null
+++ b/drivers/net/hfi/Makefile
@@ -0,0 +1 @@
+obj-$(CONFIG_HFI)                += core/
diff --git a/drivers/net/hfi/core/Kconfig b/drivers/net/hfi/core/Kconfig
new file mode 100644
index 0000000..3cd637c
--- /dev/null
+++ b/drivers/net/hfi/core/Kconfig
@@ -0,0 +1,8 @@
+config HFI
+	tristate "HFI driver support"
+	depends on IBMEBUS
+	---help---
+	This driver supports the IBM System p HFI adapter.
+
+	To compile the driver as a module, choose M here. The module
+	will be called hfi_core.
diff --git a/drivers/net/hfi/core/Makefile b/drivers/net/hfi/core/Makefile
new file mode 100644
index 0000000..80790c6
--- /dev/null
+++ b/drivers/net/hfi/core/Makefile
@@ -0,0 +1,5 @@
+#
+# Makefile for the HFI device driver for IBM eServer System p
+#
+hfi_core-objs:=	hfidd_init.o
+obj-$(CONFIG_HFI) += hfi_core.o
diff --git a/drivers/net/hfi/core/hfidd_init.c b/drivers/net/hfi/core/hfidd_init.c
new file mode 100644
index 0000000..9498faf
--- /dev/null
+++ b/drivers/net/hfi/core/hfidd_init.c
@@ -0,0 +1,141 @@
+/*
+ * hfidd_init.c
+ *
+ * HFI device driver for IBM System p
+ *
+ *  Authors:
+ *      Fu-Chung Chang <fcchang@linux.vnet.ibm.com>
+ *      William S. Cadden <wscadden@linux.vnet.ibm.com>
+ *      Wen C. Chen <winstonc@linux.vnet.ibm.com>
+ *      Scot Sakolish <sakolish@linux.vnet.ibm.com>
+ *      Jian Xiao <jian@linux.vnet.ibm.com>
+ *      Carol L. Soto <clsoto@linux.vnet.ibm.com>
+ *      Sarah J. Sheppard <sjsheppa@linux.vnet.ibm.com>
+ *
+ *  (C) Copyright IBM Corp. 2010
+ *
+ * This program is free software; you can redistribute it and/or modify
+ * it under the terms of the GNU General Public License as published by
+ * the Free Software Foundation; either version 2 of the License, or
+ * (at your option) any later version.
+ *
+ * This program is distributed in the hope that it will be useful,
+ * but WITHOUT ANY WARRANTY; without even the implied warranty of
+ * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
+ * GNU General Public License for more details.
+ *
+ * You should have received a copy of the GNU General Public License
+ * along with this program; if not, write to the Free Software
+ * Foundation, Inc., 59 Temple Place, Suite 330, Boston, MA  02111-1307  USA
+ *
+ */
+
+#include <linux/module.h>
+#include <linux/init.h>
+#include <linux/device.h>
+
+#include <linux/hfi/hfidd_internal.h>
+
+MODULE_VERSION("1.0");
+MODULE_DESCRIPTION("Device Driver for IBM eServer HFI for IBM System p");
+MODULE_AUTHOR("James Dykman <dykmanj@linux.vnet.ibm.com> and "
+	 "Piyush Chaudhary <piyushc@linux.vnet.ibm.com>");
+MODULE_LICENSE("GPL v2");
+
+struct hfidd_global hfidd_global;
+EXPORT_SYMBOL_GPL(hfidd_global);
+
+static dev_t   hfidd_dev;
+
+#define MAX_HFI_DEVS (MAX_HFIS + 1)
+
+/* Function to get our internal traces */
+static ssize_t hfidd_read(struct file *filep, char *buf, size_t count,
+		loff_t *pos)
+{
+	return 0;
+}
+
+/* Entry point for user space to do driver requests. */
+static ssize_t hfidd_cmd_write(struct file *filep, const char __user *buf,
+		size_t count, loff_t *pos)
+{
+	return 0;
+}
+
+static const struct file_operations hfidd_fops = {
+	.owner		= THIS_MODULE,
+	.read		= hfidd_read,
+	.write		= hfidd_cmd_write,
+};
+
+/* Destroy the HFI class */
+static inline void hfidd_destroy_class(void)
+{
+	class_destroy(hfidd_global.class);
+	cdev_del(&hfidd_global.cdev);
+	unregister_chrdev_region(hfidd_dev, MAX_HFI_DEVS);
+}
+
+/* Create the HFI class */
+static int hfidd_create_class(void)
+{
+	int rc;
+
+	rc = alloc_chrdev_region(&hfidd_dev, 0, MAX_HFI_DEVS, HFIDD_DEV_NAME);
+	if (rc) {
+		printk(KERN_ERR "%s: hfidd_create_class: alloc_chrdev_region"
+				" failed rc 0x%x\n", HFIDD_DEV_NAME, rc);
+		return rc;
+	}
+
+	cdev_init(&hfidd_global.cdev, &hfidd_fops);
+	hfidd_global.cdev.owner = THIS_MODULE;
+	kobject_set_name(&hfidd_global.cdev.kobj, HFIDD_DEV_NAME);
+	rc = cdev_add(&hfidd_global.cdev, hfidd_dev, MAX_HFI_DEVS);
+	if (rc) {
+		printk(KERN_ERR "%s: hfidd_create_class cdev_add fail"
+				" rc = %d\n", HFIDD_DEV_NAME, rc);
+		goto hfidd_create_class_error1;
+	}
+
+	hfidd_global.class = class_create(THIS_MODULE, HFIDD_CLASS_NAME);
+	if (IS_ERR(hfidd_global.class)) {
+		rc = PTR_ERR(hfidd_global.class);
+		printk(KERN_ERR "%s: hfidd_create_class class_create fail rc = %d\n",
+				HFIDD_DEV_NAME, rc);
+		goto hfidd_create_class_error2;
+	}
+
+	return rc;
+
+hfidd_create_class_error2:
+	cdev_del(&hfidd_global.cdev);
+hfidd_create_class_error1:
+	unregister_chrdev_region(hfidd_dev, MAX_HFI_DEVS);
+
+	return rc;
+}
+
+static int __init hfidd_mod_init(void)
+{
+	int			rc = 0;
+
+	rc = hfidd_create_class();
+	if (rc < 0) {
+		printk(KERN_ERR "%s: hfidd_mod_init: hfidd_create_class failed"
+			" rc=%d\n", HFIDD_DEV_NAME, rc);
+		return rc;
+	}
+
+	printk(KERN_INFO "IBM hfi device driver loaded sucessfully\n");
+	return 0;
+}
+
+static void __exit hfidd_mod_exit(void)
+{
+	hfidd_destroy_class();
+}
+
+module_init(hfidd_mod_init);
+module_exit(hfidd_mod_exit);
diff --git a/include/linux/Kbuild b/include/linux/Kbuild
index 75cf611..df925b4 100644
--- a/include/linux/Kbuild
+++ b/include/linux/Kbuild
@@ -3,6 +3,7 @@ header-y += can/
 header-y += caif/
 header-y += dvb/
 header-y += hdlc/
+header-y += hfi/
 header-y += isdn/
 header-y += nfsd/
 header-y += raid/
diff --git a/include/linux/hfi/Kbuild b/include/linux/hfi/Kbuild
new file mode 100644
index 0000000..3a742ce
--- /dev/null
+++ b/include/linux/hfi/Kbuild
@@ -0,0 +1 @@
+header-y += hfidd_client.h
diff --git a/include/linux/hfi/hfidd_client.h b/include/linux/hfi/hfidd_client.h
new file mode 100644
index 0000000..b738f4b
--- /dev/null
+++ b/include/linux/hfi/hfidd_client.h
@@ -0,0 +1,40 @@
+/*
+ * hfidd_client.h
+ *
+ * HFI device driver for IBM System p
+ *
+ *  Authors:
+ *      Fu-Chung Chang <fcchang@linux.vnet.ibm.com>
+ *      William S. Cadden <wscadden@linux.vnet.ibm.com>
+ *      Wen C. Chen <winstonc@linux.vnet.ibm.com>
+ *      Scot Sakolish <sakolish@linux.vnet.ibm.com>
+ *      Jian Xiao <jian@linux.vnet.ibm.com>
+ *      Carol L. Soto <clsoto@linux.vnet.ibm.com>
+ *      Sarah J. Sheppard <sjsheppa@linux.vnet.ibm.com>
+ *
+ *  (C) Copyright IBM Corp. 2010
+ *
+ * This program is free software; you can redistribute it and/or modify
+ * it under the terms of the GNU General Public License as published by
+ * the Free Software Foundation; either version 2 of the License, or
+ * (at your option) any later version.
+ *
+ * This program is distributed in the hope that it will be useful,
+ * but WITHOUT ANY WARRANTY; without even the implied warranty of
+ * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
+ * GNU General Public License for more details.
+ *
+ * You should have received a copy of the GNU General Public License
+ * along with this program; if not, write to the Free Software
+ * Foundation, Inc., 59 Temple Place, Suite 330, Boston, MA  02111-1307  USA
+ *
+ */
+
+#ifndef _HFIDD_CLIENT_H_
+#define _HFIDD_CLIENT_H_
+
+#define MAX_TORRENTS            1
+#define MAX_HFI_PER_TORRENT     2
+#define MAX_HFIS                (MAX_TORRENTS * MAX_HFI_PER_TORRENT)
+
+#endif /* _HFIDD_CLIENT_H_ */
diff --git a/include/linux/hfi/hfidd_internal.h b/include/linux/hfi/hfidd_internal.h
new file mode 100644
index 0000000..f5de1bb
--- /dev/null
+++ b/include/linux/hfi/hfidd_internal.h
@@ -0,0 +1,53 @@
+/*
+ * hfidd_internal.h
+ *
+ * HFI device driver for IBM System p
+ *
+ *  Authors:
+ *      Fu-Chung Chang <fcchang@linux.vnet.ibm.com>
+ *      William S. Cadden <wscadden@linux.vnet.ibm.com>
+ *      Wen C. Chen <winstonc@linux.vnet.ibm.com>
+ *      Scot Sakolish <sakolish@linux.vnet.ibm.com>
+ *      Jian Xiao <jian@linux.vnet.ibm.com>
+ *      Carol L. Soto <clsoto@linux.vnet.ibm.com>
+ *      Sarah J. Sheppard <sjsheppa@linux.vnet.ibm.com>
+ *
+ *  (C) Copyright IBM Corp. 2010
+ *
+ * This program is free software; you can redistribute it and/or modify
+ * it under the terms of the GNU General Public License as published by
+ * the Free Software Foundation; either version 2 of the License, or
+ * (at your option) any later version.
+ *
+ * This program is distributed in the hope that it will be useful,
+ * but WITHOUT ANY WARRANTY; without even the implied warranty of
+ * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
+ * GNU General Public License for more details.
+ *
+ * You should have received a copy of the GNU General Public License
+ * along with this program; if not, write to the Free Software
+ * Foundation, Inc., 59 Temple Place, Suite 330, Boston, MA  02111-1307  USA
+ *
+ */
+
+#ifndef _HFI_INTERNAL_H_
+#define _HFI_INTERNAL_H_
+
+#include <linux/fs.h>
+#include <linux/kobject.h>
+#include <linux/cdev.h>
+#include <linux/init.h>
+#include <linux/kernel.h>
+
+#include <linux/hfi/hfidd_client.h>
+
+#define HFIDD_DEV_NAME		"hfi"
+#define HFIDD_CLASS_NAME	"hfi"
+
+/* DD global */
+struct hfidd_global {
+	struct cdev		cdev;
+	struct class		*class;
+};
+
+#endif
-- 
1.7.3.5

