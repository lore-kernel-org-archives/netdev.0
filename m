From: Neal Cardwell <ncardwell@google.com>
Subject: [PATCH 1/5] tcp: heed result of security_inet_conn_request() in tcp_v6_conn_request()
Date: Sun, 24 Jun 2012 01:22:00 -0400
Message-ID: <1340515324-2152-1-git-send-email-ncardwell@google.com>
Cc: netdev@vger.kernel.org, Eric Dumazet <edumazet@google.com>,
	Tom Herbert <therbert@google.com>,
	Neal Cardwell <ncardwell@google.com>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qc0-f202.google.com ([209.85.216.202]:63744 "EHLO
	mail-qc0-f202.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751932Ab2FXFWO (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 24 Jun 2012 01:22:14 -0400
Received: by qcsu6 with SMTP id u6so40309qcs.1
        for <netdev@vger.kernel.org>; Sat, 23 Jun 2012 22:22:13 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

If security_inet_conn_request() returns non-zero then TCP/IPv6 should
drop the request, just as in TCP/IPv4 and DCCP in both IPv4 and IPv6.

Signed-off-by: Neal Cardwell <ncardwell@google.com>
---
 net/ipv6/tcp_ipv6.c |    3 ++-
 1 files changed, 2 insertions(+), 1 deletions(-)

diff --git a/net/ipv6/tcp_ipv6.c b/net/ipv6/tcp_ipv6.c
index 3a9aec2..9df64a5 100644
--- a/net/ipv6/tcp_ipv6.c
+++ b/net/ipv6/tcp_ipv6.c
@@ -1212,7 +1212,8 @@ have_isn:
 	tcp_rsk(req)->snt_isn = isn;
 	tcp_rsk(req)->snt_synack = tcp_time_stamp;
 
-	security_inet_conn_request(sk, skb, req);
+	if (security_inet_conn_request(sk, skb, req))
+		goto drop_and_release;
 
 	if (tcp_v6_send_synack(sk, req,
 			       (struct request_values *)&tmp_ext,
-- 
1.7.7.3
