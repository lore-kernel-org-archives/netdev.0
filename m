From: Johannes Berg <johannes@sipsolutions.net>
Subject: [PATCH v2] ipv6: suppress sparse warnings in IP6_ECN_set_ce()
Date: Fri, 12 Aug 2016 07:48:21 +0200
Message-ID: <1470980901-26786-1-git-send-email-johannes@sipsolutions.net>
Cc: Eric Dumazet <edumazet@google.com>,
	Johannes Berg <johannes.berg@intel.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from s3.sipsolutions.net ([5.9.151.49]:58053 "EHLO sipsolutions.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750878AbcHLFs1 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 12 Aug 2016 01:48:27 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Johannes Berg <johannes.berg@intel.com>

Pass the correct type __wsum to csum_sub() and csum_add(). This doesn't
really change anything since __wsum really *is* __be32, but removes the
address space warnings from sparse.

Cc: Eric Dumazet <edumazet@google.com>
Fixes: 34ae6a1aa054 ("ipv6: update skb->csum when CE mark is propagated")
Signed-off-by: Johannes Berg <johannes.berg@intel.com>
---
 include/net/inet_ecn.h | 3 ++-
 1 file changed, 2 insertions(+), 1 deletion(-)

diff --git a/include/net/inet_ecn.h b/include/net/inet_ecn.h
index 0dc0a51da38f..dce2d586d9ce 100644
--- a/include/net/inet_ecn.h
+++ b/include/net/inet_ecn.h
@@ -128,7 +128,8 @@ static inline int IP6_ECN_set_ce(struct sk_buff *skb, struct ipv6hdr *iph)
 	to = from | htonl(INET_ECN_CE << 20);
 	*(__be32 *)iph = to;
 	if (skb->ip_summed == CHECKSUM_COMPLETE)
-		skb->csum = csum_add(csum_sub(skb->csum, from), to);
+		skb->csum = csum_add(csum_sub(skb->csum, (__force __wsum)from),
+				     (__force __wsum)to);
 	return 1;
 }
 
-- 
2.8.1
