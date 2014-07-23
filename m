From: Cong Wang <xiyou.wangcong@gmail.com>
Subject: [Patch net-next] net: do not name the pointer to struct net_device net
Date: Wed, 23 Jul 2014 16:09:10 -0700
Message-ID: <1406156950-8934-1-git-send-email-xiyou.wangcong@gmail.com>
Cc: "David S. Miller" <davem@davemloft.net>,
	Cong Wang <xiyou.wangcong@gmail.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f47.google.com ([209.85.220.47]:34787 "EHLO
	mail-pa0-f47.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1758092AbaGWXJW (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 23 Jul 2014 19:09:22 -0400
Received: by mail-pa0-f47.google.com with SMTP id kx10so2613883pab.6
        for <netdev@vger.kernel.org>; Wed, 23 Jul 2014 16:09:22 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

"net" is normally for struct net*, pointer to struct net_device
should be named to either "dev" or "ndev" etc.

Cc: "David S. Miller" <davem@davemloft.net>
Signed-off-by: Cong Wang <xiyou.wangcong@gmail.com>

---
 net/core/net-sysfs.c | 142 +++++++++++++++++++++++++--------------------------
 1 file changed, 71 insertions(+), 71 deletions(-)

diff --git a/net/core/net-sysfs.c b/net/core/net-sysfs.c
index 7752f2a..9dd0669 100644
--- a/net/core/net-sysfs.c
+++ b/net/core/net-sysfs.c
@@ -43,12 +43,12 @@ static ssize_t netdev_show(const struct device *dev,
 			   struct device_attribute *attr, char *buf,
 			   ssize_t (*format)(const struct net_device *, char *))
 {
-	struct net_device *net = to_net_dev(dev);
+	struct net_device *ndev = to_net_dev(dev);
 	ssize_t ret = -EINVAL;
 
 	read_lock(&dev_base_lock);
-	if (dev_isalive(net))
-		ret = (*format)(net, buf);
+	if (dev_isalive(ndev))
+		ret = (*format)(ndev, buf);
 	read_unlock(&dev_base_lock);
 
 	return ret;
@@ -56,9 +56,9 @@ static ssize_t netdev_show(const struct device *dev,
 
 /* generate a show function for simple field */
 #define NETDEVICE_SHOW(field, format_string)				\
-static ssize_t format_##field(const struct net_device *net, char *buf)	\
+static ssize_t format_##field(const struct net_device *dev, char *buf)	\
 {									\
-	return sprintf(buf, format_string, net->field);			\
+	return sprintf(buf, format_string, dev->field);			\
 }									\
 static ssize_t field##_show(struct device *dev,				\
 			    struct device_attribute *attr, char *buf)	\
@@ -112,19 +112,19 @@ NETDEVICE_SHOW_RO(ifindex, fmt_dec);
 NETDEVICE_SHOW_RO(type, fmt_dec);
 NETDEVICE_SHOW_RO(link_mode, fmt_dec);
 
-static ssize_t format_name_assign_type(const struct net_device *net, char *buf)
+static ssize_t format_name_assign_type(const struct net_device *dev, char *buf)
 {
-	return sprintf(buf, fmt_dec, net->name_assign_type);
+	return sprintf(buf, fmt_dec, dev->name_assign_type);
 }
 
 static ssize_t name_assign_type_show(struct device *dev,
 				     struct device_attribute *attr,
 				     char *buf)
 {
-	struct net_device *net = to_net_dev(dev);
+	struct net_device *ndev = to_net_dev(dev);
 	ssize_t ret = -EINVAL;
 
-	if (net->name_assign_type != NET_NAME_UNKNOWN)
+	if (ndev->name_assign_type != NET_NAME_UNKNOWN)
 		ret = netdev_show(dev, attr, buf, format_name_assign_type);
 
 	return ret;
@@ -135,12 +135,12 @@ static DEVICE_ATTR_RO(name_assign_type);
 static ssize_t address_show(struct device *dev, struct device_attribute *attr,
 			    char *buf)
 {
-	struct net_device *net = to_net_dev(dev);
+	struct net_device *ndev = to_net_dev(dev);
 	ssize_t ret = -EINVAL;
 
 	read_lock(&dev_base_lock);
-	if (dev_isalive(net))
-		ret = sysfs_format_mac(buf, net->dev_addr, net->addr_len);
+	if (dev_isalive(ndev))
+		ret = sysfs_format_mac(buf, ndev->dev_addr, ndev->addr_len);
 	read_unlock(&dev_base_lock);
 	return ret;
 }
@@ -149,18 +149,18 @@ static DEVICE_ATTR_RO(address);
 static ssize_t broadcast_show(struct device *dev,
 			      struct device_attribute *attr, char *buf)
 {
-	struct net_device *net = to_net_dev(dev);
-	if (dev_isalive(net))
-		return sysfs_format_mac(buf, net->broadcast, net->addr_len);
+	struct net_device *ndev = to_net_dev(dev);
+	if (dev_isalive(ndev))
+		return sysfs_format_mac(buf, ndev->broadcast, ndev->addr_len);
 	return -EINVAL;
 }
 static DEVICE_ATTR_RO(broadcast);
 
-static int change_carrier(struct net_device *net, unsigned long new_carrier)
+static int change_carrier(struct net_device *dev, unsigned long new_carrier)
 {
-	if (!netif_running(net))
+	if (!netif_running(dev))
 		return -EINVAL;
-	return dev_change_carrier(net, (bool) new_carrier);
+	return dev_change_carrier(dev, (bool) new_carrier);
 }
 
 static ssize_t carrier_store(struct device *dev, struct device_attribute *attr,
@@ -284,9 +284,9 @@ static DEVICE_ATTR_RO(carrier_changes);
 
 /* read-write attributes */
 
-static int change_mtu(struct net_device *net, unsigned long new_mtu)
+static int change_mtu(struct net_device *dev, unsigned long new_mtu)
 {
-	return dev_set_mtu(net, (int) new_mtu);
+	return dev_set_mtu(dev, (int) new_mtu);
 }
 
 static ssize_t mtu_store(struct device *dev, struct device_attribute *attr,
@@ -296,9 +296,9 @@ static ssize_t mtu_store(struct device *dev, struct device_attribute *attr,
 }
 NETDEVICE_SHOW_RW(mtu, fmt_dec);
 
-static int change_flags(struct net_device *net, unsigned long new_flags)
+static int change_flags(struct net_device *dev, unsigned long new_flags)
 {
-	return dev_change_flags(net, (unsigned int) new_flags);
+	return dev_change_flags(dev, (unsigned int) new_flags);
 }
 
 static ssize_t flags_store(struct device *dev, struct device_attribute *attr,
@@ -308,9 +308,9 @@ static ssize_t flags_store(struct device *dev, struct device_attribute *attr,
 }
 NETDEVICE_SHOW_RW(flags, fmt_hex);
 
-static int change_tx_queue_len(struct net_device *net, unsigned long new_len)
+static int change_tx_queue_len(struct net_device *dev, unsigned long new_len)
 {
-	net->tx_queue_len = new_len;
+	dev->tx_queue_len = new_len;
 	return 0;
 }
 
@@ -363,9 +363,9 @@ static ssize_t ifalias_show(struct device *dev,
 }
 static DEVICE_ATTR_RW(ifalias);
 
-static int change_group(struct net_device *net, unsigned long new_group)
+static int change_group(struct net_device *dev, unsigned long new_group)
 {
-	dev_set_group(net, (int) new_group);
+	dev_set_group(dev, (int) new_group);
 	return 0;
 }
 
@@ -796,20 +796,20 @@ static struct kobj_type rx_queue_ktype = {
 	.namespace = rx_queue_namespace
 };
 
-static int rx_queue_add_kobject(struct net_device *net, int index)
+static int rx_queue_add_kobject(struct net_device *dev, int index)
 {
-	struct netdev_rx_queue *queue = net->_rx + index;
+	struct netdev_rx_queue *queue = dev->_rx + index;
 	struct kobject *kobj = &queue->kobj;
 	int error = 0;
 
-	kobj->kset = net->queues_kset;
+	kobj->kset = dev->queues_kset;
 	error = kobject_init_and_add(kobj, &rx_queue_ktype, NULL,
 	    "rx-%u", index);
 	if (error)
 		goto exit;
 
-	if (net->sysfs_rx_queue_group) {
-		error = sysfs_create_group(kobj, net->sysfs_rx_queue_group);
+	if (dev->sysfs_rx_queue_group) {
+		error = sysfs_create_group(kobj, dev->sysfs_rx_queue_group);
 		if (error)
 			goto exit;
 	}
@@ -825,18 +825,18 @@ exit:
 #endif /* CONFIG_SYSFS */
 
 int
-net_rx_queue_update_kobjects(struct net_device *net, int old_num, int new_num)
+net_rx_queue_update_kobjects(struct net_device *dev, int old_num, int new_num)
 {
 #ifdef CONFIG_SYSFS
 	int i;
 	int error = 0;
 
 #ifndef CONFIG_RPS
-	if (!net->sysfs_rx_queue_group)
+	if (!dev->sysfs_rx_queue_group)
 		return 0;
 #endif
 	for (i = old_num; i < new_num; i++) {
-		error = rx_queue_add_kobject(net, i);
+		error = rx_queue_add_kobject(dev, i);
 		if (error) {
 			new_num = old_num;
 			break;
@@ -844,10 +844,10 @@ net_rx_queue_update_kobjects(struct net_device *net, int old_num, int new_num)
 	}
 
 	while (--i >= new_num) {
-		if (net->sysfs_rx_queue_group)
-			sysfs_remove_group(&net->_rx[i].kobj,
-					   net->sysfs_rx_queue_group);
-		kobject_put(&net->_rx[i].kobj);
+		if (dev->sysfs_rx_queue_group)
+			sysfs_remove_group(&dev->_rx[i].kobj,
+					   dev->sysfs_rx_queue_group);
+		kobject_put(&dev->_rx[i].kobj);
 	}
 
 	return error;
@@ -1155,13 +1155,13 @@ static struct kobj_type netdev_queue_ktype = {
 	.namespace = netdev_queue_namespace,
 };
 
-static int netdev_queue_add_kobject(struct net_device *net, int index)
+static int netdev_queue_add_kobject(struct net_device *dev, int index)
 {
-	struct netdev_queue *queue = net->_tx + index;
+	struct netdev_queue *queue = dev->_tx + index;
 	struct kobject *kobj = &queue->kobj;
 	int error = 0;
 
-	kobj->kset = net->queues_kset;
+	kobj->kset = dev->queues_kset;
 	error = kobject_init_and_add(kobj, &netdev_queue_ktype, NULL,
 	    "tx-%u", index);
 	if (error)
@@ -1184,14 +1184,14 @@ exit:
 #endif /* CONFIG_SYSFS */
 
 int
-netdev_queue_update_kobjects(struct net_device *net, int old_num, int new_num)
+netdev_queue_update_kobjects(struct net_device *dev, int old_num, int new_num)
 {
 #ifdef CONFIG_SYSFS
 	int i;
 	int error = 0;
 
 	for (i = old_num; i < new_num; i++) {
-		error = netdev_queue_add_kobject(net, i);
+		error = netdev_queue_add_kobject(dev, i);
 		if (error) {
 			new_num = old_num;
 			break;
@@ -1199,7 +1199,7 @@ netdev_queue_update_kobjects(struct net_device *net, int old_num, int new_num)
 	}
 
 	while (--i >= new_num) {
-		struct netdev_queue *queue = net->_tx + i;
+		struct netdev_queue *queue = dev->_tx + i;
 
 #ifdef CONFIG_BQL
 		sysfs_remove_group(&queue->kobj, &dql_group);
@@ -1213,25 +1213,25 @@ netdev_queue_update_kobjects(struct net_device *net, int old_num, int new_num)
 #endif /* CONFIG_SYSFS */
 }
 
-static int register_queue_kobjects(struct net_device *net)
+static int register_queue_kobjects(struct net_device *dev)
 {
 	int error = 0, txq = 0, rxq = 0, real_rx = 0, real_tx = 0;
 
 #ifdef CONFIG_SYSFS
-	net->queues_kset = kset_create_and_add("queues",
-	    NULL, &net->dev.kobj);
-	if (!net->queues_kset)
+	dev->queues_kset = kset_create_and_add("queues",
+	    NULL, &dev->dev.kobj);
+	if (!dev->queues_kset)
 		return -ENOMEM;
-	real_rx = net->real_num_rx_queues;
+	real_rx = dev->real_num_rx_queues;
 #endif
-	real_tx = net->real_num_tx_queues;
+	real_tx = dev->real_num_tx_queues;
 
-	error = net_rx_queue_update_kobjects(net, 0, real_rx);
+	error = net_rx_queue_update_kobjects(dev, 0, real_rx);
 	if (error)
 		goto error;
 	rxq = real_rx;
 
-	error = netdev_queue_update_kobjects(net, 0, real_tx);
+	error = netdev_queue_update_kobjects(dev, 0, real_tx);
 	if (error)
 		goto error;
 	txq = real_tx;
@@ -1239,24 +1239,24 @@ static int register_queue_kobjects(struct net_device *net)
 	return 0;
 
 error:
-	netdev_queue_update_kobjects(net, txq, 0);
-	net_rx_queue_update_kobjects(net, rxq, 0);
+	netdev_queue_update_kobjects(dev, txq, 0);
+	net_rx_queue_update_kobjects(dev, rxq, 0);
 	return error;
 }
 
-static void remove_queue_kobjects(struct net_device *net)
+static void remove_queue_kobjects(struct net_device *dev)
 {
 	int real_rx = 0, real_tx = 0;
 
 #ifdef CONFIG_SYSFS
-	real_rx = net->real_num_rx_queues;
+	real_rx = dev->real_num_rx_queues;
 #endif
-	real_tx = net->real_num_tx_queues;
+	real_tx = dev->real_num_tx_queues;
 
-	net_rx_queue_update_kobjects(net, real_rx, 0);
-	netdev_queue_update_kobjects(net, real_tx, 0);
+	net_rx_queue_update_kobjects(dev, real_rx, 0);
+	netdev_queue_update_kobjects(dev, real_tx, 0);
 #ifdef CONFIG_SYSFS
-	kset_unregister(net->queues_kset);
+	kset_unregister(dev->queues_kset);
 #endif
 }
 
@@ -1349,13 +1349,13 @@ static struct class net_class = {
 /* Delete sysfs entries but hold kobject reference until after all
  * netdev references are gone.
  */
-void netdev_unregister_kobject(struct net_device * net)
+void netdev_unregister_kobject(struct net_device *ndev)
 {
-	struct device *dev = &(net->dev);
+	struct device *dev = &(ndev->dev);
 
 	kobject_get(&dev->kobj);
 
-	remove_queue_kobjects(net);
+	remove_queue_kobjects(ndev);
 
 	pm_runtime_set_memalloc_noio(dev, false);
 
@@ -1363,18 +1363,18 @@ void netdev_unregister_kobject(struct net_device * net)
 }
 
 /* Create sysfs entries for network device. */
-int netdev_register_kobject(struct net_device *net)
+int netdev_register_kobject(struct net_device *ndev)
 {
-	struct device *dev = &(net->dev);
-	const struct attribute_group **groups = net->sysfs_groups;
+	struct device *dev = &(ndev->dev);
+	const struct attribute_group **groups = ndev->sysfs_groups;
 	int error = 0;
 
 	device_initialize(dev);
 	dev->class = &net_class;
-	dev->platform_data = net;
+	dev->platform_data = ndev;
 	dev->groups = groups;
 
-	dev_set_name(dev, "%s", net->name);
+	dev_set_name(dev, "%s", ndev->name);
 
 #ifdef CONFIG_SYSFS
 	/* Allow for a device specific group */
@@ -1384,10 +1384,10 @@ int netdev_register_kobject(struct net_device *net)
 	*groups++ = &netstat_group;
 
 #if IS_ENABLED(CONFIG_WIRELESS_EXT) || IS_ENABLED(CONFIG_CFG80211)
-	if (net->ieee80211_ptr)
+	if (ndev->ieee80211_ptr)
 		*groups++ = &wireless_group;
 #if IS_ENABLED(CONFIG_WIRELESS_EXT)
-	else if (net->wireless_handlers)
+	else if (ndev->wireless_handlers)
 		*groups++ = &wireless_group;
 #endif
 #endif
@@ -1397,7 +1397,7 @@ int netdev_register_kobject(struct net_device *net)
 	if (error)
 		return error;
 
-	error = register_queue_kobjects(net);
+	error = register_queue_kobjects(ndev);
 	if (error) {
 		device_del(dev);
 		return error;
