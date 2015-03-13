From: Thomas Graf <tgraf@suug.ch>
Subject: [PATCH 3/3 net-next] rhashtable: Annotate RCU locking of walkers
Date: Fri, 13 Mar 2015 15:45:21 +0100
Message-ID: <80f94a90a175b0ad94af60fcd4ef8efc92ca61c6.1426257747.git.tgraf@suug.ch>
References: <cover.1426257747.git.tgraf@suug.ch>
Cc: netdev@vger.kernel.org, herbert@gondor.apana.org.au,
	daniel@iogearbox.net
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from bombadil.infradead.org ([198.137.202.9]:59841 "EHLO
	bombadil.infradead.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751889AbbCMOpc (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 13 Mar 2015 10:45:32 -0400
In-Reply-To: <cover.1426257747.git.tgraf@suug.ch>
In-Reply-To: <cover.1426257747.git.tgraf@suug.ch>
References: <cover.1426257747.git.tgraf@suug.ch>
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
index 4de97e1f..d87b989 100644
--- a/lib/rhashtable.c
+++ b/lib/rhashtable.c
@@ -762,6 +762,7 @@ EXPORT_SYMBOL_GPL(rhashtable_walk_exit);
  * by calling rhashtable_walk_next.
  */
 int rhashtable_walk_start(struct rhashtable_iter *iter)
+	__acquires(RCU)
 {
 	struct rhashtable *ht = iter->ht;
 
@@ -849,6 +850,7 @@ EXPORT_SYMBOL_GPL(rhashtable_walk_next);
  * Finish a hash table walk.
  */
 void rhashtable_walk_stop(struct rhashtable_iter *iter)
+	__releases(RCU)
 {
 	struct rhashtable *ht;
 	struct bucket_table *tbl = iter->walker->tbl;
-- 
1.9.3
