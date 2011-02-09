From: Xiaotian feng <dfeng@redhat.com>
Subject: [RFC PATCH net-next] net: rename group sysfs entry to netdev_group
Date: Wed,  9 Feb 2011 18:52:49 +0800
Message-ID: <1297248769-28530-1-git-send-email-dfeng@redhat.com>
Cc: Xiaotian Feng <dfeng@redhat.com>,
	"David S. Miller" <davem@davemloft.net>,
	Eric Dumazet <eric.dumazet@gmail.com>,
	Tom Herbert <therbert@google.com>,
	"Eric W. Biederman" <ebiederm@xmission.com>,
	Stephen Hemminger <shemminger@vyatta.com>,
	Vlad Dogaru <ddvlad@rosedu.org>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:40703 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751663Ab1BIK5P (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 9 Feb 2011 05:57:15 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Xiaotian Feng <dfeng@redhat.com>

commit a512b92 adds sysfs entry for net device group, but
before this commit, tun also uses group sysfs, so after this
commit checkin, kernel warns like this:
    sysfs: cannot create duplicate filename '/devices/virtual/net/vnet0/group'

Since tun has used this for years, rename sysfs under tun might
break existing userspace, so rename group sysfs entry for net device
group is a better choice.

Signed-off-by: Xiaotian Feng <dfeng@redhat.com>
Cc: "David S. Miller" <davem@davemloft.net>
Cc: Eric Dumazet <eric.dumazet@gmail.com>
Cc: Tom Herbert <therbert@google.com>
Cc: "Eric W. Biederman" <ebiederm@xmission.com>
Cc: Stephen Hemminger <shemminger@vyatta.com>
Cc: Vlad Dogaru <ddvlad@rosedu.org>
---
 net/core/net-sysfs.c |    4 ++--
 1 files changed, 2 insertions(+), 2 deletions(-)

diff --git a/net/core/net-sysfs.c b/net/core/net-sysfs.c
index 2e4a393..eb4b5e0 100644
--- a/net/core/net-sysfs.c
+++ b/net/core/net-sysfs.c
@@ -295,7 +295,7 @@ static ssize_t show_ifalias(struct device *dev,
 	return ret;
 }
 
-NETDEVICE_SHOW(group, fmt_dec);
+NETDEVICE_SHOW(netdev_group, fmt_dec);
 
 static int change_group(struct net_device *net, unsigned long new_group)
 {
@@ -330,7 +330,7 @@ static struct device_attribute net_class_attributes[] = {
 	__ATTR(flags, S_IRUGO | S_IWUSR, show_flags, store_flags),
 	__ATTR(tx_queue_len, S_IRUGO | S_IWUSR, show_tx_queue_len,
 	       store_tx_queue_len),
-	__ATTR(group, S_IRUGO | S_IWUSR, show_group, store_group),
+	__ATTR(netdev_group, S_IRUGO | S_IWUSR, show_group, store_group),
 	{}
 };
 
-- 
1.7.1

