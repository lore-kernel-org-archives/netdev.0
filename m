From: Pablo Neira Ayuso <pablo@netfilter.org>
Subject: [PATCH 6/9] netfilter: nf_tables: allow to filter from prerouting and postrouting
Date: Fri,  3 Oct 2014 19:20:21 +0200
Message-ID: <1412356824-6362-7-git-send-email-pablo@netfilter.org>
References: <1412356824-6362-1-git-send-email-pablo@netfilter.org>
Cc: davem@davemloft.net, netdev@vger.kernel.org
To: netfilter-devel@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.us.es ([193.147.175.20]:43893 "EHLO mail.us.es"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751283AbaJCRTb (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 3 Oct 2014 13:19:31 -0400
In-Reply-To: <1412356824-6362-1-git-send-email-pablo@netfilter.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This allows us to emulate the NAT table in ebtables, which is actually
a plain filter chain that hooks at prerouting, output and postrouting.

Signed-off-by: Pablo Neira Ayuso <pablo@netfilter.org>
---
 net/bridge/netfilter/nf_tables_bridge.c |    2 ++
 1 file changed, 2 insertions(+)

diff --git a/net/bridge/netfilter/nf_tables_bridge.c b/net/bridge/netfilter/nf_tables_bridge.c
index 5bcc0d8..da17a5e 100644
--- a/net/bridge/netfilter/nf_tables_bridge.c
+++ b/net/bridge/netfilter/nf_tables_bridge.c
@@ -34,9 +34,11 @@ static struct nft_af_info nft_af_bridge __read_mostly = {
 	.owner		= THIS_MODULE,
 	.nops		= 1,
 	.hooks		= {
+		[NF_BR_PRE_ROUTING]	= nft_do_chain_bridge,
 		[NF_BR_LOCAL_IN]	= nft_do_chain_bridge,
 		[NF_BR_FORWARD]		= nft_do_chain_bridge,
 		[NF_BR_LOCAL_OUT]	= nft_do_chain_bridge,
+		[NF_BR_POST_ROUTING]	= nft_do_chain_bridge,
 	},
 };
 
-- 
1.7.10.4
