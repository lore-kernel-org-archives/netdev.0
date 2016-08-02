From: Michal Soltys <soltys@ziu.info>
Subject: [PATCH net-next v2 2/2] net/sched/sch_hfsc.c: remove unused cl_myfadj
Date: Wed,  3 Aug 2016 00:44:55 +0200
Message-ID: <1470177895-2453-3-git-send-email-soltys@ziu.info>
References: <1470177895-2453-1-git-send-email-soltys@ziu.info>
Cc: kaber@trash.net, netdev@vger.kernel.org
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from drutsystem.com ([84.10.39.251]:33262 "EHLO drutsystem.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754758AbcHBWpt (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 2 Aug 2016 18:45:49 -0400
In-Reply-To: <1470177895-2453-1-git-send-email-soltys@ziu.info>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The code using this variable has been commented out in the past as it
was causing issues in upperlimited link-sharing scenarios.

Signed-off-by: Michal Soltys <soltys@ziu.info>
---
 net/sched/sch_hfsc.c | 7 ++-----
 1 file changed, 2 insertions(+), 5 deletions(-)

diff --git a/net/sched/sch_hfsc.c b/net/sched/sch_hfsc.c
index 6329d7d..000f1d3 100644
--- a/net/sched/sch_hfsc.c
+++ b/net/sched/sch_hfsc.c
@@ -142,8 +142,6 @@ struct hfsc_class {
 					   link-sharing, max(myf, cfmin) */
 	u64	cl_myf;			/* my fit-time (calculated from this
 					   class's own upperlimit curve) */
-	u64	cl_myfadj;		/* my fit-time adjustment (to cancel
-					   history dependence) */
 	u64	cl_cfmin;		/* earliest children's fit-time (used
 					   with cl_myf to obtain cl_f) */
 	u64	cl_cvtmin;		/* minimal virtual time among the
@@ -730,7 +728,6 @@ init_vf(struct hfsc_class *cl, unsigned int len)
 				/* compute myf */
 				cl->cl_myf = rtsc_y2x(&cl->cl_ulimit,
 						      cl->cl_total);
-				cl->cl_myfadj = 0;
 			}
 		}
 
@@ -797,9 +794,10 @@ update_vf(struct hfsc_class *cl, unsigned int len, u64 cur_time)
 
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
@@ -1471,7 +1469,6 @@ hfsc_reset_class(struct hfsc_class *cl)
 	cl->cl_parentperiod = 0;
 	cl->cl_f            = 0;
 	cl->cl_myf          = 0;
-	cl->cl_myfadj       = 0;
 	cl->cl_cfmin        = 0;
 	cl->cl_nactive      = 0;
 
-- 
2.1.3
