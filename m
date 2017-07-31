From: Shaohua Li <shli@kernel.org>
Subject: [PATCH V4 net 1/2] net: remove unnecessary rotation
Date: Mon, 31 Jul 2017 15:19:22 -0700
Message-ID: <0ffd86784b6bc5209d592ea57c0b14f51bfbdc24.1501539150.git.shli@fb.com>
References: <cover.1501539150.git.shli@fb.com>
Cc: Shaohua Li <shli@fb.com>
To: netdev@vger.kernel.org, davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.kernel.org ([198.145.29.99]:47166 "EHLO mail.kernel.org"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1751339AbdGaWT1 (ORCPT <rfc822;netdev@vger.kernel.org>);
        Mon, 31 Jul 2017 18:19:27 -0400
In-Reply-To: <cover.1501539150.git.shli@fb.com>
In-Reply-To: <cover.1501539150.git.shli@fb.com>
References: <cover.1501539150.git.shli@fb.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Shaohua Li <shli@fb.com>

According to David Miller, the rotation doesn't really help avoid
security problem, so delte it.

Suggested-by: David Miller <davem@davemloft.net>
Signed-off-by: Shaohua Li <shli@fb.com>
---
 include/net/ipv6.h | 6 ------
 1 file changed, 6 deletions(-)

diff --git a/include/net/ipv6.h b/include/net/ipv6.h
index 6eac5cf..7548367 100644
--- a/include/net/ipv6.h
+++ b/include/net/ipv6.h
@@ -790,12 +790,6 @@ static inline __be32 ip6_make_flowlabel(struct net *net, struct sk_buff *skb,
 
 	hash = skb_get_hash_flowi6(skb, fl6);
 
-	/* Since this is being sent on the wire obfuscate hash a bit
-	 * to minimize possbility that any useful information to an
-	 * attacker is leaked. Only lower 20 bits are relevant.
-	 */
-	rol32(hash, 16);
-
 	flowlabel = (__force __be32)hash & IPV6_FLOWLABEL_MASK;
 
 	if (net->ipv6.sysctl.flowlabel_state_ranges)
-- 
2.9.3
