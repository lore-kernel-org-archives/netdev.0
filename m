From: Stephen Hemminger <shemminger@osdl.org>
Subject: [PATCH] (6/6) tokenring -- get rid of old probe
Date: Wed, 15 Oct 2003 13:48:20 -0700
Sender: netdev-bounce@oss.sgi.com
Message-ID: <200310152048.h9FKmKH11939@mail.osdl.org>
Cc: netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: jgarzik@pobox.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Now that all the old drivers are gone from trif_probe,
it can be deleted.

diff -Nru a/drivers/net/Space.c b/drivers/net/Space.c
--- a/drivers/net/Space.c	Mon Oct 13 13:08:06 2003
+++ b/drivers/net/Space.c	Mon Oct 13 13:08:06 2003
@@ -430,26 +430,6 @@
 	{NULL, 0},
 };
 
-static __init int trif_probe(int unit)
-{
-	struct net_device *dev;
-	int err = -ENODEV;
-	
-	dev = alloc_trdev(0);
-	if (!dev)
-		return -ENOMEM;
-
-	sprintf(dev->name, "tr%d", unit);
-	netdev_boot_setup_check(dev);
-	if (
-	    0 ) 
-		err = register_netdev(dev);
-		
-	if (err)
-		free_netdev(dev);
-	return err;
-
-}
 
 static void __init trif_probe2(int unit)
 {
@@ -484,8 +464,7 @@
 #endif
 #ifdef CONFIG_TR
 	for (num = 0; num < 8; ++num)
-		if (!trif_probe(num))
-			trif_probe2(num);
+		trif_probe2(num);
 #endif
 	for (num = 0; num < 8; ++num)
 		if (!ethif_probe(num))
