From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH net-next-2.6 7/8] sfc: Set net_device::num_rx_queues
 once we know the correct value
Date: Wed, 22 Sep 2010 17:44:46 +0200
Message-ID: <1285170286.2639.428.camel@edumazet-laptop>
References: <1285009546.2282.126.camel@achroite.uk.solarflarecom.com>
	 <20100921.145703.189694076.davem@davemloft.net>
	 <1285106878.2697.96.camel@localhost>
	 <20100921.183834.70182767.davem@davemloft.net>
	 <1285169327.2279.3.camel@achroite.uk.solarflarecom.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: David Miller <davem@davemloft.net>, netdev@vger.kernel.org,
	linux-net-drivers@solarflare.com
To: Ben Hutchings <bhutchings@solarflare.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-fx0-f46.google.com ([209.85.161.46]:39934 "EHLO
	mail-fx0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751240Ab0IVPoz (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 22 Sep 2010 11:44:55 -0400
Received: by fxm12 with SMTP id 12so86786fxm.19
        for <netdev@vger.kernel.org>; Wed, 22 Sep 2010 08:44:54 -0700 (PDT)
In-Reply-To: <1285169327.2279.3.camel@achroite.uk.solarflarecom.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le mercredi 22 septembre 2010 =C3=A0 16:28 +0100, Ben Hutchings a =C3=A9=
crit :

>=20
> That still doesn't solve the original problem, since drivers generall=
y
> won't know how many RX queues they should (or can) create until some
> time after calling alloc_netdev_mq().
>=20
> You know very well why we distinguish real_num_tx_queues and
> num_tx_queues; what's so different about RX queues?

rx queues were added by Tom for RPS.
No function prototypes were changed to provide it as a new parameter.

What we need is to extend alloc_netdev_mq() to take a new rx_queue_coun=
t
parameter.

Then allow these txq/rxq parameters to be "unset for the moment", and
provide a new function to allocate / populate queues when driver knows
what to do, _after_ its alloc_netdev_mq() call.

Your one line patch is a work around, not a clean solution.



