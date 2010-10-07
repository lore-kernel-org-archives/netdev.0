From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH net-next-2.6] net: Fix rxq ref counting
Date: Thu, 07 Oct 2010 22:59:09 +0200
Message-ID: <1286485149.3745.93.camel@edumazet-laptop>
References: <alpine.DEB.1.00.1010071304240.4792@pokey.mtv.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: davem@davemloft.net, netdev@vger.kernel.org
To: Tom Herbert <therbert@google.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wy0-f174.google.com ([74.125.82.174]:53224 "EHLO
	mail-wy0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755907Ab0JGU7R (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 7 Oct 2010 16:59:17 -0400
Received: by mail-wy0-f174.google.com with SMTP id 28so511407wyb.19
        for <netdev@vger.kernel.org>; Thu, 07 Oct 2010 13:59:16 -0700 (PDT)
In-Reply-To: <alpine.DEB.1.00.1010071304240.4792@pokey.mtv.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le jeudi 07 octobre 2010 =C3=A0 13:09 -0700, Tom Herbert a =C3=A9crit :
> The rx->count reference is used to track reference counts to the
> number of rx-queue kobjects created for the device.  This patch
> eliminates initialization of the counter in netif_alloc_rx_queues
> and instead increments the counter each time a kobject is created.
> This is now symmetric with the decrement that is done when an object =
is
> released.
>=20
> Signed-off-by: Tom Herbert <therbert@google.com>
> ---
> diff --git a/net/core/dev.c b/net/core/dev.c
> index 7d14955..58b31d1 100644
> --- a/net/core/dev.c
> +++ b/net/core/dev.c
> @@ -5026,7 +5026,6 @@ static int netif_alloc_rx_queues(struct net_dev=
ice *dev)
>  			return -ENOMEM;
>  		}
>  		dev->_rx =3D rx;
> -		atomic_set(&rx->count, count);
> =20
>  		/*
>  		 * Set a pointer to first element in the array which holds the
> diff --git a/net/core/net-sysfs.c b/net/core/net-sysfs.c
> index fa81fd0..b143173 100644
> --- a/net/core/net-sysfs.c
> +++ b/net/core/net-sysfs.c
> @@ -726,6 +726,7 @@ static struct kobj_type rx_queue_ktype =3D {
>  static int rx_queue_add_kobject(struct net_device *net, int index)
>  {
>  	struct netdev_rx_queue *queue =3D net->_rx + index;
> +	struct netdev_rx_queue *first =3D queue->first;
>  	struct kobject *kobj =3D &queue->kobj;
>  	int error =3D 0;
> =20
> @@ -738,6 +739,7 @@ static int rx_queue_add_kobject(struct net_device=
 *net, int index)
>  	}
> =20
>  	kobject_uevent(kobj, KOBJ_ADD);
> +	atomic_inc(&first->count);
> =20
>  	return error;
>  }

Acked-by: Eric Dumazet <eric.dumazet@gmail.com>



