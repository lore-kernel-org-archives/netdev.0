From: Eric Dumazet <edumazet@google.com>
Subject: [PATCH net-next 05/17] ipv6: constify ip6_dst_lookup_{flow|tail}() sock arguments
Date: Fri, 25 Sep 2015 07:39:12 -0700
Message-ID: <1443191964-923-6-git-send-email-edumazet@google.com>
References: <1443191964-923-1-git-send-email-edumazet@google.com>
Cc: netdev <netdev@vger.kernel.org>,
	Eric Dumazet <edumazet@google.com>,
	Eric Dumazet <edumazet@gmail.com>
To: "David S . Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f51.google.com ([209.85.220.51]:35550 "EHLO
	mail-pa0-f51.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932113AbbIYOkL (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 25 Sep 2015 10:40:11 -0400
Received: by pacfv12 with SMTP id fv12so109574443pac.2
        for <netdev@vger.kernel.org>; Fri, 25 Sep 2015 07:40:00 -0700 (PDT)
In-Reply-To: <1443191964-923-1-git-send-email-edumazet@google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

ip6_dst_lookup_flow() and ip6_dst_lookup_tail() do not touch
socket, lets add a const qualifier.

This will permit the same change in inet6_csk_route_req()

Signed-off-by: Eric Dumazet <edumazet@google.com>
---
 include/net/ipv6.h    | 2 +-
 net/ipv6/ip6_output.c | 4 ++--
 2 files changed, 3 insertions(+), 3 deletions(-)

diff --git a/include/net/ipv6.h b/include/net/ipv6.h
index 384a93cf07d6..9877b68ad207 100644
--- a/include/net/ipv6.h
+++ b/include/net/ipv6.h
@@ -849,7 +849,7 @@ static inline struct sk_buff *ip6_finish_skb(struct sock *sk)
 
 int ip6_dst_lookup(struct net *net, struct sock *sk, struct dst_entry **dst,
 		   struct flowi6 *fl6);
-struct dst_entry *ip6_dst_lookup_flow(struct sock *sk, struct flowi6 *fl6,
+struct dst_entry *ip6_dst_lookup_flow(const struct sock *sk, struct flowi6 *fl6,
 				      const struct in6_addr *final_dst);
 struct dst_entry *ip6_sk_dst_lookup_flow(struct sock *sk, struct flowi6 *fl6,
 					 const struct in6_addr *final_dst);
diff --git a/net/ipv6/ip6_output.c b/net/ipv6/ip6_output.c
index 291a07be5dfb..6b0d86f3fbfc 100644
--- a/net/ipv6/ip6_output.c
+++ b/net/ipv6/ip6_output.c
@@ -883,7 +883,7 @@ out:
 	return dst;
 }
 
-static int ip6_dst_lookup_tail(struct net *net, struct sock *sk,
+static int ip6_dst_lookup_tail(struct net *net, const struct sock *sk,
 			       struct dst_entry **dst, struct flowi6 *fl6)
 {
 #ifdef CONFIG_IPV6_OPTIMISTIC_DAD
@@ -1014,7 +1014,7 @@ EXPORT_SYMBOL_GPL(ip6_dst_lookup);
  *	It returns a valid dst pointer on success, or a pointer encoded
  *	error code.
  */
-struct dst_entry *ip6_dst_lookup_flow(struct sock *sk, struct flowi6 *fl6,
+struct dst_entry *ip6_dst_lookup_flow(const struct sock *sk, struct flowi6 *fl6,
 				      const struct in6_addr *final_dst)
 {
 	struct dst_entry *dst = NULL;
-- 
2.6.0.rc2.230.g3dd15c0
