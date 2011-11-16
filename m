From: David Decotigny <david.decotigny@google.com>
Subject: [PATCH net-next v5 02/10] net-sysfs: fixed minor sparse warning
Date: Tue, 15 Nov 2011 21:15:50 -0800
Message-ID: <1a71b137887d15a0bad8af7c931b8795ee7f20b7.1321420513.git.david.decotigny@google.com>
References: <cover.1321420513.git.david.decotigny@google.com>
Cc: "David S. Miller" <davem@davemloft.net>,
	Ian Campbell <ian.campbell@citrix.com>,
	Eric Dumazet <eric.dumazet@gmail.com>,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>,
	Ben Hutchings <bhutchings@solarflare.com>,
	Jiri Pirko <jpirko@redhat.com>, Joe Perches <joe@perches.com>,
	Szymon Janc <szymon@janc.net.pl>,
	Richard Jones <rick.jones2@hp.com>,
	Ayaz Abdulla <AAbdulla@nvidia.com>,
	David Decotigny <david.decotigny@google.com>
To: netdev@vger.kernel.org, linux-kernel@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-yx0-f202.google.com ([209.85.213.202]:33204 "EHLO
	mail-yx0-f202.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752618Ab1KPFQ3 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 16 Nov 2011 00:16:29 -0500
Received: by yenm10 with SMTP id m10so223253yen.1
        for <netdev@vger.kernel.org>; Tue, 15 Nov 2011 21:16:29 -0800 (PST)
In-Reply-To: <cover.1321420513.git.david.decotigny@google.com>
In-Reply-To: <cover.1321420513.git.david.decotigny@google.com>
References: <cover.1321420513.git.david.decotigny@google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This commit fixes following warning:
net/core/net-sysfs.c:921:6: warning: symbol 'numa_node' shadows an earlier one
include/linux/topology.h:222:1: originally declared here



Signed-off-by: David Decotigny <david.decotigny@google.com>
---
 net/core/net-sysfs.c |   12 ++++++------
 1 files changed, 6 insertions(+), 6 deletions(-)

diff --git a/net/core/net-sysfs.c b/net/core/net-sysfs.c
index c71c434..a64382f 100644
--- a/net/core/net-sysfs.c
+++ b/net/core/net-sysfs.c
@@ -901,7 +901,7 @@ static ssize_t store_xps_map(struct netdev_queue *queue,
 	struct xps_map *map, *new_map;
 	struct xps_dev_maps *dev_maps, *new_dev_maps;
 	int nonempty = 0;
-	int numa_node = -2;
+	int numa_node_id = -2;
 
 	if (!capable(CAP_NET_ADMIN))
 		return -EPERM;
@@ -944,10 +944,10 @@ static ssize_t store_xps_map(struct netdev_queue *queue,
 		need_set = cpumask_test_cpu(cpu, mask) && cpu_online(cpu);
 #ifdef CONFIG_NUMA
 		if (need_set) {
-			if (numa_node == -2)
-				numa_node = cpu_to_node(cpu);
-			else if (numa_node != cpu_to_node(cpu))
-				numa_node = -1;
+			if (numa_node_id == -2)
+				numa_node_id = cpu_to_node(cpu);
+			else if (numa_node_id != cpu_to_node(cpu))
+				numa_node_id = -1;
 		}
 #endif
 		if (need_set && pos >= map_len) {
@@ -997,7 +997,7 @@ static ssize_t store_xps_map(struct netdev_queue *queue,
 	if (dev_maps)
 		kfree_rcu(dev_maps, rcu);
 
-	netdev_queue_numa_node_write(queue, (numa_node >= 0) ? numa_node :
+	netdev_queue_numa_node_write(queue, (numa_node_id >= 0) ? numa_node_id :
 					    NUMA_NO_NODE);
 
 	mutex_unlock(&xps_map_mutex);
-- 
1.7.3.1
