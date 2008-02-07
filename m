From: Christoph Hellwig <hch@infradead.org>
Subject: Re: [PATCH 01/24 for-2.6.25] DM9000: Fix endian-ness of data
	accesses. Patch from: Laurent Pinchart <laurentp@cse-semaphore.com>
Date: Thu, 7 Feb 2008 08:30:33 -0500
Message-ID: <20080207133033.GA31059@infradead.org>
References: <20080205000159.432081941@fluff.org.uk> <20080205000814.539308209@fluff.org.uk>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, jeff@garzik.org, akpm@linux-foundation.org,
	daniel@caiaq.de, laurentp@cse-semaphore.com
To: Ben Dooks <ben-linux@fluff.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from bombadil.infradead.org ([18.85.46.34]:33355 "EHLO
	bombadil.infradead.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754186AbYBGNaf (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 7 Feb 2008 08:30:35 -0500
Content-Disposition: inline
In-Reply-To: <20080205000814.539308209@fluff.org.uk>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Feb 05, 2008 at 12:02:00AM +0000, Ben Dooks wrote:
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

thgis should be __le16.  Also please install sparse and do a

	make C=2 CHECKFLAGS="-D__CHECK_ENDIAN__"

run over the driver to make sure all hw structures are properly
annotated and you do byteswaps consistantly.

