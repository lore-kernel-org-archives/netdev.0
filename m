From: Peter Zijlstra <peterz@infradead.org>
Subject: Re: e1000_netpoll(): disable_irq() triggers might_sleep() on
 linux-next
Date: Wed, 29 Oct 2014 21:51:31 +0100
Message-ID: <20141029205131.GI10501@worktop.programming.kicks-ass.net>
References: <20141029155620.GA4886@kria>
 <20141029180734.GQ12706@worktop.programming.kicks-ass.net>
 <alpine.DEB.2.11.1410291918060.5308@nanos>
 <20141029193603.GS12706@worktop.programming.kicks-ass.net>
 <alpine.DEB.2.11.1410292046270.5308@nanos>
 <20141029195054.GH10501@worktop.programming.kicks-ass.net>
 <alpine.DEB.2.11.1410292053430.5308@nanos>
 <alpine.DEB.2.11.1410292119350.5308@nanos>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Sabrina Dubroca <sd@queasysnail.net>, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org, jeffrey.t.kirsher@intel.com
To: Thomas Gleixner <tglx@linutronix.de>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <alpine.DEB.2.11.1410292119350.5308@nanos>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wed, Oct 29, 2014 at 09:23:42PM +0100, Thomas Gleixner wrote:
> But at least it allows to mitigate the impact by making it conditional
> at a central point.
> 
> static inline void netpoll_lock(struct net_device *nd)
> {
> 	if (netpoll_active(nd))
> 		spin_lock(&nd->netpoll_lock);
> }

branch fail vs lock might be a toss on most machines, but if we're
hitting cold cachelines we loose big.

> and let the core code make sure that activation/deactivation of
> netpoll on a particular interface is serialized against the interrupt
> and netpoll calls.
> 
> Not sure if it's worth the trouble, but at least it allows to deal
> with it in the core instead of dealing with it on a per driver base.

Does multi-queue have one netdev per queue or does that need moar
logicz?
