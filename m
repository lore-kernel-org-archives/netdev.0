From: Patrick McHardy <kaber@trash.net>
Subject: [PATCH PKT_SCHED 16/17]: Return proper error codes in tcf_pedit_init
Date: Thu, 30 Dec 2004 04:41:09 +0100
Message-ID: <41D378D5.9040406@trash.net>
Mime-Version: 1.0
Content-Type: multipart/mixed;
 boundary="------------040500050206060209080109"
Cc: Maillist netdev <netdev@oss.sgi.com>
Return-path: <netdev-bounce@oss.sgi.com>
To: jamal <hadi@cyberus.ca>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

This is a multi-part message in MIME format.
--------------040500050206060209080109
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit

Return proper error codes in tcf_pedit_init.


--------------040500050206060209080109
Content-Type: text/x-patch;
 name="16.diff"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline;
 filename="16.diff"

# This is a BitKeeper generated diff -Nru style patch.
#
# ChangeSet
#   2004/12/30 03:52:40+01:00 kaber@coreworks.de 
#   [PKT_SCHED]: Return proper error codes in tcf_pedit_init
#   
#   Signed-off-by: Patrick McHardy <kaber@trash.net>
# 
# net/sched/pedit.c
#   2004/12/30 03:52:34+01:00 kaber@coreworks.de +7 -7
#   [PKT_SCHED]: Return proper error codes in tcf_pedit_init
#   
#   Signed-off-by: Patrick McHardy <kaber@trash.net>
# 
diff -Nru a/net/sched/pedit.c b/net/sched/pedit.c
--- a/net/sched/pedit.c	2004-12-30 04:02:05 +01:00
+++ b/net/sched/pedit.c	2004-12-30 04:02:05 +01:00
@@ -64,26 +64,26 @@
 	struct tcf_pedit *p;
 
 	if (rtattr_parse(tb, TCA_PEDIT_MAX, RTA_DATA(rta), RTA_PAYLOAD(rta)) < 0)
-		return -1;
-	if (tb[TCA_PEDIT_PARMS - 1] == NULL) {
-		printk("BUG: tcf_pedit_init called with NULL params\n");
-		return -1;
-	}
+		return -EINVAL;
+	if (tb[TCA_PEDIT_PARMS - 1] == NULL)
+		return -EINVAL;
 
 	parm = RTA_DATA(tb[TCA_PEDIT_PARMS - 1]);
 	p = tcf_hash_check(parm, a, ovr, bind);
 	if (p == NULL) { /* new */
 		if (!parm->nkeys)
-			return -1;
+			return -EINVAL;
 		size = sizeof(*p) + parm->nkeys * sizeof(struct tc_pedit_key);
 		p = tcf_hash_create(parm, est, a, size, ovr, bind);
 		if (p == NULL)
-			return -1;
+			return -ENOMEM;
 		ret = 1;
 		goto override;
 	} 
 
+	ret = -EEXIST;
 	if (ovr) {
+		ret = 0;
 override:
 		p->flags = parm->flags;
 		p->nkeys = parm->nkeys;

--------------040500050206060209080109--
