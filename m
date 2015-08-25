From: Santosh Shilimkar <santosh.shilimkar@oracle.com>
Subject: [PATCH 1/6] RDS: fix the dangling reference to rds_ib_incoming_slab
Date: Tue, 25 Aug 2015 12:01:58 -0700
Message-ID: <1440529323-4171-2-git-send-email-santosh.shilimkar@oracle.com>
References: <1440529323-4171-1-git-send-email-santosh.shilimkar@oracle.com>
Cc: linux-kernel@vger.kernel.org, davem@davemloft.net,
	ssantosh@kernel.org,
	Santosh Shilimkar <santosh.shilimkar@oracle.com>
To: netdev@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1440529323-4171-1-git-send-email-santosh.shilimkar@oracle.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On rds_ib_frag_slab allocation failure, ensure rds_ib_incoming_slab
is not pointing to the detsroyed memory.

Signed-off-by: Santosh Shilimkar <ssantosh@kernel.org>
Signed-off-by: Santosh Shilimkar <santosh.shilimkar@oracle.com>
---
 net/rds/ib_recv.c | 5 +++--
 1 file changed, 3 insertions(+), 2 deletions(-)

diff --git a/net/rds/ib_recv.c b/net/rds/ib_recv.c
index 3afdcbd..26015eb 100644
--- a/net/rds/ib_recv.c
+++ b/net/rds/ib_recv.c
@@ -1102,9 +1102,10 @@ int rds_ib_recv_init(void)
 	rds_ib_frag_slab = kmem_cache_create("rds_ib_frag",
 					sizeof(struct rds_page_frag),
 					0, SLAB_HWCACHE_ALIGN, NULL);
-	if (!rds_ib_frag_slab)
+	if (!rds_ib_frag_slab) {
 		kmem_cache_destroy(rds_ib_incoming_slab);
-	else
+		rds_ib_incoming_slab = NULL;
+	} else
 		ret = 0;
 out:
 	return ret;
-- 
1.9.1
