From: Jarek Poplawski <jarkao2@gmail.com>
Subject: Re: Regression, bisected: reference leak with IPSec since ~2.6.31
Date: Tue, 21 Sep 2010 09:38:53 +0000
Message-ID: <20100921093853.GA8664@ff.dom.local>
References: <20100921091248.GA8424@ff.dom.local> <1285060860.2617.158.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Nick Bowler <nbowler@elliptictech.com>,
	linux-kernel@vger.kernel.org, netdev@vger.kernel.org,
	"David S. Miller" <davem@davemloft.net>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <1285060860.2617.158.camel@edumazet-laptop>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tue, Sep 21, 2010 at 11:21:00AM +0200, Eric Dumazet wrote:
> Le mardi 21 septembre 2010 ?? 09:12 +0000, Jarek Poplawski a =E9crit =
:
> > On 2010-09-20 23:31, Eric Dumazet wrote:
> > ...
> > > @@ -510,11 +509,13 @@ int ip_fragment(struct sk_buff *skb, int (*=
output)(struct sk_buff *))
> > >  				goto slow_path;
> > > =20
> > >  			BUG_ON(frag->sk);
> > > -			if (skb->sk) {
> > > +		}
> > > +		if (skb->sk) {
> > > +			skb_walk_frags(skb, frag) {
> > >  				frag->sk =3D skb->sk;
> > >  				frag->destructor =3D sock_wfree;
> >=20
> > Nice catch, but it seems doing it in the first loop as now, and
> > reverting changes before goto slow_path might be more optimal here.
> >=20
>=20
> I thought of this, but found this function already very complex.
>=20
> Once everything is in cpu caches, the added loop is very cheap.

I hope you're right with this.

>=20
> I liked the :
>=20
> <check everything without changing state>
> if something wrong
> 	goto slow_path
> else
> 	<OK, lets do destructive things>
>=20

But it's an optimization of the "unlikely" case btw. ;-)

Jarek P.
