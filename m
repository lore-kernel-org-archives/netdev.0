From: Hannes Frederic Sowa <hannes@stressinduktion.org>
Subject: Re: [PATCH net-next v4] IPv6: use anycast addresses as source addresses in echo reply
Date: Mon, 6 Jan 2014 11:56:14 +0100
Message-ID: <20140106105614.GB4611@order.stressinduktion.org>
References: <20140105230505.GA29910@order.stressinduktion.org> <1389004901.29746.YahooMailBasic@web125506.mail.ne1.yahoo.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org, "David S. Miller" <davem@davemloft.net>,
	Alexey Kuznetsov <kuznet@ms2.inr.ac.ru>,
	James Morris <jmorris@namei.org>,
	Hideaki Yoshifuji <yoshfuji@linux-ipv6.org>,
	Patrick McHardy <kaber@trash.net>
To: =?utf-8?Q?Fran=C3=A7ois-Xavier?= Le Bail <fx.lebail@yahoo.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from order.stressinduktion.org ([87.106.68.36]:41793 "EHLO
	order.stressinduktion.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753899AbaAFK4P (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 6 Jan 2014 05:56:15 -0500
Content-Disposition: inline
In-Reply-To: <1389004901.29746.YahooMailBasic@web125506.mail.ne1.yahoo.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Jan 06, 2014 at 02:41:41AM -0800, Fran=C3=A7ois-Xavier Le Bail =
wrote:
> On Sun, 1/5/14, Hannes Frederic Sowa <hannes@stressinduktion.org> wro=
te:
>=20
> > On Fri, Jan 03, 2014 at 05:43:31PM +0100, Francois-Xavier Le Bail w=
rote:
> > > diff --git a/net/ipv6/icmp.c b/net/ipv6/icmp.c
> > > index 5d42009..65c8619 100644
> > > --- a/net/ipv6/icmp.c
> > > +++ b/net/ipv6/icmp.c
> > > @@ -556,7 +556,9 @@ static void icmpv6_echo_reply(struct sk_buff =
*skb)
> > > =20
> > >  	saddr =3D &ipv6_hdr(skb)->daddr;
> > > =20
> > > -	if (!ipv6_unicast_destination(skb))
> > > +	if (!ipv6_unicast_destination(skb) &&
> > > +	    !(net->ipv6.anycast_src_echo_reply &&
> > > +	      ipv6_chk_acast_addr(net, NULL, saddr)))
> > >  		saddr =3D NULL;
>=20
> > I am not sure why you left out the device at ipv6_chk_acast_addr?
>=20
> > IMHO this logic is a bit more complex, we can pass NULL for ipv6 ad=
dresses of
> > scope global but need to check the interface for scope link.
>=20
> > It is already possible via setsockopt JOIN_ANYCAST that an ll addre=
ss is
> > anycast on another interface which may not be checked here.
>=20
> In this case, there are neighbor solicitations "who has LL anycast" w=
ith no reply, so no echo request is sent.

A counter-example would be NOARP interfaces where we also don't speak n=
disc.

> Do you find some problem testing my patch ?

A quick test I did yesterday looked good.

Greetings,

  Hannes
