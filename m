From: Arjan van de Ven <arjan@infradead.org>
Subject: Re: PATCH] net: b44.c fix sleeping-with-spinlock-helt during resume
Date: Sun, 1 Jun 2008 09:01:07 -0700
Message-ID: <20080601090107.1ed8d5a7@infradead.org>
References: <20080531201130.0244dc29@infradead.org>
	<200806011203.40437.mb@bu3sch.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	akpm@linux-foundation.org
To: Michael Buesch <mb@bu3sch.de>
Return-path: <netdev-owner@vger.kernel.org>
Received: from pentafluge.infradead.org ([213.146.154.40]:43996 "EHLO
	pentafluge.infradead.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751859AbYFAQBQ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 1 Jun 2008 12:01:16 -0400
In-Reply-To: <200806011203.40437.mb@bu3sch.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sun, 1 Jun 2008 12:03:40 +0200
Michael Buesch <mb@bu3sch.de> wrote:

> Index: wireless-testing/drivers/ssb/driver_pcicore.c
> ===================================================================
> --- wireless-testing.orig/drivers/ssb/driver_pcicore.c
> 2008-04-23 16:06:56.000000000 +0200 +++
> wireless-testing/drivers/ssb/driver_pcicore.c	2008-06-01
> 12:02:33.000000000 +0200 @@ -537,12 +537,12 @@ int
> ssb_pcicore_dev_irqvecs_enable(struc int err = 0; u32 tmp;
>  
> -	might_sleep();
> -
>  	if (!pdev)
>  		goto out;
>  	bus = pdev->bus;
>  
> +	might_sleep_if(pdev->id.coreid != SSB_DEV_PCI);
> +
>  	/* Enable interrupts for this device. */
>  	if (bus->host_pci &&
>  	    ((pdev->id.revision >= 6) || (pdev->id.coreid ==
> SSB_DEV_PCIE))) {
> 
> 
> 

fair enough.... can we get something like this into 2.6.26 still? Quite
a few people are hitting this (even though the warning is harmless, it
still is better to silence it)

-- 
If you want to reach me at my work email, use arjan@linux.intel.com
For development, discussion and tips for power savings, 
visit http://www.lesswatts.org
