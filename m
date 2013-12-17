From: Yang Yingliang <yangyingliang@huawei.com>
Subject: [PATCH net-next 2/2] sch_cbq: remove unnecessary null pointer check
Date: Tue, 17 Dec 2013 15:29:17 +0800
Message-ID: <1387265357-19352-3-git-send-email-yangyingliang@huawei.com>
References: <1387265357-19352-1-git-send-email-yangyingliang@huawei.com>
Mime-Version: 1.0
Content-Type: text/plain
To: <davem@davemloft.net>, <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from szxga02-in.huawei.com ([119.145.14.65]:45278 "EHLO
	szxga02-in.huawei.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752297Ab3LQH32 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 17 Dec 2013 02:29:28 -0500
In-Reply-To: <1387265357-19352-1-git-send-email-yangyingliang@huawei.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

It already has a NULL pointer check of rtab in qdisc_put_rtab().
Remove the check outside of qdisc_put_rtab().

Signed-off-by: Yang Yingliang <yangyingliang@huawei.com>
---
 net/sched/sch_cbq.c | 3 +--
 1 file changed, 1 insertion(+), 2 deletions(-)

diff --git a/net/sched/sch_cbq.c b/net/sched/sch_cbq.c
index d5a8a4b..e251833 100644
--- a/net/sched/sch_cbq.c
+++ b/net/sched/sch_cbq.c
@@ -1783,8 +1783,7 @@ cbq_change_class(struct Qdisc *sch, u32 classid, u32 parentid, struct nlattr **t
 						    qdisc_root_sleeping_lock(sch),
 						    tca[TCA_RATE]);
 			if (err) {
-				if (rtab)
-					qdisc_put_rtab(rtab);
+				qdisc_put_rtab(rtab);
 				return err;
 			}
 		}
-- 
1.8.0
