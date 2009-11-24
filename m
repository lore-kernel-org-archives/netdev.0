From: Peter P Waskiewicz Jr <peter.p.waskiewicz.jr@intel.com>
Subject: Re: [PATCH v2] irq: Add node_affinity CPU masks for smarter
 irqbalance hints
Date: Tue, 24 Nov 2009 14:05:43 -0800
Message-ID: <1259100343.2631.78.camel@ppwaskie-mobl2>
References: <20091124093518.3909.16435.stgit@ppwaskie-hc2.jf.intel.com>
	 <alpine.LFD.2.00.0911241151360.24119@localhost.localdomain>
	 <20091124.095703.107687163.davem@davemloft.net>
	 <alpine.LFD.2.00.0911242252190.24119@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>,
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
	"arjan@linux.jf.intel.com" <arjan@linux.jf.intel.com>,
	"mingo@elte.hu" <mingo@elte.hu>,
	"yong.zhang0@gmail.com" <yong.zhang0@gmail.com>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: Thomas Gleixner <tglx@linutronix.de>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga02.intel.com ([134.134.136.20]:14603 "EHLO mga02.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1757216AbZKXWFc (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 24 Nov 2009 17:05:32 -0500
In-Reply-To: <alpine.LFD.2.00.0911242252190.24119@localhost.localdomain>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 2009-11-24 at 13:56 -0800, Thomas Gleixner wrote:
> On Tue, 24 Nov 2009, David Miller wrote:
> 
> > From: Thomas Gleixner <tglx@linutronix.de>
> > Date: Tue, 24 Nov 2009 12:07:35 +0100 (CET)
> > 
> > > And what does the kernel do with this information and why are we not
> > > using the existing device/numa_node information ?
> > 
> > It's a different problem space Thomas.
> > 
> > If the device lives on NUMA node X, we still end up wanting to
> > allocate memory resources (RX ring buffers) on other NUMA nodes on a
> > per-queue basis.
> > 
> > Otherwise a network card's forwarding performance is limited by the
> > memory bandwidth of a single NUMA node, and on a multiqueue cards we
> > therefore fare much better by allocating each device RX queue's memory
> > resources on a different NUMA node.
> > 
> > It is this NUMA usage that PJ is trying to export somehow to userspace
> > so that irqbalanced and friends can choose the IRQ cpu masks more
> > intelligently.
> 
> So you need a preferred irq mask information on a per IRQ basis and
> that mask is not restricted to the CPUs of a single NUMA node, right ?
> 

Just to clarify, I need a preferred CPU mask on a per IRQ basis.  And
yes, that mask may not be restricted to the CPUs of a single NUMA node.
But in the normal case, the mask will be restricted to CPUs of a single
node.

Cheers,
-PJ

