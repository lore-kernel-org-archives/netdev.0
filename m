From: Arvind Yadav <arvind.yadav.cs@gmail.com>
Subject: [PATCH] netfilter: nat: constify rhashtable_params
Date: Wed, 30 Aug 2017 17:18:04 +0530
Message-ID: <d978194ca83e9aa41a330a42442eecd8be9e9a60.1504093452.git.arvind.yadav.cs@gmail.com>
Cc: linux-kernel@vger.kernel.org, netdev@vger.kernel.org,
        coreteam@netfilter.org, netfilter-devel@vger.kernel.org
To: davem@davemloft.net, fw@strlen.de, kadlec@blackhole.kfki.hu,
        pablo@netfilter.org
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

rhashtable_params are not supposed to change at runtime. All
Functions rhashtable_* working with const rhashtable_params
provided by <linux/rhashtable.h>. So mark the non-const structs
as const.

Signed-off-by: Arvind Yadav <arvind.yadav.cs@gmail.com>
---
 net/netfilter/nf_nat_core.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/net/netfilter/nf_nat_core.c b/net/netfilter/nf_nat_core.c
index eb54178..d1f355e 100644
--- a/net/netfilter/nf_nat_core.c
+++ b/net/netfilter/nf_nat_core.c
@@ -198,7 +198,7 @@ static int nf_nat_bysource_cmp(struct rhashtable_compare_arg *arg,
 	return 0;
 }
 
-static struct rhashtable_params nf_nat_bysource_params = {
+static const struct rhashtable_params nf_nat_bysource_params = {
 	.head_offset = offsetof(struct nf_conn, nat_bysource),
 	.obj_hashfn = nf_nat_bysource_hash,
 	.obj_cmpfn = nf_nat_bysource_cmp,
-- 
1.9.1
