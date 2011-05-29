From: Russell King - ARM Linux <linux@arm.linux.org.uk>
Subject: Re: [PATCH] pxa: don't ask for a buffer from DMA zone
Date: Sun, 29 May 2011 11:24:56 +0100
Message-ID: <20110529102456.GX24876@n2100.arm.linux.org.uk>
References: <1306658575-17160-1-git-send-email-dbaryshkov@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Samuel Ortiz <samuel@sortiz.org>, netdev@vger.kernel.org,
	Eric Miao <eric.y.miao@gmail.com>,
	linux-arm-kernel@lists.infradead.org
To: Dmitry Eremin-Solenikov <dbaryshkov@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from caramon.arm.linux.org.uk ([78.32.30.218]:33013 "EHLO
	caramon.arm.linux.org.uk" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751301Ab1E2KZP (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 29 May 2011 06:25:15 -0400
Content-Disposition: inline
In-Reply-To: <1306658575-17160-1-git-send-email-dbaryshkov@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sun, May 29, 2011 at 12:42:55PM +0400, Dmitry Eremin-Solenikov wrote:
> PXA don't have special DMA zone. And since
> 197b59ae6e8bee56fcef37ea2482dc08414e2ac (mm: fail GFP_DMA allocations
> when ZONE_DMA is not configured) allocation with GFP_DMA set will fail
> with a trace like this:

These buffers are never used with DMA, its only used with the PIO activity
when in SIR mode.  When in FIR mode, and DMA is being used, we copy it to
a block of memory allocated by dma_coherent_alloc().  So the GFP_DMA
annotation here is redundant.

And that's probably more important to document in the changelog... its not
that PXA doesn't have a special DMA zone, it's that the driver doesn't do
DMA on these buffers so its pointless marking them with GFP_DMA.

>  static int pxa_irda_init_iobuf(iobuff_t *io, int size)
>  {
> -	io->head = kmalloc(size, GFP_KERNEL | GFP_DMA);
> +	io->head = kmalloc(size, GFP_KERNEL);
>  	if (io->head != NULL) {
>  		io->truesize = size;
>  		io->in_frame = FALSE;
> -- 
> 1.7.4.4
> 
> 
> _______________________________________________
> linux-arm-kernel mailing list
> linux-arm-kernel@lists.infradead.org
> http://lists.infradead.org/mailman/listinfo/linux-arm-kernel
