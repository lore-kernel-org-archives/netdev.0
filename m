From: Joerg Roedel <joro@8bytes.org>
Subject: Re: [PATCH 07/10] x86: add checks for alloc/free_coherent code
Date: Sat, 22 Nov 2008 10:38:15 +0100
Message-ID: <20081122093815.GH29705@8bytes.org>
References: <1227284770-19215-1-git-send-email-joerg.roedel@amd.com> <1227284770-19215-8-git-send-email-joerg.roedel@amd.com> <20081122120902Y.fujita.tomonori@lab.ntt.co.jp>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: joerg.roedel@amd.com, netdev@vger.kernel.org, tglx@linutronix.de,
	mingo@redhat.com, linux-kernel@vger.kernel.org,
	iommu@lists.linux-foundation.org
To: FUJITA Tomonori <fujita.tomonori@lab.ntt.co.jp>
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1757075AbYKVJib@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <20081122120902Y.fujita.tomonori@lab.ntt.co.jp>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Sat, Nov 22, 2008 at 12:27:42PM +0900, FUJITA Tomonori wrote:
> On Fri, 21 Nov 2008 17:26:07 +0100
> Joerg Roedel <joerg.roedel@amd.com> wrote:
> > +void debug_alloc_coherent(struct device *dev, size_t size,
> > +			  dma_addr_t dma_addr, void *virt)
> > +{
> > +	unsigned long flags;
> > +	struct dma_debug_entry *entry;
> > +
> > +	if (dma_addr == bad_dma_address)
> > +		return;
> > +
> > +	entry = dma_entry_alloc();
> > +	if (!entry)
> > +		return;
> > +
> > +	entry->type      = DMA_DEBUG_COHERENT;
> > +	entry->dev       = dev;
> > +	entry->cpu_addr  = virt;
> > +	entry->size      = size;
> > +	entry->dev_addr  = dma_addr;
> > +	entry->direction = DMA_BIDIRECTIONAL;
> > +
> > +	spin_lock_irqsave(&dma_lock, flags);
> > +	add_dma_entry(entry);
> > +	spin_unlock_irqrestore(&dma_lock, flags);
> > +}
> > +EXPORT_SYMBOL(debug_alloc_coherent);
> 
> Can you clean up the duplication in debug_map_single, debug_map_sg,
> and debug_alloc_coherent? The higher-level helper functions might
> help.

Hmm, lets see. For me it makes only sense if it won't result in helper
functions with tons of parameters. This is worse than little code
duplication. But lets see.

Joerg
