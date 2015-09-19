From: Santosh Shilimkar <santosh.shilimkar@oracle.com>
Subject: [PATCH 05/15] RDS: increase size of hash-table to 8K
Date: Sat, 19 Sep 2015 19:04:42 -0400
Message-ID: <1442703892-26692-6-git-send-email-santosh.shilimkar@oracle.com>
References: <1442703892-26692-1-git-send-email-santosh.shilimkar@oracle.com>
Cc: linux-kernel@vger.kernel.org, davem@davemloft.net,
	ssantosh@kernel.org,
	Santosh Shilimkar <santosh.shilimkar@oracle.com>
To: netdev@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1442703892-26692-1-git-send-email-santosh.shilimkar@oracle.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Even with per bucket locking scheme, in a massive parallel
system with active rds sockets which could be in excess of multiple
of 10K, rds_bin_lookup() workload is siginificant because of smaller
hashtable size.

With some tests, it was found that we get modest but still nice
reduction in rds_bind_lookup with bigger bucket.

	Hashtable	Baseline(1k)	Delta
	2048:		8.28%     	-2.45%
	4096:		8.28%		-4.60%
	8192:		8.28%		-6.46%
	16384:		8.28%		-6.75%

Based on the data, we set 8K as the bind hash-table size.

Signed-off-by: Santosh Shilimkar <ssantosh@kernel.org>
Signed-off-by: Santosh Shilimkar <santosh.shilimkar@oracle.com>
---
 net/rds/bind.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/net/rds/bind.c b/net/rds/bind.c
index bc6b93e..fb2d545 100644
--- a/net/rds/bind.c
+++ b/net/rds/bind.c
@@ -43,7 +43,7 @@ struct bind_bucket {
 	struct hlist_head	head;
 };
 
-#define BIND_HASH_SIZE 1024
+#define BIND_HASH_SIZE 8192
 static struct bind_bucket bind_hash_table[BIND_HASH_SIZE];
 
 static struct bind_bucket *hash_to_bucket(__be32 addr, __be16 port)
-- 
1.9.1
