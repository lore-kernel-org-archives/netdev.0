From: Stephen Hemminger <stephen@networkplumber.org>
Subject: [PATCH net-next 02/10] net: constify netdev_class_file
Date: Fri, 18 Aug 2017 13:46:20 -0700
Message-ID: <20170818204628.17147-3-sthemmin@microsoft.com>
References: <20170818204628.17147-1-sthemmin@microsoft.com>
Cc: netdev@vger.kernel.org, Stephen Hemminger <sthemmin@microsoft.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pg0-f46.google.com ([74.125.83.46]:33563 "EHLO
        mail-pg0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751693AbdHRUqj (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 18 Aug 2017 16:46:39 -0400
Received: by mail-pg0-f46.google.com with SMTP id t3so43026970pgt.0
        for <netdev@vger.kernel.org>; Fri, 18 Aug 2017 13:46:38 -0700 (PDT)
In-Reply-To: <20170818204628.17147-1-sthemmin@microsoft.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

These functions are wrapper arount class_create_file which can take a
const attribute.

Signed-off-by: Stephen Hemminger <sthemmin@microsoft.com>
---
 include/linux/netdevice.h | 8 ++++----
 net/core/net-sysfs.c      | 4 ++--
 2 files changed, 6 insertions(+), 6 deletions(-)

diff --git a/include/linux/netdevice.h b/include/linux/netdevice.h
index 0f1c4cb2441e..eaa77bd9cb80 100644
--- a/include/linux/netdevice.h
+++ b/include/linux/netdevice.h
@@ -4013,17 +4013,17 @@ static inline netdev_tx_t netdev_start_xmit(struct sk_buff *skb, struct net_devi
 	return rc;
 }
 
-int netdev_class_create_file_ns(struct class_attribute *class_attr,
+int netdev_class_create_file_ns(const struct class_attribute *class_attr,
 				const void *ns);
-void netdev_class_remove_file_ns(struct class_attribute *class_attr,
+void netdev_class_remove_file_ns(const struct class_attribute *class_attr,
 				 const void *ns);
 
-static inline int netdev_class_create_file(struct class_attribute *class_attr)
+static inline int netdev_class_create_file(const struct class_attribute *class_attr)
 {
 	return netdev_class_create_file_ns(class_attr, NULL);
 }
 
-static inline void netdev_class_remove_file(struct class_attribute *class_attr)
+static inline void netdev_class_remove_file(const struct class_attribute *class_attr)
 {
 	netdev_class_remove_file_ns(class_attr, NULL);
 }
diff --git a/net/core/net-sysfs.c b/net/core/net-sysfs.c
index 46ff41bf0210..40937ee63f14 100644
--- a/net/core/net-sysfs.c
+++ b/net/core/net-sysfs.c
@@ -1618,14 +1618,14 @@ int netdev_register_kobject(struct net_device *ndev)
 	return error;
 }
 
-int netdev_class_create_file_ns(struct class_attribute *class_attr,
+int netdev_class_create_file_ns(const struct class_attribute *class_attr,
 				const void *ns)
 {
 	return class_create_file_ns(&net_class, class_attr, ns);
 }
 EXPORT_SYMBOL(netdev_class_create_file_ns);
 
-void netdev_class_remove_file_ns(struct class_attribute *class_attr,
+void netdev_class_remove_file_ns(const struct class_attribute *class_attr,
 				 const void *ns)
 {
 	class_remove_file_ns(&net_class, class_attr, ns);
-- 
2.11.0
