From: Akinobu Mita <akinobu.mita@gmail.com>
Subject: [PATCH 22/29] net/sched: rename random32() and net_random() to prandom_u32()
Date: Mon, 24 Dec 2012 11:14:09 +0900
Message-ID: <1356315256-6572-23-git-send-email-akinobu.mita@gmail.com>
References: <1356315256-6572-1-git-send-email-akinobu.mita@gmail.com>
Cc: Akinobu Mita <akinobu.mita@gmail.com>,
	Stephen Hemminger <shemminger@vyatta.com>,
	Jamal Hadi Salim <jhs@mojatatu.com>,
	"David S. Miller" <davem@davemloft.net>,
	netem@lists.linux-foundation.org, netdev@vger.kernel.org
To: linux-kernel@vger.kernel.org, akpm@linux-foundation.org
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1356315256-6572-1-git-send-email-akinobu.mita@gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Use more preferable function name which implies using a pseudo-random
number generator.

Signed-off-by: Akinobu Mita <akinobu.mita@gmail.com>
Cc: Stephen Hemminger <shemminger@vyatta.com>
Cc: Jamal Hadi Salim <jhs@mojatatu.com>
Cc: "David S. Miller" <davem@davemloft.net>
Cc: netem@lists.linux-foundation.org
Cc: netdev@vger.kernel.org
Cc: netdev@vger.kernel.org
---
 net/sched/act_gact.c     |  2 +-
 net/sched/sch_choke.c    |  2 +-
 net/sched/sch_fq_codel.c |  2 +-
 net/sched/sch_netem.c    | 19 ++++++++++---------
 net/sched/sch_sfb.c      |  4 ++--
 net/sched/sch_sfq.c      |  6 +++---
 6 files changed, 18 insertions(+), 17 deletions(-)

