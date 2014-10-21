From: Sabrina Dubroca <sd@queasysnail.net>
Subject: [PATCH net] net: sched: initialize bstats syncp
Date: Tue, 21 Oct 2014 11:23:30 +0200
Message-ID: <20141021092330.GA9863@kria>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Cc: netdev@vger.kernel.org, john.r.fastabend@intel.com
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp5-g21.free.fr ([212.27.42.5]:55785 "EHLO smtp5-g21.free.fr"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754981AbaJUJXi (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 21 Oct 2014 05:23:38 -0400
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Use netdev_alloc_pcpu_stats to allocate percpu stats and initialize syncp.

Fixes: 22e0f8b9322c "net: sched: make bstats per cpu and estimator RCU safe"
Signed-off-by: Sabrina Dubroca <sd@queasysnail.net>
---
 net/sched/sch_api.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/net/sched/sch_api.c b/net/sched/sch_api.c
index 2cf61b3e633c..76f402e05bd6 100644
--- a/net/sched/sch_api.c
+++ b/net/sched/sch_api.c
@@ -947,7 +947,7 @@ qdisc_create(struct net_device *dev, struct netdev_queue *dev_queue,
 	if (!ops->init || (err = ops->init(sch, tca[TCA_OPTIONS])) == 0) {
 		if (qdisc_is_percpu_stats(sch)) {
 			sch->cpu_bstats =
-				alloc_percpu(struct gnet_stats_basic_cpu);
+				netdev_alloc_pcpu_stats(struct gnet_stats_basic_cpu);
 			if (!sch->cpu_bstats)
 				goto err_out4;
 
-- 
2.1.2
