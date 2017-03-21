From: Kees Cook <keescook@chromium.org>
Subject: Re: [PATCH 07/17] net: convert sock.sk_refcnt from
	atomic_t to refcount_t
Date: Tue, 21 Mar 2017 13:49:00 -0700
Message-ID: <CAGXu5j+HK6jXeA3EdJGMLK_7o04AiTwXmmjuKOmExz0g5rs=kw@mail.gmail.com>
References: <1489767196.28631.305.camel@edumazet-glaptop3.roam.corp.google.com>
	<20170318164759.GA23837@gondor.apana.org.au>
	<20170318.182121.439615057765380575.davem@davemloft.net>
	<20170320103937.lq7nfnutupr3gkn7@hirez.programming.kicks-ass.net>
	<20170320131629.GA26405@gondor.apana.org.au>
	<20170320132357.acygo3umw6fiwb4p@hirez.programming.kicks-ass.net>
	<20170320132713.GA26954@gondor.apana.org.au>
	<20170320134017.h3c2jrsnd4guuyu7@hirez.programming.kicks-ass.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Herbert Xu <herbert@gondor.apana.org.au>,
	Eric Dumazet <eric.dumazet@gmail.com>, Patrick McHardy <kaber@trash.net>,
	Network Development <netdev@vger.kernel.org>,
	bridge@lists.linux-foundation.org, LKML <linux-kernel@vger.kernel.org>,
	James Morris <jmorris@namei.org>, Hans Liljestrand <ishkamiel@gmail.com>,
	Alexey Kuznetsov <kuznet@ms2.inr.ac.ru>,
	Andrew Morton <akpm@linux-foundation.org>,
	David Miller <davem@davemloft.net>, "Reshetova,
	Elena" <elena.reshetova@intel.com>, David Windsor <dwindsor@gmail.com>
To: Peter Zijlstra <peterz@infradead.org>
Return-path: <bridge-bounces@lists.linux-foundation.org>
In-Reply-To: <20170320134017.h3c2jrsnd4guuyu7@hirez.programming.kicks-ass.net>
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

On Mon, Mar 20, 2017 at 6:40 AM, Peter Zijlstra <peterz@infradead.org> wrote:
> On Mon, Mar 20, 2017 at 09:27:13PM +0800, Herbert Xu wrote:
>> On Mon, Mar 20, 2017 at 02:23:57PM +0100, Peter Zijlstra wrote:
>> >
>> > So what bench/setup do you want ran?
>>
>> You can start by counting how many cycles an atomic op takes
>> vs. how many cycles this new code takes.
>
> On what uarch?
>
> I think I tested hand coded asm version and it ended up about double the
> cycles for a cmpxchg loop vs the direct instruction on an IVB-EX (until
> the memory bus saturated, at which point they took the same). Newer
> parts will of course have different numbers,
>
> Can't we run some iperf on a 40gbe fiber loop or something? It would be
> very useful to have an actual workload we can run.

Yeah, this is exactly what I'd like to find as well. Just comparing
cycles between refcount implementations, while interesting, doesn't
show us real-world performance changes, which is what we need to
measure.

Is Eric's "20 concurrent 'netperf -t UDP_STREAM'" example (from
elsewhere in this email thread) real-world meaningful enough?

-Kees

-- 
Kees Cook
Pixel Security
