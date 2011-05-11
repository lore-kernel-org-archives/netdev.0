From: =?ISO-8859-2?Q?Micha=B3_Miros=B3aw?= <mirqus@gmail.com>
Subject: Re: [PATCH net-next 2/2 V3] net: driver: use NETIF_F_GSO_SOFTWARE
 masks directly
Date: Wed, 11 May 2011 12:07:26 +0200
Message-ID: <BANLkTikCfj5=0UXH1hu4BfXcwoSnqRbVXg@mail.gmail.com>
References: <4DCA2BEB.4000308@cn.fujitsu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-2
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: David Miller <davem@davemloft.net>,
	netdev <netdev@vger.kernel.org>, rusty@rustcorp.com.au,
	"Michael S. Tsirkin" <mst@redhat.com>,
	Eric Dumazet <eric.dumazet@gmail.com>, krkumar2@in.ibm.com,
	Ben Hutchings <bhutchings@solarflare.com>
To: Shan Wei <shanwei@cn.fujitsu.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qw0-f46.google.com ([209.85.216.46]:54121 "EHLO
	mail-qw0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756602Ab1EKQ5i convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 11 May 2011 12:57:38 -0400
Received: by qwk3 with SMTP id 3so358105qwk.19
        for <netdev@vger.kernel.org>; Wed, 11 May 2011 09:57:38 -0700 (PDT)
In-Reply-To: <4DCA2BEB.4000308@cn.fujitsu.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

2011/5/11 Shan Wei <shanwei@cn.fujitsu.com>:
> For loopback device can support any offload, so directly using
> NETIF_F_GSO_SOFTWARE offload mask is enough safe.
> And as Micha=B3 Miros=B3aw suggested, add NETIF_F_HIGHDMA to hw_featu=
res.
>
>
> For virtio_net driver, safely using NETIF_F_GSO_SOFTWARE offload mask=
 for bit operation.
>
> Signed-off-by: Shan Wei <shanwei@cn.fujitsu.com>
> ---
> =A0drivers/net/loopback.c =A0 | =A0 16 +++++-----------
> =A0drivers/net/virtio_net.c | =A0 =A03 ++-
> =A02 files changed, 7 insertions(+), 12 deletions(-)
>
> diff --git a/drivers/net/loopback.c b/drivers/net/loopback.c
> index 4ce9e5f..e6cccec 100644
> --- a/drivers/net/loopback.c
> +++ b/drivers/net/loopback.c
> @@ -165,17 +165,11 @@ static void loopback_setup(struct net_device *d=
ev)
> =A0 =A0 =A0 =A0dev->type =A0 =A0 =A0 =A0 =A0 =A0 =A0 =3D ARPHRD_LOOPB=
ACK; =A0 =A0 =A0/* 0x0001*/
> =A0 =A0 =A0 =A0dev->flags =A0 =A0 =A0 =A0 =A0 =A0 =A0=3D IFF_LOOPBACK=
;
> =A0 =A0 =A0 =A0dev->priv_flags =A0 =A0 =A0 =A0&=3D ~IFF_XMIT_DST_RELE=
ASE;
> - =A0 =A0 =A0 dev->hw_features =A0 =A0 =A0 =A0=3D NETIF_F_ALL_TSO | N=
ETIF_F_UFO;
> - =A0 =A0 =A0 dev->features =A0 =A0 =A0 =A0 =A0 =3D NETIF_F_SG | NETI=
=46_F_FRAGLIST
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 | NETIF_F_ALL_TSO
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 | NETIF_F_UFO
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 | NETIF_F_NO_CSUM
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 | NETIF_F_RXCSUM
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 | NETIF_F_HIGHDMA
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 | NETIF_F_LLTX
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 | NETIF_F_NETNS_LOCAL
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 | NETIF_F_VLAN_CHALLENGED
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 | NETIF_F_LOOPBACK;
> + =A0 =A0 =A0 dev->hw_features =A0 =A0 =A0 =A0=3D NETIF_F_GSO_SOFTWAR=
E | NETIF_F_HIGHDMA;
> + =A0 =A0 =A0 dev->features =A0 =A0 =A0 =A0 =A0 =3D dev->hw_features =
| NETIF_F_SG
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 | NETIF_F_FRAGLIST | NETIF_F_NO_CSUM | =
NETIF_F_RXCSUM
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 | NETIF_F_LLTX | NETIF_F_NETNS_LOCAL
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 | NETIF_F_VLAN_CHALLENGED | NETIF_F_LOO=
PBACK;
> =A0 =A0 =A0 =A0dev->ethtool_ops =A0 =A0 =A0 =A0=3D &loopback_ethtool_=
ops;
> =A0 =A0 =A0 =A0dev->header_ops =A0 =A0 =A0 =A0 =3D &eth_header_ops;
> =A0 =A0 =A0 =A0dev->netdev_ops =A0 =A0 =A0 =A0 =3D &loopback_ops;
[...]

Looks ok. For loopback, more features are actually changeable - only
last 4 are really forced here.

Best Regards,
Micha=B3 Miros=B3aw
