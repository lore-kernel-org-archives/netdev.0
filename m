From: Patrick McHardy <kaber@trash.net>
Subject: [PATCH PKT_SCHED 7/17]: Remove checks for impossible conditions in
 gact action
Date: Thu, 30 Dec 2004 04:39:59 +0100
Message-ID: <41D3788F.7030501@trash.net>
Mime-Version: 1.0
Content-Type: multipart/mixed;
 boundary="------------060603020807000000040607"
Cc: Maillist netdev <netdev@oss.sgi.com>
Return-path: <netdev-bounce@oss.sgi.com>
To: jamal <hadi@cyberus.ca>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

This is a multi-part message in MIME format.
--------------060603020807000000040607
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit

a->priv can only be NULL in tcf_gact_cleanup, everything else _is_
a bug, so let's just crash so we get a backtrace.


--------------060603020807000000040607
Content-Type: text/x-patch;
 name="07.diff"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline;
 filename="07.diff"

# This is a BitKeeper generated diff -Nru style patch.
#
# ChangeSet
#   2004/12/30 02:25:13+01:00 kaber@coreworks.de 
#   [PKT_SCHED]: Remove checks for impossible conditions in gact action
#   
#   a->priv can only be NULL in tcf_gact_cleanup, everything else _is_ a
#   bug, so let's just crash so we get a backtrace.
#   
#   Signed-off-by: Patrick McHardy <kaber@trash.net>
#   
# 
# net/sched/gact.c
#   2004/12/30 02:25:07+01:00 kaber@coreworks.de +1 -12
#   [PKT_SCHED]: Remove checks for impossible conditions in gact action
#   
#   a->priv can only be NULL in tcf_gact_cleanup, everything else _is_ a
#   bug, so let's just crash so we get a backtrace.
#   
#   Signed-off-by: Patrick McHardy <kaber@trash.net>
#   
# 
diff -Nru a/net/sched/gact.c b/net/sched/gact.c
--- a/net/sched/gact.c	2004-12-30 04:01:24 +01:00
+++ b/net/sched/gact.c	2004-12-30 04:01:24 +01:00
@@ -85,7 +85,7 @@
 	if (rtattr_parse(tb, TCA_GACT_MAX, RTA_DATA(rta), RTA_PAYLOAD(rta)) < 0)
 		return -1;
 
-	if (a == NULL || tb[TCA_GACT_PARMS - 1] == NULL) {
+	if (tb[TCA_GACT_PARMS - 1] == NULL) {
 		printk("BUG: tcf_gact_init called with NULL params\n");
 		return -1;
 	}
@@ -140,12 +140,6 @@
 	struct sk_buff *skb = *pskb;
 	int action = TC_ACT_SHOT;
 
-	if (p == NULL) {
-		if (net_ratelimit())
-			printk("BUG: tcf_gact called with NULL params\n");
-		return -1;
-	}
-
 	spin_lock(&p->lock);
 #ifdef CONFIG_GACT_PROB
 	if (p->ptype && gact_rand[p->ptype] != NULL)
@@ -175,11 +169,6 @@
 #endif
 	struct tcf_gact *p = PRIV(a, gact);
 	struct tcf_t t;
-
-	if (p == NULL) {
-		printk("BUG: tcf_gact_dump called with NULL params\n");
-		goto rtattr_failure;
-	}
 
 	opt.index = p->index;
 	opt.refcnt = p->refcnt - ref;

--------------060603020807000000040607--
