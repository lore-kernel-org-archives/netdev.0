From: Yang Yingliang <yangyingliang@huawei.com>
Subject: [PATCH net-next 5/6] net_sched: sfq: put sfq_unlink in a do - while loop
Date: Tue, 10 Dec 2013 20:55:33 +0800
Message-ID: <1386680134-85452-6-git-send-email-yangyingliang@huawei.com>
References: <1386680134-85452-1-git-send-email-yangyingliang@huawei.com>
Mime-Version: 1.0
Content-Type: text/plain
To: <davem@davemloft.net>, <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from szxga01-in.huawei.com ([119.145.14.64]:4282 "EHLO
	szxga01-in.huawei.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753145Ab3LJMzv (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 10 Dec 2013 07:55:51 -0500
In-Reply-To: <1386680134-85452-1-git-send-email-yangyingliang@huawei.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Macros with multiple statements should be enclosed in a do - while loop

Signed-off-by: Yang Yingliang <yangyingliang@huawei.com>
---
 net/sched/sch_sfq.c | 10 ++++++----
 1 file changed, 6 insertions(+), 4 deletions(-)

diff --git a/net/sched/sch_sfq.c b/net/sched/sch_sfq.c
index d3a1bc2..76f01e0 100644
--- a/net/sched/sch_sfq.c
+++ b/net/sched/sch_sfq.c
@@ -237,10 +237,12 @@ static inline void sfq_link(struct sfq_sched_data *q, sfq_index x)
 }
 
 #define sfq_unlink(q, x, n, p)			\
-	n = q->slots[x].dep.next;		\
-	p = q->slots[x].dep.prev;		\
-	sfq_dep_head(q, p)->next = n;		\
-	sfq_dep_head(q, n)->prev = p
+	do {					\
+		n = q->slots[x].dep.next;	\
+		p = q->slots[x].dep.prev;	\
+		sfq_dep_head(q, p)->next = n;	\
+		sfq_dep_head(q, n)->prev = p;	\
+	} while (0)
 
 
 static inline void sfq_dec(struct sfq_sched_data *q, sfq_index x)
-- 
1.8.0
