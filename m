From: Jeff Garzik <jeff@garzik.org>
Subject: Re: [PATCH 1/2] 8139too: Make PIO/MMIO a modparam
Date: Tue, 15 Jul 2008 19:03:50 -0400
Message-ID: <487D2CD6.2070303@garzik.org>
References: <20080429215626.GC2859@redhat.com> <48179B56.7000606@garzik.org> <20080429153240.7200e1a3.akpm@linux-foundation.org> <4818546C.4060703@garzik.org> <20080529150752.GB8247@redhat.com> <483EF385.3000103@garzik.org> <20080529184106.GB24408@redhat.com> <483EFD8F.2070407@garzik.org> <20080715184006.GA20772@redhat.com> <487D2236.9000903@garzik.org> <20080715225410.GB10532@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Andrew Morton <akpm@linux-foundation.org>, netdev@vger.kernel.org
To: Dave Jones <davej@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from srv5.dvmed.net ([207.36.208.214]:55368 "EHLO mail.dvmed.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756311AbYGOXD5 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 15 Jul 2008 19:03:57 -0400
In-Reply-To: <20080715225410.GB10532@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Dave Jones wrote:
> On Tue, Jul 15, 2008 at 06:18:30PM -0400, Jeff Garzik wrote:
> 
>  > * [extra project] would be highly useful for MMIO to fall back to PIO, 
>  > and vice versa, should any resource be unavailable.  Sometimes, mainly 
>  > with MMIO and broken/weird BIOSen, only the PIO PCI BARs will be filled 
>  > in with useful info.
> 
> Hmm, this bit might actually be fairly trivial on top of my other patch..
> 
> 
> --- linux-2.6.26.noarch/drivers/net/8139too.c~	2008-07-15 18:49:02.000000000 -0400
> +++ linux-2.6.26.noarch/drivers/net/8139too.c	2008-07-15 18:53:07.000000000 -0400
> @@ -784,6 +784,7 @@ static int __devinit rtl8139_init_board 
>  	DPRINTK("PIO region size == 0x%02X\n", pio_len);
>  	DPRINTK("MMIO region size == 0x%02lX\n", mmio_len);
>  
> +retry:
>  	if (use_io) {
>  		/* make sure PCI base addr 0 is PIO */
>  		if (!(pio_flags & IORESOURCE_IO)) {
> @@ -832,9 +833,10 @@ static int __devinit rtl8139_init_board 
>  		/* ioremap MMIO region */
>  		ioaddr = pci_iomap(pdev, 1, 0);
>  		if (ioaddr == NULL) {
> -			dev_err(&pdev->dev, "cannot remap MMIO, aborting\n");
> -			rc = -EIO;
> -			goto err_out;
> +			dev_err(&pdev->dev, "cannot remap MMIO, trying PIO\n");
> +			pci_release_regions(pdev);
> +			use_ui = 1;
> +			goto retry;

use_ui?  Are you sure this is not not an X.org patch?  :)

Yes, seems like that would do the trick quite nicely...

If you would be kind enough to post this as a separate patch from your 
use_io patch (since IMO its a separate logical change), that would be 
helpful.

	Jeff



