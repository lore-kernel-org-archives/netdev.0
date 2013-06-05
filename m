From: Pablo Neira Ayuso <pablo@netfilter.org>
Subject: [PATCH 12/12] netfilter: nfnetlink_queue: only add CAP_LEN attr when needed
Date: Wed,  5 Jun 2013 22:40:32 +0200
Message-ID: <1370464832-4216-12-git-send-email-pablo@netfilter.org>
References: <1370464832-4216-1-git-send-email-pablo@netfilter.org>
Cc: davem@davemloft.net, netdev@vger.kernel.org
To: netfilter-devel@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.us.es ([193.147.175.20]:57502 "EHLO mail.us.es"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S932188Ab3FEUlI (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 5 Jun 2013 16:41:08 -0400
In-Reply-To: <1370464832-4216-1-git-send-email-pablo@netfilter.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Florian Westphal <fw@strlen.de>

CAP_LEN contains the size of the network packet we're queueing to
userspace, i.e. normally it is the same as the NFQA_PAYLOAD attribute len.

Include it only in the unlikely case when NFQA_PAYLOAD is truncated due
to copy_range limitations.

Signed-off-by: Florian Westphal <fw@strlen.de>
Signed-off-by: Pablo Neira Ayuso <pablo@netfilter.org>
---
 net/netfilter/nfnetlink_queue_core.c |    3 ++-
 1 file changed, 2 insertions(+), 1 deletion(-)

diff --git a/net/netfilter/nfnetlink_queue_core.c b/net/netfilter/nfnetlink_queue_core.c
index 3c42181..eb2cde8 100644
--- a/net/netfilter/nfnetlink_queue_core.c
+++ b/net/netfilter/nfnetlink_queue_core.c
@@ -472,7 +472,8 @@ nfqnl_build_packet_message(struct nfqnl_instance *queue,
 	if (ct && nfqnl_ct_put(skb, ct, ctinfo) < 0)
 		goto nla_put_failure;
 
-	if (cap_len > 0 && nla_put_be32(skb, NFQA_CAP_LEN, htonl(cap_len)))
+	if (cap_len > data_len &&
+	    nla_put_be32(skb, NFQA_CAP_LEN, htonl(cap_len)))
 		goto nla_put_failure;
 
 	if (nfqnl_put_packet_info(skb, entskb))
-- 
1.7.10.4
