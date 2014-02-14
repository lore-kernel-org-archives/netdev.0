From: Yang Yingliang <yangyingliang@huawei.com>
Subject: [PATCH net-next 1/7] sch_netem: clear old clgstate when old qdisc's replaced
Date: Fri, 14 Feb 2014 16:36:04 +0800
Message-ID: <1392366970-11592-2-git-send-email-yangyingliang@huawei.com>
References: <1392366970-11592-1-git-send-email-yangyingliang@huawei.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <davem@davemloft.net>, <stephen@networkplumber.org>
To: <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from szxga01-in.huawei.com ([119.145.14.64]:45267 "EHLO
	szxga01-in.huawei.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751643AbaBNIgW (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 14 Feb 2014 03:36:22 -0500
In-Reply-To: <1392366970-11592-1-git-send-email-yangyingliang@huawei.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

If we set a netem qdisc with clgstate options, while we
use "#tc qdisc replace ..." that without clgstate options
to replace the old qdisc, the old clgstate's value is still
there. We need clear these values after qdisc's replaced.

Signed-off-by: Yang Yingliang <yangyingliang@huawei.com>
---
 net/sched/sch_netem.c | 1 +
 1 file changed, 1 insertion(+)

diff --git a/net/sched/sch_netem.c b/net/sched/sch_netem.c
index 4fced67..6f2cc04 100644
--- a/net/sched/sch_netem.c
+++ b/net/sched/sch_netem.c
@@ -845,6 +845,7 @@ static int netem_change(struct Qdisc *sch, struct nlattr *opt)
 		}
 	} else {
 		q->loss_model = CLG_RANDOM;
+		memset(&q->clg, 0, sizeof(q->clg));
 	}
 
 	if (tb[TCA_NETEM_DELAY_DIST]) {
-- 
1.8.0
