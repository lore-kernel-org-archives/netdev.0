From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: [PATCH][IPSEC]: Aggregate make_jiffies
Date: Wed, 16 Aug 2006 12:33:49 +1000
Message-ID: <20060816023349.GA24174@gondor.apana.org.au>
References: <1155693500.5122.39.camel@jzny2>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: "David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from rhun.apana.org.au ([64.62.148.172]:42756 "EHLO
	arnor.apana.org.au") by vger.kernel.org with ESMTP id S1750830AbWHPCeG
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 15 Aug 2006 22:34:06 -0400
To: jamal <hadi@cyberus.ca>
Content-Disposition: inline
In-Reply-To: <1155693500.5122.39.camel@jzny2>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tue, Aug 15, 2006 at 09:58:19PM -0400, jamal wrote:
>
> diff --git a/include/net/xfrm.h b/include/net/xfrm.h
> index 8123d49..05444dd 100644
> --- a/include/net/xfrm.h
> +++ b/include/net/xfrm.h
> @@ -619,6 +619,14 @@ xfrm_state_addr_cmp(struct xfrm_tmpl *tm
>  	return !0;
>  }
>  
> +static inline unsigned long make_jiffies(long secs)
> +{
> +	if (secs >= (MAX_SCHEDULE_TIMEOUT-1)/HZ)
> +		return MAX_SCHEDULE_TIMEOUT-1;
> +	else
> +		return secs*HZ;
> +}

This name is probably too generic for net/xfrm.h.  How about moving
it to linux/jiffies.h and rewrite in the style of msec_to_jiffies?

Cheers,
-- 
Visit Openswan at http://www.openswan.org/
Email: Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
