From: Christoph Lameter <cl@linux.com>
Subject: Re: [PATCH net-next] net:  allocate skbs on local node
Date: Tue, 12 Oct 2010 07:50:27 -0500 (CDT)
Message-ID: <alpine.DEB.2.00.1010120745360.31832@router.home>
References: <1286838210.30423.128.camel@edumazet-laptop> <1286839363.30423.130.camel@edumazet-laptop> <1286859925.30423.184.camel@edumazet-laptop> <20101011230322.f0f6dd47.akpm@linux-foundation.org> <1286866699.30423.234.camel@edumazet-laptop>
 <20101012002435.f51f2c0e.akpm@linux-foundation.org> <1286869793.2732.24.camel@edumazet-laptop> <20101012005856.994bea6d.akpm@linux-foundation.org> <4CB441CB.2000708@cs.helsinki.fi>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: Andrew Morton <akpm@linux-foundation.org>,
	Eric Dumazet <eric.dumazet@gmail.com>,
	David Miller <davem@davemloft.net>,
	netdev <netdev@vger.kernel.org>,
	Michael Chan <mchan@broadcom.com>,
	Eilon Greenstein <eilong@broadcom.com>,
	Christoph Hellwig <hch@lst.de>,
	David Rientjes <rientjes@google.com>,
	LKML <linux-kernel@vger.kernel.org>,
	Nick Piggin <npiggin@kernel.dk>
To: Pekka Enberg <penberg@cs.helsinki.fi>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <4CB441CB.2000708@cs.helsinki.fi>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tue, 12 Oct 2010, Pekka Enberg wrote:

> There's little point in discussing the removal of SLAB as long as there are
> performance regressions for real workloads from people who are willing to
> share results and test patches. I'm optimistic that we'll be able to try
> removing SLAB some time next year unless something interesting pops up...

Hmmm. Given these effects I think we should be more cautious regarding the
unification work. May be the "unified allocator" should replace SLAB
instead and SLUB can stay unchanged? The unification patches go back to
the one lock per node SLAB thing because the queue maintenance overhead is
otherwise causing large regressions in hackbench because of lots of atomic
ops. The per node lock seem to be causing problems here in the network
stack,. Take the unified as a SLAB cleanup instead? Then at least we have
a large common code base and just differentiate through the locking
mechanism?
