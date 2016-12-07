From: Pablo Neira Ayuso <pablo@netfilter.org>
Subject: [PATCH 01/50] ipvs: Use IS_ERR_OR_NULL(svc) instead of IS_ERR(svc) || svc == NULL
Date: Wed,  7 Dec 2016 22:52:07 +0100
Message-ID: <1481147576-5690-2-git-send-email-pablo@netfilter.org>
References: <1481147576-5690-1-git-send-email-pablo@netfilter.org>
Cc: davem@davemloft.net, netdev@vger.kernel.org
To: netfilter-devel@vger.kernel.org
Return-path: <netfilter-devel-owner@vger.kernel.org>
In-Reply-To: <1481147576-5690-1-git-send-email-pablo@netfilter.org>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Gao Feng <fgao@ikuai8.com>

This minor refactoring does not change the logic of function
ip_vs_genl_dump_dests.

Signed-off-by: Gao Feng <fgao@ikuai8.com>
Acked-by: Julian Anastasov <ja@ssi.bg>
Signed-off-by: Simon Horman <horms@verge.net.au>
---
 net/netfilter/ipvs/ip_vs_ctl.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/net/netfilter/ipvs/ip_vs_ctl.c b/net/netfilter/ipvs/ip_vs_ctl.c
index 6b85ded4f91d..217e0105b5e0 100644
--- a/net/netfilter/ipvs/ip_vs_ctl.c
+++ b/net/netfilter/ipvs/ip_vs_ctl.c
@@ -3260,7 +3260,7 @@ static int ip_vs_genl_dump_dests(struct sk_buff *skb,
 
 
 	svc = ip_vs_genl_find_service(ipvs, attrs[IPVS_CMD_ATTR_SERVICE]);
-	if (IS_ERR(svc) || svc == NULL)
+	if (IS_ERR_OR_NULL(svc))
 		goto out_err;
 
 	/* Dump the destinations */
-- 
2.1.4

