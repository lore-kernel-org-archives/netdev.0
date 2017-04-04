From: Yuchung Cheng <ycheng@google.com>
Subject: [PATCH net 1/2] tcp: fix lost retransmit SNMP under-counting
Date: Tue,  4 Apr 2017 14:15:39 -0700
Message-ID: <20170404211540.47887-1-ycheng@google.com>
Cc: netdev@vger.kernel.org, ncardwell@google.com, edumazet@google.com,
        soheil@google.com, Yuchung Cheng <ycheng@google.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f176.google.com ([209.85.192.176]:34323 "EHLO
        mail-pf0-f176.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752768AbdDDVQG (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 4 Apr 2017 17:16:06 -0400
Received: by mail-pf0-f176.google.com with SMTP id 197so12730176pfv.1
        for <netdev@vger.kernel.org>; Tue, 04 Apr 2017 14:16:06 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The lost retransmit SNMP stat is under-counting retransmission
that uses segment offloading. This patch fixes that so all
retransmission related SNMP counters are consistent.

Fixes: 10d3be569243 ("tcp-tso: do not split TSO packets at retransmit time")
Signed-off-by: Yuchung Cheng <ycheng@google.com>
Signed-off-by: Eric Dumazet <edumazet@google.com>
Signed-off-by: Neal Cardwell <ncardwell@google.com>
Signed-off-by: Soheil Hassas Yeganeh <soheil@google.com>
---
 net/ipv4/tcp_recovery.c | 3 ++-
 1 file changed, 2 insertions(+), 1 deletion(-)

diff --git a/net/ipv4/tcp_recovery.c b/net/ipv4/tcp_recovery.c
index 4ecb38ae8504..d8acbd9f477a 100644
--- a/net/ipv4/tcp_recovery.c
+++ b/net/ipv4/tcp_recovery.c
@@ -12,7 +12,8 @@ static void tcp_rack_mark_skb_lost(struct sock *sk, struct sk_buff *skb)
 		/* Account for retransmits that are lost again */
 		TCP_SKB_CB(skb)->sacked &= ~TCPCB_SACKED_RETRANS;
 		tp->retrans_out -= tcp_skb_pcount(skb);
-		NET_INC_STATS(sock_net(sk), LINUX_MIB_TCPLOSTRETRANSMIT);
+		NET_ADD_STATS(sock_net(sk), LINUX_MIB_TCPLOSTRETRANSMIT,
+			      tcp_skb_pcount(skb));
 	}
 }
 
-- 
2.12.2.715.g7642488e1d-goog
