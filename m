From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH v2 00/46] Clean up RX copybreak and DMA handling
Date: Mon, 11 Jul 2011 02:24:03 -0700 (PDT)
Message-ID: <20110711.022403.532062888492669176.davem@davemloft.net>
References: <cover.1310339688.git.mirq-linux@rere.qmqm.pl>
	<20110710.235458.1549578255936886669.davem@davemloft.net>
	<20110711091649.GA6380@rere.qmqm.pl>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=euc-kr
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org
To: mirq-linux@rere.qmqm.pl
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([198.137.202.13]:51085 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750870Ab1GKJYJ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 11 Jul 2011 05:24:09 -0400
In-Reply-To: <20110711091649.GA6380@rere.qmqm.pl>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

=46rom: Micha=A9=A9 Miros=A9=A9aw <mirq-linux@rere.qmqm.pl>
Date: Mon, 11 Jul 2011 11:16:49 +0200

> Packet is indicated in queue N, theres no memory for new skb, so its
> dropped, and the buffer goes back to free list. In parallel, queue M
> (!=3D N) indicates new packet. Still, there's no memory for new skb s=
o
> its also dropped and its buffer is reused. The effect is that all
> packets are dropped, whatever queue they appear on.

Why would queue M (!=3D N) fail just because N did?  They may be
allocating out of different NUMA nodes, and thus succeed.

> The HOL blocking does not matter here, because there's only one head
> --- the system memory. If I misunderstood this point, please explain
> it further.

Multiqueue drivers are moving towards placing the queues on different
NUMA nodes, and in that scenerio one queue might succeed even if the
other fails.

Back to the hardware hanging issue, it's real.  Getting into a
situation where the RX ring lacks any buffers at all is the least
tested path for these chips.

Testing fate is a really bad idea, and this is why I always propose to
keep the hardware with RX buffers to use in all circumstances.
