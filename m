From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: [PATCH net-next] ipv6: tcp: clean up tcp_v6_early_demux() icsk
 variable
Date: Tue, 23 Oct 2012 09:41:48 +0200
Message-ID: <1350978108.8609.1542.camel@edumazet-glaptop>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev <netdev@vger.kernel.org>,
	Neal Cardwell <ncardwell@google.com>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-bk0-f46.google.com ([209.85.214.46]:56839 "EHLO
	mail-bk0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752355Ab2JWHlx (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 23 Oct 2012 03:41:53 -0400
Received: by mail-bk0-f46.google.com with SMTP id jk13so1377008bkc.19
        for <netdev@vger.kernel.org>; Tue, 23 Oct 2012 00:41:51 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Neal Cardwell <ncardwell@google.com>

Remove an icsk variable, which by convention should refer to an
inet_connection_sock rather than an inet_sock. In the process, make
the tcp_v6_early_demux() code and formatting a bit more like
tcp_v4_early_demux(), to ease comparisons and maintenance.

Signed-off-by: Neal Cardwell <ncardwell@google.com>
Signed-off-by: Eric Dumazet <edumazet@google.com>
---
 net/ipv6/tcp_ipv6.c |    4 ++--
 1 files changed, 2 insertions(+), 2 deletions(-)

diff --git a/net/ipv6/tcp_ipv6.c b/net/ipv6/tcp_ipv6.c
index 26175bf..bb6782e 100644
--- a/net/ipv6/tcp_ipv6.c
+++ b/net/ipv6/tcp_ipv6.c
@@ -1741,11 +1741,11 @@ static void tcp_v6_early_demux(struct sk_buff *skb)
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
