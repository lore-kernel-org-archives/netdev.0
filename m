From: David Dillow <dave@thedillows.org>
Subject: [RFC BK 2/22] xfrm offload v2: Add xfrm offload management calls to struct netdevice
Date: Mon, 10 Jan 2005 10:36:59 -0500
Message-ID: <20040110014300.11@ori.thedillows.org>
References: <20040110014300.10@ori.thedillows.org>
Cc: dave@thedillows.org
Return-path: <netdev-bounce@oss.sgi.com>
To: netdev@oss.sgi.com
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

# This is a BitKeeper generated diff -Nru style patch.
#
# ChangeSet
#   2005/01/10 00:02:31-05:00 dave@thedillows.org 
#   Add the xfrm offload management calls to struct netdevice.
#   
#   xfrm_state_add() is called for inbound xfrm states
#   xfrm_bundle_add() is called for outbound xfrm bundles
#   xfrm_state_del() is called for all offloaded xfrms,
#   	inbound or outbound.
#   
#   If a driver adds NETIF_F_IPSEC to its features, it must
#   provide all three callbacks.
#   
#   Signed-off-by: David Dillow <dave@thedillows.org>
# 
# include/linux/netdevice.h
#   2005/01/10 00:02:15-05:00 dave@thedillows.org +10 -0
#   Add the xfrm offload management calls to struct netdevice.
#   
#   xfrm_state_add() is called for inbound xfrm states
#   xfrm_bundle_add() is called for outbound xfrm bundles
#   xfrm_state_del() is called for all offloaded xfrms,
#   	inbound or outbound.
#   
#   If a driver adds NETIF_F_IPSEC to its features, it must
#   provide all three callbacks.
#   
#   Signed-off-by: David Dillow <dave@thedillows.org>
# 
diff -Nru a/include/linux/netdevice.h b/include/linux/netdevice.h
--- a/include/linux/netdevice.h	2005-01-10 01:20:27 -05:00
+++ b/include/linux/netdevice.h	2005-01-10 01:20:27 -05:00
@@ -250,6 +250,8 @@
 };
 #define NETDEV_BOOT_SETUP_MAX 8
 
+struct xfrm_state;
+struct xfrm_offload;
 
 /*
  *	The DEVICE structure.
@@ -415,6 +417,7 @@
 #define NETIF_F_VLAN_CHALLENGED	1024	/* Device cannot handle VLAN packets */
 #define NETIF_F_TSO		2048	/* Can offload TCP/IP segmentation */
 #define NETIF_F_LLTX		4096	/* LockLess TX */
+#define NETIF_F_IPSEC		8192	/* Can offload IPSEC crypto */
 
 	/* Called after device is detached from network. */
 	void			(*uninit)(struct net_device *dev);
@@ -464,6 +467,13 @@
 						   unsigned short vid);
 	void			(*vlan_rx_kill_vid)(struct net_device *dev,
 						    unsigned short vid);
+
+	void			(*xfrm_state_add)(struct net_device *dev,
+						  struct xfrm_state *x);
+	void			(*xfrm_bundle_add)(struct net_device *dev,
+						   struct dst_entry *bundle);
+	void			(*xfrm_state_del)(struct net_device *dev,
+						  struct xfrm_offload *xol);
 
 	int			(*hard_header_parse)(struct sk_buff *skb,
 						     unsigned char *haddr);
