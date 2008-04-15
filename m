From: Allan Stephens <allan.stephens@windriver.com>
Subject: [PATCH 4/7 net-2.6.26] [TIPC]: Remove redundant NULL check when discarding buffers
Date: Tue, 15 Apr 2008 15:43:54 -0400
Message-ID: <1208288637-15304-5-git-send-email-allan.stephens@windriver.com>
References: <1208288637-15304-1-git-send-email-allan.stephens@windriver.com>
Cc: netdev@vger.kernel.org, allan.stephens@windriver.com
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.windriver.com ([147.11.1.11]:46949 "EHLO mail.wrs.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756362AbYDOTpy (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 15 Apr 2008 15:45:54 -0400
In-Reply-To: <1208288637-15304-1-git-send-email-allan.stephens@windriver.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patch eliminates a null pointer check when discarding a
TIPC message buffer, since kfree_skb() already handles this
situation.

Acknowledgements to Florian Westphal (fw@strlen.de> for
suggesting this enhancement.

Signed-off-by: Allan Stephens <allan.stephens@windriver.com>
---
 net/tipc/core.h |    3 +--
 1 files changed, 1 insertions(+), 2 deletions(-)

diff --git a/net/tipc/core.h b/net/tipc/core.h
index 3fe9b70..3229d29 100644
--- a/net/tipc/core.h
+++ b/net/tipc/core.h
@@ -334,8 +334,7 @@ static inline struct sk_buff *buf_acquire(u32 size)
 
 static inline void buf_discard(struct sk_buff *skb)
 {
-	if (likely(skb != NULL))
-		kfree_skb(skb);
+	kfree_skb(skb);
 }
 
 #endif
-- 
1.5.3.2

