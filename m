From: sfeldma@gmail.com
Subject: [PATCH net-next v4 3/8] switchdev: add IPv4 fib ndo ops wrappers
Date: Thu,  5 Mar 2015 21:21:15 -0800
Message-ID: <1425619280-27492-4-git-send-email-sfeldma@gmail.com>
References: <1425619280-27492-1-git-send-email-sfeldma@gmail.com>
To: netdev@vger.kernel.org, davem@davemloft.net, jiri@resnulli.us,
	roopa@cumulusnetworks.com, alexander.h.duyck@redhat.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f43.google.com ([209.85.220.43]:41041 "EHLO
	mail-pa0-f43.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753538AbbCFFUj (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 6 Mar 2015 00:20:39 -0500
Received: by pablj1 with SMTP id lj1so42464301pab.8
        for <netdev@vger.kernel.org>; Thu, 05 Mar 2015 21:20:38 -0800 (PST)
In-Reply-To: <1425619280-27492-1-git-send-email-sfeldma@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Scott Feldman <sfeldma@gmail.com>

Add IPv4 fib ndo wrapper funcs and stub them out for now.

Signed-off-by: Scott Feldman <sfeldma@gmail.com>
---
 include/net/switchdev.h   |   19 +++++++++++++++++++
 net/switchdev/switchdev.c |   39 +++++++++++++++++++++++++++++++++++++++
 2 files changed, 58 insertions(+)

diff --git a/include/net/switchdev.h b/include/net/switchdev.h
index cfcdac2..8d2ac66 100644
--- a/include/net/switchdev.h
+++ b/include/net/switchdev.h
@@ -51,6 +51,11 @@ int ndo_dflt_netdev_switch_port_bridge_dellink(struct net_device *dev,
 					       struct nlmsghdr *nlh, u16 flags);
 int ndo_dflt_netdev_switch_port_bridge_setlink(struct net_device *dev,
 					       struct nlmsghdr *nlh, u16 flags);
+int netdev_switch_fib_ipv4_add(u32 dst, int dst_len, struct fib_info *fi,
+			       u8 tos, u8 type, u32 tb_id);
+int netdev_switch_fib_ipv4_del(u32 dst, int dst_len, struct fib_info *fi,
+			       u8 tos, u8 type, u32 tb_id);
+
 #else
 
 static inline int netdev_switch_parent_id_get(struct net_device *dev,
@@ -109,6 +114,20 @@ static inline int ndo_dflt_netdev_switch_port_bridge_setlink(struct net_device *
 	return 0;
 }
 
+static inline int netdev_switch_fib_ipv4_add(u32 dst, int dst_len,
+					     struct fib_info *fi,
+					     u8 tos, u8 type, u32 tb_id)
+{
+	return 0;
+}
+
+static inline int netdev_switch_fib_ipv4_del(u32 dst, int dst_len,
+					     struct fib_info *fi,
+					     u8 tos, u8 type, u32 tb_id)
+{
+	return 0;
+}
+
 #endif
 
 #endif /* _LINUX_SWITCHDEV_H_ */
diff --git a/net/switchdev/switchdev.c b/net/switchdev/switchdev.c
index 8c1e558..3c090f8 100644
--- a/net/switchdev/switchdev.c
+++ b/net/switchdev/switchdev.c
@@ -14,6 +14,7 @@
 #include <linux/mutex.h>
 #include <linux/notifier.h>
 #include <linux/netdevice.h>
+#include <net/ip_fib.h>
 #include <net/switchdev.h>
 
 /**
@@ -225,3 +226,41 @@ int ndo_dflt_netdev_switch_port_bridge_dellink(struct net_device *dev,
 	return ret;
 }
 EXPORT_SYMBOL(ndo_dflt_netdev_switch_port_bridge_dellink);
+
+/**
+ *	netdev_switch_fib_ipv4_add - Add IPv4 route entry to switch
+ *
+ *	@dst: route's IPv4 destination address
+ *	@dst_len: destination address length (prefix length)
+ *	@fi: route FIB info structure
+ *	@tos: route TOS
+ *	@type: route type
+ *	@tb_id: route table ID
+ *
+ *	Add IPv4 route entry to switch device.
+ */
+int netdev_switch_fib_ipv4_add(u32 dst, int dst_len, struct fib_info *fi,
+			       u8 tos, u8 type, u32 tb_id)
+{
+	return 0;
+}
+EXPORT_SYMBOL(netdev_switch_fib_ipv4_add);
+
+/**
+ *	netdev_switch_fib_ipv4_del - Delete IPv4 route entry from switch
+ *
+ *	@dst: route's IPv4 destination address
+ *	@dst_len: destination address length (prefix length)
+ *	@fi: route FIB info structure
+ *	@tos: route TOS
+ *	@type: route type
+ *	@tb_id: route table ID
+ *
+ *	Delete IPv4 route entry from switch device.
+ */
+int netdev_switch_fib_ipv4_del(u32 dst, int dst_len, struct fib_info *fi,
+			       u8 tos, u8 type, u32 tb_id)
+{
+	return 0;
+}
+EXPORT_SYMBOL(netdev_switch_fib_ipv4_del);
-- 
1.7.10.4
