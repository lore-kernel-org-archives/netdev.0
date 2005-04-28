From: jamal <hadi@cyberus.ca>
Subject: Re: patch: policy update by id
Date: Wed, 27 Apr 2005 21:52:20 -0400
Message-ID: <1114653140.7663.36.camel@localhost.localdomain>
References: <1114602874.7670.4.camel@localhost.localdomain>
	 <1114604657.7670.22.camel@localhost.localdomain>
	 <1114604826.7670.24.camel@localhost.localdomain>
	 <20050427233924.GA22238@gondor.apana.org.au>
	 <1114650816.7663.13.camel@localhost.localdomain>
	 <20050428012135.GA22950@gondor.apana.org.au>
	 <20050428013014.GA23043@gondor.apana.org.au>
Reply-To: hadi@cyberus.ca
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Herbert Xu <herbert@gondor.apana.org.au>
In-Reply-To: <20050428013014.GA23043@gondor.apana.org.au>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Thu, 2005-28-04 at 11:30 +1000, Herbert Xu wrote:
> On Thu, Apr 28, 2005 at 11:21:35AM +1000, herbert wrote:
> > 
> > I see.  In that case you want to change your expression above
> > so that the memcmp is never done if excl is off and the index
> > is non-zero.  Otherwise this will result in non-deterministic
> > behaviour as the result will change depending on whether the
> > first hit is an index match or a selector match.
> 
> Sorry, the index match needs more work.  We need to maintain
> these invariants:
> 
> 1) There is only one policy with a given selector.
> 2) There is only one policy with a given index.
> 
> So to allow matching by index when updating, we need to deal
> with the possibility of having to delete two existing policies.
> The current code simply can't deal with that.
> 

Well, while snooping i was bothered as well. I am not sure i agree with
your #1 above ;->

1) It would seem to me that the priority field is to be used 
as a ambiguity resolver (thats what a gazillion other classification
schemes do). 

Lets take an example of an add:
If i specify a priority and a selector matches when doing an add, then
the priority being different should allow me to add the rule even if the
selectors match. 
Current behavior: We dont allow entering multiple selectors with the
same value even if i specify a different prio.

2) index really oughta be unique across the SPD.  
Current behavior: I can add several new rules with the same index.

I realize what i am asking in #2 is the opposite of what i ask for in 
#1 - the big unresolved question is: if both selector and index are
going to be keys to manipulating the SPD, then their behavior needs to
be consistent with each other. I really like to see the index being
unique, but the selector being priority disambiguated.


> So if we're going to do this we'll need a bigger patch :)

Lets agree on the principles first ;-> The patch i sent maintains the
status quo.

cheers,
jamal
