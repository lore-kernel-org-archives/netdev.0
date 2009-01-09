From: Joerg Roedel <joro@8bytes.org>
Subject: Re: [PATCH 10/16] dma-debug: add add checking for map/unmap_sg
Date: Fri, 9 Jan 2009 19:11:14 +0100
Message-ID: <20090109181114.GA9466@8bytes.org>
References: <1231517970-20288-1-git-send-email-joerg.roedel@amd.com> <1231517970-20288-11-git-send-email-joerg.roedel@amd.com> <20090109180836.GD30168@ioremap.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Joerg Roedel <joerg.roedel@amd.com>, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org, iommu@lists.linux-foundation.org,
	mingo@redhat.com
To: Evgeniy Polyakov <zbr@ioremap.net>
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1755432AbZAISLm@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <20090109180836.GD30168@ioremap.net>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Fri, Jan 09, 2009 at 09:08:36PM +0300, Evgeniy Polyakov wrote:
> On Fri, Jan 09, 2009 at 05:19:24PM +0100, Joerg Roedel (joerg.roedel@amd.com) wrote:
> > +void debug_map_sg(struct device *dev, struct scatterlist *sg,
> > +		  int nents, int direction)
> > +{
> > +	struct dma_debug_entry *entry;
> > +	struct scatterlist *s;
> > +	int i;
> > +
> > +	if (global_disable)
> > +		return;
> > +
> > +	for_each_sg(sg, s, nents, i) {
> > +		entry = dma_entry_alloc();
> > +		if (!entry)
> > +			return;
> > +
> > +		entry->type      = dma_debug_sg;
> > +		entry->dev       = dev;
> > +		entry->cpu_addr  = sg_virt(s);
> > +		entry->size      = s->length;
> > +		entry->dev_addr  = s->dma_address;
> > +		entry->direction = direction;
> > +
> > +		add_dma_entry(entry);
> > +	}
> > +}
> > +EXPORT_SYMBOL(debug_map_sg);
> > +
> > +void debug_unmap_sg(struct device *dev, struct scatterlist *sglist,
> > +		    int nelems, int dir)
> > +{
> > +	struct scatterlist *s;
> > +	int i;
> > +
> > +	if (global_disable)
> > +		return;
> > +
> > +	for_each_sg(sglist, s, nelems, i) {
> > +
> > +		struct dma_debug_entry ref = {
> > +			.type           = dma_debug_sg,
> > +			.dev            = dev,
> > +			.cpu_addr       = sg_virt(s),
> > +			.dev_addr       = s->dma_address,
> > +			.size           = s->length,
> > +			.direction      = dir,
> > +		};
> > +
> > +		check_unmap(&ref);
> 
> Will this print false errors if above map debug failed to add an entry
> into the list?

No. The code disables itself if adding an entry fails. This can only
happen when we run out of preallocated dma_debug_entries.

Joerg
