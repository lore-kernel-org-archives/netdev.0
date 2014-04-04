From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] net: sched: dev_deactivate_many(): use msleep(1)
 instead of yield() to wait for outstanding qdisc_run callsb
Date: Fri, 04 Apr 2014 11:26:28 -0400 (EDT)
Message-ID: <20140404.112628.1273328398538574058.davem@davemloft.net>
References: <20140402110743.GG27965@twins.programming.kicks-ass.net>
	<1396437459.3989.39.camel@edumazet-glaptop2.roam.corp.google.com>
	<20140404151942.GI10526@twins.programming.kicks-ass.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: eric.dumazet@gmail.com, tglx@linutronix.de, ben@decadent.org.uk,
	mkl@pengutronix.de, linux-rt-users@vger.kernel.org,
	linux-kernel@vger.kernel.org, netdev@vger.kernel.org,
	kernel@pengutronix.de
To: peterz@infradead.org
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20140404151942.GI10526@twins.programming.kicks-ass.net>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Peter Zijlstra <peterz@infradead.org>
Date: Fri, 4 Apr 2014 17:19:42 +0200

> The proper way to fix the dev_deactivate_many() is to use wait_event(),
> polling for that state is just daft. Afaict there is no reason the qdisc
> code could not do a wakeup whenever that condition changes.

I actually looked into this, and it's going to add expensive checks
to the fast paths of packet processing.

If it was so easy we'd be doing it that way already.
