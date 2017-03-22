From: Peter Zijlstra <peterz@infradead.org>
Subject: Re: [PATCH 07/17] net: convert sock.sk_refcnt from
 atomic_t to refcount_t
Date: Wed, 22 Mar 2017 15:33:29 +0100
Message-ID: <20170322143329.ya5jnretfptf4iud@hirez.programming.kicks-ass.net>
References: <20170320131629.GA26405@gondor.apana.org.au>
	<20170320132357.acygo3umw6fiwb4p@hirez.programming.kicks-ass.net>
	<20170320132713.GA26954@gondor.apana.org.au>
	<20170320134017.h3c2jrsnd4guuyu7@hirez.programming.kicks-ass.net>
	<CAGXu5j+HK6jXeA3EdJGMLK_7o04AiTwXmmjuKOmExz0g5rs=kw@mail.gmail.com>
	<1490131389.16816.123.camel@edumazet-glaptop3.roam.corp.google.com>
	<CAGXu5jKPckDxKV8ShY=5VtGm62Qxr5-gO9JDa_C+UL_P84jxVw@mail.gmail.com>
	<1490148199.16816.126.camel@edumazet-glaptop3.roam.corp.google.com>
	<20170322122540.odnm4j3r4c4uf7wt@hirez.programming.kicks-ass.net>
	<1490188936.16816.143.camel@edumazet-glaptop3.roam.corp.google.com>
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
In-Reply-To: <1490188936.16816.143.camel@edumazet-glaptop3.roam.corp.google.com>
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

On Wed, Mar 22, 2017 at 06:22:16AM -0700, Eric Dumazet wrote:

> But admittedly we can replace all these by standard refcount_inc() and
> simply provide a CONFIG option to turn off the checks, and let brave
> people enable this option.

Still brings us back to lacking a real reason to provide that CONFIG
option. Not to mention that this CONFIG knob will kill the warnings for
everything, even the code that might not be as heavily audited as
network and which doesn't really care much about the performance of
refcount operations.


So I'm actually in favour of _nocheck variants, if we can show the need
for them. And I like your idea of being able to dynamically switch them
back to full debug as well.


But I would feel a whole lot better about the entire thing if we could
measure their impact. It would also give us good precedent to whack
other potential users of _nocheck over the head with -- show numbers.
