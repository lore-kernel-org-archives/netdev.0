From: Michal Soltys <soltys@ziu.info>
Subject: [net-next PATCH 5/5] net/sched/sch_hfsc.c: anchor virtual curve at proper vt in hfsc_change_fsc()
Date: Thu, 30 Jun 2016 02:26:48 +0200
Message-ID: <1467246408-913-6-git-send-email-soltys@ziu.info>
References: <1467246408-913-1-git-send-email-soltys@ziu.info>
Cc: netdev@vger.kernel.org, kaber@trash.net
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from drutsystem.com ([84.10.39.251]:50041 "EHLO drutsystem.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751491AbcF3A1b (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 29 Jun 2016 20:27:31 -0400
In-Reply-To: <1467246408-913-1-git-send-email-soltys@ziu.info>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

cl->cl_vt alone is relative only to the current backlog period, while
the curve operates on cumulative virtual time. This patch adds missing
cl->cl_vtoff.

Signed-off-by: Michal Soltys <soltys@ziu.info>
---
 net/sched/sch_hfsc.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/net/sched/sch_hfsc.c b/net/sched/sch_hfsc.c
index 4eef857..dff92ea 100644
--- a/net/sched/sch_hfsc.c
+++ b/net/sched/sch_hfsc.c
@@ -940,7 +940,7 @@ static void
 hfsc_change_fsc(struct hfsc_class *cl, struct tc_service_curve *fsc)
 {
 	sc2isc(fsc, &cl->cl_fsc);
-	rtsc_init(&cl->cl_virtual, &cl->cl_fsc, cl->cl_vt, cl->cl_total);
+	rtsc_init(&cl->cl_virtual, &cl->cl_fsc, cl->cl_vtoff + cl->cl_vt, cl->cl_total);
 	cl->cl_flags |= HFSC_FSC;
 }
 
-- 
2.1.3
