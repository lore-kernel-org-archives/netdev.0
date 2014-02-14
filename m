From: Yang Yingliang <yangyingliang@huawei.com>
Subject: [PATCH net-next 7/7] sch_netem: clear old ecn when old qdisc's replaced
Date: Fri, 14 Feb 2014 16:36:10 +0800
Message-ID: <1392366970-11592-8-git-send-email-yangyingliang@huawei.com>
References: <1392366970-11592-1-git-send-email-yangyingliang@huawei.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <davem@davemloft.net>, <stephen@networkplumber.org>
To: <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from szxga03-in.huawei.com ([119.145.14.66]:44515 "EHLO
	szxga03-in.huawei.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752046AbaBNIg2 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 14 Feb 2014 03:36:28 -0500
In-Reply-To: <1392366970-11592-1-git-send-email-yangyingliang@huawei.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

If we set a netem qdisc with ecn option, while we
use "#tc qdisc replace ..." that without ecn option
to replace the old qdisc, the old ecn is still there.
We need clear old ecn after qdisc's replaced.

Signed-off-by: Yang Yingliang <yangyingliang@huawei.com>
---
 net/sched/sch_netem.c | 2 ++
 1 file changed, 2 insertions(+)

diff --git a/net/sched/sch_netem.c b/net/sched/sch_netem.c
index 92f6ba6..52ae2ef 100644
--- a/net/sched/sch_netem.c
+++ b/net/sched/sch_netem.c
@@ -936,6 +936,8 @@ static int netem_change(struct Qdisc *sch, struct nlattr *opt)
 
 	if (tb[TCA_NETEM_ECN])
 		q->ecn = nla_get_u32(tb[TCA_NETEM_ECN]);
+	else
+		q->ecn = 0;
 
 	return ret;
 }
-- 
1.8.0
