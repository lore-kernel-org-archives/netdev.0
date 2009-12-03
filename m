From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH v2] net: Introduce realloc_netdev_mq()
Date: Thu, 03 Dec 2009 16:17:43 +0100
Message-ID: <4B17D697.8000105@gmail.com>
References: <20091101132017.GA2598@ami.dom.local> <20091102.033533.08766686.davem@davemloft.net> <20091102123029.GA7790@ff.dom.local> <20091102.043907.236634594.davem@davemloft.net> <20091203143918.GA20526@ff.dom.local>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: David Miller <davem@davemloft.net>, mchan@broadcom.com,
	kaber@trash.net, netdev@vger.kernel.org
To: Jarek Poplawski <jarkao2@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from gw1.cosmosbay.com ([212.99.114.194]:54492 "EHLO
	gw1.cosmosbay.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756288AbZLCPRn (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 3 Dec 2009 10:17:43 -0500
In-Reply-To: <20091203143918.GA20526@ff.dom.local>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Jarek Poplawski a =E9crit :
> Take 2 (with forgotten headers, sorry).

Very nice, thanks !

> Here is a proposal of netdev api change. I hope Michael finds time
> to try if this can be really useful for drivers.
>=20
> Thanks,
> Jarek P.
> ---------------> (take 2)
>=20
> This patch separates allocation of TX subqueues from alloc_netdev_mq(=
)
> to realloc_netdev_mq() to allow for resizing like in this example:
>=20
> some_nic_probe()
> {
> 	...
> 	dev =3D alloc_etherdev_mq(sizeof(*bp), 1)
> 	...
> 	if (MSI-X_available && device_supports_MSI-X_and_multiqueue)
> 		realloc_netdev_mq(dev, TX_MAX_RINGS)
> 	register_netdev(dev)
> 	...
> }
>=20

Or the reverse :

ie, the device first allocate its max possible tx rings

dev =3D alloc_etherdev_mq(sizeof(*bp), 128)

then, later, try to reduce it, when knowing exact tx count.

if (realloc_netdev_mq(dev, real_queues))
	dev->real_num_tx_queues =3D real_queues;

In this case the memory error is not fatal.
