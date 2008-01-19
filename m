From: Stephen Hemminger <stephen.hemminger@vyatta.com>
Subject: [PATCH 3/3] sfq: whitespace cleanup
Date: Fri, 18 Jan 2008 16:09:41 -0800
Message-ID: <20080118160941.5599bb47@deepthought>
References: <20080118144309.3530ed2f@deepthought>
 <20080118144730.7878f12a@deepthought>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Stephen Hemminger <shemminger@vyatta.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.vyatta.com ([216.93.170.194]:54586 "EHLO mail.vyatta.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751933AbYASAMd (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 18 Jan 2008 19:12:33 -0500
In-Reply-To: <20080118144730.7878f12a@deepthought>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Add whitespace around operators, and add a few blank lines
to improve readability.

Signed-off-by: Stephen Hemminger <shemminger@vyatta.com>


--- a/net/sched/sch_sfq.c	2008-01-17 08:33:04.000000000 -0800
+++ b/net/sched/sch_sfq.c	2008-01-17 08:43:51.000000000 -0800
@@ -122,7 +122,7 @@ static unsigned sfq_hash(struct sfq_sche
 	{
 		const struct iphdr *iph = ip_hdr(skb);
 		h = iph->daddr;
-		h2 = iph->saddr^iph->protocol;
+		h2 = iph->saddr ^ iph->protocol;
 		if (!(iph->frag_off&htons(IP_MF|IP_OFFSET)) &&
 		    (iph->protocol == IPPROTO_TCP ||
 		     iph->protocol == IPPROTO_UDP ||
@@ -137,7 +137,7 @@ static unsigned sfq_hash(struct sfq_sche
 	{
 		struct ipv6hdr *iph = ipv6_hdr(skb);
 		h = iph->daddr.s6_addr32[3];
-		h2 = iph->saddr.s6_addr32[3]^iph->nexthdr;
+		h2 = iph->saddr.s6_addr32[3] ^ iph->nexthdr;
 		if (iph->nexthdr == IPPROTO_TCP ||
 		    iph->nexthdr == IPPROTO_UDP ||
 		    iph->nexthdr == IPPROTO_UDPLITE ||
@@ -148,9 +148,10 @@ static unsigned sfq_hash(struct sfq_sche
 		break;
 	}
 	default:
-		h = (u32)(unsigned long)skb->dst^skb->protocol;
-		h2 = (u32)(unsigned long)skb->sk;
+		h = (unsigned long)skb->dst ^ skb->protocol;
+		h2 = (unsigned long)skb->sk;
 	}
+
 	return sfq_fold_hash(q, h, h2);
 }
 
@@ -208,7 +209,7 @@ static unsigned int sfq_drop(struct Qdis
 	   drop a packet from it */
 
 	if (d > 1) {
-		sfq_index x = q->dep[d+SFQ_DEPTH].next;
+		sfq_index x = q->dep[d + SFQ_DEPTH].next;
 		skb = q->qs[x].prev;
 		len = skb->len;
 		__skb_unlink(skb, &q->qs[x]);
@@ -241,7 +242,7 @@ static unsigned int sfq_drop(struct Qdis
 }
 
 static int
-sfq_enqueue(struct sk_buff *skb, struct Qdisc* sch)
+sfq_enqueue(struct sk_buff *skb, struct Qdisc *sch)
 {
 	struct sfq_sched_data *q = qdisc_priv(sch);
 	unsigned hash = sfq_hash(q, skb);
@@ -252,6 +253,7 @@ sfq_enqueue(struct sk_buff *skb, struct 
 		q->ht[hash] = x = q->dep[SFQ_DEPTH].next;
 		q->hash[x] = hash;
 	}
+
 	/* If selected queue has length q->limit, this means that
 	 * all another queues are empty and that we do simple tail drop,
 	 * i.e. drop _this_ packet.
@@ -284,7 +286,7 @@ sfq_enqueue(struct sk_buff *skb, struct 
 }
 
 static int
-sfq_requeue(struct sk_buff *skb, struct Qdisc* sch)
+sfq_requeue(struct sk_buff *skb, struct Qdisc *sch)
 {
 	struct sfq_sched_data *q = qdisc_priv(sch);
 	unsigned hash = sfq_hash(q, skb);
@@ -295,6 +297,7 @@ sfq_requeue(struct sk_buff *skb, struct 
 		q->ht[hash] = x = q->dep[SFQ_DEPTH].next;
 		q->hash[x] = hash;
 	}
+
 	sch->qstats.backlog += skb->len;
 	__skb_queue_head(&q->qs[x], skb);
 	/* If selected queue has length q->limit+1, this means that
@@ -310,6 +313,7 @@ sfq_requeue(struct sk_buff *skb, struct 
 		kfree_skb(skb);
 		return NET_XMIT_CN;
 	}
+
 	sfq_inc(q, x);
 	if (q->qs[x].qlen == 1) {		/* The flow is new */
 		if (q->tail == SFQ_DEPTH) {	/* It is the first flow */
@@ -322,6 +326,7 @@ sfq_requeue(struct sk_buff *skb, struct 
 			q->tail = x;
 		}
 	}
+
 	if (++sch->q.qlen <= q->limit) {
 		sch->qstats.requeues++;
 		return 0;
@@ -336,7 +341,7 @@ sfq_requeue(struct sk_buff *skb, struct 
 
 
 static struct sk_buff *
-sfq_dequeue(struct Qdisc* sch)
+sfq_dequeue(struct Qdisc *sch)
 {
 	struct sfq_sched_data *q = qdisc_priv(sch);
 	struct sk_buff *skb;
@@ -373,7 +378,7 @@ sfq_dequeue(struct Qdisc* sch)
 }
 
 static void
-sfq_reset(struct Qdisc* sch)
+sfq_reset(struct Qdisc *sch)
 {
 	struct sk_buff *skb;
 
@@ -383,7 +388,7 @@ sfq_reset(struct Qdisc* sch)
 
 static void sfq_perturbation(unsigned long arg)
 {
-	struct Qdisc *sch = (struct Qdisc*)arg;
+	struct Qdisc *sch = (struct Qdisc *)arg;
 	struct sfq_sched_data *q = qdisc_priv(sch);
 
 	q->perturbation = net_random();
@@ -403,7 +408,7 @@ static int sfq_change(struct Qdisc *sch,
 
 	sch_tree_lock(sch);
 	q->quantum = ctl->quantum ? : psched_mtu(sch->dev);
-	q->perturb_period = ctl->perturb_period*HZ;
+	q->perturb_period = ctl->perturb_period * HZ;
 	if (ctl->limit)
 		q->limit = min_t(u32, ctl->limit, SFQ_DEPTH - 1);
 
@@ -430,13 +435,15 @@ static int sfq_init(struct Qdisc *sch, s
 	timer->data = (unsigned long)sch;;
 	init_timer_deferrable(&q->perturb_timer);
 
-	for (i=0; i<SFQ_HASH_DIVISOR; i++)
+	for (i = 0; i < SFQ_HASH_DIVISOR; i++)
 		q->ht[i] = SFQ_DEPTH;
-	for (i=0; i<SFQ_DEPTH; i++) {
+
+	for (i = 0; i < SFQ_DEPTH; i++) {
 		skb_queue_head_init(&q->qs[i]);
-		q->dep[i+SFQ_DEPTH].next = i+SFQ_DEPTH;
-		q->dep[i+SFQ_DEPTH].prev = i+SFQ_DEPTH;
+		q->dep[i + SFQ_DEPTH].next = i + SFQ_DEPTH;
+		q->dep[i + SFQ_DEPTH].prev = i + SFQ_DEPTH;
 	}
+
 	q->limit = SFQ_DEPTH - 1;
 	q->max_depth = 0;
 	q->tail = SFQ_DEPTH;
@@ -449,7 +456,8 @@ static int sfq_init(struct Qdisc *sch, s
 		if (err)
 			return err;
 	}
-	for (i=0; i<SFQ_DEPTH; i++)
+
+	for (i = 0; i < SFQ_DEPTH; i++)
 		sfq_link(q, i);
 	return 0;
 }
@@ -467,7 +475,7 @@ static int sfq_dump(struct Qdisc *sch, s
 	struct tc_sfq_qopt opt;
 
 	opt.quantum = q->quantum;
-	opt.perturb_period = q->perturb_period/HZ;
+	opt.perturb_period = q->perturb_period / HZ;
 
 	opt.limit = q->limit;
 	opt.divisor = SFQ_HASH_DIVISOR;
