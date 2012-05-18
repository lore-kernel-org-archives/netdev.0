From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: [PATCH net-next] ip_frag: struct inet_frags match() method returns
 a bool
Date: Fri, 18 May 2012 05:57:13 +0200
Message-ID: <1337313433.3403.73.camel@edumazet-glaptop>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev <netdev@vger.kernel.org>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-we0-f174.google.com ([74.125.82.174]:39489 "EHLO
	mail-we0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1760418Ab2ERD5R (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 17 May 2012 23:57:17 -0400
Received: by weyu7 with SMTP id u7so1552318wey.19
        for <netdev@vger.kernel.org>; Thu, 17 May 2012 20:57:16 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <edumazet@google.com>

- match() method returns a boolean
- return (A && B && C && D) -> return A && B && C && D
- fix indentation

Signed-off-by: Eric Dumazet <edumazet@google.com>
---
 include/net/inet_frag.h |    3 +--
 include/net/ipv6.h      |    2 +-
 net/ipv4/ip_fragment.c  |   10 +++++-----
 net/ipv6/reassembly.c   |    9 +++++----
 4 files changed, 12 insertions(+), 12 deletions(-)

diff --git a/include/net/inet_frag.h b/include/net/inet_frag.h
index 16ff29a..2431cf8 100644
--- a/include/net/inet_frag.h
+++ b/include/net/inet_frag.h
@@ -46,8 +46,7 @@ struct inet_frags {
 						void *arg);
 	void			(*destructor)(struct inet_frag_queue *);
 	void			(*skb_free)(struct sk_buff *);
-	int			(*match)(struct inet_frag_queue *q,
-						void *arg);
+	bool			(*match)(struct inet_frag_queue *q, void *arg);
 	void			(*frag_expire)(unsigned long data);
 };
 
diff --git a/include/net/ipv6.h b/include/net/ipv6.h
index 4332e9a..5f65e7c 100644
--- a/include/net/ipv6.h
+++ b/include/net/ipv6.h
@@ -387,7 +387,7 @@ struct ip6_create_arg {
 };
 
 void ip6_frag_init(struct inet_frag_queue *q, void *a);
-int ip6_frag_match(struct inet_frag_queue *q, void *a);
+bool ip6_frag_match(struct inet_frag_queue *q, void *a);
 
 static inline int ipv6_addr_any(const struct in6_addr *a)
 {
diff --git a/net/ipv4/ip_fragment.c b/net/ipv4/ip_fragment.c
index 9f9bd13..695b27f 100644
--- a/net/ipv4/ip_fragment.c
+++ b/net/ipv4/ip_fragment.c
@@ -148,17 +148,17 @@ static unsigned int ip4_hashfn(struct inet_frag_queue *q)
 	return ipqhashfn(ipq->id, ipq->saddr, ipq->daddr, ipq->protocol);
 }
 
-static int ip4_frag_match(struct inet_frag_queue *q, void *a)
+static bool ip4_frag_match(struct inet_frag_queue *q, void *a)
 {
 	struct ipq *qp;
 	struct ip4_create_arg *arg = a;
 
 	qp = container_of(q, struct ipq, q);
 	return	qp->id == arg->iph->id &&
-			qp->saddr == arg->iph->saddr &&
-			qp->daddr == arg->iph->daddr &&
-			qp->protocol == arg->iph->protocol &&
-			qp->user == arg->user;
+		qp->saddr == arg->iph->saddr &&
+		qp->daddr == arg->iph->daddr &&
+		qp->protocol == arg->iph->protocol &&
+		qp->user == arg->user;
 }
 
 /* Memory Tracking Functions. */
diff --git a/net/ipv6/reassembly.c b/net/ipv6/reassembly.c
index f1b86fd..5d32dfa 100644
--- a/net/ipv6/reassembly.c
+++ b/net/ipv6/reassembly.c
@@ -134,15 +134,16 @@ static unsigned int ip6_hashfn(struct inet_frag_queue *q)
 	return inet6_hash_frag(fq->id, &fq->saddr, &fq->daddr, ip6_frags.rnd);
 }
 
-int ip6_frag_match(struct inet_frag_queue *q, void *a)
+bool ip6_frag_match(struct inet_frag_queue *q, void *a)
 {
 	struct frag_queue *fq;
 	struct ip6_create_arg *arg = a;
 
 	fq = container_of(q, struct frag_queue, q);
-	return (fq->id == arg->id && fq->user == arg->user &&
-			ipv6_addr_equal(&fq->saddr, arg->src) &&
-			ipv6_addr_equal(&fq->daddr, arg->dst));
+	return	fq->id == arg->id &&
+		fq->user == arg->user &&
+		ipv6_addr_equal(&fq->saddr, arg->src) &&
+		ipv6_addr_equal(&fq->daddr, arg->dst);
 }
 EXPORT_SYMBOL(ip6_frag_match);
 
