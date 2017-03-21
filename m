From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH 07/17] net: convert sock.sk_refcnt from
 atomic_t to refcount_t
Date: Tue, 21 Mar 2017 14:23:09 -0700
Message-ID: <1490131389.16816.123.camel@edumazet-glaptop3.roam.corp.google.com>
References: <1489767196.28631.305.camel@edumazet-glaptop3.roam.corp.google.com>
	<20170318164759.GA23837@gondor.apana.org.au>
	<20170318.182121.439615057765380575.davem@davemloft.net>
	<20170320103937.lq7nfnutupr3gkn7@hirez.programming.kicks-ass.net>
	<20170320131629.GA26405@gondor.apana.org.au>
	<20170320132357.acygo3umw6fiwb4p@hirez.programming.kicks-ass.net>
	<20170320132713.GA26954@gondor.apana.org.au>
	<20170320134017.h3c2jrsnd4guuyu7@hirez.programming.kicks-ass.net>
	<CAGXu5j+HK6jXeA3EdJGMLK_7o04AiTwXmmjuKOmExz0g5rs=kw@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Herbert Xu <herbert@gondor.apana.org.au>, Patrick McHardy <kaber@trash.net>,
	Peter Zijlstra <peterz@infradead.org>,
	Network Development <netdev@vger.kernel.org>,
	bridge@lists.linux-foundation.org, LKML <linux-kernel@vger.kernel.org>,
	James Morris <jmorris@namei.org>, Hans Liljestrand <ishkamiel@gmail.com>,
	Alexey Kuznetsov <kuznet@ms2.inr.ac.ru>,
	Andrew Morton <akpm@linux-foundation.org>,
	David Miller <davem@davemloft.net>, "Reshetova,
	Elena" <elena.reshetova@intel.com>, David Windsor <dwindsor@gmail.com>
To: Kees Cook <keescook@chromium.org>
Return-path: <bridge-bounces@lists.linux-foundation.org>
In-Reply-To: <CAGXu5j+HK6jXeA3EdJGMLK_7o04AiTwXmmjuKOmExz0g5rs=kw@mail.gmail.com>
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

On Tue, 2017-03-21 at 13:49 -0700, Kees Cook wrote:

> Yeah, this is exactly what I'd like to find as well. Just comparing
> cycles between refcount implementations, while interesting, doesn't
> show us real-world performance changes, which is what we need to
> measure.
> 
> Is Eric's "20 concurrent 'netperf -t UDP_STREAM'" example (from
> elsewhere in this email thread) real-world meaningful enough?

Not at all ;)

This was targeting the specific change I had in mind for
ip_idents_reserve(), which is not used by TCP flows.

Unfortunately there is no good test simulating real-world workloads,
which are mostly using TCP flows.

Most synthetic tools you can find are not using epoll(), and very often
hit bottlenecks in other layers.


It looks like our suggestion to get kernel builds with atomic_inc()
being exactly an atomic_inc() is not even discussed or implemented.

Coding this would require less time than running a typical Google kernel
qualification (roughly one month, thousands of hosts..., days of SWE).
