From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: [PATCH v2] pkt_sched: fq: clear time_next_packet for reused flows
Date: Sun, 27 Oct 2013 16:26:43 -0700
Message-ID: <1382916403.4045.17.camel@edumazet-glaptop.roam.corp.google.com>
References: <1382612508.7572.53.camel@edumazet-glaptop.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev <netdev@vger.kernel.org>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f52.google.com ([209.85.220.52]:50195 "EHLO
	mail-pa0-f52.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751371Ab3J0X0o (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 27 Oct 2013 19:26:44 -0400
Received: by mail-pa0-f52.google.com with SMTP id bj1so201618pad.11
        for <netdev@vger.kernel.org>; Sun, 27 Oct 2013 16:26:44 -0700 (PDT)
In-Reply-To: <1382612508.7572.53.camel@edumazet-glaptop.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <edumazet@google.com>

When a socket is freed/reallocated, we need to clear time_next_packet
or else we can inherit a prior value and delay first packets of the
new flow.

Signed-off-by: Eric Dumazet <edumazet@google.com>
---
v2: wrapping issue

 net/sched/sch_fq.c |    1 +
 1 file changed, 1 insertion(+)

diff --git a/net/sched/sch_fq.c b/net/sched/sch_fq.c
index a9dfdda..fdc041c 100644
--- a/net/sched/sch_fq.c
+++ b/net/sched/sch_fq.c
@@ -255,6 +255,7 @@ static struct fq_flow *fq_classify(struct sk_buff *skb, struct fq_sched_data *q)
 				     f->socket_hash != sk->sk_hash)) {
 				f->credit = q->initial_quantum;
 				f->socket_hash = sk->sk_hash;
+				f->time_next_packet = 0ULL;
 			}
 			return f;
 		}
