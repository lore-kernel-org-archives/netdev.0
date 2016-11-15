From: Simon Horman <horms@verge.net.au>
Subject: [PATCH nf-next 1/2] ipvs: Use IS_ERR_OR_NULL(svc) instead of IS_ERR(svc) || svc == NULL
Date: Tue, 15 Nov 2016 10:01:42 +0100
Message-ID: <1479200503-25842-2-git-send-email-horms@verge.net.au>
References: <1479200503-25842-1-git-send-email-horms@verge.net.au>
Cc: lvs-devel@vger.kernel.org, netdev@vger.kernel.org,
        netfilter-devel@vger.kernel.org,
        Wensong Zhang <wensong@linux-vs.org>,
        Julian Anastasov <ja@ssi.bg>, Gao Feng <fgao@ikuai8.com>,
        Simon Horman <horms@verge.net.au>
To: Pablo Neira Ayuso <pablo@netfilter.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from kirsty.vergenet.net ([202.4.237.240]:47538 "EHLO
        kirsty.vergenet.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S937351AbcKOJCB (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 15 Nov 2016 04:02:01 -0500
In-Reply-To: <1479200503-25842-1-git-send-email-horms@verge.net.au>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

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
2.7.0.rc3.207.g0ac5344
