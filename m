From: Evgeniy Polyakov <zbr@ioremap.net>
Subject: Re: [PATCH 10/16] dma-debug: add add checking for map/unmap_sg
Date: Fri, 9 Jan 2009 21:08:36 +0300
Message-ID: <20090109180836.GD30168@ioremap.net>
References: <1231517970-20288-1-git-send-email-joerg.roedel@amd.com> <1231517970-20288-11-git-send-email-joerg.roedel@amd.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: linux-kernel@vger.kernel.org, mingo@redhat.com,
	dwmw2@infradead.org, fujita.tomonori@lab.ntt.co.jp,
	netdev@vger.kernel.org, iommu@lists.linux-foundation.org
To: Joerg Roedel <joerg.roedel@amd.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from kandzendo.ru ([195.178.208.66]:59108 "EHLO tservice.net.ru"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752958AbZAISIh (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 9 Jan 2009 13:08:37 -0500
Content-Disposition: inline
In-Reply-To: <1231517970-20288-11-git-send-email-joerg.roedel@amd.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, Jan 09, 2009 at 05:19:24PM +0100, Joerg Roedel (joerg.roedel@amd.com) wrote:
> +void debug_map_sg(struct device *dev, struct scatterlist *sg,
> +		  int nents, int direction)
> +{
> +	struct dma_debug_entry *entry;
> +	struct scatterlist *s;
> +	int i;
> +
> +	if (global_disable)
> +		return;
> +
> +	for_each_sg(sg, s, nents, i) {
> +		entry = dma_entry_alloc();
> +		if (!entry)
> +			return;
> +
> +		entry->type      = dma_debug_sg;
> +		entry->dev       = dev;
> +		entry->cpu_addr  = sg_virt(s);
> +		entry->size      = s->length;
> +		entry->dev_addr  = s->dma_address;
> +		entry->direction = direction;
> +
> +		add_dma_entry(entry);
> +	}
> +}
> +EXPORT_SYMBOL(debug_map_sg);
> +
> +void debug_unmap_sg(struct device *dev, struct scatterlist *sglist,
> +		    int nelems, int dir)
> +{
> +	struct scatterlist *s;
> +	int i;
> +
> +	if (global_disable)
> +		return;
> +
> +	for_each_sg(sglist, s, nelems, i) {
> +
> +		struct dma_debug_entry ref = {
> +			.type           = dma_debug_sg,
> +			.dev            = dev,
> +			.cpu_addr       = sg_virt(s),
> +			.dev_addr       = s->dma_address,
> +			.size           = s->length,
> +			.direction      = dir,
> +		};
> +
> +		check_unmap(&ref);

Will this print false errors if above map debug failed to add an entry
into the list?

-- 
	Evgeniy Polyakov
