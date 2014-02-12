From: Yang Yingliang <yangyingliang@huawei.com>
Subject: [PATCH net-next 4/4] sch_netem: replace spin_(un)lock_bh with sch_tree_(un)lock
Date: Wed, 12 Feb 2014 10:58:15 +0800
Message-ID: <1392173895-5012-5-git-send-email-yangyingliang@huawei.com>
References: <1392173895-5012-1-git-send-email-yangyingliang@huawei.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <davem@davemloft.net>, <stephen@networkplumber.org>
To: <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from szxga02-in.huawei.com ([119.145.14.65]:15570 "EHLO
	szxga02-in.huawei.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752503AbaBLC6b (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 11 Feb 2014 21:58:31 -0500
In-Reply-To: <1392173895-5012-1-git-send-email-yangyingliang@huawei.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

spin_(un)lock_bh(root_lock) is same as sch_tree_(un)lock.

Signed-off-by: Yang Yingliang <yangyingliang@huawei.com>
---
 net/sched/sch_netem.c | 7 ++-----
 1 file changed, 2 insertions(+), 5 deletions(-)

diff --git a/net/sched/sch_netem.c b/net/sched/sch_netem.c
index 4fced67..62811d5 100644
--- a/net/sched/sch_netem.c
+++ b/net/sched/sch_netem.c
@@ -665,7 +665,6 @@ static int get_dist_table(struct Qdisc *sch, const struct nlattr *attr)
 	struct netem_sched_data *q = qdisc_priv(sch);
 	size_t n = nla_len(attr)/sizeof(__s16);
 	const __s16 *data = nla_data(attr);
-	spinlock_t *root_lock;
 	struct disttable *d;
 	int i;
 	size_t s;
@@ -684,11 +683,9 @@ static int get_dist_table(struct Qdisc *sch, const struct nlattr *attr)
 	for (i = 0; i < n; i++)
 		d->table[i] = data[i];
 
-	root_lock = qdisc_root_sleeping_lock(sch);
-
-	spin_lock_bh(root_lock);
+	sch_tree_lock(sch);
 	swap(q->delay_dist, d);
-	spin_unlock_bh(root_lock);
+	sch_tree_unlock(sch);
 
 	dist_free(d);
 	return 0;
-- 
1.8.0
