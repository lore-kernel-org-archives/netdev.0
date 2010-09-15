From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH] vlan: enable GRO if real_dev supports it
Date: Wed, 15 Sep 2010 19:08:40 +0200
Message-ID: <1284570520.2462.5.camel@edumazet-laptop>
References: <20100915015052.GA6602@mmm.home.ifup.org>
	 <20100914.213544.112598547.davem@davemloft.net>
	 <20100915163749.GA4191@mmm.home.ifup.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: David Miller <davem@davemloft.net>, jeffrey.t.kirsher@intel.com,
	jesse.brandeburg@intel.com, bruce.w.allan@intel.com,
	alexander.h.duyck@intel.com, peter.p.waskiewicz.jr@intel.com,
	john.ronciak@intel.com, donald.c.skidmore@intel.com,
	netdev@vger.kernel.org, e1000-devel@lists.sourceforge.net
To: Brandon Philips <bphilips@suse.de>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ww0-f42.google.com ([74.125.82.42]:34721 "EHLO
	mail-ww0-f42.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751727Ab0IORIu (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 15 Sep 2010 13:08:50 -0400
Received: by wwb18 with SMTP id 18so605441wwb.1
        for <netdev@vger.kernel.org>; Wed, 15 Sep 2010 10:08:46 -0700 (PDT)
In-Reply-To: <20100915163749.GA4191@mmm.home.ifup.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le mercredi 15 septembre 2010 =C3=A0 09:37 -0700, Brandon Philips a =C3=
=A9crit :
> Currently vlan devices don't have GRO by default as none of the Ether=
net
> drivers add NETIF_F_GRO to their vlan_features.
>=20
> As GRO is a software feature just propogate GRO from the real_dev in =
the
> vlan core. There is no need to have the drivers each add NETIF_F_GRO =
to
> their vlan_features.
>=20
> Signed-off-by: Brandon Philips <bphilips@suse.de>
> ---
>  net/8021q/vlan_dev.c |    1 +
>  1 files changed, 1 insertions(+), 0 deletions(-)
>=20
> diff --git a/net/8021q/vlan_dev.c b/net/8021q/vlan_dev.c
> index 3bccdd1..6fbc445 100644
> --- a/net/8021q/vlan_dev.c
> +++ b/net/8021q/vlan_dev.c
> @@ -735,6 +735,7 @@ static int vlan_dev_init(struct net_device *dev)
>  					  (1<<__LINK_STATE_DORMANT))) |
>  		      (1<<__LINK_STATE_PRESENT);
> =20
> +	dev->features |=3D real_dev->features & NETIF_F_GRO;
>  	dev->features |=3D real_dev->features & real_dev->vlan_features;
>  	dev->gso_max_size =3D real_dev->gso_max_size;
> =20

Hmm, this is only part of a generic solution.

If I enable gro with "ethtool -K eth0 gro on", should we propagate GRO
on vlan eth0.555 ?



