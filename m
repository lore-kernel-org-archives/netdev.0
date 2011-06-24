From: Paul Gortmaker <paul.gortmaker@windriver.com>
Subject: [PATCH net-next 15/20] tipc: Eliminate useless check when creating internal message
Date: Fri, 24 Jun 2011 18:07:22 -0400
Message-ID: <1308953247-25266-16-git-send-email-paul.gortmaker@windriver.com>
References: <1308953247-25266-1-git-send-email-paul.gortmaker@windriver.com>
Cc: netdev@vger.kernel.org, Allan.Stephens@windriver.com,
	Allan Stephens <allan.stephens@windriver.com>,
	Paul Gortmaker <paul.gortmaker@windriver.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.windriver.com ([147.11.1.11]:34411 "EHLO
	mail.windriver.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756994Ab1FXWHx (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 24 Jun 2011 18:07:53 -0400
In-Reply-To: <1308953247-25266-1-git-send-email-paul.gortmaker@windriver.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Allan Stephens <allan.stephens@windriver.com>

Gets rid of code that allows tipc_msg_init() to create a short
payload message header. This optimization is possible because
there are no longer any callers who require this capability.

Signed-off-by: Allan Stephens <allan.stephens@windriver.com>
Signed-off-by: Paul Gortmaker <paul.gortmaker@windriver.com>
---
 net/tipc/msg.c |    6 ++----
 1 files changed, 2 insertions(+), 4 deletions(-)

diff --git a/net/tipc/msg.c b/net/tipc/msg.c
index 03e57bf..83d5096 100644
--- a/net/tipc/msg.c
+++ b/net/tipc/msg.c
@@ -61,10 +61,8 @@ void tipc_msg_init(struct tipc_msg *m, u32 user, u32 type,
 	msg_set_size(m, hsize);
 	msg_set_prevnode(m, tipc_own_addr);
 	msg_set_type(m, type);
-	if (!msg_short(m)) {
-		msg_set_orignode(m, tipc_own_addr);
-		msg_set_destnode(m, destnode);
-	}
+	msg_set_orignode(m, tipc_own_addr);
+	msg_set_destnode(m, destnode);
 }
 
 /**
-- 
1.7.4.4

