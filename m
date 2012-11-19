From: Bill Pemberton <wfp5p@virginia.edu>
Subject: [PATCH 018/493] net: remove CONFIG_HOTPLUG ifdefs
Date: Mon, 19 Nov 2012 13:19:27 -0500
Message-ID: <1353349642-3677-18-git-send-email-wfp5p@virginia.edu>
References: <1353349642-3677-1-git-send-email-wfp5p@virginia.edu>
Cc: "David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org
To: gregkh@linuxfoundation.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from viridian.itc.Virginia.EDU ([128.143.12.139]:41656 "EHLO
	viridian.itc.virginia.edu" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754520Ab2KSSiI (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 19 Nov 2012 13:38:08 -0500
In-Reply-To: <1353349642-3677-1-git-send-email-wfp5p@virginia.edu>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Remove conditional code based on CONFIG_HOTPLUG being false.  It's
always on now in preparation of it going away as an option.

Signed-off-by: Bill Pemberton <wfp5p@virginia.edu>
Cc: "David S. Miller" <davem@davemloft.net> 
Cc: netdev@vger.kernel.org 
---
 net/core/net-sysfs.c | 4 ----
 1 file changed, 4 deletions(-)

diff --git a/net/core/net-sysfs.c b/net/core/net-sysfs.c
index bcf02f6..adcb1b5 100644
--- a/net/core/net-sysfs.c
+++ b/net/core/net-sysfs.c
@@ -1320,7 +1320,6 @@ struct kobj_ns_type_operations net_ns_type_operations = {
 };
 EXPORT_SYMBOL_GPL(net_ns_type_operations);
 
-#ifdef CONFIG_HOTPLUG
 static int netdev_uevent(struct device *d, struct kobj_uevent_env *env)
 {
 	struct net_device *dev = to_net_dev(d);
@@ -1339,7 +1338,6 @@ static int netdev_uevent(struct device *d, struct kobj_uevent_env *env)
 exit:
 	return retval;
 }
-#endif
 
 /*
  *	netdev_release -- destroy and free a dead device.
@@ -1368,9 +1366,7 @@ static struct class net_class = {
 #ifdef CONFIG_SYSFS
 	.dev_attrs = net_class_attributes,
 #endif /* CONFIG_SYSFS */
-#ifdef CONFIG_HOTPLUG
 	.dev_uevent = netdev_uevent,
-#endif
 	.ns_type = &net_ns_type_operations,
 	.namespace = net_namespace,
 };
-- 
1.8.0
