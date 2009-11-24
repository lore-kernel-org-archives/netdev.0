From: Andi Kleen <andi@firstfloor.org>
Subject: Re: [PATCH] irq: Add node_affinity CPU masks for smarter irqbalance hints
Date: Tue, 24 Nov 2009 21:35:41 +0100
Message-ID: <87iqczwtia.fsf@basil.nowhere.org>
References: <20091124.093956.247147202.davem@davemloft.net>
	<1259085412.2631.48.camel@ppwaskie-mobl2> <4B0C2547.8030408@gmail.com>
	<20091124.105442.06273019.davem@davemloft.net>
	<4B0C2CCA.6030006@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: David Miller <davem@davemloft.net>,
	peter.p.waskiewicz.jr@intel.com, peterz@infradead.org,
	arjan@linux.intel.com, yong.zhang0@gmail.com,
	linux-kernel@vger.kernel.org, arjan@linux.jf.intel.com,
	netdev@vger.kernel.org
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from one.firstfloor.org ([213.235.205.2]:51737 "EHLO
	one.firstfloor.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757572AbZKXUfg (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 24 Nov 2009 15:35:36 -0500
In-Reply-To: <4B0C2CCA.6030006@gmail.com> (Eric Dumazet's message of "Tue, 24 Nov 2009 19:58:18 +0100")
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Eric Dumazet <eric.dumazet@gmail.com> writes:

> David Miller a =E9crit :
>> From: Eric Dumazet <eric.dumazet@gmail.com>
>> Date: Tue, 24 Nov 2009 19:26:15 +0100
>>=20
>>> It seems complex to me, maybe optimal thing would be to use a NUMA =
policy to
>>> spread vmalloc() allocations to all nodes to get a good bandwidth..=
=2E
>>=20
>> vmalloc() and sk_buff's don't currently mix and I really don't see u=
s
>> every allowing them to :-)
>
> I think Peter was referring to tx/rx rings buffers, not sk_buffs.
>
> They (ring buffers) are allocated with vmalloc() at driver init time.

They are typically allocated with dma_alloc_coherent(), which does
allocate a continuous area.  In theory you could do interleaving
with IOMMus, but just putting it on the same node as the device
is probably better.

-Andi
--=20
ak@linux.intel.com -- Speaking for myself only.
