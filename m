From: Peter Zijlstra <peterz@infradead.org>
Subject: Re: [PATCH 07/17] net: convert sock.sk_refcnt from atomic_t to
 refcount_t
Date: Mon, 20 Mar 2017 15:59:38 +0100
Message-ID: <20170320145938.cmj5m33uxunladli@hirez.programming.kicks-ass.net>
References: <1489767196.28631.305.camel@edumazet-glaptop3.roam.corp.google.com>
 <20170318164759.GA23837@gondor.apana.org.au>
 <20170318.182121.439615057765380575.davem@davemloft.net>
 <20170320103937.lq7nfnutupr3gkn7@hirez.programming.kicks-ass.net>
 <20170320131629.GA26405@gondor.apana.org.au>
 <20170320132357.acygo3umw6fiwb4p@hirez.programming.kicks-ass.net>
 <20170320132713.GA26954@gondor.apana.org.au>
 <20170320134017.h3c2jrsnd4guuyu7@hirez.programming.kicks-ass.net>
 <1490021461.16816.52.camel@edumazet-glaptop3.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Herbert Xu <herbert@gondor.apana.org.au>,
        David Miller <davem@davemloft.net>, elena.reshetova@intel.com,
        keescook@chromium.org, netdev@vger.kernel.org,
        bridge@lists.linux-foundation.org, linux-kernel@vger.kernel.org,
        kuznet@ms2.inr.ac.ru, jmorris@namei.org, kaber@trash.net,
        stephen@networkplumber.org, ishkamiel@gmail.com,
        dwindsor@gmail.com, akpm@linux-foundation.org
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <1490021461.16816.52.camel@edumazet-glaptop3.roam.corp.google.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Mon, Mar 20, 2017 at 07:51:01AM -0700, Eric Dumazet wrote:
> PowerPC has no efficient atomic_inc() and this definitely shows on
> network intensive workloads involving concurrent cores/threads.

Correct, PPC LL/SC are dreadfully expensive.

> atomic_cmpxchg() on PowerPC is horribly more expensive because of the
> added two SYNC instructions.

Note that refcount_t uses atomic_cmpxchg_release() and
atomic_cmpxchg_relaxed() which avoid most of the painful barriers.
