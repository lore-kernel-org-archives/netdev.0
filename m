From: Michal Soltys <soltys@ziu.info>
Subject: [PATCH 04/11] sch_hfsc.c: remove initial check in vttree_get_minvt() (optional)
Date: Sat,  5 Nov 2011 03:32:50 +0100
Message-ID: <1320460377-8682-5-git-send-email-soltys@ziu.info>
References: <1320460377-8682-1-git-send-email-soltys@ziu.info>
Cc: davem@davemloft.net, netdev@vger.kernel.org
To: kaber@trash.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from tha.ppgk.com.pl ([77.252.116.179]:15225 "EHLO tha.ppgk.com.pl"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753426Ab1KECdJ (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 4 Nov 2011 22:33:09 -0400
In-Reply-To: <1320460377-8682-1-git-send-email-soltys@ziu.info>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Remove initial check in vttree_get_minvt(), as it's implicitly
handled by vttree_firstfit().

Also see:
http://marc.info/?l=linux-netdev&m=128457329614914&w=2

Signed-off-by: Michal Soltys <soltys@ziu.info>
---
 net/sched/sch_hfsc.c |    4 ----
 1 files changed, 0 insertions(+), 4 deletions(-)

diff --git a/net/sched/sch_hfsc.c b/net/sched/sch_hfsc.c
index 710cbda..97d720c 100644
--- a/net/sched/sch_hfsc.c
+++ b/net/sched/sch_hfsc.c
@@ -307,10 +307,6 @@ vttree_firstfit(struct hfsc_class *cl, u64 cur_time)
 static struct hfsc_class *
 vttree_get_minvt(struct hfsc_class *cl, u64 cur_time)
 {
-	/* if root-class's cfmin is bigger than cur_time nothing to do */
-	if (cl->cl_cfmin > cur_time)
-		return NULL;
-
 	while (cl->level > 0) {
 		cl = vttree_firstfit(cl, cur_time);
 		if (cl == NULL)
-- 
1.7.7.1
