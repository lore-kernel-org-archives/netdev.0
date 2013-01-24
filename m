From: "Michael S. Tsirkin" <mst@redhat.com>
Subject: Re: [PATCH] vhost-net: fall back to vmalloc if high-order allocation
 fails
Date: Thu, 24 Jan 2013 12:06:00 +0200
Message-ID: <20130124100600.GB8710@redhat.com>
References: <87k3r31vbc.fsf@silenus.orebokech.com>
 <AE90C24D6B3A694183C094C60CF0A2F6026B711E@saturn3.aculab.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Romain Francoise <romain@orebokech.com>, kvm@vger.kernel.org,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: David Laight <David.Laight@ACULAB.COM>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <AE90C24D6B3A694183C094C60CF0A2F6026B711E@saturn3.aculab.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thu, Jan 24, 2013 at 09:45:50AM -0000, David Laight wrote:
> > +	n = kmalloc(sizeof *n, GFP_KERNEL | __GFP_NOWARN);
> > +	if (!n)
> > +		n = vmalloc(sizeof *n);
> 
> I'm slightly confused by this construct.
> I thought kmalloc(... GFP_KERNEL) would sleep waiting for
> memory (rather than return NULL).
> 
> I realise that (for multi-page sizes) that kmalloc() and
> vmalloc() both need to find a contiguous block of kernel
> virtual addresses - in different address ranges, and
> that vmalloc() then has to find physical memory pages
> (which will not be contiguous).
> 
> I think this means that kmalloc() is likely to be faster
> (if it doesn't have to sleep), but that vmalloc() is
> allocating from a much larger resource.
> 
> This make me that that large allocations that are not
> temporary should probably be allocated with vmalloc().

vmalloc has some issues for example afaik it's not backed by
a huge page so  I think its use puts more stress on the TLB cache.

> Is there a 'NO_SLEEP' flag to kmalloc()? is that all
> GFP_ATOMIC requests? If so you might try a non-sleeping
> kmalloc() with a vmalloc() if it fails.
> 
> This all looks as though there should be a GFP_NONCONTIG
> flag (or similar) so that kmalloc() can make a decision itself.
> 
> Of at least a wrapper - like the one for free().
> 
> 	David
> 
> 
