From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: [PATCH 2.6] dev.c: clear SIOCGIFHWADDR buffer if !dev->addr_len
Date: Tue, 2 Nov 2004 07:27:54 +1100
Message-ID: <20041101202754.GA23149@gondor.apana.org.au>
References: <20041030013700.GA21540@lists.us.dell.com> <E1CNiOT-0008GU-00@gondolin.me.apana.org.au> <20041030030936.GA25102@lists.us.dell.com> <1099163419.1039.97.camel@jzny.localdomain> <20041101044433.GA18772@lists.us.dell.com> <20041101173434.GA12437@lists.us.dell.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@oss.sgi.com, jamal <hadi@cyberus.ca>
Return-path: <netdev-bounce@oss.sgi.com>
To: Matt Domsch <Matt_Domsch@dell.com>
Content-Disposition: inline
In-Reply-To: <20041101173434.GA12437@lists.us.dell.com>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Mon, Nov 01, 2004 at 11:34:34AM -0600, Matt Domsch wrote:
>
> +			else if (!dev->addr_len)
> +				memset(ifr->ifr_hwaddr.sa_data, 0, sizeof ifr->ifr_hwaddr.sa_data);
> +			else
> +				memcpy(ifr->ifr_hwaddr.sa_data, dev->dev_addr,
> +				       min(sizeof ifr->ifr_hwaddr.sa_data, (size_t) dev->addr_len));

Same problem as before.  If dev->addr_len is greater than zero but less
than sizeof ifr->ifr_hwaddr.sa_data, then you've got garbage in there.
Zero is not a special case.
-- 
Visit Openswan at http://www.openswan.org/
Email: Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
