From: "Srivatsa S. Bhat" <srivatsa.bhat@linux.vnet.ibm.com>
Subject: [v2 PATCH 1/2] netprio_cgroup: Remove update_netdev_tables() since it
 is unnecessary
Date: Wed, 12 Sep 2012 11:37:42 +0530
Message-ID: <20120912060741.11037.37347.stgit@srivatsabhat.in.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: David.Laight@aculab.com, john.r.fastabend@intel.com,
	gaofeng@cn.fujitsu.com, eric.dumazet@gmail.com,
	mark.d.rustad@intel.com, lizefan@huawei.com,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	srivatsa.bhat@linux.vnet.ibm.com
To: davem@davemloft.net, nhorman@tuxdriver.com
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

The update_netdev_tables() function appears to be unnecessary, since the
write_update_netdev_table() function will adjust the priomaps as and when
required anyway. So drop the usage of update_netdev_tables() entirely.

Signed-off-by: Srivatsa S. Bhat <srivatsa.bhat@linux.vnet.ibm.com>
---

 net/core/netprio_cgroup.c |   32 --------------------------------
 1 files changed, 0 insertions(+), 32 deletions(-)

diff --git a/net/core/netprio_cgroup.c b/net/core/netprio_cgroup.c
index c75e3f9..fd339bb0 100644
--- a/net/core/netprio_cgroup.c
+++ b/net/core/netprio_cgroup.c
@@ -109,32 +109,6 @@ static int write_update_netdev_table(struct net_device *dev)
 	return ret;
 }
 
-static int update_netdev_tables(void)
-{
-	int ret = 0;
-	struct net_device *dev;
-	u32 max_len;
-	struct netprio_map *map;
-
-	rtnl_lock();
-	max_len = atomic_read(&max_prioidx) + 1;
-	for_each_netdev(&init_net, dev) {
-		map = rtnl_dereference(dev->priomap);
-		/*
-		 * don't allocate priomap if we didn't
-		 * change net_prio.ifpriomap (map == NULL),
-		 * this will speed up skb_update_prio.
-		 */
-		if (map && map->priomap_len < max_len) {
-			ret = extend_netdev_table(dev, max_len);
-			if (ret < 0)
-				break;
-		}
-	}
-	rtnl_unlock();
-	return ret;
-}
-
 static struct cgroup_subsys_state *cgrp_create(struct cgroup *cgrp)
 {
 	struct cgroup_netprio_state *cs;
@@ -153,12 +127,6 @@ static struct cgroup_subsys_state *cgrp_create(struct cgroup *cgrp)
 		goto out;
 	}
 
-	ret = update_netdev_tables();
-	if (ret < 0) {
-		put_prioidx(cs->prioidx);
-		goto out;
-	}
-
 	return &cs->css;
 out:
 	kfree(cs);
