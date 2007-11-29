From: Laszlo Attila Toth <panther@balabit.hu>
Subject: [PATCHv7 4/5] Ifgroup read/write support in sysfs
Date: Thu, 29 Nov 2007 17:11:45 +0100
Message-ID: <11963527103391-git-send-email-panther@balabit.hu>
References: <11963527094077-git-send-email-panther@balabit.hu>
 <11963527103201-git-send-email-panther@balabit.hu>
 <1196352710402-git-send-email-panther@balabit.hu>
 <11963527101876-git-send-email-panther@balabit.hu>
Cc: Patrick McHardy <kaber@trash.net>, netdev@vger.kernel.org,
	Laszlo Attila Toth <panther@balabit.hu>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from www.balabit.hu ([212.92.18.33]:38140 "EHLO lists.balabit.hu"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1757285AbXK2QL6 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 29 Nov 2007 11:11:58 -0500
Received: from balabit.hu (unknown [10.80.0.254])
	by lists.balabit.hu (Postfix) with ESMTP id 69573C14C4
	for <netdev@vger.kernel.org>; Thu, 29 Nov 2007 17:11:57 +0100 (CET)
In-Reply-To: <11963527101876-git-send-email-panther@balabit.hu>
In-Reply-To: <ifgroup-20071129-165736-1196351856-panther@balabit.hu>
References: <ifgroup-20071129-165736-1196351856-panther@balabit.hu>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

The ifgroup member of each net device can be read and changed in sysfs.

Author: Lutz Jaenicke <ljaenicke@innominate.com>
---

 net/core/net-sysfs.c |   15 +++++++++++++++
 1 files changed, 15 insertions(+), 0 deletions(-)

diff --git a/net/core/net-sysfs.c b/net/core/net-sysfs.c
index 61ead1d..5bd6d35 100644
--- a/net/core/net-sysfs.c
+++ b/net/core/net-sysfs.c
@@ -219,6 +219,20 @@ static ssize_t store_tx_queue_len(struct device *dev,
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
@@ -235,6 +249,7 @@ static struct device_attribute net_class_attributes[] = {
 	__ATTR(flags, S_IRUGO | S_IWUSR, show_flags, store_flags),
 	__ATTR(tx_queue_len, S_IRUGO | S_IWUSR, show_tx_queue_len,
 	       store_tx_queue_len),
+	__ATTR(ifgroup, S_IRUGO | S_IWUSR, show_ifgroup, store_ifgroup),
 	{}
 };
 
