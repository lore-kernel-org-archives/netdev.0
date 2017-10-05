From: Herbert Xu <herbert-lOAM2aK0SrRLBo1qDEOMRrpzq4S04n8Q@public.gmane.org>
Subject: Re: [PATCH V2] Fix a sleep-in-atomic bug in shash_setkey_unaligned
Date: Thu, 5 Oct 2017 21:16:31 +0800
Message-ID: <20171005131631.GA1553@gondor.apana.org.au>
References: <20171003052643.GB22750@gondor.apana.org.au>
 <20171003224505.GE19750@localhost.localdomain>
 <20171005034054.GB31996@gondor.apana.org.au>
 <20171004.213758.2210486785503998906.davem@davemloft.net>
 <20171005101620.GA1246@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: marcelo.leitner-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org, luto-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org, baijiaju1990-9Onoh4P/yGk@public.gmane.org,
        nhorman-2XuSBdqkA4R54TAoqtyWWQ@public.gmane.org, vyasevich-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org, kvalo-sgV2jX0FEOL9JmXXK+q4OQ@public.gmane.org,
        linux-crypto-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
        linux-sctp-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: David Miller <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>
Return-path: <linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <20171005101620.GA1246-lOAM2aK0SrRLBo1qDEOMRrpzq4S04n8Q@public.gmane.org>
Sender: linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

On Thu, Oct 05, 2017 at 06:16:20PM +0800, Herbert Xu wrote:
>
> That was my point.  Functions like sctp_pack_cookie shouldn't be
> setting the key in the first place.  The setkey should happen at
> the point when the key is generated.  That's sctp_endpoint_init
> which AFAICS only gets called in GFP_KERNEL context.
> 
> Or is there a code-path where sctp_endpoint_init is called in
> softirq context?

OK, there are indeed code paths where the key is derived in softirq
context.  Notably sctp_auth_calculate_hmac.

So I think this patch is the correct fix and I will push it upstream
as well as back to stable.

Thanks,
-- 
Email: Herbert Xu <herbert-lOAM2aK0SrRLBo1qDEOMRrpzq4S04n8Q@public.gmane.org>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
