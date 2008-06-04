From: Karsten Keil <kkeil@suse.de>
Subject: Re: [Bugme-new] [Bug 10790] New: driver "sunhme" experiences corrupt packets if machine has more than 2GB of memory
Date: Wed, 4 Jun 2008 10:21:21 +0200
Message-ID: <20080604082121.GA23128@pingi.kke.suse.de>
References: <bug-10790-10286@http.bugzilla.kernel.org/> <20080525114548.6ad40fd7.akpm@linux-foundation.org> <20080603.163317.148261530.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: akpm@linux-foundation.org, netdev@vger.kernel.org,
	bugme-daemon@bugzilla.kernel.org, f0h3a-kernel@yahoo.com,
	kkeil@suse.de
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.suse.de ([195.135.220.2]:40377 "EHLO mx1.suse.de"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752444AbYFDIVY (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 4 Jun 2008 04:21:24 -0400
Content-Disposition: inline
In-Reply-To: <20080603.163317.148261530.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Jun 03, 2008 at 04:33:17PM -0700, David Miller wrote:
> From: Andrew Morton <akpm@linux-foundation.org>
> Date: Sun, 25 May 2008 11:45:48 -0700
> 
> > Note that this patch from Karsten:
> > https://bugzilla.novell.com/attachment.cgi?id=217968 did not work.
> 
> That patch is unlikely to be the issue, right.
> 

No, this patch was a experiment to fix the issue, it is not in our kernel
by default.

> > Stoopid question: if it fails at 2GB, should we try DMA_31BIT_MASK?
> 
> I've scoured all of the docs and the chip itself and the PCI front-end
> it is connected to support full 32-bit PCI addressing.
> 
> The bug report says platform "All" but the report specifically
> mentions Q6600 cpus, is this x86_64 by chance?  I wonder if the
> problem is that we use GFP_ATOMIC/GFP_KERNEL for allocations
> of SKB data, and we end up with buffers above 4GB but the IOMMU
> mapping operation doesn't cope with that correctly.

Yes it is x86_64 and I think, that if you put more as 2G in this machine,
some physical addresses are behind the 4 GB border.


> 
> In the arch/x86/kernel/pci-nommu.c case, this would result in
> kernel log messages from check_addr():
> 
> 		if (*hwdev->dma_mask >= DMA_32BIT_MASK)
> 			printk(KERN_ERR
> 			    "nommu_%s: overflow %Lx+%zu of device mask %Lx\n",
> 				name, (long long)bus, size,
> 				(long long)*hwdev->dma_mask);

-- 
Karsten Keil
SuSE Labs
ISDN and VOIP development
SUSE LINUX Products GmbH, Maxfeldstr.5 90409 Nuernberg, GF: Markus Rex, HRB 16746 (AG Nuernberg)
