From: Stephen Hemminger <shemminger@osdl.org>
Subject: [PATCH] (3/5) remove X25 pre-existing device discovery loop
Date: Tue, 13 Jan 2004 11:01:03 -0800
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20040113110103.4a36c0d1.shemminger@osdl.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@oss.sgi.com, Henner Eisen <eis@baty.hanse.de>,
        linux-x25@vger.kernel.org
Return-path: <netdev-bounce@oss.sgi.com>
To: "David S. Miller" <davem@redhat.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Remove duplicate/conflicting code 
now that netdev_register_notifier replays the device registration events.

diff -Nru a/net/x25/af_x25.c b/net/x25/af_x25.c
--- a/net/x25/af_x25.c	Mon Jan 12 14:22:07 2004
+++ b/net/x25/af_x25.c	Mon Jan 12 14:22:07 2004
@@ -1372,9 +1372,6 @@
 
 static int __init x25_init(void)
 {
-#ifdef MODULE
-	struct net_device *dev;
-#endif /* MODULE */
 	sock_register(&x25_family_ops);
 
 	dev_add_pack(&x25_packet_type);
@@ -1386,23 +1383,7 @@
 #ifdef CONFIG_SYSCTL
 	x25_register_sysctl();
 #endif
-
 	x25_proc_init();
-#ifdef MODULE
-	/*
-	 *	Register any pre existing devices.
-	 */
-	read_lock(&dev_base_lock);
-	for (dev = dev_base; dev; dev = dev->next) {
-		if ((dev->flags & IFF_UP) && (dev->type == ARPHRD_X25
-#if defined(CONFIG_LLC) || defined(CONFIG_LLC_MODULE)
-					   || dev->type == ARPHRD_ETHER
-#endif
-			))
-			x25_link_device_up(dev);
-	}
-	read_unlock(&dev_base_lock);
-#endif /* MODULE */
 	return 0;
 }
 module_init(x25_init);
