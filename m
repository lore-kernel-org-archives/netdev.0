From: Shmulik Hen <shmulik.hen@intel.com>
Subject: [SET 1][PATCH 2/6][bonding] backport 2.6 changes to 2.4
Date: Fri, 8 Aug 2003 17:44:21 +0300
Sender: netdev-bounce@oss.sgi.com
Message-ID: <200308081744.21237.shmulik.hen@intel.com>
Reply-To: shmulik.hen@intel.com
Mime-Version: 1.0
Content-Type: text/plain;
  charset="us-ascii"
Content-Transfer-Encoding: 8bit
Return-path: <netdev-bounce@oss.sgi.com>
To: bonding-devel@lists.sourceforge.net, netdev@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Export alloc_netdev()

diff -Nuarp linux-2.4.22-rc1/drivers/net/net_init.c linux-2.4.22-rc1-devel/drivers/net/net_init.c
--- linux-2.4.22-rc1/drivers/net/net_init.c	Fri Aug  8 14:02:26 2003
+++ linux-2.4.22-rc1-devel/drivers/net/net_init.c	Fri Aug  8 14:02:27 2003
@@ -71,7 +71,7 @@
 */
 
 
-static struct net_device *alloc_netdev(int sizeof_priv, const char *mask,
+struct net_device *alloc_netdev(int sizeof_priv, const char *mask,
 				       void (*setup)(struct net_device *))
 {
 	struct net_device *dev;
@@ -97,6 +97,7 @@ static struct net_device *alloc_netdev(i
 
 	return dev;
 }
+EXPORT_SYMBOL(alloc_netdev);
 
 static struct net_device *init_alloc_dev(int sizeof_priv)
 {
diff -Nuarp linux-2.4.22-rc1/include/linux/netdevice.h linux-2.4.22-rc1-devel/include/linux/netdevice.h
--- linux-2.4.22-rc1/include/linux/netdevice.h	Fri Aug  8 14:02:26 2003
+++ linux-2.4.22-rc1-devel/include/linux/netdevice.h	Fri Aug  8 14:02:27 2003
@@ -801,6 +801,8 @@ extern void		tr_setup(struct net_device 
 extern void		fc_setup(struct net_device *dev);
 extern void		fc_freedev(struct net_device *dev);
 /* Support for loadable net-drivers */
+extern struct net_device *alloc_netdev(int sizeof_priv, const char *name,
+				       void (*setup)(struct net_device *));
 extern int		register_netdev(struct net_device *dev);
 extern void		unregister_netdev(struct net_device *dev);
 /* Functions used for multicast support */


-- 
| Shmulik Hen   Advanced Network Services  |
| Israel Design Center, Jerusalem          |
| LAN Access Division, Platform Networking |
| Intel Communications Group, Intel corp.  |
