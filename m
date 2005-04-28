From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: patch: policy update by id
Date: Thu, 28 Apr 2005 11:21:35 +1000
Message-ID: <20050428012135.GA22950@gondor.apana.org.au>
References: <1114602874.7670.4.camel@localhost.localdomain> <1114604657.7670.22.camel@localhost.localdomain> <1114604826.7670.24.camel@localhost.localdomain> <20050427233924.GA22238@gondor.apana.org.au> <1114650816.7663.13.camel@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: jamal <hadi@cyberus.ca>
Content-Disposition: inline
In-Reply-To: <1114650816.7663.13.camel@localhost.localdomain>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Wed, Apr 27, 2005 at 09:13:36PM -0400, jamal wrote:
>
> > > +		if (!delpol && 
> > > +		((!excl && policy->index && (policy->index == pol->index)) || 
> > > +		 (memcmp(&policy->selector, &pol->selector, sizeof(pol->selector)) == 0))) {
>
> > Also the excl check doesn't make sense.  You should let the
> > following excl check take place after you've found out that
> > the indices is identical.
> 
> the policy->index is only relevant for the update not the add;
> the update could also be done by selector. So i didnt follow.

I see.  In that case you want to change your expression above
so that the memcmp is never done if excl is off and the index
is non-zero.  Otherwise this will result in non-deterministic
behaviour as the result will change depending on whether the
first hit is an index match or a selector match.

Actually, would it be so bad to check the policy->index for the
add case? It does have a well-defined meaning there.

Cheers,
-- 
Visit Openswan at http://www.openswan.org/
Email: Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
