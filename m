From: Pablo Neira Ayuso <pablo@netfilter.org>
Subject: [PATCH 08/12] netfilter: nf_tables: Release memory obtained by kasprintf
Date: Mon,  9 Oct 2017 18:25:42 +0200
Message-ID: <1507566346-32553-9-git-send-email-pablo@netfilter.org>
References: <1507566346-32553-1-git-send-email-pablo@netfilter.org>
Cc: davem@davemloft.net, netdev@vger.kernel.org
To: netfilter-devel@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.us.es ([193.147.175.20]:57782 "EHLO mail.us.es"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1754953AbdJIQ0C (ORCPT <rfc822;netdev@vger.kernel.org>);
        Mon, 9 Oct 2017 12:26:02 -0400
Received: from antivirus1-rhel7.int (unknown [192.168.2.11])
        by mail.us.es (Postfix) with ESMTP id 4D76CC0B38
        for <netdev@vger.kernel.org>; Mon,  9 Oct 2017 18:26:01 +0200 (CEST)
Received: from antivirus1-rhel7.int (localhost [127.0.0.1])
        by antivirus1-rhel7.int (Postfix) with ESMTP id 3CA0DDA396
        for <netdev@vger.kernel.org>; Mon,  9 Oct 2017 18:26:01 +0200 (CEST)
In-Reply-To: <1507566346-32553-1-git-send-email-pablo@netfilter.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Arvind Yadav <arvind.yadav.cs@gmail.com>

Free memory region, if nf_tables_set_alloc_name is not successful.

Fixes: 387454901bd6 ("netfilter: nf_tables: Allow set names of up to 255 chars")
Signed-off-by: Arvind Yadav <arvind.yadav.cs@gmail.com>
Signed-off-by: Pablo Neira Ayuso <pablo@netfilter.org>
---
 net/netfilter/nf_tables_api.c | 4 +++-
 1 file changed, 3 insertions(+), 1 deletion(-)

diff --git a/net/netfilter/nf_tables_api.c b/net/netfilter/nf_tables_api.c
index f98ca8c6aa59..34adedcb239e 100644
--- a/net/netfilter/nf_tables_api.c
+++ b/net/netfilter/nf_tables_api.c
@@ -2741,8 +2741,10 @@ static int nf_tables_set_alloc_name(struct nft_ctx *ctx, struct nft_set *set,
 	list_for_each_entry(i, &ctx->table->sets, list) {
 		if (!nft_is_active_next(ctx->net, i))
 			continue;
-		if (!strcmp(set->name, i->name))
+		if (!strcmp(set->name, i->name)) {
+			kfree(set->name);
 			return -ENFILE;
+		}
 	}
 	return 0;
 }
-- 
2.1.4
