From: Stephen Hemminger <shemminger@osdl.org>
Subject: [PATCH] (2/11) bridge -- cleanup of bridge allocation
Date: Fri, 21 May 2004 15:47:58 -0700
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20040521154758.16f6e873@dell_ss3.pdx.osdl.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: bridge@osdl.org, netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: "David S. Miller" <davem@redhat.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Minor cleanup (lead in to later sysfs support).  
Change new_nb to new_bridge_dev and return the net_device rather than
bridge because that is what the caller wants anyway.

diff -Nru a/net/bridge/br_if.c b/net/bridge/br_if.c
--- a/net/bridge/br_if.c	2004-05-20 08:44:18 -07:00
+++ b/net/bridge/br_if.c	2004-05-20 08:44:18 -07:00
@@ -124,7 +124,7 @@
  	unregister_netdevice(br->dev);
 }
 
-static struct net_bridge *new_nb(const char *name)
+static struct net_device *new_bridge_dev(const char *name)
 {
 	struct net_bridge *br;
 	struct net_device *dev;
@@ -135,7 +135,7 @@
 	if (!dev)
 		return NULL;
 
-	br = dev->priv;
+	br = netdev_priv(dev);
 	br->dev = dev;
 
 	br->lock = SPIN_LOCK_UNLOCKED;
@@ -160,7 +160,7 @@
 
 	br_stp_timer_init(br);
 
-	return br;
+	return dev;
 }
 
 /* find an available port number */
@@ -218,15 +218,16 @@
 
 int br_add_bridge(const char *name)
 {
-	struct net_bridge *br;
+	struct net_device *dev;
 	int ret;
 
-	if ((br = new_nb(name)) == NULL) 
+	dev = new_bridge_dev(name);
+	if (!dev) 
 		return -ENOMEM;
 
-	ret = register_netdev(br->dev);
+	ret = register_netdev(dev);
 	if (ret)
-		free_netdev(br->dev);
+		free_netdev(dev);
 	return ret;
 }
 
@@ -251,7 +252,7 @@
 	} 
 
 	else 
-		del_br(dev->priv);
+		del_br(netdev_priv(dev));
 
 	rtnl_unlock();
 	return ret;
