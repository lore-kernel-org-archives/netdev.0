From: Ying Xue <ying.xue@windriver.com>
Subject: [PATCH net-next 3/5] rhashtable: use future table
	size to make expansion decision
Date: Tue, 6 Jan 2015 15:23:21 +0800
Message-ID: <1420529003-22244-4-git-send-email-ying.xue@windriver.com>
References: <1420529003-22244-1-git-send-email-ying.xue@windriver.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: jon.maloy@ericsson.com, netdev@vger.kernel.org,
	Paul.Gortmaker@windriver.com,
	tipc-discussion@lists.sourceforge.net, davem@davemloft.net
To: <tgraf@suug.ch>
Return-path: <tipc-discussion-bounces@lists.sourceforge.net>
In-Reply-To: <1420529003-22244-1-git-send-email-ying.xue@windriver.com>
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/tipc-discussion>,
	<mailto:tipc-discussion-request@lists.sourceforge.net?subject=unsubscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum_name=tipc-discussion>
List-Post: <mailto:tipc-discussion@lists.sourceforge.net>
List-Help: <mailto:tipc-discussion-request@lists.sourceforge.net?subject=help>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/tipc-discussion>,
	<mailto:tipc-discussion-request@lists.sourceforge.net?subject=subscribe>
Errors-To: tipc-discussion-bounces@lists.sourceforge.net
List-Id: netdev.vger.kernel.org

Should use future table size instead of old table size to decide
whether hash table is worth being expanded.

Signed-off-by: Ying Xue <ying.xue@windriver.com>
Cc: Thomas Graf <tgraf@suug.ch>
---
 lib/rhashtable.c |    5 +++--
 1 file changed, 3 insertions(+), 2 deletions(-)

diff --git a/lib/rhashtable.c b/lib/rhashtable.c
index 6eda22f..f5288b1 100644
--- a/lib/rhashtable.c
+++ b/lib/rhashtable.c
@@ -478,13 +478,14 @@ EXPORT_SYMBOL_GPL(rhashtable_shrink);
 static void rht_deferred_worker(struct work_struct *work)
 {
 	struct rhashtable *ht;
-	struct bucket_table *tbl;
+	struct bucket_table *tbl, *new_tbl;
 
 	ht = container_of(work, struct rhashtable, run_work.work);
 	mutex_lock(&ht->mutex);
 	tbl = rht_dereference(ht->tbl, ht);
+	new_tbl = rht_dereference(ht->future_tbl, ht);
 
-	if (ht->p.grow_decision && ht->p.grow_decision(ht, tbl->size))
+	if (ht->p.grow_decision && ht->p.grow_decision(ht, new_tbl->size))
 		rhashtable_expand(ht);
 	else if (ht->p.shrink_decision && ht->p.shrink_decision(ht, tbl->size))
 		rhashtable_shrink(ht);
-- 
1.7.9.5


------------------------------------------------------------------------------
Dive into the World of Parallel Programming! The Go Parallel Website,
sponsored by Intel and developed in partnership with Slashdot Media, is your
hub for all things parallel software development, from weekly thought
leadership blogs to news, videos, case studies, tutorials and more. Take a
look and join the conversation now. http://goparallel.sourceforge.net
