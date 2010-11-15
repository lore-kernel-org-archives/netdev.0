From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH] net: use the macros defined for the members of flowi
Date: Mon, 15 Nov 2010 22:38:46 +0100
Message-ID: <1289857126.3364.14.camel@edumazet-laptop>
References: <1289623435-22713-1-git-send-email-xiaosuo@gmail.com>
	 <4CE1A710.9040603@hp.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Changli Gao <xiaosuo@gmail.com>,
	"David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org
To: Brian Haley <brian.haley@hp.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ww0-f44.google.com ([74.125.82.44]:42582 "EHLO
	mail-ww0-f44.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751823Ab0KOViw (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 15 Nov 2010 16:38:52 -0500
Received: by wwa36 with SMTP id 36so521830wwa.1
        for <netdev@vger.kernel.org>; Mon, 15 Nov 2010 13:38:51 -0800 (PST)
In-Reply-To: <4CE1A710.9040603@hp.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le lundi 15 novembre 2010 =C3=A0 16:33 -0500, Brian Haley a =C3=A9crit =
:
> On 11/12/2010 11:43 PM, Changli Gao wrote:
> > Use the macros defined for the members of flowi to clean the code u=
p.
> >=20
> > diff --git a/net/bridge/br_netfilter.c b/net/bridge/br_netfilter.c
> > index 865fd76..36cd0b7 100644
> > --- a/net/bridge/br_netfilter.c
> > +++ b/net/bridge/br_netfilter.c
> > @@ -412,13 +412,8 @@ static int br_nf_pre_routing_finish(struct sk_=
buff *skb)
> >  	if (dnat_took_place(skb)) {
> >  		if ((err =3D ip_route_input(skb, iph->daddr, iph->saddr, iph->to=
s, dev))) {
> >  			struct flowi fl =3D {
> > -				.nl_u =3D {
> > -					.ip4_u =3D {
> > -						 .daddr =3D iph->daddr,
> > -						 .saddr =3D 0,
> > -						 .tos =3D RT_TOS(iph->tos) },
> > -				},
> > -				.proto =3D 0,
> > +				.fl4_dst =3D iph->daddr,
> > +				.fl4_tos =3D RT_TOS(iph->tos),
> >  			};
>=20
> Are these actually equivalent?  You dropped two assignments to zero.
> I always thought things on the stack weren't.

Same question on lkml few hours ago. I think gcc does the assignement t=
o
zero, even on automatic variables (at least done on x86), but could not
find a doc on it.



