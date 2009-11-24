From: Peter P Waskiewicz Jr <peter.p.waskiewicz.jr@intel.com>
Subject: Re: [PATCH] irq: Add node_affinity CPU masks for smarter
 irqbalance hints
Date: Tue, 24 Nov 2009 00:59:16 -0800
Message-ID: <1259053156.2631.21.camel@ppwaskie-mobl2>
References: <20091123064630.7385.30498.stgit@ppwaskie-hc2.jf.intel.com>
	 <2674af740911222332i65c0d066h79bf2c1ca1d5e4f0@mail.gmail.com>
	 <1258968980.2697.9.camel@ppwaskie-mobl2> <1258995923.4531.715.camel@laptop>
	 <Pine.WNT.4.64.0911231529240.10056@ppwaskie-MOBL2.amr.corp.intel.com>
	 <1259051902.4531.1053.camel@laptop>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: Yong Zhang <yong.zhang0@gmail.com>,
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
	"arjan@linux.jf.intel.com" <arjan@linux.jf.intel.com>,
	"davem@davemloft.net" <davem@davemloft.net>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	Thomas Gleixner <tglx@linutronix.de>
To: Peter Zijlstra <peterz@infradead.org>
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S932375AbZKXI7J@vger.kernel.org>
In-Reply-To: <1259051902.4531.1053.camel@laptop>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tue, 2009-11-24 at 01:38 -0700, Peter Zijlstra wrote:
> On Mon, 2009-11-23 at 15:32 -0800, Waskiewicz Jr, Peter P wrote:
> 
> > Unfortunately, a driver can't.  The irq_set_affinity() function isn't 
> > exported.  I proposed a patch on netdev to export it, and then to tie down 
> > an interrupt using IRQF_NOBALANCING, so irqbalance won't touch it.  That 
> > was rejected, since the driver is enforcing policy of the interrupt 
> > balancing, not irqbalance.
> 
> Why would a patch touching the irq subsystem go to netdev?

The only change to the IRQ subsystem was:

EXPORT_SYMBOL(irq_set_affinity);

The majority of the changeset was for the ixgbe driver.

> What is wrong with exporting irq_set_affinity(), and wtf do you need
> IRQF_NOBALANCING for?
> 

Again, the pushback I received was with allowing anything other than
irqbalance to dictate interrupt affinity policy.

And if I set interrupt affinity from the driver or from /proc,
irqbalance will happily rebalance the interrupt elsewhere.  The
IRQF_NOBALANCING flag will prevent irqbalance from being able to move
the interrupt.

> > I and Jesse Brandeburg had a meeting with Arjan about this.  What we came 
> > up with was this interface, so drivers can set what they'd like to see, if 
> > irqbalance decides to honor it.  That way interrupt affinity policies are 
> > set only by irqbalance, but this interface gives us a mechanism to hint to 
> > irqbalance what we'd like it to do.
> 
> If all you want is to expose policy to userspace then you don't need any
> of this, simply expose the NICs home node through a sysfs device thingy
> (I was under the impression its already there somewhere, but I can't
> ever find anything in /sys).
> 
> No need what so ever to poke at the IRQ subsystem.

The point is we need something common that the kernel side (whether a
driver or /proc can modify) that irqbalance can use.

> > Also, if you use the /proc interface to change smp_affinity on an 
> > interrupt without any of these changes, irqbalance will override it on its 
> > next poll interval.  This also is not desirable.
> 
> This all sounds backwards.. we've got a perfectly functional interface
> for affinity -- which people object to being used for some reason. So
> you add another interface on top, and that is ok?
> 

But it's not functional.  If I set the affinity in smp_affinity, then
irqbalance will override it 10 seconds later.

> All the while not CC'ing the IRQ folks,.. brilliant approach.

If I knew who I should CC, I'd be happy to add them.  Can you provide
email addresses please?

Cheers,
-PJ Waskiewicz
