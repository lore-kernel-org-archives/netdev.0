From: Paul Gortmaker <paul.gortmaker@windriver.com>
Subject: [PATCH net-next 4/9] tipc: manually inline single use media_name_valid routine
Date: Thu, 16 Aug 2012 18:09:09 -0400
Message-ID: <1345154954-12526-5-git-send-email-paul.gortmaker@windriver.com>
References: <1345154954-12526-1-git-send-email-paul.gortmaker@windriver.com>
Cc: netdev@vger.kernel.org, Jon Maloy <jon.maloy@ericsson.com>,
	Ying Xue <ying.xue@windriver.com>,
	Paul Gortmaker <paul.gortmaker@windriver.com>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.windriver.com ([147.11.1.11]:57489 "EHLO
	mail.windriver.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754119Ab2HPWOv (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 16 Aug 2012 18:14:51 -0400
In-Reply-To: <1345154954-12526-1-git-send-email-paul.gortmaker@windriver.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Ying Xue <ying.xue@windriver.com>

After eliminating the mechanism which checks whether all letters
in media name string are within a given character set, the
media_name_valid routine becomes trivial.  It is also only
used once, so it is unnecessary to keep it as a separate function.

Signed-off-by: Ying Xue <ying.xue@windriver.com>
Signed-off-by: Jon Maloy <jon.maloy@ericsson.com>
Signed-off-by: Paul Gortmaker <paul.gortmaker@windriver.com>
---
 net/tipc/bearer.c | 17 +----------------
 1 file changed, 1 insertion(+), 16 deletions(-)

diff --git a/net/tipc/bearer.c b/net/tipc/bearer.c
index 6b2faa5..4ec5c80 100644
--- a/net/tipc/bearer.c
+++ b/net/tipc/bearer.c
@@ -49,21 +49,6 @@ struct tipc_bearer tipc_bearers[MAX_BEARERS];
 static void bearer_disable(struct tipc_bearer *b_ptr);
 
 /**
- * media_name_valid - validate media name
- *
- * Returns 1 if media name is valid, otherwise 0.
- */
-static int media_name_valid(const char *name)
-{
-	u32 len;
-
-	len = strlen(name);
-	if ((len + 1) > TIPC_MAX_MEDIA_NAME)
-		return 0;
-	return 1;
-}
-
-/**
  * tipc_media_find - locates specified media object by name
  */
 struct tipc_media *tipc_media_find(const char *name)
@@ -102,7 +87,7 @@ int tipc_register_media(struct tipc_media *m_ptr)
 
 	write_lock_bh(&tipc_net_lock);
 
-	if (!media_name_valid(m_ptr->name))
+	if ((strlen(m_ptr->name) + 1) > TIPC_MAX_MEDIA_NAME)
 		goto exit;
 	if ((m_ptr->bcast_addr.media_id != m_ptr->type_id) ||
 	    !m_ptr->bcast_addr.broadcast)
-- 
1.7.11.1
