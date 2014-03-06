From: Yang Yingliang <yangyingliang@huawei.com>
Subject: [PATCH net-next 1/5] net_sched: add flag parameter in qdisc_change
Date: Thu, 6 Mar 2014 21:08:37 +0800
Message-ID: <1394111321-11192-2-git-send-email-yangyingliang@huawei.com>
References: <1394111321-11192-1-git-send-email-yangyingliang@huawei.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <stephen@networkplumber.org>, <eric.dumazet@gmail.com>
To: <davem@davemloft.net>, <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from szxga01-in.huawei.com ([119.145.14.64]:13553 "EHLO
	szxga01-in.huawei.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751065AbaCFNIu (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 6 Mar 2014 08:08:50 -0500
In-Reply-To: <1394111321-11192-1-git-send-email-yangyingliang@huawei.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Add a new parameter for checking if it's "change" or "replace".

Signed-off-by: Yang Yingliang <yangyingliang@huawei.com>
---
 net/sched/sch_api.c | 4 ++--
 1 file changed, 2 insertions(+), 2 deletions(-)

diff --git a/net/sched/sch_api.c b/net/sched/sch_api.c
index 1313145e3b86..961cb0f1bd0c 100644
--- a/net/sched/sch_api.c
+++ b/net/sched/sch_api.c
@@ -993,7 +993,7 @@ err_out4:
 	goto err_out3;
 }
 
-static int qdisc_change(struct Qdisc *sch, struct nlattr **tca)
+static int qdisc_change(struct Qdisc *sch, struct nlattr **tca, u16 flags)
 {
 	struct qdisc_size_table *ostab, *stab = NULL;
 	int err = 0;
@@ -1248,7 +1248,7 @@ replay:
 		return -EEXIST;
 	if (tca[TCA_KIND] && nla_strcmp(tca[TCA_KIND], q->ops->id))
 		return -EINVAL;
-	err = qdisc_change(q, tca);
+	err = qdisc_change(q, tca, n->nlmsg_flags);
 	if (err == 0)
 		qdisc_notify(net, skb, n, clid, NULL, q);
 	return err;
-- 
1.8.0
