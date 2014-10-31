From: Pablo Neira Ayuso <pablo@netfilter.org>
Subject: [PATCH 2/6] netfilter: nf_tables_bridge: update hook_mask to allow {pre,post}routing
Date: Fri, 31 Oct 2014 13:18:28 +0100
Message-ID: <1414757912-29150-3-git-send-email-pablo@netfilter.org>
References: <1414757912-29150-1-git-send-email-pablo@netfilter.org>
Cc: davem@davemloft.net, netdev@vger.kernel.org
To: netfilter-devel@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.us.es ([193.147.175.20]:48108 "EHLO mail.us.es"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1759349AbaJaMRS (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 31 Oct 2014 08:17:18 -0400
In-Reply-To: <1414757912-29150-1-git-send-email-pablo@netfilter.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Fixes: 36d2af5 ("netfilter: nf_tables: allow to filter from prerouting and postrouting")
Signed-off-by: Pablo Neira Ayuso <pablo@netfilter.org>
---
 net/bridge/netfilter/nf_tables_bridge.c |    6 ++++--
 1 file changed, 4 insertions(+), 2 deletions(-)

diff --git a/net/bridge/netfilter/nf_tables_bridge.c b/net/bridge/netfilter/nf_tables_bridge.c
index da17a5e..074c557 100644
--- a/net/bridge/netfilter/nf_tables_bridge.c
+++ b/net/bridge/netfilter/nf_tables_bridge.c
@@ -75,9 +75,11 @@ static const struct nf_chain_type filter_bridge = {
 	.type		= NFT_CHAIN_T_DEFAULT,
 	.family		= NFPROTO_BRIDGE,
 	.owner		= THIS_MODULE,
-	.hook_mask	= (1 << NF_BR_LOCAL_IN) |
+	.hook_mask	= (1 << NF_BR_PRE_ROUTING) |
+			  (1 << NF_BR_LOCAL_IN) |
 			  (1 << NF_BR_FORWARD) |
-			  (1 << NF_BR_LOCAL_OUT),
+			  (1 << NF_BR_LOCAL_OUT) |
+			  (1 << NF_BR_POST_ROUTING),
 };
 
 static int __init nf_tables_bridge_init(void)
-- 
1.7.10.4
