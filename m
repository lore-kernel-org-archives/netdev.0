From: Patrick McHardy <kaber@trash.net>
Subject: [PATCH PKT_SCHED 8/17]: Return proper error codes in tcf_gact_init
Date: Thu, 30 Dec 2004 04:40:05 +0100
Message-ID: <41D37895.4010801@trash.net>
Mime-Version: 1.0
Content-Type: multipart/mixed;
 boundary="------------050808070300080804000405"
Cc: Maillist netdev <netdev@oss.sgi.com>
Return-path: <netdev-bounce@oss.sgi.com>
To: jamal <hadi@cyberus.ca>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

This is a multi-part message in MIME format.
--------------050808070300080804000405
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit

Return proper error codes in tcf_gact_init.


--------------050808070300080804000405
Content-Type: text/x-patch;
 name="08.diff"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline;
 filename="08.diff"

# This is a BitKeeper generated diff -Nru style patch.
#
# ChangeSet
#   2004/12/30 02:29:53+01:00 kaber@coreworks.de 
#   [PKT_SCHED]: Return proper error codes in tcf_gact_init
#   
#   Signed-off-by: Patrick McHardy <kaber@trash.net>
# 
# net/sched/gact.c
#   2004/12/30 02:29:47+01:00 kaber@coreworks.de +4 -7
#   [PKT_SCHED]: Return proper error codes in tcf_gact_init
#   
#   Signed-off-by: Patrick McHardy <kaber@trash.net>
# 
diff -Nru a/net/sched/gact.c b/net/sched/gact.c
--- a/net/sched/gact.c	2004-12-30 04:01:28 +01:00
+++ b/net/sched/gact.c	2004-12-30 04:01:28 +01:00
@@ -83,12 +83,9 @@
 	int ret = 0;
 
 	if (rtattr_parse(tb, TCA_GACT_MAX, RTA_DATA(rta), RTA_PAYLOAD(rta)) < 0)
-		return -1;
-
-	if (tb[TCA_GACT_PARMS - 1] == NULL) {
-		printk("BUG: tcf_gact_init called with NULL params\n");
-		return -1;
-	}
+		return -EINVAL;
+	if (tb[TCA_GACT_PARMS - 1] == NULL)
+		return -EINVAL;
 
 	parm = RTA_DATA(tb[TCA_GACT_PARMS - 1]);
 #ifdef CONFIG_GACT_PROB
@@ -99,7 +96,7 @@
 	if (p == NULL) {
 		p = tcf_hash_create(parm, est, a, sizeof(*p), ovr, bind);
 		if (p == NULL)
-			return -1;
+			return -ENOMEM;
 		else {
 			p->refcnt = 1;
 			ret = 1;

--------------050808070300080804000405--
