From: Thomas Gleixner <tglx@linutronix.de>
Subject: Re: [PATCH RFC: linux-next 1/2] irq: Add CPU mask affinity hint
 callback framework
Date: Thu, 29 Apr 2010 21:48:24 +0200 (CEST)
Message-ID: <alpine.LFD.2.00.1004292121310.2951@localhost.localdomain>
References: <20100419045741.30276.23233.stgit@ppwaskie-hc2.jf.intel.com>  <alpine.LFD.2.00.1004271425140.2951@localhost.localdomain>  <Pine.WNT.4.64.1004270856560.320@PPWASKIE-MOBL2.amr.corp.intel.com>  <alpine.LFD.2.00.1004271809080.2951@localhost.localdomain>
 <1272563946.9614.1.camel@localhost>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: "davem@davemloft.net" <davem@davemloft.net>,
	"arjan@linux.jf.intel.com" <arjan@linux.jf.intel.com>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>
To: Peter P Waskiewicz Jr <peter.p.waskiewicz.jr@intel.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1272563946.9614.1.camel@localhost>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

B1;2005;0cPeter,

On Thu, 29 Apr 2010, Peter P Waskiewicz Jr wrote:
> On Wed, 2010-04-28 at 09:45 -0700, Thomas Gleixner wrote:
> > So you need a reference to your device, so what about the following:
> > 
> > struct irq_affinity_hint;
> > 
> > struct irq_affinity_hint {
> >        unsigned int (*callback)(unsigned int irq, struct irq_affinity_hint *hint,
> > 				cpumask_var_t *mask);
> > }
> > 
> > Now you embed that struct into your device private data structure and
> > you get the reference to it back in the callback function. No extra
> > kmalloc/kfree, less code.
> 
> Good idea!  I'll roll that into my new version.

Thinking more about it, I wonder whether you have a cpu_mask in your
driver/device private data anyway. I bet you have :)

So it should be sufficient to set a pointer to that cpu_mask in
irq_desc and get rid of the callback completely.

Any access to desc->affinity_hint needs to be protected by desc->lock.
For setting the pointer to a real mask resp. NULL that's fine. The
copy which you need to do in the proc-read function is not going to
introduce huge latencies either.

Thanks,

	tglx
