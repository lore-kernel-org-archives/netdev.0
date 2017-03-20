From: Peter Zijlstra <peterz@infradead.org>
Subject: Re: [PATCH 07/17] net: convert sock.sk_refcnt from atomic_t to
 refcount_t
Date: Mon, 20 Mar 2017 15:28:07 +0100
Message-ID: <20170320142807.mhu3xod2x2zzvego@hirez.programming.kicks-ass.net>
References: <1489767196.28631.305.camel@edumazet-glaptop3.roam.corp.google.com>
 <20170318164759.GA23837@gondor.apana.org.au>
 <20170318.182121.439615057765380575.davem@davemloft.net>
 <20170320103937.lq7nfnutupr3gkn7@hirez.programming.kicks-ass.net>
 <20170320131629.GA26405@gondor.apana.org.au>
 <063D6719AE5E284EB5DD2968C1650D6DCFFB5483@AcuExch.aculab.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: 'Herbert Xu' <herbert@gondor.apana.org.au>,
        David Miller <davem@davemloft.net>,
        "eric.dumazet@gmail.com" <eric.dumazet@gmail.com>,
        "elena.reshetova@intel.com" <elena.reshetova@intel.com>,
        "keescook@chromium.org" <keescook@chromium.org>,
        "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
        "bridge@lists.linux-foundation.org"
        <bridge@lists.linux-foundation.org>,
        "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
        "kuznet@ms2.inr.ac.ru" <kuznet@ms2.inr.ac.ru>,
        "jmorris@namei.org" <jmorris@namei.org>,
        "kaber@trash.net" <kaber@trash.net>,
        "stephen@networkplumber.org" <stephen@networkplumber.org>,
        "ishkamiel@gmail.com" <ishkamiel@gmail.com>,
        "dwindsor@gmail.com" <dwindsor@gmail.com>,
        "akpm@linux-foundation.org" <akpm@linux-foundation.org>
To: David Laight <David.Laight@ACULAB.COM>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <063D6719AE5E284EB5DD2968C1650D6DCFFB5483@AcuExch.aculab.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Mon, Mar 20, 2017 at 02:10:24PM +0000, David Laight wrote:
> On x86 the cpu flags from the 'lock inc/dec' could be used to reasonably
> cheaply detect errors - provided you actually generate a forwards branch.

Note that currently there is no arch specific implementation. We could
of course cure this.

But note that the thing you propose; using the overflow flag, can only
reasonably be done on PREEMPT=n kernels, otherwise we have an incredible
number of contexts that can nest.

Sure; getting all starts aligned to double overflow is incredibly rare,
but I don't want to be the one to have to debug that.
