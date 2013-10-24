From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: [PATCH] pkt_sched: fq: clear time_next_packet for reused flows
Date: Thu, 24 Oct 2013 04:01:48 -0700
Message-ID: <1382612508.7572.53.camel@edumazet-glaptop.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev <netdev@vger.kernel.org>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wi0-f169.google.com ([209.85.212.169]:42940 "EHLO
	mail-wi0-f169.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754968Ab3JXLBw (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 24 Oct 2013 07:01:52 -0400
Received: by mail-wi0-f169.google.com with SMTP id cb5so9657154wib.0
        for <netdev@vger.kernel.org>; Thu, 24 Oct 2013 04:01:51 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <edumazet@google.com>

When a socket is freed/reallocated, we need to clear time_next_packet
or else we can inherit a prior value and delay first packets of the
new flow.

Signed-off-by: Eric Dumazet <edumazet@google.com>
---
 net/sched/sch_fq.c |    1 +
 1 file changed, 1 insertion(+)

diff --git a/net/sched/sch_fq.c b/net/sched/sch_fq.c
index a9dfdda..fdc041c 100644
--- a/net/sched/sch_fq.c
+++ b/net/sched/sch_fq.c
@@ -255,6 +255,7 @@ static struct fq_flow *fq_classify(struct sk_buff
*skb, struct fq_sched_data *q)
 				     f->socket_hash != sk->sk_hash)) {
 				f->credit = q->initial_quantum;
 				f->socket_hash = sk->sk_hash;
+				f->time_next_packet = 0ULL;
 			}
 			return f;
 		}
