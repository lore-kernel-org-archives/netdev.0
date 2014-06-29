From: Amir Vadai <amirv@mellanox.com>
Subject: [PATCH net V1 2/3] lib/cpumask: cpumask_set_cpu_local_first to use all cores when numa node is not defined
Date: Sun, 29 Jun 2014 11:54:56 +0300
Message-ID: <1404032097-5132-3-git-send-email-amirv@mellanox.com>
References: <1404032097-5132-1-git-send-email-amirv@mellanox.com>
Cc: netdev@vger.kernel.org, Amir Vadai <amirv@mellanox.com>,
	Or Gerlitz <ogerlitz@mellanox.com>,
	Yevgeny Petrilin <yevgenyp@mellanox.com>
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mailp.voltaire.com ([193.47.165.129]:43619 "EHLO mellanox.co.il"
	rhost-flags-OK-FAIL-OK-FAIL) by vger.kernel.org with ESMTP
	id S1752430AbaF2IzP (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sun, 29 Jun 2014 04:55:15 -0400
In-Reply-To: <1404032097-5132-1-git-send-email-amirv@mellanox.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

When device is non numa aware (numa_node == -1), use all online cpu's.

Signed-off-by: Amir Vadai <amirv@mellanox.com>
---
 lib/cpumask.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/lib/cpumask.c b/lib/cpumask.c
index c101230..b6513a9 100644
--- a/lib/cpumask.c
+++ b/lib/cpumask.c
@@ -191,7 +191,7 @@ int cpumask_set_cpu_local_first(int i, int numa_node, cpumask_t *dstp)
 
 	i %= num_online_cpus();
 
-	if (!cpumask_of_node(numa_node)) {
+	if (numa_node == -1 || !cpumask_of_node(numa_node)) {
 		/* Use all online cpu's for non numa aware system */
 		cpumask_copy(mask, cpu_online_mask);
 	} else {
-- 
1.8.3.4
