From: Paul Gortmaker <paul.gortmaker@windriver.com>
Subject: [PATCH net-next 07/17] tipc: Eliminate a test for negative unsigned quantities
Date: Wed, 29 Feb 2012 18:18:33 -0500
Message-ID: <1330557523-2024-8-git-send-email-paul.gortmaker@windriver.com>
References: <1330557523-2024-1-git-send-email-paul.gortmaker@windriver.com>
Cc: netdev@vger.kernel.org, allan.stephens@windriver.com,
	ying.xue@windriver.com,
	Paul Gortmaker <paul.gortmaker@windriver.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.windriver.com ([147.11.1.11]:53956 "EHLO
	mail.windriver.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S965311Ab2B2XTC (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 29 Feb 2012 18:19:02 -0500
In-Reply-To: <1330557523-2024-1-git-send-email-paul.gortmaker@windriver.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Allan Stephens <allan.stephens@windriver.com>

Simplifies a comparison operation to eliminate a useless test that
checks if an unsigned value is less than zero.

Signed-off-by: Allan Stephens <allan.stephens@windriver.com>
Signed-off-by: Paul Gortmaker <paul.gortmaker@windriver.com>
---
 net/tipc/bearer.c |    3 +--
 1 files changed, 1 insertions(+), 2 deletions(-)

diff --git a/net/tipc/bearer.c b/net/tipc/bearer.c
index 329fb65..5f5e89e 100644
--- a/net/tipc/bearer.c
+++ b/net/tipc/bearer.c
@@ -456,8 +456,7 @@ int tipc_enable_bearer(const char *name, u32 disc_domain, u32 priority)
 		warn("Bearer <%s> rejected, illegal discovery domain\n", name);
 		return -EINVAL;
 	}
-	if ((priority < TIPC_MIN_LINK_PRI ||
-	     priority > TIPC_MAX_LINK_PRI) &&
+	if ((priority > TIPC_MAX_LINK_PRI) &&
 	    (priority != TIPC_MEDIA_LINK_PRI)) {
 		warn("Bearer <%s> rejected, illegal priority\n", name);
 		return -EINVAL;
-- 
1.7.9.1
