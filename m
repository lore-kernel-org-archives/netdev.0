From: David Lamparter <equinox@diac24.net>
Subject: Re: [patch v2, kernel version 3.2.1] net/ipv4/ip_gre: Ethernet
 multipoint GRE over IP
Date: Tue, 17 Jan 2012 11:11:31 +0100
Message-ID: <20120117101131.GH1077372@jupiter.n2.diac24.net>
References: <CAGsizz+x1GVNR9Pz=b7wO0ELx29=FMosfvhQWL5K26EpkwsUCg@mail.gmail.com>
 <20120116202907.GF1077372@jupiter.n2.diac24.net>
 <CAGsizz+NuyPHtau3b2LjCqdAGyrPf1-08v2uD0xJBSJS9qs5Fg@mail.gmail.com>
 <20120117095049.GG1077372@jupiter.n2.diac24.net>
 <CAGsizz+irKwP5VVmL3_0et+c9YwrHYZ6843dowZmMzA0osXNYg@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: David Lamparter <equinox@diac24.net>,
	Alexey Kuznetsov <kuznet@ms2.inr.ac.ru>,
	"David S. Miller" <davem@davemloft.net>,
	James Morris <jmorris@namei.org>,
	Hideaki YOSHIFUJI <yoshfuji@linux-ipv6.org>,
	Patrick McHardy <kaber@trash.net>, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: =?utf-8?Q?=C5=A0tefan?= Gula <steweg@ynet.sk>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <CAGsizz+irKwP5VVmL3_0et+c9YwrHYZ6843dowZmMzA0osXNYg@mail.gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tue, Jan 17, 2012 at 10:56:51AM +0100, =C5=A0tefan Gula wrote:
> D=C5=88a 17. janu=C3=A1ra 2012 10:50, David Lamparter <equinox@diac24=
=2Enet> nap=C3=ADsal/a:
> > On Mon, Jan 16, 2012 at 11:52:25PM +0100, =C5=A0tefan Gula wrote:
> >> D=C5=88a 16. janu=C3=A1ra 2012 21:29, David Lamparter <equinox@dia=
c24.net> nap=C3=ADsal/a:
> >> > At the risk of repeating myself, Linux GRE support already has
> >> > provisions for multipoint tunnels. And unlike your code, those r=
euse the
> >> > existing neighbor table infrastructure, including all of its use=
r
> >> > interface and introspection capabilities.
> >> >
> >> > It's actually slightly visible in your patch:
> >> >
> >> > On Mon, Jan 16, 2012 at 08:45:14PM +0100, =C5=A0tefan Gula wrote=
:
> >> >> +++ linux-3.2.1-my/net/ipv4/ip_gre.c =C2=A02012-01-16 20:42:03.=
000000000 +0100
> >> >> @@ -716,7 +942,19 @@ static netdev_tx_t ipgre_tunnel_xmit(str
> >> > [...]
> >> >> =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 /* NBMA tunnel=
 */
> >> >>
> >> >> =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 if (skb_dst(sk=
b) =3D=3D NULL) {
> >> >
> >> >
> >> > -David
> >>
> >> That code you are referring to is used only for routed traffic ins=
ide
> >> GRE - L3 traffic over L3 routed infrastructure. My patch is dealin=
g
> >> with L2 traffic over L3 routed infrastructure - so the decision he=
re
> >> is based on destination MAC addresses and not based on IPv4/IPv6
> >> addresses.
> >
> > Yes, it currently only does IPv4/IPv6 -> IPv4 through the neighbor
> > table. That doesn't mean it can't be extended to handle ethernet
> > addresses the same way.
>=20
> Routing mechanisms and switching mechanisms works completely
> different, in switching you simply don't have anything like next-hop
> from routing, which can be resolved by utilizing modified ARP message
> and there is also absolutely no hierarchy in MAC address (like you
> have in routing table), so I seriously doubt that it can be done the
> same way, but I am opened to ideas here. So how would you do like to
> do that?

NBMA GRE does not use routing mechanisms, it uses the neighbor table.
The neighbor table does not use any hierarchy in its lookups.

So you have the existing neighbor table use cases:
 - IPv4 -> MAC with in-kernel ARP
 - IPv6 -> MAC with in-kernel ND
 - IPv4 -> IPv4 on NBMA GRE devices (without in-kernel filling)
 - IPv6 -> IPv4 on NBMA GRE devices (without in-kernel filling)
You could add to that:
 - MAC -> IPv4 on NBMA GRETAP devices


-David
