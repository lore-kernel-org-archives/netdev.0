From: David Miller <davem@davemloft.net>
Subject: Re: NIU driver unmap_page call
Date: Mon, 01 Jun 2009 03:11:04 -0700 (PDT)
Message-ID: <20090601.031104.187911913.davem@davemloft.net>
References: <71C5D403-0A82-45E6-8FEF-2911B7BB9C24@freescale.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: afleming@freescale.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:49663
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1755828AbZFAKLE (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 1 Jun 2009 06:11:04 -0400
In-Reply-To: <71C5D403-0A82-45E6-8FEF-2911B7BB9C24@freescale.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Andy Fleming <afleming@freescale.com>
Date: Fri, 29 May 2009 17:38:50 -0500

> I'm trying to figure out what this code does:
> 
>                if ((page->index + rp->rbr_block_size) - rcr_size == addr) {
>                        *link = (struct page *) page->mapping;
>                        np->ops->unmap_page(np->device, page->index,
>                                            PAGE_SIZE, DMA_FROM_DEVICE);
>                        page->index = 0;
>                        page->mapping = NULL;
>                        rp->rbr_refill_pending++;
>                } else
>                        get_page(page);
> 
> It's clear it's taking the opportunity to remove the page from the
> hash table, and to unmap the page, but I'm not familiar enough with
> this nic to understand what the if statement is looking for.  My first
> thought was that it was looking to see if this was the first buffer in
> the page?

It's looking to see if this is the LAST chunk in the page, not the
first.

rcr_size is the size of the sub-buffers within the page that the
chip is carving out of the page.

Since when we allocated the page initially this obtained on reference
to the page, we increment for every chunk given out to an SKB except
the last one.
