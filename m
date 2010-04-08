From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: netfilter: Only do skb_checksum_help on CHECKSUM_PARTIAL in
	ip6_queue
Date: Thu, 8 Apr 2010 20:39:30 +0800
Message-ID: <20100408123930.GA23910@gondor.apana.org.au>
References: <20100408123545.GA23829@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
To: Patrick McHardy <kaber@trash.net>,
	"David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from ringil.hengli.com.au ([216.59.3.182]:52448 "EHLO
	arnor.apana.org.au" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1750771Ab0DHMjh (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 8 Apr 2010 08:39:37 -0400
Content-Disposition: inline
In-Reply-To: <20100408123545.GA23829@gondor.apana.org.au>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Apr 08, 2010 at 08:35:45PM +0800, Herbert Xu wrote:
> 
> netfilter: Only do skb_checksum_help on CHECKSUM_PARTIAL in ip_queue

Doh! There are three of these queue beasts.

netfilter: Only do skb_checksum_help on CHECKSUM_PARTIAL in ip6_queue

As we will set ip_summed to CHECKSUM_NONE when necessary in
ipq_mangle_ipv6, there is no need to zap CHECKSUM_COMPLETE in
ipq_build_packet_message.

Signed-off-by: Herbert Xu <herbert@gondor.apana.org.au>

diff --git a/net/ipv6/netfilter/ip6_queue.c b/net/ipv6/netfilter/ip6_queue.c
index 6a68a74..8656eb7 100644
--- a/net/ipv6/netfilter/ip6_queue.c
+++ b/net/ipv6/netfilter/ip6_queue.c
@@ -162,8 +162,7 @@ ipq_build_packet_message(struct nf_queue_entry *entry, int *errp)
 		break;
 
 	case IPQ_COPY_PACKET:
-		if ((entry->skb->ip_summed == CHECKSUM_PARTIAL ||
-		     entry->skb->ip_summed == CHECKSUM_COMPLETE) &&
+		if (entry->skb->ip_summed == CHECKSUM_PARTIAL &&
 		    (*errp = skb_checksum_help(entry->skb))) {
 			read_unlock_bh(&queue_lock);
 			return NULL;

Cheers,
-- 
Visit Openswan at http://www.openswan.org/
Email: Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
