From: Benjamin Herrenschmidt <benh@kernel.crashing.org>
Subject: Re: [PATCH 2/4] arch: Add lightweight memory barriers fast_rmb()
 and fast_wmb()
Date: Wed, 19 Nov 2014 08:07:53 +1100
Message-ID: <1416344873.5704.12.camel@kernel.crashing.org>
References: <20141117171005.22333.96544.stgit@ahduyck-server>
	 <20141117171812.22333.90395.stgit@ahduyck-server>
	 <1416254687.18381.3.camel@kernel.crashing.org> <546A5968.1090201@gmail.com>
	 <1416271167.18381.16.camel@kernel.crashing.org>
	 <546AB959.1020602@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Alexander Duyck <alexander.duyck@gmail.com>,
	linux-arch@vger.kernel.org, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org, mathieu.desnoyers@polymtl.ca,
	peterz@infradead.org, heiko.carstens@de.ibm.com, mingo@kernel.org,
	mikey@neuling.org, linux@arm.linux.org.uk,
	donald.c.skidmore@intel.com, matthew.vick@intel.com,
	geert@linux-m68k.org, jeffrey.t.kirsher@intel.com,
	romieu@fr.zoreil.com, paulmck@linux.vnet.ibm.com,
	nic_swsd@realtek.com, will.deacon@arm.com, michael@ellerman.id.au,
	tony.luck@intel.com, torvalds@linux-foundation.org,
	oleg@redhat.com, schwidefsky@de.ibm.com, fweisbec@gmail.com,
	davem@davemloft.net
To: Alexander Duyck <alexander.h.duyck@redhat.com>
Return-path: <linux-arch-owner@vger.kernel.org>
In-Reply-To: <546AB959.1020602@redhat.com>
Sender: linux-arch-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Mon, 2014-11-17 at 19:13 -0800, Alexander Duyck wrote:
> 
> ARM adds some funky things.  They have two different types of 
> primitives, a dmb() which is a data memory barrier, and a dsb() which is 
> a data synchronization barrier.  Then with each of those they have the 
> "domains" the barriers are effective within.
> 
> So for example on ARM a rmb() is dsb(sy) which means it is a system wide 
> synchronization barrier which stops execution on the CPU core until the 
> read completes.  

That's amazingly heavy handed ... I can see that being useful for MMIO,
we do something similar in our MMIO accessors by using a special variant
of trap instruction that never traps to make the core thing the load
value has been consumed. But that's typically only needed to guarantee
MMIO timings.

> However the smp_rmb() is a dmb(ish) which means it is 
> only a barrier as far as the inner shareable domain which I believe only 
> goes as far as the local shared cache hierarchy and only guarantees read 
> ordering without necessarily halting the CPU or stopping in-order 
> speculative reads.  So what a coherent_rmb() would be in my setup is 
> dmb(sy) which means the barrier runs all the way out to memory, and it 
> is allowed to speculative read as long as it does it in order.

Correct, which is thus the same as smp_rmb() ... which was my original
point, or am I missing something else ?

> If it is still unclear you might check out Will Deacon's talk on the 
> topic at https://www.youtube.com/watch?v=6ORn6_35kKo, at about 7:00 in 
> he explains the whole domains thing, and at 13:30 he explains dmb()/dsb().

Ok, I'll try to watch that when I get a chance.

Cheers,
Ben.
