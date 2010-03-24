From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [PATCH] e1000e: Use pr_<level> and netdev_<level>
Date: Wed, 24 Mar 2010 15:55:30 -0700
Message-ID: <20100324225529.7104.17189.stgit@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, gospo@redhat.com,
	Joe Perches <joe@perches.com>,
	Bruce Allan <bruce.w.allan@intel.com>,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from qmta05.emeryville.ca.mail.comcast.net ([76.96.30.48]:33400 "EHLO
	qmta05.emeryville.ca.mail.comcast.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751314Ab0CXW4Q (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 24 Mar 2010 18:56:16 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Bruce Allan <bruce.w.allan@intel.com>

As an alternative to a quite large patch previously submitted by Joe
Perches to make use of kernel logging API, this patch is much less
intrusive.

Convert e_<level> to netdev_<level>
Use #define pr_fmt
Convert a few printks to pr_<level>

Cc: Joe Perches <joe@perches.com>
Signed-off-by: Bruce Allan <bruce.w.allan@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---

 drivers/net/e1000e/e1000.h  |   19 +++++--------------
 drivers/net/e1000e/netdev.c |    9 +++++----
 2 files changed, 10 insertions(+), 18 deletions(-)

diff --git a/drivers/net/e1000e/e1000.h b/drivers/net/e1000e/e1000.h
index 118bdf4..23ab67c 100644
--- a/drivers/net/e1000e/e1000.h
+++ b/drivers/net/e1000e/e1000.h
@@ -42,25 +42,16 @@
 
 struct e1000_info;
 
-#define e_printk(level, adapter, format, arg...) \
-	printk(level "%s: %s: " format, pci_name(adapter->pdev), \
-	       adapter->netdev->name, ## arg)
-
-#ifdef DEBUG
 #define e_dbg(format, arg...) \
-	e_printk(KERN_DEBUG , hw->adapter, format, ## arg)
-#else
-#define e_dbg(format, arg...) do { (void)(hw); } while (0)
-#endif
-
+	netdev_dbg(hw->adapter->netdev, format, ## arg)
 #define e_err(format, arg...) \
-	e_printk(KERN_ERR, adapter, format, ## arg)
+	netdev_err(adapter->netdev, format, ## arg)
 #define e_info(format, arg...) \
-	e_printk(KERN_INFO, adapter, format, ## arg)
+	netdev_info(adapter->netdev, format, ## arg)
 #define e_warn(format, arg...) \
-	e_printk(KERN_WARNING, adapter, format, ## arg)
+	netdev_warn(adapter->netdev, format, ## arg)
 #define e_notice(format, arg...) \
-	e_printk(KERN_NOTICE, adapter, format, ## arg)
+	netdev_notice(adapter->netdev, format, ## arg)
 
 
 /* Interrupt modes, as used by the IntMode parameter */
diff --git a/drivers/net/e1000e/netdev.c b/drivers/net/e1000e/netdev.c
index e1cceb6..ad4546e 100644
--- a/drivers/net/e1000e/netdev.c
+++ b/drivers/net/e1000e/netdev.c
@@ -26,6 +26,8 @@
 
 *******************************************************************************/
 
+#define pr_fmt(fmt) KBUILD_MODNAME ": " fmt
+
 #include <linux/module.h>
 #include <linux/types.h>
 #include <linux/init.h>
@@ -5394,10 +5396,9 @@ static struct pci_driver e1000_driver = {
 static int __init e1000_init_module(void)
 {
 	int ret;
-	printk(KERN_INFO "%s: Intel(R) PRO/1000 Network Driver - %s\n",
-	       e1000e_driver_name, e1000e_driver_version);
-	printk(KERN_INFO "%s: Copyright (c) 1999 - 2009 Intel Corporation.\n",
-	       e1000e_driver_name);
+	pr_info("Intel(R) PRO/1000 Network Driver - %s\n",
+		e1000e_driver_version);
+	pr_info("Copyright (c) 1999 - 2009 Intel Corporation.\n");
 	ret = pci_register_driver(&e1000_driver);
 
 	return ret;

