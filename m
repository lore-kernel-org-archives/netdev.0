From: Patrick McHardy <kaber@trash.net>
Subject: [PATCH PKT_SCHED 9/17]: Return -EOPNOTSUPP if gact probability is
 requested but not compiled in
Date: Thu, 30 Dec 2004 04:40:12 +0100
Message-ID: <41D3789C.3040705@trash.net>
Mime-Version: 1.0
Content-Type: multipart/mixed;
 boundary="------------050707060508060702040603"
Cc: Maillist netdev <netdev@oss.sgi.com>
Return-path: <netdev-bounce@oss.sgi.com>
To: jamal <hadi@cyberus.ca>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

This is a multi-part message in MIME format.
--------------050707060508060702040603
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit

Return -EOPNOTSUPP if gact probability is requested but not compiled in.


--------------050707060508060702040603
Content-Type: text/x-patch;
 name="09.diff"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline;
 filename="09.diff"

# This is a BitKeeper generated diff -Nru style patch.
#
# ChangeSet
#   2004/12/30 02:34:11+01:00 kaber@coreworks.de 
#   [PKT_SCHED]: Return -EOPNOTSUPP if gact probability is requested but not compiled in
#   
#   Signed-off-by: Patrick McHardy <kaber@trash.net>
# 
# net/sched/gact.c
#   2004/12/30 02:34:04+01:00 kaber@coreworks.de +3 -1
#   [PKT_SCHED]: Return -EOPNOTSUPP if gact probability is requested but not compiled in
#   
#   Signed-off-by: Patrick McHardy <kaber@trash.net>
# 
diff -Nru a/net/sched/gact.c b/net/sched/gact.c
--- a/net/sched/gact.c	2004-12-30 04:01:33 +01:00
+++ b/net/sched/gact.c	2004-12-30 04:01:33 +01:00
@@ -88,9 +88,11 @@
 		return -EINVAL;
 
 	parm = RTA_DATA(tb[TCA_GACT_PARMS - 1]);
-#ifdef CONFIG_GACT_PROB
 	if (tb[TCA_GACT_PROB - 1] != NULL)
+#ifdef CONFIG_GACT_PROB
 		p_parm = RTA_DATA(tb[TCA_GACT_PROB - 1]);
+#else
+		return -EOPNOTSUPP;
 #endif
 	p = tcf_hash_check(parm, a, ovr, bind);
 	if (p == NULL) {

--------------050707060508060702040603--
