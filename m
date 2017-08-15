From: Shaohua Li <shli@kernel.org>
Subject: [PATCH v5 net 1/2] net: remove unnecessary rotation
Date: Mon, 14 Aug 2017 19:53:20 -0700
Message-ID: <d5d7d41ab1b618832ad33be4a8d62967692f950a.1502761278.git.shli@fb.com>
References: <cover.1502761278.git.shli@fb.com>
Cc: Kernel-team@fb.com, Shaohua Li <shli@fb.com>
To: netdev@vger.kernel.org, davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.kernel.org ([198.145.29.99]:49846 "EHLO mail.kernel.org"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1752326AbdHOCxZ (ORCPT <rfc822;netdev@vger.kernel.org>);
        Mon, 14 Aug 2017 22:53:25 -0400
In-Reply-To: <cover.1502761278.git.shli@fb.com>
In-Reply-To: <cover.1502761278.git.shli@fb.com>
References: <cover.1502761278.git.shli@fb.com>
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
2.9.5
