From: Stephen Hemminger <shemminger@osdl.org>
Subject: [PATCH 2.5.70+] expose alloc_netdev for use by drivers.
Date: Mon, 9 Jun 2003 11:51:01 -0700
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20030609115101.1f875e0c.shemminger@osdl.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: "David S. Miller" <davem@redhat.com>, Jeff Garzik <jgarzik@pobox.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Several network drivers (tun, bridge, slip, vlan, ...) need to allocate private data structures
in a like manner to ether_allocdev.  This exposes the net_init hook for them to use.

diff -Nru a/drivers/net/net_init.c b/drivers/net/net_init.c
--- a/drivers/net/net_init.c	Mon Jun  9 11:42:25 2003
+++ b/drivers/net/net_init.c	Mon Jun  9 11:42:25 2003
@@ -70,7 +70,7 @@
 */
 
 
-static struct net_device *alloc_netdev(int sizeof_priv, const char *mask,
+struct net_device *alloc_netdev(int sizeof_priv, const char *mask,
 				       void (*setup)(struct net_device *))
 {
 	struct net_device *dev;
@@ -96,6 +96,7 @@
 
 	return dev;
 }
+EXPORT_SYMBOL(alloc_netdev);
 
 static struct net_device *init_alloc_dev(int sizeof_priv)
 {
diff -Nru a/include/linux/etherdevice.h b/include/linux/etherdevice.h
--- a/include/linux/etherdevice.h	Mon Jun  9 11:42:25 2003
+++ b/include/linux/etherdevice.h	Mon Jun  9 11:42:25 2003
@@ -40,7 +40,6 @@
 					 unsigned char *haddr);
 extern struct net_device *init_etherdev(struct net_device *dev, int sizeof_priv);
 extern struct net_device *alloc_etherdev(int sizeof_priv);
-
 static inline void eth_copy_and_sum (struct sk_buff *dest, unsigned char *src, int len, int base)
 {
 	memcpy (dest->data, src, len);
diff -Nru a/include/linux/netdevice.h b/include/linux/netdevice.h
--- a/include/linux/netdevice.h	Mon Jun  9 11:42:25 2003
+++ b/include/linux/netdevice.h	Mon Jun  9 11:42:25 2003
@@ -815,6 +815,8 @@
 extern void		fc_setup(struct net_device *dev);
 extern void		fc_freedev(struct net_device *dev);
 /* Support for loadable net-drivers */
+extern struct net_device *alloc_netdev(int sizeof_priv, const char *name,
+				       void (*setup)(struct net_device *));
 extern int		register_netdev(struct net_device *dev);
 extern void		unregister_netdev(struct net_device *dev);
 /* Functions used for multicast support */
