From: Duan Jiong <duanj.fnst@cn.fujitsu.com>
Subject: Re: [PATCH] ipv6: replace RTF_ROUTEINFO with RTF_ADDRCONF in  rt6_get_route_info()
Date: Thu, 07 Nov 2013 12:19:05 +0800
Message-ID: <527B14B9.7040305@cn.fujitsu.com>
References: <5279EF31.4040705@cn.fujitsu.com> <20131107015100.GF8144@order.stressinduktion.org> <527AF477.1060604@cn.fujitsu.com> <20131107024202.GH8144@order.stressinduktion.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: David Miller <davem@davemloft.net>, netdev@vger.kernel.org
To: hannes@stressinduktion.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from cn.fujitsu.com ([222.73.24.84]:7463 "EHLO song.cn.fujitsu.com"
	rhost-flags-OK-FAIL-OK-OK) by vger.kernel.org with ESMTP
	id S1750766Ab3KGEVJ convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 6 Nov 2013 23:21:09 -0500
In-Reply-To: <20131107024202.GH8144@order.stressinduktion.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

=E4=BA=8E 2013=E5=B9=B411=E6=9C=8807=E6=97=A5 10:42, Hannes Frederic So=
wa =E5=86=99=E9=81=93:
> On Thu, Nov 07, 2013 at 10:01:27AM +0800, Duan Jiong wrote:
>> =E4=BA=8E 2013=E5=B9=B411=E6=9C=8807=E6=97=A5 09:51, Hannes Frederic=
 Sowa =E5=86=99=E9=81=93:
>>> On Wed, Nov 06, 2013 at 03:26:41PM +0800, Duan Jiong wrote:
>>>>
>>>> As the rfc 4191 said, the Router Preference and Lifetime values in=
 a
>>>> ::/0 Route Information Option should override the preference and l=
ifetime
>>>> values in the Router Advertisement header. But when the kernel dea=
ls with
>>>> a ::/0 Route Information Option, the rt6_get_route_info() always r=
eturn
>>>> NULL, that means that overriding will not happen, because those de=
fault
>>>> routers were added without flag RTF_ROUTEINFO in rt6_add_dflt_rout=
er().
>>>>
>>>> In order to match those default routers, we can replace RTF_ROUTEI=
NFO=20
>>>> with RTF_ADDRCONF in rt6_get_route_info().
>>>>
>>>> Signed-off-by: Duan Jiong <duanj.fnst@cn.fujitsu.com>
>>>
>>> Hmm, that looks like a bug. Nice catch!
>>>
>>> Couldn't we just replace the rt6_get_route_info in rt6_route_rcv wi=
th a call
>>> to rt6_get_dflt_router? Seems easier, already handles the ::/0 case=
 and also
>>> does preserve the check for the RTF_ROUTEINFO flag in rt6_add_route=
_info.
>>
>> Yeah, your idea is better. I will modify my patch.
>=20
> Stop, stop, stop, sorry that suggestion is plain wrong and stupid.
>=20

In my opinion, i think that is well. According to your suggestion, we c=
an=20
call the rt6_get_dflt_router or rt6_get_route_info in different situati=
on.

if (rinfo->prefix_len =3D=3D 0)
	rt =3D rt6_get_dflt_router(gwaddr, dev);
else
	rt =3D rt6_get_route_info(net, prefix, rinfo->prefix_len, gwaddr,
				dev->ifindex);

How do you think of the change above?

Thanks,
  Duan

> But I still would like to see the check for RTF_ROUTEINFO happening
> in rt6_add_route_info. We should also rename the function if you only=
 query
> for RTF_ADDRCONF and not RTF_ROUTEINFO.
>=20
> Sorry,
>=20
>   Hannes
>=20
>=20
