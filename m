From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH] irq: Add node_affinity CPU masks for smarter irqbalance
 hints
Date: Tue, 24 Nov 2009 19:26:15 +0100
Message-ID: <4B0C2547.8030408@gmail.com>
References: <1258995923.4531.715.camel@laptop>	 <4B0B782A.4030901@linux.intel.com>	<1259051986.4531.1057.camel@laptop>	 <20091124.093956.247147202.davem@davemloft.net> <1259085412.2631.48.camel@ppwaskie-mobl2>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: David Miller <davem@davemloft.net>,
	"peterz@infradead.org" <peterz@infradead.org>,
	"arjan@linux.intel.com" <arjan@linux.intel.com>,
	"yong.zhang0@gmail.com" <yong.zhang0@gmail.com>,
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
	"arjan@linux.jf.intel.com" <arjan@linux.jf.intel.com>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: Peter P Waskiewicz Jr <peter.p.waskiewicz.jr@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from gw1.cosmosbay.com ([212.99.114.194]:58086 "EHLO
	gw1.cosmosbay.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S933743AbZKXS02 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 24 Nov 2009 13:26:28 -0500
In-Reply-To: <1259085412.2631.48.camel@ppwaskie-mobl2>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Peter P Waskiewicz Jr a =E9crit :
 That's the kind of thing PJ is trying to make available.
>=20
> Yes, that's exactly what I'm trying to do.  Even further, we want to
> allocate the ring SW struct itself and descriptor structures on other
> NUMA nodes, and make sure the interrupt lines up with those allocatio=
ns.
>=20

Say you allocate ring buffers on NUMA node of the CPU handling interrup=
t
on a particular queue.

If irqbalance or an admin changes /proc/irq/{number}/smp_affinities,
do you want to realloc ring buffer to another NUMA node ?

It seems complex to me, maybe optimal thing would be to use a NUMA poli=
cy to
spread vmalloc() allocations to all nodes to get a good bandwidth...

