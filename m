From: Eric Dumazet <edumazet@google.com>
Subject: [PATCH v2 net-next 2/3] inet_diag: adjust inet_sk_diag_fill() bug condition
Date: Fri, 13 Mar 2015 15:51:11 -0700
Message-ID: <1426287072-22175-3-git-send-email-edumazet@google.com>
References: <1426287072-22175-1-git-send-email-edumazet@google.com>
Cc: netdev@vger.kernel.org, Eric Dumazet <edumazet@google.com>
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qg0-f73.google.com ([209.85.192.73]:33607 "EHLO
	mail-qg0-f73.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756989AbbCMW6s (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 13 Mar 2015 18:58:48 -0400
Received: by qgdz107 with SMTP id z107so4317178qgd.0
        for <netdev@vger.kernel.org>; Fri, 13 Mar 2015 15:58:48 -0700 (PDT)
In-Reply-To: <1426287072-22175-1-git-send-email-edumazet@google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

inet_sk_diag_fill() only copes with non timewait and non request socks

Signed-off-by: Eric Dumazet <edumazet@google.com>
---
 net/ipv4/inet_diag.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/net/ipv4/inet_diag.c b/net/ipv4/inet_diag.c
index e1e4d8c0384a..d827fe2e3ce0 100644
--- a/net/ipv4/inet_diag.c
+++ b/net/ipv4/inet_diag.c
@@ -93,7 +93,7 @@ int inet_sk_diag_fill(struct sock *sk, struct inet_connection_sock *icsk,
 		return -EMSGSIZE;
 
 	r = nlmsg_data(nlh);
-	BUG_ON(sk->sk_state == TCP_TIME_WAIT);
+	BUG_ON((1 << sk->sk_state) & (TCPF_TIME_WAIT | TCPF_NEW_SYN_RECV));
 
 	r->idiag_family = sk->sk_family;
 	r->idiag_state = sk->sk_state;
-- 
2.2.0.rc0.207.ga3a616c
