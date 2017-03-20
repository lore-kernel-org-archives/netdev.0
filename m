From: Peter Zijlstra <peterz@infradead.org>
Subject: Re: [PATCH 07/17] net: convert sock.sk_refcnt from atomic_t to
 refcount_t
Date: Mon, 20 Mar 2017 14:40:17 +0100
Message-ID: <20170320134017.h3c2jrsnd4guuyu7@hirez.programming.kicks-ass.net>
References: <1489767196.28631.305.camel@edumazet-glaptop3.roam.corp.google.com>
 <20170318164759.GA23837@gondor.apana.org.au>
 <20170318.182121.439615057765380575.davem@davemloft.net>
 <20170320103937.lq7nfnutupr3gkn7@hirez.programming.kicks-ass.net>
 <20170320131629.GA26405@gondor.apana.org.au>
 <20170320132357.acygo3umw6fiwb4p@hirez.programming.kicks-ass.net>
 <20170320132713.GA26954@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: David Miller <davem@davemloft.net>, eric.dumazet@gmail.com,
        elena.reshetova@intel.com, keescook@chromium.org,
        netdev@vger.kernel.org, bridge@lists.linux-foundation.org,
        linux-kernel@vger.kernel.org, kuznet@ms2.inr.ac.ru,
        jmorris@namei.org, kaber@trash.net, stephen@networkplumber.org,
        ishkamiel@gmail.com, dwindsor@gmail.com, akpm@linux-foundation.org
To: Herbert Xu <herbert@gondor.apana.org.au>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <20170320132713.GA26954@gondor.apana.org.au>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Mon, Mar 20, 2017 at 09:27:13PM +0800, Herbert Xu wrote:
> On Mon, Mar 20, 2017 at 02:23:57PM +0100, Peter Zijlstra wrote:
> >
> > So what bench/setup do you want ran?
> 
> You can start by counting how many cycles an atomic op takes
> vs. how many cycles this new code takes.

On what uarch?

I think I tested hand coded asm version and it ended up about double the
cycles for a cmpxchg loop vs the direct instruction on an IVB-EX (until
the memory bus saturated, at which point they took the same). Newer
parts will of course have different numbers,

Can't we run some iperf on a 40gbe fiber loop or something? It would be
very useful to have an actual workload we can run.
