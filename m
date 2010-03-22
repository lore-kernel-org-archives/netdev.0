From: Tom Herbert <therbert@google.com>
Subject: rps: Fix build with CONFIG_SYSFS enabled
Date: Mon, 22 Mar 2010 13:57:56 -0700 (PDT)
Message-ID: <alpine.DEB.1.00.1003221355380.25849@pokey.mtv.corp.google.com>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: netdev@vger.kernel.org
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp-out.google.com ([216.239.44.51]:34981 "EHLO
	smtp-out.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752137Ab0CVU6A (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 22 Mar 2010 16:58:00 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Fix build with CONFIG_SYSFS not enabled.


Signed-off-by: Tom Herbert <therbert@google.com>
---
diff --git a/net/core/net-sysfs.c b/net/core/net-sysfs.c
index 7a46343..f6b6bfe 100644
--- a/net/core/net-sysfs.c
+++ b/net/core/net-sysfs.c
@@ -739,7 +739,9 @@ void netdev_unregister_kobject(struct net_device * net)
 	if (!net_eq(dev_net(net), &init_net))
 		return;
 
+#ifdef CONFIG_SYSFS
 	rx_queue_remove_kobjects(net);
+#endif
 
 	device_del(dev);
 }
@@ -780,11 +782,13 @@ int netdev_register_kobject(struct net_device *net)
 	if (error)
 		return error;
 
+#ifdef CONFIG_SYSFS
 	error = rx_queue_register_kobjects(net);
 	if (error) {
 		device_del(dev);
 		return error;
 	}
+#endif
 
 	return error;
 }

