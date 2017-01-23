From: Wei Wang <tracywwnj@gmail.com>
Subject: [PATCH net-next 2/3] net: Remove __sk_dst_reset() in tcp_v6_connect()
Date: Mon, 23 Jan 2017 10:59:21 -0800
Message-ID: <20170123185922.48046-3-tracywwnj@gmail.com>
References: <20170123185922.48046-1-tracywwnj@gmail.com>
Cc: Eric Dumazet <edumazet@google.com>,
        Yuchung Cheng <ycheng@google.com>, Wei Wang <weiwan@google.com>
To: netdev@vger.kernel.org, David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f196.google.com ([209.85.192.196]:33333 "EHLO
        mail-pf0-f196.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751474AbdAWTA0 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 23 Jan 2017 14:00:26 -0500
Received: by mail-pf0-f196.google.com with SMTP id e4so10494474pfg.0
        for <netdev@vger.kernel.org>; Mon, 23 Jan 2017 11:00:26 -0800 (PST)
In-Reply-To: <20170123185922.48046-1-tracywwnj@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Wei Wang <weiwan@google.com>

Remove __sk_dst_reset() in the failure handling because __sk_dst_reset()
will eventually get called when sk is released. No need to handle it in
the protocol specific connect call.
This is also to make the code path consistent with ipv4.

Signed-off-by: Wei Wang <weiwan@google.com>
---
 net/ipv6/tcp_ipv6.c | 1 -
 1 file changed, 1 deletion(-)

diff --git a/net/ipv6/tcp_ipv6.c b/net/ipv6/tcp_ipv6.c
index f72100eedd5d..0b7cd3d009b6 100644
--- a/net/ipv6/tcp_ipv6.c
+++ b/net/ipv6/tcp_ipv6.c
@@ -295,7 +295,6 @@ static int tcp_v6_connect(struct sock *sk, struct sockaddr *uaddr,
 
 late_failure:
 	tcp_set_state(sk, TCP_CLOSE);
-	__sk_dst_reset(sk);
 failure:
 	inet->inet_dport = 0;
 	sk->sk_route_caps = 0;
-- 
2.11.0.483.g087da7b7c-goog
