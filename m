From: Steffen Klassert <steffen.klassert@secunet.com>
Subject: Re: [PATCHv2 net-next 2/3] xfrm: export verify_userspi_info for
 pkfey and netlink interface
Date: Mon, 16 Dec 2013 10:39:59 +0100
Message-ID: <20131216093958.GE31491@secunet.com>
References: <1387099194-18540-1-git-send-email-fan.du@windriver.com>
 <1387099194-18540-3-git-send-email-fan.du@windriver.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: davem@davemloft.net, netdev@vger.kernel.org
To: Fan Du <fan.du@windriver.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from a.mx.secunet.com ([195.81.216.161]:52468 "EHLO a.mx.secunet.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751184Ab3LPJkF (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 16 Dec 2013 04:40:05 -0500
Content-Disposition: inline
In-Reply-To: <1387099194-18540-3-git-send-email-fan.du@windriver.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sun, Dec 15, 2013 at 05:19:53PM +0800, Fan Du wrote:
> diff --git a/net/key/af_key.c b/net/key/af_key.c
> index 545f047..7605d51 100644
> --- a/net/key/af_key.c
> +++ b/net/key/af_key.c
> @@ -1340,6 +1340,12 @@ static int pfkey_getspi(struct sock *sk, struct sk_buff *skb, const struct sadb_
>  		max_spi = range->sadb_spirange_max;
>  	}
>  
> +	err = verify_spi_info(x->id.proto, min_spi, max_spi);
> +	if (err) {
> +		xfrm_state_put(x);
> +		return err; 

This line adds a trailing whitespace.

> +	}
> +
>  	err = xfrm_alloc_spi(x, min_spi, max_spi);
>  	resp_skb = err ? ERR_PTR(err) : pfkey_xfrm_state2msg(x);
>  
> diff --git a/net/xfrm/xfrm_state.c b/net/xfrm/xfrm_state.c
> index 68c2f35..d953639 100644
> --- a/net/xfrm/xfrm_state.c
> +++ b/net/xfrm/xfrm_state.c
> @@ -1496,6 +1496,30 @@ u32 xfrm_get_acqseq(void)
>  }
>  EXPORT_SYMBOL(xfrm_get_acqseq);
>  
> +int verify_spi_info(u8 proto, u32 min, u32 max)
> +{
> +        switch (proto) {
> +        case IPPROTO_AH:
> +        case IPPROTO_ESP:
> +                break;
> +
> +        case IPPROTO_COMP:
> +                /* IPCOMP spi is 16-bits. */
> +                if (max >= 0x10000)
> +                        return -EINVAL;
> +                break;
> +
> +        default:
> +                return -EINVAL;
> +        }    

This one too.
