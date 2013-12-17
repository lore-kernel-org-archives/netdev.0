From: Yang Yingliang <yangyingliang@huawei.com>
Subject: [PATCH net-next 1/2] act_police: remove unnecessary null pointer check
Date: Tue, 17 Dec 2013 15:29:16 +0800
Message-ID: <1387265357-19352-2-git-send-email-yangyingliang@huawei.com>
References: <1387265357-19352-1-git-send-email-yangyingliang@huawei.com>
Mime-Version: 1.0
Content-Type: text/plain
To: <davem@davemloft.net>, <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from szxga03-in.huawei.com ([119.145.14.66]:20400 "EHLO
	szxga03-in.huawei.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752360Ab3LQH3w (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 17 Dec 2013 02:29:52 -0500
In-Reply-To: <1387265357-19352-1-git-send-email-yangyingliang@huawei.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

It already has a NULL pointer check of rtab in qdisc_put_rtab().
Remove the check outside of qdisc_put_rtab().

Signed-off-by: Yang Yingliang <yangyingliang@huawei.com>
---
 net/sched/act_police.c | 6 ++----
 1 file changed, 2 insertions(+), 4 deletions(-)

diff --git a/net/sched/act_police.c b/net/sched/act_police.c
index 16a62c3..cf01c97 100644
--- a/net/sched/act_police.c
+++ b/net/sched/act_police.c
@@ -277,10 +277,8 @@ override:
 failure_unlock:
 	spin_unlock_bh(&police->tcf_lock);
 failure:
-	if (P_tab)
-		qdisc_put_rtab(P_tab);
-	if (R_tab)
-		qdisc_put_rtab(R_tab);
+	qdisc_put_rtab(P_tab);
+	qdisc_put_rtab(R_tab);
 	if (ret == ACT_P_CREATED)
 		kfree(police);
 	return err;
-- 
1.8.0
