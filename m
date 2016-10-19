From: Or Gerlitz <ogerlitz@mellanox.com>
Subject: [PATCH net] net/sched: act_mirred: Use passed lastuse argument
Date: Wed, 19 Oct 2016 17:42:39 +0300
Message-ID: <1476888159-30332-1-git-send-email-ogerlitz@mellanox.com>
Cc: Amir Vadai <amirva@mellanox.com>, jakub.kicinski@netronome.com,
        netdev@vger.kernel.org, Paul Blakey <paulb@mellanox.com>,
        Or Gerlitz <ogerlitz@mellanox.com>
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-il-dmz.mellanox.com ([193.47.165.129]:44608 "EHLO
        mellanox.co.il" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
        with ESMTP id S942886AbcJSOms (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 19 Oct 2016 10:42:48 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Paul Blakey <paulb@mellanox.com>

stats_update callback is called by NIC drivers doing hardware
offloading of the mirred action. Lastuse is passed as argument
to specify when the stats was actually last updated and is not
always the current time.

Fixes: 9798e6fe4f9b ('net: act_mirred: allow statistic updates from offloaded actions')
Signed-off-by: Paul Blakey <paulb@mellanox.com>
Signed-off-by: Or Gerlitz <ogerlitz@mellanox.com>
---
 net/sched/act_mirred.c | 5 ++++-
 1 file changed, 4 insertions(+), 1 deletion(-)

diff --git a/net/sched/act_mirred.c b/net/sched/act_mirred.c
index 667dc38..6b07fba 100644
--- a/net/sched/act_mirred.c
+++ b/net/sched/act_mirred.c
@@ -207,8 +207,11 @@ static int tcf_mirred(struct sk_buff *skb, const struct tc_action *a,
 static void tcf_stats_update(struct tc_action *a, u64 bytes, u32 packets,
 			     u64 lastuse)
 {
-	tcf_lastuse_update(&a->tcfa_tm);
+	struct tcf_mirred *m = to_mirred(a);
+	struct tcf_t *tm = &m->tcf_tm;
+
 	_bstats_cpu_update(this_cpu_ptr(a->cpu_bstats), bytes, packets);
+	tm->lastuse = lastuse;
 }
 
 static int tcf_mirred_dump(struct sk_buff *skb, struct tc_action *a, int bind,
-- 
2.3.7
