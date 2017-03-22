From: Peter Zijlstra <peterz@infradead.org>
Subject: Re: [PATCH 07/17] net: convert sock.sk_refcnt from
 atomic_t to refcount_t
Date: Wed, 22 Mar 2017 16:08:47 +0100
Message-ID: <20170322150847.rsvhkbft3bn35rim@hirez.programming.kicks-ass.net>
References: <20170320132713.GA26954@gondor.apana.org.au>
	<20170320134017.h3c2jrsnd4guuyu7@hirez.programming.kicks-ass.net>
	<CAGXu5j+HK6jXeA3EdJGMLK_7o04AiTwXmmjuKOmExz0g5rs=kw@mail.gmail.com>
	<1490131389.16816.123.camel@edumazet-glaptop3.roam.corp.google.com>
	<CAGXu5jKPckDxKV8ShY=5VtGm62Qxr5-gO9JDa_C+UL_P84jxVw@mail.gmail.com>
	<1490148199.16816.126.camel@edumazet-glaptop3.roam.corp.google.com>
	<20170322122540.odnm4j3r4c4uf7wt@hirez.programming.kicks-ass.net>
	<1490188936.16816.143.camel@edumazet-glaptop3.roam.corp.google.com>
	<20170322143329.ya5jnretfptf4iud@hirez.programming.kicks-ass.net>
	<1490194444.16816.154.camel@edumazet-glaptop3.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Kees Cook <keescook@chromium.org>, Patrick McHardy <kaber@trash.net>,
	Network Development <netdev@vger.kernel.org>,
	bridge@lists.linux-foundation.org, LKML <linux-kernel@vger.kernel.org>,
	James Morris <jmorris@namei.org>, Hans Liljestrand <ishkamiel@gmail.com>,
	Alexey Kuznetsov <kuznet@ms2.inr.ac.ru>,
	Andrew Morton <akpm@linux-foundation.org>,
	David Windsor <dwindsor@gmail.com>,
	David Miller <davem@davemloft.net>, "Reshetova,
	Elena" <elena.reshetova@intel.com>,
	Herbert Xu <herbert@gondor.apana.org.au>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <bridge-bounces@lists.linux-foundation.org>
Content-Disposition: inline
In-Reply-To: <1490194444.16816.154.camel@edumazet-glaptop3.roam.corp.google.com>
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

On Wed, Mar 22, 2017 at 07:54:04AM -0700, Eric Dumazet wrote:
> On Wed, 2017-03-22 at 15:33 +0100, Peter Zijlstra wrote:
> 
> > 
> > But I would feel a whole lot better about the entire thing if we could
> > measure their impact. It would also give us good precedent to whack
> > other potential users of _nocheck over the head with -- show numbers.
> 
> I wont be able to measure the impact on real workloads, our productions
> kernels are based on 4.3 at this moment.

Is there really no micro bench that exercises the relevant network
paths? Do you really fully rely on Google production workloads?

> I guess someone could code a lib/test_refcount.c launching X threads
> using either atomic_inc or refcount_inc() in a loop.
> 
> That would give a rough estimate of the refcount_t overhead among
> various platforms.

Its also a fairly meaningless number. It doesn't include any of the
other work the network path does.
