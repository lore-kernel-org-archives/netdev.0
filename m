From: Jamal Hadi Salim <jhs@mojatatu.com>
Subject: [net-next PATCH 2/2] net sched: actions use tcf_lastuse_update
Date: Tue, 17 May 2016 17:19:15 -0400
Message-ID: <1463519955-2866-3-git-send-email-jhs@emojatatu.com>
References: <1463519955-2866-1-git-send-email-jhs@emojatatu.com>
Cc: netdev@vger.kernel.org, xiyou.wangcong@gmail.com, nbd@nbd.name,
	baronchon@n7mm.org, alexander.duyck@gmail.com,
	herbert@gondor.apana.org.au, Jamal Hadi Salim <jhs@mojatatu.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-io0-f193.google.com ([209.85.223.193]:34520 "EHLO
	mail-io0-f193.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751662AbcEQVT3 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 17 May 2016 17:19:29 -0400
Received: by mail-io0-f193.google.com with SMTP id d62so5988798iof.1
        for <netdev@vger.kernel.org>; Tue, 17 May 2016 14:19:28 -0700 (PDT)
In-Reply-To: <1463519955-2866-1-git-send-email-jhs@emojatatu.com>
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
index 17520ed..5daeab6 100644
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
index e5ca7bb..65bc135 100644
--- a/net/sched/act_ipt.c
+++ b/net/sched/act_ipt.c
@@ -213,7 +213,7 @@ static int tcf_ipt(struct sk_buff *skb, const struct tc_action *a,
 
 	spin_lock(&ipt->tcf_lock);
 
-	ipt->tcf_tm.lastuse = jiffies;
+	tcf_lastuse_update(&ipt->tcf_tm);
 	bstats_update(&ipt->tcf_bstats, skb);
 
 	/* yes, we have to worry about both in and out dev
diff --git a/net/sched/act_mirred.c b/net/sched/act_mirred.c
index 9e682c8..f718090 100644
--- a/net/sched/act_mirred.c
+++ b/net/sched/act_mirred.c
@@ -156,7 +156,6 @@ static int tcf_mirred(struct sk_buff *skb, const struct tc_action *a,
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
index d9f44be..bfdfc66 100644
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
index 784b478..d9d1f41 100644
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
index ab41556..68da2eb 100644
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
