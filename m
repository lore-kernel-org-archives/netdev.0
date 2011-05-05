From: Shan Wei <shanwei@cn.fujitsu.com>
Subject: Re: [PATCH 2/2 net-next] net: drivers: set TSO/UFO offload option
 explicitly
Date: Thu, 05 May 2011 16:51:59 +0800
Message-ID: <4DC2652F.9080709@cn.fujitsu.com>
References: <4DBA4DF5.5020101@cn.fujitsu.com> <BANLkTikckKWTBY0udurXi09UhdqOUExk6A@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: David Miller <davem@davemloft.net>,
	netdev <netdev@vger.kernel.org>, rusty@rustcorp.com.au,
	mst@redhat.com, Eric Dumazet <eric.dumazet@gmail.com>,
	mirq-linux@rere.qmqm.pl, bhutchings@solarflare.com, dm@chelsio.com
To: =?UTF-8?B?TWljaGHFgiBNaXJvc8WCYXc=?= <mirqus@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from cn.fujitsu.com ([222.73.24.84]:59146 "EHLO song.cn.fujitsu.com"
	rhost-flags-OK-FAIL-OK-OK) by vger.kernel.org with ESMTP
	id S1753155Ab1EEIzv convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 5 May 2011 04:55:51 -0400
In-Reply-To: <BANLkTikckKWTBY0udurXi09UhdqOUExk6A@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Micha=C5=82 Miros=C5=82aw wrote, at 05/04/2011 08:36 PM:
> 2011/4/29 Shan Wei <shanwei@cn.fujitsu.com>:
>> The device drivers should not use NETIF_F_ALL_TSO mask to set hw_fea=
tures(or features),
>> but have to explicitly set offload option. Because, This would make =
drivers automatically
>> clain to support any new TSO feature an the moment of NETIF_F_ALL_TS=
O is expanded.
>>
>> Some code style tuning. Just compile test.
>>
>> Signed-off-by: Shan Wei <shanwei@cn.fujitsu.com>
>> ---
>>  drivers/net/loopback.c   |   18 ++++++++----------
>>  drivers/net/virtio_net.c |    9 ++++++---
>>  2 files changed, 14 insertions(+), 13 deletions(-)
>>
>> diff --git a/drivers/net/loopback.c b/drivers/net/loopback.c
>> index d70fb76..bfb6a4a 100644
>> --- a/drivers/net/loopback.c
>> +++ b/drivers/net/loopback.c
>> @@ -152,6 +152,9 @@ static const struct net_device_ops loopback_ops =
=3D {
>>        .ndo_get_stats64 =3D loopback_get_stats64,
>>  };
>>
>> +#define LOOPBACK_USER_FEATURES (NETIF_F_TSO | NETIF_F_TSO_ECN | \
>> +                               NETIF_F_TSO6 | NETIF_F_UFO)
>> +
>>  /*
>>  * The loopback device is special. There is only one instance
>>  * per network namespace.
>> @@ -165,16 +168,11 @@ static void loopback_setup(struct net_device *=
dev)
>>        dev->type               =3D ARPHRD_LOOPBACK;      /* 0x0001*/
>>        dev->flags              =3D IFF_LOOPBACK;
>>        dev->priv_flags        &=3D ~IFF_XMIT_DST_RELEASE;
>> -       dev->hw_features        =3D NETIF_F_ALL_TSO | NETIF_F_UFO;
>> -       dev->features           =3D NETIF_F_SG | NETIF_F_FRAGLIST
>> -               | NETIF_F_ALL_TSO
>> -               | NETIF_F_UFO
>> -               | NETIF_F_NO_CSUM
>> -               | NETIF_F_RXCSUM
>> -               | NETIF_F_HIGHDMA
>> -               | NETIF_F_LLTX
>> -               | NETIF_F_NETNS_LOCAL
>> -               | NETIF_F_VLAN_CHALLENGED;
>> +       dev->hw_features        =3D LOOPBACK_USER_FEATURES;
>> +       dev->features           =3D NETIF_F_SG | NETIF_F_FRAGLIST
>> +               | LOOPBACK_USER_FEATURES | NETIF_F_NO_CSUM | NETIF_F=
_RXCSUM
>> +               | NETIF_F_HIGHDMA | NETIF_F_LLTX
>> +               | NETIF_F_NETNS_LOCAL | NETIF_F_VLAN_CHALLENGED;
>>        dev->ethtool_ops        =3D &loopback_ethtool_ops;
>>        dev->header_ops         =3D &eth_header_ops;
>>        dev->netdev_ops         =3D &loopback_ops;
>=20
> You can add NETIF_F_HIGHDMA and NETIF_F_NO_CSUM to
> LOOPBACK_USER_FEATURES in one go. NETIF_F_RXCSUM could match
> NETIF_F_NO_CSUM state (this needs ndo_fix_features callback), but thi=
s
> won't have much real functional impact.

Do you mean that defining LOOPBACK_USER_FEATURES as:
#define LOOPBACK_USER_FEATURES (NETIF_F_TSO | NETIF_F_TSO_ECN | \
                               NETIF_F_TSO6 | NETIF_F_UFO | NETIF_F_HIG=
HDMA | NETIF_F_NO_CSUM)

Is it necessary to add NETIF_F_NO_CSUM to hw_features?
After that, user can change TX hw csum offload(NETIF_F_NO_CSUM is disab=
led). But, this is not surportted before.

--=20
Best Regards
-----
Shan Wei
