From: Hannes Frederic Sowa <hannes@stressinduktion.org>
Subject: Re: [PATCH net-next v4] IPv6: use anycast addresses as source addresses in echo reply
Date: Tue, 7 Jan 2014 00:05:08 +0100
Message-ID: <20140106230508.GD10204@order.stressinduktion.org>
References: <1389045229.42277.YahooMailBasic@web125505.mail.ne1.yahoo.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: David Miller <davem@davemloft.net>, netdev@vger.kernel.org,
	kuznet@ms2.inr.ac.ru, jmorris@namei.org, yoshfuji@linux-ipv6.org,
	kaber@trash.net
To: =?utf-8?Q?Fran=C3=A7ois-Xavier?= Le Bail <fx.lebail@yahoo.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from order.stressinduktion.org ([87.106.68.36]:43508 "EHLO
	order.stressinduktion.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755477AbaAFXFJ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 6 Jan 2014 18:05:09 -0500
Content-Disposition: inline
In-Reply-To: <1389045229.42277.YahooMailBasic@web125505.mail.ne1.yahoo.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Jan 06, 2014 at 01:53:49PM -0800, Fran=C3=A7ois-Xavier Le Bail =
wrote:
> On Mon, 1/6/14, David Miller <davem@davemloft.net> wrote:
>=20
> > From: Hannes Frederic Sowa <hannes@stressinduktion.org>
> > Date: Mon, 6 Jan 2014 00:05:05 +0100
>=20
> >> On Fri, Jan 03, 2014 at 05:43:31PM +0100, Francois-Xavier Le Bail =
wrote:
> >>> diff --git a/net/ipv6/icmp.c b/net/ipv6/icmp.c
> >>> index 5d42009..65c8619 100644
> >>> --- a/net/ipv6/icmp.c
> >>> +++ b/net/ipv6/icmp.c
> >>> @@ -556,7 +556,9 @@ static void icmpv6_echo_reply(struct sk_buff =
*skb)
> >>>=C2=A0=20
> >>>=C2=A0 =C2=A0=C2=A0=C2=A0 saddr =3D &ipv6_hdr(skb)->daddr;
> >>>=C2=A0=20
> >>> -=C2=A0=C2=A0=C2=A0 if (!ipv6_unicast_destination(skb))
> >>> +=C2=A0=C2=A0=C2=A0 if (!ipv6_unicast_destination(skb) &&
> >>> +=C2=A0=C2=A0=C2=A0 =C2=A0 =C2=A0 !(net->ipv6.anycast_src_echo_re=
ply &&
> >>> +=C2=A0=C2=A0=C2=A0 =C2=A0 =C2=A0 =C2=A0 ipv6_chk_acast_addr(net,=
 NULL, saddr)))
> >>>=C2=A0 =C2=A0=C2=A0=C2=A0 =C2=A0=C2=A0=C2=A0 saddr =3D NULL;
> >>=20
> >> I am not sure why you left out the device at ipv6_chk_acast_addr?
> >>=20
> >> IMHO this logic is a bit more complex, we can pass NULL for ipv6 a=
ddresses of
> >> scope global but need to check the interface for scope link.
> >>=20
> >> It is already possible via setsockopt JOIN_ANYCAST that an ll addr=
ess is
> >> anycast on another interface which may not be checked here.
>=20
> > I think we should pass a valid device in unless it breaks something
> > obvious.
>=20
> The problem is that "saddr" is not necessarily an address on "skb->de=
v"
> in icmpv6_echo_reply(). It may be an address on another interface.

Maybe you're right, but then I don't get it. Could you make an example?

Thanks,

  Hannes
