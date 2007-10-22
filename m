From: Pavel Emelyanov <xemul@openvz.org>
Subject: [PATCH 2/3] Remove in-code externs for some functions from net/core/dev.c
Date: Mon, 22 Oct 2007 19:25:50 +0400
Message-ID: <471CC0FE.9030602@openvz.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: Linux Netdev List <netdev@vger.kernel.org>, devel@openvz.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from sacred.ru ([62.205.161.221]:43482 "EHLO sacred.ru"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752026AbXJVPZQ (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 22 Oct 2007 11:25:16 -0400
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Inconsistent prototype and real type for functions may have
worse consequences, than those for variables, so move them
into a header.

Since they are used privately in net/core, make this file
reside in the same place.

Signed-off-by: Pavel Emelyanov <xemul@openvz.org>

---

diff --git a/net/core/dev.c b/net/core/dev.c
index 8726589..9ea3665 100644
--- a/net/core/dev.c
+++ b/net/core/dev.c
@@ -120,6 +120,8 @@
 #include <linux/ctype.h>
 #include <linux/if_arp.h>
 
+#include "net-sysfs.h"
+
 /*
  *	The list of packet types we will receive (as opposed to discard)
  *	and the routines to invoke.
@@ -249,10 +251,6 @@ static RAW_NOTIFIER_HEAD(netdev_chain);
 
 DEFINE_PER_CPU(struct softnet_data, softnet_data);
 
-extern int netdev_kobject_init(void);
-extern int netdev_register_kobject(struct net_device *);
-extern void netdev_unregister_kobject(struct net_device *);
-
 #ifdef CONFIG_DEBUG_LOCK_ALLOC
 /*
  * register_netdevice() inits dev->_xmit_lock and sets lockdep class
diff --git a/net/core/net-sysfs.c b/net/core/net-sysfs.c
index 6628e45..61ead1d 100644
--- a/net/core/net-sysfs.c
+++ b/net/core/net-sysfs.c
@@ -18,6 +18,8 @@
 #include <linux/wireless.h>
 #include <net/iw_handler.h>
 
+#include "net-sysfs.h"
+
 #ifdef CONFIG_SYSFS
 static const char fmt_hex[] = "%#x\n";
 static const char fmt_long_hex[] = "%#lx\n";
diff --git a/net/core/net-sysfs.h b/net/core/net-sysfs.h
new file mode 100644
index 0000000..a41683d
--- /dev/null
+++ b/net/core/net-sysfs.h
@@ -0,0 +1,8 @@
+#ifndef __NET_SYSFS_H__
+#define __NET_SYSFS_H__
+
+int netdev_kobject_init(void);
+int netdev_register_kobject(struct net_device *);
+void netdev_unregister_kobject(struct net_device *);
+
+#endif
-- 
1.5.3.4

