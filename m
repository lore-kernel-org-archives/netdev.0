From: Joerg Roedel <joro@8bytes.org>
Subject: Re: [PATCH 03/16] dma-debug: add hash functions for dma_debug_entries
Date: Fri, 9 Jan 2009 19:14:46 +0100
Message-ID: <20090109181446.GB9466@8bytes.org>
References: <1231517970-20288-1-git-send-email-joerg.roedel@amd.com> <1231517970-20288-4-git-send-email-joerg.roedel@amd.com> <20090109175542.GB30168@ioremap.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Joerg Roedel <joerg.roedel@amd.com>, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org, iommu@lists.linux-foundation.org,
	mingo@redhat.com
To: Evgeniy Polyakov <zbr@ioremap.net>
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1754573AbZAISO4@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <20090109175542.GB30168@ioremap.net>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Fri, Jan 09, 2009 at 08:55:42PM +0300, Evgeniy Polyakov wrote:
> Hi Joerg.
> 
> On Fri, Jan 09, 2009 at 05:19:17PM +0100, Joerg Roedel (joerg.roedel@amd.com) wrote:
> > +/*
> > + * Request exclusive access to a hash bucket for a given dma_debug_entry.
> > + */
> > +static struct hash_bucket *get_hash_bucket(struct dma_debug_entry *entry,
> > +					   unsigned long *flags)
> > +{
> > +	int idx = hash_fn(entry);
> > +	unsigned long __flags;
> > +
> > +	spin_lock_irqsave(&dma_entry_hash[idx].lock, __flags);
> > +	*flags = __flags;
> > +	return &dma_entry_hash[idx];
> > +}
> > +
> > +/*
> > + * Give up exclusive access to the hash bucket
> > + */
> > +static void put_hash_bucket(struct hash_bucket *bucket,
> > +			    unsigned long *flags)
> > +{
> > +	unsigned long __flags = *flags;
> > +
> > +	spin_unlock_irqrestore(&bucket->lock, __flags);
> > +}
> 
> Why do you need such ugly helpers?

Because everything else I thought about here was even more ugly. But
maybe you have a better idea? I tried to lock directly in the debug_
functions. But this is ugly and unnecessary code duplication.

> 
> > + * Add an entry to a hash bucket
> > + */
> > +static void hash_bucket_add(struct hash_bucket *bucket,
> > +			    struct dma_debug_entry *entry)
> > +{
> > +	list_add_tail(&entry->list, &bucket->list);
> > +}
> 
> > +/*
> > + * Remove entry from a hash bucket list
> > + */
> > +static void hash_bucket_del(struct dma_debug_entry *entry)
> > +{
> > +	list_del(&entry->list);
> > +}
> 
> Do you really need this getting they are called only from single place?

Hmm, true. I will inline these functions.

Joerg
