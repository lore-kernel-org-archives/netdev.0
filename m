From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] net: use the macros defined for the members of flowi
Date: Mon, 15 Nov 2010 17:56:48 -0800 (PST)
Message-ID: <20101115.175648.226754712.davem@davemloft.net>
References: <1289623435-22713-1-git-send-email-xiaosuo@gmail.com>
	<4CE1A710.9040603@hp.com>
	<1289857126.3364.14.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: brian.haley@hp.com, xiaosuo@gmail.com, netdev@vger.kernel.org
To: eric.dumazet@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:53342
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1759098Ab0KPB4X convert rfc822-to-8bit
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 15 Nov 2010 20:56:23 -0500
In-Reply-To: <1289857126.3364.14.camel@edumazet-laptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

=46rom: Eric Dumazet <eric.dumazet@gmail.com>
Date: Mon, 15 Nov 2010 22:38:46 +0100

> Le lundi 15 novembre 2010 =E0 16:33 -0500, Brian Haley a =E9crit :
>> On 11/12/2010 11:43 PM, Changli Gao wrote:
>> > Use the macros defined for the members of flowi to clean the code =
up.
>> >=20
>> > diff --git a/net/bridge/br_netfilter.c b/net/bridge/br_netfilter.c
>> > index 865fd76..36cd0b7 100644
>> > --- a/net/bridge/br_netfilter.c
>> > +++ b/net/bridge/br_netfilter.c
>> > @@ -412,13 +412,8 @@ static int br_nf_pre_routing_finish(struct sk=
_buff *skb)
>> >  	if (dnat_took_place(skb)) {
>> >  		if ((err =3D ip_route_input(skb, iph->daddr, iph->saddr, iph->t=
os, dev))) {
>> >  			struct flowi fl =3D {
>> > -				.nl_u =3D {
>> > -					.ip4_u =3D {
>> > -						 .daddr =3D iph->daddr,
>> > -						 .saddr =3D 0,
>> > -						 .tos =3D RT_TOS(iph->tos) },
>> > -				},
>> > -				.proto =3D 0,
>> > +				.fl4_dst =3D iph->daddr,
>> > +				.fl4_tos =3D RT_TOS(iph->tos),
>> >  			};
>>=20
>> Are these actually equivalent?  You dropped two assignments to zero.
>> I always thought things on the stack weren't.
>=20
> Same question on lkml few hours ago. I think gcc does the assignement=
 to
> zero, even on automatic variables (at least done on x86), but could n=
ot
> find a doc on it.

It always has, it always will.  "type var =3D { };" always zeros
out the structure.

