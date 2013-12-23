From: Yang Yingliang <yangyingliang@huawei.com>
Subject: [PATCH net-next v2 3/3] sch_dsmark: use correct func name in print messages
Date: Mon, 23 Dec 2013 17:39:00 +0800
Message-ID: <1387791540-27028-4-git-send-email-yangyingliang@huawei.com>
References: <1387791540-27028-1-git-send-email-yangyingliang@huawei.com>
Mime-Version: 1.0
Content-Type: text/plain
To: <davem@davemloft.net>, <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from szxga03-in.huawei.com ([119.145.14.66]:63301 "EHLO
	szxga03-in.huawei.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752355Ab3LWJjQ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 23 Dec 2013 04:39:16 -0500
In-Reply-To: <1387791540-27028-1-git-send-email-yangyingliang@huawei.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

In dsmark_drop(), the function name printed by pr_debug
is "dsmark_reset", correct it to "dsmark_drop" by using
__func__ .

BTW, replace the other function names with __func__ .

Signed-off-by: Yang Yingliang <yangyingliang@huawei.com>
---
 net/sched/sch_dsmark.c | 37 +++++++++++++++++++------------------
 1 file changed, 19 insertions(+), 18 deletions(-)

diff --git a/net/sched/sch_dsmark.c b/net/sched/sch_dsmark.c
index 7cd49e5..49d6ef3 100644
--- a/net/sched/sch_dsmark.c
+++ b/net/sched/sch_dsmark.c
@@ -57,8 +57,8 @@ static int dsmark_graft(struct Qdisc *sch, unsigned long arg,
 {
 	struct dsmark_qdisc_data *p = qdisc_priv(sch);
 
-	pr_debug("dsmark_graft(sch %p,[qdisc %p],new %p,old %p)\n",
-		sch, p, new, old);
+	pr_debug("%s(sch %p,[qdisc %p],new %p,old %p)\n",
+		 __func__, sch, p, new, old);
 
 	if (new == NULL) {
 		new = qdisc_create_dflt(sch->dev_queue, &pfifo_qdisc_ops,
@@ -85,8 +85,8 @@ static struct Qdisc *dsmark_leaf(struct Qdisc *sch, unsigned long arg)
 
 static unsigned long dsmark_get(struct Qdisc *sch, u32 classid)
 {
-	pr_debug("dsmark_get(sch %p,[qdisc %p],classid %x)\n",
-		sch, qdisc_priv(sch), classid);
+	pr_debug("%s(sch %p,[qdisc %p],classid %x)\n",
+		 __func__, sch, qdisc_priv(sch), classid);
 
 	return TC_H_MIN(classid) + 1;
 }
@@ -118,8 +118,8 @@ static int dsmark_change(struct Qdisc *sch, u32 classid, u32 parent,
 	int err = -EINVAL;
 	u8 mask = 0;
 
-	pr_debug("dsmark_change(sch %p,[qdisc %p],classid %x,parent %x),"
-		"arg 0x%lx\n", sch, p, classid, parent, *arg);
+	pr_debug("%s(sch %p,[qdisc %p],classid %x,parent %x), arg 0x%lx\n",
+		 __func__, sch, p, classid, parent, *arg);
 
 	if (!dsmark_valid_index(p, *arg)) {
 		err = -ENOENT;
@@ -166,7 +166,8 @@ static void dsmark_walk(struct Qdisc *sch, struct qdisc_walker *walker)
 	struct dsmark_qdisc_data *p = qdisc_priv(sch);
 	int i;
 
-	pr_debug("dsmark_walk(sch %p,[qdisc %p],walker %p)\n", sch, p, walker);
+	pr_debug("%s(sch %p,[qdisc %p],walker %p)\n",
+		 __func__, sch, p, walker);
 
 	if (walker->stop)
 		return;
@@ -199,7 +200,7 @@ static int dsmark_enqueue(struct sk_buff *skb, struct Qdisc *sch)
 	struct dsmark_qdisc_data *p = qdisc_priv(sch);
 	int err;
 
-	pr_debug("dsmark_enqueue(skb %p,sch %p,[qdisc %p])\n", skb, sch, p);
+	pr_debug("%s(skb %p,sch %p,[qdisc %p])\n", __func__, skb, sch, p);
 
 	if (p->set_tc_index) {
 		switch (skb->protocol) {
@@ -275,7 +276,7 @@ static struct sk_buff *dsmark_dequeue(struct Qdisc *sch)
 	struct sk_buff *skb;
 	u32 index;
 
-	pr_debug("dsmark_dequeue(sch %p,[qdisc %p])\n", sch, p);
+	pr_debug("%s(sch %p,[qdisc %p])\n", __func__, sch, p);
 
 	skb = p->q->ops->dequeue(p->q);
 	if (skb == NULL)
@@ -303,8 +304,8 @@ static struct sk_buff *dsmark_dequeue(struct Qdisc *sch)
 		 * and don't need yet another qdisc as a bypass.
 		 */
 		if (p->mask[index] != 0xff || p->value[index])
-			pr_warn("dsmark_dequeue: unsupported protocol %d\n",
-				ntohs(skb->protocol));
+			pr_warn("%s: unsupported protocol %d\n",
+				__func__, ntohs(skb->protocol));
 		break;
 	}
 
@@ -315,7 +316,7 @@ static struct sk_buff *dsmark_peek(struct Qdisc *sch)
 {
 	struct dsmark_qdisc_data *p = qdisc_priv(sch);
 
-	pr_debug("dsmark_peek(sch %p,[qdisc %p])\n", sch, p);
+	pr_debug("%s(sch %p,[qdisc %p])\n", __func__, sch, p);
 
 	return p->q->ops->peek(p->q);
 }
@@ -325,7 +326,7 @@ static unsigned int dsmark_drop(struct Qdisc *sch)
 	struct dsmark_qdisc_data *p = qdisc_priv(sch);
 	unsigned int len;
 
-	pr_debug("dsmark_reset(sch %p,[qdisc %p])\n", sch, p);
+	pr_debug("%s(sch %p,[qdisc %p])\n", __func__, sch, p);
 
 	if (p->q->ops->drop == NULL)
 		return 0;
@@ -346,7 +347,7 @@ static int dsmark_init(struct Qdisc *sch, struct nlattr *opt)
 	u16 indices;
 	u8 *mask;
 
-	pr_debug("dsmark_init(sch %p,[qdisc %p],opt %p)\n", sch, p, opt);
+	pr_debug("%s(sch %p,[qdisc %p],opt %p)\n", __func__, sch, p, opt);
 
 	if (!opt)
 		goto errout;
@@ -384,7 +385,7 @@ static int dsmark_init(struct Qdisc *sch, struct nlattr *opt)
 	if (p->q == NULL)
 		p->q = &noop_qdisc;
 
-	pr_debug("dsmark_init: qdisc %p\n", p->q);
+	pr_debug("%s: qdisc %p\n", __func__, p->q);
 
 	err = 0;
 errout:
@@ -395,7 +396,7 @@ static void dsmark_reset(struct Qdisc *sch)
 {
 	struct dsmark_qdisc_data *p = qdisc_priv(sch);
 
-	pr_debug("dsmark_reset(sch %p,[qdisc %p])\n", sch, p);
+	pr_debug("%s(sch %p,[qdisc %p])\n", __func__, sch, p);
 	qdisc_reset(p->q);
 	sch->q.qlen = 0;
 }
@@ -404,7 +405,7 @@ static void dsmark_destroy(struct Qdisc *sch)
 {
 	struct dsmark_qdisc_data *p = qdisc_priv(sch);
 
-	pr_debug("dsmark_destroy(sch %p,[qdisc %p])\n", sch, p);
+	pr_debug("%s(sch %p,[qdisc %p])\n", __func__, sch, p);
 
 	tcf_destroy_chain(&p->filter_list);
 	qdisc_destroy(p->q);
@@ -417,7 +418,7 @@ static int dsmark_dump_class(struct Qdisc *sch, unsigned long cl,
 	struct dsmark_qdisc_data *p = qdisc_priv(sch);
 	struct nlattr *opts = NULL;
 
-	pr_debug("dsmark_dump_class(sch %p,[qdisc %p],class %ld\n", sch, p, cl);
+	pr_debug("%s(sch %p,[qdisc %p],class %ld\n", __func__, sch, p, cl);
 
 	if (!dsmark_valid_index(p, cl))
 		return -EINVAL;
-- 
1.8.0
