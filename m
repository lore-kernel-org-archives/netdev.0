From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: Resend: Re: PATCH: IPSEC acquire in presence of multiple managers
Date: Sun, 27 Mar 2005 05:27:40 +1000
Message-ID: <20050326192740.GA9638@gondor.apana.org.au>
References: <1111795927.1089.749.camel@jzny.localdomain> <1111862131.1092.872.camel@jzny.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: "David S. Miller" <davem@redhat.com>,
        Masahide NAKAMURA <nakam@linux-ipv6.org>,
        Shinta Sugimoto <shinta.sugimoto@ericsson.com>,
        netdev <netdev@oss.sgi.com>
To: jamal <hadi@cyberus.ca>
Content-Disposition: inline
In-Reply-To: <1111862131.1092.872.camel@jzny.localdomain>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Sat, Mar 26, 2005 at 01:35:31PM -0500, jamal wrote:
>
>  int km_query(struct xfrm_state *x, struct xfrm_tmpl *t, struct xfrm_policy *pol)
>  {
> -	int err = -EINVAL;
> +	int err = -EINVAL, acqret = -EINVAL;

BTW, you don't need to initialise acqret here since it's only used
inside the loop and is always assigned unconditionally..

> +		acqret = km->acquire(x, t, pol, XFRM_POLICY_OUT);
> +		if (!acqret)
> +			err = acqret;

Cheers,
-- 
Visit Openswan at http://www.openswan.org/
Email: Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
