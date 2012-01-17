From: =?ISO-8859-2?Q?=A9tefan_Gula?= <steweg@ynet.sk>
Subject: Re: [patch v2, kernel version 3.2.1] net/ipv4/ip_gre: Ethernet
 multipoint GRE over IP
Date: Tue, 17 Jan 2012 10:56:51 +0100
Message-ID: <CAGsizz+irKwP5VVmL3_0et+c9YwrHYZ6843dowZmMzA0osXNYg@mail.gmail.com>
References: <CAGsizz+x1GVNR9Pz=b7wO0ELx29=FMosfvhQWL5K26EpkwsUCg@mail.gmail.com>
 <20120116202907.GF1077372@jupiter.n2.diac24.net> <CAGsizz+NuyPHtau3b2LjCqdAGyrPf1-08v2uD0xJBSJS9qs5Fg@mail.gmail.com>
 <20120117095049.GG1077372@jupiter.n2.diac24.net>
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
In-Reply-To: <20120117095049.GG1077372@jupiter.n2.diac24.net>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

D=F2a 17. janu=E1ra 2012 10:50, David Lamparter <equinox@diac24.net> na=
p=EDsal/a:
> On Mon, Jan 16, 2012 at 11:52:25PM +0100, =A9tefan Gula wrote:
>> D=F2a 16. janu=E1ra 2012 21:29, David Lamparter <equinox@diac24.net>=
 nap=EDsal/a:
>> > At the risk of repeating myself, Linux GRE support already has
>> > provisions for multipoint tunnels. And unlike your code, those reu=
se the
>> > existing neighbor table infrastructure, including all of its user
>> > interface and introspection capabilities.
>> >
>> > It's actually slightly visible in your patch:
>> >
>> > On Mon, Jan 16, 2012 at 08:45:14PM +0100, =A9tefan Gula wrote:
>> >> +++ linux-3.2.1-my/net/ipv4/ip_gre.c =A02012-01-16 20:42:03.00000=
0000 +0100
>> >> @@ -716,7 +942,19 @@ static netdev_tx_t ipgre_tunnel_xmit(str
>> > [...]
>> >> =A0 =A0 =A0 =A0 =A0 =A0 =A0 /* NBMA tunnel */
>> >>
>> >> =A0 =A0 =A0 =A0 =A0 =A0 =A0 if (skb_dst(skb) =3D=3D NULL) {
>> >
>> >
>> > -David
>>
>> That code you are referring to is used only for routed traffic insid=
e
>> GRE - L3 traffic over L3 routed infrastructure. My patch is dealing
>> with L2 traffic over L3 routed infrastructure - so the decision here
>> is based on destination MAC addresses and not based on IPv4/IPv6
>> addresses.
>
> Yes, it currently only does IPv4/IPv6 -> IPv4 through the neighbor
> table. That doesn't mean it can't be extended to handle ethernet
> addresses the same way.
>
>
> -David

Routing mechanisms and switching mechanisms works completely
different, in switching you simply don't have anything like next-hop
from routing, which can be resolved by utilizing modified ARP message
and there is also absolutely no hierarchy in MAC address (like you
have in routing table), so I seriously doubt that it can be done the
same way, but I am opened to ideas here. So how would you do like to
do that?