diff --git a/net/sched/act_gact.c b/net/sched/act_gact.c
index 05d60859..d3ceed8 100644
--- a/net/sched/act_gact.c
+++ b/net/sched/act_gact.c
@@ -37,7 +37,7 @@ static struct tcf_hashinfo gact_hash_info = {
 #ifdef CONFIG_GACT_PROB
 static int gact_net_rand(struct tcf_gact *gact)
 {
-	if (!gact->tcfg_pval || net_random() % gact->tcfg_pval)
+	if (!gact->tcfg_pval || prandom_u32() % gact->tcfg_pval)
 		return gact->tcf_action;
 	return gact->tcfg_paction;
 }
diff --git a/net/sched/sch_choke.c b/net/sched/sch_choke.c
index cc37dd5..ef53ab8 100644
--- a/net/sched/sch_choke.c
+++ b/net/sched/sch_choke.c
@@ -80,7 +80,7 @@ struct choke_sched_data {
 /* deliver a random number between 0 and N - 1 */
 static u32 random_N(unsigned int N)
 {
-	return reciprocal_divide(random32(), N);
+	return reciprocal_divide(prandom_u32(), N);
 }
 
 /* number of elements in queue including holes */
diff --git a/net/sched/sch_fq_codel.c b/net/sched/sch_fq_codel.c
index 4e606fc..93d7f41 100644
--- a/net/sched/sch_fq_codel.c
+++ b/net/sched/sch_fq_codel.c
@@ -390,7 +390,7 @@ static int fq_codel_init(struct Qdisc *sch, struct nlattr *opt)
 	sch->limit = 10*1024;
 	q->flows_cnt = 1024;
 	q->quantum = psched_mtu(qdisc_dev(sch));
-	q->perturbation = net_random();
+	q->perturbation = prandom_u32();
 	INIT_LIST_HEAD(&q->new_flows);
 	INIT_LIST_HEAD(&q->old_flows);
 	codel_params_init(&q->cparams);
diff --git a/net/sched/sch_netem.c b/net/sched/sch_netem.c
index 298c0dd..e3126e2 100644
--- a/net/sched/sch_netem.c
+++ b/net/sched/sch_netem.c
@@ -142,7 +142,7 @@ static inline struct netem_skb_cb *netem_skb_cb(struct sk_buff *skb)
 static void init_crandom(struct crndstate *state, unsigned long rho)
 {
 	state->rho = rho;
-	state->last = net_random();
+	state->last = prandom_u32();
 }
 
 /* get_crandom - correlated random number generator
@@ -155,9 +155,9 @@ static u32 get_crandom(struct crndstate *state)
 	unsigned long answer;
 
 	if (state->rho == 0)	/* no correlation */
-		return net_random();
+		return prandom_u32();
 
-	value = net_random();
+	value = prandom_u32();
 	rho = (u64)state->rho + 1;
 	answer = (value * ((1ull<<32) - rho) + state->last * rho) >> 32;
 	state->last = answer;
@@ -171,7 +171,7 @@ static u32 get_crandom(struct crndstate *state)
 static bool loss_4state(struct netem_sched_data *q)
 {
 	struct clgstate *clg = &q->clg;
-	u32 rnd = net_random();
+	u32 rnd = prandom_u32();
 
 	/*
 	 * Makes a comparison between rnd and the transition
@@ -238,14 +238,14 @@ static bool loss_gilb_ell(struct netem_sched_data *q)
 
 	switch (clg->state) {
 	case 1:
-		if (net_random() < clg->a1)
+		if (prandom_u32() < clg->a1)
 			clg->state = 2;
-		if (net_random() < clg->a4)
+		if (prandom_u32() < clg->a4)
 			return true;
 	case 2:
-		if (net_random() < clg->a2)
+		if (prandom_u32() < clg->a2)
 			clg->state = 1;
-		if (clg->a3 > net_random())
+		if (clg->a3 > prandom_u32())
 			return true;
 	}
 
@@ -415,7 +415,8 @@ static int netem_enqueue(struct sk_buff *skb, struct Qdisc *sch)
 		     skb_checksum_help(skb)))
 			return qdisc_drop(skb, sch);
 
-		skb->data[net_random() % skb_headlen(skb)] ^= 1<<(net_random() % 8);
+		skb->data[prandom_u32() % skb_headlen(skb)] ^=
+			1 << (prandom_u32() % 8);
 	}
 
 	if (unlikely(skb_queue_len(&sch->q) >= sch->limit))
diff --git a/net/sched/sch_sfb.c b/net/sched/sch_sfb.c
index 30ea467..9b0f709 100644
--- a/net/sched/sch_sfb.c
+++ b/net/sched/sch_sfb.c
@@ -220,7 +220,7 @@ static u32 sfb_compute_qlen(u32 *prob_r, u32 *avgpm_r, const struct sfb_sched_da
 
 static void sfb_init_perturbation(u32 slot, struct sfb_sched_data *q)
 {
-	q->bins[slot].perturbation = net_random();
+	q->bins[slot].perturbation = prandom_u32();
 }
 
 static void sfb_swap_slot(struct sfb_sched_data *q)
@@ -381,7 +381,7 @@ static int sfb_enqueue(struct sk_buff *skb, struct Qdisc *sch)
 		goto enqueue;
 	}
 
-	r = net_random() & SFB_MAX_PROB;
+	r = prandom_u32() & SFB_MAX_PROB;
 
 	if (unlikely(r < p_min)) {
 		if (unlikely(p_min > SFB_MAX_PROB / 2)) {
diff --git a/net/sched/sch_sfq.c b/net/sched/sch_sfq.c
index d3a1bc2..921130e 100644
--- a/net/sched/sch_sfq.c
+++ b/net/sched/sch_sfq.c
@@ -627,7 +627,7 @@ static void sfq_perturbation(unsigned long arg)
 	spinlock_t *root_lock = qdisc_lock(qdisc_root_sleeping(sch));
 
 	spin_lock(root_lock);
-	q->perturbation = net_random();
+	q->perturbation = prandom_u32();
 	if (!q->filter_list && q->tail)
 		sfq_rehash(sch);
 	spin_unlock(root_lock);
@@ -696,7 +696,7 @@ static int sfq_change(struct Qdisc *sch, struct nlattr *opt)
 	del_timer(&q->perturb_timer);
 	if (q->perturb_period) {
 		mod_timer(&q->perturb_timer, jiffies + q->perturb_period);
-		q->perturbation = net_random();
+		q->perturbation = prandom_u32();
 	}
 	sch_tree_unlock(sch);
 	kfree(p);
@@ -757,7 +757,7 @@ static int sfq_init(struct Qdisc *sch, struct nlattr *opt)
 	q->quantum = psched_mtu(qdisc_dev(sch));
 	q->scaled_quantum = SFQ_ALLOT_SIZE(q->quantum);
 	q->perturb_period = 0;
-	q->perturbation = net_random();
+	q->perturbation = prandom_u32();
 
 	if (opt) {
 		int err = sfq_change(sch, opt);
-- 
1.7.11.7
