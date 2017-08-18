From: Stephen Hemminger <stephen@networkplumber.org>
Subject: [PATCH net-next 06/10] net: drop unused attribute argument from sysfs queue funcs
Date: Fri, 18 Aug 2017 13:46:24 -0700
Message-ID: <20170818204628.17147-7-sthemmin@microsoft.com>
References: <20170818204628.17147-1-sthemmin@microsoft.com>
Cc: netdev@vger.kernel.org, Stephen Hemminger <sthemmin@microsoft.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pg0-f44.google.com ([74.125.83.44]:37615 "EHLO
        mail-pg0-f44.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751695AbdHRUqn (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 18 Aug 2017 16:46:43 -0400
Received: by mail-pg0-f44.google.com with SMTP id y129so71046530pgy.4
        for <netdev@vger.kernel.org>; Fri, 18 Aug 2017 13:46:43 -0700 (PDT)
In-Reply-To: <20170818204628.17147-1-sthemmin@microsoft.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The show and store functions don't need/use the attribute.

Signed-off-by: Stephen Hemminger <sthemmin@microsoft.com>
---
 include/linux/netdevice.h |  5 ++---
 net/core/net-sysfs.c      | 37 +++++++++++--------------------------
 2 files changed, 13 insertions(+), 29 deletions(-)

diff --git a/include/linux/netdevice.h b/include/linux/netdevice.h
index b0c928598dab..c5475b37a631 100644
--- a/include/linux/netdevice.h
+++ b/include/linux/netdevice.h
@@ -694,10 +694,9 @@ struct netdev_rx_queue {
  */
 struct rx_queue_attribute {
 	struct attribute attr;
-	ssize_t (*show)(struct netdev_rx_queue *queue,
-	    struct rx_queue_attribute *attr, char *buf);
+	ssize_t (*show)(struct netdev_rx_queue *queue, char *buf);
 	ssize_t (*store)(struct netdev_rx_queue *queue,
-	    struct rx_queue_attribute *attr, const char *buf, size_t len);
+			 const char *buf, size_t len);
 };
 
 #ifdef CONFIG_XPS
diff --git a/net/core/net-sysfs.c b/net/core/net-sysfs.c
index 76ec74d4a65b..48714c8024f3 100644
--- a/net/core/net-sysfs.c
+++ b/net/core/net-sysfs.c
@@ -661,7 +661,7 @@ static ssize_t rx_queue_attr_show(struct kobject *kobj, struct attribute *attr,
 	if (!attribute->show)
 		return -EIO;
 
-	return attribute->show(queue, attribute, buf);
+	return attribute->show(queue, buf);
 }
 
 static ssize_t rx_queue_attr_store(struct kobject *kobj, struct attribute *attr,
@@ -673,7 +673,7 @@ static ssize_t rx_queue_attr_store(struct kobject *kobj, struct attribute *attr,
 	if (!attribute->store)
 		return -EIO;
 
-	return attribute->store(queue, attribute, buf, count);
+	return attribute->store(queue, buf, count);
 }
 
 static const struct sysfs_ops rx_queue_sysfs_ops = {
@@ -682,8 +682,7 @@ static const struct sysfs_ops rx_queue_sysfs_ops = {
 };
 
 #ifdef CONFIG_RPS
-static ssize_t show_rps_map(struct netdev_rx_queue *queue,
-			    struct rx_queue_attribute *attribute, char *buf)
+static ssize_t show_rps_map(struct netdev_rx_queue *queue, char *buf)
 {
 	struct rps_map *map;
 	cpumask_var_t mask;
@@ -706,8 +705,7 @@ static ssize_t show_rps_map(struct netdev_rx_queue *queue,
 }
 
 static ssize_t store_rps_map(struct netdev_rx_queue *queue,
-		      struct rx_queue_attribute *attribute,
-		      const char *buf, size_t len)
+			     const char *buf, size_t len)
 {
 	struct rps_map *old_map, *map;
 	cpumask_var_t mask;
@@ -765,7 +763,6 @@ static ssize_t store_rps_map(struct netdev_rx_queue *queue,
 }
 
 static ssize_t show_rps_dev_flow_table_cnt(struct netdev_rx_queue *queue,
-					   struct rx_queue_attribute *attr,
 					   char *buf)
 {
 	struct rps_dev_flow_table *flow_table;
@@ -788,8 +785,7 @@ static void rps_dev_flow_table_release(struct rcu_head *rcu)
 }
 
 static ssize_t store_rps_dev_flow_table_cnt(struct netdev_rx_queue *queue,
-				     struct rx_queue_attribute *attr,
-				     const char *buf, size_t len)
+					    const char *buf, size_t len)
 {
 	unsigned long mask, count;
 	struct rps_dev_flow_table *table, *old_table;
@@ -975,10 +971,9 @@ net_rx_queue_update_kobjects(struct net_device *dev, int old_num, int new_num)
  */
 struct netdev_queue_attribute {
 	struct attribute attr;
-	ssize_t (*show)(struct netdev_queue *queue,
-	    struct netdev_queue_attribute *attr, char *buf);
+	ssize_t (*show)(struct netdev_queue *queue, char *buf);
 	ssize_t (*store)(struct netdev_queue *queue,
-	    struct netdev_queue_attribute *attr, const char *buf, size_t len);
+			 const char *buf, size_t len);
 };
 #define to_netdev_queue_attr(_attr) container_of(_attr,		\
     struct netdev_queue_attribute, attr)
@@ -994,7 +989,7 @@ static ssize_t netdev_queue_attr_show(struct kobject *kobj,
 	if (!attribute->show)
 		return -EIO;
 
-	return attribute->show(queue, attribute, buf);
+	return attribute->show(queue, buf);
 }
 
 static ssize_t netdev_queue_attr_store(struct kobject *kobj,
@@ -1007,7 +1002,7 @@ static ssize_t netdev_queue_attr_store(struct kobject *kobj,
 	if (!attribute->store)
 		return -EIO;
 
-	return attribute->store(queue, attribute, buf, count);
+	return attribute->store(queue, buf, count);
 }
 
 static const struct sysfs_ops netdev_queue_sysfs_ops = {
@@ -1016,7 +1011,6 @@ static const struct sysfs_ops netdev_queue_sysfs_ops = {
 };
 
 static ssize_t show_trans_timeout(struct netdev_queue *queue,
-				  struct netdev_queue_attribute *attribute,
 				  char *buf)
 {
 	unsigned long trans_timeout;
@@ -1040,7 +1034,6 @@ static unsigned int get_netdev_queue_index(struct netdev_queue *queue)
 }
 
 static ssize_t show_traffic_class(struct netdev_queue *queue,
-				  struct netdev_queue_attribute *attribute,
 				  char *buf)
 {
 	struct net_device *dev = queue->dev;
@@ -1055,14 +1048,12 @@ static ssize_t show_traffic_class(struct netdev_queue *queue,
 
 #ifdef CONFIG_XPS
 static ssize_t show_tx_maxrate(struct netdev_queue *queue,
-			       struct netdev_queue_attribute *attribute,
 			       char *buf)
 {
 	return sprintf(buf, "%lu\n", queue->tx_maxrate);
 }
 
 static ssize_t set_tx_maxrate(struct netdev_queue *queue,
-			      struct netdev_queue_attribute *attribute,
 			      const char *buf, size_t len)
 {
 	struct net_device *dev = queue->dev;
@@ -1130,7 +1121,6 @@ static ssize_t bql_set(const char *buf, const size_t count,
 }
 
 static ssize_t bql_show_hold_time(struct netdev_queue *queue,
-				  struct netdev_queue_attribute *attr,
 				  char *buf)
 {
 	struct dql *dql = &queue->dql;
@@ -1139,7 +1129,6 @@ static ssize_t bql_show_hold_time(struct netdev_queue *queue,
 }
 
 static ssize_t bql_set_hold_time(struct netdev_queue *queue,
-				 struct netdev_queue_attribute *attribute,
 				 const char *buf, size_t len)
 {
 	struct dql *dql = &queue->dql;
@@ -1160,7 +1149,6 @@ static struct netdev_queue_attribute bql_hold_time_attribute =
 	    bql_set_hold_time);
 
 static ssize_t bql_show_inflight(struct netdev_queue *queue,
-				 struct netdev_queue_attribute *attr,
 				 char *buf)
 {
 	struct dql *dql = &queue->dql;
@@ -1173,14 +1161,12 @@ static struct netdev_queue_attribute bql_inflight_attribute =
 
 #define BQL_ATTR(NAME, FIELD)						\
 static ssize_t bql_show_ ## NAME(struct netdev_queue *queue,		\
-				 struct netdev_queue_attribute *attr,	\
 				 char *buf)				\
 {									\
 	return bql_show(buf, queue->dql.FIELD);				\
 }									\
 									\
 static ssize_t bql_set_ ## NAME(struct netdev_queue *queue,		\
-				struct netdev_queue_attribute *attr,	\
 				const char *buf, size_t len)		\
 {									\
 	return bql_set(buf, len, &queue->dql.FIELD);			\
@@ -1211,7 +1197,7 @@ static const struct attribute_group dql_group = {
 
 #ifdef CONFIG_XPS
 static ssize_t show_xps_map(struct netdev_queue *queue,
-			    struct netdev_queue_attribute *attribute, char *buf)
+			    char *buf)
 {
 	struct net_device *dev = queue->dev;
 	int cpu, len, num_tc = 1, tc = 0;
@@ -1258,8 +1244,7 @@ static ssize_t show_xps_map(struct netdev_queue *queue,
 }
 
 static ssize_t store_xps_map(struct netdev_queue *queue,
-		      struct netdev_queue_attribute *attribute,
-		      const char *buf, size_t len)
+			     const char *buf, size_t len)
 {
 	struct net_device *dev = queue->dev;
 	unsigned long index;
-- 
2.11.0
