From: Stephen Hemminger <shemminger@osdl.org>
Subject: [PATCH] mark dev_alloc as deprecated.
Date: Tue, 14 Oct 2003 11:19:40 -0700
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20031014111940.709280d7.shemminger@osdl.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: "David S. Miller" <davem@redhat.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

dev_alloc is an older way of getting a network device.  Most uses of it are gone,
and it was usually used in an unsafe way.  The remaining usage in 2.6.0-test7
are in arcnet devices.

diff -urN -X dontdiff linux-2.5/include/linux/netdevice.h linux-2.5-net/include/linux/netdevice.h
--- linux-2.5/include/linux/netdevice.h	2003-10-07 11:28:37.000000000 -0700
+++ linux-2.5-net/include/linux/netdevice.h	2003-10-07 11:59:36.000000000 -0700
@@ -511,7 +511,11 @@
 						    unsigned short mask);
 extern struct net_device	*dev_get_by_name(const char *name);
 extern struct net_device	*__dev_get_by_name(const char *name);
-extern struct net_device	*dev_alloc(const char *name, int *err);
+extern struct net_device        *__dev_alloc(const char *name, int *err);
+static inline __deprecated struct net_device *dev_alloc(const char *name, int *err)
+{
+	return __dev_alloc(name, err);
+}
 extern int		dev_alloc_name(struct net_device *dev, const char *name);
 extern int		dev_open(struct net_device *dev);
 extern int		dev_close(struct net_device *dev);
diff -urN -X dontdiff linux-2.5/net/core/dev.c linux-2.5-net/net/core/dev.c
--- linux-2.5/net/core/dev.c	2003-10-07 11:29:56.000000000 -0700
+++ linux-2.5-net/net/core/dev.c	2003-10-07 16:35:51.000000000 -0700
@@ -646,11 +646,12 @@
  *	failed. The cause of an error is returned as a negative errno code
  *	in the variable @err points to.
  *
- *	The caller must hold the @dev_base or RTNL locks when doing this in
+ *	This call is deprecated in favor of alloc_netdev because
+ *	the caller must hold the @dev_base or RTNL locks when doing this in
  *	order to avoid duplicate name allocations.
  */
 
-struct net_device *dev_alloc(const char *name, int *err)
+struct net_device *__dev_alloc(const char *name, int *err)
 {
 	struct net_device *dev = kmalloc(sizeof(*dev), GFP_KERNEL);
 
@@ -2997,7 +2998,7 @@
 EXPORT_SYMBOL(__skb_linearize);
 EXPORT_SYMBOL(call_netdevice_notifiers);
 EXPORT_SYMBOL(dev_add_pack);
-EXPORT_SYMBOL(dev_alloc);
+EXPORT_SYMBOL(__dev_alloc);
 EXPORT_SYMBOL(dev_alloc_name);
 EXPORT_SYMBOL(dev_close);
 EXPORT_SYMBOL(dev_get_by_flags);
