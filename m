From: Amir Noam <amir.noam@intel.com>
Subject: [PATCH 2/5] [bonding] backport 2.6 changes to 2.4
Date: Wed, 30 Jul 2003 20:07:09 +0300
Sender: netdev-bounce@oss.sgi.com
Message-ID: <200307302007.09735.amir.noam@intel.com>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="us-ascii"
Content-Transfer-Encoding: 8bit
Cc: bonding-devel@lists.sourceforge.net, netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: fubar@us.ibm.com, jgarzik@pobox.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Export alloc_netdev()

Amir

diff -Nuarp linux-2.4.22-pre9/drivers/net/net_init.c linux-2.4.22-pre9-devel/drivers/net/net_init.c
--- linux-2.4.22-pre9/drivers/net/net_init.c	Wed Jul 30 19:14:03 2003
+++ linux-2.4.22-pre9-devel/drivers/net/net_init.c	Wed Jul 30 19:14:04 2003
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
diff -Nuarp linux-2.4.22-pre9/include/linux/netdevice.h linux-2.4.22-pre9-devel/include/linux/netdevice.h
--- linux-2.4.22-pre9/include/linux/netdevice.h	Wed Jul 30 19:14:03 2003
+++ linux-2.4.22-pre9-devel/include/linux/netdevice.h	Wed Jul 30 19:14:04 2003
@@ -801,6 +801,8 @@ extern void		tr_setup(struct net_device 
 extern void		fc_setup(struct net_device *dev);
 extern void		fc_freedev(struct net_device *dev);
 /* Support for loadable net-drivers */
+extern struct net_device *alloc_netdev(int sizeof_priv, const char *name,
+				       void (*setup)(struct net_device *));
 extern int		register_netdev(struct net_device *dev);
 extern void		unregister_netdev(struct net_device *dev);
 /* Functions used for multicast support */
