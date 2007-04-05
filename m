From: Valerie Henson <val_henson@linux.intel.com>
Subject: Re: [PATCH] fix MCA when shutting down tulip quad-NIC
Date: Thu, 5 Apr 2007 14:34:17 -0700
Message-ID: <20070405213415.GA22707@nifty>
References: <20070403211916.GA25570@aepfle.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: andrew.patterson@hp.com, netdev@vger.kernel.org
To: Olaf Hering <olaf@aepfle.de>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga06.intel.com ([134.134.136.21]:31200 "EHLO
	orsmga101.jf.intel.com" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1767331AbXDEVeU (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 5 Apr 2007 17:34:20 -0400
Content-Disposition: inline
In-Reply-To: <20070403211916.GA25570@aepfle.de>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tue, Apr 03, 2007 at 11:19:16PM +0200, Olaf Hering wrote:
> From: andrew.patterson@hp.com
> 
>  https://bugzilla.novell.com/show_bug.cgi?id=SUSE39204

Wow, registering for Novell's bugzilla is painful.  And in the end I
get "Access denied" on that bug.  Can you give us this information
some other way?

> Shutting down the network causes an MCA because of an IO TLB error when
> a DEC quad 10/100 card is in any slot.  This problem was originally seen
> on an HP rx4640.

I'm not clear on why pci_disable_device() would fix this bug.  Do you
have an explanation (or can copy one out of the bug report)?  I'm
hesitant to make even obviously correct changes to the tulip driver
without good evidence, given the incredible variety of buggy hardware
out there.

This looks to me like another iteration of the shutdown DMA/irq race
at first glance.  Grant has a patch for it; I'm working on one I
consider cleaner.

-VAL

> 
> 
> Signed-off-by: Olaf Hering <olaf@aepfle.de>
> 
> ---
> 
> Andrew: Why is it tp->pdev instead of pdev?

> 
>  drivers/net/tulip/tulip_core.c |    1 +
>  1 file changed, 1 insertion(+)
> 
> Index: b/drivers/net/tulip/tulip_core.c
> ===================================================================
> --- a/drivers/net/tulip/tulip_core.c
> +++ b/drivers/net/tulip/tulip_core.c
> @@ -1798,6 +1798,7 @@ static void __devexit tulip_remove_one (
>  		return;
>  
>  	tp = netdev_priv(dev);
> +	pci_disable_device(tp->pdev);
>  	unregister_netdev(dev);
>  	pci_free_consistent (pdev,
>  			     sizeof (struct tulip_rx_desc) * RX_RING_SIZE +
