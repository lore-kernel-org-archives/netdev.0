From: Patrick McHardy <kaber@trash.net>
Subject: [PATCH PKT_SCHED 15/17]: Remove checks for impossible conditions
 in pedit action
Date: Thu, 30 Dec 2004 04:41:01 +0100
Message-ID: <41D378CD.9090407@trash.net>
Mime-Version: 1.0
Content-Type: multipart/mixed;
 boundary="------------060903040607030803060503"
Cc: Maillist netdev <netdev@oss.sgi.com>
Return-path: <netdev-bounce@oss.sgi.com>
To: jamal <hadi@cyberus.ca>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

This is a multi-part message in MIME format.
--------------060903040607030803060503
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit

Remove checks for impossible conditions in pedit action.


--------------060903040607030803060503
Content-Type: text/x-patch;
 name="15.diff"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline;
 filename="15.diff"

# This is a BitKeeper generated diff -Nru style patch.
#
# ChangeSet
#   2004/12/30 03:47:30+01:00 kaber@coreworks.de 
#   [PKT_SCHED]: Remove checks for impossible conditions in pedit action
#   
#   Signed-off-by: Patrick McHardy <kaber@trash.net>
# 
# net/sched/pedit.c
#   2004/12/30 03:47:24+01:00 kaber@coreworks.de +1 -11
#   [PKT_SCHED]: Remove checks for impossible conditions in pedit action
#   
#   Signed-off-by: Patrick McHardy <kaber@trash.net>
# 
diff -Nru a/net/sched/pedit.c b/net/sched/pedit.c
--- a/net/sched/pedit.c	2004-12-30 04:02:01 +01:00
+++ b/net/sched/pedit.c	2004-12-30 04:02:01 +01:00
@@ -65,7 +65,7 @@
 
 	if (rtattr_parse(tb, TCA_PEDIT_MAX, RTA_DATA(rta), RTA_PAYLOAD(rta)) < 0)
 		return -1;
-	if (a == NULL || tb[TCA_PEDIT_PARMS - 1] == NULL) {
+	if (tb[TCA_PEDIT_PARMS - 1] == NULL) {
 		printk("BUG: tcf_pedit_init called with NULL params\n");
 		return -1;
 	}
@@ -113,11 +113,6 @@
 	int i, munged = 0;
 	u8 *pptr;
 
-	if (p == NULL) {
-		printk("BUG: tcf_pedit called with NULL params\n");
-		return -1; /* change to something symbolic */
-	}
-
 	if (!(skb->tc_verd & TC_OK2MUNGE)) {
 		/* should we set skb->cloned? */
 		if (pskb_expand_head(skb, 0, 0, GFP_ATOMIC)) {
@@ -189,11 +184,6 @@
 	struct tcf_t t;
 	int s; 
 		
-	if (p == NULL) {
-		printk("BUG: tcf_pedit_dump called with NULL params\n");
-		goto rtattr_failure;
-	}
-
 	s = sizeof(*opt) + p->nkeys * sizeof(struct tc_pedit_key);
 
 	/* netlink spinlocks held above us - must use ATOMIC */

--------------060903040607030803060503--
