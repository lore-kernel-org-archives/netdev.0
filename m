From: Ingo Molnar <mingo@elte.hu>
Subject: Re: iptables very slow after commit
	784544739a25c30637397ace5489eeb6e15d7d49
Date: Sun, 12 Apr 2009 12:54:16 +0200
Message-ID: <20090412105416.GB25392@elte.hu>
References: <Pine.LNX.4.64.0904101656190.2093@boston.corp.fedex.com> <20090410095246.4fdccb56@s6510> <20090410.182507.140306636.davem@davemloft.net> <alpine.LFD.2.00.0904101828490.4583@localhost.localdomain> <20090411041533.GB6822@linux.vnet.ibm.com> <20090411070854.GC11799@elte.hu> <20090411174801.GG6822@linux.vnet.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Linus Torvalds <torvalds@linux-foundation.org>,
	David Miller <davem@davemloft.net>,
	Lai Jiangshan <laijs@cn.fujitsu.com>, shemminger@vyatta.com,
	jeff.chua.linux@gmail.com, dada1@cosmosbay.com, jengelh@medozas.de,
	kaber@trash.net, r000n@r000n.net,
	Linux Kernel Mailing List <linux-kernel@vger.kernel.org>,
	netfilter-devel@vger.kernel.org, netdev@vger.kernel.org,
	paulus@samba.org, benh@kernel.crashing.org
To: "Paul E. McKenney" <paulmck@linux.vnet.ibm.com>
Return-path: <netfilter-devel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <20090411174801.GG6822@linux.vnet.ibm.com>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


* Paul E. McKenney <paulmck@linux.vnet.ibm.com> wrote:

> On Sat, Apr 11, 2009 at 09:08:54AM +0200, Ingo Molnar wrote:
> > 
> > * Paul E. McKenney <paulmck@linux.vnet.ibm.com> wrote:
> > 
> > > 	I will nevertheless suggest the following egregious hack to
> > > 	get a consistent sample of one counter for some other CPU:
> > > 
> > > 	a.	Disable interrupts
> > > 	b.	Atomically exchange the bottom 32 bits of the
> > > 		counter with the value zero.
> > > 	c.	Atomically exchange the top 32 bits of the counter
> > > 		with the value zero.
> > > 	d.	Concatenate the values obtained in (b) and (c), which
> > > 		is the snapshot value.
> > 
> > Note, i have recently implemented full atomic64_t support on 32-bit 
> > x86, for the perfcounters code, based on the CMPXCHG8B instruction.
> > 
> > Which, while not the lightest of instructions, is still much better 
> > than the sequence above.
> > 
> > So i think a better approach would be to also add a dumb generic 
> > implementation for atomic64_t (using a global lock or so), and then 
> > generic code could just assume that atomic64_t always exists.
> > 
> > It is far nicer - and faster as well - as the hack above, even on 
> > 32-bit x86.
> 
> If the generic implementation is needed only on !SMP systems, that 
> could work.  The architectures I would be worried about include 
> powerpc and ia64, which I believe support 32-bit SMP builds.

ia64 would naturally support the CMPXCHG8B instructions.

Not sure about powerpc32. Having a lock for the library 
implementation is not _that_ much of a problem. We obviously dont 
want the design of Linux to be dictated by the weakest link of all 
platforms, right?

	Ingo
