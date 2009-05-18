From: Ingo Molnar <mingo@elte.hu>
Subject: Re: [PATCH RFC] v5 expedited "big hammer" RCU grace periods
Date: Mon, 18 May 2009 17:42:41 +0200
Message-ID: <20090518154241.GA27047@elte.hu>
References: <20090517191141.GA25915@linux.vnet.ibm.com> <20090518075630.GA10687@elte.hu> <20090518151421.GB6768@linux.vnet.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: linux-kernel@vger.kernel.org, netdev@vger.kernel.org,
	netfilter-devel@vger.kernel.org, akpm@linux-foundation.org,
	torvalds@linux-foundation.org, davem@davemloft.net,
	dada1@cosmosbay.com, zbr@ioremap.net, jeff.chua.linux@gmail.com,
	paulus@samba.org, laijs@cn.fujitsu.com, jengelh@medozas.de,
	r000n@r000n.net, benh@kernel.crashing.org,
	mathieu.desnoyers@polymtl.ca
To: "Paul E. McKenney" <paulmck@linux.vnet.ibm.com>
Return-path: <netfilter-devel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <20090518151421.GB6768@linux.vnet.ibm.com>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


* Paul E. McKenney <paulmck@linux.vnet.ibm.com> wrote:

> > i might be missing something fundamental here, but why not just 
> > have per CPU helper threads, all on the same waitqueue, and wake 
> > them up via a single wake_up() call? That would remove the SMP 
> > cross call (wakeups do immediate cross-calls already).
> 
> My concern with this is that the cache misses accessing all the 
> processes on this single waitqueue would be serialized, slowing 
> things down. In contrast, the bitmask that smp_call_function() 
> traverses delivers on the order of a thousand CPUs' worth of bits 
> per cache miss.  I will give it a try, though.

At least if you go via the migration threads, you can queue up 
requests to them locally. But there's going to be cachemisses 
_anyway_, since you have to access them all from a single CPU, and 
then they have to fetch details about what to do, and then have to 
notify the originator about completion.

	Ingo
