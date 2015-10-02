From: Eric Dumazet <edumazet@google.com>
Subject: [PATCH net-next 07/17] tcp: remove BUG_ON() in tcp_check_req()
Date: Fri,  2 Oct 2015 11:43:29 -0700
Message-ID: <1443811419-4798-8-git-send-email-edumazet@google.com>
References: <1443811419-4798-1-git-send-email-edumazet@google.com>
Cc: netdev <netdev@vger.kernel.org>,
	Eric Dumazet <edumazet@google.com>, Ying Cai <ycai@google.com>,
	Willem de Bruijn <willemb@google.com>,
	Eric Dumazet <eric.dumazet@gmail.com>
To: "David S . Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f51.google.com ([209.85.220.51]:35456 "EHLO
	mail-pa0-f51.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752002AbbJBSoF (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 2 Oct 2015 14:44:05 -0400
Received: by pacfv12 with SMTP id fv12so115648926pac.2
        for <netdev@vger.kernel.org>; Fri, 02 Oct 2015 11:44:04 -0700 (PDT)
In-Reply-To: <1443811419-4798-1-git-send-email-edumazet@google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Once listener is lockless, its sk_state can change anytime.

Signed-off-by: Eric Dumazet <edumazet@google.com>
---
 net/ipv4/tcp_minisocks.c | 2 --
 1 file changed, 2 deletions(-)

diff --git a/net/ipv4/tcp_minisocks.c b/net/ipv4/tcp_minisocks.c
index 897e34273ba3..9adf1e2c3170 100644
--- a/net/ipv4/tcp_minisocks.c
+++ b/net/ipv4/tcp_minisocks.c
@@ -578,8 +578,6 @@ struct sock *tcp_check_req(struct sock *sk, struct sk_buff *skb,
 	__be32 flg = tcp_flag_word(th) & (TCP_FLAG_RST|TCP_FLAG_SYN|TCP_FLAG_ACK);
 	bool paws_reject = false;
 
-	BUG_ON(fastopen == (sk->sk_state == TCP_LISTEN));
-
 	tmp_opt.saw_tstamp = 0;
 	if (th->doff > (sizeof(struct tcphdr)>>2)) {
 		tcp_parse_options(skb, &tmp_opt, 0, NULL);
-- 
2.6.0.rc2.230.g3dd15c0
