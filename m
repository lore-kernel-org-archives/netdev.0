From: Hannes Frederic Sowa <hannes@stressinduktion.org>
Subject: Re: [PATCH] ipv6: replace RTF_ROUTEINFO with RTF_ADDRCONF in  rt6_get_route_info()
Date: Thu, 7 Nov 2013 13:19:01 +0100
Message-ID: <20131107121901.GJ8144@order.stressinduktion.org>
References: <5279EF31.4040705@cn.fujitsu.com> <20131107015100.GF8144@order.stressinduktion.org> <527AF477.1060604@cn.fujitsu.com> <20131107024202.GH8144@order.stressinduktion.org> <527B14B9.7040305@cn.fujitsu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: David Miller <davem@davemloft.net>, netdev@vger.kernel.org
To: Duan Jiong <duanj.fnst@cn.fujitsu.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from order.stressinduktion.org ([87.106.68.36]:55421 "EHLO
	order.stressinduktion.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751143Ab3KGMTC (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 7 Nov 2013 07:19:02 -0500
Content-Disposition: inline
In-Reply-To: <527B14B9.7040305@cn.fujitsu.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Nov 07, 2013 at 12:19:05PM +0800, Duan Jiong wrote:
> =E4=BA=8E 2013=E5=B9=B411=E6=9C=8807=E6=97=A5 10:42, Hannes Frederic =
Sowa =E5=86=99=E9=81=93:
> > On Thu, Nov 07, 2013 at 10:01:27AM +0800, Duan Jiong wrote:
> >> =E4=BA=8E 2013=E5=B9=B411=E6=9C=8807=E6=97=A5 09:51, Hannes Freder=
ic Sowa =E5=86=99=E9=81=93:
> >>> On Wed, Nov 06, 2013 at 03:26:41PM +0800, Duan Jiong wrote:
> >>>>
> >>>> As the rfc 4191 said, the Router Preference and Lifetime values =
in a
> >>>> ::/0 Route Information Option should override the preference and=
 lifetime
> >>>> values in the Router Advertisement header. But when the kernel d=
eals with
> >>>> a ::/0 Route Information Option, the rt6_get_route_info() always=
 return
> >>>> NULL, that means that overriding will not happen, because those =
default
> >>>> routers were added without flag RTF_ROUTEINFO in rt6_add_dflt_ro=
uter().
> >>>>
> >>>> In order to match those default routers, we can replace RTF_ROUT=
EINFO=20
> >>>> with RTF_ADDRCONF in rt6_get_route_info().
> >>>>
> >>>> Signed-off-by: Duan Jiong <duanj.fnst@cn.fujitsu.com>
> >>>
> >>> Hmm, that looks like a bug. Nice catch!
> >>>
> >>> Couldn't we just replace the rt6_get_route_info in rt6_route_rcv =
with a call
> >>> to rt6_get_dflt_router? Seems easier, already handles the ::/0 ca=
se and also
> >>> does preserve the check for the RTF_ROUTEINFO flag in rt6_add_rou=
te_info.
> >>
> >> Yeah, your idea is better. I will modify my patch.
> >=20
> > Stop, stop, stop, sorry that suggestion is plain wrong and stupid.
> >=20
>=20
> In my opinion, i think that is well. According to your suggestion, we=
 can=20
> call the rt6_get_dflt_router or rt6_get_route_info in different situa=
tion.
>=20
> if (rinfo->prefix_len =3D=3D 0)
> 	rt =3D rt6_get_dflt_router(gwaddr, dev);
> else
> 	rt =3D rt6_get_route_info(net, prefix, rinfo->prefix_len, gwaddr,
> 				dev->ifindex);

That's perfect.

Greetings,

  Hannes
