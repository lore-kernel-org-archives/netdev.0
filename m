From: Stephen Hemminger <stephen@networkplumber.org>
Subject: [PATCH net-next 10/10] net: style cleanups
Date: Fri, 18 Aug 2017 13:46:28 -0700
Message-ID: <20170818204628.17147-11-sthemmin@microsoft.com>
References: <20170818204628.17147-1-sthemmin@microsoft.com>
Cc: netdev@vger.kernel.org, Stephen Hemminger <sthemmin@microsoft.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pg0-f54.google.com ([74.125.83.54]:33818 "EHLO
        mail-pg0-f54.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752255AbdHRUqs (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 18 Aug 2017 16:46:48 -0400
Received: by mail-pg0-f54.google.com with SMTP id n4so7421568pgn.1
        for <netdev@vger.kernel.org>; Fri, 18 Aug 2017 13:46:48 -0700 (PDT)
In-Reply-To: <20170818204628.17147-1-sthemmin@microsoft.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Make code closer to current style. Mostly whitespace changes.

Signed-off-by: Stephen Hemminger <sthemmin@microsoft.com>
---
 net/core/net-sysfs.c | 68 +++++++++++++++++++++++++++-------------------------
 1 file changed, 36 insertions(+), 32 deletions(-)

diff --git a/net/core/net-sysfs.c b/net/core/net-sysfs.c
index ca82c4a72350..927a6dcbad96 100644
--- a/net/core/net-sysfs.c
+++ b/net/core/net-sysfs.c
@@ -97,7 +97,8 @@ static ssize_t netdev_store(struct device *dev, struct device_attribute *attr,
 		return restart_syscall();
 
 	if (dev_isalive(netdev)) {
-		if ((ret = (*set)(netdev, new)) == 0)
+		ret = (*set)(netdev, new);
+		if (ret == 0)
 			ret = len;
 	}
 	rtnl_unlock();
@@ -160,6 +161,7 @@ static ssize_t broadcast_show(struct device *dev,
 			      struct device_attribute *attr, char *buf)
 {
 	struct net_device *ndev = to_net_dev(dev);
+
 	if (dev_isalive(ndev))
 		return sysfs_format_mac(buf, ndev->broadcast, ndev->addr_len);
 	return -EINVAL;
@@ -170,7 +172,7 @@ static int change_carrier(struct net_device *dev, unsigned long new_carrier)
 {
 	if (!netif_running(dev))
 		return -EINVAL;
-	return dev_change_carrier(dev, (bool) new_carrier);
+	return dev_change_carrier(dev, (bool)new_carrier);
 }
 
 static ssize_t carrier_store(struct device *dev, struct device_attribute *attr,
@@ -183,9 +185,10 @@ static ssize_t carrier_show(struct device *dev,
 			    struct device_attribute *attr, char *buf)
 {
 	struct net_device *netdev = to_net_dev(dev);
-	if (netif_running(netdev)) {
+
+	if (netif_running(netdev))
 		return sprintf(buf, fmt_dec, !!netif_carrier_ok(netdev));
-	}
+
 	return -EINVAL;
 }
 static DEVICE_ATTR_RW(carrier);
@@ -290,6 +293,7 @@ static ssize_t carrier_changes_show(struct device *dev,
 				    char *buf)
 {
 	struct net_device *netdev = to_net_dev(dev);
+
 	return sprintf(buf, fmt_dec,
 		       atomic_read(&netdev->carrier_changes));
 }
@@ -299,7 +303,7 @@ static DEVICE_ATTR_RO(carrier_changes);
 
 static int change_mtu(struct net_device *dev, unsigned long new_mtu)
 {
-	return dev_set_mtu(dev, (int) new_mtu);
+	return dev_set_mtu(dev, (int)new_mtu);
 }
 
 static ssize_t mtu_store(struct device *dev, struct device_attribute *attr,
@@ -311,7 +315,7 @@ NETDEVICE_SHOW_RW(mtu, fmt_dec);
 
 static int change_flags(struct net_device *dev, unsigned long new_flags)
 {
-	return dev_change_flags(dev, (unsigned int) new_flags);
+	return dev_change_flags(dev, (unsigned int)new_flags);
 }
 
 static ssize_t flags_store(struct device *dev, struct device_attribute *attr,
@@ -362,8 +366,8 @@ static int change_gro_flush_timeout(struct net_device *dev, unsigned long val)
 }
 
 static ssize_t gro_flush_timeout_store(struct device *dev,
-				  struct device_attribute *attr,
-				  const char *buf, size_t len)
+				       struct device_attribute *attr,
+				       const char *buf, size_t len)
 {
 	if (!capable(CAP_NET_ADMIN))
 		return -EPERM;
@@ -412,7 +416,7 @@ static DEVICE_ATTR_RW(ifalias);
 
 static int change_group(struct net_device *dev, unsigned long new_group)
 {
-	dev_set_group(dev, (int) new_group);
+	dev_set_group(dev, (int)new_group);
 	return 0;
 }
 
@@ -426,7 +430,7 @@ static DEVICE_ATTR(netdev_group, S_IRUGO | S_IWUSR, group_show, group_store);
 
 static int change_proto_down(struct net_device *dev, unsigned long proto_down)
 {
-	return dev_change_proto_down(dev, (bool) proto_down);
+	return dev_change_proto_down(dev, (bool)proto_down);
 }
 
 static ssize_t proto_down_store(struct device *dev,
@@ -549,14 +553,14 @@ static ssize_t netstat_show(const struct device *d,
 	ssize_t ret = -EINVAL;
 
 	WARN_ON(offset > sizeof(struct rtnl_link_stats64) ||
-			offset % sizeof(u64) != 0);
+		offset % sizeof(u64) != 0);
 
 	read_lock(&dev_base_lock);
 	if (dev_isalive(dev)) {
 		struct rtnl_link_stats64 temp;
 		const struct rtnl_link_stats64 *stats = dev_get_stats(dev, &temp);
 
-		ret = sprintf(buf, fmt_u64, *(u64 *)(((u8 *) stats) + offset));
+		ret = sprintf(buf, fmt_u64, *(u64 *)(((u8 *)stats) + offset));
 	}
 	read_unlock(&dev_base_lock);
 	return ret;
@@ -565,7 +569,7 @@ static ssize_t netstat_show(const struct device *d,
 /* generate a read-only statistics attribute */
 #define NETSTAT_ENTRY(name)						\
 static ssize_t name##_show(struct device *d,				\
-			   struct device_attribute *attr, char *buf) 	\
+			   struct device_attribute *attr, char *buf)	\
 {									\
 	return netstat_show(d, attr, buf,				\
 			    offsetof(struct rtnl_link_stats64, name));	\
@@ -625,7 +629,6 @@ static struct attribute *netstat_attrs[] __ro_after_init = {
 	NULL
 };
 
-
 static const struct attribute_group netstat_group = {
 	.name  = "statistics",
 	.attrs  = netstat_attrs,
@@ -647,8 +650,8 @@ static const struct attribute_group wireless_group = {
 #endif /* CONFIG_SYSFS */
 
 #ifdef CONFIG_SYSFS
-#define to_rx_queue_attr(_attr) container_of(_attr,		\
-    struct rx_queue_attribute, attr)
+#define to_rx_queue_attr(_attr) \
+	container_of(_attr, struct rx_queue_attribute, attr)
 
 #define to_rx_queue(obj) container_of(obj, struct netdev_rx_queue, kobj)
 
@@ -725,8 +728,8 @@ static ssize_t store_rps_map(struct netdev_rx_queue *queue,
 	}
 
 	map = kzalloc(max_t(unsigned int,
-	    RPS_MAP_SIZE(cpumask_weight(mask)), L1_CACHE_BYTES),
-	    GFP_KERNEL);
+			    RPS_MAP_SIZE(cpumask_weight(mask)), L1_CACHE_BYTES),
+		      GFP_KERNEL);
 	if (!map) {
 		free_cpumask_var(mask);
 		return -ENOMEM;
@@ -736,9 +739,9 @@ static ssize_t store_rps_map(struct netdev_rx_queue *queue,
 	for_each_cpu_and(cpu, mask, cpu_online_mask)
 		map->cpus[i++] = cpu;
 
-	if (i)
+	if (i) {
 		map->len = i;
-	else {
+	} else {
 		kfree(map);
 		map = NULL;
 	}
@@ -827,8 +830,9 @@ static ssize_t store_rps_dev_flow_table_cnt(struct netdev_rx_queue *queue,
 		table->mask = mask;
 		for (count = 0; count <= mask; count++)
 			table->flows[count].cpu = RPS_NO_CPU;
-	} else
+	} else {
 		table = NULL;
+	}
 
 	spin_lock(&rps_dev_flow_lock);
 	old_table = rcu_dereference_protected(queue->rps_flow_table,
@@ -865,7 +869,6 @@ static void rx_queue_release(struct kobject *kobj)
 	struct rps_map *map;
 	struct rps_dev_flow_table *flow_table;
 
-
 	map = rcu_dereference_protected(queue->rps_map, 1);
 	if (map) {
 		RCU_INIT_POINTER(queue->rps_map, NULL);
@@ -910,7 +913,7 @@ static int rx_queue_add_kobject(struct net_device *dev, int index)
 
 	kobj->kset = dev->queues_kset;
 	error = kobject_init_and_add(kobj, &rx_queue_ktype, NULL,
-	    "rx-%u", index);
+				     "rx-%u", index);
 	if (error)
 		return error;
 
@@ -974,8 +977,8 @@ struct netdev_queue_attribute {
 	ssize_t (*store)(struct netdev_queue *queue,
 			 const char *buf, size_t len);
 };
-#define to_netdev_queue_attr(_attr) container_of(_attr,		\
-    struct netdev_queue_attribute, attr)
+#define to_netdev_queue_attr(_attr) \
+	container_of(_attr, struct netdev_queue_attribute, attr)
 
 #define to_netdev_queue(obj) container_of(obj, struct netdev_queue, kobj)
 
@@ -1104,9 +1107,9 @@ static ssize_t bql_set(const char *buf, const size_t count,
 	unsigned int value;
 	int err;
 
-	if (!strcmp(buf, "max") || !strcmp(buf, "max\n"))
+	if (!strcmp(buf, "max") || !strcmp(buf, "max\n")) {
 		value = DQL_MAX_LIMIT;
-	else {
+	} else {
 		err = kstrtouint(buf, 10, &value);
 		if (err < 0)
 			return err;
@@ -1320,7 +1323,7 @@ static int netdev_queue_add_kobject(struct net_device *dev, int index)
 
 	kobj->kset = dev->queues_kset;
 	error = kobject_init_and_add(kobj, &netdev_queue_ktype, NULL,
-	    "tx-%u", index);
+				     "tx-%u", index);
 	if (error)
 		return error;
 
@@ -1377,7 +1380,7 @@ static int register_queue_kobjects(struct net_device *dev)
 
 #ifdef CONFIG_SYSFS
 	dev->queues_kset = kset_create_and_add("queues",
-	    NULL, &dev->dev.kobj);
+					       NULL, &dev->dev.kobj);
 	if (!dev->queues_kset)
 		return -ENOMEM;
 	real_rx = dev->real_num_rx_queues;
@@ -1467,7 +1470,8 @@ static int netdev_uevent(struct device *d, struct kobj_uevent_env *env)
 
 	/* pass ifindex to uevent.
 	 * ifindex is useful as it won't change (interface name may change)
-	 * and is what RtNetlink uses natively. */
+	 * and is what RtNetlink uses natively.
+	 */
 	retval = add_uevent_var(env, "IFINDEX=%d", dev->ifindex);
 
 exit:
@@ -1542,7 +1546,7 @@ EXPORT_SYMBOL(of_find_net_device_by_node);
  */
 void netdev_unregister_kobject(struct net_device *ndev)
 {
-	struct device *dev = &(ndev->dev);
+	struct device *dev = &ndev->dev;
 
 	if (!atomic_read(&dev_net(ndev)->count))
 		dev_set_uevent_suppress(dev, 1);
@@ -1559,7 +1563,7 @@ void netdev_unregister_kobject(struct net_device *ndev)
 /* Create sysfs entries for network device. */
 int netdev_register_kobject(struct net_device *ndev)
 {
-	struct device *dev = &(ndev->dev);
+	struct device *dev = &ndev->dev;
 	const struct attribute_group **groups = ndev->sysfs_groups;
 	int error = 0;
 
-- 
2.11.0
