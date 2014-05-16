From: Duan Jiong <duanj.fnst@cn.fujitsu.com>
Subject: Re: [PATCH net-next] ip_tunnel: don't add tunnel twice
Date: Fri, 16 May 2014 13:06:47 +0800
Message-ID: <53759CE7.8000207@cn.fujitsu.com>
References: <53744B76.3080101@cn.fujitsu.com> <20140515.231051.1178432224326720292.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: <kaber@trash.net>, <netdev@vger.kernel.org>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from cn.fujitsu.com ([59.151.112.132]:2328 "EHLO
	heian.cn.fujitsu.com" rhost-flags-OK-FAIL-OK-FAIL) by vger.kernel.org
	with ESMTP id S1752725AbaEPFJO convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 16 May 2014 01:09:14 -0400
In-Reply-To: <20140515.231051.1178432224326720292.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

=E4=BA=8E 2014=E5=B9=B405=E6=9C=8816=E6=97=A5 11:10, David Miller =E5=86=
=99=E9=81=93:
> From: Duan Jiong <duanj.fnst@cn.fujitsu.com>
> Date: Thu, 15 May 2014 13:07:02 +0800
>=20
>>
>> When using command "ip tunnel add" to add a tunnel, the tunnel will =
be added twice,
>> through ip_tunnel_create() and ip_tunnel_update().
>>
>> Because the second is unnecessary, so we can just break after adding=
 tunnel
>> through ip_tunnel_create().
>>
>> Signed-off-by: Duan Jiong <duanj.fnst@cn.fujitsu.com>
>=20
> ip_tunnel_update() seems to do some things tha ip_tunnel_create()
> does not.
>=20
> For example, setting dev->dev_addr[] and dev->broadcast[] from the
> ipv4 parms if appropriate.
>=20
> I think you need to rethink this change.

When registering tunnel link, function register_netdevice() will call=20
dev->netdev_ops->ndo_init, actually the virtual function ndo_init will
do some same things  the ip_tunnel_update() does, such as the=20
above you mentioned.

So i think you don't need to worry about that.

Thanks,
   Duan
> --
> To unsubscribe from this list: send the line "unsubscribe netdev" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
>=20
