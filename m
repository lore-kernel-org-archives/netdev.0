From: Patrick McHardy <kaber@trash.net>
Subject: [PATCH PKT_SCHED 11/17]: Remove checks for impossible conditions
 in ipt action
Date: Thu, 30 Dec 2004 04:40:27 +0100
Message-ID: <41D378AB.70204@trash.net>
Mime-Version: 1.0
Content-Type: multipart/mixed;
 boundary="------------000506070304060700050205"
Cc: Maillist netdev <netdev@oss.sgi.com>
Return-path: <netdev-bounce@oss.sgi.com>
To: jamal <hadi@cyberus.ca>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

This is a multi-part message in MIME format.
--------------000506070304060700050205
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit

Remove checks for impossible conditions in ipt action, same as for gact.


--------------000506070304060700050205
Content-Type: text/x-patch;
 name="11.diff"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline;
 filename="11.diff"

# This is a BitKeeper generated diff -Nru style patch.
#
# ChangeSet
#   2004/12/30 02:52:02+01:00 kaber@coreworks.de 
#   [PKT_SCHED]: Remove checks for impossible conditions in ipt action
#   
#   Signed-off-by: Patrick McHardy <kaber@trash.net>
# 
# net/sched/ipt.c
#   2004/12/30 02:51:56+01:00 kaber@coreworks.de +1 -9
#   [PKT_SCHED]: Remove checks for impossible conditions in ipt action
#   
#   Signed-off-by: Patrick McHardy <kaber@trash.net>
# 
diff -Nru a/net/sched/ipt.c b/net/sched/ipt.c
--- a/net/sched/ipt.c	2004-12-30 04:01:42 +01:00
+++ b/net/sched/ipt.c	2004-12-30 04:01:42 +01:00
@@ -104,8 +104,7 @@
 	u32 index = 0;
 	u32 hook = 0;
 
-	if (a == NULL || rta == NULL ||
-	    rtattr_parse(tb, TCA_IPT_MAX, RTA_DATA(rta), RTA_PAYLOAD(rta)) < 0)
+	if (rtattr_parse(tb, TCA_IPT_MAX, RTA_DATA(rta), RTA_PAYLOAD(rta)) < 0)
 		return -1;
 
 	if (tb[TCA_IPT_INDEX - 1]) {
@@ -243,9 +242,6 @@
 	struct tcf_ipt *p = PRIV(a, ipt);
 	struct sk_buff *skb = *pskb;
 
-	if (p == NULL || skb == NULL)
-		return -1;
-
 	spin_lock(&p->lock);
 
 	p->tm.lastuse = jiffies;
@@ -293,10 +289,6 @@
 	unsigned char *b = skb->tail;
 	struct tcf_ipt *p = PRIV(a, ipt);
 
-	if (p == NULL) {
-		printk("BUG: tcf_ipt_dump called with NULL params\n");
-		goto rtattr_failure;
-	}
 	/* for simple targets kernel size == user size
 	** user name = target name
 	** for foolproof you need to not assume this

--------------000506070304060700050205--
