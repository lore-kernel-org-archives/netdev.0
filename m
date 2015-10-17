From: Yuchung Cheng <ycheng@google.com>
Subject: [PATCH net-next 4/7] tcp: add tcp_tsopt_ecr_before helper
Date: Fri, 16 Oct 2015 21:57:44 -0700
Message-ID: <1445057867-32257-5-git-send-email-ycheng@google.com>
References: <1445057867-32257-1-git-send-email-ycheng@google.com>
Cc: netdev@vger.kernel.org, Yuchung Cheng <ycheng@google.com>,
	Neal Cardwell <ncardwell@google.com>,
	Eric Dumazet <edumazet@google.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f54.google.com ([209.85.220.54]:34330 "EHLO
	mail-pa0-f54.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751064AbbJQE6H (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 17 Oct 2015 00:58:07 -0400
Received: by pabws5 with SMTP id ws5so8324585pab.1
        for <netdev@vger.kernel.org>; Fri, 16 Oct 2015 21:58:06 -0700 (PDT)
In-Reply-To: <1445057867-32257-1-git-send-email-ycheng@google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

a helper to prepare the main RACK patch

Signed-off-by: Yuchung Cheng <ycheng@google.com>
Signed-off-by: Neal Cardwell <ncardwell@google.com>
Signed-off-by: Eric Dumazet <edumazet@google.com>
---
 net/ipv4/tcp_input.c | 9 +++++++--
 1 file changed, 7 insertions(+), 2 deletions(-)

diff --git a/net/ipv4/tcp_input.c b/net/ipv4/tcp_input.c
index 5ad08d8..c304b5f 100644
--- a/net/ipv4/tcp_input.c
+++ b/net/ipv4/tcp_input.c
@@ -2250,14 +2250,19 @@ static inline void tcp_moderate_cwnd(struct tcp_sock *tp)
 	tp->snd_cwnd_stamp = tcp_time_stamp;
 }
 
+static bool tcp_tsopt_ecr_before(const struct tcp_sock *tp, u32 when)
+{
+	return tp->rx_opt.saw_tstamp && tp->rx_opt.rcv_tsecr &&
+	       before(tp->rx_opt.rcv_tsecr, when);
+}
+
 /* Nothing was retransmitted or returned timestamp is less
  * than timestamp of the first retransmission.
  */
 static inline bool tcp_packet_delayed(const struct tcp_sock *tp)
 {
 	return !tp->retrans_stamp ||
-		(tp->rx_opt.saw_tstamp && tp->rx_opt.rcv_tsecr &&
-		 before(tp->rx_opt.rcv_tsecr, tp->retrans_stamp));
+	       tcp_tsopt_ecr_before(tp, tp->retrans_stamp);
 }
 
 /* Undo procedures. */
-- 
2.6.0.rc2.230.g3dd15c0
