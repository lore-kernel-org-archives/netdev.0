From: Pekka Enberg <penberg@kernel.org>
Subject: Re: [PATCH net-next] net:  allocate skbs on local node
Date: Wed, 13 Oct 2010 09:17:12 +0300
Message-ID: <4CB54EE8.4020707@kernel.org>
References: <1286838210.30423.128.camel@edumazet-laptop> <1286839363.30423.130.camel@edumazet-laptop> <1286859925.30423.184.camel@edumazet-laptop> <20101011230322.f0f6dd47.akpm@linux-foundation.org> <1286866699.30423.234.camel@edumazet-laptop> <20101012002435.f51f2c0e.akpm@linux-foundation.org> <1286869793.2732.24.camel@edumazet-laptop> <20101012005856.994bea6d.akpm@linux-foundation.org> <4CB441CB.2000708@cs.helsinki.fi> <alpine.DEB.2.00.1010120745360.31832@router.home> <alpine.DEB.2.00.1010121234380.10165@chino.kir.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Christoph Lameter <cl@linux.com>,
	Andrew Morton <akpm@linux-foundation.org>,
	Eric Dumazet <eric.dumazet@gmail.com>,
	David Miller <davem@davemloft.net>,
	netdev <netdev@vger.kernel.org>,
	Michael Chan <mchan@broadcom.com>,
	Eilon Greenstein <eilong@broadcom.com>,
	Christoph Hellwig <hch@lst.de>,
	LKML <linux-kernel@vger.kernel.org>,
	Nick Piggin <npiggin@kernel.dk>
To: David Rientjes <rientjes@google.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <alpine.DEB.2.00.1010121234380.10165@chino.kir.corp.google.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tue, 12 Oct 2010, Christoph Lameter wrote:
>> Hmmm. Given these effects I think we should be more cautious regarding the
>> unification work. May be the "unified allocator" should replace SLAB
>> instead and SLUB can stay unchanged?

On 10/12/10 10:43 PM, David Rientjes wrote:
> Linus has said that he refuses to merge another allocator until one is
> removed or replaced, so that would force the unificiation patches to go
> into slab instead if you want to leave slub untouched.

Yes, and quite frankly, I'm not interested in introducing a new one either.

On Tue, 12 Oct 2010, Christoph Lameter wrote:
>> The unification patches go back to
>> the one lock per node SLAB thing because the queue maintenance overhead is
>> otherwise causing large regressions in hackbench because of lots of atomic
>> ops. The per node lock seem to be causing problems here in the network
>> stack,.

On Tue, 12 Oct 2010, Christoph Lameter wrote:
>> Take the unified as a SLAB cleanup instead? Then at least we have
>> a large common code base and just differentiate through the locking
>> mechanism?

On 10/12/10 10:43 PM, David Rientjes wrote:
> Will you be adding the extensive slub debugging to slab then?  It would be
> a shame to lose it because one allocator is chosen over another for
> performance reasons and then we need to recompile to debug issues as they
> arise.

I think Christoph is saying that we'd remove SLAB and make the unified 
allocator the new SLAB while keeping SLUB in place. In any case, yes, 
the debugging support in SLUB is something that we want to keep.

			Pekka
