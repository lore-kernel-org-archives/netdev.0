From: Yang Yingliang <yangyingliang@huawei.com>
Subject: [PATCH 2/3] net: sched: htb: fix condition of failure when rate is 0
Date: Thu, 14 Nov 2013 17:01:53 +0800
Message-ID: <1384419714-24364-3-git-send-email-yangyingliang@huawei.com>
References: <1384419714-24364-1-git-send-email-yangyingliang@huawei.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <eric.dumazet@gmail.com>
To: <davem@davemloft.net>, <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from szxga02-in.huawei.com ([119.145.14.65]:27542 "EHLO
	szxga02-in.huawei.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752801Ab3KNJC2 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 14 Nov 2013 04:02:28 -0500
In-Reply-To: <1384419714-24364-1-git-send-email-yangyingliang@huawei.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

When rate32 is 0, it doesn't means wrong.
Because htb support 64bit rates now, it
could use rate64.
So change the condition, when rate32 and
rate64 are both 0, it goes to failure.

Signed-off-by: Yang Yingliang <yangyingliang@huawei.com>
---
 net/sched/sch_htb.c | 3 ++-
 1 file changed, 2 insertions(+), 1 deletion(-)

diff --git a/net/sched/sch_htb.c b/net/sched/sch_htb.c
index 0e1e38b..f983803 100644
--- a/net/sched/sch_htb.c
+++ b/net/sched/sch_htb.c
@@ -1357,7 +1357,8 @@ static int htb_change_class(struct Qdisc *sch, u32 classid,
 	parent = parentid == TC_H_ROOT ? NULL : htb_find(parentid, sch);
 
 	hopt = nla_data(tb[TCA_HTB_PARMS]);
-	if (!hopt->rate.rate || !hopt->ceil.rate)
+	if ((!hopt->rate.rate && !tb[TCA_HTB_RATE64]) ||
+	    (!hopt->ceil.rate && !tb[TCA_HTB_CEIL64]))
 		goto failure;
 
 	/* Keeping backward compatible with rate_table based iproute2 tc */
-- 
1.7.12
