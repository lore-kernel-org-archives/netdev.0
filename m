From: Stephen Hemminger <shemminger@osdl.org>
Subject: [PATCH] ethertap can use alloc_etherdev
Date: Tue, 11 Nov 2003 14:45:57 -0800
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20031111144557.38bde052.shemminger@osdl.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Jeff Garzik <jgarzik@pobox.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Can use alloc_etherdev, don't need to call ether_setup.
Found by viro.

diff -Nru a/drivers/net/ethertap.c b/drivers/net/ethertap.c
--- a/drivers/net/ethertap.c	Tue Nov 11 09:36:15 2003
+++ b/drivers/net/ethertap.c	Tue Nov 11 09:36:15 2003
@@ -72,8 +72,7 @@
 	struct net_device *dev;
 	int err = -ENOMEM;
 
-	dev = alloc_netdev(sizeof(struct net_local), "tap%d",
-			   ether_setup);
+	dev = alloc_etherdev(sizeof(struct net_local));
 
 	if (!dev)
 		goto out;
