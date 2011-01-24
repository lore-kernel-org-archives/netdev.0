From: Vlad Dogaru <ddvlad@rosedu.org>
Subject: [PATCH] net: add sysfs entry for device group
Date: Mon, 24 Jan 2011 15:37:29 +0200
Message-ID: <1295876249-15634-1-git-send-email-ddvlad@rosedu.org>
Cc: Vlad Dogaru <ddvlad@rosedu.org>,
	Stephen Hemminger <shemminger@vyatta.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from [141.85.37.41] ([141.85.37.41]:50270 "EHLO swarm.cs.pub.ro"
	rhost-flags-FAIL-FAIL-OK-OK) by vger.kernel.org with ESMTP
	id S1752022Ab1AXNhl (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 24 Jan 2011 08:37:41 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The group of a network device can be queried or changed from userspace
using sysfs.

For example, considering sysfs mounted in /sys, one can change the group
that interface lo belongs to:
	echo 1 > /sys/class/net/lo/group

Signed-off-by: Vlad Dogaru <ddvlad@rosedu.org>
---
 net/core/net-sysfs.c |   15 +++++++++++++++
 1 files changed, 15 insertions(+), 0 deletions(-)

diff --git a/net/core/net-sysfs.c b/net/core/net-sysfs.c
index e23c01b..b726131 100644
--- a/net/core/net-sysfs.c
+++ b/net/core/net-sysfs.c
@@ -295,6 +295,20 @@ static ssize_t show_ifalias(struct device *dev,
 	return ret;
 }
 
+NETDEVICE_SHOW(group, fmt_dec);
+
+static int change_group(struct net_device *net, unsigned long new_group)
+{
+	dev_set_group(net, (int) new_group);
+	return 0;
+}
+
+static ssize_t store_group(struct device *dev, struct device_attribute *attr,
+			 const char *buf, size_t len)
+{
+	return netdev_store(dev, attr, buf, len, change_group);
+}
+
 static struct device_attribute net_class_attributes[] = {
 	__ATTR(addr_assign_type, S_IRUGO, show_addr_assign_type, NULL),
 	__ATTR(addr_len, S_IRUGO, show_addr_len, NULL),
@@ -316,6 +330,7 @@ static struct device_attribute net_class_attributes[] = {
 	__ATTR(flags, S_IRUGO | S_IWUSR, show_flags, store_flags),
 	__ATTR(tx_queue_len, S_IRUGO | S_IWUSR, show_tx_queue_len,
 	       store_tx_queue_len),
+	__ATTR(group, S_IRUGO | S_IWUSR, show_group, store_group),
 	{}
 };
 
-- 
1.7.1

