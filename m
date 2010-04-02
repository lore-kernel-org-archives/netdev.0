From: Brian Haley <brian.haley@hp.com>
Subject: [PATCH] SCTP: Change to use ipv6_addr_copy()
Date: Fri,  2 Apr 2010 17:38:58 -0400
Message-ID: <1270244338-4190-1-git-send-email-brian.haley@hp.com>
Cc: netdev@vger.kernel.org, linux-sctp@vger.kernel.org
To: vladislav.yasevich@hp.com, davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from g1t0026.austin.hp.com ([15.216.28.33]:48010 "EHLO
	g1t0026.austin.hp.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754811Ab0DBVjA (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 2 Apr 2010 17:39:00 -0400
In-Reply-To: <>
References: <>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Change SCTP IPv6 code to use ipv6_addr_copy()

Signed-off-by: Brian Haley <brian.haley@hp.com>
---
 net/sctp/ipv6.c |    8 ++++----
 1 files changed, 4 insertions(+), 4 deletions(-)

diff --git a/net/sctp/ipv6.c b/net/sctp/ipv6.c
index 216d88f..db1c767 100644
--- a/net/sctp/ipv6.c
+++ b/net/sctp/ipv6.c
@@ -364,7 +364,7 @@ static void sctp_v6_copy_addrlist(struct list_head *addrlist,
 		if (addr) {
 			addr->a.v6.sin6_family = AF_INET6;
 			addr->a.v6.sin6_port = 0;
-			addr->a.v6.sin6_addr = ifp->addr;
+			ipv6_addr_copy(&addr->a.v6.sin6_addr, &ifp->addr);
 			addr->a.v6.sin6_scope_id = dev->ifindex;
 			addr->valid = 1;
 			INIT_LIST_HEAD(&addr->list);
@@ -405,7 +405,7 @@ static void sctp_v6_from_sk(union sctp_addr *addr, struct sock *sk)
 {
 	addr->v6.sin6_family = AF_INET6;
 	addr->v6.sin6_port = 0;
-	addr->v6.sin6_addr = inet6_sk(sk)->rcv_saddr;
+	ipv6_addr_copy(&addr->v6.sin6_addr, &inet6_sk(sk)->rcv_saddr);
 }
 
 /* Initialize sk->sk_rcv_saddr from sctp_addr. */
@@ -418,7 +418,7 @@ static void sctp_v6_to_sk_saddr(union sctp_addr *addr, struct sock *sk)
 		inet6_sk(sk)->rcv_saddr.s6_addr32[3] =
 			addr->v4.sin_addr.s_addr;
 	} else {
-		inet6_sk(sk)->rcv_saddr = addr->v6.sin6_addr;
+		ipv6_addr_copy(&inet6_sk(sk)->rcv_saddr, &addr->v6.sin6_addr);
 	}
 }
 
@@ -431,7 +431,7 @@ static void sctp_v6_to_sk_daddr(union sctp_addr *addr, struct sock *sk)
 		inet6_sk(sk)->daddr.s6_addr32[2] = htonl(0x0000ffff);
 		inet6_sk(sk)->daddr.s6_addr32[3] = addr->v4.sin_addr.s_addr;
 	} else {
-		inet6_sk(sk)->daddr = addr->v6.sin6_addr;
+		ipv6_addr_copy(&inet6_sk(sk)->daddr, &addr->v6.sin6_addr);
 	}
 }
 
-- 
1.5.4.3

