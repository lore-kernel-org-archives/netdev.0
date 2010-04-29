From: Peter P Waskiewicz Jr <peter.p.waskiewicz.jr@intel.com>
Subject: Re: [PATCH RFC: linux-next 1/2] irq: Add CPU mask affinity hint
 callback framework
Date: Thu, 29 Apr 2010 13:28:50 -0700
Message-ID: <1272572930.9614.3.camel@localhost>
References: <20100419045741.30276.23233.stgit@ppwaskie-hc2.jf.intel.com>
	 <alpine.LFD.2.00.1004271425140.2951@localhost.localdomain>
	 <Pine.WNT.4.64.1004270856560.320@PPWASKIE-MOBL2.amr.corp.intel.com>
	 <alpine.LFD.2.00.1004271809080.2951@localhost.localdomain>
	 <1272563946.9614.1.camel@localhost>
	 <alpine.LFD.2.00.1004292121310.2951@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: "davem@davemloft.net" <davem@davemloft.net>,
	"arjan@linux.jf.intel.com" <arjan@linux.jf.intel.com>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>
To: Thomas Gleixner <tglx@linutronix.de>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <alpine.LFD.2.00.1004292121310.2951@localhost.localdomain>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thu, 2010-04-29 at 12:48 -0700, Thomas Gleixner wrote:
> B1;2005;0cPeter,
> 
> On Thu, 29 Apr 2010, Peter P Waskiewicz Jr wrote:
> > On Wed, 2010-04-28 at 09:45 -0700, Thomas Gleixner wrote:
> > > So you need a reference to your device, so what about the following:
> > > 
> > > struct irq_affinity_hint;
> > > 
> > > struct irq_affinity_hint {
> > >        unsigned int (*callback)(unsigned int irq, struct irq_affinity_hint *hint,
> > > 				cpumask_var_t *mask);
> > > }
> > > 
> > > Now you embed that struct into your device private data structure and
> > > you get the reference to it back in the callback function. No extra
> > > kmalloc/kfree, less code.
> > 
> > Good idea!  I'll roll that into my new version.
> 
> Thinking more about it, I wonder whether you have a cpu_mask in your
> driver/device private data anyway. I bet you have :)

Well, at this point we don't, but nothing says we can't.

> So it should be sufficient to set a pointer to that cpu_mask in
> irq_desc and get rid of the callback completely.

So "register" would just assign the pointer, and "unregister" would make
sure to NULL the mask pointer out.  I like it.  It'll sure clean things
up too.

> Any access to desc->affinity_hint needs to be protected by desc->lock.
> For setting the pointer to a real mask resp. NULL that's fine. The
> copy which you need to do in the proc-read function is not going to
> introduce huge latencies either.

Right.

> Thanks,
> 
> 	tglx

Thanks for the additional inputs.  Patches coming soon.

-PJ
