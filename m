From: Dan Aloni <da-x@gmx.net>
Subject: [PATCH] network device renaming sysfs fix
Date: Fri, 15 Aug 2003 14:15:14 +0300
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20030815111514.GA5228@callisto.yi.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: "David S. Miller" <davem@redhat.com>, Mark Huth <mhuth@mvista.com>
Return-path: <netdev-bounce@oss.sgi.com>
To: Linux Net-Dev <netdev@oss.sgi.com>
Content-Disposition: inline
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

(repost, now will hopefully reach the mailing list)

I believe this is a better approach for fixing the sysfs renaming
discrepancy. Later I'll also look into fixing the same issue 
with sysctl.

--- linux/net/core/dev.c	2003-08-15 12:47:50.000000000 +0300
+++ linux/net/core/dev.c	2003-08-15 12:47:59.000000000 +0300
@@ -2347,10 +2347,14 @@
 				return -EEXIST;
 			memcpy(dev->name, ifr->ifr_newname, IFNAMSIZ);
 			dev->name[IFNAMSIZ - 1] = 0;
-			strlcpy(dev->class_dev.class_id, dev->name, BUS_ID_SIZE);
+
+			err = class_device_rename(&dev->class_dev, dev->name);
+			if (err) 
+				printk(KERN_DEBUG "SIOCSIFNAME: error renaming class_device (%d)\n", err);
+
 			notifier_call_chain(&netdev_chain,
 					    NETDEV_CHANGENAME, dev);
-			return 0;
+			return err;
 
 		/*
 		 *	Unknown or private ioctl



-- 
Dan Aloni
da-x@gmx.net
