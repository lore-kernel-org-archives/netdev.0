From: Matthew Wilcox <willy@debian.org>
Subject: [PATCH] Move eth_mac_addr and eth_change_mtu
Date: Fri, 11 Jul 2003 19:19:46 +0100
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20030711181946.GG20424@parcelfarce.linux.theplanet.co.uk>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Return-path: <netdev-bounce@oss.sgi.com>
To: netdev@oss.sgi.com
Content-Disposition: inline
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org


Move eth_mac_addr() and eth_change_mtu() from drivers/net/net_init.c
to net/ethernet/eth.c

Index: drivers/net/net_init.c
===================================================================
RCS file: /var/cvs/linux-2.5/drivers/net/net_init.c,v
retrieving revision 1.4
diff -u -p -r1.4 net_init.c
--- drivers/net/net_init.c	14 Jun 2003 22:15:21 -0000	1.4
+++ drivers/net/net_init.c	10 Jul 2003 20:57:55 -0000
@@ -222,23 +222,6 @@ struct net_device *alloc_etherdev(int si
 EXPORT_SYMBOL(init_etherdev);
 EXPORT_SYMBOL(alloc_etherdev);
 
-static int eth_mac_addr(struct net_device *dev, void *p)
-{
-	struct sockaddr *addr=p;
-	if (netif_running(dev))
-		return -EBUSY;
-	memcpy(dev->dev_addr, addr->sa_data,dev->addr_len);
-	return 0;
-}
-
-static int eth_change_mtu(struct net_device *dev, int new_mtu)
-{
-	if ((new_mtu < 68) || (new_mtu > 1500))
-		return -EINVAL;
-	dev->mtu = new_mtu;
-	return 0;
-}
-
 #ifdef CONFIG_FDDI
 
 /**
Index: include/linux/etherdevice.h
===================================================================
RCS file: /var/cvs/linux-2.5/include/linux/etherdevice.h,v
retrieving revision 1.3
diff -u -p -r1.3 etherdevice.h
--- include/linux/etherdevice.h	14 Jun 2003 22:16:01 -0000	1.3
+++ include/linux/etherdevice.h	10 Jul 2003 21:00:23 -0000
@@ -38,6 +38,8 @@ extern int		eth_header_cache(struct neig
 					 struct hh_cache *hh);
 extern int		eth_header_parse(struct sk_buff *skb,
 					 unsigned char *haddr);
+extern int		eth_mac_addr(struct net_device *dev, void *p);
+extern int		eth_change_mtu(struct net_device *dev, int new_mtu);
 extern struct net_device *init_etherdev(struct net_device *dev, int sizeof_priv);
 extern struct net_device *alloc_etherdev(int sizeof_priv);
 static inline void eth_copy_and_sum (struct sk_buff *dest, unsigned char *src, int len, int base)
Index: net/ethernet/eth.c
===================================================================
RCS file: /var/cvs/linux-2.5/net/ethernet/eth.c,v
retrieving revision 1.4
diff -u -p -r1.4 eth.c
--- net/ethernet/eth.c	23 Jun 2003 03:30:58 -0000	1.4
+++ net/ethernet/eth.c	10 Jul 2003 20:58:54 -0000
@@ -241,3 +241,20 @@ void eth_header_cache_update(struct hh_c
 	memcpy(((u8*)hh->hh_data) + HH_DATA_OFF(sizeof(struct ethhdr)),
 	       haddr, dev->addr_len);
 }
+
+int eth_mac_addr(struct net_device *dev, void *p)
+{
+	struct sockaddr *addr=p;
+	if (netif_running(dev))
+		return -EBUSY;
+	memcpy(dev->dev_addr, addr->sa_data, dev->addr_len);
+	return 0;
+}
+
+int eth_change_mtu(struct net_device *dev, int new_mtu)
+{
+	if ((new_mtu < 68) || (new_mtu > 1500))
+		return -EINVAL;
+	dev->mtu = new_mtu;
+	return 0;
+}

-- 
"It's not Hollywood.  War is real, war is primarily not about defeat or
victory, it is about death.  I've seen thousands and thousands of dead bodies.
Do you think I want to have an academic debate on this subject?" -- Robert Fisk
