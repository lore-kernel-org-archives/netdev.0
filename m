From: Jeff Garzik <jeff@garzik.org>
Subject: Re: [PATCH 5/9] [TULIP] Flush MMIO writes in reset sequence
Date: Wed, 09 Aug 2006 01:33:49 -0400
Message-ID: <44D973BD.4000100@garzik.org>
References: <20060807204418.GE401@athena.road.mcmartin.ca> <11549840122892-git-send-email-kyle@parisc-linux.org> <11549840321096-git-send-email-kyle@parisc-linux.org> <1154984032324-git-send-email-kyle@parisc-linux.org> <115498403384-git-send-email-kyle@parisc-linux.org> <11549840341728-git-send-email-kyle@parisc-linux.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, grundler@parisc-linux.org,
	val_henson@linux.intel.com, akpm@osdl.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from srv5.dvmed.net ([207.36.208.214]:1696 "EHLO mail.dvmed.net")
	by vger.kernel.org with ESMTP id S965067AbWHIFdv (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 9 Aug 2006 01:33:51 -0400
To: Kyle McMartin <kyle@parisc-linux.org>
In-Reply-To: <11549840341728-git-send-email-kyle@parisc-linux.org>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Kyle McMartin wrote:
> From: Grant Grundler <grundler@parisc-linux.org>
> 
> The obvious safe registers to read is one from PCI config space.
> 
> Signed-off-by: Grant Grundler <grundler@parisc-linux.org>
> Signed-off-by: Kyle McMartin <kyle@parisc-linux.org>
> ---
>  drivers/net/tulip/tulip_core.c |    2 ++
>  1 files changed, 2 insertions(+), 0 deletions(-)
> 
> diff --git a/drivers/net/tulip/tulip_core.c b/drivers/net/tulip/tulip_core.c
> index 6b54572..81905f4 100644
> --- a/drivers/net/tulip/tulip_core.c
> +++ b/drivers/net/tulip/tulip_core.c
> @@ -295,12 +295,14 @@ static void tulip_up(struct net_device *
>  
>  	/* Reset the chip, holding bit 0 set at least 50 PCI cycles. */
>  	iowrite32(0x00000001, ioaddr + CSR0);
> +	pci_read_config_dword(tp->pdev, PCI_COMMAND, &i);  /* flush write */
>  	udelay(100);
>  
>  	/* Deassert reset.
>  	   Wait the specified 50 PCI cycles after a reset by initializing
>  	   Tx and Rx queues and the address filter list. */
>  	iowrite32(tp->csr0, ioaddr + CSR0);
> +	pci_read_config_dword(tp->pdev, PCI_COMMAND, &i);  /* flush write */
>  	udelay(100);

OK


