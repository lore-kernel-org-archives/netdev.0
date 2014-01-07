From: Hannes Frederic Sowa <hannes@stressinduktion.org>
Subject: Re: [PATCH net-next v4] IPv6: use anycast addresses as source addresses in echo reply
Date: Tue, 7 Jan 2014 14:01:01 +0100
Message-ID: <20140107130101.GD24730@order.stressinduktion.org>
References: <1389098302.90053.YahooMailBasic@web125504.mail.ne1.yahoo.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: David Miller <davem@davemloft.net>, netdev@vger.kernel.org,
	kuznet@ms2.inr.ac.ru, jmorris@namei.org, yoshfuji@linux-ipv6.org,
	kaber@trash.net
To: =?utf-8?Q?Fran=C3=A7ois-Xavier?= Le Bail <fx.lebail@yahoo.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from order.stressinduktion.org ([87.106.68.36]:45003 "EHLO
	order.stressinduktion.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751489AbaAGNBC (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 7 Jan 2014 08:01:02 -0500
Content-Disposition: inline
In-Reply-To: <1389098302.90053.YahooMailBasic@web125504.mail.ne1.yahoo.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Jan 07, 2014 at 04:38:22AM -0800, Fran=C3=A7ois-Xavier Le Bail =
wrote:
> On Mon, 1/6/14, Hannes Frederic Sowa <hannes@stressinduktion.org> wro=
te:
>=20
>=20
> > > > I think we should pass a valid device in unless it
> > > > breaks something obvious.
>=20
> > > The problem is that "saddr" is not necessarily an address on "skb=
->dev"
> > > in icmpv6_echo_reply(). It may be an address on another interface=
=2E
> =20
> > Maybe you're right, but then I don't get it. Could you make
> > an example?
>=20
> Yes :
> box with eth1, eth2, forwarding enable.
>=20
> echo request arrives on eth2
> -------------------------------> eth2 (2a01:3::1)  {forwarding enable=
}   eth1 (2a01:2::1)
>=20
> if dest =3D=3D 2a01:3::
> Jan=C2=A0 7 10:36:36 localhost kernel: [=C2=A0=C2=A0=C2=A059.155376] =
icmpv6_echo_reply: saddr =3D=3D 2a01:3::
> Jan=C2=A0 7 10:36:36 localhost kernel: [=C2=A0=C2=A0=C2=A059.155395] =
icmpv6_echo_reply: skb->dev->name =3D=3D eth2
> Jan=C2=A0 7 10:36:36 localhost kernel: [=C2=A0=C2=A0=C2=A059.155398] =
icmpv6_echo_reply: ipv6_chk_acast_addr(net, skb->dev, saddr) =3D=3D 1
> Jan=C2=A0 7 10:36:36 localhost kernel: [=C2=A0=C2=A0=C2=A059.155400] =
icmpv6_echo_reply: ipv6_chk_acast_addr(net, NULL, saddr) =3D=3D 1
> if dest =3D=3D 2a01:2::
> Jan=C2=A0 7 10:36:46 localhost kernel: [=C2=A0=C2=A0=C2=A068.807565] =
icmpv6_echo_reply: saddr =3D=3D 2a01:2::
> Jan=C2=A0 7 10:36:46 localhost kernel: [=C2=A0=C2=A0=C2=A068.807580] =
icmpv6_echo_reply: skb->dev->name =3D=3D eth2
> Jan=C2=A0 7 10:36:46 localhost kernel: [=C2=A0=C2=A0=C2=A068.807583] =
icmpv6_echo_reply: ipv6_chk_acast_addr(net, skb->dev, saddr) =3D=3D 0
> Jan=C2=A0 7 10:36:46 localhost kernel: [=C2=A0=C2=A0=C2=A068.807586] =
icmpv6_echo_reply: ipv6_chk_acast_addr(net, NULL, saddr) =3D=3D 1
>=20
> So, as 2a01:2:: is a address on eth1, ipv6_chk_acast_addr(net, skb->d=
ev, saddr) with dev =3D=3D eth2 return 0.
>=20
> It is the reason why I use dev =3D=3D NULL.
>=20
> Do your tests show something different ?

I haven't tested this particular setup.

>=20
> Anyway, although I think that this solution is valid, I am testing an=
other way to do this change.

Ok, thanks for explaining, I see now, of course.

Maybe we could just do (ipv6_addr_type(addr) & IPV6_ADDR_LINKLOCAL) ? s=
kb->dev
: NULL?

I guess the NULL solution would be ok now, too. You can decide. I just
think we can be a bit more defensive here with no additional cost. Rout=
ing
table behaviour is pretty complicated and maybe can change in future.

Thank you,

  Hannes
