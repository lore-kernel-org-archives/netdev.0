From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: Checking SPI in xfrm_state_find
Date: Thu, 31 Mar 2005 10:46:58 +1000
Message-ID: <20050331004658.GA26395@gondor.apana.org.au>
References: <20050214221006.GA18415@gondor.apana.org.au> <20050214221200.GA18465@gondor.apana.org.au> <20050214221433.GB18465@gondor.apana.org.au> <20050214221607.GC18465@gondor.apana.org.au> <424864CE.5060802@trash.net> <20050328233917.GB15369@gondor.apana.org.au> <424B40C2.90304@trash.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: "David S. Miller" <davem@davemloft.net>,
        Alexey Kuznetsov <kuznet@ms2.inr.ac.ru>,
        James Morris <jmorris@redhat.com>,
        YOSHIFUJI Hideaki <yoshfuji@linux-ipv6.org>, netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Patrick McHardy <kaber@trash.net>
Content-Disposition: inline
In-Reply-To: <424B40C2.90304@trash.net>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Thu, Mar 31, 2005 at 02:13:54AM +0200, Patrick McHardy wrote:
>
> Thanks, both done by these two patches.

Great.

> # This is a BitKeeper generated diff -Nru style patch.
> #
> # ChangeSet
> #   2005/03/30 06:02:45+02:00 kaber@coreworks.de 
> #   [IPSEC]: Check SPI in xfrm_state_find()
> #   
> #   Signed-off-by: Patrick McHardy <kaber@trash.net>

Looks good.

Signed-off-by: Herbert Xu <herbert@gondor.apana.org.au>

> # This is a BitKeeper generated diff -Nru style patch.
> #
> # ChangeSet
> #   2005/03/31 02:07:54+02:00 kaber@coreworks.de 
> #   [IPSEC]: Check if SPI exists before creating acquire state
> #   
> #   Signed-off-by: Patrick McHardy <kaber@trash.net>
>  
>  	x = best;
> -	if (!x && !error && !acquire_in_progress &&
> -	    ((x = xfrm_state_alloc()) != NULL)) {
> +	if (!x && !error && !acquire_in_progress) {
> +		x0 = afinfo->state_lookup(&tmpl->id.daddr, tmpl->id.spi, tmpl->id.proto);

It just occured to me that it would be much simpler if you did the
existence check in the first loop.

So something like

		if (x->props.family != family ||
		    !xfrm_state_addr_check(x, daddr, saddr, family) ||
		    tmpl->id.proto == x->id.proto)
			continue;
		if (tmpl->id.spi) {
			if (tmpl->id.spi != x->id.spi)
				continue;
			error = -EEXIST;
		}
		if (x->props.reqid == tmpl->reqid &&
		    tmpl->mode == x->props.mode) {
		}

Cheers,
-- 
Visit Openswan at http://www.openswan.org/
Email: Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
