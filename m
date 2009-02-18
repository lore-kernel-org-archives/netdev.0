From: Ingo Molnar <mingo@elte.hu>
Subject: Re: [patch] timers: add mod_timer_pending()
Date: Wed, 18 Feb 2009 20:24:58 +0100
Message-ID: <20090218192458.GG8889@elte.hu>
References: <20090218051906.174295181@vyatta.com> <20090218052747.437271195@vyatta.com> <20090218092041.GC3294@elte.hu> <499BDDFE.5010101@trash.net> <20090218120508.GB4100@elte.hu> <20090218170057.GA28825@redhat.com> <20090218182311.GC26802@elte.hu> <20090218185850.GA2494@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Patrick McHardy <kaber@trash.net>,
	Peter Zijlstra <a.p.zijlstra@chello.nl>,
	Stephen Hemminger <shemminger@vyatta.com>,
	David Miller <davem@davemloft.net>,
	Rick Jones <rick.jones2@hp.com>,
	Eric Dumazet <dada1@cosmosbay.com>, netdev@vger.kernel.org,
	netfilter-devel@vger.kernel.org, tglx@linutronix.de,
	Martin Josefsson <gandalf@wlug.westbo.se>
To: Oleg Nesterov <oleg@redhat.com>
Return-path: <netfilter-devel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <20090218185850.GA2494@redhat.com>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


* Oleg Nesterov <oleg@redhat.com> wrote:

> On 02/18, Ingo Molnar wrote:
> >
> > * Oleg Nesterov <oleg@redhat.com> wrote:
> >
> > > Unlike __mod_timer(..., bool pending_only), it preserves the CPU on
> > > which the timer is pending.
> > >
> > > Or, perhaps, we can modify __mod_timer() further,
> >
> > if then i'd put it into a separate commit.
> >
> > I think the auto-migration of all the mod_timer() variants is a
> > scalability feature: if for example a networking socket's main
> > user migrates to another CPU, then the timer 'follows' it - even
> > if the timer never actually expires (which is quite common for
> > high-speed high-reliability networking transports).
> 
> OK.
> 
> But sometimes it is better (or necessary) to prevent the 
> migration. Since you already are changed __mod_timer() it 
> would be ugly to add yet another helper. Perhaps we should 
> turn "bool pending_only" into "int flags" right now?
> 
> This is minor, and perhaps we will never need the 
> TIMER_DONT_MIGRATE flag. But if ever need, then we have to 
> audit all callers.

hm, dunno - such unused flags are generally frowned upon, 
especially if they influence the code flow in a dynamic way. In 
fact i tried to avoid this flag here too - but __mod_timer() is 
too small, the flag is used in the middle, and two separate 
helpers would have made the code look worse.

	Ingo
