From: Michal Soltys <soltys@ziu.info>
Subject: [net-next PATCH 2/5] net/sched/sch_hfsc.c: add unlikely() in qdisc_peek_len()
Date: Thu, 30 Jun 2016 02:26:45 +0200
Message-ID: <1467246408-913-3-git-send-email-soltys@ziu.info>
References: <1467246408-913-1-git-send-email-soltys@ziu.info>
Cc: netdev@vger.kernel.org, kaber@trash.net
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from drutsystem.com ([84.10.39.251]:50042 "EHLO drutsystem.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751591AbcF3A1b (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 29 Jun 2016 20:27:31 -0400
In-Reply-To: <1467246408-913-1-git-send-email-soltys@ziu.info>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The condition can only succeed on wrong configurations.

Signed-off-by: Michal Soltys <soltys@ziu.info>
---
 net/sched/sch_hfsc.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/net/sched/sch_hfsc.c b/net/sched/sch_hfsc.c
index 6d6df6b..e2244bb 100644
--- a/net/sched/sch_hfsc.c
+++ b/net/sched/sch_hfsc.c
@@ -882,7 +882,7 @@ qdisc_peek_len(struct Qdisc *sch)
 	unsigned int len;
 
 	skb = sch->ops->peek(sch);
-	if (skb == NULL) {
+	if (unlikely(skb == NULL)) {
 		qdisc_warn_nonwc("qdisc_peek_len", sch);
 		return 0;
 	}
-- 
2.1.3
