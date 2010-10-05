From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [net-next-2.6 PATCH] net: netif_set_real_num_rx_queues may cap
 num_rx_queues at init time
Date: Tue, 05 Oct 2010 07:35:26 +0200
Message-ID: <1286256926.2457.2.camel@edumazet-laptop>
References: <20101004220042.3471.92774.stgit@jf-dev1-dcblab>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: bhutchings@solarflare.com, netdev@vger.kernel.org,
	therbert@google.com
To: John Fastabend <john.r.fastabend@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ww0-f42.google.com ([74.125.82.42]:35464 "EHLO
	mail-ww0-f42.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753476Ab0JEFfl (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 5 Oct 2010 01:35:41 -0400
Received: by wwe15 with SMTP id 15so89621wwe.1
        for <netdev@vger.kernel.org>; Mon, 04 Oct 2010 22:35:40 -0700 (PDT)
In-Reply-To: <20101004220042.3471.92774.stgit@jf-dev1-dcblab>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le lundi 04 octobre 2010 =C3=A0 15:00 -0700, John Fastabend a =C3=A9cri=
t :
> The logic for netif_set_real_num_rx_queues is the following,
>=20
> netif_set_real_num_rx_queues(dev, rxq)
> {
> 	...
> 	if (dev->reg_state =3D=3D NETREG_REGISTERED) {
> 		...
> 	} else {
> 		dev->num_rx_queues =3D rxq;
> 	}
>=20
> 	dev->real_num_rx_queues =3D rxq;
> 	return 0;
> }
>=20
> Some drivers init path looks like the following,
>=20
> alloc_etherdev_mq(priv_sz, max_num_queues_ever);
> ...
> netif_set_real_num_rx_queues(dev, queues_to_use_now);
> ...
> register_netdev(dev);
> ...
>=20
> Because netif_set_real_num_rx_queues sets num_rx_queues if the
> reg state is not NETREG_REGISTERED we end up with the incorrect
> max number of rx queues. This patch proposes to remove the else
> clause above so this does not occur.  Also just reading the
> function set_real_num it seems a bit unexpected that num_rx_queues
> gets set.
>=20

You dont tell why its "incorrect".

Why should we keep num_rx_queues > real_num_rx_queues ?

It creates /sys files, and Qdisc stuff for nothing...



> CC: Ben Hutchings <bhutchings@solarflare.com>
>=20
> Signed-off-by: John Fastabend <john.r.fastabend@intel.com>
> ---
>=20
>  net/core/dev.c |    2 --
>  1 files changed, 0 insertions(+), 2 deletions(-)
>=20
> diff --git a/net/core/dev.c b/net/core/dev.c
> index a313bab..f78d996 100644
> --- a/net/core/dev.c
> +++ b/net/core/dev.c
> @@ -1592,8 +1592,6 @@ int netif_set_real_num_rx_queues(struct net_dev=
ice *dev, unsigned int rxq)
>  						  rxq);
>  		if (rc)
>  			return rc;
> -	} else {
> -		dev->num_rx_queues =3D rxq;
>  	}
> =20
>  	dev->real_num_rx_queues =3D rxq;
>=20
> --


