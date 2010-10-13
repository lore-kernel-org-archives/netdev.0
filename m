From: Tom Herbert <therbert@google.com>
Subject: Re: [PATCH v2] xps-mp: Transmit Packet Steering for multiqueue
Date: Wed, 13 Oct 2010 08:41:16 -0700
Message-ID: <AANLkTi=KzdzaMJh0d5=v2+d3FL+OSafWyKEWOkw-dUQq@mail.gmail.com>
References: <alpine.DEB.1.00.1010121705500.15786@pokey.mtv.corp.google.com>
	<1286948893.2703.88.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: davem@davemloft.net, netdev@vger.kernel.org
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp-out.google.com ([74.125.121.35]:8656 "EHLO
	smtp-out.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750759Ab0JMPlU convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 13 Oct 2010 11:41:20 -0400
Received: from hpaq13.eem.corp.google.com (hpaq13.eem.corp.google.com [172.25.149.13])
	by smtp-out.google.com with ESMTP id o9DFfJP0024777
	for <netdev@vger.kernel.org>; Wed, 13 Oct 2010 08:41:19 -0700
Received: from pvf33 (pvf33.prod.google.com [10.241.210.97])
	by hpaq13.eem.corp.google.com with ESMTP id o9DFfHjh015497
	for <netdev@vger.kernel.org>; Wed, 13 Oct 2010 08:41:17 -0700
Received: by pvf33 with SMTP id 33so509908pvf.14
        for <netdev@vger.kernel.org>; Wed, 13 Oct 2010 08:41:16 -0700 (PDT)
In-Reply-To: <1286948893.2703.88.camel@edumazet-laptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Oct 12, 2010 at 10:48 PM, Eric Dumazet <eric.dumazet@gmail.com>=
 wrote:
>
> Le mardi 12 octobre 2010 =E0 17:20 -0700, Tom Herbert a =E9crit :
> > +#ifdef CONFIG_RPS
> > + =A0 =A0 =A0 struct kobject =A0 =A0 =A0 =A0 =A0kobj;
> > + =A0 =A0 =A0 struct netdev_queue =A0 =A0 *first;
> > + =A0 =A0 =A0 atomic_t =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0count;
> > + =A0 =A0 =A0 struct xps_map =A0 =A0 =A0 =A0 =A0*xps_maps;
> > +#endif
>
> Please put kobj at the end of this block, because its a big object (6=
4
> bytes)
>
Okay.

> +#ifdef CONFIG_RPS
> > + =A0 =A0 =A0 struct xps_map =A0 =A0 =A0 =A0 =A0*xps_maps;
> > + =A0 =A0 =A0 struct netdev_queue =A0 =A0 *first;
> > + =A0 =A0 =A0 atomic_t =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0count;
> > + =A0 =A0 =A0 struct kobject =A0 =A0 =A0 =A0 =A0kobj;
> > +#endif
> >
>
> This way, we only use one cache line to access hot path fields, inste=
ad
> of two cache lines.
>
Okay.

>
>
> Tom, I believe you should split your patch in several parts, its real=
ly
> too hard to review.
>
>
> For example the netif_alloc_netdev_queues() stuff should be a patch o=
n
> its own, as this stuff was already discussed on netdev some days ago,=
 so
> that you could copy Ben and me on this one ;)
>
Ahh, that was some discussion about TX queues in the thread about RX
queue allocation.  I seemed to have missed that part.

> (Ie not allocating _tx in alloc_netdev_mq() but in register_netdevice=
())
>
Sorry about that.  The good changes in rx queue motivated these
changes.  I'll extract the parts that move the TX queue allocation
into a separate patch.

Thanks for reviewing,
Tom

>
>
> Its also a good thing to give diffstat output :
>
> =A0include/linux/netdevice.h | =A0 28 +++
> =A0include/linux/skbuff.h =A0 =A0| =A0 =A01
> =A0net/core/dev.c =A0 =A0 =A0 =A0 =A0 =A0| =A0191 ++++++++++++++++---=
---
> =A0net/core/net-sysfs.c =A0 =A0 =A0| =A0305 +++++++++++++++++++++++++=
++++++++++-
> =A0net/core/net-sysfs.h =A0 =A0 =A0| =A0 =A03
> =A0net/ipv4/tcp_output.c =A0 =A0 | =A0 =A04
> =A06 files changed, 471 insertions(+), 61 deletions(-)
>
>
>
