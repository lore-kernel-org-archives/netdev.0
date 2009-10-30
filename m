From: "Eric W. Biederman" <ebiederm@xmission.com>
Subject: [PATCH 1/6] net: Allow devices to specify a device specific sysfs group.
Date: Thu, 29 Oct 2009 17:18:21 -0700
Message-ID: <1256861906-5059-1-git-send-email-ebiederm@xmission.com>
References: <m1tyxhwxah.fsf@fess.ebiederm.org>
Cc: <netdev@vger.kernel.org>, Jay Vosburgh <fubar@us.ibm.com>,
	"Eric W. Biederman" <ebiederm@aristanetworks.com>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from out02.mta.xmission.com ([166.70.13.232]:35823 "EHLO
	out02.mta.xmission.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755122AbZJ3ASj (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 29 Oct 2009 20:18:39 -0400
In-Reply-To: <m1tyxhwxah.fsf@fess.ebiederm.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric W. Biederman <ebiederm@aristanetworks.com>

This isn't beautifully abstracted, but it is simple,
simplifies uses and so far is only needed for the bonding driver.

Signed-off-by: Eric W. Biederman <ebiederm@aristanetworks.com>
---
 include/linux/netdevice.h |    4 ++--
 net/core/net-sysfs.c      |    5 ++++-
 2 files changed, 6 insertions(+), 3 deletions(-)

diff --git a/include/linux/netdevice.h b/include/linux/netdevice.h
index ffc3106..b37f01e 100644
--- a/include/linux/netdevice.h
+++ b/include/linux/netdevice.h
@@ -899,8 +899,8 @@ struct net_device
 
 	/* class/net/name entry */
 	struct device		dev;
-	/* space for optional statistics and wireless sysfs groups */
-	const struct attribute_group *sysfs_groups[3];
+	/* space for optional device, statistics, and wireless sysfs groups */
+	const struct attribute_group *sysfs_groups[4];
 
 	/* rtnetlink link ops */
 	const struct rtnl_link_ops *rtnl_link_ops;
diff --git a/net/core/net-sysfs.c b/net/core/net-sysfs.c
index 89de182..157645c 100644
--- a/net/core/net-sysfs.c
+++ b/net/core/net-sysfs.c
@@ -544,8 +544,11 @@ int netdev_register_kobject(struct net_device *net)
 	dev_set_name(dev, "%s", net->name);
 
 #ifdef CONFIG_SYSFS
-	*groups++ = &netstat_group;
+	/* Allow for a device specific group */
+	if (*groups)
+		groups++;
 
+	*groups++ = &netstat_group;
 #ifdef CONFIG_WIRELESS_EXT_SYSFS
 	if (net->ieee80211_ptr)
 		*groups++ = &wireless_group;
-- 
1.6.3.1.54.g99dd.dirty

