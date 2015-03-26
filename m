From: Pablo Neira Ayuso <pablo@netfilter.org>
Subject: [PATCH 05/15] netfilter: nft_meta: use raw_smp_processor_id()
Date: Thu, 26 Mar 2015 13:06:52 +0100
Message-ID: <1427371622-4466-6-git-send-email-pablo@netfilter.org>
References: <1427371622-4466-1-git-send-email-pablo@netfilter.org>
Cc: davem@davemloft.net, netdev@vger.kernel.org
To: netfilter-devel@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.us.es ([193.147.175.20]:38326 "EHLO mail.us.es"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752462AbbCZMDa (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 26 Mar 2015 08:03:30 -0400
In-Reply-To: <1427371622-4466-1-git-send-email-pablo@netfilter.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Patrick McHardy <kaber@trash.net>

Using smp_processor_id() triggers warnings with PREEMPT_RCU. There is no
point in disabling preemption since we only collect the numeric value,
so use raw_smp_processor_id() instead.

Signed-off-by: Patrick McHardy <kaber@trash.net>
Signed-off-by: Pablo Neira Ayuso <pablo@netfilter.org>
---
 net/netfilter/nft_meta.c |    2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/net/netfilter/nft_meta.c b/net/netfilter/nft_meta.c
index abe6811..5197874 100644
--- a/net/netfilter/nft_meta.c
+++ b/net/netfilter/nft_meta.c
@@ -153,7 +153,7 @@ void nft_meta_get_eval(const struct nft_expr *expr,
 		}
 		break;
 	case NFT_META_CPU:
-		dest->data[0] = smp_processor_id();
+		dest->data[0] = raw_smp_processor_id();
 		break;
 	case NFT_META_IIFGROUP:
 		if (in == NULL)
-- 
1.7.10.4
