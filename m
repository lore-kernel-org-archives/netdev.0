From: Paul Gortmaker <paul.gortmaker@windriver.com>
Subject: [PATCH net-next 14/15] tipc: Eliminate alteration of publication key during name table purging
Date: Mon,  6 Feb 2012 19:52:47 -0500
Message-ID: <1328575968-20643-15-git-send-email-paul.gortmaker@windriver.com>
References: <1328575968-20643-1-git-send-email-paul.gortmaker@windriver.com>
Cc: netdev@vger.kernel.org, allan.stephens@windriver.com,
	ying.xue@windriver.com,
	Paul Gortmaker <paul.gortmaker@windriver.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.windriver.com ([147.11.1.11]:50221 "EHLO
	mail.windriver.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756534Ab2BGAxT (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 6 Feb 2012 19:53:19 -0500
In-Reply-To: <1328575968-20643-1-git-send-email-paul.gortmaker@windriver.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Allan Stephens <allan.stephens@windriver.com>

Removes code that alters the publication key of a name table entry
that is being forcibly purged from TIPC's name table after contact
with the publishing node has been lost.

Current TIPC ensures that all defunct names are purged before
re-establishing contact with a failed node.  There used to be a risk
that the publication might be accidentally deleted because it might be
re-added to the name table before the purge operation was completed.
But now there is no longer a need to ensure that the new key is different
than the old one.

Signed-off-by: Allan Stephens <allan.stephens@windriver.com>
Signed-off-by: Paul Gortmaker <paul.gortmaker@windriver.com>
---
 net/tipc/name_distr.c |    4 ----
 1 files changed, 0 insertions(+), 4 deletions(-)

diff --git a/net/tipc/name_distr.c b/net/tipc/name_distr.c
index 98ebb37..acecfda 100644
--- a/net/tipc/name_distr.c
+++ b/net/tipc/name_distr.c
@@ -239,9 +239,6 @@ exit:
  *
  * Invoked for each publication issued by a newly failed node.
  * Removes publication structure from name table & deletes it.
- * In rare cases the link may have come back up again when this
- * function is called, and we have two items representing the same
- * publication. Nudge this item's key to distinguish it from the other.
  */
 
 static void named_purge_publ(struct publication *publ)
@@ -249,7 +246,6 @@ static void named_purge_publ(struct publication *publ)
 	struct publication *p;
 
 	write_lock_bh(&tipc_nametbl_lock);
-	publ->key += 1222345;
 	p = tipc_nametbl_remove_publ(publ->type, publ->lower,
 				     publ->node, publ->ref, publ->key);
 	if (p)
-- 
1.7.9
