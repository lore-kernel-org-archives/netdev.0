From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH net-next-2.6 1/2] net: Allow changing number of RX
 queues after device allocation
Date: Fri, 24 Sep 2010 04:48:25 +0200
Message-ID: <1285296505.2380.43.camel@edumazet-laptop>
References: <1285273118.7794.23.camel@achroite.uk.solarflarecom.com>
	 <1285273194.7794.24.camel@achroite.uk.solarflarecom.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: David Miller <davem@davemloft.net>, netdev@vger.kernel.org,
	linux-net-drivers@solarflare.com, Tom Herbert <therbert@google.com>
To: Ben Hutchings <bhutchings@solarflare.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-fx0-f46.google.com ([209.85.161.46]:59372 "EHLO
	mail-fx0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751844Ab0IXCse (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 23 Sep 2010 22:48:34 -0400
Received: by fxm3 with SMTP id 3so507834fxm.19
        for <netdev@vger.kernel.org>; Thu, 23 Sep 2010 19:48:32 -0700 (PDT)
In-Reply-To: <1285273194.7794.24.camel@achroite.uk.solarflarecom.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le jeudi 23 septembre 2010 =C3=A0 21:19 +0100, Ben Hutchings a =C3=A9cr=
it :
> For RPS, we create a kobject for each RX queue based on the number of
> queues passed to alloc_netdev_mq().  However, drivers generally do no=
t
> determine the numbers of hardware queues to use until much later, so
> this usually represents the maximum number the driver may use and not
> the actual number in use.
>=20
> For TX queues, drivers can update the actual number using
> netif_set_real_num_tx_queues().  Add a corresponding function for RX
> queues, netif_set_real_num_rx_queues().
>=20
> Signed-off-by: Ben Hutchings <bhutchings@solarflare.com>
> ---

Seems very good to me, except a minor style issue here :

All functions in this file use a single line.

> -static int rx_queue_register_kobjects(struct net_device *net)
> +int
> +net_rx_queue_update_kobjects(struct net_device *net, int old_num, in=
t new_num)

->

int net_rx_queue_update_kobjects(struct net_device *net, int old, int n=
ew)


Also, I dont understand why we need to restrict
netif_set_real_num_rx_queues() to lower the count.
This wastes memory.

Why dont we allocate dev->_rx once we know the real count, not in
alloc_netdev_mq() but in register_netdevice() ?



