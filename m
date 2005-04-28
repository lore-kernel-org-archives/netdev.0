From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: patch: policy update by id
Date: Thu, 28 Apr 2005 11:30:14 +1000
Message-ID: <20050428013014.GA23043@gondor.apana.org.au>
References: <1114602874.7670.4.camel@localhost.localdomain> <1114604657.7670.22.camel@localhost.localdomain> <1114604826.7670.24.camel@localhost.localdomain> <20050427233924.GA22238@gondor.apana.org.au> <1114650816.7663.13.camel@localhost.localdomain> <20050428012135.GA22950@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: jamal <hadi@cyberus.ca>
Content-Disposition: inline
In-Reply-To: <20050428012135.GA22950@gondor.apana.org.au>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Thu, Apr 28, 2005 at 11:21:35AM +1000, herbert wrote:
> 
> I see.  In that case you want to change your expression above
> so that the memcmp is never done if excl is off and the index
> is non-zero.  Otherwise this will result in non-deterministic
> behaviour as the result will change depending on whether the
> first hit is an index match or a selector match.

Sorry, the index match needs more work.  We need to maintain
these invariants:

1) There is only one policy with a given selector.
2) There is only one policy with a given index.

So to allow matching by index when updating, we need to deal
with the possibility of having to delete two existing policies.
The current code simply can't deal with that.

So if we're going to do this we'll need a bigger patch :)

Cheers,
-- 
Visit Openswan at http://www.openswan.org/
Email: Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
