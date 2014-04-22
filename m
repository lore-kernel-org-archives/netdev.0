From: Jianyu Zhan <nasa4836@gmail.com>
Subject: [PATCH 3/4] netprio_cgroup: use accessor to get id from css
Date: Tue, 22 Apr 2014 14:31:01 +0800
Message-ID: <0b10af801af45fdbf4835e8da54273e9752b239f.1398147734.git.nasa4836@gmail.com>
References: <cover.1398147734.git.nasa4836@gmail.com>
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: davem@davemloft.net, tj@kernel.org, lizefan@huawei.com,
	nhorman@tuxdriver.com, daniel.wagner@bmw-carit.de,
	nasa4836@gmail.com, jiri@resnulli.us, gaofeng@cn.fujitsu.com,
	stephen@networkplumber.org
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <cover.1398147734.git.nasa4836@gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This is a prepared patch for converting from per-cgroup id to
per-subsystem id.

We should not access per-cgroup id directly, since this is
implemetation detail.

Use the accessor css_from_id() instead.

This patch has no functional change.

Signed-off-by: Jianyu Zhan <nasa4836@gmail.com>
---
 net/core/netprio_cgroup.c | 8 ++++----
 1 file changed, 4 insertions(+), 4 deletions(-)

diff --git a/net/core/netprio_cgroup.c b/net/core/netprio_cgroup.c
index ce285c6..fc21035 100644
--- a/net/core/netprio_cgroup.c
+++ b/net/core/netprio_cgroup.c
@@ -89,7 +89,7 @@ static int extend_netdev_table(struct net_device *dev, u32 target_idx)
 static u32 netprio_prio(struct cgroup_subsys_state *css, struct net_device *dev)
 {
 	struct netprio_map *map = rcu_dereference_rtnl(dev->priomap);
-	int id = css->cgroup->id;
+	int id = css_to_id(css);
 
 	if (map && id < map->priomap_len)
 		return map->priomap[id];
@@ -109,7 +109,7 @@ static int netprio_set_prio(struct cgroup_subsys_state *css,
 			    struct net_device *dev, u32 prio)
 {
 	struct netprio_map *map;
-	int id = css->cgroup->id;
+	int id = css_to_id(css);
 	int ret;
 
 	/* avoid extending priomap for zero writes */
@@ -170,7 +170,7 @@ static void cgrp_css_free(struct cgroup_subsys_state *css)
 
 static u64 read_prioidx(struct cgroup_subsys_state *css, struct cftype *cft)
 {
-	return css->cgroup->id;
+	return css_to_id(css);
 }
 
 static int read_priomap(struct seq_file *sf, void *v)
@@ -222,7 +222,7 @@ static void net_prio_attach(struct cgroup_subsys_state *css,
 			    struct cgroup_taskset *tset)
 {
 	struct task_struct *p;
-	void *v = (void *)(unsigned long)css->cgroup->id;
+	void *v = (void *)(unsigned long)css_to_id(css);
 
 	cgroup_taskset_for_each(p, tset) {
 		task_lock(p);
-- 
2.0.0-rc0
