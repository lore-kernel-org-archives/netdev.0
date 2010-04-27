From: Stephen Hemminger <shemminger@vyatta.com>
Subject: Re: [PATCH net-next] bridge: multicast router list manipulation
Date: Tue, 27 Apr 2010 16:25:30 -0700
Message-ID: <20100427162530.04deb551@nehalam>
References: <20100228054012.GA7583@gondor.apana.org.au>
	<E1NlbuX-00021m-Bq@gondolin.me.apana.org.au>
	<20100427101311.2f445227@nehalam>
	<y2ne2d7436a1004271611h5dc5f184gcbbc6748839c3c58@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Herbert Xu <herbert@gondor.apana.org.au>,
	"David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org
To: =?UTF-8?B?TWljaGHFgiBNaXJvc8WCYXc=?= <mirqus@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.vyatta.com ([76.74.103.46]:34011 "EHLO mail.vyatta.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753263Ab0D0XZl convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 27 Apr 2010 19:25:41 -0400
In-Reply-To: <y2ne2d7436a1004271611h5dc5f184gcbbc6748839c3c58@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 28 Apr 2010 01:11:52 +0200
Micha=C5=82 Miros=C5=82aw <mirqus@gmail.com> wrote:

> 2010/4/27 Stephen Hemminger <shemminger@vyatta.com>:
> > I prefer that the hlist be only accessed through the hlist macro
> > objects. Explicit twiddling of links (especially with RCU) exposes
> > the code to future bugs.
> [...]
> > - =C2=A0 =C2=A0 =C2=A0 port->rlist.pprev =3D h;
> > - =C2=A0 =C2=A0 =C2=A0 port->rlist.next =3D p;
> > - =C2=A0 =C2=A0 =C2=A0 rcu_assign_pointer(*h, &port->rlist);
> > - =C2=A0 =C2=A0 =C2=A0 if (p)
> > - =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 p->pprev =3D &po=
rt->rlist.next;
> > + =C2=A0 =C2=A0 =C2=A0 hlist_for_each_entry(p, n, &br->router_list,=
 rlist) {
>=20
> Shouldn't this be hlist_for_each_entry_rcu?
>=20

This code should already be protected by br->multicast_lock
