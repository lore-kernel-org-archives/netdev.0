From: Valdis Kletnieks <Valdis.Kletnieks@vt.edu>
Subject: [PATCH] fix suspicious rcu_dereference_check in net/sched/sch_fq_codel.c
Date: Tue, 09 Dec 2014 16:15:50 -0500
Message-ID: <58905.1418159750@turing-police.cc.vt.edu>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: linux-kernel@vger.kernel.org, netdev <netdev@vger.kernel.org>
To: Eric Dumazet <edumazet@google.com>,
	John Fastabend <john.r.fastabend@intel.com>,
	"David S. Miller" <davem@davemloft.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

commit 46e5da40ae (net: qdisc: use rcu prefix and silence
 sparse warnings) triggers a spurious warning:

net/sched/sch_fq_codel.c:97 suspicious rcu_dereference_check() usage!

The code should be using the _bh variant of rcu_dereference.

Signed-off-by: Valdis Kletnieks <valdis.kletnieks@vt.edu>
---
 net/sched/sch_fq_codel.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/net/sched/sch_fq_codel.c b/net/sched/sch_fq_codel.c
index b9ca32ebc1de..1e52decb7b59 100644
--- a/net/sched/sch_fq_codel.c
+++ b/net/sched/sch_fq_codel.c
@@ -94,7 +94,7 @@ static unsigned int fq_codel_classify(struct sk_buff *skb, struct Qdisc *sch,
 	    TC_H_MIN(skb->priority) <= q->flows_cnt)
 		return TC_H_MIN(skb->priority);
 
-	filter = rcu_dereference(q->filter_list);
+	filter = rcu_dereference_bh(q->filter_list);
 	if (!filter)
 		return fq_codel_hash(q, skb) + 1;
 
-- 
2.2.0
