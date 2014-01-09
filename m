From: Cong Wang <xiyou.wangcong@gmail.com>
Subject: [RFC Patch net-next 4/4] net_sched: make ingress qdisc lockless
Date: Thu,  9 Jan 2014 10:19:53 -0800
Message-ID: <1389291593-2494-5-git-send-email-xiyou.wangcong@gmail.com>
References: <1389291593-2494-1-git-send-email-xiyou.wangcong@gmail.com>
Cc: Cong Wang <xiyou.wangcong@gmail.com>,
	John Fastabend <john.fastabend@gmail.com>,
	Eric Dumazet <eric.dumazet@gmail.com>,
	"David S. Miller" <davem@davemloft.net>,
	Jamal Hadi Salim <jhs@mojatatu.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pd0-f169.google.com ([209.85.192.169]:37659 "EHLO
	mail-pd0-f169.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754925AbaAISUP (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 9 Jan 2014 13:20:15 -0500
Received: by mail-pd0-f169.google.com with SMTP id v10so3484352pde.14
        for <netdev@vger.kernel.org>; Thu, 09 Jan 2014 10:20:14 -0800 (PST)
In-Reply-To: <1389291593-2494-1-git-send-email-xiyou.wangcong@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Cc: John Fastabend <john.fastabend@gmail.com>
Cc: Eric Dumazet <eric.dumazet@gmail.com>
Cc: David S. Miller <davem@davemloft.net>
Cc: Jamal Hadi Salim <jhs@mojatatu.com>
Signed-off-by: Cong Wang <xiyou.wangcong@gmail.com>
---
 net/core/dev.c | 2 --
 1 file changed, 2 deletions(-)

diff --git a/net/core/dev.c b/net/core/dev.c
index ce01847..e357d05 100644
--- a/net/core/dev.c
+++ b/net/core/dev.c
@@ -3376,10 +3376,8 @@ static int ing_filter(struct sk_buff *skb, struct netdev_queue *rxq)
 
 	q = rxq->qdisc;
 	if (q != &noop_qdisc) {
-		spin_lock(qdisc_lock(q));
 		if (likely(!test_bit(__QDISC_STATE_DEACTIVATED, &q->state)))
 			result = qdisc_enqueue_root(skb, q);
-		spin_unlock(qdisc_lock(q));
 	}
 
 	return result;
-- 
1.8.3.1
