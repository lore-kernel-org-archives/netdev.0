From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: [PATCH 2.6] dev.c: clear SIOCGIFHWADDR buffer if !dev->addr_len
Date: Tue, 2 Nov 2004 07:41:31 +1100
Message-ID: <20041101204131.GA23277@gondor.apana.org.au>
References: <20041030013700.GA21540@lists.us.dell.com> <E1CNiOT-0008GU-00@gondolin.me.apana.org.au> <20041030030936.GA25102@lists.us.dell.com> <1099163419.1039.97.camel@jzny.localdomain> <20041101044433.GA18772@lists.us.dell.com> <20041101173434.GA12437@lists.us.dell.com> <20041101202754.GA23149@gondor.apana.org.au> <20041101203821.GA15086@lists.us.dell.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@oss.sgi.com, jamal <hadi@cyberus.ca>
Return-path: <netdev-bounce@oss.sgi.com>
To: Matt Domsch <Matt_Domsch@dell.com>
Content-Disposition: inline
In-Reply-To: <20041101203821.GA15086@lists.us.dell.com>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Mon, Nov 01, 2004 at 02:38:21PM -0600, Matt Domsch wrote:
> 
> OK, I'll unconditionally clear it all first.  How's this?

It's nearly there :)

> +			if ((size_t) dev->addr_len > sizeof ifr->ifr_hwaddr.sa_data)
> +				return -EOVERFLOW;
> +			memset(ifr->ifr_hwaddr.sa_data, 0, sizeof ifr->ifr_hwaddr.sa_data);
>  			memcpy(ifr->ifr_hwaddr.sa_data, dev->dev_addr,
>  			       min(sizeof ifr->ifr_hwaddr.sa_data, (size_t) dev->addr_len));

You don't need the min anymore since you've checked that dev->addr_len
is not greater than sizeof ifr->ifr_hwaddr.sa_data.

Cheers,
-- 
Visit Openswan at http://www.openswan.org/
Email: Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
