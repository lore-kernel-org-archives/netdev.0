From: Peter Zijlstra <peterz@infradead.org>
Subject: Re: [PATCH] net: sched: dev_deactivate_many(): use msleep(1) instead
 of yield() to wait for outstanding qdisc_run callsb
Date: Mon, 7 Apr 2014 13:24:13 +0200
Message-ID: <20140407112413.GI11096@twins.programming.kicks-ass.net>
References: <20140402110743.GG27965@twins.programming.kicks-ass.net>
 <1396437459.3989.39.camel@edumazet-glaptop2.roam.corp.google.com>
 <20140404151942.GI10526@twins.programming.kicks-ass.net>
 <20140404.112850.1541183418380443600.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: eric.dumazet@gmail.com, tglx@linutronix.de, ben@decadent.org.uk,
	mkl@pengutronix.de, linux-rt-users@vger.kernel.org,
	linux-kernel@vger.kernel.org, netdev@vger.kernel.org,
	kernel@pengutronix.de
To: David Miller <davem@davemloft.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <20140404.112850.1541183418380443600.davem@davemloft.net>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Fri, Apr 04, 2014 at 11:28:50AM -0400, David Miller wrote:
> From: Peter Zijlstra <peterz@infradead.org>
> Date: Fri, 4 Apr 2014 17:19:42 +0200
> 
> > And the above loop in tcp_output() is a plain memory deadlock, you
> > should not loop on allocations like that. If the allocation fails;
> > propagate the error.
> 
> There is nothing to "propagate" it to.  We have no "event" that will
> trigger so that we have a second chance to send the FIN out, it really
> must go out before we progress any further at this stage.

>From what I remember of TCP/IP the FIN packet is used once per
connection; to terminate said connection. So if we pre-allocate one per
connection, at establishment time (where we can still easily fail) we
should be good and safe.

Now, I suppose there's valid arguments against this -- wasted memory
being one I suspect.

Also, seeing how this code has basically been this way forever and has
not caused (afaik) any actual memory deadlocks (they're hard anyway). We
might just get away with not touching it.

That said, at the very least we want a comment here stating that this is
a potential memory deadlock and why the alternatives aren't any good, so
that future readers (possibly us again) know this has been considered.
