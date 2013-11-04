From: Pablo Neira Ayuso <pablo@netfilter.org>
Subject: [PATCH 5/5] netfilter: nft_compat: use _safe version of list_for_each
Date: Mon,  4 Nov 2013 23:05:21 +0100
Message-ID: <1383602721-5728-6-git-send-email-pablo@netfilter.org>
References: <1383602721-5728-1-git-send-email-pablo@netfilter.org>
Cc: davem@davemloft.net, netdev@vger.kernel.org
To: netfilter-devel@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.us.es ([193.147.175.20]:57704 "EHLO mail.us.es"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752554Ab3KDWFd (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 4 Nov 2013 17:05:33 -0500
In-Reply-To: <1383602721-5728-1-git-send-email-pablo@netfilter.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Dan Carpenter <dan.carpenter@oracle.com>

We need to use the _safe version of list_for_each_entry() here otherwise
we have a use after free bug.

Signed-off-by: Dan Carpenter <dan.carpenter@oracle.com>
Signed-off-by: Pablo Neira Ayuso <pablo@netfilter.org>
---
 net/netfilter/nft_compat.c |    8 ++++----
 1 file changed, 4 insertions(+), 4 deletions(-)

diff --git a/net/netfilter/nft_compat.c b/net/netfilter/nft_compat.c
index 4811f76..a82667c 100644
--- a/net/netfilter/nft_compat.c
+++ b/net/netfilter/nft_compat.c
@@ -634,9 +634,9 @@ nft_match_select_ops(const struct nft_ctx *ctx,
 
 static void nft_match_release(void)
 {
-	struct nft_xt *nft_match;
+	struct nft_xt *nft_match, *tmp;
 
-	list_for_each_entry(nft_match, &nft_match_list, head)
+	list_for_each_entry_safe(nft_match, tmp, &nft_match_list, head)
 		kfree(nft_match);
 }
 
@@ -705,9 +705,9 @@ nft_target_select_ops(const struct nft_ctx *ctx,
 
 static void nft_target_release(void)
 {
-	struct nft_xt *nft_target;
+	struct nft_xt *nft_target, *tmp;
 
-	list_for_each_entry(nft_target, &nft_target_list, head)
+	list_for_each_entry_safe(nft_target, tmp, &nft_target_list, head)
 		kfree(nft_target);
 }
 
-- 
1.7.10.4
