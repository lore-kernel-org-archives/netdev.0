From: Andreas Gruenbacher <agruenba@redhat.com>
Subject: [PATCH] rhashtable: Documentation tweak
Date: Tue, 19 Sep 2017 12:41:37 +0200
Message-ID: <20170919104137.22916-1-agruenba@redhat.com>
Cc: netdev@vger.kernel.org, Andreas Gruenbacher <agruenba@redhat.com>
To: Thomas Graf <tgraf@suug.ch>,
        Herbert Xu <herbert@gondor.apana.org.au>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:44130 "EHLO mx1.redhat.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1751284AbdISKlk (ORCPT <rfc822;netdev@vger.kernel.org>);
        Tue, 19 Sep 2017 06:41:40 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Clarify that rhashtable_walk_{stop,start} will not reset the iterator to
the beginning of the hash table.  Confusion between rhashtable_walk_enter
and rhashtable_walk_start has already lead to a bug.

Signed-off-by: Andreas Gruenbacher <agruenba@redhat.com>
---
 lib/rhashtable.c | 9 +++++----
 1 file changed, 5 insertions(+), 4 deletions(-)

diff --git a/lib/rhashtable.c b/lib/rhashtable.c
index 707ca5d677c6..ddd7dde87c3c 100644
--- a/lib/rhashtable.c
+++ b/lib/rhashtable.c
@@ -735,9 +735,9 @@ EXPORT_SYMBOL_GPL(rhashtable_walk_exit);
  * rhashtable_walk_start - Start a hash table walk
  * @iter:	Hash table iterator
  *
- * Start a hash table walk.  Note that we take the RCU lock in all
- * cases including when we return an error.  So you must always call
- * rhashtable_walk_stop to clean up.
+ * Start a hash table walk at the current iterator position.  Note that we take
+ * the RCU lock in all cases including when we return an error.  So you must
+ * always call rhashtable_walk_stop to clean up.
  *
  * Returns zero if successful.
  *
@@ -846,7 +846,8 @@ EXPORT_SYMBOL_GPL(rhashtable_walk_next);
  * rhashtable_walk_stop - Finish a hash table walk
  * @iter:	Hash table iterator
  *
- * Finish a hash table walk.
+ * Finish a hash table walk.  Does not reset the iterator to the start of the
+ * hash table.
  */
 void rhashtable_walk_stop(struct rhashtable_iter *iter)
 	__releases(RCU)
-- 
2.13.3
