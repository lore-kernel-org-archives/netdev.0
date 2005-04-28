From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: patch2: del/get byid
Date: Fri, 29 Apr 2005 09:11:54 +1000
Message-ID: <20050428231154.GA14215@gondor.apana.org.au>
References: <1114654284.7663.50.camel@localhost.localdomain> <20050428021426.GA23415@gondor.apana.org.au> <1114655014.7663.61.camel@localhost.localdomain> <20050428022549.GA23556@gondor.apana.org.au> <1114655980.7663.76.camel@localhost.localdomain> <20050428024253.GA23695@gondor.apana.org.au> <1114656932.7663.88.camel@localhost.localdomain> <20050428030325.GB23823@gondor.apana.org.au> <1114658657.7663.110.camel@localhost.localdomain> <1114698033.7663.197.camel@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Alexey Kuznetsov <kuznet@ms2.inr.ac.ru>, netdev@oss.sgi.com,
        "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-bounce@oss.sgi.com>
To: jamal <hadi@cyberus.ca>
Content-Disposition: inline
In-Reply-To: <1114698033.7663.197.camel@localhost.localdomain>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Thu, Apr 28, 2005 at 10:20:33AM -0400, jamal wrote:
> 
> Well, heres some minimalist patch i havent tested. i.e doesnt change any
> of the functions; but at least it doesnt break the timers.
> This includes both patches i posted earlier and introduces dir in 
> xfrm_policy. 

Thanks, the dir stuff looks good.

> @@ -345,7 +345,10 @@
>  
>  	write_lock_bh(&xfrm_policy_lock);
>  	for (p = &xfrm_policy_list[dir]; (pol=*p)!=NULL;) {
> -		if (!delpol && memcmp(&policy->selector, &pol->selector, sizeof(pol->selector)) == 0) {
> +		if (!delpol && 
> +		    ((!excl && policy->index && 
> +		      (policy->index == pol->index)) || 
> +		    (memcmp(&policy->selector, &pol->selector, sizeof(pol->selector)) == 0))) {

Now that you are allowing the user to set the index, this excl check
really needs to go.  Otherwise the user can add two policies with
the same index.

You also still need to solve the problem that you may need to
delete two policies if one matches the index while the other matches
the selector (or selector plus priority if you do that).

Cheers,
-- 
Visit Openswan at http://www.openswan.org/
Email: Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
