From: Arvind Yadav <arvind.yadav.cs@gmail.com>
Subject: [PATCH] RDS: constify rhashtable_params
Date: Wed, 30 Aug 2017 17:19:51 +0530
Message-ID: <3cdaecc7c8080b0f2172d8788b96303528957b08.1504093495.git.arvind.yadav.cs@gmail.com>
Cc: linux-kernel@vger.kernel.org, rds-devel@oss.oracle.com,
        linux-rdma@vger.kernel.org, netdev@vger.kernel.org
To: davem@davemloft.net, santosh.shilimkar@oracle.com
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

rhashtable_params are not supposed to change at runtime. All
Functions rhashtable_* working with const rhashtable_params
provided by <linux/rhashtable.h>. So mark the non-const structs
as const.

Signed-off-by: Arvind Yadav <arvind.yadav.cs@gmail.com>
---
 net/rds/bind.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/net/rds/bind.c b/net/rds/bind.c
index 3a915be..75d43dc 100644
--- a/net/rds/bind.c
+++ b/net/rds/bind.c
@@ -40,7 +40,7 @@
 
 static struct rhashtable bind_hash_table;
 
-static struct rhashtable_params ht_parms = {
+static const struct rhashtable_params ht_parms = {
 	.nelem_hint = 768,
 	.key_len = sizeof(u64),
 	.key_offset = offsetof(struct rds_sock, rs_bound_key),
-- 
1.9.1
