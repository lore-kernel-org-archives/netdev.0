From: "Waskiewicz Jr, Peter P" <peter.p.waskiewicz.jr@intel.com>
Subject: Re: [PATCH] irq: Add node_affinity CPU masks for smarter irqbalance
 hints
Date: Mon, 23 Nov 2009 15:32:36 -0800 (Pacific Standard Time)
Message-ID: <Pine.WNT.4.64.0911231529240.10056@ppwaskie-MOBL2.amr.corp.intel.com>
References: <20091123064630.7385.30498.stgit@ppwaskie-hc2.jf.intel.com>
 <2674af740911222332i65c0d066h79bf2c1ca1d5e4f0@mail.gmail.com>
 <1258968980.2697.9.camel@ppwaskie-mobl2> <1258995923.4531.715.camel@laptop>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: "Waskiewicz Jr, Peter P" <peter.p.waskiewicz.jr@intel.com>,
	Yong Zhang <yong.zhang0@gmail.com>,
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
	"arjan@linux.jf.intel.com" <arjan@linux.jf.intel.com>,
	"davem@davemloft.net" <davem@davemloft.net>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: Peter Zijlstra <peterz@infradead.org>
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1757502AbZKWXcc@vger.kernel.org>
In-Reply-To: <1258995923.4531.715.camel@laptop>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Mon, 23 Nov 2009, Peter Zijlstra wrote:

> On Mon, 2009-11-23 at 01:36 -0800, Peter P Waskiewicz Jr wrote:
> 
> > This mechanism isn't going to be used by any internal kernel mechanism
> > for determining interrupt placement or operation.  It's purely something
> > that either a driver can modify, or external script (through /proc),
> > that irqbalance will make use of.  If irqbalance isn't running, or the
> > current version of irqbalance doesn't support reading node_affinity,
> > then it won't affect the system's operation.
> > 
> > If irqbalance does support it, it'll read whatever the supplied mask is,
> > and then will try and balance interrupts within that mask.  It will bail
> > if the mask is invalid, or won't apply to the running system, just like
> > how putting a bogus mask into smp_affinity is ignored.
> > 
> > If there's something I'm missing beyond this with the two suggestions
> > you've made (I looked into those two parameters and tried to draw
> > conclusions), please let me know.
> 
> I don't see the point in adding it, if the driver wants to set a node
> cpu mask it can already do that using the regular smp affinity settings.

Unfortunately, a driver can't.  The irq_set_affinity() function isn't 
exported.  I proposed a patch on netdev to export it, and then to tie down 
an interrupt using IRQF_NOBALANCING, so irqbalance won't touch it.  That 
was rejected, since the driver is enforcing policy of the interrupt 
balancing, not irqbalance.

I and Jesse Brandeburg had a meeting with Arjan about this.  What we came 
up with was this interface, so drivers can set what they'd like to see, if 
irqbalance decides to honor it.  That way interrupt affinity policies are 
set only by irqbalance, but this interface gives us a mechanism to hint to 
irqbalance what we'd like it to do.

Also, if you use the /proc interface to change smp_affinity on an 
interrupt without any of these changes, irqbalance will override it on its 
next poll interval.  This also is not desirable.

Cheers,
-PJ
