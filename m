From: Andy Fleming <afleming@freescale.com>
Subject: NIU driver unmap_page call
Date: Fri, 29 May 2009 17:38:50 -0500
Message-ID: <71C5D403-0A82-45E6-8FEF-2911B7BB9C24@freescale.com>
Mime-Version: 1.0 (Apple Message framework v930.3)
Content-Type: text/plain; charset=US-ASCII; format=flowed; delsp=yes
Content-Transfer-Encoding: 7bit
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from az33egw02.freescale.net ([192.88.158.103]:51250 "EHLO
	az33egw02.freescale.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752346AbZE2Wiy (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 29 May 2009 18:38:54 -0400
Received: from az33smr01.freescale.net (az33smr01.freescale.net [10.64.34.199])
	by az33egw02.freescale.net (8.14.3/az33egw02) with ESMTP id n4TMcp7b009390
	for <netdev@vger.kernel.org>; Fri, 29 May 2009 15:38:53 -0700 (MST)
Received: from [192.168.2.3] (mvp-10-214-72-40.am.freescale.net [10.214.72.40])
	by az33smr01.freescale.net (8.13.1/8.13.0) with ESMTP id n4TMcoPe029155
	for <netdev@vger.kernel.org>; Fri, 29 May 2009 17:38:51 -0500 (CDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

I'm working on a driver for a nic which has a hardware buffer  
management feature, and I'm patterning some of the management of that  
feature off the niu driver. I'm trying to figure out what this code  
does:

                if ((page->index + rp->rbr_block_size) - rcr_size ==  
addr) {
                        *link = (struct page *) page->mapping;
                        np->ops->unmap_page(np->device, page->index,
                                            PAGE_SIZE, DMA_FROM_DEVICE);
                        page->index = 0;
                        page->mapping = NULL;
                        rp->rbr_refill_pending++;
                } else
                        get_page(page);

It's clear it's taking the opportunity to remove the page from the  
hash table, and to unmap the page, but I'm not familiar enough with  
this nic to understand what the if statement is looking for.  My first  
thought was that it was looking to see if this was the first buffer in  
the page?  But that can't be right...   And why the get_page? I  
thought the add_page code took care of incrementing the reference  
count.  Lastly, the unmap_page call concerns me.  I'm on a 32-bit  
platform with support for 36-bit physical addresses, which means I  
need to unmap the memory before I give it to the stack.

I suppose the easier solution would be to kmalloc the buffers I put in  
the pool, but that would take longer, so I'm hoping I can use the same  
method as the NIU driver.

Thanks,
Andy
