From: Phil Sutter <phil@nwl.cc>
Subject: [PATCH] net: inet_diag: always export IPV6_V6ONLY sockopt
Date: Thu,  9 Jul 2015 10:42:27 +0200
Message-ID: <1436431347-720-1-git-send-email-phil@nwl.cc>
Cc: davem@davemloft.net, Eric Dumazet <edumazet@google.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from orbit.nwl.cc ([176.31.251.142]:55729 "EHLO mail.nwl.cc"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751525AbbGIIma (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 9 Jul 2015 04:42:30 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Reconsidering my commit 20462155 "net: inet_diag: export IPV6_V6ONLY
sockopt", I am not happy with the limitations it causes for socket
analysing code in userspace. Exporting the value only if it is set makes
it hard for userspace to decide whether the option is not set or the
kernel does not support exporting the option at all.

>From an auditor's perspective, the interesting question for AF_INET6
sockets is: "Does it NOT have IPV6_V6ONLY set?" Because it is the
unexpected case. This patch allows to answer this question reliably.

Signed-off-by: Phil Sutter <phil@nwl.cc>
Cc: Eric Dumazet <edumazet@google.com>
---
 net/ipv4/inet_diag.c | 3 +--
 1 file changed, 1 insertion(+), 2 deletions(-)

diff --git a/net/ipv4/inet_diag.c b/net/ipv4/inet_diag.c
index 9bc2667..e622d2e 100644
--- a/net/ipv4/inet_diag.c
+++ b/net/ipv4/inet_diag.c
@@ -152,8 +152,7 @@ int inet_sk_diag_fill(struct sock *sk, struct inet_connection_sock *icsk,
 				       inet6_sk(sk)->tclass) < 0)
 				goto errout;
 
-		if (ipv6_only_sock(sk) &&
-		    nla_put_u8(skb, INET_DIAG_SKV6ONLY, 1))
+		if (nla_put_u8(skb, INET_DIAG_SKV6ONLY, ipv6_only_sock(sk)))
 			goto errout;
 	}
 #endif
-- 
2.1.2
