From: fgao@ikuai8.com
Subject: [PATCH 1/1] netfilter: Use IS_ERR_OR_NULL instead of IS_ERR and NULl check to simplify the codes in ip_vs_genl_dump_dests and resolve_normal_ct
Date: Thu, 21 Jul 2016 22:09:19 +0800
Message-ID: <1469110159-19200-1-git-send-email-fgao@ikuai8.com>
Cc: gfree.wind@gmail.com, Gao Feng <fgao@ikuai8.com>
To: pablo@netfilter.org, kaber@trash.net,
	netfilter-devel@vger.kernel.org, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from SMTPBG351.QQ.COM ([183.57.50.165]:42456 "EHLO smtpbg351.qq.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751429AbcGUOXD (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 21 Jul 2016 10:23:03 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Gao Feng <fgao@ikuai8.com>

Signed-off-by: Gao Feng <fgao@ikuai8.com>
---
 v1: Initial Version

 net/netfilter/ipvs/ip_vs_ctl.c    | 2 +-
 net/netfilter/nf_conntrack_core.c | 6 ++----
 2 files changed, 3 insertions(+), 5 deletions(-)

diff --git a/net/netfilter/ipvs/ip_vs_ctl.c b/net/netfilter/ipvs/ip_vs_ctl.c
index c3c809b..6dc86cc 100644
--- a/net/netfilter/ipvs/ip_vs_ctl.c
+++ b/net/netfilter/ipvs/ip_vs_ctl.c
@@ -3267,7 +3267,7 @@ static int ip_vs_genl_dump_dests(struct sk_buff *skb,
 
 
 	svc = ip_vs_genl_find_service(ipvs, attrs[IPVS_CMD_ATTR_SERVICE]);
-	if (IS_ERR(svc) || svc == NULL)
+	if (IS_ERR_OR_NULL(svc))
 		goto out_err;
 
 	/* Dump the destinations */
diff --git a/net/netfilter/nf_conntrack_core.c b/net/netfilter/nf_conntrack_core.c
index 153e33f..634d592 100644
--- a/net/netfilter/nf_conntrack_core.c
+++ b/net/netfilter/nf_conntrack_core.c
@@ -1108,10 +1108,8 @@ resolve_normal_ct(struct net *net, struct nf_conn *tmpl,
 	if (!h) {
 		h = init_conntrack(net, tmpl, &tuple, l3proto, l4proto,
 				   skb, dataoff, hash);
-		if (!h)
-			return NULL;
-		if (IS_ERR(h))
-			return (void *)h;
+		if (IS_ERR_OR_NULL(h))
+			return ERR_CAST(h);
 	}
 	ct = nf_ct_tuplehash_to_ctrack(h);
 
-- 
1.9.1
