From: Eric Dumazet <edumazet@google.com>
Subject: [PATCH net-next 08/10] tcp: use tp->tcp_mstamp in tcp_clean_rtx_queue()
Date: Tue, 25 Apr 2017 10:15:39 -0700
Message-ID: <20170425171541.3417-9-edumazet@google.com>
References: <20170425171541.3417-1-edumazet@google.com>
Cc: netdev <netdev@vger.kernel.org>,
        Soheil Hassas Yeganeh <soheil@google.com>,
        Eric Dumazet <edumazet@google.com>,
        Eric Dumazet <eric.dumazet@gmail.com>
To: "David S . Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-it0-f50.google.com ([209.85.214.50]:33734 "EHLO
        mail-it0-f50.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1951806AbdDYRQL (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 25 Apr 2017 13:16:11 -0400
Received: by mail-it0-f50.google.com with SMTP id 70so20279834ita.0
        for <netdev@vger.kernel.org>; Tue, 25 Apr 2017 10:16:10 -0700 (PDT)
In-Reply-To: <20170425171541.3417-1-edumazet@google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Following patch will remove ack_time from struct tcp_sacktag_state

Same info is now found in tp->tcp_mstamp

Signed-off-by: Eric Dumazet <edumazet@google.com>
Acked-by: Soheil Hassas Yeganeh <soheil@google.com>
---
 net/ipv4/tcp_input.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/net/ipv4/tcp_input.c b/net/ipv4/tcp_input.c
index 5485204853d3aefaea5027bcf6480ed20a1e8efa..f4e1836c696c9a45a545a32de8ba62ce3bd0dc12 100644
--- a/net/ipv4/tcp_input.c
+++ b/net/ipv4/tcp_input.c
@@ -3056,8 +3056,8 @@ static int tcp_clean_rtx_queue(struct sock *sk, int prior_fackets,
 {
 	const struct inet_connection_sock *icsk = inet_csk(sk);
 	struct skb_mstamp first_ackt, last_ackt;
-	struct skb_mstamp *now = &sack->ack_time;
 	struct tcp_sock *tp = tcp_sk(sk);
+	struct skb_mstamp *now = &tp->tcp_mstamp;
 	u32 prior_sacked = tp->sacked_out;
 	u32 reord = tp->packets_out;
 	bool fully_acked = true;
-- 
2.13.0.rc0.306.g87b477812d-goog
