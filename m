From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: [PATCH] ipv6: fix sparse errors in ip6_make_flowlabel()
Date: Wed, 04 Feb 2015 15:03:25 -0800
Message-ID: <1423091005.31870.26.camel@edumazet-glaptop2.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev <netdev@vger.kernel.org>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ie0-f174.google.com ([209.85.223.174]:46710 "EHLO
	mail-ie0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S966688AbbBDXD1 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 4 Feb 2015 18:03:27 -0500
Received: by mail-ie0-f174.google.com with SMTP id vy18so6022718iec.5
        for <netdev@vger.kernel.org>; Wed, 04 Feb 2015 15:03:27 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <edumazet@google.com>

include/net/ipv6.h:713:22: warning: incorrect type in assignment (different base types)
include/net/ipv6.h:713:22:    expected restricted __be32 [usertype] hash
include/net/ipv6.h:713:22:    got unsigned int
include/net/ipv6.h:719:25: warning: restricted __be32 degrades to integer
include/net/ipv6.h:719:22: warning: invalid assignment: ^=
include/net/ipv6.h:719:22:    left side has type restricted __be32
include/net/ipv6.h:719:22:    right side has type unsigned int

Signed-off-by: Eric Dumazet <edumazet@google.com>
---
 include/net/ipv6.h |    4 ++--
 1 file changed, 2 insertions(+), 2 deletions(-)

diff --git a/include/net/ipv6.h b/include/net/ipv6.h
index 8027ca53e31f5903e055c425fef097ca9ccaa173..a419d766e9b538ab5eda9f4c3ee5e6244de5cf7e 100644
--- a/include/net/ipv6.h
+++ b/include/net/ipv6.h
@@ -708,7 +708,7 @@ static inline __be32 ip6_make_flowlabel(struct net *net, struct sk_buff *skb,
 					__be32 flowlabel, bool autolabel)
 {
 	if (!flowlabel && (autolabel || net->ipv6.sysctl.auto_flowlabels)) {
-		__be32 hash;
+		u32 hash;
 
 		hash = skb_get_hash(skb);
 
@@ -718,7 +718,7 @@ static inline __be32 ip6_make_flowlabel(struct net *net, struct sk_buff *skb,
 		 */
 		hash ^= hash >> 12;
 
-		flowlabel = hash & IPV6_FLOWLABEL_MASK;
+		flowlabel = (__force __be32)hash & IPV6_FLOWLABEL_MASK;
 	}
 
 	return flowlabel;
