From: Patrick McHardy <kaber@trash.net>
Subject: [PATCH]: Fix tbf_reset
Date: Thu, 13 Nov 2003 15:47:44 +0100
Sender: netdev-bounce@oss.sgi.com
Message-ID: <3FB39990.3000205@trash.net>
Mime-Version: 1.0
Content-Type: multipart/mixed;
 boundary="------------070108000100030408000200"
Cc: netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: "David S. Miller" <davem@redhat.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

This is a multi-part message in MIME format.
--------------070108000100030408000200
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit

This patch fixes TBF purging an unused queue in tbf_reset instead
of resetting q.qlen. I haven't checked the history, but it looks
like this place was forgotten when making TBF classful.

Best regards,
Patrick


--------------070108000100030408000200
Content-Type: text/plain;
 name="02-tbf_reset.diff"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline;
 filename="02-tbf_reset.diff"

# This is a BitKeeper generated patch for the following project:
# Project Name: Linux kernel tree
# This patch format is intended for GNU patch command version 2.5 or higher.
# This patch includes the following deltas:
#	           ChangeSet	1.1428  -> 1.1429 
#	 net/sched/sch_tbf.c	1.11    -> 1.12   
#
# The following is the BitKeeper ChangeSet Log
# --------------------------------------------
# 03/11/12	kaber@trash.net	1.1429
# Reset q.qlen in tbf_reset instead of purging an unused queue
# --------------------------------------------
#
diff -Nru a/net/sched/sch_tbf.c b/net/sched/sch_tbf.c
--- a/net/sched/sch_tbf.c	Thu Nov 13 14:57:27 2003
+++ b/net/sched/sch_tbf.c	Thu Nov 13 14:57:27 2003
@@ -268,7 +268,7 @@
 	struct tbf_sched_data *q = (struct tbf_sched_data *)sch->data;
 
 	qdisc_reset(q->qdisc);
-	skb_queue_purge(&sch->q);
+	sch->q.qlen = 0;
 	sch->stats.backlog = 0;
 	PSCHED_GET_TIME(q->t_c);
 	q->tokens = q->buffer;

--------------070108000100030408000200--
