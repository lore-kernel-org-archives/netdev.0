From: Stephen Hemminger <shemminger@osdl.org>
Subject: [PATCH] (1/4) support large number of network devices
Date: Fri, 16 Jan 2004 15:46:52 -0800
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20040116154652.04dd3324.shemminger@osdl.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: "David S. Miller" <davem@redhat.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

In preparation for the other changes to allow large number
of network devices, move the device table head and lock from
over in the network drivers setup code into the core netdev code.


diff -Nru a/drivers/net/Space.c b/drivers/net/Space.c
--- a/drivers/net/Space.c	Thu Jan 15 16:12:02 2004
+++ b/drivers/net/Space.c	Thu Jan 15 16:12:02 2004
@@ -455,28 +455,3 @@
 }
 
 device_initcall(net_olddevs_init);
-
-/*
- * The @dev_base list is protected by @dev_base_lock and the rtln
- * semaphore.
- *
- * Pure readers hold dev_base_lock for reading.
- *
- * Writers must hold the rtnl semaphore while they loop through the
- * dev_base list, and hold dev_base_lock for writing when they do the
- * actual updates.  This allows pure readers to access the list even
- * while a writer is preparing to update it.
- *
- * To put it another way, dev_base_lock is held for writing only to
- * protect against pure readers; the rtnl semaphore provides the
- * protection against other writers.
- *
- * See, for example usages, register_netdevice() and
- * unregister_netdevice(), which must be called with the rtnl
- * semaphore held.
- */
-struct net_device *dev_base;
-rwlock_t dev_base_lock = RW_LOCK_UNLOCKED;
-
-EXPORT_SYMBOL(dev_base);
-EXPORT_SYMBOL(dev_base_lock);
diff -Nru a/net/core/dev.c b/net/core/dev.c
--- a/net/core/dev.c	Thu Jan 15 16:12:02 2004
+++ b/net/core/dev.c	Thu Jan 15 16:12:02 2004
@@ -161,6 +161,31 @@
 #endif
 
 /*
+ * The @dev_base list is protected by @dev_base_lock and the rtln
+ * semaphore.
+ *
+ * Pure readers hold dev_base_lock for reading.
+ *
+ * Writers must hold the rtnl semaphore while they loop through the
+ * dev_base list, and hold dev_base_lock for writing when they do the
+ * actual updates.  This allows pure readers to access the list even
+ * while a writer is preparing to update it.
+ *
+ * To put it another way, dev_base_lock is held for writing only to
+ * protect against pure readers; the rtnl semaphore provides the
+ * protection against other writers.
+ *
+ * See, for example usages, register_netdevice() and
+ * unregister_netdevice(), which must be called with the rtnl
+ * semaphore held.
+ */
+struct net_device *dev_base;
+rwlock_t dev_base_lock = RW_LOCK_UNLOCKED;
+
+EXPORT_SYMBOL(dev_base);
+EXPORT_SYMBOL(dev_base_lock);
+
+/*
  *	Our notifier list
  */
 
