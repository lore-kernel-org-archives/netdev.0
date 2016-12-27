From: Marcelo Ricardo Leitner <marcelo.leitner@gmail.com>
Subject: [PATCH net-next 3/5] sctp: simplify addr copy
Date: Tue, 27 Dec 2016 15:08:30 -0200
Message-ID: <dd32e257f5edc5395e3bc6eb3ed4999c822aaefa.1482857832.git.marcelo.leitner@gmail.com>
References: <cover.1482857832.git.marcelo.leitner@gmail.com>
Cc: linux-sctp@vger.kernel.org, Vlad Yasevich <vyasevich@gmail.com>,
        Neil Horman <nhorman@tuxdriver.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qk0-f195.google.com ([209.85.220.195]:35478 "EHLO
        mail-qk0-f195.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1753065AbcL0RKe (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 27 Dec 2016 12:10:34 -0500
In-Reply-To: <cover.1482857832.git.marcelo.leitner@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Make it a bit easier to read.

Signed-off-by: Marcelo Ricardo Leitner <marcelo.leitner@gmail.com>
---
 net/sctp/ipv6.c     | 16 +++++++---------
 net/sctp/protocol.c | 18 +++++++-----------
 2 files changed, 14 insertions(+), 20 deletions(-)

diff --git a/net/sctp/ipv6.c b/net/sctp/ipv6.c
index 176af3080a2b8f8ffc56b55f3ccb13a169e195fe..434167ac0c8e89078b0bac80f0a81da92be37e07 100644
--- a/net/sctp/ipv6.c
+++ b/net/sctp/ipv6.c
@@ -412,22 +412,20 @@ static void sctp_v6_copy_addrlist(struct list_head *addrlist,
 static void sctp_v6_from_skb(union sctp_addr *addr, struct sk_buff *skb,
 			     int is_saddr)
 {
-	__be16 *port;
-	struct sctphdr *sh;
+	/* Always called on head skb, so this is safe */
+	struct sctphdr *sh = sctp_hdr(skb);
+	struct sockaddr_in6 *sa = &addr->v6;
 
-	port = &addr->v6.sin6_port;
 	addr->v6.sin6_family = AF_INET6;
 	addr->v6.sin6_flowinfo = 0; /* FIXME */
 	addr->v6.sin6_scope_id = ((struct inet6_skb_parm *)skb->cb)->iif;
 
-	/* Always called on head skb, so this is safe */
-	sh = sctp_hdr(skb);
 	if (is_saddr) {
-		*port  = sh->source;
-		addr->v6.sin6_addr = ipv6_hdr(skb)->saddr;
+		sa->sin6_port = sh->source;
+		sa->sin6_addr = ipv6_hdr(skb)->saddr;
 	} else {
-		*port = sh->dest;
-		addr->v6.sin6_addr = ipv6_hdr(skb)->daddr;
+		sa->sin6_port = sh->dest;
+		sa->sin6_addr = ipv6_hdr(skb)->daddr;
 	}
 }
 
diff --git a/net/sctp/protocol.c b/net/sctp/protocol.c
index ad40fa153878f354a367b5cefa2ccd4322463eb2..fe6c62607e99961b5b3bf524b6f6f46d4be3251d 100644
--- a/net/sctp/protocol.c
+++ b/net/sctp/protocol.c
@@ -237,23 +237,19 @@ int sctp_copy_local_addr_list(struct net *net, struct sctp_bind_addr *bp,
 static void sctp_v4_from_skb(union sctp_addr *addr, struct sk_buff *skb,
 			     int is_saddr)
 {
-	void *from;
-	__be16 *port;
-	struct sctphdr *sh;
+	/* Always called on head skb, so this is safe */
+	struct sctphdr *sh = sctp_hdr(skb);
+	struct sockaddr_in *sa = &addr->v4;
 
-	port = &addr->v4.sin_port;
 	addr->v4.sin_family = AF_INET;
 
-	/* Always called on head skb, so this is safe */
-	sh = sctp_hdr(skb);
 	if (is_saddr) {
-		*port  = sh->source;
-		from = &ip_hdr(skb)->saddr;
+		sa->sin_port = sh->source;
+		sa->sin_addr.s_addr = ip_hdr(skb)->saddr;
 	} else {
-		*port = sh->dest;
-		from = &ip_hdr(skb)->daddr;
+		sa->sin_port = sh->dest;
+		sa->sin_addr.s_addr = ip_hdr(skb)->daddr;
 	}
-	memcpy(&addr->v4.sin_addr.s_addr, from, sizeof(struct in_addr));
 }
 
 /* Initialize an sctp_addr from a socket. */
-- 
2.9.3
