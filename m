From: Daniel Borkmann <daniel@iogearbox.net>
Subject: [PATCH net-next] net: sched: don't break line in tc_classify loop notification
Date: Fri, 28 Aug 2015 18:46:39 +0200
Message-ID: <4b24d2566b1877613540f277e60673c817b71842.1440780286.git.daniel@iogearbox.net>
Cc: ast@plumgrid.com, netdev@vger.kernel.org,
	Daniel Borkmann <daniel@iogearbox.net>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from www62.your-server.de ([213.133.104.62]:37218 "EHLO
	www62.your-server.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752182AbbH1Qqm (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 28 Aug 2015 12:46:42 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Just some minor noise follow-up to address some stylistic issues of
commit 3b3ae880266d ("net: sched: consolidate tc_classify{,_compat}").
Accidentally v1 instead of v2 of that commit got applied, so this
patch adds the relative diff.

Suggested-by: Alexei Starovoitov <ast@plumgrid.com>
Signed-off-by: Daniel Borkmann <daniel@iogearbox.net>
---
 net/sched/sch_api.c | 9 ++++-----
 1 file changed, 4 insertions(+), 5 deletions(-)

diff --git a/net/sched/sch_api.c b/net/sched/sch_api.c
index a3c70a1..f43c8f3 100644
--- a/net/sched/sch_api.c
+++ b/net/sched/sch_api.c
@@ -1825,8 +1825,7 @@ reclassify:
 
 		err = tp->classify(skb, tp, res);
 #ifdef CONFIG_NET_CLS_ACT
-		if (unlikely(err == TC_ACT_RECLASSIFY &&
-			     !compat_mode))
+		if (unlikely(err == TC_ACT_RECLASSIFY && !compat_mode))
 			goto reset;
 #endif
 		if (err >= 0)
@@ -1837,9 +1836,9 @@ reclassify:
 #ifdef CONFIG_NET_CLS_ACT
 reset:
 	if (unlikely(limit++ >= MAX_REC_LOOP)) {
-		net_notice_ratelimited("%s: reclassify loop, rule prio %u, "
-				       "protocol %02x\n", tp->q->ops->id,
-				       tp->prio & 0xffff, ntohs(tp->protocol));
+		net_notice_ratelimited("%s: reclassify loop, rule prio %u, protocol %02x\n",
+				       tp->q->ops->id, tp->prio & 0xffff,
+				       ntohs(tp->protocol));
 		return TC_ACT_SHOT;
 	}
 
-- 
1.9.3
