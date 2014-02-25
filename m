From: Amir Vadai <amirv@mellanox.com>
Subject: [PATCH net-next 1/3] net: Add sysfs file for port number
Date: Tue, 25 Feb 2014 18:17:50 +0200
Message-ID: <1393345072-31584-2-git-send-email-amirv@mellanox.com>
References: <1393345072-31584-1-git-send-email-amirv@mellanox.com>
Cc: Or Gerlitz <ogerlitz@mellanox.com>,
	Yevgeny Petrilin <yevgenyp@mellanox.com>,
	Amir Vadai <amirv@mellanox.com>, netdev@vger.kernel.org
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mailp.voltaire.com ([193.47.165.129]:43241 "EHLO mellanox.co.il"
	rhost-flags-OK-FAIL-OK-FAIL) by vger.kernel.org with ESMTP
	id S1752129AbaBYQSn (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 25 Feb 2014 11:18:43 -0500
In-Reply-To: <1393345072-31584-1-git-send-email-amirv@mellanox.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Add a sysfs file to enable user space to query the device
port number used by a netdevice instance. This is needed for
devices that have multiple ports on the same PCI function.

Signed-off-by: Amir Vadai <amirv@mellanox.com>
---
 include/linux/netdevice.h | 4 ++++
 net/core/net-sysfs.c      | 2 ++
 2 files changed, 6 insertions(+)

diff --git a/include/linux/netdevice.h b/include/linux/netdevice.h
index 5e47565..5e84483 100644
--- a/include/linux/netdevice.h
+++ b/include/linux/netdevice.h
@@ -1279,6 +1279,10 @@ struct net_device {
 						 * that share the same link
 						 * layer address
 						 */
+	unsigned short          dev_port;	/* Used to differentiate
+						 * devices that share the same
+						 * function
+						 */
 	spinlock_t		addr_list_lock;
 	struct netdev_hw_addr_list	uc;	/* Unicast mac addresses */
 	struct netdev_hw_addr_list	mc;	/* Multicast mac addresses */
diff --git a/net/core/net-sysfs.c b/net/core/net-sysfs.c
index 73aa594..daed9a6 100644
--- a/net/core/net-sysfs.c
+++ b/net/core/net-sysfs.c
@@ -104,6 +104,7 @@ static ssize_t netdev_store(struct device *dev, struct device_attribute *attr,
 }
 
 NETDEVICE_SHOW_RO(dev_id, fmt_hex);
+NETDEVICE_SHOW_RO(dev_port, fmt_dec);
 NETDEVICE_SHOW_RO(addr_assign_type, fmt_dec);
 NETDEVICE_SHOW_RO(addr_len, fmt_dec);
 NETDEVICE_SHOW_RO(iflink, fmt_dec);
@@ -373,6 +374,7 @@ static struct attribute *net_class_attrs[] = {
 	&dev_attr_netdev_group.attr,
 	&dev_attr_type.attr,
 	&dev_attr_dev_id.attr,
+	&dev_attr_dev_port.attr,
 	&dev_attr_iflink.attr,
 	&dev_attr_ifindex.attr,
 	&dev_attr_addr_assign_type.attr,
-- 
1.8.3.4
