From: "Bryan O'Sullivan" <bos@serpentine.com>
Subject: [TRIVIAL PATCH] export dev->state via sysfs
Date: 19 Aug 2003 22:04:56 -0700
Sender: netdev-bounce@oss.sgi.com
Message-ID: <1061355896.10843.22.camel@camp4.serpentine.com>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Return-path: <netdev-bounce@oss.sgi.com>
To: netdev@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

This trivial patch exports the netdev state field via sysfs.  The
motivation is to make it possible to check link state from userspace
without having to go through the netlink interface.

	<b

--- 2.6.0-test3/net/core/net-sysfs.c	Wed Jul 23 12:21:29 2003
+++ 2.6.0-test3-sysfs/net/core/net-sysfs.c	Tue Aug 19 22:04:13 2003
@@ -147,6 +147,10 @@
 
 static CLASS_DEVICE_ATTR(flags, S_IRUGO | S_IWUSR, show_flags, store_flags);
 
+NETDEVICE_SHOW(state, "%#x\n");
+
+static CLASS_DEVICE_ATTR(state, S_IRUGO, show_state, NULL);
+
 NETDEVICE_SHOW(tx_queue_len, "%lu\n");
 
 static int change_tx_queue_len(struct net_device *net, unsigned long new_len)
@@ -172,6 +176,7 @@
 	&class_device_attr_features,
 	&class_device_attr_mtu,
 	&class_device_attr_flags,
+	&class_device_attr_state,
 	&class_device_attr_type,
 	&class_device_attr_address,
 	&class_device_attr_broadcast,
