From: akpm@osdl.org
Subject: [patch 4/4] pkt_sched.h warning fixes
Date: Wed, 23 Jun 2004 23:30:40 -0700
Sender: netdev-bounce@oss.sgi.com
Message-ID: <200406240631.i5O6VaZ31258@mail.osdl.org>
Cc: netdev@oss.sgi.com, akpm@osdl.org
Return-path: <netdev-bounce@oss.sgi.com>
To: davem@redhat.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org



net/sched/police.c: In function `tcf_act_police':
net/sched/police.c:324: warning: statement with no effect
net/sched/police.c: In function `tcf_police':
net/sched/police.c:526: warning: statement with no effect
net/sched/sch_htb.c: In function `htb_debug_dump':
net/sched/sch_htb.c:370: warning: statement with no effect
net/sched/sch_htb.c: In function `htb_charge_class':
net/sched/sch_htb.c:810: warning: statement with no effect
net/sched/sch_htb.c: In function `htb_do_events':
net/sched/sch_htb.c:881: warning: statement with no effect
net/sched/sch_red.c: In function `red_enqueue':
net/sched/sch_red.c:192: warning: statement with no effect
net/sched/sch_gred.c: In function `gred_enqueue':
net/sched/sch_gred.c:158: warning: statement with no effect
net/sched/sch_gred.c: In function `gred_dump':
net/sched/sch_gred.c:554: warning: statement with no effect
net/sched/sch_tbf.c: In function `tbf_dequeue':
net/sched/sch_tbf.c:210: warning: statement with no effect

Signed-off-by: Andrew Morton <akpm@osdl.org>
---

 25-akpm/net/sched/police.c   |    4 ++--
 25-akpm/net/sched/sch_gred.c |    4 ++--
 25-akpm/net/sched/sch_htb.c  |    6 +++---
 25-akpm/net/sched/sch_red.c  |    2 +-
 25-akpm/net/sched/sch_tbf.c  |    2 +-
 5 files changed, 9 insertions(+), 9 deletions(-)

diff -puN net/sched/police.c~pkt_sched-warning-fixes net/sched/police.c
--- 25/net/sched/police.c~pkt_sched-warning-fixes	2004-06-23 23:30:10.482605272 -0700
+++ 25-akpm/net/sched/police.c	2004-06-23 23:30:10.491603904 -0700
@@ -321,7 +321,7 @@ int tcf_act_police(struct sk_buff **pskb
 
 		PSCHED_GET_TIME(now);
 
-		toks = PSCHED_TDIFF_SAFE(now, p->t_c, p->burst, 0);
+		toks = PSCHED_TDIFF_SAFE(now, p->t_c, p->burst, (void)0);
 
 		if (p->P_tab) {
 			ptoks = toks + p->ptoks;
@@ -523,7 +523,7 @@ int tcf_police(struct sk_buff *skb, stru
 
 		PSCHED_GET_TIME(now);
 
-		toks = PSCHED_TDIFF_SAFE(now, p->t_c, p->burst, 0);
+		toks = PSCHED_TDIFF_SAFE(now, p->t_c, p->burst, (void)0);
 
 		if (p->P_tab) {
 			ptoks = toks + p->ptoks;
diff -puN net/sched/sch_gred.c~pkt_sched-warning-fixes net/sched/sch_gred.c
--- 25/net/sched/sch_gred.c~pkt_sched-warning-fixes	2004-06-23 23:30:10.483605120 -0700
+++ 25-akpm/net/sched/sch_gred.c	2004-06-23 23:30:10.492603752 -0700
@@ -155,7 +155,7 @@ gred_enqueue(struct sk_buff *skb, struct
 	if (!PSCHED_IS_PASTPERFECT(q->qidlestart)) {
 		long us_idle;
 		PSCHED_GET_TIME(now);
-		us_idle = PSCHED_TDIFF_SAFE(now, q->qidlestart, q->Scell_max, 0);
+		us_idle = PSCHED_TDIFF_SAFE(now, q->qidlestart, q->Scell_max, (void)0);
 		PSCHED_SET_PASTPERFECT(q->qidlestart);
 
 		q->qave >>= q->Stab[(us_idle>>q->Scell_log)&0xFF];
@@ -551,7 +551,7 @@ static int gred_dump(struct Qdisc *sch, 
 				long idle;
 				psched_time_t now;
 				PSCHED_GET_TIME(now);
-				idle = PSCHED_TDIFF_SAFE(now, q->qidlestart, q->Scell_max, 0);
+				idle = PSCHED_TDIFF_SAFE(now, q->qidlestart, q->Scell_max, (void)0);
 				qave  = q->qave >> q->Stab[(idle>>q->Scell_log)&0xFF];
 				dst->qave = qave >> q->Wlog;
 
diff -puN net/sched/sch_htb.c~pkt_sched-warning-fixes net/sched/sch_htb.c
--- 25/net/sched/sch_htb.c~pkt_sched-warning-fixes	2004-06-23 23:30:10.485604816 -0700
+++ 25-akpm/net/sched/sch_htb.c	2004-06-23 23:30:10.493603600 -0700
@@ -367,7 +367,7 @@ static void htb_debug_dump (struct htb_s
 		struct list_head *l;
 		list_for_each (l,q->hash+i) {
 			struct htb_class *cl = list_entry(l,struct htb_class,hlist);
-			long diff = PSCHED_TDIFF_SAFE(q->now, cl->t_c, (u32)cl->mbuffer, 0);
+			long diff = PSCHED_TDIFF_SAFE(q->now, cl->t_c, (u32)cl->mbuffer, (void)0);
 			printk(KERN_DEBUG "htb*c%x m=%d t=%ld c=%ld pq=%lu df=%ld ql=%d "
 					"pa=%x f:",
 				cl->classid,cl->cmode,cl->tokens,cl->ctokens,
@@ -807,7 +807,7 @@ static void htb_charge_class(struct htb_
 
 	while (cl) {
 		HTB_CHCL(cl);
-		diff = PSCHED_TDIFF_SAFE(q->now, cl->t_c, (u32)cl->mbuffer, 0);
+		diff = PSCHED_TDIFF_SAFE(q->now, cl->t_c, (u32)cl->mbuffer, (void)0);
 #ifdef HTB_DEBUG
 		if (diff > cl->mbuffer || diff < 0 || PSCHED_TLESS(q->now, cl->t_c)) {
 			if (net_ratelimit())
@@ -878,7 +878,7 @@ static long htb_do_events(struct htb_sch
 			return cl->pq_key - q->jiffies;
 		}
 		htb_safe_rb_erase(p,q->wait_pq+level);
-		diff = PSCHED_TDIFF_SAFE(q->now, cl->t_c, (u32)cl->mbuffer, 0);
+		diff = PSCHED_TDIFF_SAFE(q->now, cl->t_c, (u32)cl->mbuffer, (void)0);
 #ifdef HTB_DEBUG
 		if (diff > cl->mbuffer || diff < 0 || PSCHED_TLESS(q->now, cl->t_c)) {
 			if (net_ratelimit())
diff -puN net/sched/sch_red.c~pkt_sched-warning-fixes net/sched/sch_red.c
--- 25/net/sched/sch_red.c~pkt_sched-warning-fixes	2004-06-23 23:30:10.486604664 -0700
+++ 25-akpm/net/sched/sch_red.c	2004-06-23 23:30:10.494603448 -0700
@@ -189,7 +189,7 @@ red_enqueue(struct sk_buff *skb, struct 
 		int  shift;
 
 		PSCHED_GET_TIME(now);
-		us_idle = PSCHED_TDIFF_SAFE(now, q->qidlestart, q->Scell_max, 0);
+		us_idle = PSCHED_TDIFF_SAFE(now, q->qidlestart, q->Scell_max, (void)0);
 		PSCHED_SET_PASTPERFECT(q->qidlestart);
 
 /*
diff -puN net/sched/sch_tbf.c~pkt_sched-warning-fixes net/sched/sch_tbf.c
--- 25/net/sched/sch_tbf.c~pkt_sched-warning-fixes	2004-06-23 23:30:10.488604360 -0700
+++ 25-akpm/net/sched/sch_tbf.c	2004-06-23 23:30:10.494603448 -0700
@@ -207,7 +207,7 @@ static struct sk_buff *tbf_dequeue(struc
 
 		PSCHED_GET_TIME(now);
 
-		toks = PSCHED_TDIFF_SAFE(now, q->t_c, q->buffer, 0);
+		toks = PSCHED_TDIFF_SAFE(now, q->t_c, q->buffer, (void)0);
 
 		if (q->P_tab) {
 			ptoks = toks + q->ptokens;
_
