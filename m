From: =?ISO-8859-2?Q?=A9tefan_Gula?= <steweg@ynet.sk>
Subject: Re: [patch v2, kernel version 3.2.1] net/ipv4/ip_gre: Ethernet
 multipoint GRE over IP
Date: Tue, 17 Jan 2012 11:40:44 +0100
Message-ID: <CAGsizzJk37G6DPgVJnpmxC7kBfbC4OqAp+YisaAfbNqSQq_bFg@mail.gmail.com>
References: <CAGsizz+x1GVNR9Pz=b7wO0ELx29=FMosfvhQWL5K26EpkwsUCg@mail.gmail.com>
 <20120116202907.GF1077372@jupiter.n2.diac24.net> <CAGsizz+NuyPHtau3b2LjCqdAGyrPf1-08v2uD0xJBSJS9qs5Fg@mail.gmail.com>
 <20120117095049.GG1077372@jupiter.n2.diac24.net> <CAGsizz+irKwP5VVmL3_0et+c9YwrHYZ6843dowZmMzA0osXNYg@mail.gmail.com>
 <20120117101131.GH1077372@jupiter.n2.diac24.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-2
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Alexey Kuznetsov <kuznet@ms2.inr.ac.ru>,
	"David S. Miller" <davem@davemloft.net>,
	James Morris <jmorris@namei.org>,
	Hideaki YOSHIFUJI <yoshfuji@linux-ipv6.org>,
	Patrick McHardy <kaber@trash.net>, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: David Lamparter <equinox@diac24.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20120117101131.GH1077372@jupiter.n2.diac24.net>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

D=F2a 17. janu=E1ra 2012 11:11, David Lamparter <equinox@diac24.net> na=
p=EDsal/a:
> On Tue, Jan 17, 2012 at 10:56:51AM +0100, =A9tefan Gula wrote:
>> D=F2a 17. janu=E1ra 2012 10:50, David Lamparter <equinox@diac24.net>=
 nap=EDsal/a:
>> > On Mon, Jan 16, 2012 at 11:52:25PM +0100, =A9tefan Gula wrote:
>> >> D=F2a 16. janu=E1ra 2012 21:29, David Lamparter <equinox@diac24.n=
et> nap=EDsal/a:
>> >> > At the risk of repeating myself, Linux GRE support already has
>> >> > provisions for multipoint tunnels. And unlike your code, those =
reuse the
>> >> > existing neighbor table infrastructure, including all of its us=
er
>> >> > interface and introspection capabilities.
>> >> >
>> >> > It's actually slightly visible in your patch:
>> >> >
>> >> > On Mon, Jan 16, 2012 at 08:45:14PM +0100, =A9tefan Gula wrote:
>> >> >> +++ linux-3.2.1-my/net/ipv4/ip_gre.c =A02012-01-16 20:42:03.00=
0000000 +0100
>> >> >> @@ -716,7 +942,19 @@ static netdev_tx_t ipgre_tunnel_xmit(str
>> >> > [...]
>> >> >> =A0 =A0 =A0 =A0 =A0 =A0 =A0 /* NBMA tunnel */
>> >> >>
>> >> >> =A0 =A0 =A0 =A0 =A0 =A0 =A0 if (skb_dst(skb) =3D=3D NULL) {
>> >> >
>> >> >
>> >> > -David
>> >>
>> >> That code you are referring to is used only for routed traffic in=
side
>> >> GRE - L3 traffic over L3 routed infrastructure. My patch is deali=
ng
>> >> with L2 traffic over L3 routed infrastructure - so the decision h=
ere
>> >> is based on destination MAC addresses and not based on IPv4/IPv6
>> >> addresses.
>> >
>> > Yes, it currently only does IPv4/IPv6 -> IPv4 through the neighbor
>> > table. That doesn't mean it can't be extended to handle ethernet
>> > addresses the same way.
>>
>> Routing mechanisms and switching mechanisms works completely
>> different, in switching you simply don't have anything like next-hop
>> from routing, which can be resolved by utilizing modified ARP messag=
e
>> and there is also absolutely no hierarchy in MAC address (like you
>> have in routing table), so I seriously doubt that it can be done the
>> same way, but I am opened to ideas here. So how would you do like to
>> do that?
>
> NBMA GRE does not use routing mechanisms, it uses the neighbor table.
> The neighbor table does not use any hierarchy in its lookups.
>
> So you have the existing neighbor table use cases:
> =A0- IPv4 -> MAC with in-kernel ARP
> =A0- IPv6 -> MAC with in-kernel ND
> =A0- IPv4 -> IPv4 on NBMA GRE devices (without in-kernel filling)
> =A0- IPv6 -> IPv4 on NBMA GRE devices (without in-kernel filling)
> You could add to that:
> =A0- MAC -> IPv4 on NBMA GRETAP devices
>
>
> -David
Current status:
 - no general neighbor table exists (currently used build-in tables
for forwarding mechanism ARP, ND, RT, RT6 or combinations to get the
right information)

Your proposal:
 - creating another kernel build-in table -  MAC -> IPv4 on NBMA
GRETAP device table doesn't currently exists at all in kernel
 - adjust/implement learning mechanism to populate the table
 - adjust/implement forwarding mechanisms to forward frames based on
information from given table

My patch:
- creates table for holding MAC -> IPv4 on NBMA GRETAP device
- adjust/implement learning mechanism (using bridge code logic)
- adjust/implement forwarding mechanism (using bridge code logic)

So I think we are talking about the same thing here, only you are
talking in more general way, I am talking more about the actual
implementation.
