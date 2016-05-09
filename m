From: Pablo Neira Ayuso <pablo@netfilter.org>
Subject: [PATCH 09/36] netfilter: nft_rbtree: introduce nft_rbtree_interval_end() helper
Date: Mon,  9 May 2016 20:46:27 +0200
Message-ID: <1462819614-5402-10-git-send-email-pablo@netfilter.org>
References: <1462819614-5402-1-git-send-email-pablo@netfilter.org>
Cc: davem@davemloft.net, netdev@vger.kernel.org
To: netfilter-devel@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.us.es ([193.147.175.20]:45691 "EHLO mail.us.es"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752360AbcEISrM (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 9 May 2016 14:47:12 -0400
Received: from antivirus1-rhel7.int (unknown [192.168.2.11])
	by mail.us.es (Postfix) with ESMTP id C7351E8E8C
	for <netdev@vger.kernel.org>; Mon,  9 May 2016 20:47:11 +0200 (CEST)
Received: from antivirus1-rhel7.int (localhost [127.0.0.1])
	by antivirus1-rhel7.int (Postfix) with ESMTP id B93A1134711
	for <netdev@vger.kernel.org>; Mon,  9 May 2016 20:47:11 +0200 (CEST)
Received: from antivirus1-rhel7.int (localhost [127.0.0.1])
	by antivirus1-rhel7.int (Postfix) with ESMTP id AEC3D134713
	for <netdev@vger.kernel.org>; Mon,  9 May 2016 20:47:09 +0200 (CEST)
In-Reply-To: <1462819614-5402-1-git-send-email-pablo@netfilter.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Add this new nft_rbtree_interval_end() helper function to check in the
end interval is set.

Signed-off-by: Pablo Neira Ayuso <pablo@netfilter.org>
---
 net/netfilter/nft_rbtree.c | 9 ++++++---
 1 file changed, 6 insertions(+), 3 deletions(-)

diff --git a/net/netfilter/nft_rbtree.c b/net/netfilter/nft_rbtree.c
index 1c30f41..29f2ab8 100644
--- a/net/netfilter/nft_rbtree.c
+++ b/net/netfilter/nft_rbtree.c
@@ -29,6 +29,11 @@ struct nft_rbtree_elem {
 	struct nft_set_ext	ext;
 };
 
+static bool nft_rbtree_interval_end(const struct nft_rbtree_elem *rbe)
+{
+	return nft_set_ext_exists(&rbe->ext, NFT_SET_EXT_FLAGS) &&
+	       (*nft_set_ext_flags(&rbe->ext) & NFT_SET_ELEM_INTERVAL_END);
+}
 
 static bool nft_rbtree_lookup(const struct nft_set *set, const u32 *key,
 			      const struct nft_set_ext **ext)
@@ -56,9 +61,7 @@ found:
 				parent = parent->rb_left;
 				continue;
 			}
-			if (nft_set_ext_exists(&rbe->ext, NFT_SET_EXT_FLAGS) &&
-			    *nft_set_ext_flags(&rbe->ext) &
-			    NFT_SET_ELEM_INTERVAL_END)
+			if (nft_rbtree_interval_end(rbe))
 				goto out;
 			spin_unlock_bh(&nft_rbtree_lock);
 
-- 
2.1.4
