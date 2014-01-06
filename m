From: Daniel Borkmann <dborkman@redhat.com>
Subject: [PATCH net-next] net: netdev_kobject_init: annotate with __init
Date: Mon,  6 Jan 2014 01:20:11 +0100
Message-ID: <1388967611-14263-1-git-send-email-dborkman@redhat.com>
Cc: netdev@vger.kernel.org
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:56320 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751407AbaAFAUO (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sun, 5 Jan 2014 19:20:14 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

netdev_kobject_init() is only being called from __init context,
that is, net_dev_init(), so annotate it with __init as well, thus
the kernel can take this as a hint that the function is used only
during the initialization phase and free up used memory resources
after its invocation.

Signed-off-by: Daniel Borkmann <dborkman@redhat.com>
---
 net/core/net-sysfs.c | 2 +-
 net/core/net-sysfs.h | 2 +-
 2 files changed, 2 insertions(+), 2 deletions(-)

diff --git a/net/core/net-sysfs.c b/net/core/net-sysfs.c
index 1a7b7b1..49843bf 100644
--- a/net/core/net-sysfs.c
+++ b/net/core/net-sysfs.c
@@ -1358,7 +1358,7 @@ void netdev_class_remove_file_ns(struct class_attribute *class_attr,
 }
 EXPORT_SYMBOL(netdev_class_remove_file_ns);
 
-int netdev_kobject_init(void)
+int __init netdev_kobject_init(void)
 {
 	kobj_ns_type_register(&net_ns_type_operations);
 	return class_register(&net_class);
diff --git a/net/core/net-sysfs.h b/net/core/net-sysfs.h
index bd7751e..2745a1b 100644
--- a/net/core/net-sysfs.h
+++ b/net/core/net-sysfs.h
@@ -1,7 +1,7 @@
 #ifndef __NET_SYSFS_H__
 #define __NET_SYSFS_H__
 
-int netdev_kobject_init(void);
+int __init netdev_kobject_init(void);
 int netdev_register_kobject(struct net_device *);
 void netdev_unregister_kobject(struct net_device *);
 int net_rx_queue_update_kobjects(struct net_device *, int old_num, int new_num);
-- 
1.7.11.7
