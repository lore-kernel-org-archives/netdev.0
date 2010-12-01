From: Stephen Hemminger <shemminger@vyatta.com>
Subject: Re: [PATCH] ipv6: slightly simplify keeping IPv6 addresses on link
 down
Date: Wed, 1 Dec 2010 13:04:21 -0800
Message-ID: <20101201130421.0ac08bcd@nehalam>
References: <20101201.110157.246534994.davem@davemloft.net>
	<AAs7234jas72lda05laWgh1LziatUa+qSHd+6Jj+k_eO=@mail.gmail.com>
	<20101201122253.2a8be2e0@nehalam>
	<AANLkTin5f+BZnFEzuc6iPLC8Hp++V0Jam8aAU2jMvxQq@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org, David Miller <davem@davemloft.net>
To: Lorenzo Colitti <lorenzo@google.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.vyatta.com ([76.74.103.46]:44999 "EHLO mail.vyatta.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755600Ab0LAVEY convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 1 Dec 2010 16:04:24 -0500
In-Reply-To: <AANLkTin5f+BZnFEzuc6iPLC8Hp++V0Jam8aAU2jMvxQq@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 1 Dec 2010 12:52:42 -0800
Lorenzo Colitti <lorenzo@google.com> wrote:

> On Wed, Dec 1, 2010 at 12:22 PM, Stephen Hemminger
> <shemminger@vyatta.com> wrote:
> > > --- a/net/ipv6/addrconf.c
> > > +++ b/net/ipv6/addrconf.c
> > > @@ -2663,7 +2663,8 @@ static int addrconf_ifdown(struct net_devic=
e *dev, int how)
> > > =A0{
> > > =A0 =A0 =A0 struct net *net =3D dev_net(dev);
> > > =A0 =A0 =A0 struct inet6_dev *idev;
> > > - =A0 =A0 struct inet6_ifaddr *ifa, *ifn;
> > > + =A0 =A0 struct inet6_ifaddr *ifa;
> > > + =A0 =A0 LIST_HEAD(keep_list);
> > > =A0 =A0 =A0 int state;
> >
> > Your patch is backwards? The existing code is:
>=20
> Oops, yes. Wrong order of arguments. Another one coming up.
>=20
> > Also, the addrconf_ifdown can race with other updates to idev->addr=
_list
> > from addrconf timers etc. =A0Therefore even list_for_each_entry_saf=
e is not safe.
>=20
> No, wait... The loop is protected by idev->lock, and the code just
> before it that clears the temporary address list is essentially
> identical (except it looks over tempaddr_list instead). Wouldn't that
> blow up as well?

The old code walked the list until it was empty. New code could
get confused if list changed by other changes during the
period when idev->lock is dropped and notifier is called.



--=20
