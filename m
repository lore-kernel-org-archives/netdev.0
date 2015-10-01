From: Mike Galbraith <umgwanakikbuti@gmail.com>
Subject: Re: skbuff: Fix checksum start check in skb_postpull_rcsum
Date: Thu, 01 Oct 2015 13:48:13 +0200
Message-ID: <1443700093.3237.0.camel@gmail.com>
References: <20151001084222.GA25104@gondor.apana.org.au>
	 <1443698177.3401.1.camel@gmail.com>
	 <20151001112134.GA26657@gondor.apana.org.au>
	 <20151001113407.GA26772@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, pshelar@nicira.com,
	linux-kernel@vger.kernel.org
To: Herbert Xu <herbert@gondor.apana.org.au>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20151001113407.GA26772@gondor.apana.org.au>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Yup, all better.  Thanks.

	-Mike

On Thu, 2015-10-01 at 19:34 +0800, Herbert Xu wrote:
> In skb_postpull_rcsum the skb has already been pulled so we should
> be testing whether the checksum start offset is non-negative rather
> than how it compares to the length that we have pulled.
> 
> Fixes: 6ae459bdaaee ("skbuff: Fix skb checksum flag on skb pull")
> Reported-by: Mike Galbraith <umgwanakikbuti@gmail.com>
> Signed-off-by: Herbert Xu <herbert@gondor.apana.org.au>
> 
> diff --git a/include/linux/skbuff.h b/include/linux/skbuff.h
> index 2b0a30a..4398411 100644
> --- a/include/linux/skbuff.h
> +++ b/include/linux/skbuff.h
> @@ -2708,7 +2708,7 @@ static inline void skb_postpull_rcsum(struct sk_buff *skb,
>  	if (skb->ip_summed == CHECKSUM_COMPLETE)
>  		skb->csum = csum_sub(skb->csum, csum_partial(start, len, 0));
>  	else if (skb->ip_summed == CHECKSUM_PARTIAL &&
> -		 skb_checksum_start_offset(skb) <= len)
> +		 skb_checksum_start_offset(skb) < 0)
>  		skb->ip_summed = CHECKSUM_NONE;
>  }
>  
