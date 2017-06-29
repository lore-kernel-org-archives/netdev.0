From: Pablo Neira Ayuso <pablo@netfilter.org>
Subject: [PATCH 28/29] netfilter: nf_tables: reduce chain type table size
Date: Fri, 30 Jun 2017 00:53:26 +0200
Message-ID: <1498776807-11124-29-git-send-email-pablo@netfilter.org>
References: <1498776807-11124-1-git-send-email-pablo@netfilter.org>
Cc: davem@davemloft.net, netdev@vger.kernel.org
To: netfilter-devel@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.us.es ([193.147.175.20]:57662 "EHLO mail.us.es"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1752409AbdF2Wx6 (ORCPT <rfc822;netdev@vger.kernel.org>);
        Thu, 29 Jun 2017 18:53:58 -0400
Received: from antivirus1-rhel7.int (unknown [192.168.2.11])
        by mail.us.es (Postfix) with ESMTP id 62BA8BDF5A
        for <netdev@vger.kernel.org>; Fri, 30 Jun 2017 00:53:47 +0200 (CEST)
Received: from antivirus1-rhel7.int (localhost [127.0.0.1])
        by antivirus1-rhel7.int (Postfix) with ESMTP id 5406BD1CA3
        for <netdev@vger.kernel.org>; Fri, 30 Jun 2017 00:53:47 +0200 (CEST)
Received: from antivirus1-rhel7.int (localhost [127.0.0.1])
        by antivirus1-rhel7.int (Postfix) with ESMTP id 26396D1CAB
        for <netdev@vger.kernel.org>; Fri, 30 Jun 2017 00:53:45 +0200 (CEST)
In-Reply-To: <1498776807-11124-1-git-send-email-pablo@netfilter.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Florian Westphal <fw@strlen.de>

text  data  bss     dec    hex filename
old: 151590  2240 1152  154982  25d66 net/netfilter/nf_tables_api.o
new: 151666  2240  416  154322  25ad2 net/netfilter/nf_tables_api.o

Signed-off-by: Florian Westphal <fw@strlen.de>
Signed-off-by: Pablo Neira Ayuso <pablo@netfilter.org>
---
 net/netfilter/nf_tables_api.c | 5 ++++-
 1 file changed, 4 insertions(+), 1 deletion(-)

diff --git a/net/netfilter/nf_tables_api.c b/net/netfilter/nf_tables_api.c
index bc8f03a53734..5f3339978f6b 100644
--- a/net/netfilter/nf_tables_api.c
+++ b/net/netfilter/nf_tables_api.c
@@ -387,7 +387,7 @@ static inline u64 nf_tables_alloc_handle(struct nft_table *table)
 	return ++table->hgenerator;
 }
 
-static const struct nf_chain_type *chain_type[AF_MAX][NFT_CHAIN_T_MAX];
+static const struct nf_chain_type *chain_type[NFPROTO_NUMPROTO][NFT_CHAIN_T_MAX];
 
 static const struct nf_chain_type *
 __nf_tables_chain_type_lookup(int family, const struct nlattr *nla)
@@ -870,6 +870,9 @@ int nft_register_chain_type(const struct nf_chain_type *ctype)
 {
 	int err = 0;
 
+	if (WARN_ON(ctype->family >= NFPROTO_NUMPROTO))
+		return -EINVAL;
+
 	nfnl_lock(NFNL_SUBSYS_NFTABLES);
 	if (chain_type[ctype->family][ctype->type] != NULL) {
 		err = -EBUSY;
-- 
2.1.4
