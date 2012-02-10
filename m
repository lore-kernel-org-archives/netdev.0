From: Neil Horman <nhorman@tuxdriver.com>
Subject: [PATCH 2/3] netprio_cgroup: don't allocate prio table when a device is registered
Date: Fri, 10 Feb 2012 10:43:37 -0500
Message-ID: <1328888618-16208-3-git-send-email-nhorman@tuxdriver.com>
References: <1328888618-16208-1-git-send-email-nhorman@tuxdriver.com>
Cc: Neil Horman <nhorman@tuxdriver.com>,
	Li Zefan <lizf@cn.fujitsu.com>,
	"David S. Miller" <davem@davemloft.net>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from charlotte.tuxdriver.com ([70.61.120.58]:58510 "EHLO
	smtp.tuxdriver.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1758071Ab2BJPof (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 10 Feb 2012 10:44:35 -0500
In-Reply-To: <1328888618-16208-1-git-send-email-nhorman@tuxdriver.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

So we delay the allocation till the priority is set through cgroup,
and this makes skb_update_priority() faster when it's not set.

This also eliminates an off-by-one bug similar with the one fixed
in the previous patch.

Origionally-authored-by: Li Zefan <lizf@cn.fujitsu.com>
Signed-off-by: Li Zefan <lizf@cn.fujitsu.com>
Signed-off-by: Neil Horman <nhorman@tuxdriver.com>
CC: "David S. Miller" <davem@davemloft.net>
---
 net/core/netprio_cgroup.c |    6 ------
 1 files changed, 0 insertions(+), 6 deletions(-)

diff --git a/net/core/netprio_cgroup.c b/net/core/netprio_cgroup.c
index 72c6387..4dacc44 100644
--- a/net/core/netprio_cgroup.c
+++ b/net/core/netprio_cgroup.c
@@ -271,7 +271,6 @@ static int netprio_device_event(struct notifier_block *unused,
 {
 	struct net_device *dev = ptr;
 	struct netprio_map *old;
-	u32 max_len = atomic_read(&max_prioidx);
 
 	/*
 	 * Note this is called with rtnl_lock held so we have update side
@@ -279,11 +278,6 @@ static int netprio_device_event(struct notifier_block *unused,
 	 */
 
 	switch (event) {
-
-	case NETDEV_REGISTER:
-		if (max_len)
-			extend_netdev_table(dev, max_len);
-		break;
 	case NETDEV_UNREGISTER:
 		old = rtnl_dereference(dev->priomap);
 		RCU_INIT_POINTER(dev->priomap, NULL);
-- 
1.7.7.6
