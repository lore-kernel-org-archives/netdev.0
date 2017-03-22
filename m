From: Peter Zijlstra <peterz@infradead.org>
Subject: Re: [PATCH 07/17] net: convert sock.sk_refcnt from
 atomic_t to refcount_t
Date: Wed, 22 Mar 2017 13:11:00 +0100
Message-ID: <20170322121100.cjeqno4g3s5n2qtl@hirez.programming.kicks-ass.net>
References: <20170318164759.GA23837@gondor.apana.org.au>
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
Content-Type: text/plain; charset=us-ascii
Cc: Herbert Xu <herbert@gondor.apana.org.au>,
	Eric Dumazet <eric.dumazet@gmail.com>, Patrick McHardy <kaber@trash.net>,
	Network Development <netdev@vger.kernel.org>,
	bridge@lists.linux-foundation.org, LKML <linux-kernel@vger.kernel.org>,
	James Morris <jmorris@namei.org>, Hans Liljestrand <ishkamiel@gmail.com>,
	Alexey Kuznetsov <kuznet@ms2.inr.ac.ru>,
	Andrew Morton <akpm@linux-foundation.org>,
	David Miller <davem@davemloft.net>, "Reshetova,
	Elena" <elena.reshetova@intel.com>, David Windsor <dwindsor@gmail.com>
To: Kees Cook <keescook@chromium.org>
Return-path: <bridge-bounces@lists.linux-foundation.org>
Content-Disposition: inline
In-Reply-To: <CAGXu5jKPckDxKV8ShY=5VtGm62Qxr5-gO9JDa_C+UL_P84jxVw@mail.gmail.com>
List-Unsubscribe: <https://lists.linuxfoundation.org/mailman/options/bridge>,
	<mailto:bridge-request@lists.linux-foundation.org?subject=unsubscribe>
List-Archive: <http://lists.linuxfoundation.org/pipermail/bridge/>
List-Post: <mailto:bridge@lists.linux-foundation.org>
List-Help: <mailto:bridge-request@lists.linux-foundation.org?subject=help>
List-Subscribe: <https://lists.linuxfoundation.org/mailman/listinfo/bridge>,
	<mailto:bridge-request@lists.linux-foundation.org?subject=subscribe>
Sender: bridge-bounces@lists.linux-foundation.org
Errors-To: bridge-bounces@lists.linux-foundation.org
List-Id: netdev.vger.kernel.org

On Tue, Mar 21, 2017 at 04:51:13PM -0700, Kees Cook wrote:
> On Tue, Mar 21, 2017 at 2:23 PM, Eric Dumazet <eric.dumazet@gmail.com> wrote:

> > Unfortunately there is no good test simulating real-world workloads,
> > which are mostly using TCP flows.
> 
> Sure, but there has to be _something_ that can be used to test to
> measure the effects. Without a meaningful test, it's weird to reject a
> change for performance reasons.

This. How can you optimize if there's no way to actually measure
something?

> > Most synthetic tools you can find are not using epoll(), and very often
> > hit bottlenecks in other layers.
> >
> >
> > It looks like our suggestion to get kernel builds with atomic_inc()
> > being exactly an atomic_inc() is not even discussed or implemented.
> 
> So, FWIW, I originally tried to make this a CONFIG in the first couple
> passes at getting a refcount defense. I would be fine with this, but I
> was not able to convince Peter. :) However, things have evolved a lot
> since then, so perhaps there are things do be done here.

Well, the argument was that unless there's a benchmark that shows it
cares, its all premature optimization.

Similarly, you wanted this enabled at all times because hardening.
