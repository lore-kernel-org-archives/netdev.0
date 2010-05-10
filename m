From: kaber@trash.net
Subject: [PATCH 57/84] netfilter: only do skb_checksum_help on CHECKSUM_PARTIAL in ip6_queue
Date: Mon, 10 May 2010 22:18:28 +0200
Message-ID: <1273522735-24672-58-git-send-email-kaber@trash.net>
References: <1273522735-24672-1-git-send-email-kaber@trash.net>
Cc: netfilter-devel@vger.kernel.org, netdev@vger.kernel.org
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from stinky.trash.net ([213.144.137.162]:54526 "EHLO
	stinky.trash.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756893Ab0EJUTT (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 10 May 2010 16:19:19 -0400
In-Reply-To: <1273522735-24672-1-git-send-email-kaber@trash.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Herbert Xu <herbert@gondor.apana.org.au>

As we will set ip_summed to CHECKSUM_NONE when necessary in
ipq_mangle_ipv6, there is no need to zap CHECKSUM_COMPLETE in
ipq_build_packet_message.

Signed-off-by: Herbert Xu <herbert@gondor.apana.org.au>
Signed-off-by: Patrick McHardy <kaber@trash.net>
---
 net/ipv6/netfilter/ip6_queue.c |    3 +--
 1 files changed, 1 insertions(+), 2 deletions(-)

diff --git a/net/ipv6/netfilter/ip6_queue.c b/net/ipv6/netfilter/ip6_queue.c
index 7854052..39856a2 100644
--- a/net/ipv6/netfilter/ip6_queue.c
+++ b/net/ipv6/netfilter/ip6_queue.c
@@ -161,8 +161,7 @@ ipq_build_packet_message(struct nf_queue_entry *entry, int *errp)
 		break;
 
 	case IPQ_COPY_PACKET:
-		if ((entry->skb->ip_summed == CHECKSUM_PARTIAL ||
-		     entry->skb->ip_summed == CHECKSUM_COMPLETE) &&
+		if (entry->skb->ip_summed == CHECKSUM_PARTIAL &&
 		    (*errp = skb_checksum_help(entry->skb))) {
 			read_unlock_bh(&queue_lock);
 			return NULL;
-- 
1.7.0.4

