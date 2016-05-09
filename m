From: Pablo Neira Ayuso <pablo@netfilter.org>
Subject: [PATCH 29/36] netfilter: nf_tables: allow set names up to 32 bytes
Date: Mon,  9 May 2016 20:46:47 +0200
Message-ID: <1462819614-5402-30-git-send-email-pablo@netfilter.org>
References: <1462819614-5402-1-git-send-email-pablo@netfilter.org>
Cc: davem@davemloft.net, netdev@vger.kernel.org
To: netfilter-devel@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.us.es ([193.147.175.20]:45787 "EHLO mail.us.es"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752714AbcEISrd (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 9 May 2016 14:47:33 -0400
Received: from antivirus1-rhel7.int (unknown [192.168.2.11])
	by mail.us.es (Postfix) with ESMTP id 6683DE8E89
	for <netdev@vger.kernel.org>; Mon,  9 May 2016 20:47:32 +0200 (CEST)
Received: from antivirus1-rhel7.int (localhost [127.0.0.1])
	by antivirus1-rhel7.int (Postfix) with ESMTP id 4D087134724
	for <netdev@vger.kernel.org>; Mon,  9 May 2016 20:47:32 +0200 (CEST)
Received: from antivirus1-rhel7.int (localhost [127.0.0.1])
	by antivirus1-rhel7.int (Postfix) with ESMTP id 86E8EFAB55
	for <netdev@vger.kernel.org>; Mon,  9 May 2016 20:47:29 +0200 (CEST)
In-Reply-To: <1462819614-5402-1-git-send-email-pablo@netfilter.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Currently, we support set names of up to 16 bytes, get this aligned
with the maximum length we can use in ipset to make it easier when
considering migration to nf_tables.

Signed-off-by: Pablo Neira Ayuso <pablo@netfilter.org>
---
 include/net/netfilter/nf_tables.h        | 2 +-
 include/uapi/linux/netfilter/nf_tables.h | 1 +
 net/netfilter/nf_tables_api.c            | 6 +++---
 3 files changed, 5 insertions(+), 4 deletions(-)

diff --git a/include/net/netfilter/nf_tables.h b/include/net/netfilter/nf_tables.h
index f6b1daf..0922354 100644
--- a/include/net/netfilter/nf_tables.h
+++ b/include/net/netfilter/nf_tables.h
@@ -303,7 +303,7 @@ void nft_unregister_set(struct nft_set_ops *ops);
 struct nft_set {
 	struct list_head		list;
 	struct list_head		bindings;
-	char				name[IFNAMSIZ];
+	char				name[NFT_SET_MAXNAMELEN];
 	u32				ktype;
 	u32				dtype;
 	u32				size;
diff --git a/include/uapi/linux/netfilter/nf_tables.h b/include/uapi/linux/netfilter/nf_tables.h
index 6602313..6a4dbe0 100644
--- a/include/uapi/linux/netfilter/nf_tables.h
+++ b/include/uapi/linux/netfilter/nf_tables.h
@@ -3,6 +3,7 @@
 
 #define NFT_TABLE_MAXNAMELEN	32
 #define NFT_CHAIN_MAXNAMELEN	32
+#define NFT_SET_MAXNAMELEN	32
 #define NFT_USERDATA_MAXLEN	256
 
 /**
diff --git a/net/netfilter/nf_tables_api.c b/net/netfilter/nf_tables_api.c
index 73c8fad..4d292b9 100644
--- a/net/netfilter/nf_tables_api.c
+++ b/net/netfilter/nf_tables_api.c
@@ -2317,7 +2317,7 @@ nft_select_set_ops(const struct nlattr * const nla[],
 static const struct nla_policy nft_set_policy[NFTA_SET_MAX + 1] = {
 	[NFTA_SET_TABLE]		= { .type = NLA_STRING },
 	[NFTA_SET_NAME]			= { .type = NLA_STRING,
-					    .len = IFNAMSIZ - 1 },
+					    .len = NFT_SET_MAXNAMELEN - 1 },
 	[NFTA_SET_FLAGS]		= { .type = NLA_U32 },
 	[NFTA_SET_KEY_TYPE]		= { .type = NLA_U32 },
 	[NFTA_SET_KEY_LEN]		= { .type = NLA_U32 },
@@ -2401,7 +2401,7 @@ static int nf_tables_set_alloc_name(struct nft_ctx *ctx, struct nft_set *set,
 	unsigned long *inuse;
 	unsigned int n = 0, min = 0;
 
-	p = strnchr(name, IFNAMSIZ, '%');
+	p = strnchr(name, NFT_SET_MAXNAMELEN, '%');
 	if (p != NULL) {
 		if (p[1] != 'd' || strchr(p + 2, '%'))
 			return -EINVAL;
@@ -2696,7 +2696,7 @@ static int nf_tables_newset(struct net *net, struct sock *nlsk,
 	struct nft_table *table;
 	struct nft_set *set;
 	struct nft_ctx ctx;
-	char name[IFNAMSIZ];
+	char name[NFT_SET_MAXNAMELEN];
 	unsigned int size;
 	bool create;
 	u64 timeout;
-- 
2.1.4
