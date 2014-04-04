From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] net: sched: dev_deactivate_many(): use msleep(1)
 instead of yield() to wait for outstanding qdisc_run callsb
Date: Fri, 04 Apr 2014 11:28:50 -0400 (EDT)
Message-ID: <20140404.112850.1541183418380443600.davem@davemloft.net>
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

> And the above loop in tcp_output() is a plain memory deadlock, you
> should not loop on allocations like that. If the allocation fails;
> propagate the error.

There is nothing to "propagate" it to.  We have no "event" that will
trigger so that we have a second chance to send the FIN out, it really
must go out before we progress any further at this stage.
