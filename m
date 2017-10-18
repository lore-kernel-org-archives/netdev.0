From: Ard Biesheuvel <ard.biesheuvel@linaro.org>
Subject: [PATCH] lib/dynamic_queue_limits.c: relax BUG_ON to WARN_ON in dql_complete()
Date: Wed, 18 Oct 2017 16:45:15 +0100
Message-ID: <20171018154515.16751-1-ard.biesheuvel@linaro.org>
Cc: Ard Biesheuvel <ard.biesheuvel@linaro.org>
To: linux-kernel@vger.kernel.org, netdev@vger.kernel.org,
        davem@davemloft.net
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Even though calling dql_completed() with a count that exceeds the
queued count is a serious error, it still does not justify bringing
down the entire kernel with a BUG_ON(). So relax it to a WARN_ON()
instead.

Signed-off-by: Ard Biesheuvel <ard.biesheuvel@linaro.org>
---
 lib/dynamic_queue_limits.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/lib/dynamic_queue_limits.c b/lib/dynamic_queue_limits.c
index f346715e2255..24ce495d78f3 100644
--- a/lib/dynamic_queue_limits.c
+++ b/lib/dynamic_queue_limits.c
@@ -23,7 +23,7 @@ void dql_completed(struct dql *dql, unsigned int count)
 	num_queued = ACCESS_ONCE(dql->num_queued);
 
 	/* Can't complete more than what's in queue */
-	BUG_ON(count > num_queued - dql->num_completed);
+	WARN_ON(count > num_queued - dql->num_completed);
 
 	completed = dql->num_completed + count;
 	limit = dql->limit;
-- 
2.11.0
