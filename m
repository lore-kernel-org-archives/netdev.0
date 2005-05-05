From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: resend patch:  xfrm policybyid
Date: Fri, 6 May 2005 07:32:39 +1000
Message-ID: <20050505213239.GA29526@gondor.apana.org.au>
References: <1115298877.7680.75.camel@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: "David S. Miller" <davem@davemloft.net>, netdev <netdev@oss.sgi.com>
Return-path: <netdev-bounce@oss.sgi.com>
To: jamal <hadi@cyberus.ca>
Content-Disposition: inline
In-Reply-To: <1115298877.7680.75.camel@localhost.localdomain>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Thu, May 05, 2005 at 09:14:36AM -0400, jamal wrote:
>
> +	if (policy->index)
> +		delpol = xfrm_policy_byid(dir, policy->index, 0);
> +	delpol2 = xfrm_policy_bysel(dir, &policy->selector, 0);
> +
> +	/* must be unique in both index and selector */
> +	if (delpol && delpol2) 
> +		if (delpol != delpol2) 
> +			goto pol_err;
>  
> +	if (delpol) 
> +		delp = delpol;
> +	else 
> +		delp = delpol2;
> +			
> +	if (delp && excl) { 
> +		ret = -EEXIST;
> +		goto pol_err;
> +	}
> +
> +	/* insert, sorted by prio*/
>  	write_lock_bh(&xfrm_policy_lock);

This is still racy since delp can be killed by timers before you get
the lock.

Cheers,
-- 
Visit Openswan at http://www.openswan.org/
Email: Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
