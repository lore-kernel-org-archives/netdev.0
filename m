From: Laszlo Attila Toth <panther@balabit.hu>
Subject: [PATCHv8 2/2] Ifgroup read/write support in sysfs
Date: Thu,  6 Mar 2008 15:03:59 +0100
Message-ID: <12048122391192-git-send-email-panther@balabit.hu>
References: <12048121721361-git-send-email-panther@balabit.hu>
Cc: netdev@vger.kernel.org, Laszlo Attila Toth <panther@balabit.hu>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from www.balabit.hu ([212.92.18.33]:49497 "EHLO lists.balabit.hu"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S934435AbYCFOEE (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 6 Mar 2008 09:04:04 -0500
Received: from balabit.hu (unknown [10.80.0.254])
	by lists.balabit.hu (Postfix) with ESMTP id B7EB5C1318
	for <netdev@vger.kernel.org>; Thu,  6 Mar 2008 15:04:01 +0100 (CET)
In-Reply-To: <12048121721361-git-send-email-panther@balabit.hu>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The ifgroup member of each net device can be read and changed in sysfs.

Author: Lutz Jaenicke <ljaenicke@innominate.com>

Signed-off-by: Laszlo Attila Toth <panther@balabit.hu>
---
 net/core/net-sysfs.c |   15 +++++++++++++++
 1 files changed, 15 insertions(+), 0 deletions(-)

diff --git a/net/core/net-sysfs.c b/net/core/net-sysfs.c
index 7635d3f..6652974 100644
--- a/net/core/net-sysfs.c
+++ b/net/core/net-sysfs.c
@@ -208,6 +208,20 @@ static ssize_t store_tx_queue_len(struct device *dev,
 	return netdev_store(dev, attr, buf, len, change_tx_queue_len);
 }
 
+NETDEVICE_SHOW(ifgroup, fmt_hex);
+
+static int change_ifgroup(struct net_device *net, unsigned long new_ifgroup)
+{
+	net->ifgroup = new_ifgroup;
+	return 0;
+}
+
+static ssize_t store_ifgroup(struct device *dev, struct device_attribute *attr,
+			   const char *buf, size_t len)
+{
+	return netdev_store(dev, attr, buf, len, change_ifgroup);
+}
+
 static struct device_attribute net_class_attributes[] = {
 	__ATTR(addr_len, S_IRUGO, show_addr_len, NULL),
 	__ATTR(iflink, S_IRUGO, show_iflink, NULL),
@@ -224,6 +238,7 @@ static struct device_attribute net_class_attributes[] = {
 	__ATTR(flags, S_IRUGO | S_IWUSR, show_flags, store_flags),
 	__ATTR(tx_queue_len, S_IRUGO | S_IWUSR, show_tx_queue_len,
 	       store_tx_queue_len),
+	__ATTR(ifgroup, S_IRUGO | S_IWUSR, show_ifgroup, store_ifgroup),
 	{}
 };
 
-- 
1.5.2.5

