From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [net-2.6 PATCH v2] net: zero kobject in rx_queue_release
Date: Wed, 17 Nov 2010 06:51:59 +0100
Message-ID: <1289973119.2732.104.camel@edumazet-laptop>
References: <20101117054253.8714.24548.stgit@jf-dev1-dcblab>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: davem@davemloft.net, therbert@google.com, netdev@vger.kernel.org
To: John Fastabend <john.r.fastabend@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wy0-f174.google.com ([74.125.82.174]:56533 "EHLO
	mail-wy0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750940Ab0KQFwF (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 17 Nov 2010 00:52:05 -0500
Received: by wyb28 with SMTP id 28so1606733wyb.19
        for <netdev@vger.kernel.org>; Tue, 16 Nov 2010 21:52:04 -0800 (PST)
In-Reply-To: <20101117054253.8714.24548.stgit@jf-dev1-dcblab>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le mardi 16 novembre 2010 =C3=A0 21:42 -0800, John Fastabend a =C3=A9cr=
it :
> netif_set_real_num_rx_queues() can decrement and increment
> the number of rx queues. For example ixgbe does this as
> features and offloads are toggled. Presumably this could
> also happen across down/up on most devices if the available
> resources changed (cpu offlined).
>=20
> The kobject needs to be zero'd in this case so that the
> state is not preserved across kobject_put()/kobject_init_and_add().
>=20
> This resolves the following error report.
>=20
> ixgbe 0000:03:00.0: eth2: NIC Link is Up 10 Gbps, Flow Control: RX/TX
> kobject (ffff880324b83210): tried to init an initialized object, some=
thing is seriously wrong.
> Pid: 1972, comm: lldpad Not tainted 2.6.37-rc18021qaz+ #169
> Call Trace:
>  [<ffffffff8121c940>] kobject_init+0x3a/0x83
>  [<ffffffff8121cf77>] kobject_init_and_add+0x23/0x57
>  [<ffffffff8107b800>] ? mark_lock+0x21/0x267
>  [<ffffffff813c6d11>] net_rx_queue_update_kobjects+0x63/0xc6
>  [<ffffffff813b5e0e>] netif_set_real_num_rx_queues+0x5f/0x78
>  [<ffffffffa0261d49>] ixgbe_set_num_queues+0x1c6/0x1ca [ixgbe]
>  [<ffffffffa0262509>] ixgbe_init_interrupt_scheme+0x1e/0x79c [ixgbe]
>  [<ffffffffa0274596>] ixgbe_dcbnl_set_state+0x167/0x189 [ixgbe]
>=20
> Signed-off-by: John Fastabend <john.r.fastabend@intel.com>
> ---

I am not sure why you resent it, anyway, I ack it

Acked-by: Eric Dumazet <eric.dumazet@gmail.com>

Thanks


