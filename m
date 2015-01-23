From: Francois Romieu <romieu@fr.zoreil.com>
Subject: Re: [PATCH] atheros/atlx: Simplify bit manipulations
Date: Fri, 23 Jan 2015 21:26:19 +0100
Message-ID: <20150123202619.GA10084@electric-eye.fr.zoreil.com>
References: <1422011212-30095-1-git-send-email-linux@rasmusvillemoes.dk>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Jay Cliburn <jcliburn@gmail.com>,
	Chris Snook <chris.snook@gmail.com>, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: Rasmus Villemoes <linux@rasmusvillemoes.dk>
Return-path: <netdev-owner@vger.kernel.org>
Received: from violet.fr.zoreil.com ([92.243.8.30]:40565 "EHLO
	violet.fr.zoreil.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753191AbbAWU0W (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 23 Jan 2015 15:26:22 -0500
Content-Disposition: inline
In-Reply-To: <1422011212-30095-1-git-send-email-linux@rasmusvillemoes.dk>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Rasmus Villemoes <linux@rasmusvillemoes.dk> :
[...]
> diff --git a/drivers/net/ethernet/atheros/atlx/atl2.c b/drivers/net/ethernet/atheros/atlx/atl2.c
> index 84a09e8ddd9c..46d1b959daa8 100644
> --- a/drivers/net/ethernet/atheros/atlx/atl2.c
> +++ b/drivers/net/ethernet/atheros/atlx/atl2.c
> @@ -1278,14 +1278,10 @@ static void atl2_setup_pcicmd(struct pci_dev *pdev)
>  
>  	pci_read_config_word(pdev, PCI_COMMAND, &cmd);
>  
> -	if (cmd & PCI_COMMAND_INTX_DISABLE)
> -		cmd &= ~PCI_COMMAND_INTX_DISABLE;
> -	if (cmd & PCI_COMMAND_IO)
> -		cmd &= ~PCI_COMMAND_IO;
> -	if (0 == (cmd & PCI_COMMAND_MEMORY))
> -		cmd |= PCI_COMMAND_MEMORY;
> -	if (0 == (cmd & PCI_COMMAND_MASTER))
> -		cmd |= PCI_COMMAND_MASTER;
> +	cmd &= ~PCI_COMMAND_INTX_DISABLE;
> +	cmd &= ~PCI_COMMAND_IO;
> +	cmd |= PCI_COMMAND_MEMORY;
> +	cmd |= PCI_COMMAND_MASTER;
>  	pci_write_config_word(pdev, PCI_COMMAND, cmd);

Mostly open-coded pci_set_master, pci_enable_device_mem and pci_intx.

I'd suggest to ignore the PCI_COMMAND_IO bit at all then use the standard
pci helpers.

-- 
Ueimor
