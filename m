From: Amir Noam <amir.noam@intel.com>
Subject: [PATCH 2/3] [bonding 2.4] Backport free_netdev()
Date: Mon, 15 Sep 2003 12:00:34 +0300
Sender: netdev-bounce@oss.sgi.com
Message-ID: <200309151200.34709.amir.noam@intel.com>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="us-ascii"
Content-Transfer-Encoding: 8bit
Cc: jgarzik@pobox.com
Return-path: <netdev-bounce@oss.sgi.com>
To: bonding-devel@lists.sourceforge.net, netdev@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

diff -Nuarp a/drivers/net/bonding/bond_main.c b/drivers/net/bonding/bond_main.c
--- a/drivers/net/bonding/bond_main.c	2003-09-15 11:39:39.000000000 +0300
+++ b/drivers/net/bonding/bond_main.c	2003-09-15 11:39:41.000000000 +0300
@@ -3788,7 +3788,7 @@ static void bond_free_all(void)
 
 		unregister_netdev(dev);
 		bond_deinit(dev);
-		kfree(dev);
+		free_netdev(dev);
 	}
 }
 
@@ -4194,7 +4194,7 @@ static int __init bonding_init(void)
 
 		err = dev_alloc_name(dev, "bond%d");
 		if (err < 0) {
-			kfree(dev);
+			free_netdev(dev);
 			goto out_err;
 		}
 
@@ -4204,7 +4204,7 @@ static int __init bonding_init(void)
 		 */
 		err = bond_init(dev);
 		if (err < 0) {
-			kfree(dev);
+			free_netdev(dev);
 			goto out_err;
 		}
 
@@ -4213,7 +4213,7 @@ static int __init bonding_init(void)
 		err = register_netdevice(dev);
 		if (err < 0) {
 			bond_deinit(dev);
-			kfree(dev);
+			free_netdev(dev);
 			goto out_err;
 		}
 	}
diff -Nuarp a/include/linux/netdevice.h b/include/linux/netdevice.h
--- a/include/linux/netdevice.h	2003-09-15 11:39:39.000000000 +0300
+++ b/include/linux/netdevice.h	2003-09-15 11:39:41.000000000 +0300
@@ -49,6 +49,7 @@ struct ethtool_ops;
 
 #define HAVE_ALLOC_NETDEV		/* feature macro: alloc_xxxdev
 					   functions are available. */
+#define HAVE_FREE_NETDEV
 
 #define NET_XMIT_SUCCESS	0
 #define NET_XMIT_DROP		1	/* skb dropped			*/
@@ -871,6 +872,10 @@ extern int		netdev_fastroute_obstacles;
 extern void		dev_clear_fastroute(struct net_device *dev);
 #endif
 
+static inline void free_netdev(struct net_device *dev)
+{
+	kfree(dev);
+}
 
 #endif /* __KERNEL__ */
 
