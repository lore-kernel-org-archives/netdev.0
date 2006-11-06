From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: SKB BUG: Invalid truesize, current git
Date: Tue, 7 Nov 2006 06:36:20 +1100
Message-ID: <20061106193620.GA1766@gondor.apana.org.au>
References: <20061106190725.GW9057@kvack.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from rhun.apana.org.au ([64.62.148.172]:47377 "EHLO
	arnor.apana.org.au") by vger.kernel.org with ESMTP id S1752721AbWKFTgj
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 6 Nov 2006 14:36:39 -0500
To: Benjamin LaHaise <bcrl@kvack.org>,
	"David S. Miller" <davem@davemloft.net>
Content-Disposition: inline
In-Reply-To: <20061106190725.GW9057@kvack.org>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Mon, Nov 06, 2006 at 07:07:26PM +0000, Benjamin LaHaise wrote:
> 
> I managed to get a backtrace for the Invalid truesize bug.  The trigger is 
> running LMbench2, but it's rater intermittent.  Traffic should be going 
> over the loopback interface, but the main nic on the machine is e1000.  
> Let me know if anyone has any ideas for things to try.

OK, this should cure it.  BTW, this indicates that your app is
retransmitting unnecessarily which might be a problem in itself.

This patch applies to all recent 2.6 kernels.

[NET]: Set truesize in pskb_copy

Since pskb_copy tacks on the non-linear bits from the original
skb, it needs to count them in the truesize field of the new skb.

Signed-off-by: Herbert Xu <herbert@gondor.apana.org.au>

Cheers,
-- 
Visit Openswan at http://www.openswan.org/
Email: Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
--
diff --git a/net/core/skbuff.c b/net/core/skbuff.c
index f735455..b8b1063 100644
--- a/net/core/skbuff.c
+++ b/net/core/skbuff.c
@@ -639,6 +639,7 @@ struct sk_buff *pskb_copy(struct sk_buff
 	n->csum	     = skb->csum;
 	n->ip_summed = skb->ip_summed;
 
+	n->truesize += skb->data_len;
 	n->data_len  = skb->data_len;
 	n->len	     = skb->len;
 
