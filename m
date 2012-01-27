From: Paul Gortmaker <paul.gortmaker@windriver.com>
Subject: [PATCH net-next] drivers/net: strip unused module code from sun3_82586.c
Date: Fri, 27 Jan 2012 18:55:46 -0500
Message-ID: <1327708546-30973-1-git-send-email-paul.gortmaker@windriver.com>
Cc: netdev@vger.kernel.org,
	Paul Gortmaker <paul.gortmaker@windriver.com>
To: sammy@sammy.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.windriver.com ([147.11.1.11]:45623 "EHLO
	mail.windriver.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751521Ab2A0X4a (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 27 Jan 2012 18:56:30 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This code is clearly unused, since it has a #error right
in it.  Given the vintage of sun3 hardware, it is probably
safe to assume that there is little interest in adding new
functionality to the driver now, so just delete the unused
block of code.

Signed-off-by: Paul Gortmaker <paul.gortmaker@windriver.com>

diff --git a/drivers/net/ethernet/i825xx/sun3_82586.c b/drivers/net/ethernet/i825xx/sun3_82586.c
index 6ef5e11..296cf8a 100644
--- a/drivers/net/ethernet/i825xx/sun3_82586.c
+++ b/drivers/net/ethernet/i825xx/sun3_82586.c
@@ -28,7 +28,6 @@ static int automatic_resume = 0; /* experimental .. better should be zero */
 static int rfdadd = 0; /* rfdadd=1 may be better for 8K MEM cards */
 static int fifo=0x8;	/* don't change */
 
-#include <linux/module.h>
 #include <linux/kernel.h>
 #include <linux/string.h>
 #include <linux/errno.h>
@@ -1151,28 +1150,6 @@ static void set_multicast_list(struct net_device *dev)
 	netif_wake_queue(dev);
 }
 
-#ifdef MODULE
-#error This code is not currently supported as a module
-static struct net_device *dev_sun3_82586;
-
-int init_module(void)
-{
-	dev_sun3_82586 = sun3_82586_probe(-1);
-	if (IS_ERR(dev_sun3_82586))
-		return PTR_ERR(dev_sun3_82586);
-	return 0;
-}
-
-void cleanup_module(void)
-{
-	unsigned long ioaddr = dev_sun3_82586->base_addr;
-	unregister_netdev(dev_sun3_82586);
-	release_region(ioaddr, SUN3_82586_TOTAL_SIZE);
-	iounmap((void *)ioaddr);
-	free_netdev(dev_sun3_82586);
-}
-#endif /* MODULE */
-
 #if 0
 /*
  * DUMP .. we expect a not running CMD unit and enough space
@@ -1209,5 +1186,3 @@ void sun3_82586_dump(struct net_device *dev,void *ptr)
 	printk("\n");
 }
 #endif
-
-MODULE_LICENSE("GPL");
-- 
1.7.7
