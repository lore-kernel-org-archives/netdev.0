From: Patrick McHardy <kaber@trash.net>
Subject: [PATCH]: Check for leaf-class when classifying by priority
Date: Thu, 13 Nov 2003 16:00:50 +0100
Sender: netdev-bounce@oss.sgi.com
Message-ID: <3FB39CA2.401@trash.net>
Mime-Version: 1.0
Content-Type: multipart/mixed;
 boundary="------------050003080006020806060808"
Cc: netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Martin Devera <devik@cdi.cz>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

This is a multi-part message in MIME format.
--------------050003080006020806060808
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit

Hi devik,

this patch makes htb_classify check if a class is a leaf when classifying
by priority. It also adds a check from cbq to skip htb_find if the majors
of skb->priority and sch->handle differ.

Best regards,
Patrick


--------------050003080006020806060808
Content-Type: text/plain;
 name="htb-classify.diff"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline;
 filename="htb-classify.diff"

# This is a BitKeeper generated patch for the following project:
# Project Name: Linux kernel tree
# This patch format is intended for GNU patch command version 2.5 or higher.
# This patch includes the following deltas:
#	           ChangeSet	1.1430  -> 1.1431 
#	 net/sched/sch_htb.c	1.15    -> 1.16   
#
# The following is the BitKeeper ChangeSet Log
# --------------------------------------------
# 03/11/12	kaber@trash.net	1.1431
# Check for leaf-class when classifying by priority, don't try if majors differ
# --------------------------------------------
#
diff -Nru a/net/sched/sch_htb.c b/net/sched/sch_htb.c
--- a/net/sched/sch_htb.c	Thu Nov 13 15:52:28 2003
+++ b/net/sched/sch_htb.c	Thu Nov 13 15:52:28 2003
@@ -303,8 +303,10 @@
 	   rules in it */
 	if (skb->priority == sch->handle)
 		return HTB_DIRECT;  /* X:0 (direct flow) selected */
-	if ((cl = htb_find(skb->priority,sch)) != NULL) 
-		return cl;
+	if (TC_H_MAJ(skb->priority^sch->handle) == 0 &&
+	    (cl = htb_find(skb->priority,sch)) != NULL) 
+		if (cl->level == 0)
+			return cl;
 
 	tcf = q->filter_list;
 	while (tcf && (result = tc_classify(skb, tcf, &res)) >= 0) {

--------------050003080006020806060808--
