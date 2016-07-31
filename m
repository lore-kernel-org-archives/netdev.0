From: Michal Soltys <soltys@ziu.info>
Subject: [PATCH 2/2] net/sched/sch_hfsc.c: comment out cl_myfadj
Date: Mon,  1 Aug 2016 01:03:59 +0200
Message-ID: <1470006239-20299-3-git-send-email-soltys@ziu.info>
References: <1470006239-20299-1-git-send-email-soltys@ziu.info>
Cc: kaber@trash.net, netdev@vger.kernel.org
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from drutsystem.com ([84.10.39.251]:36828 "EHLO drutsystem.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751661AbcGaXF5 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sun, 31 Jul 2016 19:05:57 -0400
In-Reply-To: <1470006239-20299-1-git-send-email-soltys@ziu.info>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The part of the code using it is commented out, so the needless use
of this variable can be commented out as well.

Signed-off-by: Michal Soltys <soltys@ziu.info>
---
 net/sched/sch_hfsc.c | 12 +++++++++++-
 1 file changed, 11 insertions(+), 1 deletion(-)

diff --git a/net/sched/sch_hfsc.c b/net/sched/sch_hfsc.c
index 6329d7d..99ddc38 100644
--- a/net/sched/sch_hfsc.c
+++ b/net/sched/sch_hfsc.c
@@ -142,8 +142,11 @@ struct hfsc_class {
 					   link-sharing, max(myf, cfmin) */
 	u64	cl_myf;			/* my fit-time (calculated from this
 					   class's own upperlimit curve) */
+#if 0
+/* code using cl_myfadj is disabled */
 	u64	cl_myfadj;		/* my fit-time adjustment (to cancel
 					   history dependence) */
+#endif
 	u64	cl_cfmin;		/* earliest children's fit-time (used
 					   with cl_myf to obtain cl_f) */
 	u64	cl_cvtmin;		/* minimal virtual time among the
@@ -730,7 +733,10 @@ init_vf(struct hfsc_class *cl, unsigned int len)
 				/* compute myf */
 				cl->cl_myf = rtsc_y2x(&cl->cl_ulimit,
 						      cl->cl_total);
+#if 0
+/* code using cl_myfadj is disabled */
 				cl->cl_myfadj = 0;
+#endif
 			}
 		}
 
@@ -797,9 +803,10 @@ update_vf(struct hfsc_class *cl, unsigned int len, u64 cur_time)
 
 		/* update f */
 		if (cl->cl_flags & HFSC_USC) {
+			cl->cl_myf = rtsc_y2x(&cl->cl_ulimit, cl->cl_total);
+#if 0
 			cl->cl_myf = cl->cl_myfadj + rtsc_y2x(&cl->cl_ulimit,
 							      cl->cl_total);
-#if 0
 			/*
 			 * This code causes classes to stay way under their
 			 * limit when multiple classes are used at gigabit
@@ -1471,7 +1478,10 @@ hfsc_reset_class(struct hfsc_class *cl)
 	cl->cl_parentperiod = 0;
 	cl->cl_f            = 0;
 	cl->cl_myf          = 0;
+#if 0
+/* code using cl_myfadj is disabled */
 	cl->cl_myfadj       = 0;
+#endif
 	cl->cl_cfmin        = 0;
 	cl->cl_nactive      = 0;
 
-- 
2.1.3
