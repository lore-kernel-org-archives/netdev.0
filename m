From: Geliang Tang <geliangtang@163.com>
Subject: [PATCH 12/14] net: sched: use list_for_each_entry
Date: Fri, 18 Dec 2015 23:33:36 +0800
Message-ID: <7af1edfe42223ba907e54f69c68ca552f84f3bf1.1450451516.git.geliangtang@163.com>
References: <ab66a344512e064000357c6d3c2a6f3d0e948ddb.1450451516.git.geliangtang@163.com>
Cc: Geliang Tang <geliangtang@163.com>, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: Jamal Hadi Salim <jhs@mojatatu.com>,
	"David S. Miller" <davem@davemloft.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <ab66a344512e064000357c6d3c2a6f3d0e948ddb.1450451516.git.geliangtang@163.com>
In-Reply-To: <ab66a344512e064000357c6d3c2a6f3d0e948ddb.1450451516.git.geliangtang@163.com>
References: <ab66a344512e064000357c6d3c2a6f3d0e948ddb.1450451516.git.geliangtang@163.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Use list_for_each_entry() instead of list_for_each() to simplify
the code.

Signed-off-by: Geliang Tang <geliangtang@163.com>
---
 net/sched/sch_htb.c | 7 +++----
 1 file changed, 3 insertions(+), 4 deletions(-)

diff --git a/net/sched/sch_htb.c b/net/sched/sch_htb.c
index 15ccd7f..5f7aa74 100644
--- a/net/sched/sch_htb.c
+++ b/net/sched/sch_htb.c
@@ -948,10 +948,9 @@ static unsigned int htb_drop(struct Qdisc *sch)
 	int prio;
 
 	for (prio = TC_HTB_NUMPRIO - 1; prio >= 0; prio--) {
-		struct list_head *p;
-		list_for_each(p, q->drops + prio) {
-			struct htb_class *cl = list_entry(p, struct htb_class,
-							  un.leaf.drop_list);
+		struct htb_class *cl;
+
+		list_for_each_entry(cl, q->drops + prio, un.leaf.drop_list) {
 			unsigned int len;
 			if (cl->un.leaf.q->ops->drop &&
 			    (len = cl->un.leaf.q->ops->drop(cl->un.leaf.q))) {
-- 
2.5.0
