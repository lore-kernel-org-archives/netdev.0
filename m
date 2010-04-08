From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: netfilter: Only do skb_checksum_help on CHECKSUM_PARTIAL in
	nfnetlink_queue
Date: Thu, 8 Apr 2010 20:41:58 +0800
Message-ID: <20100408124158.GB23910@gondor.apana.org.au>
References: <20100408123545.GA23829@gondor.apana.org.au> <20100408123930.GA23910@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
To: Patrick McHardy <kaber@trash.net>,
	"David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from ringil.hengli.com.au ([216.59.3.182]:52456 "EHLO
	arnor.apana.org.au" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1758389Ab0DHMmH (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 8 Apr 2010 08:42:07 -0400
Content-Disposition: inline
In-Reply-To: <20100408123930.GA23910@gondor.apana.org.au>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

netfilter: Only do skb_checksum_help on CHECKSUM_PARTIAL in nfnetlink_queue

As we will set ip_summed to CHECKSUM_NONE when necessary in
nfqnl_mangle, there is no need to zap CHECKSUM_COMPLETE in
nfqnl_build_packet_message.

Signed-off-by: Herbert Xu <herbert@gondor.apana.org.au>

diff --git a/net/netfilter/nfnetlink_queue.c b/net/netfilter/nfnetlink_queue.c
index e70a6ef..12e1ab3 100644
--- a/net/netfilter/nfnetlink_queue.c
+++ b/net/netfilter/nfnetlink_queue.c
@@ -246,8 +246,7 @@ nfqnl_build_packet_message(struct nfqnl_instance *queue,
 		break;
 
 	case NFQNL_COPY_PACKET:
-		if ((entskb->ip_summed == CHECKSUM_PARTIAL ||
-		     entskb->ip_summed == CHECKSUM_COMPLETE) &&
+		if (entskb->ip_summed == CHECKSUM_PARTIAL &&
 		    skb_checksum_help(entskb)) {
 			spin_unlock_bh(&queue->lock);
 			return NULL;

Cheers,
-- 
Visit Openswan at http://www.openswan.org/
Email: Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
