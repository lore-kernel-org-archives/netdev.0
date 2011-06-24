From: Paul Gortmaker <paul.gortmaker@windriver.com>
Subject: [PATCH net-next 07/20] tipc: Eliminate message header routines for caching destination node
Date: Fri, 24 Jun 2011 18:07:14 -0400
Message-ID: <1308953247-25266-8-git-send-email-paul.gortmaker@windriver.com>
References: <1308953247-25266-1-git-send-email-paul.gortmaker@windriver.com>
Cc: netdev@vger.kernel.org, Allan.Stephens@windriver.com,
	Allan Stephens <allan.stephens@windriver.com>,
	Paul Gortmaker <paul.gortmaker@windriver.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.windriver.com ([147.11.1.11]:34375 "EHLO
	mail.windriver.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756960Ab1FXWHp (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 24 Jun 2011 18:07:45 -0400
In-Reply-To: <1308953247-25266-1-git-send-email-paul.gortmaker@windriver.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Allan Stephens <allan.stephens@windriver.com>

Gets rid of a pair of routines that provide support for temporarily
caching the destination node for a message in the associated message
buffer's application handle, since this capability is no longer used.

Signed-off-by: Allan Stephens <allan.stephens@windriver.com>
Signed-off-by: Paul Gortmaker <paul.gortmaker@windriver.com>
---
 net/tipc/msg.h |   20 --------------------
 1 files changed, 0 insertions(+), 20 deletions(-)

diff --git a/net/tipc/msg.h b/net/tipc/msg.h
index 8452454..11b74dc 100644
--- a/net/tipc/msg.h
+++ b/net/tipc/msg.h
@@ -311,26 +311,6 @@ static inline void msg_set_seqno(struct tipc_msg *m, u32 n)
 }
 
 /*
- * TIPC may utilize the "link ack #" and "link seq #" fields of a short
- * message header to hold the destination node for the message, since the
- * normal "dest node" field isn't present.  This cache is only referenced
- * when required, so populating the cache of a longer message header is
- * harmless (as long as the header has the two link sequence fields present).
- *
- * Note: Host byte order is OK here, since the info never goes off-card.
- */
-
-static inline u32 msg_destnode_cache(struct tipc_msg *m)
-{
-	return m->hdr[2];
-}
-
-static inline void msg_set_destnode_cache(struct tipc_msg *m, u32 dnode)
-{
-	m->hdr[2] = dnode;
-}
-
-/*
  * Words 3-10
  */
 
-- 
1.7.4.4

