From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: patch: policy update by id
Date: Thu, 28 Apr 2005 09:39:24 +1000
Message-ID: <20050427233924.GA22238@gondor.apana.org.au>
References: <1114602874.7670.4.camel@localhost.localdomain> <1114604657.7670.22.camel@localhost.localdomain> <1114604826.7670.24.camel@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Jamal Hadi Salim <hadi@znyx.com>
Content-Disposition: inline
In-Reply-To: <1114604826.7670.24.camel@localhost.localdomain>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Wed, Apr 27, 2005 at 08:27:06AM -0400, Jamal Hadi Salim wrote:
>
> --- /usr/src/26117-mod/net/xfrm/xfrm_policy.c	2005/04/27 11:32:13	1.1
> +++ /usr/src/26117-mod/net/xfrm/xfrm_policy.c	2005/04/27 12:25:24
> @@ -345,7 +345,9 @@
>  
>  	write_lock_bh(&xfrm_policy_lock);
>  	for (p = &xfrm_policy_list[dir]; (pol=*p)!=NULL;) {
> -		if (!delpol && memcmp(&policy->selector, &pol->selector, sizeof(pol->selector)) == 0) {
> +		if (!delpol && 
> +		((!excl && policy->index && (policy->index == pol->index)) || 
> +		 (memcmp(&policy->selector, &pol->selector, sizeof(pol->selector)) == 0))) {

I have no problems with the idea itself.  However, I have a couple of
minor issues with this patch :)

First of all please align the continued lines to the if expression, e.g.,
		if (!delpol && 
		    (policy->index && (policy->index == pol->index)) || 

Also the excl check doesn't make sense.  You should let the
following excl check take place after you've found out that
the indices is identical.

>  			if (excl) {
>  				write_unlock_bh(&xfrm_policy_lock);
>  				return -EEXIST;

Cheers,
-- 
Visit Openswan at http://www.openswan.org/
Email: Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
