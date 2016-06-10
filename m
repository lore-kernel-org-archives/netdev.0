From: Eric Dumazet <edumazet@google.com>
Subject: [PATCH net-next 3/4] net_sched: netem: remove qdisc_is_throttled() use
Date: Fri, 10 Jun 2016 16:41:38 -0700
Message-ID: <1465602099-15808-4-git-send-email-edumazet@google.com>
References: <1465602099-15808-1-git-send-email-edumazet@google.com>
Cc: netdev <netdev@vger.kernel.org>,
	Eric Dumazet <edumazet@google.com>,
	Eric Dumazet <eric.dumazet@gmail.com>
To: "David S . Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f176.google.com ([209.85.192.176]:33876 "EHLO
	mail-pf0-f176.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932376AbcFJXlv (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 10 Jun 2016 19:41:51 -0400
Received: by mail-pf0-f176.google.com with SMTP id 62so27523351pfd.1
        for <netdev@vger.kernel.org>; Fri, 10 Jun 2016 16:41:51 -0700 (PDT)
In-Reply-To: <1465602099-15808-1-git-send-email-edumazet@google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Looks like it is only there as some optimization attempt.

Since __QDISC_STATE_THROTTLED set/unset is way too expensive,
and netem is the last user, just remove this check.

Signed-off-by: Eric Dumazet <edumazet@google.com>
---
 net/sched/sch_netem.c | 3 ---
 1 file changed, 3 deletions(-)

diff --git a/net/sched/sch_netem.c b/net/sched/sch_netem.c
index 9ca7947ab643..2dbe732ca135 100644
--- a/net/sched/sch_netem.c
+++ b/net/sched/sch_netem.c
@@ -582,9 +582,6 @@ static struct sk_buff *netem_dequeue(struct Qdisc *sch)
 	struct sk_buff *skb;
 	struct rb_node *p;
 
-	if (qdisc_is_throttled(sch))
-		return NULL;
-
 tfifo_dequeue:
 	skb = __skb_dequeue(&sch->q);
 	if (skb) {
-- 
2.8.0.rc3.226.g39d4020
