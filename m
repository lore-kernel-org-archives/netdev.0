From: Ingo Molnar <mingo@elte.hu>
Subject: Re: tip: origin tree build failure, [patch] fix isdn/gigaset build
 failure
Date: Mon, 19 Apr 2010 20:05:20 +0200
Message-ID: <20100419180520.GA9244@elte.hu>
References: <20100419.003857.260094283.davem@davemloft.net>
 <20100419172731.GA4358@elte.hu>
 <20100419.103304.35342954.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: tilman@imap.cc, torvalds@linux-foundation.org,
	akpm@linux-foundation.org, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <20100419.103304.35342954.davem@davemloft.net>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


* David Miller <davem@davemloft.net> wrote:

> From: Ingo Molnar <mingo@elte.hu>
> Date: Mon, 19 Apr 2010 19:27:31 +0200
> 
> > Introduced by commit b91ecb00 that got pushed out today. That change removed 
> > an implicit sched.h inclusion that came in via slab.h.
> > 
> > The patch below fixes it by adding the sched.h dependency.
> 
> Thanks Ingo, Linus please apply:
> 
> Acked-by: David S. Miller <davem@davemloft.net>

Note, i just found that my patch is not enough as we fail the build elsewhere as well:

drivers/isdn/gigaset/proc.c:52: error: 'TASK_UNINTERRUPTIBLE' undeclared (first use in this function)
drivers/isdn/gigaset/proc.c:52: error: (Each undeclared identifier is reported only once
drivers/isdn/gigaset/proc.c:52: error: for each function it appears in.)
drivers/isdn/gigaset/proc.c:52: error: implicit declaration of function 'schedule'
drivers/isdn/gigaset/interface.c:49: error: 'TASK_UNINTERRUPTIBLE' undeclared (first use in this function)
drivers/isdn/gigaset/interface.c:49: error: (Each undeclared identifier is reported only once
drivers/isdn/gigaset/interface.c:49: error: for each function it appears in.)
drivers/isdn/gigaset/interface.c:49: error: implicit declaration of function 'schedule'
drivers/isdn/gigaset/interface.c:83: error: 'TASK_UNINTERRUPTIBLE' undeclared (first use in this function)
drivers/isdn/gigaset/ev-layer.c:981: error: 'TASK_NORMAL' undeclared (first use in this function)
drivers/isdn/gigaset/ev-layer.c:981: error: (Each undeclared identifier is reported only once
drivers/isdn/gigaset/ev-layer.c:981: error: for each function it appears in.)
drivers/isdn/gigaset/ev-layer.c:1001: error: 'TASK_NORMAL' undeclared (first use in this function)
drivers/isdn/gigaset/ev-layer.c:1495: error: 'TASK_NORMAL' undeclared (first use in this function)

i'd suggest a revert of b91ecb00 instead.

	Ingo
