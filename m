From: Jamal Hadi Salim <jhs@mojatatu.com>
Subject: [PATCH v2 net-next 1/3] net sched: actions use tcf_lastuse_update for consistency
Date: Mon,  6 Jun 2016 06:32:53 -0400
Message-ID: <1465209175-8002-2-git-send-email-jhs@emojatatu.com>
References: <1465209175-8002-1-git-send-email-jhs@emojatatu.com>
Cc: netdev@vger.kernel.org, xiyou.wangcong@gmail.com,
	daniel@iogearbox.net, Jamal Hadi Salim <jhs@mojatatu.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-it0-f68.google.com ([209.85.214.68]:33761 "EHLO
	mail-it0-f68.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751169AbcFFKfL (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 6 Jun 2016 06:35:11 -0400
Received: by mail-it0-f68.google.com with SMTP id u203so5540309itc.0
        for <netdev@vger.kernel.org>; Mon, 06 Jun 2016 03:35:10 -0700 (PDT)
In-Reply-To: <1465209175-8002-1-git-send-email-jhs@emojatatu.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jamal Hadi Salim <jhs@mojatatu.com>

Signed-off-by: Jamal Hadi Salim <jhs@mojatatu.com>
---
 net/sched/act_connmark.c | 2 +-
 net/sched/act_csum.c     | 2 +-
 net/sched/act_ife.c      | 6 +++---
 net/sched/act_ipt.c      | 2 +-
 net/sched/act_mirred.c   | 1 -
 net/sched/act_nat.c      | 2 +-
 net/sched/act_pedit.c    | 2 +-
 net/sched/act_simple.c   | 2 +-
 net/sched/act_skbedit.c  | 2 +-
 net/sched/act_vlan.c     | 2 +-
 10 files changed, 11 insertions(+), 12 deletions(-)

diff --git a/net/sched/act_connmark.c b/net/sched/act_connmark.c
index 2ba700c..e0e6c68 100644
--- a/net/sched/act_connmark.c
+++ b/net/sched/act_connmark.c
@@ -44,7 +44,7 @@ static int tcf_connmark(struct sk_buff *skb, const struct tc_action *a,
 	int proto;
 
 	spin_lock(&ca->tcf_lock);
-	ca->tcf_tm.lastuse = jiffies;
+	tcf_lastuse_update(&ca->tcf_tm);
 	bstats_update(&ca->tcf_bstats, skb);
 
 	if (skb->protocol == htons(ETH_P_IP)) {
diff --git a/net/sched/act_csum.c b/net/sched/act_csum.c
index 28e934e..065f716 100644
--- a/net/sched/act_csum.c
+++ b/net/sched/act_csum.c
@@ -501,7 +501,7 @@ static int tcf_csum(struct sk_buff *skb,
 	u32 update_flags;
 
 	spin_lock(&p->tcf_lock);
-	p->tcf_tm.lastuse = jiffies;
+	tcf_lastuse_update(&p->tcf_tm);
 	bstats_update(&p->tcf_bstats, skb);
 	action = p->tcf_action;
 	update_flags = p->update_flags;
diff --git a/net/sched/act_ife.c b/net/sched/act_ife.c
index 658046d..6491576 100644
--- a/net/sched/act_ife.c
+++ b/net/sched/act_ife.c
@@ -623,7 +623,7 @@ static int tcf_ife_decode(struct sk_buff *skb, const struct tc_action *a,
 
 	spin_lock(&ife->tcf_lock);
 	bstats_update(&ife->tcf_bstats, skb);
-	ife->tcf_tm.lastuse = jiffies;
+	tcf_lastuse_update(&ife->tcf_tm);
 	spin_unlock(&ife->tcf_lock);
 
 	ifehdrln = ntohs(ifehdrln);
@@ -711,7 +711,7 @@ static int tcf_ife_encode(struct sk_buff *skb, const struct tc_action *a,
 
 	spin_lock(&ife->tcf_lock);
 	bstats_update(&ife->tcf_bstats, skb);
-	ife->tcf_tm.lastuse = jiffies;
+	tcf_lastuse_update(&ife->tcf_tm);
 
 	if (!metalen) {		/* no metadata to send */
 		/* abuse overlimits to count when we allow packet
@@ -802,7 +802,7 @@ static int tcf_ife_act(struct sk_buff *skb, const struct tc_action *a,
 	pr_info_ratelimited("unknown failure(policy neither de/encode\n");
 	spin_lock(&ife->tcf_lock);
 	bstats_update(&ife->tcf_bstats, skb);
-	ife->tcf_tm.lastuse = jiffies;
+	tcf_lastuse_update(&ife->tcf_tm);
 	ife->tcf_qstats.drops++;
 	spin_unlock(&ife->tcf_lock);
 
diff --git a/net/sched/act_ipt.c b/net/sched/act_ipt.c
index 9f002ad..30e9087 100644
--- a/net/sched/act_ipt.c
+++ b/net/sched/act_ipt.c
@@ -212,7 +212,7 @@ static int tcf_ipt(struct sk_buff *skb, const struct tc_action *a,
 
 	spin_lock(&ipt->tcf_lock);
 
-	ipt->tcf_tm.lastuse = jiffies;
+	tcf_lastuse_update(&ipt->tcf_tm);
 	bstats_update(&ipt->tcf_bstats, skb);
 
 	/* yes, we have to worry about both in and out dev
diff --git a/net/sched/act_mirred.c b/net/sched/act_mirred.c
index 128942b..d3ac73e 100644
--- a/net/sched/act_mirred.c
+++ b/net/sched/act_mirred.c
@@ -157,7 +157,6 @@ static int tcf_mirred(struct sk_buff *skb, const struct tc_action *a,
 	u32 at;
 
 	tcf_lastuse_update(&m->tcf_tm);
-
 	bstats_cpu_update(this_cpu_ptr(m->common.cpu_bstats), skb);
 
 	rcu_read_lock();
diff --git a/net/sched/act_nat.c b/net/sched/act_nat.c
index c0a879f..9135aa8 100644
--- a/net/sched/act_nat.c
+++ b/net/sched/act_nat.c
@@ -103,7 +103,7 @@ static int tcf_nat(struct sk_buff *skb, const struct tc_action *a,
 
 	spin_lock(&p->tcf_lock);
 
-	p->tcf_tm.lastuse = jiffies;
+	tcf_lastuse_update(&p->tcf_tm);
 	old_addr = p->old_addr;
 	new_addr = p->new_addr;
 	mask = p->mask;
diff --git a/net/sched/act_pedit.c b/net/sched/act_pedit.c
index c6e18f2..67a1726 100644
--- a/net/sched/act_pedit.c
+++ b/net/sched/act_pedit.c
@@ -121,7 +121,7 @@ static int tcf_pedit(struct sk_buff *skb, const struct tc_action *a,
 
 	spin_lock(&p->tcf_lock);
 
-	p->tcf_tm.lastuse = jiffies;
+	tcf_lastuse_update(&p->tcf_tm);
 
 	if (p->tcfp_nkeys > 0) {
 		struct tc_pedit_key *tkey = p->tcfp_keys;
diff --git a/net/sched/act_simple.c b/net/sched/act_simple.c
index e42f8da..f95d1c5 100644
--- a/net/sched/act_simple.c
+++ b/net/sched/act_simple.c
@@ -35,7 +35,7 @@ static int tcf_simp(struct sk_buff *skb, const struct tc_action *a,
 	struct tcf_defact *d = a->priv;
 
 	spin_lock(&d->tcf_lock);
-	d->tcf_tm.lastuse = jiffies;
+	tcf_lastuse_update(&d->tcf_tm);
 	bstats_update(&d->tcf_bstats, skb);
 
 	/* print policy string followed by _ then packet count
diff --git a/net/sched/act_skbedit.c b/net/sched/act_skbedit.c
index e928802..82105c8 100644
--- a/net/sched/act_skbedit.c
+++ b/net/sched/act_skbedit.c
@@ -37,7 +37,7 @@ static int tcf_skbedit(struct sk_buff *skb, const struct tc_action *a,
 	struct tcf_skbedit *d = a->priv;
 
 	spin_lock(&d->tcf_lock);
-	d->tcf_tm.lastuse = jiffies;
+	tcf_lastuse_update(&d->tcf_tm);
 	bstats_update(&d->tcf_bstats, skb);
 
 	if (d->flags & SKBEDIT_F_PRIORITY)
diff --git a/net/sched/act_vlan.c b/net/sched/act_vlan.c
index ac4adc8..da5120f 100644
--- a/net/sched/act_vlan.c
+++ b/net/sched/act_vlan.c
@@ -31,7 +31,7 @@ static int tcf_vlan(struct sk_buff *skb, const struct tc_action *a,
 	int err;
 
 	spin_lock(&v->tcf_lock);
-	v->tcf_tm.lastuse = jiffies;
+	tcf_lastuse_update(&v->tcf_tm);
 	bstats_update(&v->tcf_bstats, skb);
 	action = v->tcf_action;
 
-- 
1.9.1
