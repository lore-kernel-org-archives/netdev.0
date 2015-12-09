From: Thomas Graf <tgraf@suug.ch>
Subject: Re: rhashtable: Use __vmalloc with GFP_ATOMIC for table allocation
Date: Wed, 9 Dec 2015 03:36:32 +0100
Message-ID: <20151209023632.GD19097@pox.localdomain>
References: <20151207.142953.387889541116696974.davem@davemloft.net>
 <20151205070603.GB23255@gondor.apana.org.au>
 <20151209021826.GC19097@pox.localdomain>
 <20151209022454.GA24515@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: David Miller <davem@davemloft.net>, Phil Sutter <phil@nwl.cc>,
	Eric Dumazet <eric.dumazet@gmail.com>, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org, fengguang.wu@intel.com,
	wfg@linux.intel.com, lkp@01.org
To: Herbert Xu <herbert@gondor.apana.org.au>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <20151209022454.GA24515@gondor.apana.org.au>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 12/09/15 at 10:24am, Herbert Xu wrote:
> On Wed, Dec 09, 2015 at 03:18:26AM +0100, Thomas Graf wrote:
> > 
> > Assuming that we only encounter this scenario with very large
> > table sizes, it might be OK to assume that deferring the actual
> > resize via the worker thread while continuing to insert above
> > 100% utilization in atomic context is safe.
> 
> As test_rhashtable has demonstrated already this approach doesn't
> work.  There is nothing in the kernel that will ensure that the
> worker thread gets to run at all.

If we define work assuming that an insertion in atomic context
should never fail then yes.  I'm not sure you can guarantee that
with a segmented table either though. I agree though that the
insertion behaviour is much better defined.

My argument is that if we are in a situation in which a worker
thread is never invoked and we've grown 2x from the original
table size, do we still need entries to be inserted into the
table or can we fail?

Without knowing your exact implementation plans: introducing an
additional reference indirection for every lookup will have a
huge performance penalty as well.

Is your plan to only introduce the master table after an
allocation has failed?
