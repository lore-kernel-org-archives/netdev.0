From: Francois Romieu <romieu@fr.zoreil.com>
Subject: Re: [PATCH 01/24 for-2.6.25] DM9000: Fix endian-ness of data
	accesses. Patch from: Laurent Pinchart <laurentp@cse-semaphore.com>
Date: Tue, 5 Feb 2008 23:57:37 +0100
Message-ID: <20080205225737.GB12258@electric-eye.fr.zoreil.com>
References: <20080205000159.432081941@fluff.org.uk> <20080205000814.539308209@fluff.org.uk>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, jeff@garzik.org, akpm@linux-foundation.org,
	daniel@caiaq.de, laurentp@cse-semaphore.com
To: Ben Dooks <ben-linux@fluff.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from electric-eye.fr.zoreil.com ([213.41.134.224]:46799 "EHLO
	electric-eye.fr.zoreil.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1756845AbYBEXQj (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 5 Feb 2008 18:16:39 -0500
Content-Disposition: inline
In-Reply-To: <20080205000814.539308209@fluff.org.uk>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Ben Dooks <ben-linux@fluff.org> :
> This patch splits the receive status in 8bit wide fields and convert the
> packet length from little endian to CPU byte order.
> 
> Signed-off-by: Laurent Pinchart <laurentp@cse-semaphore.com>
> Signed-off-by: Ben Dooks <ben-linux@fluff.org>
> 
> Index: linux-2.6.24-git5-dm9k/drivers/net/dm9000.c
> ===================================================================
> --- linux-2.6.24-git5-dm9k.orig/drivers/net/dm9000.c
> +++ linux-2.6.24-git5-dm9k/drivers/net/dm9000.c
> @@ -867,7 +867,8 @@ dm9000_timer(unsigned long data)
>  }
>  
>  struct dm9000_rxhdr {
> -	u16	RxStatus;
> +	u8	RxPktReady;
> +	u8	RxStatus;
>  	u16	RxLen;

Given the description of the patch, you could s/u16/__le16/

Al regularly pushes endianness fixes. You can save him some work.

-- 
Ueimor
