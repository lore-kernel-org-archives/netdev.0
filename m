From: Stephen Hemminger <shemminger@osdl.org>
Subject: [PATCH] (5/5) lapbether remove pre-existing device discovery loop
Date: Tue, 13 Jan 2004 11:01:47 -0800
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20040113110147.641bf4e1.shemminger@osdl.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@oss.sgi.com, Nenad Corbic <ncorbic@sangoma.com>
Return-path: <netdev-bounce@oss.sgi.com>
To: "David S. Miller" <davem@redhat.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Remove duplicate/conflicting code 
now that netdev_register_notifier replays the device registration events.

diff -Nru a/drivers/net/wan/lapbether.c b/drivers/net/wan/lapbether.c
--- a/drivers/net/wan/lapbether.c	Tue Jan 13 10:26:01 2004
+++ b/drivers/net/wan/lapbether.c	Tue Jan 13 10:26:01 2004
@@ -448,21 +448,11 @@
 
 static int __init lapbeth_init_driver(void)
 {
-	struct net_device *dev;
-
 	dev_add_pack(&lapbeth_packet_type);
 
 	register_netdevice_notifier(&lapbeth_dev_notifier);
 
 	printk(banner);
-
-	rtnl_lock();
-	for (dev = dev_base; dev; dev = dev->next) {
-		if (dev_is_ethdev(dev)) {
-			lapbeth_new_device(dev);
-		}
-	}
-	rtnl_unlock();
 
 	return 0;
 }
