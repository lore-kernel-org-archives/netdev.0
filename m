From: Jesper Dangaard Brouer <hawk@diku.dk>
Subject: Re: [PATCH] netfilter: xtables: fix reentrancy
Date: Thu, 17 Mar 2011 12:36:56 +0100 (CET)
Message-ID: <Pine.LNX.4.64.1103171231220.21558@ask.diku.dk>
References: <1300302005.3202.23.camel@edumazet-laptop>
 <20110316.131648.15245216.davem@davemloft.net> <1300358140.3133.117.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII; format=flowed
Cc: David Miller <davem@davemloft.net>,
	Patrick McHardy <kaber@trash.net>,
	Netfilter Developers <netfilter-devel@vger.kernel.org>,
	netdev <netdev@vger.kernel.org>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netfilter-devel-owner@vger.kernel.org>
In-Reply-To: <1300358140.3133.117.camel@edumazet-laptop>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


Hi Eric,

How critial is this bug fix?

Should I apply this on my stable production kernels?
(I'm preparing a 2.6.38 kernel for prod usage, eventhougt its just been 
released, because I want your SFQ fixes...)


On Thu, 17 Mar 2011, Eric Dumazet wrote:

> While looking at it (and trying to only require preemption disabled
> instead of BH disabled), I believe stackptr management is not safe.
>
> I suggest following patch to make sure we restore *stackptr to origptr
> before enabling BH (or preemption later)
>
> Thanks
>
> [PATCH] netfilter: xtables: fix reentrancy
>
> commit f3c5c1bfd4308 (make ip_tables reentrant) introduced a race in
> handling the stackptr restore, at the end of ipt_do_table()
>
> We should do it before the call to xt_info_rdunlock_bh(), or we allow
> cpu preemption and another cpu overwrites stackptr of original one.
>
> A second fix is to change the underflow test to check the origptr value
> instead of 0 to detect underflow, or else we allow a jump from different
> hooks.
>
> Signed-off-by: Eric Dumazet <eric.dumazet@gmail.com>
[...]

Hilsen
   Jesper Brouer

--
-------------------------------------------------------------------
MSc. Master of Computer Science
Dept. of Computer Science, University of Copenhagen
Author of http://www.adsl-optimizer.dk
-------------------------------------------------------------------
