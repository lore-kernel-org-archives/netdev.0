From: Stephen Hemminger <shemminger@vyatta.com>
Subject: Re: [PATCH net-next] bridge: multicast router list manipulation
Date: Tue, 27 Apr 2010 16:44:12 -0700
Message-ID: <20100427164412.791e4999@nehalam>
References: <20100427101311.2f445227@nehalam>
	<y2ne2d7436a1004271611h5dc5f184gcbbc6748839c3c58@mail.gmail.com>
	<20100427162530.04deb551@nehalam>
	<20100427.162811.233419535.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: mirqus@gmail.com, herbert@gondor.apana.org.au,
	netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.vyatta.com ([76.74.103.46]:35004 "EHLO mail.vyatta.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754586Ab0D0Xod convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 27 Apr 2010 19:44:33 -0400
In-Reply-To: <20100427.162811.233419535.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 27 Apr 2010 16:28:11 -0700 (PDT)
David Miller <davem@davemloft.net> wrote:

> From: Stephen Hemminger <shemminger@vyatta.com>
> Date: Tue, 27 Apr 2010 16:25:30 -0700
>=20
> > On Wed, 28 Apr 2010 01:11:52 +0200
> > Micha=C5=82 Miros=C5=82aw <mirqus@gmail.com> wrote:
> >=20
> >> 2010/4/27 Stephen Hemminger <shemminger@vyatta.com>:
> >> > I prefer that the hlist be only accessed through the hlist macro
> >> > objects. Explicit twiddling of links (especially with RCU) expos=
es
> >> > the code to future bugs.
> >> [...]
> >> > - =C2=A0 =C2=A0 =C2=A0 port->rlist.pprev =3D h;
> >> > - =C2=A0 =C2=A0 =C2=A0 port->rlist.next =3D p;
> >> > - =C2=A0 =C2=A0 =C2=A0 rcu_assign_pointer(*h, &port->rlist);
> >> > - =C2=A0 =C2=A0 =C2=A0 if (p)
> >> > - =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 p->pprev =3D =
&port->rlist.next;
> >> > + =C2=A0 =C2=A0 =C2=A0 hlist_for_each_entry(p, n, &br->router_li=
st, rlist) {
> >>=20
> >> Shouldn't this be hlist_for_each_entry_rcu?
> >>=20
> >=20
> > This code should already be protected by br->multicast_lock
>=20
> But the adds et al. use RCU already, I think we should be consistent
> one way or another.
>=20
> I've already made Micha=C5=82's suggested change to net-next-2.6, if =
you
> think _rcu() isn't necessary then trim it from all the hlist calls
> in this function.

Code that doesn't need rcu for traversal should not use it.
It just confuses things and implies that rcu_read_lock is held
which it is not in this code.
