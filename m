From: =?iso-8859-1?Q?Fran=E7ois-Xavier_Le_Bail?= <fx.lebail@yahoo.com>
Subject: Re: [PATCH net-next v4] IPv6: use anycast addresses as source addresses in echo reply
Date: Mon, 6 Jan 2014 05:48:16 -0800 (PST)
Message-ID: <1389016096.57230.YahooMailBasic@web125502.mail.ne1.yahoo.com>
References: <20140106105614.GB4611@order.stressinduktion.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org, "David S. Miller" <davem@davemloft.net>,
	Alexey Kuznetsov <kuznet@ms2.inr.ac.ru>,
	James Morris <jmorris@namei.org>,
	Hideaki Yoshifuji <yoshfuji@linux-ipv6.org>,
	Patrick McHardy <kaber@trash.net>
To: Hannes Frederic Sowa <hannes@stressinduktion.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from nm35.bullet.mail.ne1.yahoo.com ([98.138.229.28]:35277 "HELO
	nm35.bullet.mail.ne1.yahoo.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with SMTP id S1750990AbaAFNvO convert rfc822-to-8bit
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 6 Jan 2014 08:51:14 -0500
In-Reply-To: <20140106105614.GB4611@order.stressinduktion.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, 1/6/14, Hannes Frederic Sowa <hannes@stressinduktion.org> wrote=
:

> On Mon, Jan 06, 2014 at 02:41:41AM -0800, Fran=E7ois-Xavier Le Bail w=
rote:
> > On Sun, 1/5/14, Hannes Frederic Sowa <hannes@stressinduktion.org> w=
rote:
> >=20
> > > On Fri, Jan 03, 2014 at 05:43:31PM +0100, Francois-Xavier Le Bail=
 wrote:
> > > > diff --git a/net/ipv6/icmp.c b/net/ipv6/icmp.c
> > > > index 5d42009..65c8619 100644
> > > > --- a/net/ipv6/icmp.c
> > > > +++ b/net/ipv6/icmp.c
> > > > @@ -556,7 +556,9 @@ static void icmpv6_echo_reply(struct sk_buf=
f *skb)
> > > > =20
> > > >  	saddr =3D &ipv6_hdr(skb)->daddr;
> > > > =20
> > > > -	if (!ipv6_unicast_destination(skb))
> > > > +	if (!ipv6_unicast_destination(skb) &&
> > > > +	    !(net->ipv6.anycast_src_echo_reply &&
> > > > +	      ipv6_chk_acast_addr(net, NULL, saddr)))
> > > >  		saddr =3D NULL;
> >=20
> > > I am not sure why you left out the device at ipv6_chk_acast_addr?
> >=20
> > > IMHO this logic is a bit more complex, we can pass NULL for ipv6 =
addresses of
> > > scope global but need to check the interface for scope link.
> >=20
> > > It is already possible via setsockopt JOIN_ANYCAST that an ll add=
ress is
> > > anycast on another interface which may not be checked here.
> >=20
> > In this case, there are neighbor solicitations "who has LL anycast"=
 with no reply, so no echo request is sent.
>=20
> A counter-example would be NOARP interfaces where we also don't speak=
 ndisc.

Right. But if an echo request arrive on an interface which do not liste=
n at this LL anycast, is a reply can occur ?

> > Do you find some problem testing my patch ?
>=20
> A quick test I did yesterday looked good.

Thanks for the test.
