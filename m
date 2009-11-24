From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH] irq: Add node_affinity CPU masks for smarter irqbalance
 hints
Date: Tue, 24 Nov 2009 20:01:25 +0100
Message-ID: <4B0C2D85.7020200@gmail.com>
References: <1258995923.4531.715.camel@laptop>	 <4B0B782A.4030901@linux.intel.com>	<1259051986.4531.1057.camel@laptop>	 <20091124.093956.247147202.davem@davemloft.net>	 <1259085412.2631.48.camel@ppwaskie-mobl2>  <4B0C2547.8030408@gmail.com> <1259087601.2631.56.camel@ppwaskie-mobl2>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: David Miller <davem@davemloft.net>,
	"peterz@infradead.org" <peterz@infradead.org>,
	"arjan@linux.intel.com" <arjan@linux.intel.com>,
	"yong.zhang0@gmail.com" <yong.zhang0@gmail.com>,
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
	"arjan@linux.jf.intel.com" <arjan@linux.jf.intel.com>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: Peter P Waskiewicz Jr <peter.p.waskiewicz.jr@intel.com>
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S933973AbZKXTBh@vger.kernel.org>
In-Reply-To: <1259087601.2631.56.camel@ppwaskie-mobl2>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Peter P Waskiewicz Jr a =C3=A9crit :

> That's exactly what we're doing in our 10GbE driver right now (isn't
> pushed upstream yet, still finalizing our testing).  We spread to all
> NUMA nodes in a semi-intelligent fashion when allocating our rings an=
d
> buffers.  The last piece is ensuring the interrupts tied to the vario=
us
> queues all route to the NUMA nodes those CPUs belong to.  irqbalance
> needs some kind of hint to make sure it does the right thing, which
> today it does not.

sk_buff allocations should be done on the node of the cpu handling rx i=
nterrupts.

=46or rings, I am ok for irqbalance and driver cooperation, in case adm=
in
 doesnt want to change the defaults.

>=20
> I don't see how this is complex though.  Driver loads, allocates acro=
ss
> the NUMA nodes for optimal throughput, then writes CPU masks for the
> NUMA nodes each interrupt belongs to.  irqbalance comes along and loo=
ks
> at the new mask "hint," and then balances that interrupt within that
> hinted mask.

So NUMA policy is given by the driver at load time ?

An admin might chose to direct all NIC trafic to a given node, because
its machine has mixed workload. 3 nodes out of 4 for database workload,
one node for network IO...

So if an admin changes smp_affinity, is your driver able to reconfigure=
 itself
and re-allocate all its rings to be on NUMA node chosen by admin ? This=
 is
what I qualify as complex.
