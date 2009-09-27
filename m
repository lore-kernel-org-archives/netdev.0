From: Johannes Berg <johannes-cdvu00un1VgdHxzADdlk8Q@public.gmane.org>
Subject: [PATCH 1/2] net: introduce NETDEV_PRE_INIT notifier
Date: Sun, 27 Sep 2009 20:26:39 +0200
Message-ID: <1254075999.6583.4.camel@johannes.local>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: linux-wireless <linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
To: netdev <netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
Return-path: <linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
Sender: linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

For various purposes including a wireless extensions
bugfix, we need to hook into the netdev creation at
a point before netdev_register_kobject(). It seems
more generic, however, to have it even earlier. This
will also ease doing the dev type assignment that
Marcel was working on generically.

Signed-off-by: Johannes Berg <johannes-cdvu00un1VgdHxzADdlk8Q@public.gmane.org>
---
 include/linux/notifier.h |    1 +
 net/core/dev.c           |    5 +++++
 2 files changed, 6 insertions(+)

--- wireless-testing.orig/include/linux/notifier.h	2009-09-27 15:09:10.000000000 +0200
+++ wireless-testing/include/linux/notifier.h	2009-09-27 15:10:19.000000000 +0200
@@ -199,6 +199,7 @@ static inline int notifier_to_errno(int 
 #define NETDEV_FEAT_CHANGE	0x000B
 #define NETDEV_BONDING_FAILOVER 0x000C
 #define NETDEV_PRE_UP		0x000D
+#define NETDEV_PRE_INIT		0x000E
 
 #define SYS_DOWN	0x0001	/* Notify of system down */
 #define SYS_RESTART	SYS_DOWN
--- wireless-testing.orig/net/core/dev.c	2009-09-27 15:09:56.000000000 +0200
+++ wireless-testing/net/core/dev.c	2009-09-27 15:11:40.000000000 +0200
@@ -4734,6 +4734,11 @@ int register_netdevice(struct net_device
 
 	dev->iflink = -1;
 
+	ret = call_netdevice_notifiers(NETDEV_PRE_INIT, dev);
+	ret = notifier_to_errno(ret);
+	if (ret)
+		goto out;
+
 	/* Init, if this function is available */
 	if (dev->netdev_ops->ndo_init) {
 		ret = dev->netdev_ops->ndo_init(dev);


--
To unsubscribe from this list: send the line "unsubscribe linux-wireless" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
