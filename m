From: Thomas Gleixner <tglx@linutronix.de>
Subject: Re: [PATCH v2] irq: Add node_affinity CPU masks for smarter irqbalance
 hints
Date: Tue, 24 Nov 2009 23:23:44 +0100 (CET)
Message-ID: <alpine.LFD.2.00.0911242317280.24119@localhost.localdomain>
References: <20091124093518.3909.16435.stgit@ppwaskie-hc2.jf.intel.com>  <alpine.LFD.2.00.0911241151360.24119@localhost.localdomain>  <20091124.095703.107687163.davem@davemloft.net>  <alpine.LFD.2.00.0911242252190.24119@localhost.localdomain>
 <1259100343.2631.78.camel@ppwaskie-mobl2>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: David Miller <davem@davemloft.net>,
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
	"arjan@linux.jf.intel.com" <arjan@linux.jf.intel.com>,
	"mingo@elte.hu" <mingo@elte.hu>,
	"yong.zhang0@gmail.com" <yong.zhang0@gmail.com>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: Peter P Waskiewicz Jr <peter.p.waskiewicz.jr@intel.com>
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S934274AbZKXWYI@vger.kernel.org>
In-Reply-To: <1259100343.2631.78.camel@ppwaskie-mobl2>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tue, 24 Nov 2009, Peter P Waskiewicz Jr wrote:
> On Tue, 2009-11-24 at 13:56 -0800, Thomas Gleixner wrote:
> > On Tue, 24 Nov 2009, David Miller wrote:
> > 
> > > From: Thomas Gleixner <tglx@linutronix.de>
> > > Date: Tue, 24 Nov 2009 12:07:35 +0100 (CET)
> > > 
> > > > And what does the kernel do with this information and why are we not
> > > > using the existing device/numa_node information ?
> > > 
> > > It's a different problem space Thomas.
> > > 
> > > If the device lives on NUMA node X, we still end up wanting to
> > > allocate memory resources (RX ring buffers) on other NUMA nodes on a
> > > per-queue basis.
> > > 
> > > Otherwise a network card's forwarding performance is limited by the
> > > memory bandwidth of a single NUMA node, and on a multiqueue cards we
> > > therefore fare much better by allocating each device RX queue's memory
> > > resources on a different NUMA node.
> > > 
> > > It is this NUMA usage that PJ is trying to export somehow to userspace
> > > so that irqbalanced and friends can choose the IRQ cpu masks more
> > > intelligently.
> > 
> > So you need a preferred irq mask information on a per IRQ basis and
> > that mask is not restricted to the CPUs of a single NUMA node, right ?
> > 
> Just to clarify, I need a preferred CPU mask on a per IRQ basis.  And
> yes, that mask may not be restricted to the CPUs of a single NUMA node.
> But in the normal case, the mask will be restricted to CPUs of a single
> node.

Right, but the normal case does not help much if we need to consider
the special case of multiple nodes affected which requires another
cpumask in irq_desc. That's what I really want to avoid.

I at least understand the exact problem you guys want to solve. Will
think more about it.

Thanks,

	tglx
