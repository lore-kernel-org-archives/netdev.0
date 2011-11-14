From: Simon Kirby <sim@hostway.ca>
Subject: Re: [3.1] Divide by zero in __tcp_select_window()
Date: Mon, 14 Nov 2011 12:44:38 -0800
Message-ID: <20111114204438.GC11668@hostway.ca>
References: <20111108205411.GA23642@hostway.ca> <1320787405.26025.10.camel@edumazet-laptop> <20111114.153608.2064552703690099046.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: eric.dumazet@gmail.com, tglx@linutronix.de, netdev@vger.kernel.org,
	a.p.zijlstra@chello.nl, linux-kernel@vger.kernel.org,
	davej@redhat.com, schwidefsky@de.ibm.com, mingo@elte.hu
To: David Miller <davem@davemloft.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <20111114.153608.2064552703690099046.davem@davemloft.net>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Mon, Nov 14, 2011 at 03:36:08PM -0500, David Miller wrote:

> From: Eric Dumazet <eric.dumazet@gmail.com>
> Date: Tue, 08 Nov 2011 22:23:25 +0100
> 
> > OK, it seems we let a timer running while we free the socket (same error
> > path than your previous bug report, because of the NULL route)
> > 
> > We arm this keepalive timer in tcp_create_openreq_child()
> > 
> > net/ipv4/tcp_minisocks.c:513
> > 	if (sock_flag(newsk, SOCK_KEEPOPEN))
> > 		inet_csk_reset_keepalive_timer(newsk,
> > 			keepalive_time_when(newtp));
> > 
> > I would try to add a call to tcp_clear_xmit_timers() as well
> > 
> > Please try following patch :
> 
> We've been waiting quite some time to get some testing validation on
> this patch, but I think it's correct.
> 
> Eric can you formally submit this?  Thanks!

Sorry, I'm still testing slowly, with the "crash into the new kernel"
method. :) I'll reboot the rest shortly, but so far no recurrences on
boxes running with this fix, and no other problems noted with it applied.

Simon-
