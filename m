From: Allan Stephens <allan.stephens@windriver.com>
Subject: [PATCH 5/7 net-2.6.26] [TIPC]: Use fast buffer cloning to improve performance
Date: Tue, 15 Apr 2008 15:43:55 -0400
Message-ID: <1208288637-15304-6-git-send-email-allan.stephens@windriver.com>
References: <1208288637-15304-1-git-send-email-allan.stephens@windriver.com>
Cc: netdev@vger.kernel.org, allan.stephens@windriver.com
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.windriver.com ([147.11.1.11]:46957 "EHLO mail.wrs.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755826AbYDOTpy (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 15 Apr 2008 15:45:54 -0400
In-Reply-To: <1208288637-15304-1-git-send-email-allan.stephens@windriver.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patch causes TIPC to allocate fast clonable sk_buffs,
rather than standard ones.  This speeds up the cloning
operation done by the link code each time a message is sent
off-node.

Signed-off-by: Allan Stephens <allan.stephens@windriver.com>
---
 net/tipc/core.h |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/net/tipc/core.h b/net/tipc/core.h
index 3229d29..b3c9df3 100644
--- a/net/tipc/core.h
+++ b/net/tipc/core.h
@@ -316,7 +316,7 @@ static inline struct sk_buff *buf_acquire(u32 size)
 	struct sk_buff *skb;
 	unsigned int buf_size = (BUF_HEADROOM + size + 3) & ~3u;
 
-	skb = alloc_skb(buf_size, GFP_ATOMIC);
+	skb = alloc_skb_fclone(buf_size, GFP_ATOMIC);
 	if (skb) {
 		skb_reserve(skb, BUF_HEADROOM);
 		skb_put(skb, size);
-- 
1.5.3.2

