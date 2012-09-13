From: "Srivatsa S. Bhat" <srivatsa.bhat@linux.vnet.ibm.com>
Subject: [v3 PATCH 2/2] netprio_cgroup: Use memcpy instead of the for-loop to
 copy priomap
Date: Thu, 13 Sep 2012 12:02:34 +0530
Message-ID: <20120913063233.6278.7615.stgit@srivatsabhat.in.ibm.com>
References: <20120913063225.6278.87780.stgit@srivatsabhat.in.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: David.Laight@aculab.com, john.r.fastabend@intel.com,
	gaofeng@cn.fujitsu.com, eric.dumazet@gmail.com,
	mark.d.rustad@intel.com, lizefan@huawei.com,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	"Srivatsa S. Bhat" <srivatsa.bhat@linux.vnet.ibm.com>
To: davem@davemloft.net, nhorman@tuxdriver.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20120913063225.6278.87780.stgit@srivatsabhat.in.ibm.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Replace the current (inefficient) for-loop with memcpy, to copy priomap.

Signed-off-by: Srivatsa S. Bhat <srivatsa.bhat@linux.vnet.ibm.com>
---

 net/core/netprio_cgroup.c |    9 ++++-----
 1 files changed, 4 insertions(+), 5 deletions(-)

diff --git a/net/core/netprio_cgroup.c b/net/core/netprio_cgroup.c
index fd339bb0..45c503e 100644
--- a/net/core/netprio_cgroup.c
+++ b/net/core/netprio_cgroup.c
@@ -73,7 +73,6 @@ static int extend_netdev_table(struct net_device *dev, u32 new_len)
 			   ((sizeof(u32) * new_len));
 	struct netprio_map *new_priomap = kzalloc(new_size, GFP_KERNEL);
 	struct netprio_map *old_priomap;
-	int i;
 
 	old_priomap  = rtnl_dereference(dev->priomap);
 
@@ -82,10 +81,10 @@ static int extend_netdev_table(struct net_device *dev, u32 new_len)
 		return -ENOMEM;
 	}
 
-	for (i = 0;
-	     old_priomap && (i < old_priomap->priomap_len);
-	     i++)
-		new_priomap->priomap[i] = old_priomap->priomap[i];
+	if (old_priomap)
+		memcpy(new_priomap->priomap, old_priomap->priomap,
+		       old_priomap->priomap_len *
+		       sizeof(old_priomap->priomap[0]));
 
 	new_priomap->priomap_len = new_len;
 
