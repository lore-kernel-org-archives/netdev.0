From: Neal Cardwell <ncardwell@google.com>
Subject: [PATCH net] ipv6: clean up tcp_v6_early_demux() icsk variable
Date: Fri,  5 Oct 2012 09:21:24 -0400
Message-ID: <1349443284-14640-1-git-send-email-ncardwell@google.com>
Cc: netdev@vger.kernel.org, Eric Dumazet <edumazet@google.com>,
	Neal Cardwell <ncardwell@google.com>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-vc0-f202.google.com ([209.85.220.202]:44347 "EHLO
	mail-vc0-f202.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754776Ab2JENV1 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 5 Oct 2012 09:21:27 -0400
Received: by mail-vc0-f202.google.com with SMTP id fy27so183041vcb.1
        for <netdev@vger.kernel.org>; Fri, 05 Oct 2012 06:21:26 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Remove an icsk variable, which by convention should refer to an
inet_connection_sock rather than an inet_sock. In the process, make
the tcp_v6_early_demux() code and formatting a bit more like
tcp_v4_early_demux(), to ease comparisons and maintenance.

Signed-off-by: Neal Cardwell <ncardwell@google.com>
---
 net/ipv6/tcp_ipv6.c |    4 ++--
 1 files changed, 2 insertions(+), 2 deletions(-)

diff --git a/net/ipv6/tcp_ipv6.c b/net/ipv6/tcp_ipv6.c
index 49c8903..491c41b 100644
--- a/net/ipv6/tcp_ipv6.c
+++ b/net/ipv6/tcp_ipv6.c
@@ -1740,11 +1740,11 @@ static void tcp_v6_early_demux(struct sk_buff *skb)
 		skb->destructor = sock_edemux;
 		if (sk->sk_state != TCP_TIME_WAIT) {
 			struct dst_entry *dst = sk->sk_rx_dst;
-			struct inet_sock *icsk = inet_sk(sk);
+
 			if (dst)
 				dst = dst_check(dst, inet6_sk(sk)->rx_dst_cookie);
 			if (dst &&
-			    icsk->rx_dst_ifindex == skb->skb_iif)
+			    inet_sk(sk)->rx_dst_ifindex == skb->skb_iif)
 				skb_dst_set_noref(skb, dst);
 		}
 	}
-- 
1.7.7.3
