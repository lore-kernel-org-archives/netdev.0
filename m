From: Peter Zijlstra <peterz@infradead.org>
Subject: Re: [PATCH] net: sched: dev_deactivate_many(): use msleep(1) instead
 of yield() to wait for outstanding qdisc_run callsb
Date: Mon, 7 Apr 2014 13:19:06 +0200
Message-ID: <20140407111906.GH11096@twins.programming.kicks-ass.net>
References: <20140402110743.GG27965@twins.programming.kicks-ass.net>
 <1396437459.3989.39.camel@edumazet-glaptop2.roam.corp.google.com>
 <20140404151942.GI10526@twins.programming.kicks-ass.net>
 <20140404.112628.1273328398538574058.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: eric.dumazet@gmail.com, tglx@linutronix.de, ben@decadent.org.uk,
	mkl@pengutronix.de, linux-rt-users@vger.kernel.org,
	linux-kernel@vger.kernel.org, netdev@vger.kernel.org,
	kernel@pengutronix.de
To: David Miller <davem@davemloft.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <20140404.112628.1273328398538574058.davem@davemloft.net>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Fri, Apr 04, 2014 at 11:26:28AM -0400, David Miller wrote:
> From: Peter Zijlstra <peterz@infradead.org>
> Date: Fri, 4 Apr 2014 17:19:42 +0200
> 
> > The proper way to fix the dev_deactivate_many() is to use wait_event(),
> > polling for that state is just daft. Afaict there is no reason the qdisc
> > code could not do a wakeup whenever that condition changes.
> 
> I actually looked into this, and it's going to add expensive checks
> to the fast paths of packet processing.
> 
> If it was so easy we'd be doing it that way already.

Fair enough; and I suppose this waiting side is 'rare' compared to the
packet processing side of things?

In that case you could add a comment with the msleep() and just leave it
at that I suppose.
