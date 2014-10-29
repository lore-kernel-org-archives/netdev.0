From: Thomas Gleixner <tglx@linutronix.de>
Subject: Re: e1000_netpoll(): disable_irq() triggers might_sleep() on
 linux-next
Date: Wed, 29 Oct 2014 22:03:20 +0100 (CET)
Message-ID: <alpine.DEB.2.11.1410292201530.5308@nanos>
References: <20141029155620.GA4886@kria> <20141029180734.GQ12706@worktop.programming.kicks-ass.net> <alpine.DEB.2.11.1410291918060.5308@nanos> <20141029193603.GS12706@worktop.programming.kicks-ass.net> <alpine.DEB.2.11.1410292046270.5308@nanos>
 <20141029195054.GH10501@worktop.programming.kicks-ass.net> <alpine.DEB.2.11.1410292053430.5308@nanos> <alpine.DEB.2.11.1410292119350.5308@nanos> <20141029205131.GI10501@worktop.programming.kicks-ass.net>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: Sabrina Dubroca <sd@queasysnail.net>, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org, jeffrey.t.kirsher@intel.com
To: Peter Zijlstra <peterz@infradead.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20141029205131.GI10501@worktop.programming.kicks-ass.net>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wed, 29 Oct 2014, Peter Zijlstra wrote:

> On Wed, Oct 29, 2014 at 09:23:42PM +0100, Thomas Gleixner wrote:
> > But at least it allows to mitigate the impact by making it conditional
> > at a central point.
> > 
> > static inline void netpoll_lock(struct net_device *nd)
> > {
> > 	if (netpoll_active(nd))
> > 		spin_lock(&nd->netpoll_lock);
> > }
> 
> branch fail vs lock might be a toss on most machines, but if we're
> hitting cold cachelines we loose big.

Well, if the net_device is not cache hot on irq entry you have lost
already. The extra branch/lock is not going to add much to that.
 
Thanks,

	tglx
