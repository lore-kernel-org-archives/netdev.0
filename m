From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH 07/17] net: convert sock.sk_refcnt from
 atomic_t to refcount_t
Date: Wed, 22 Mar 2017 06:22:16 -0700
Message-ID: <1490188936.16816.143.camel@edumazet-glaptop3.roam.corp.google.com>
References: <20170318.182121.439615057765380575.davem@davemloft.net>
	<20170320103937.lq7nfnutupr3gkn7@hirez.programming.kicks-ass.net>
	<20170320131629.GA26405@gondor.apana.org.au>
	<20170320132357.acygo3umw6fiwb4p@hirez.programming.kicks-ass.net>
	<20170320132713.GA26954@gondor.apana.org.au>
	<20170320134017.h3c2jrsnd4guuyu7@hirez.programming.kicks-ass.net>
	<CAGXu5j+HK6jXeA3EdJGMLK_7o04AiTwXmmjuKOmExz0g5rs=kw@mail.gmail.com>
	<1490131389.16816.123.camel@edumazet-glaptop3.roam.corp.google.com>
	<CAGXu5jKPckDxKV8ShY=5VtGm62Qxr5-gO9JDa_C+UL_P84jxVw@mail.gmail.com>
	<1490148199.16816.126.camel@edumazet-glaptop3.roam.corp.google.com>
	<20170322122540.odnm4j3r4c4uf7wt@hirez.programming.kicks-ass.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
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
To: Peter Zijlstra <peterz@infradead.org>
Return-path: <bridge-bounces@lists.linux-foundation.org>
In-Reply-To: <20170322122540.odnm4j3r4c4uf7wt@hirez.programming.kicks-ass.net>
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

On Wed, 2017-03-22 at 13:25 +0100, Peter Zijlstra wrote:
> On Tue, Mar 21, 2017 at 07:03:19PM -0700, Eric Dumazet wrote:
> 
> > Note that we might define two refcount_inc()  : One that does whole
> > tests, and refcount_inc_relaxed() that might translate to atomic_inc()
> > on non debug kernels.
> 
> So you'd want a duplicate interface, such that most code, which doesn't
> care about refcount performance much, can still have all the tests
> enabled.
> 
> But the code that cares about it (and preferably can prove it with
> numbers) can use the other.
> 
> I'm also somewhat hesitant to use _relaxed for this distinction, as it
> has a clear meaning in atomics, maybe _nocheck?
> 
> Also; what operations do you want _nocheck variants of, only
> refcount_inc() ?

I was mostly thinking of points where we were already checking the value
either before or after the atomic_inc(), using some lazy check (a la
WARN_ON(atomic_read(p) == 0) or something like that.

But admittedly we can replace all these by standard refcount_inc() and
simply provide a CONFIG option to turn off the checks, and let brave
people enable this option.


 
