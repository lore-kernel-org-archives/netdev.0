From: =?iso-8859-2?Q?Micha=B3_Miros=B3aw?= <mirq-linux@rere.qmqm.pl>
Subject: Re: [PATCH v2 00/46] Clean up RX copybreak and DMA handling
Date: Mon, 11 Jul 2011 11:47:23 +0200
Message-ID: <20110711094723.GC6380@rere.qmqm.pl>
References: <cover.1310339688.git.mirq-linux@rere.qmqm.pl>
 <20110710.235458.1549578255936886669.davem@davemloft.net>
 <20110711091649.GA6380@rere.qmqm.pl>
 <20110711.022403.532062888492669176.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-2
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from rere.qmqm.pl ([89.167.52.164]:37016 "EHLO rere.qmqm.pl"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751317Ab1GKJrY (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 11 Jul 2011 05:47:24 -0400
Content-Disposition: inline
In-Reply-To: <20110711.022403.532062888492669176.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Jul 11, 2011 at 02:24:03AM -0700, David Miller wrote:
> From: Micha=B3 Miros=B3aw <mirq-linux@rere.qmqm.pl>
> Date: Mon, 11 Jul 2011 11:16:49 +0200
> > Packet is indicated in queue N, theres no memory for new skb, so it=
s
> > dropped, and the buffer goes back to free list. In parallel, queue =
M
> > (!=3D N) indicates new packet. Still, there's no memory for new skb=
 so
> > its also dropped and its buffer is reused. The effect is that all
> > packets are dropped, whatever queue they appear on.
> Why would queue M (!=3D N) fail just because N did?  They may be
> allocating out of different NUMA nodes, and thus succeed.
>=20
> > The HOL blocking does not matter here, because there's only one hea=
d
> > --- the system memory. If I misunderstood this point, please explai=
n
> > it further.
> Multiqueue drivers are moving towards placing the queues on different
> NUMA nodes, and in that scenerio one queue might succeed even if the
> other fails.

I assumed that all queues get buffers from the same rx free ring. If
queues have their own free list, then we can treat them as separate NIC=
s
for this discussion. Queues on one NUMA node stall, others go on normal=
ly.

> Back to the hardware hanging issue, it's real.  Getting into a
> situation where the RX ring lacks any buffers at all is the least
> tested path for these chips.
>=20
> Testing fate is a really bad idea, and this is why I always propose t=
o
> keep the hardware with RX buffers to use in all circumstances.

Catch 22: The chips are not tested because they have always free buffer=
s,
they are provided with endless rx buffers because they are not being
tested. I'd rather test them well rather than workaround a phantom issu=
e.
Tripping on empty free rx buffer ring is still possible even with schem=
e
#1 (eg. with lots of NICs receiving heavy traffic) --- just harder to
recognise and debug (if it breaks at all) when it happens.

Best Regards,
Micha=B3 Miros=B3aw
