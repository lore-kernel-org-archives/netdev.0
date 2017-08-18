From: Stephen Hemminger <stephen@networkplumber.org>
Subject: [PATCH net-next 09/10] net: mark receive queue attributes ro_after_init
Date: Fri, 18 Aug 2017 13:46:27 -0700
Message-ID: <20170818204628.17147-10-sthemmin@microsoft.com>
References: <20170818204628.17147-1-sthemmin@microsoft.com>
Cc: netdev@vger.kernel.org, Stephen Hemminger <sthemmin@microsoft.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pg0-f42.google.com ([74.125.83.42]:33600 "EHLO
        mail-pg0-f42.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751935AbdHRUqq (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 18 Aug 2017 16:46:46 -0400
Received: by mail-pg0-f42.google.com with SMTP id t3so43028678pgt.0
        for <netdev@vger.kernel.org>; Fri, 18 Aug 2017 13:46:46 -0700 (PDT)
In-Reply-To: <20170818204628.17147-1-sthemmin@microsoft.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Signed-off-by: Stephen Hemminger <sthemmin@microsoft.com>
---
 net/core/net-sysfs.c | 25 +++++++++++++------------
 1 file changed, 13 insertions(+), 12 deletions(-)

diff --git a/net/core/net-sysfs.c b/net/core/net-sysfs.c
index 808fbb837f25..ca82c4a72350 100644
--- a/net/core/net-sysfs.c
+++ b/net/core/net-sysfs.c
@@ -655,7 +655,7 @@ static const struct attribute_group wireless_group = {
 static ssize_t rx_queue_attr_show(struct kobject *kobj, struct attribute *attr,
 				  char *buf)
 {
-	struct rx_queue_attribute *attribute = to_rx_queue_attr(attr);
+	const struct rx_queue_attribute *attribute = to_rx_queue_attr(attr);
 	struct netdev_rx_queue *queue = to_rx_queue(kobj);
 
 	if (!attribute->show)
@@ -667,7 +667,7 @@ static ssize_t rx_queue_attr_show(struct kobject *kobj, struct attribute *attr,
 static ssize_t rx_queue_attr_store(struct kobject *kobj, struct attribute *attr,
 				   const char *buf, size_t count)
 {
-	struct rx_queue_attribute *attribute = to_rx_queue_attr(attr);
+	const struct rx_queue_attribute *attribute = to_rx_queue_attr(attr);
 	struct netdev_rx_queue *queue = to_rx_queue(kobj);
 
 	if (!attribute->store)
@@ -842,16 +842,15 @@ static ssize_t store_rps_dev_flow_table_cnt(struct netdev_rx_queue *queue,
 	return len;
 }
 
-static struct rx_queue_attribute rps_cpus_attribute =
-	__ATTR(rps_cpus, S_IRUGO | S_IWUSR, show_rps_map, store_rps_map);
+static struct rx_queue_attribute rps_cpus_attribute __ro_after_init
+	= __ATTR(rps_cpus, S_IRUGO | S_IWUSR, show_rps_map, store_rps_map);
 
-
-static struct rx_queue_attribute rps_dev_flow_table_cnt_attribute =
-	__ATTR(rps_flow_cnt, S_IRUGO | S_IWUSR,
-	    show_rps_dev_flow_table_cnt, store_rps_dev_flow_table_cnt);
+static struct rx_queue_attribute rps_dev_flow_table_cnt_attribute __ro_after_init
+	= __ATTR(rps_flow_cnt, S_IRUGO | S_IWUSR,
+		 show_rps_dev_flow_table_cnt, store_rps_dev_flow_table_cnt);
 #endif /* CONFIG_RPS */
 
-static struct attribute *rx_queue_default_attrs[] = {
+static struct attribute *rx_queue_default_attrs[] __ro_after_init = {
 #ifdef CONFIG_RPS
 	&rps_cpus_attribute.attr,
 	&rps_dev_flow_table_cnt_attribute.attr,
@@ -896,7 +895,7 @@ static const void *rx_queue_namespace(struct kobject *kobj)
 	return ns;
 }
 
-static struct kobj_type rx_queue_ktype = {
+static struct kobj_type rx_queue_ktype __ro_after_init = {
 	.sysfs_ops = &rx_queue_sysfs_ops,
 	.release = rx_queue_release,
 	.default_attrs = rx_queue_default_attrs,
@@ -983,7 +982,8 @@ struct netdev_queue_attribute {
 static ssize_t netdev_queue_attr_show(struct kobject *kobj,
 				      struct attribute *attr, char *buf)
 {
-	struct netdev_queue_attribute *attribute = to_netdev_queue_attr(attr);
+	const struct netdev_queue_attribute *attribute
+		= to_netdev_queue_attr(attr);
 	struct netdev_queue *queue = to_netdev_queue(kobj);
 
 	if (!attribute->show)
@@ -996,7 +996,8 @@ static ssize_t netdev_queue_attr_store(struct kobject *kobj,
 				       struct attribute *attr,
 				       const char *buf, size_t count)
 {
-	struct netdev_queue_attribute *attribute = to_netdev_queue_attr(attr);
+	const struct netdev_queue_attribute *attribute
+		= to_netdev_queue_attr(attr);
 	struct netdev_queue *queue = to_netdev_queue(kobj);
 
 	if (!attribute->store)
-- 
2.11.0
