From: Stephen Hemminger <shemminger@osdl.org>
Subject: [PATCH] mark init_etherdev as deprecated
Date: Thu, 16 Oct 2003 10:28:31 -0700
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20031016102831.589d9e20.shemminger@osdl.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: "David S. Miller" <davem@redhat.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

For 2.6.0-test7-bk latest, mark init_etherdev as deprecated because it is
implicitly racy, and has been replaced by using alloc_etherdev.

diff -Nru a/drivers/net/net_init.c b/drivers/net/net_init.c
--- a/drivers/net/net_init.c	Thu Oct 16 10:20:46 2003
+++ b/drivers/net/net_init.c	Thu Oct 16 10:20:46 2003
@@ -197,9 +197,13 @@
  *
  * If an empty string area is passed as dev->name, or a new structure is made,
  * a new name string is constructed.
+ *
+ * Deprecated because of exposed window between device registration 
+ * and interfaces pointers that need to be set by driver.
+ * Use alloc_etherdev and register_netdev instead.
  */
 
-struct net_device *init_etherdev(struct net_device *dev, int sizeof_priv)
+struct net_device *__init_etherdev(struct net_device *dev, int sizeof_priv)
 {
 	return init_netdev(dev, sizeof_priv, "eth%d", ether_setup);
 }
@@ -222,7 +226,7 @@
 	return alloc_netdev(sizeof_priv, "eth%d", ether_setup);
 }
 
-EXPORT_SYMBOL(init_etherdev);
+EXPORT_SYMBOL(__init_etherdev);
 EXPORT_SYMBOL(alloc_etherdev);
 
 static int eth_mac_addr(struct net_device *dev, void *p)
diff -Nru a/include/linux/etherdevice.h b/include/linux/etherdevice.h
--- a/include/linux/etherdevice.h	Thu Oct 16 10:20:46 2003
+++ b/include/linux/etherdevice.h	Thu Oct 16 10:20:46 2003
@@ -38,7 +38,13 @@
 					 struct hh_cache *hh);
 extern int		eth_header_parse(struct sk_buff *skb,
 					 unsigned char *haddr);
-extern struct net_device *init_etherdev(struct net_device *dev, int sizeof_priv);
+extern struct net_device *__init_etherdev(struct net_device *dev, int sizeof_priv);
+static inline __deprecated struct net_device *init_etherdev(struct net_device *dev,
+							    int sizeof_priv)
+{
+	return __init_etherdev(dev, sizeof_priv);
+}
+
 extern struct net_device *alloc_etherdev(int sizeof_priv);
 static inline void eth_copy_and_sum (struct sk_buff *dest, unsigned char *src, int len, int base)
 {
