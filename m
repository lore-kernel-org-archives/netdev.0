From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH 07/17] net: convert sock.sk_refcnt from atomic_t to
 refcount_t
Date: Tue, 21 Mar 2017 19:03:19 -0700
Message-ID: <1490148199.16816.126.camel@edumazet-glaptop3.roam.corp.google.com>
References: <1489767196.28631.305.camel@edumazet-glaptop3.roam.corp.google.com>
         <20170318164759.GA23837@gondor.apana.org.au>
         <20170318.182121.439615057765380575.davem@davemloft.net>
         <20170320103937.lq7nfnutupr3gkn7@hirez.programming.kicks-ass.net>
         <20170320131629.GA26405@gondor.apana.org.au>
         <20170320132357.acygo3umw6fiwb4p@hirez.programming.kicks-ass.net>
         <20170320132713.GA26954@gondor.apana.org.au>
         <20170320134017.h3c2jrsnd4guuyu7@hirez.programming.kicks-ass.net>
         <CAGXu5j+HK6jXeA3EdJGMLK_7o04AiTwXmmjuKOmExz0g5rs=kw@mail.gmail.com>
         <1490131389.16816.123.camel@edumazet-glaptop3.roam.corp.google.com>
         <CAGXu5jKPckDxKV8ShY=5VtGm62Qxr5-gO9JDa_C+UL_P84jxVw@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Peter Zijlstra <peterz@infradead.org>,
        Herbert Xu <herbert@gondor.apana.org.au>,
        David Miller <davem@davemloft.net>,
        "Reshetova, Elena" <elena.reshetova@intel.com>,
        Network Development <netdev@vger.kernel.org>,
        bridge@lists.linux-foundation.org,
        LKML <linux-kernel@vger.kernel.org>,
        Alexey Kuznetsov <kuznet@ms2.inr.ac.ru>,
        James Morris <jmorris@namei.org>,
        Patrick McHardy <kaber@trash.net>,
        Stephen Hemminger <stephen@networkplumber.org>,
        Hans Liljestrand <ishkamiel@gmail.com>,
        David Windsor <dwindsor@gmail.com>,
        Andrew Morton <akpm@linux-foundation.org>
To: Kees Cook <keescook@chromium.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <CAGXu5jKPckDxKV8ShY=5VtGm62Qxr5-gO9JDa_C+UL_P84jxVw@mail.gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tue, 2017-03-21 at 16:51 -0700, Kees Cook wrote:

> Am I understanding you correctly that you'd want something like:
> 
> refcount.h:
> #ifdef UNPROTECTED_REFCOUNT
> #define refcount_inc(x)   atomic_inc(x)
> ...
> #else
> void refcount_inc(...
> ...
> #endif
> 
> some/net.c:
> #define UNPROTECTED_REFCOUNT
> #include <refcount.h>
> 
> or similar?

At first, it could be something simple like that yes.

Note that we might define two refcount_inc()  : One that does whole
tests, and refcount_inc_relaxed() that might translate to atomic_inc()
on non debug kernels.

Then later, maybe provide a dynamic infrastructure so that we can
dynamically force the full checks even for refcount_inc_relaxed() on say
1% of the hosts, to get better debug coverage ?
