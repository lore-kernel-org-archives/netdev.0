From: Duan Jiong <duanj.fnst@cn.fujitsu.com>
Subject: Re: [PATCH] ipv6: replace RTF_ROUTEINFO with RTF_ADDRCONF in  rt6_get_route_info()
Date: Thu, 07 Nov 2013 10:01:27 +0800
Message-ID: <527AF477.1060604@cn.fujitsu.com>
References: <5279EF31.4040705@cn.fujitsu.com> <20131107015100.GF8144@order.stressinduktion.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: David Miller <davem@davemloft.net>, netdev@vger.kernel.org
To: hannes@stressinduktion.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from cn.fujitsu.com ([222.73.24.84]:5009 "EHLO song.cn.fujitsu.com"
	rhost-flags-OK-FAIL-OK-OK) by vger.kernel.org with ESMTP
	id S1753148Ab3KGCD3 convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 6 Nov 2013 21:03:29 -0500
In-Reply-To: <20131107015100.GF8144@order.stressinduktion.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

=E4=BA=8E 2013=E5=B9=B411=E6=9C=8807=E6=97=A5 09:51, Hannes Frederic So=
wa =E5=86=99=E9=81=93:
> On Wed, Nov 06, 2013 at 03:26:41PM +0800, Duan Jiong wrote:
>>
>> As the rfc 4191 said, the Router Preference and Lifetime values in a
>> ::/0 Route Information Option should override the preference and lif=
etime
>> values in the Router Advertisement header. But when the kernel deals=
 with
>> a ::/0 Route Information Option, the rt6_get_route_info() always ret=
urn
>> NULL, that means that overriding will not happen, because those defa=
ult
>> routers were added without flag RTF_ROUTEINFO in rt6_add_dflt_router=
().
>>
>> In order to match those default routers, we can replace RTF_ROUTEINF=
O=20
>> with RTF_ADDRCONF in rt6_get_route_info().
>>
>> Signed-off-by: Duan Jiong <duanj.fnst@cn.fujitsu.com>
>=20
> Hmm, that looks like a bug. Nice catch!
>=20
> Couldn't we just replace the rt6_get_route_info in rt6_route_rcv with=
 a call
> to rt6_get_dflt_router? Seems easier, already handles the ::/0 case a=
nd also
> does preserve the check for the RTF_ROUTEINFO flag in rt6_add_route_i=
nfo.

Yeah, your idea is better. I will modify my patch.

Thanks,
  Duan

>=20
> Greetings,
>=20
>   Hannes
>=20
> --
> To unsubscribe from this list: send the line "unsubscribe netdev" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
>=20
