From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: PATCH: IPSEC xfrm events
Date: Fri, 1 Apr 2005 22:35:54 +1000
Message-ID: <20050401123554.GA3468@gondor.apana.org.au>
References: <1112319441.1089.83.camel@jzny.localdomain> <20050401042106.GA27762@gondor.apana.org.au> <1112353398.1096.116.camel@jzny.localdomain> <20050401114258.GA2932@gondor.apana.org.au> <1112358278.1096.160.camel@jzny.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Patrick McHardy <kaber@trash.net>,
        Masahide NAKAMURA <nakam@linux-ipv6.org>,
        "David S. Miller" <davem@davemloft.net>, netdev <netdev@oss.sgi.com>
Return-path: <netdev-bounce@oss.sgi.com>
To: jamal <hadi@cyberus.ca>
Content-Disposition: inline
In-Reply-To: <1112358278.1096.160.camel@jzny.localdomain>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Fri, Apr 01, 2005 at 07:24:38AM -0500, jamal wrote:
> 
> I think either scheme is fine really;-> I will definetely go back and
> consider the approach you are suggesting and see if it results into
> more maintanable code - then fair. Otherwise you realize its more work
> for me ;->

Well I'm happy to code that part if you want :)
 
> I havent checked the state machine closely, but the following seems to
> make sense:
> The first thing that happens to delete the state/policy should win if
> the state/policy is transitioned to dead. 

Agreed.  That's what we'll get if we make __xfrm_state_delete return
success/failure.
 
> So why would you generate an event in the case when you didnt delete anything?

You're right that the RFC isn't very clear.

Let's forget about the RFC and simply consider the usefulness of this.
I contend that it is useful to see a FLUSH notification even when
it flushed nothing.

The reason is that this is an indication to all listeners that the
database is completely empty.

> > Well when the policy expires you will get one expire notification from
> > the current timer code and a new one from your patch since the timer
> > calls xfrm_policy_delete.
> >
> > See my point? By putting the call in xfrm_policy.c you have to be
> > really careful in dividing the internal users which shouldn't
> > generate notifications and the external users which should.  By doing
> > it in af_key/xfrm_user you can avoid all this work.
> 
> Thats a bug really which is being exposed now. So it has nothing to do
> with the approach taken ;-> 

You're right that it is a bug.  However, this bug would've never triggered
before because we simply didn't have delete policy notifications :)

> No expire should be sent if the policy has transitioned to dead. The bug
> is trivial to fix - and actually should be fixed regardless of this
> patch.

Yes the same fix to __xfrm_state_delete can be applied to
xfrm_policy_delete.

Cheers,
-- 
Visit Openswan at http://www.openswan.org/
Email: Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
