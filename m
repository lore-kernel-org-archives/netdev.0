From: Jeff Muizelaar <muizelaar@rogers.com>
Subject: [PATCH] post-sysfs netdev cleanup
Date: Thu, 22 May 2003 20:41:17 -0400
Sender: netdev-bounce@oss.sgi.com
Message-ID: <3ECD6E2D.5090000@rogers.com>
Mime-Version: 1.0
Content-Type: multipart/mixed;
 boundary="------------090507050505030501060708"
Cc: netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: shemminger@osdl.org
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

This is a multi-part message in MIME format.
--------------090507050505030501060708
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit

The attached patch removes the struct device from struct net_device and 
sets net_device.class_dev.dev directly.
The class_dev memset is removed because all of struct net_device should 
already be memset to 0 or there will be other problems.

-Jeff

--------------090507050505030501060708
Content-Type: text/plain;
 name="netdev-cleanup.patch"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline;
 filename="netdev-cleanup.patch"

diff -urN linux-2.5.69-bk15/include/linux/netdevice.h linux-2.5.69-bk15-netdev-cleanup/include/linux/netdevice.h
--- linux-2.5.69-bk15/include/linux/netdevice.h	2003-05-22 20:14:06.000000000 -0400
+++ linux-2.5.69-bk15-netdev-cleanup/include/linux/netdevice.h	2003-05-22 20:15:56.000000000 -0400
@@ -441,9 +441,6 @@
 	struct divert_blk	*divert;
 #endif /* CONFIG_NET_DIVERT */
 
-	/* generic device structure used in constructing class */
-	struct device		*dev;
-
 	/* class/net/name entry */
 	struct class_device	class_dev;
 
@@ -455,7 +452,7 @@
 /* Set the sysfs physical device reference for the network logical device
  * if set prior to registration will cause a symlink during initialization.
  */
-#define SET_NETDEV_DEV(net, pdev)	((net)->dev = (pdev))
+#define SET_NETDEV_DEV(net, pdev)	((net)->class_dev.dev = (pdev))
 
 
 struct packet_type 
diff -urN linux-2.5.69-bk15/net/core/net-sysfs.c linux-2.5.69-bk15-netdev-cleanup/net/core/net-sysfs.c
--- linux-2.5.69-bk15/net/core/net-sysfs.c	2003-05-22 20:14:08.000000000 -0400
+++ linux-2.5.69-bk15-netdev-cleanup/net/core/net-sysfs.c	2003-05-22 20:15:56.000000000 -0400
@@ -291,9 +291,7 @@
 	struct class_device_attribute *attr;
 	int ret;
 
-	memset(class_dev, 0, sizeof(struct class_device)); 
 	class_dev->class = &net_class;
-	class_dev->dev = net->dev;
 	class_dev->class_data = net;
 
 	snprintf(class_dev->class_id, BUS_ID_SIZE, net->name);

--------------090507050505030501060708--
