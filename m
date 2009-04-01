From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: [PATCH] Re: skb_segment() questions
Date: Wed, 1 Apr 2009 17:24:57 +0800
Message-ID: <20090401092457.GB19847@gondor.apana.org.au>
References: <20090329020701.GA9983@gondor.apana.org.au> <20090401091801.GA5970@ff.dom.local>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: James Huang <jamesclhuang@gmail.com>,
	"David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org
To: Jarek Poplawski <jarkao2@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from rhun.apana.org.au ([64.62.148.172]:55473 "EHLO
	arnor.apana.org.au" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1752823AbZDAJZH (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 1 Apr 2009 05:25:07 -0400
Content-Disposition: inline
In-Reply-To: <20090401091801.GA5970@ff.dom.local>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Apr 01, 2009 at 09:18:01AM +0000, Jarek Poplawski wrote:
>
> gso: Fix support for linear packets 2
> 
> The previous fix removed a check, which should be useful, only a bit
> later, by skipping at least two similar checks and three useless
> assignments in case a header is (still) copied.
> 
> Signed-off-by: Jarek Poplawski <jarkao2@gmail.com>
> ---
> 
>  net/core/skbuff.c |    2 ++
>  1 files changed, 2 insertions(+), 0 deletions(-)
> 
> diff --git a/net/core/skbuff.c b/net/core/skbuff.c
> index ce6356c..2123a92 100644
> --- a/net/core/skbuff.c
> +++ b/net/core/skbuff.c
> @@ -2594,6 +2594,8 @@ struct sk_buff *skb_segment(struct sk_buff *skb, int features)
>  
>  		skb_copy_from_linear_data_offset(skb, offset,
>  						 skb_put(nskb, hsize), hsize);
> +		if (pos >= offset + len)
> +			continue;
>  
>  		while (pos < offset + len && i < nfrags) {
>  			*frag = skb_shinfo(skb)->frags[i];

The common case (non-linear skb) is going to fail that check so 
I'm no sure if it's warranted.

Thanks,
-- 
Visit Openswan at http://www.openswan.org/
Email: Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
