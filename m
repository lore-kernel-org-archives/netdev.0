From: Peter P Waskiewicz Jr <peter.p.waskiewicz.jr@intel.com>
Subject: Re: [PATCH] irq: Add node_affinity CPU masks for smarter
 irqbalance hints
Date: Tue, 24 Nov 2009 00:39:32 -0800
Message-ID: <1259051972.2631.12.camel@ppwaskie-mobl2>
References: <20091123064630.7385.30498.stgit@ppwaskie-hc2.jf.intel.com>
	 <2674af740911222332i65c0d066h79bf2c1ca1d5e4f0@mail.gmail.com>
	 <1258968980.2697.9.camel@ppwaskie-mobl2>
	 <2674af740911232117l275e933yaca3f1b8c1207bce@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
	"arjan@linux.jf.intel.com" <arjan@linux.jf.intel.com>,
	"davem@davemloft.net" <davem@davemloft.net>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: Yong Zhang <yong.zhang0@gmail.com>
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S932260AbZKXIjX@vger.kernel.org>
In-Reply-To: <2674af740911232117l275e933yaca3f1b8c1207bce@mail.gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Mon, 2009-11-23 at 22:17 -0700, Yong Zhang wrote:
> [snip]
> >>
> >> 1) I think you should consider CONFIG_CPUMASK_OFFSTACK which will affect
> >>    node_affinity.
> >> 2) It seems like this patch can't work with SPARSE_IRQ.
> >
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
> My two suggestions are both about your adding node_affinity. Before you can
> use this element, you must initialise it firstly. You can refer how
> irq_desc::affinity
> is used in function alloc_desc_masks().
> include/linux/irq.h:
> static inline bool alloc_desc_masks(struct irq_desc *desc, int node,
> 							bool boot)
> {
> 	gfp_t gfp = GFP_ATOMIC;
> 
> 	if (boot)
> 		gfp = GFP_NOWAIT;
> 
> #ifdef CONFIG_CPUMASK_OFFSTACK
> 	if (!alloc_cpumask_var_node(&desc->affinity, gfp, node))
> 		return false;
> 
> #ifdef CONFIG_GENERIC_PENDING_IRQ
> 	if (!alloc_cpumask_var_node(&desc->pending_mask, gfp, node)) {
> 		free_cpumask_var(desc->affinity);
> 		return false;
> 	}
> #endif
> #endif
> 	return true;
> }
> 

Ah, ok.  I see what you were referring to now.  Let me respin the patch
and send a second version.

Thanks Yong,

-PJ Waskiewicz
