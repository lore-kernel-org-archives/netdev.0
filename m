From: Joe Perches <joe@perches.com>
Subject: [PATCH 17/24] sched: Remove unnecessary OOM logging messages
Date: Mon, 29 Aug 2011 14:17:36 -0700
Message-ID: <2c57e8e336c6059dc550ba88e96dcaa27056382f.1314650069.git.joe@perches.com>
References: <cover.1314650069.git.joe@perches.com>
Cc: "David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: Jamal Hadi Salim <hadi@cyberus.ca>
Return-path: <netdev-owner@vger.kernel.org>
Received: from perches-mx.perches.com ([206.117.179.246]:40352 "EHLO
	labridge.com" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1755187Ab1H2VVU (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 29 Aug 2011 17:21:20 -0400
In-Reply-To: <cover.1314650069.git.joe@perches.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Removing unnecessary messages saves code and text.

Site specific OOM messages are duplications of a generic MM
out of memory message and aren't really useful, so just
delete them.

Signed-off-by: Joe Perches <joe@perches.com>
---
 net/sched/act_api.c |    6 ++----
 net/sched/sch_atm.c |    1 -
 2 files changed, 2 insertions(+), 5 deletions(-)

diff --git a/net/sched/act_api.c b/net/sched/act_api.c
index f2fb67e..fb98a30 100644
--- a/net/sched/act_api.c
+++ b/net/sched/act_api.c
@@ -749,10 +749,9 @@ static struct tc_action *create_a(int i)
 	struct tc_action *act;
 
 	act = kzalloc(sizeof(*act), GFP_KERNEL);
-	if (act == NULL) {
-		pr_debug("create_a: failed to alloc!\n");
+	if (act == NULL)
 		return NULL;
-	}
+
 	act->order = i;
 	return act;
 }
@@ -778,7 +777,6 @@ static int tca_action_flush(struct net *net, struct nlattr *nla,
 
 	skb = alloc_skb(NLMSG_GOODSIZE, GFP_KERNEL);
 	if (!skb) {
-		pr_debug("tca_action_flush: failed skb alloc\n");
 		kfree(a);
 		return err;
 	}
diff --git a/net/sched/sch_atm.c b/net/sched/sch_atm.c
index e25e490..cba66c4 100644
--- a/net/sched/sch_atm.c
+++ b/net/sched/sch_atm.c
@@ -270,7 +270,6 @@ static int atm_tc_change(struct Qdisc *sch, u32 classid, u32 parent,
 	}
 	pr_debug("atm_tc_change: new id %x\n", classid);
 	flow = kzalloc(sizeof(struct atm_flow_data) + hdr_len, GFP_KERNEL);
-	pr_debug("atm_tc_change: flow %p\n", flow);
 	if (!flow) {
 		error = -ENOBUFS;
 		goto err_out;
-- 
1.7.6.405.gc1be0
