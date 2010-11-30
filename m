From: Paul Gortmaker <paul.gortmaker@windriver.com>
Subject: [PATCH net-next 04/11] tipc: Eliminate useless return value when disabling a bearer
Date: Tue, 30 Nov 2010 17:00:56 -0500
Message-ID: <1291154463-26346-5-git-send-email-paul.gortmaker@windriver.com>
References: <1291154463-26346-1-git-send-email-paul.gortmaker@windriver.com>
Cc: netdev@vger.kernel.org, allan.stephens@windriver.com
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.windriver.com ([147.11.1.11]:58707 "EHLO
	mail.windriver.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752545Ab0K3WBL (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 30 Nov 2010 17:01:11 -0500
In-Reply-To: <1291154463-26346-1-git-send-email-paul.gortmaker@windriver.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Allan Stephens <Allan.Stephens@windriver.com>

Modifies bearer_disable() to return void since it always indicates
success anyway.

Signed-off-by: Allan Stephens <Allan.Stephens@windriver.com>
Signed-off-by: Paul Gortmaker <paul.gortmaker@windriver.com>
---
 net/tipc/bearer.c |    9 +++++----
 1 files changed, 5 insertions(+), 4 deletions(-)

diff --git a/net/tipc/bearer.c b/net/tipc/bearer.c
index 347f255..885da94 100644
--- a/net/tipc/bearer.c
+++ b/net/tipc/bearer.c
@@ -622,7 +622,7 @@ int tipc_block_bearer(const char *name)
  * Note: This routine assumes caller holds tipc_net_lock.
  */
 
-static int bearer_disable(struct bearer *b_ptr)
+static void bearer_disable(struct bearer *b_ptr)
 {
 	struct link *l_ptr;
 	struct link *temp_l_ptr;
@@ -638,7 +638,6 @@ static int bearer_disable(struct bearer *b_ptr)
 	}
 	spin_unlock_bh(&b_ptr->publ.lock);
 	memset(b_ptr, 0, sizeof(struct bearer));
-	return 0;
 }
 
 int tipc_disable_bearer(const char *name)
@@ -651,8 +650,10 @@ int tipc_disable_bearer(const char *name)
 	if (b_ptr == NULL) {
 		warn("Attempt to disable unknown bearer <%s>\n", name);
 		res = -EINVAL;
-	} else
-		res = bearer_disable(b_ptr);
+	} else {
+		bearer_disable(b_ptr);
+		res = 0;
+	}
 	write_unlock_bh(&tipc_net_lock);
 	return res;
 }
-- 
1.7.3.2.146.g2d444

