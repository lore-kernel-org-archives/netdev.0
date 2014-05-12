From: Yang Yingliang <yangyingliang@huawei.com>
Subject: [PATCH iproute2] fq: don't allow set options to zero
Date: Mon, 12 May 2014 12:18:39 +0800
Message-ID: <1399868319-2184-1-git-send-email-yangyingliang@huawei.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <netdev@vger.kernel.org>, <eric.dumazet@gmail.com>
To: <stephen@networkplumber.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from szxga03-in.huawei.com ([119.145.14.66]:60320 "EHLO
	szxga03-in.huawei.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751677AbaELESt (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 12 May 2014 00:18:49 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Now options of fair queue can be zero but cannot be (~0U).
Zero is useless, so don't allow set the options to zero.
Also, maxrate cannot be reset to unlimited because it
cannot be (~0U).

Cc: Eric Dumazet <edumazet@google.com>
Signed-off-by: Yang Yingliang <yangyingliang@huawei.com>
---
 tc/q_fq.c | 24 ++++++++++++------------
 1 file changed, 12 insertions(+), 12 deletions(-)

diff --git a/tc/q_fq.c b/tc/q_fq.c
index c1f658e..c529842 100644
--- a/tc/q_fq.c
+++ b/tc/q_fq.c
@@ -71,13 +71,13 @@ static unsigned int ilog2(unsigned int val)
 static int fq_parse_opt(struct qdisc_util *qu, int argc, char **argv,
 			struct nlmsghdr *n)
 {
-	unsigned int plimit = ~0U;
-	unsigned int flow_plimit = ~0U;
-	unsigned int quantum = ~0U;
-	unsigned int initial_quantum = ~0U;
+	unsigned int plimit = 0;
+	unsigned int flow_plimit = 0;
+	unsigned int quantum = 0;
+	unsigned int initial_quantum = 0;
 	unsigned int buckets = 0;
-	unsigned int maxrate = ~0U;
-	unsigned int defrate = ~0U;
+	unsigned int maxrate = 0;
+	unsigned int defrate = 0;
 	int pacing = -1;
 	struct rtattr *tail;
 
@@ -147,24 +147,24 @@ static int fq_parse_opt(struct qdisc_util *qu, int argc, char **argv,
 		addattr_l(n, 1024, TCA_FQ_BUCKETS_LOG,
 			  &log, sizeof(log));
 	}
-	if (plimit != ~0U)
+	if (plimit)
 		addattr_l(n, 1024, TCA_FQ_PLIMIT,
 			  &plimit, sizeof(plimit));
-	if (flow_plimit != ~0U)
+	if (flow_plimit)
 		addattr_l(n, 1024, TCA_FQ_FLOW_PLIMIT,
 			  &flow_plimit, sizeof(flow_plimit));
-	if (quantum != ~0U)
+	if (quantum)
 		addattr_l(n, 1024, TCA_FQ_QUANTUM, &quantum, sizeof(quantum));
-	if (initial_quantum != ~0U)
+	if (initial_quantum)
 		addattr_l(n, 1024, TCA_FQ_INITIAL_QUANTUM,
 			  &initial_quantum, sizeof(initial_quantum));
 	if (pacing != -1)
 		addattr_l(n, 1024, TCA_FQ_RATE_ENABLE,
 			  &pacing, sizeof(pacing));
-	if (maxrate != ~0U)
+	if (maxrate)
 		addattr_l(n, 1024, TCA_FQ_FLOW_MAX_RATE,
 			  &maxrate, sizeof(maxrate));
-	if (defrate != ~0U)
+	if (defrate)
 		addattr_l(n, 1024, TCA_FQ_FLOW_DEFAULT_RATE,
 			  &defrate, sizeof(defrate));
 	tail->rta_len = (void *) NLMSG_TAIL(n) - (void *) tail;
-- 
1.8.0
