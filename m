From: Peter Zijlstra <peterz@infradead.org>
Subject: Re: e1000_netpoll(): disable_irq() triggers might_sleep() on
 linux-next
Date: Wed, 29 Oct 2014 20:50:54 +0100
Message-ID: <20141029195054.GH10501@worktop.programming.kicks-ass.net>
References: <20141029155620.GA4886@kria>
 <20141029180734.GQ12706@worktop.programming.kicks-ass.net>
 <alpine.DEB.2.11.1410291918060.5308@nanos>
 <20141029193603.GS12706@worktop.programming.kicks-ass.net>
 <alpine.DEB.2.11.1410292046270.5308@nanos>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Sabrina Dubroca <sd@queasysnail.net>, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org, jeffrey.t.kirsher@intel.com
To: Thomas Gleixner <tglx@linutronix.de>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <alpine.DEB.2.11.1410292046270.5308@nanos>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wed, Oct 29, 2014 at 08:49:03PM +0100, Thomas Gleixner wrote:
> On Wed, 29 Oct 2014, Peter Zijlstra wrote:
> 
> > On Wed, Oct 29, 2014 at 07:33:00PM +0100, Thomas Gleixner wrote:
> > > Yuck. No. You are just papering over the problem.
> > > 
> > > What happens if you add 'threadirqs' to the kernel command line? Or if
> > > the interrupt line is shared with a real threaded interrupt user?
> > > 
> > > The proper solution is to have a poll_lock for e1000 which serializes
> > > the hardware interrupt against netpoll instead of using
> > > disable/enable_irq().
> > > 
> > > In fact that's less expensive than the disable/enable_irq() dance and
> > > the chance of contention is pretty low. If done right it will be a
> > > NOOP for the CONFIG_NET_POLL_CONTROLLER=n case.
> > > 
> > 
> > OK a little something like so then I suppose.. But I suspect most all
> > the network drivers will need this and maybe more, disable_irq() is a
> > popular little thing and we 'just' changed semantics on them.
> 
> We changed that almost 4 years ago :) What we 'just' did was to add a
> prominent warning into the code.

You know that is the same right... they didn't know it was broken
therefore it wasn't :-), but now they need to go actually do stuff about
it, an entirely different proposition.
