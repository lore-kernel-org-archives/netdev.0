From: Neal Cardwell <ncardwell@google.com>
Subject: [PATCH net-next 1/4] tcp: fix inet6_csk_route_req() for link-local addresses
Date: Thu, 28 Jun 2012 15:34:18 -0700
Message-ID: <1340922861-11684-1-git-send-email-ncardwell@google.com>
Cc: netdev@vger.kernel.org, Eric Dumazet <edumazet@google.com>,
	Neal Cardwell <ncardwell@google.com>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-vb0-f74.google.com ([209.85.212.74]:53884 "EHLO
	mail-vb0-f74.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753689Ab2F1Xpj (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 28 Jun 2012 19:45:39 -0400
Received: by mail-vb0-f74.google.com with SMTP id l22so268730vbn.1
        for <netdev@vger.kernel.org>; Thu, 28 Jun 2012 16:45:38 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Fix inet6_csk_route_req() to use as the flowi6_oif the treq->iif,
which is correctly fixed up in tcp_v6_conn_request() to handle the
case of link-local addresses. This brings it in line with the
tcp_v6_send_synack() code, which is already correctly using the
treq->iif in this way.

Signed-off-by: Neal Cardwell <ncardwell@google.com>
---
 net/ipv6/inet6_connection_sock.c |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/net/ipv6/inet6_connection_sock.c b/net/ipv6/inet6_connection_sock.c
index e6cee52..e23d354 100644
--- a/net/ipv6/inet6_connection_sock.c
+++ b/net/ipv6/inet6_connection_sock.c
@@ -68,7 +68,7 @@ struct dst_entry *inet6_csk_route_req(struct sock *sk,
 	fl6.daddr = treq->rmt_addr;
 	final_p = fl6_update_dst(&fl6, np->opt, &final);
 	fl6.saddr = treq->loc_addr;
-	fl6.flowi6_oif = sk->sk_bound_dev_if;
+	fl6.flowi6_oif = treq->iif;
 	fl6.flowi6_mark = sk->sk_mark;
 	fl6.fl6_dport = inet_rsk(req)->rmt_port;
 	fl6.fl6_sport = inet_rsk(req)->loc_port;
-- 
1.7.4.1
