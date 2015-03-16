From: Thomas Graf <tgraf@suug.ch>
Subject: [PATCH 2/2 net-next] rhashtable: Annotate RCU locking of walkers
Date: Mon, 16 Mar 2015 10:42:27 +0100
Message-ID: <a04b70711ea826e6fa2ddf14369768ead310f59d.1426494808.git.tgraf@suug.ch>
References: <cover.1426494808.git.tgraf@suug.ch>
Cc: netdev@vger.kernel.org, herbert@gondor.apana.org.au
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from casper.infradead.org ([85.118.1.10]:41861 "EHLO
	casper.infradead.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750862AbbCPJmb (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 16 Mar 2015 05:42:31 -0400
In-Reply-To: <cover.1426494808.git.tgraf@suug.ch>
In-Reply-To: <cover.1426494808.git.tgraf@suug.ch>
References: <cover.1426494808.git.tgraf@suug.ch>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Fixes the following sparse warnings:

lib/rhashtable.c:767:5: warning: context imbalance in 'rhashtable_walk_start' - wrong count at exit
lib/rhashtable.c:849:6: warning: context imbalance in 'rhashtable_walk_stop' - unexpected unlock

Fixes: f2dba9c6ff0d ("rhashtable: Introduce rhashtable_walk_*")
Signed-off-by: Thomas Graf <tgraf@suug.ch>
---
 lib/rhashtable.c | 2 ++
 1 file changed, 2 insertions(+)

diff --git a/lib/rhashtable.c b/lib/rhashtable.c
index e396d7e..09a7ada 100644
--- a/lib/rhashtable.c
+++ b/lib/rhashtable.c
@@ -759,6 +759,7 @@ EXPORT_SYMBOL_GPL(rhashtable_walk_exit);
  * by calling rhashtable_walk_next.
  */
 int rhashtable_walk_start(struct rhashtable_iter *iter)
+	__acquires(RCU)
 {
 	struct rhashtable *ht = iter->ht;
 
@@ -846,6 +847,7 @@ EXPORT_SYMBOL_GPL(rhashtable_walk_next);
  * Finish a hash table walk.
  */
 void rhashtable_walk_stop(struct rhashtable_iter *iter)
+	__releases(RCU)
 {
 	struct rhashtable *ht;
 	struct bucket_table *tbl = iter->walker->tbl;
-- 
1.9.3
