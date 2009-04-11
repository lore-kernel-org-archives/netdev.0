From: Stephen Hemminger <shemminger@vyatta.com>
Subject: Re: iptables very slow after commit
 784544739a25c30637397ace5489eeb6e15d7d49
Date: Sat, 11 Apr 2009 08:05:54 -0700
Message-ID: <20090411080554.67a17410@nehalam>
References: <Pine.LNX.4.64.0904101656190.2093@boston.corp.fedex.com>
	<20090410095246.4fdccb56@s6510>
	<20090410.182507.140306636.davem@davemloft.net>
	<alpine.LFD.2.00.0904101828490.4583@localhost.localdomain>
	<20090411041533.GB6822@linux.vnet.ibm.com>
	<20090411070854.GC11799@elte.hu>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: "Paul E. McKenney" <paulmck@linux.vnet.ibm.com>,
	Linus Torvalds <torvalds@linux-foundation.org>,
	David Miller <davem@davemloft.net>,
	Lai Jiangshan <laijs@cn.fujitsu.com>,
	jeff.chua.linux@gmail.com, dada1@cosmosbay.com, jengelh@medozas.de,
	kaber@trash.net, r000n@r000n.net,
	Linux Kernel Mailing List <linux-kernel@vger.kernel.org>,
	netfilter-devel@vger.kernel.org, netdev@vger.kernel.org
To: Ingo Molnar <mingo@elte.hu>
Return-path: <netfilter-devel-owner@vger.kernel.org>
In-Reply-To: <20090411070854.GC11799@elte.hu>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Sat, 11 Apr 2009 09:08:54 +0200
Ingo Molnar <mingo@elte.hu> wrote:

> 
> * Paul E. McKenney <paulmck@linux.vnet.ibm.com> wrote:
> 
> > 	I will nevertheless suggest the following egregious hack to
> > 	get a consistent sample of one counter for some other CPU:
> > 
> > 	a.	Disable interrupts
> > 	b.	Atomically exchange the bottom 32 bits of the
> > 		counter with the value zero.
> > 	c.	Atomically exchange the top 32 bits of the counter
> > 		with the value zero.
> > 	d.	Concatenate the values obtained in (b) and (c), which
> > 		is the snapshot value.
> 
> Note, i have recently implemented full atomic64_t support on 32-bit 
> x86, for the perfcounters code, based on the CMPXCHG8B instruction.
> 
> Which, while not the lightest of instructions, is still much better 
> than the sequence above.
> 
> So i think a better approach would be to also add a dumb generic 
> implementation for atomic64_t (using a global lock or so), and then 
> generic code could just assume that atomic64_t always exists.
> 
> It is far nicer - and faster as well - as the hack above, even on 
> 32-bit x86.
> 
> 	Ingo

The iptables counters are write mostly, read rarely so they don't
fit the seq counter or atomic use case. Also, it is important
to get a consistent snapshot of the whole set not just each
individual counter.
