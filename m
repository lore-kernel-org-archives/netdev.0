From: jamal <hadi@cyberus.ca>
Subject: Re: RFC: IPSEC patch 0 for netlink events
Date: 30 Mar 2005 08:18:25 -0500
Message-ID: <1112188704.1088.170.camel@jzny.localdomain>
References: <1111864971.1092.904.camel@jzny.localdomain>
	 <20050326194707.GA9872@gondor.apana.org.au>
	 <1111867875.1089.915.camel@jzny.localdomain>
	 <20050327081848.GA13428@gondor.apana.org.au>
	 <1111950449.1089.938.camel@jzny.localdomain>
	 <20050330125518.GA10853@gondor.apana.org.au>
Reply-To: hadi@cyberus.ca
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: Patrick McHardy <kaber@trash.net>,
        Masahide NAKAMURA <nakam@linux-ipv6.org>,
        "David S. Miller" <davem@davemloft.net>, netdev <netdev@oss.sgi.com>
Return-path: <netdev-bounce@oss.sgi.com>
To: Herbert Xu <herbert@gondor.apana.org.au>
In-Reply-To: <20050330125518.GA10853@gondor.apana.org.au>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Wed, 2005-03-30 at 07:55, Herbert Xu wrote:
> Hi Jamal:
> 
> On Sun, Mar 27, 2005 at 02:07:29PM -0500, jamal wrote:
> >
> > @@ -478,6 +491,9 @@
> >  
> >  	if (x1->km.state == XFRM_STATE_ACQ) {
> >  		__xfrm_state_insert(x);
> > +		/* XXXX: We already have xfrm_state_lock
> > +		 * do we need to grab x->lock as well? */
> > +		xfrm_sa_notify(x, c, XFRM_SA_ADDED);
> 
> Actually, this shouldn't be here at all.
> 
> Calls to xfrm_sa_notify (better to call it km_state_notify for
> consistency) should be made from the places where we currently
> call pfkey_broadcast and the corresponding locations in xfrm_user.
> 

we let the km make the call; pfkey already had these calls and i believe
they are the ones that should go in order to be generic. Actually more
like split into two. But thats defered for later (if it ever gets done).

cheers,
jamal
