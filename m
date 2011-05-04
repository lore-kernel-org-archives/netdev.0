From: =?ISO-8859-2?Q?Micha=B3_Miros=B3aw?= <mirqus@gmail.com>
Subject: Re: [PATCH 2/2 net-next] net: drivers: set TSO/UFO offload option explicitly
Date: Wed, 4 May 2011 14:36:39 +0200
Message-ID: <BANLkTikckKWTBY0udurXi09UhdqOUExk6A@mail.gmail.com>
References: <4DBA4DF5.5020101@cn.fujitsu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: David Miller <davem@davemloft.net>,
	netdev <netdev@vger.kernel.org>, rusty@rustcorp.com.au,
	mst@redhat.com, Eric Dumazet <eric.dumazet@gmail.com>,
	mirq-linux@rere.qmqm.pl, bhutchings@solarflare.com, dm@chelsio.com
To: Shan Wei <shanwei@cn.fujitsu.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qw0-f46.google.com ([209.85.216.46]:54788 "EHLO
	mail-qw0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753547Ab1EDMhA convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 4 May 2011 08:37:00 -0400
Received: by qwk3 with SMTP id 3so651981qwk.19
        for <netdev@vger.kernel.org>; Wed, 04 May 2011 05:36:59 -0700 (PDT)
In-Reply-To: <4DBA4DF5.5020101@cn.fujitsu.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

2011/4/29 Shan Wei <shanwei@cn.fujitsu.com>:
> The device drivers should not use NETIF_F_ALL_TSO mask to set hw_feat=
ures(or features),
> but have to explicitly set offload option. Because, This would make d=
rivers automatically
> clain to support any new TSO feature an the moment of NETIF_F_ALL_TSO=
 is expanded.
>
> Some code style tuning. Just compile test.
>
> Signed-off-by: Shan Wei <shanwei@cn.fujitsu.com>
> ---
> =C2=A0drivers/net/loopback.c =C2=A0 | =C2=A0 18 ++++++++----------
> =C2=A0drivers/net/virtio_net.c | =C2=A0 =C2=A09 ++++++---
> =C2=A02 files changed, 14 insertions(+), 13 deletions(-)
>
> diff --git a/drivers/net/loopback.c b/drivers/net/loopback.c
> index d70fb76..bfb6a4a 100644
> --- a/drivers/net/loopback.c
> +++ b/drivers/net/loopback.c
> @@ -152,6 +152,9 @@ static const struct net_device_ops loopback_ops =3D=
 {
> =C2=A0 =C2=A0 =C2=A0 =C2=A0.ndo_get_stats64 =3D loopback_get_stats64,
> =C2=A0};
>
> +#define LOOPBACK_USER_FEATURES (NETIF_F_TSO | NETIF_F_TSO_ECN | \
> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0=
 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 NETIF_F_TSO6 | NETIF_F_UFO)
> +
> =C2=A0/*
> =C2=A0* The loopback device is special. There is only one instance
> =C2=A0* per network namespace.
> @@ -165,16 +168,11 @@ static void loopback_setup(struct net_device *d=
ev)
> =C2=A0 =C2=A0 =C2=A0 =C2=A0dev->type =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0=
 =C2=A0 =C2=A0 =3D ARPHRD_LOOPBACK; =C2=A0 =C2=A0 =C2=A0/* 0x0001*/
> =C2=A0 =C2=A0 =C2=A0 =C2=A0dev->flags =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=
=A0 =C2=A0 =C2=A0=3D IFF_LOOPBACK;
> =C2=A0 =C2=A0 =C2=A0 =C2=A0dev->priv_flags =C2=A0 =C2=A0 =C2=A0 =C2=A0=
&=3D ~IFF_XMIT_DST_RELEASE;
> - =C2=A0 =C2=A0 =C2=A0 dev->hw_features =C2=A0 =C2=A0 =C2=A0 =C2=A0=3D=
 NETIF_F_ALL_TSO | NETIF_F_UFO;
> - =C2=A0 =C2=A0 =C2=A0 dev->features =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0=
 =3D NETIF_F_SG | NETIF_F_FRAGLIST
> - =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 | NETIF_F_ALL_TSO
> - =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 | NETIF_F_UFO
> - =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 | NETIF_F_NO_CSUM
> - =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 | NETIF_F_RXCSUM
> - =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 | NETIF_F_HIGHDMA
> - =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 | NETIF_F_LLTX
> - =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 | NETIF_F_NETNS_LO=
CAL
> - =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 | NETIF_F_VLAN_CHA=
LLENGED;
> + =C2=A0 =C2=A0 =C2=A0 dev->hw_features =C2=A0 =C2=A0 =C2=A0 =C2=A0=3D=
 LOOPBACK_USER_FEATURES;
> + =C2=A0 =C2=A0 =C2=A0 dev->features =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0=
 =3D NETIF_F_SG | NETIF_F_FRAGLIST
> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 | LOOPBACK_USER_FE=
ATURES | NETIF_F_NO_CSUM | NETIF_F_RXCSUM
> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 | NETIF_F_HIGHDMA =
| NETIF_F_LLTX
> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 | NETIF_F_NETNS_LO=
CAL | NETIF_F_VLAN_CHALLENGED;
> =C2=A0 =C2=A0 =C2=A0 =C2=A0dev->ethtool_ops =C2=A0 =C2=A0 =C2=A0 =C2=A0=
=3D &loopback_ethtool_ops;
> =C2=A0 =C2=A0 =C2=A0 =C2=A0dev->header_ops =C2=A0 =C2=A0 =C2=A0 =C2=A0=
 =3D &eth_header_ops;
> =C2=A0 =C2=A0 =C2=A0 =C2=A0dev->netdev_ops =C2=A0 =C2=A0 =C2=A0 =C2=A0=
 =3D &loopback_ops;

You can add NETIF_F_HIGHDMA and NETIF_F_NO_CSUM to
LOOPBACK_USER_FEATURES in one go. NETIF_F_RXCSUM could match
NETIF_F_NO_CSUM state (this needs ndo_fix_features callback), but this
won't have much real functional impact.

Best Regards,
Micha=C5=82 Miros=C5=82aw
