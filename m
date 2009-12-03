From: Jarek Poplawski <jarkao2@gmail.com>
Subject: Re: [PATCH v2] net: Introduce realloc_netdev_mq()
Date: Thu, 3 Dec 2009 17:36:40 +0100
Message-ID: <20091203163640.GA2584@ami.dom.local>
References: <20091101132017.GA2598@ami.dom.local>
 <20091102.033533.08766686.davem@davemloft.net>
 <20091102123029.GA7790@ff.dom.local>
 <20091102.043907.236634594.davem@davemloft.net>
 <20091203143918.GA20526@ff.dom.local>
 <4B17D697.8000105@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: David Miller <davem@davemloft.net>, mchan@broadcom.com,
	kaber@trash.net, netdev@vger.kernel.org
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-bw0-f227.google.com ([209.85.218.227]:36088 "EHLO
	mail-bw0-f227.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751784AbZLCQg6 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 3 Dec 2009 11:36:58 -0500
Received: by bwz27 with SMTP id 27so1261539bwz.21
        for <netdev@vger.kernel.org>; Thu, 03 Dec 2009 08:37:03 -0800 (PST)
Content-Disposition: inline
In-Reply-To: <4B17D697.8000105@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Dec 03, 2009 at 04:17:43PM +0100, Eric Dumazet wrote:
> Jarek Poplawski a =E9crit :
> > Take 2 (with forgotten headers, sorry).
>=20
> Very nice, thanks !
>=20
> > Here is a proposal of netdev api change. I hope Michael finds time
> > to try if this can be really useful for drivers.
> >=20
> > Thanks,
> > Jarek P.
> > ---------------> (take 2)
> >=20
> > This patch separates allocation of TX subqueues from alloc_netdev_m=
q()
> > to realloc_netdev_mq() to allow for resizing like in this example:
> >=20
> > some_nic_probe()
> > {
> > 	...
> > 	dev =3D alloc_etherdev_mq(sizeof(*bp), 1)
> > 	...
> > 	if (MSI-X_available && device_supports_MSI-X_and_multiqueue)
> > 		realloc_netdev_mq(dev, TX_MAX_RINGS)
> > 	register_netdev(dev)
> > 	...
> > }
> >=20
>=20
> Or the reverse :
>=20
> ie, the device first allocate its max possible tx rings
>=20
> dev =3D alloc_etherdev_mq(sizeof(*bp), 128)
>=20
> then, later, try to reduce it, when knowing exact tx count.

Right, especially when we know it's a common config/capability for
a NIC.

>=20
> if (realloc_netdev_mq(dev, real_queues))
> 	dev->real_num_tx_queues =3D real_queues;
>=20
> In this case the memory error is not fatal.

Good point! We can consider doing this inside the function too?

Thanks,
Jarek P.
