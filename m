From: Dmitry Torokhov <dtor_core@ameritech.net>
Subject: [PATCH 1/2 (resend)] Fix TBF class reporting (tc class show)
Date: Tue, 23 Mar 2004 01:08:08 -0500
Sender: linux-net-owner@vger.kernel.org
Message-ID: <200403230108.08384.dtor_core@ameritech.net>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: netdev@oss.sgi.com
Return-path: <linux-net-owner@vger.kernel.org>
To: linux-net@vger.kernel.org
Content-Disposition: inline
List-Id: netdev.vger.kernel.org

Hi,

The patch below fixes issue with "tc class show dev <dev>" not showing any
classes when TBF qdisc is present in the chain. PLease copnsider for
inclusion.

-- 
Dmitry


===================================================================


ChangeSet@1.1648, 2004-03-05 01:02:36-05:00, dtor_core@ameritech.net
  NET: Fix class reporting in TBF qdisc


 sch_tbf.c |    9 +++------
 1 files changed, 3 insertions(+), 6 deletions(-)


===================================================================



diff -Nru a/net/sched/sch_tbf.c b/net/sched/sch_tbf.c
--- a/net/sched/sch_tbf.c	Fri Mar  5 01:26:33 2004
+++ b/net/sched/sch_tbf.c	Fri Mar  5 01:26:33 2004
@@ -434,8 +434,7 @@
 	if (cl != 1) 	/* only one class */ 
 		return -ENOENT;
     
-	tcm->tcm_parent = TC_H_ROOT;
-	tcm->tcm_handle = 1;
+	tcm->tcm_handle |= TC_H_MIN(1);
 	tcm->tcm_info = q->qdisc->handle;
 
 	return 0;
@@ -486,11 +485,9 @@
 
 static void tbf_walk(struct Qdisc *sch, struct qdisc_walker *walker)
 {
-	struct tbf_sched_data *q = (struct tbf_sched_data *)sch->data;
-
 	if (!walker->stop) {
-		if (walker->count >= walker->skip) 
-			if (walker->fn(sch, (unsigned long)q, walker) < 0) { 
+		if (walker->count >= walker->skip)
+			if (walker->fn(sch, 1, walker) < 0) {
 				walker->stop = 1;
 				return;
 			}
