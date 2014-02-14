From: Yang Yingliang <yangyingliang@huawei.com>
Subject: [PATCH net-next 2/7] sch_netem: clear old dist table when old qdisc's replaced
Date: Fri, 14 Feb 2014 16:36:05 +0800
Message-ID: <1392366970-11592-3-git-send-email-yangyingliang@huawei.com>
References: <1392366970-11592-1-git-send-email-yangyingliang@huawei.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <davem@davemloft.net>, <stephen@networkplumber.org>
To: <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from szxga01-in.huawei.com ([119.145.14.64]:45265 "EHLO
	szxga01-in.huawei.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751668AbaBNIgW (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 14 Feb 2014 03:36:22 -0500
In-Reply-To: <1392366970-11592-1-git-send-email-yangyingliang@huawei.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

If we set a netem qdisc with dist table option, while we
use "#tc qdisc replace ..." that without dist table option
to replace the old qdisc, the old dist table is still there.
We need clear dist table after qdisc's replaced.

Signed-off-by: Yang Yingliang <yangyingliang@huawei.com>
---
 net/sched/sch_netem.c | 3 +++
 1 file changed, 3 insertions(+)

diff --git a/net/sched/sch_netem.c b/net/sched/sch_netem.c
index 6f2cc04..fd2206d 100644
--- a/net/sched/sch_netem.c
+++ b/net/sched/sch_netem.c
@@ -859,6 +859,9 @@ static int netem_change(struct Qdisc *sch, struct nlattr *opt)
 			q->loss_model = old_loss_model;
 			return ret;
 		}
+	} else {
+		dist_free(q->delay_dist);
+		q->delay_dist = NULL;
 	}
 
 	sch->limit = qopt->limit;
-- 
1.8.0
