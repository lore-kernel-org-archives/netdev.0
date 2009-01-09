From: Evgeniy Polyakov <zbr@ioremap.net>
Subject: Re: [PATCH 03/16] dma-debug: add hash functions for dma_debug_entries
Date: Fri, 9 Jan 2009 20:55:42 +0300
Message-ID: <20090109175542.GB30168@ioremap.net>
References: <1231517970-20288-1-git-send-email-joerg.roedel@amd.com> <1231517970-20288-4-git-send-email-joerg.roedel@amd.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: linux-kernel@vger.kernel.org, mingo@redhat.com,
	dwmw2@infradead.org, fujita.tomonori@lab.ntt.co.jp,
	netdev@vger.kernel.org, iommu@lists.linux-foundation.org
To: Joerg Roedel <joerg.roedel@amd.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from kandzendo.ru ([195.178.208.66]:37593 "EHLO tservice.net.ru"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750698AbZAIRzo (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 9 Jan 2009 12:55:44 -0500
Content-Disposition: inline
In-Reply-To: <1231517970-20288-4-git-send-email-joerg.roedel@amd.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Joerg.

On Fri, Jan 09, 2009 at 05:19:17PM +0100, Joerg Roedel (joerg.roedel@amd.com) wrote:
> +/*
> + * Request exclusive access to a hash bucket for a given dma_debug_entry.
> + */
> +static struct hash_bucket *get_hash_bucket(struct dma_debug_entry *entry,
> +					   unsigned long *flags)
> +{
> +	int idx = hash_fn(entry);
> +	unsigned long __flags;
> +
> +	spin_lock_irqsave(&dma_entry_hash[idx].lock, __flags);
> +	*flags = __flags;
> +	return &dma_entry_hash[idx];
> +}
> +
> +/*
> + * Give up exclusive access to the hash bucket
> + */
> +static void put_hash_bucket(struct hash_bucket *bucket,
> +			    unsigned long *flags)
> +{
> +	unsigned long __flags = *flags;
> +
> +	spin_unlock_irqrestore(&bucket->lock, __flags);
> +}

Why do you need such ugly helpers?

> + * Add an entry to a hash bucket
> + */
> +static void hash_bucket_add(struct hash_bucket *bucket,
> +			    struct dma_debug_entry *entry)
> +{
> +	list_add_tail(&entry->list, &bucket->list);
> +}

> +/*
> + * Remove entry from a hash bucket list
> + */
> +static void hash_bucket_del(struct dma_debug_entry *entry)
> +{
> +	list_del(&entry->list);
> +}

Do you really need this getting they are called only from single place?

-- 
	Evgeniy Polyakov
