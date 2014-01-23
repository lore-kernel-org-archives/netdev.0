From: Yang Yingliang <yangyingliang@huawei.com>
Subject: [PATCH net-next 3/3] sch_netem: replace magic numbers with enumerate in GE model
Date: Thu, 23 Jan 2014 17:31:39 +0800
Message-ID: <1390469499-31952-4-git-send-email-yangyingliang@huawei.com>
References: <1390469499-31952-1-git-send-email-yangyingliang@huawei.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <stephen@networkplumber.org>, <davem@davemloft.net>
To: <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from szxga01-in.huawei.com ([119.145.14.64]:27860 "EHLO
	szxga01-in.huawei.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751545AbaAWJcB (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 23 Jan 2014 04:32:01 -0500
In-Reply-To: <1390469499-31952-1-git-send-email-yangyingliang@huawei.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Replace some magic numbers which describe states of GE model
loss generator with enumerate.

Signed-off-by: Yang Yingliang <yangyingliang@huawei.com>
---
 net/sched/sch_netem.c | 13 +++++++++----
 1 file changed, 9 insertions(+), 4 deletions(-)

diff --git a/net/sched/sch_netem.c b/net/sched/sch_netem.c
index 7e15f08..2479709 100644
--- a/net/sched/sch_netem.c
+++ b/net/sched/sch_netem.c
@@ -117,6 +117,11 @@ struct netem_sched_data {
 		LOST_IN_BURST_PERIOD,
 	} _4_state_model;
 
+	enum {
+		GOOD_STATE = 1,
+		BAD_STATE,
+	} GE_state_model;
+
 	/* Correlated Loss Generation models */
 	struct clgstate {
 		/* state of the Markov chain */
@@ -272,15 +277,15 @@ static bool loss_gilb_ell(struct netem_sched_data *q)
 	struct clgstate *clg = &q->clg;
 
 	switch (clg->state) {
-	case 1:
+	case GOOD_STATE:
 		if (prandom_u32() < clg->a1)
-			clg->state = 2;
+			clg->state = BAD_STATE;
 		if (prandom_u32() < clg->a4)
 			return true;
 		break;
-	case 2:
+	case BAD_STATE:
 		if (prandom_u32() < clg->a2)
-			clg->state = 1;
+			clg->state = GOOD_STATE;
 		if (prandom_u32() > clg->a3)
 			return true;
 	}
-- 
1.8.0
