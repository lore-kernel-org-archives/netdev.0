From: pablo@netfilter.org
Subject: [PATCH 1/6] netfilter: nfnetlink_log: fix NLA_PUT macro removal bug
Date: Fri, 31 Aug 2012 16:03:04 +0200
Message-ID: <1346421789-3449-2-git-send-email-pablo@netfilter.org>
References: <1346421789-3449-1-git-send-email-pablo@netfilter.org>
Cc: davem@davemloft.net, netdev@vger.kernel.org
To: netfilter-devel@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.us.es ([193.147.175.20]:54058 "EHLO mail.us.es"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753766Ab2HaOEY (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 31 Aug 2012 10:04:24 -0400
In-Reply-To: <1346421789-3449-1-git-send-email-pablo@netfilter.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Patrick McHardy <kaber@trash.net>

Commit 1db20a52 (nfnetlink_log: Stop using NLA_PUT*().) incorrectly
converted a NLA_PUT_BE16 macro to nla_put_be32() in nfnetlink_log:

-               NLA_PUT_BE16(inst->skb, NFULA_HWTYPE, htons(skb->dev->type));
+               if (nla_put_be32(inst->skb, NFULA_HWTYPE, htons(skb->dev->type))

Signed-off-by: Patrick McHardy <kaber@trash.net>
Signed-off-by: Pablo Neira Ayuso <pablo@netfilter.org>
---
 net/netfilter/nfnetlink_log.c |    2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/net/netfilter/nfnetlink_log.c b/net/netfilter/nfnetlink_log.c
index 169ab59..592091c1 100644
--- a/net/netfilter/nfnetlink_log.c
+++ b/net/netfilter/nfnetlink_log.c
@@ -480,7 +480,7 @@ __build_packet_message(struct nfulnl_instance *inst,
 	}
 
 	if (indev && skb_mac_header_was_set(skb)) {
-		if (nla_put_be32(inst->skb, NFULA_HWTYPE, htons(skb->dev->type)) ||
+		if (nla_put_be16(inst->skb, NFULA_HWTYPE, htons(skb->dev->type)) ||
 		    nla_put_be16(inst->skb, NFULA_HWLEN,
 				 htons(skb->dev->hard_header_len)) ||
 		    nla_put(inst->skb, NFULA_HWHEADER, skb->dev->hard_header_len,
-- 
1.7.10.4
