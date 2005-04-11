From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: [2/4] [IPSEC] Kill spurious hard expire messages
Date: Mon, 11 Apr 2005 21:30:40 +1000
Message-ID: <20050411113040.GA25718@gondor.apana.org.au>
References: <1112702604.1089.119.camel@jzny.localdomain> <20050409105452.GA7171@gondor.apana.org.au> <20050409111244.GB7171@gondor.apana.org.au> <1113049844.1090.23.camel@jzny.localdomain> <20050409192926.GA9423@gondor.apana.org.au> <20050409200306.GA9660@gondor.apana.org.au> <1113142244.1088.287.camel@jzny.localdomain> <20050410212707.GA30337@gondor.apana.org.au> <1113218420.1090.351.camel@jzny.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: "David S. Miller" <davem@davemloft.net>,
        Masahide NAKAMURA <nakam@linux-ipv6.org>,
        Patrick McHardy <kaber@trash.net>, netdev <netdev@oss.sgi.com>
Return-path: <netdev-bounce@oss.sgi.com>
To: jamal <hadi@cyberus.ca>
Content-Disposition: inline
In-Reply-To: <1113218420.1090.351.camel@jzny.localdomain>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Hi Jamal:

On Mon, Apr 11, 2005 at 07:20:20AM -0400, jamal wrote:
>
> We started this discussion by asserting that an expire may be issued on
> a policy (or state) despite a delete event notification already having
> happened. Thats what we were/are trying to stop, no?

Yes.

> What i am saying is you are not stopping that with this:
> ---
>   if (!xfrm_policy_delete(xp, dir))
>         km_policy_expired(xp, dir, 1);
> ---
> 
> xfrm_policy_delete will return 0 whether the policy is dead or not.

xfrm_policy_delete returns 0 if and only if the policy was removed
from xfrm_policy_list.

A user-initiated delete policy action can only succeed if the policy
was removed from xfrm_policy_list.

The locking in xfrm_policy ensures that a given policy can only be
removed from the xfrm_policy_list once.

Therefore knowing that xfrm_policy_delete returned 0 implies that
no user-initiated delete action can succeed either before or after
the expire event.

Whether a policy is dead or not is equivalent to whether it's on
xfrm_policy_list.  That is, while it's on xfrm_policy_list it
must be alive.  As soon as it is removed from xfrm_policy_list it
is killed by the entity that performed the removal.

As a corollary, xfrm_policy_delete returns 0 if and only if the
policy was on xfrm_policy_list prior to the call and was successfully
removed by the call and subsequently killed.

> OTOH, if it returns <0 for the case where it is dead, then an expire
> event will not be issued. 

I'm not sure what you're trying to say here.

Cheers,
-- 
Visit Openswan at http://www.openswan.org/
Email: Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
