From: =?iso-8859-1?Q?Fran=E7ois-Xavier_Le_Bail?= <fx.lebail@yahoo.com>
Subject: Re: [PATCH net-next v4] IPv6: use anycast addresses as source addresses in echo reply
Date: Tue, 7 Jan 2014 04:38:22 -0800 (PST)
Message-ID: <1389098302.90053.YahooMailBasic@web125504.mail.ne1.yahoo.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: David Miller <davem@davemloft.net>, netdev@vger.kernel.org,
	kuznet@ms2.inr.ac.ru, jmorris@namei.org, yoshfuji@linux-ipv6.org,
	kaber@trash.net
To: Hannes Frederic Sowa <hannes@stressinduktion.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from nm43.bullet.mail.ne1.yahoo.com ([98.138.120.50]:27116 "HELO
	nm43.bullet.mail.ne1.yahoo.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with SMTP id S1751109AbaAGMlH convert rfc822-to-8bit
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 7 Jan 2014 07:41:07 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, 1/6/14, Hannes Frederic Sowa <hannes@stressinduktion.org> wrote=
:


> > > I think we should pass a valid device in unless it
> > > breaks something obvious.

> > The problem is that "saddr" is not necessarily an address on "skb->=
dev"
> > in icmpv6_echo_reply(). It may be an address on another interface.
=20
> Maybe you're right, but then I don't get it. Could you make
> an example?

Yes :
box with eth1, eth2, forwarding enable.

echo request arrives on eth2
-------------------------------> eth2 (2a01:3::1)  {forwarding enable} =
  eth1 (2a01:2::1)

if dest =3D=3D 2a01:3::
Jan=A0 7 10:36:36 localhost kernel: [=A0=A0=A059.155376] icmpv6_echo_re=
ply: saddr =3D=3D 2a01:3::
Jan=A0 7 10:36:36 localhost kernel: [=A0=A0=A059.155395] icmpv6_echo_re=
ply: skb->dev->name =3D=3D eth2
Jan=A0 7 10:36:36 localhost kernel: [=A0=A0=A059.155398] icmpv6_echo_re=
ply: ipv6_chk_acast_addr(net, skb->dev, saddr) =3D=3D 1
Jan=A0 7 10:36:36 localhost kernel: [=A0=A0=A059.155400] icmpv6_echo_re=
ply: ipv6_chk_acast_addr(net, NULL, saddr) =3D=3D 1
if dest =3D=3D 2a01:2::
Jan=A0 7 10:36:46 localhost kernel: [=A0=A0=A068.807565] icmpv6_echo_re=
ply: saddr =3D=3D 2a01:2::
Jan=A0 7 10:36:46 localhost kernel: [=A0=A0=A068.807580] icmpv6_echo_re=
ply: skb->dev->name =3D=3D eth2
Jan=A0 7 10:36:46 localhost kernel: [=A0=A0=A068.807583] icmpv6_echo_re=
ply: ipv6_chk_acast_addr(net, skb->dev, saddr) =3D=3D 0
Jan=A0 7 10:36:46 localhost kernel: [=A0=A0=A068.807586] icmpv6_echo_re=
ply: ipv6_chk_acast_addr(net, NULL, saddr) =3D=3D 1

So, as 2a01:2:: is a address on eth1, ipv6_chk_acast_addr(net, skb->dev=
, saddr) with dev =3D=3D eth2 return 0.

It is the reason why I use dev =3D=3D NULL.

Do your tests show something different ?

Anyway, although I think that this solution is valid, I am testing anot=
her way to do this change.

BR,
=46rancois-Xavier
