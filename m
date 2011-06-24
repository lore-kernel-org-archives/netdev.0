From: Paul Gortmaker <paul.gortmaker@windriver.com>
Subject: [PATCH net-next 08/20] tipc: Eliminate redundant masking in message header routines
Date: Fri, 24 Jun 2011 18:07:15 -0400
Message-ID: <1308953247-25266-9-git-send-email-paul.gortmaker@windriver.com>
References: <1308953247-25266-1-git-send-email-paul.gortmaker@windriver.com>
Cc: netdev@vger.kernel.org, Allan.Stephens@windriver.com,
	Allan Stephens <allan.stephens@windriver.com>,
	Paul Gortmaker <paul.gortmaker@windriver.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.windriver.com ([147.11.1.11]:34378 "EHLO
	mail.windriver.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757304Ab1FXWHq (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 24 Jun 2011 18:07:46 -0400
In-Reply-To: <1308953247-25266-1-git-send-email-paul.gortmaker@windriver.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Allan Stephens <allan.stephens@windriver.com>

Gets rid of unnecessary masking in two routines that set TIPC message
header fields. (The msg_set_bits() routine already takes care of
masking the new value to the correct size.)

Signed-off-by: Allan Stephens <allan.stephens@windriver.com>
Signed-off-by: Paul Gortmaker <paul.gortmaker@windriver.com>
---
 net/tipc/msg.h |    4 ++--
 1 files changed, 2 insertions(+), 2 deletions(-)

diff --git a/net/tipc/msg.h b/net/tipc/msg.h
index 11b74dc..a58975c 100644
--- a/net/tipc/msg.h
+++ b/net/tipc/msg.h
@@ -615,7 +615,7 @@ static inline u32 msg_link_selector(struct tipc_msg *m)
 
 static inline void msg_set_link_selector(struct tipc_msg *m, u32 n)
 {
-	msg_set_bits(m, 4, 0, 1, (n & 1));
+	msg_set_bits(m, 4, 0, 1, n);
 }
 
 /*
@@ -639,7 +639,7 @@ static inline u32 msg_probe(struct tipc_msg *m)
 
 static inline void msg_set_probe(struct tipc_msg *m, u32 val)
 {
-	msg_set_bits(m, 5, 0, 1, (val & 1));
+	msg_set_bits(m, 5, 0, 1, val);
 }
 
 static inline char msg_net_plane(struct tipc_msg *m)
-- 
1.7.4.4

