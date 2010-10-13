From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH v2] xps-mp: Transmit Packet Steering for multiqueue
Date: Wed, 13 Oct 2010 07:48:13 +0200
Message-ID: <1286948893.2703.88.camel@edumazet-laptop>
References: <alpine.DEB.1.00.1010121705500.15786@pokey.mtv.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: davem@davemloft.net, netdev@vger.kernel.org
To: Tom Herbert <therbert@google.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ww0-f44.google.com ([74.125.82.44]:51682 "EHLO
	mail-ww0-f44.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751878Ab0JMFsg (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 13 Oct 2010 01:48:36 -0400
Received: by wwj40 with SMTP id 40so6016818wwj.1
        for <netdev@vger.kernel.org>; Tue, 12 Oct 2010 22:48:35 -0700 (PDT)
In-Reply-To: <alpine.DEB.1.00.1010121705500.15786@pokey.mtv.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le mardi 12 octobre 2010 =C3=A0 17:20 -0700, Tom Herbert a =C3=A9crit :
> +#ifdef CONFIG_RPS
> +       struct kobject          kobj;
> +       struct netdev_queue     *first;
> +       atomic_t                count;
> +       struct xps_map          *xps_maps;
> +#endif=20

Please put kobj at the end of this block, because its a big object (64
bytes)

+#ifdef CONFIG_RPS
> +       struct xps_map          *xps_maps;
> +       struct netdev_queue     *first;
> +       atomic_t                count;
> +       struct kobject          kobj;
> +#endif=20
>=20

This way, we only use one cache line to access hot path fields, instead
of two cache lines.



Tom, I believe you should split your patch in several parts, its really
too hard to review.


=46or example the netif_alloc_netdev_queues() stuff should be a patch o=
n
its own, as this stuff was already discussed on netdev some days ago, s=
o
that you could copy Ben and me on this one ;)

(Ie not allocating _tx in alloc_netdev_mq() but in register_netdevice()=
)



Its also a good thing to give diffstat output :

 include/linux/netdevice.h |   28 +++
 include/linux/skbuff.h    |    1=20
 net/core/dev.c            |  191 ++++++++++++++++------
 net/core/net-sysfs.c      |  305 +++++++++++++++++++++++++++++++++++-
 net/core/net-sysfs.h      |    3=20
 net/ipv4/tcp_output.c     |    4=20
 6 files changed, 471 insertions(+), 61 deletions(-)



