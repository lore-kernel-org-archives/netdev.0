From: Thomas Graf <tgraf@suug.ch>
Subject: Re: rhashtable: Use __vmalloc with GFP_ATOMIC for table allocation
Date: Wed, 9 Dec 2015 03:18:26 +0100
Message-ID: <20151209021826.GC19097@pox.localdomain>
References: <20151207.142953.387889541116696974.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Phil Sutter <phil@nwl.cc>, Eric Dumazet <eric.dumazet@gmail.com>,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	fengguang.wu@intel.com, wfg@linux.intel.com, lkp@01.org
To: Herbert Xu <herbert@gondor.apana.org.au>,
	David Miller <davem@davemloft.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <20151207.142953.387889541116696974.davem@davemloft.net>
 <20151205070603.GB23255@gondor.apana.org.au>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


On 12/05/15 at 03:06pm, Herbert Xu wrote:
> Unless we can make __vmalloc work with BH disabled, I guess we'll
> have to go back to multi-level lookups unless someone has a better
> suggestion.

Assuming that we only encounter this scenario with very large
table sizes, it might be OK to assume that deferring the actual
resize via the worker thread while continuing to insert above
100% utilization in atomic context is safe.

On 12/07/15 at 02:29pm, David Miller wrote:
> You can't issue the cross-cpu TLB flushes from atomic contexts.
> It's the kernel page table updates that create the restriction.
