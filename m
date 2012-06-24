From: Neal Cardwell <ncardwell@google.com>
Subject: [PATCH 2/5] tcp: fix inet6_csk_route_req() for link-local addresses
Date: Sun, 24 Jun 2012 01:22:01 -0400
Message-ID: <1340515324-2152-2-git-send-email-ncardwell@google.com>
References: <1340515324-2152-1-git-send-email-ncardwell@google.com>
Cc: netdev@vger.kernel.org, Eric Dumazet <edumazet@google.com>,
	Tom Herbert <therbert@google.com>,
	Neal Cardwell <ncardwell@google.com>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-yx0-f202.google.com ([209.85.213.202]:60566 "EHLO
	mail-yx0-f202.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753502Ab2FXFWR (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 24 Jun 2012 01:22:17 -0400
Received: by yenl3 with SMTP id l3so382444yen.1
        for <netdev@vger.kernel.org>; Sat, 23 Jun 2012 22:22:17 -0700 (PDT)
In-Reply-To: <1340515324-2152-1-git-send-email-ncardwell@google.com>
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
1.7.7.3
