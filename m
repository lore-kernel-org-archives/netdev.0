From: Patrick McHardy <kaber@trash.net>
Subject: [PATCH PKT_SCHED 1/6]: Use rtattr_parse_nested where appropriate
Date: Tue, 11 Jan 2005 22:46:18 +0100
Message-ID: <41E4492A.8060601@trash.net>
Mime-Version: 1.0
Content-Type: multipart/mixed;
 boundary="------------090704050901070002070602"
Cc: Maillist netdev <netdev@oss.sgi.com>
Return-path: <netdev-bounce@oss.sgi.com>
To: "David S. Miller" <davem@davemloft.net>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

This is a multi-part message in MIME format.
--------------090704050901070002070602
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit



--------------090704050901070002070602
Content-Type: text/x-patch;
 name="01.diff"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline;
 filename="01.diff"

# This is a BitKeeper generated diff -Nru style patch.
#
# ChangeSet
#   2005/01/11 20:24:08+01:00 kaber@coreworks.de 
#   [PKT_SCHED]: Use rtattr_parse_nested where appropriate
#   
#   Signed-off-by: Patrick McHardy <kaber@trash.net>
# 
# net/sched/sch_tbf.c
#   2005/01/11 20:24:00+01:00 kaber@coreworks.de +1 -1
#   [PKT_SCHED]: Use rtattr_parse_nested where appropriate
#   
#   Signed-off-by: Patrick McHardy <kaber@trash.net>
# 
# net/sched/sch_red.c
#   2005/01/11 20:24:00+01:00 kaber@coreworks.de +1 -1
#   [PKT_SCHED]: Use rtattr_parse_nested where appropriate
#   
#   Signed-off-by: Patrick McHardy <kaber@trash.net>
# 
# net/sched/sch_htb.c
#   2005/01/11 20:24:00+01:00 kaber@coreworks.de +2 -2
#   [PKT_SCHED]: Use rtattr_parse_nested where appropriate
#   
#   Signed-off-by: Patrick McHardy <kaber@trash.net>
# 
# net/sched/sch_hfsc.c
#   2005/01/11 20:24:00+01:00 kaber@coreworks.de +1 -2
#   [PKT_SCHED]: Use rtattr_parse_nested where appropriate
#   
#   Signed-off-by: Patrick McHardy <kaber@trash.net>
# 
# net/sched/sch_gred.c
#   2005/01/11 20:24:00+01:00 kaber@coreworks.de +6 -9
#   [PKT_SCHED]: Use rtattr_parse_nested where appropriate
#   
#   Signed-off-by: Patrick McHardy <kaber@trash.net>
# 
# net/sched/sch_dsmark.c
#   2005/01/11 20:24:00+01:00 kaber@coreworks.de +1 -2
#   [PKT_SCHED]: Use rtattr_parse_nested where appropriate
#   
#   Signed-off-by: Patrick McHardy <kaber@trash.net>
# 
# net/sched/sch_cbq.c
#   2005/01/11 20:24:00+01:00 kaber@coreworks.de +2 -3
#   [PKT_SCHED]: Use rtattr_parse_nested where appropriate
#   
#   Signed-off-by: Patrick McHardy <kaber@trash.net>
# 
# net/sched/sch_atm.c
#   2005/01/11 20:24:00+01:00 kaber@coreworks.de +2 -2
#   [PKT_SCHED]: Use rtattr_parse_nested where appropriate
#   
#   Signed-off-by: Patrick McHardy <kaber@trash.net>
# 
# net/sched/police.c
#   2005/01/11 20:24:00+01:00 kaber@coreworks.de +2 -4
#   [PKT_SCHED]: Use rtattr_parse_nested where appropriate
#   
#   Signed-off-by: Patrick McHardy <kaber@trash.net>
# 
# net/sched/pedit.c
#   2005/01/11 20:24:00+01:00 kaber@coreworks.de +1 -2
#   [PKT_SCHED]: Use rtattr_parse_nested where appropriate
#   
#   Signed-off-by: Patrick McHardy <kaber@trash.net>
# 
# net/sched/mirred.c
#   2005/01/11 20:24:00+01:00 kaber@coreworks.de +1 -2
#   [PKT_SCHED]: Use rtattr_parse_nested where appropriate
#   
#   Signed-off-by: Patrick McHardy <kaber@trash.net>
# 
# net/sched/ipt.c
#   2005/01/11 20:24:00+01:00 kaber@coreworks.de +1 -2
#   [PKT_SCHED]: Use rtattr_parse_nested where appropriate
#   
#   Signed-off-by: Patrick McHardy <kaber@trash.net>
# 
# net/sched/gact.c
#   2005/01/11 20:24:00+01:00 kaber@coreworks.de +1 -2
#   [PKT_SCHED]: Use rtattr_parse_nested where appropriate
#   
#   Signed-off-by: Patrick McHardy <kaber@trash.net>
# 
# net/sched/act_api.c
#   2005/01/11 20:24:00+01:00 kaber@coreworks.de +5 -8
#   [PKT_SCHED]: Use rtattr_parse_nested where appropriate
#   
#   Signed-off-by: Patrick McHardy <kaber@trash.net>
# 
diff -Nru a/net/sched/act_api.c b/net/sched/act_api.c
--- a/net/sched/act_api.c	2005-01-11 22:32:05 +01:00
+++ b/net/sched/act_api.c	2005-01-11 22:32:05 +01:00
@@ -279,8 +279,7 @@
 	*err = -EINVAL;
 
 	if (name == NULL) {
-		if (rtattr_parse(tb, TCA_ACT_MAX, RTA_DATA(rta),
-		                 RTA_PAYLOAD(rta)) < 0)
+		if (rtattr_parse_nested(tb, TCA_ACT_MAX, rta) < 0)
 			goto err_out;
 		kind = tb[TCA_ACT_KIND-1];
 		if (kind == NULL)
@@ -344,8 +343,7 @@
 	struct tc_action *head = NULL, *act, *act_prev = NULL;
 	int i;
 
-	if (rtattr_parse(tb, TCA_ACT_MAX_PRIO, RTA_DATA(rta),
-	                 RTA_PAYLOAD(rta)) < 0) {
+	if (rtattr_parse_nested(tb, TCA_ACT_MAX_PRIO, rta) < 0) {
 		*err = -EINVAL;
 		return head;
 	}
@@ -467,7 +465,7 @@
 	int index;
 
 	*err = -EINVAL;
-	if (rtattr_parse(tb, TCA_ACT_MAX, RTA_DATA(rta), RTA_PAYLOAD(rta)) < 0)
+	if (rtattr_parse_nested(tb, TCA_ACT_MAX, rta) < 0)
 		return NULL;
 
 	if (tb[TCA_ACT_INDEX - 1] == NULL ||
@@ -552,7 +550,7 @@
 
 	b = (unsigned char *)skb->tail;
 
-	if (rtattr_parse(tb, TCA_ACT_MAX, RTA_DATA(rta), RTA_PAYLOAD(rta)) < 0)
+	if (rtattr_parse_nested(tb, TCA_ACT_MAX, rta) < 0)
 		goto err_out;
 
 	kind = tb[TCA_ACT_KIND-1];
@@ -599,8 +597,7 @@
 	struct rtattr *tb[TCA_ACT_MAX_PRIO+1];
 	struct tc_action *head = NULL, *act, *act_prev = NULL;
 
-	if (rtattr_parse(tb, TCA_ACT_MAX_PRIO, RTA_DATA(rta),
-	                 RTA_PAYLOAD(rta)) < 0)
+	if (rtattr_parse_nested(tb, TCA_ACT_MAX_PRIO, rta) < 0)
 		return -EINVAL;
 
 	if (event == RTM_DELACTION && n->nlmsg_flags&NLM_F_ROOT) {
diff -Nru a/net/sched/gact.c b/net/sched/gact.c
--- a/net/sched/gact.c	2005-01-11 22:32:05 +01:00
+++ b/net/sched/gact.c	2005-01-11 22:32:05 +01:00
@@ -79,8 +79,7 @@
 	struct tcf_gact *p;
 	int ret = 0;
 
-	if (rta == NULL ||
-	    rtattr_parse(tb, TCA_GACT_MAX, RTA_DATA(rta), RTA_PAYLOAD(rta)) < 0)
+	if (rta == NULL || rtattr_parse_nested(tb, TCA_GACT_MAX, rta) < 0)
 		return -EINVAL;
 
 	if (tb[TCA_GACT_PARMS - 1] == NULL ||
diff -Nru a/net/sched/ipt.c b/net/sched/ipt.c
--- a/net/sched/ipt.c	2005-01-11 22:32:05 +01:00
+++ b/net/sched/ipt.c	2005-01-11 22:32:05 +01:00
@@ -122,8 +122,7 @@
 	u32 hook = 0;
 	u32 index = 0;
 
-	if (rta == NULL ||
-	    rtattr_parse(tb, TCA_IPT_MAX, RTA_DATA(rta), RTA_PAYLOAD(rta)) < 0)
+	if (rta == NULL || rtattr_parse_nested(tb, TCA_IPT_MAX, rta) < 0)
 		return -EINVAL;
 
 	if (tb[TCA_IPT_HOOK-1] == NULL ||
diff -Nru a/net/sched/mirred.c b/net/sched/mirred.c
--- a/net/sched/mirred.c	2005-01-11 22:32:05 +01:00
+++ b/net/sched/mirred.c	2005-01-11 22:32:05 +01:00
@@ -84,8 +84,7 @@
 	int ret = 0;
 	int ok_push = 0;
 
-	if (rta == NULL || rtattr_parse(tb, TCA_MIRRED_MAX, RTA_DATA(rta),
-	                                RTA_PAYLOAD(rta)) < 0)
+	if (rta == NULL || rtattr_parse_nested(tb, TCA_MIRRED_MAX, rta) < 0)
 		return -EINVAL;
 
 	if (tb[TCA_MIRRED_PARMS-1] == NULL ||
diff -Nru a/net/sched/pedit.c b/net/sched/pedit.c
--- a/net/sched/pedit.c	2005-01-11 22:32:05 +01:00
+++ b/net/sched/pedit.c	2005-01-11 22:32:05 +01:00
@@ -63,8 +63,7 @@
 	struct tc_pedit_key *keys = NULL;
 	int ksize;
 
-	if (rta == NULL || rtattr_parse(tb, TCA_PEDIT_MAX, RTA_DATA(rta),
-	                                RTA_PAYLOAD(rta)) < 0)
+	if (rta == NULL || rtattr_parse_nested(tb, TCA_PEDIT_MAX, rta) < 0)
 		return -EINVAL;
 
 	if (tb[TCA_PEDIT_PARMS - 1] == NULL ||
diff -Nru a/net/sched/police.c b/net/sched/police.c
--- a/net/sched/police.c	2005-01-11 22:32:05 +01:00
+++ b/net/sched/police.c	2005-01-11 22:32:05 +01:00
@@ -171,8 +171,7 @@
 	struct tcf_police *p;
 	struct qdisc_rate_table *R_tab = NULL, *P_tab = NULL;
 
-	if (rta == NULL || rtattr_parse(tb, TCA_POLICE_MAX, RTA_DATA(rta),
-	                                RTA_PAYLOAD(rta)) < 0)
+	if (rta == NULL || rtattr_parse_nested(tb, TCA_POLICE_MAX, rta) < 0)
 		return -EINVAL;
 
 	if (tb[TCA_POLICE_TBF-1] == NULL ||
@@ -417,8 +416,7 @@
 	struct rtattr *tb[TCA_POLICE_MAX];
 	struct tc_police *parm;
 
-	if (rtattr_parse(tb, TCA_POLICE_MAX, RTA_DATA(rta),
-	                 RTA_PAYLOAD(rta)) < 0)
+	if (rtattr_parse_nested(tb, TCA_POLICE_MAX, rta) < 0)
 		return NULL;
 
 	if (tb[TCA_POLICE_TBF-1] == NULL ||
diff -Nru a/net/sched/sch_atm.c b/net/sched/sch_atm.c
--- a/net/sched/sch_atm.c	2005-01-11 22:32:05 +01:00
+++ b/net/sched/sch_atm.c	2005-01-11 22:32:05 +01:00
@@ -255,8 +255,8 @@
 	 * later.)
 	 */
 	if (flow) return -EBUSY;
-	if (opt == NULL || rtattr_parse(tb,TCA_ATM_MAX,RTA_DATA(opt),
-	    RTA_PAYLOAD(opt))) return -EINVAL;
+	if (opt == NULL || rtattr_parse_nested(tb, TCA_ATM_MAX, opt))
+		return -EINVAL;
 	if (!tb[TCA_ATM_FD-1] || RTA_PAYLOAD(tb[TCA_ATM_FD-1]) < sizeof(fd))
 		return -EINVAL;
 	fd = *(int *) RTA_DATA(tb[TCA_ATM_FD-1]);
diff -Nru a/net/sched/sch_cbq.c b/net/sched/sch_cbq.c
--- a/net/sched/sch_cbq.c	2005-01-11 22:32:05 +01:00
+++ b/net/sched/sch_cbq.c	2005-01-11 22:32:05 +01:00
@@ -1439,7 +1439,7 @@
 	struct rtattr *tb[TCA_CBQ_MAX];
 	struct tc_ratespec *r;
 
-	if (rtattr_parse(tb, TCA_CBQ_MAX, RTA_DATA(opt), RTA_PAYLOAD(opt)) < 0 ||
+	if (rtattr_parse_nested(tb, TCA_CBQ_MAX, opt) < 0 ||
 	    tb[TCA_CBQ_RTAB-1] == NULL || tb[TCA_CBQ_RATE-1] == NULL ||
 	    RTA_PAYLOAD(tb[TCA_CBQ_RATE-1]) < sizeof(struct tc_ratespec))
 		return -EINVAL;
@@ -1824,8 +1824,7 @@
 	struct cbq_class *parent;
 	struct qdisc_rate_table *rtab = NULL;
 
-	if (opt==NULL ||
-	    rtattr_parse(tb, TCA_CBQ_MAX, RTA_DATA(opt), RTA_PAYLOAD(opt)))
+	if (opt==NULL || rtattr_parse_nested(tb, TCA_CBQ_MAX, opt))
 		return -EINVAL;
 
 	if (tb[TCA_CBQ_OVL_STRATEGY-1] &&
diff -Nru a/net/sched/sch_dsmark.c b/net/sched/sch_dsmark.c
--- a/net/sched/sch_dsmark.c	2005-01-11 22:32:05 +01:00
+++ b/net/sched/sch_dsmark.c	2005-01-11 22:32:05 +01:00
@@ -125,8 +125,7 @@
 	    "arg 0x%lx\n",sch,p,classid,parent,*arg);
 	if (*arg > p->indices)
 		return -ENOENT;
-	if (!opt || rtattr_parse(tb, TCA_DSMARK_MAX, RTA_DATA(opt),
-				 RTA_PAYLOAD(opt)))
+	if (!opt || rtattr_parse_nested(tb, TCA_DSMARK_MAX, opt))
 		return -EINVAL;
 	if (tb[TCA_DSMARK_MASK-1]) {
 		if (!RTA_PAYLOAD(tb[TCA_DSMARK_MASK-1]))
diff -Nru a/net/sched/sch_gred.c b/net/sched/sch_gred.c
--- a/net/sched/sch_gred.c	2005-01-11 22:32:05 +01:00
+++ b/net/sched/sch_gred.c	2005-01-11 22:32:05 +01:00
@@ -332,13 +332,11 @@
 	struct rtattr *tb2[TCA_GRED_DPS];
 	int i;
 
-	if (opt == NULL ||
-		rtattr_parse(tb, TCA_GRED_STAB, RTA_DATA(opt), RTA_PAYLOAD(opt)) )
-			return -EINVAL;
+	if (opt == NULL || rtattr_parse_nested(tb, TCA_GRED_STAB, opt))
+		return -EINVAL;
 
 	if (tb[TCA_GRED_PARMS-1] == 0 && tb[TCA_GRED_STAB-1] == 0) {
-		rtattr_parse(tb2, TCA_GRED_DPS, RTA_DATA(opt),
-		    RTA_PAYLOAD(opt));
+		rtattr_parse_nested(tb2, TCA_GRED_DPS, opt);
 
 	    if (tb2[TCA_GRED_DPS-1] == 0) 
 			return -EINVAL;
@@ -475,12 +473,11 @@
 	struct rtattr *tb[TCA_GRED_STAB];
 	struct rtattr *tb2[TCA_GRED_DPS];
 
-	if (opt == NULL ||
-		rtattr_parse(tb, TCA_GRED_STAB, RTA_DATA(opt), RTA_PAYLOAD(opt)) )
-			return -EINVAL;
+	if (opt == NULL || rtattr_parse_nested(tb, TCA_GRED_STAB, opt))
+		return -EINVAL;
 
 	if (tb[TCA_GRED_PARMS-1] == 0 && tb[TCA_GRED_STAB-1] == 0) {
-		rtattr_parse(tb2, TCA_GRED_DPS, RTA_DATA(opt),RTA_PAYLOAD(opt));
+		rtattr_parse_nested(tb2, TCA_GRED_DPS, opt);
 
 	    if (tb2[TCA_GRED_DPS-1] == 0) 
 			return -EINVAL;
diff -Nru a/net/sched/sch_hfsc.c b/net/sched/sch_hfsc.c
--- a/net/sched/sch_hfsc.c	2005-01-11 22:32:05 +01:00
+++ b/net/sched/sch_hfsc.c	2005-01-11 22:32:05 +01:00
@@ -1046,8 +1046,7 @@
 	struct tc_service_curve *rsc = NULL, *fsc = NULL, *usc = NULL;
 	u64 cur_time;
 
-	if (opt == NULL ||
-	    rtattr_parse(tb, TCA_HFSC_MAX, RTA_DATA(opt), RTA_PAYLOAD(opt)))
+	if (opt == NULL || rtattr_parse_nested(tb, TCA_HFSC_MAX, opt))
 		return -EINVAL;
 
 	if (tb[TCA_HFSC_RSC-1]) {
diff -Nru a/net/sched/sch_htb.c b/net/sched/sch_htb.c
--- a/net/sched/sch_htb.c	2005-01-11 22:32:05 +01:00
+++ b/net/sched/sch_htb.c	2005-01-11 22:32:05 +01:00
@@ -1267,7 +1267,7 @@
 	printk(KERN_INFO "HTB init, kernel part version %d.%d\n",
 			  HTB_VER >> 16,HTB_VER & 0xffff);
 #endif
-	if (!opt || rtattr_parse(tb, TCA_HTB_INIT, RTA_DATA(opt), RTA_PAYLOAD(opt)) ||
+	if (!opt || rtattr_parse_nested(tb, TCA_HTB_INIT, opt) ||
 			tb[TCA_HTB_INIT-1] == NULL ||
 			RTA_PAYLOAD(tb[TCA_HTB_INIT-1]) < sizeof(*gopt)) {
 		printk(KERN_ERR "HTB: hey probably you have bad tc tool ?\n");
@@ -1559,7 +1559,7 @@
 	struct tc_htb_opt *hopt;
 
 	/* extract all subattrs from opt attr */
-	if (!opt || rtattr_parse(tb, TCA_HTB_RTAB, RTA_DATA(opt), RTA_PAYLOAD(opt)) ||
+	if (!opt || rtattr_parse_nested(tb, TCA_HTB_RTAB, opt) ||
 			tb[TCA_HTB_PARMS-1] == NULL ||
 			RTA_PAYLOAD(tb[TCA_HTB_PARMS-1]) < sizeof(*hopt))
 		goto failure;
diff -Nru a/net/sched/sch_red.c b/net/sched/sch_red.c
--- a/net/sched/sch_red.c	2005-01-11 22:32:05 +01:00
+++ b/net/sched/sch_red.c	2005-01-11 22:32:05 +01:00
@@ -364,7 +364,7 @@
 	struct tc_red_qopt *ctl;
 
 	if (opt == NULL ||
-	    rtattr_parse(tb, TCA_RED_STAB, RTA_DATA(opt), RTA_PAYLOAD(opt)) ||
+	    rtattr_parse_nested(tb, TCA_RED_STAB, opt) ||
 	    tb[TCA_RED_PARMS-1] == 0 || tb[TCA_RED_STAB-1] == 0 ||
 	    RTA_PAYLOAD(tb[TCA_RED_PARMS-1]) < sizeof(*ctl) ||
 	    RTA_PAYLOAD(tb[TCA_RED_STAB-1]) < 256)
diff -Nru a/net/sched/sch_tbf.c b/net/sched/sch_tbf.c
--- a/net/sched/sch_tbf.c	2005-01-11 22:32:05 +01:00
+++ b/net/sched/sch_tbf.c	2005-01-11 22:32:05 +01:00
@@ -310,7 +310,7 @@
 	struct Qdisc *child = NULL;
 	int max_size,n;
 
-	if (rtattr_parse(tb, TCA_TBF_PTAB, RTA_DATA(opt), RTA_PAYLOAD(opt)) ||
+	if (rtattr_parse_nested(tb, TCA_TBF_PTAB, opt) ||
 	    tb[TCA_TBF_PARMS-1] == NULL ||
 	    RTA_PAYLOAD(tb[TCA_TBF_PARMS-1]) < sizeof(*qopt))
 		goto done;

--------------090704050901070002070602--
