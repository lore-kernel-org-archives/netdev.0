From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH, net-next] r8169: Disable some bits on pcie
Date: Thu, 20 Aug 2015 06:44:03 -0700
Message-ID: <1440078243.6610.45.camel@edumazet-glaptop2.roam.corp.google.com>
References: <1440065553-15028-1-git-send-email-corcodel.marian@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Corcodel Marian <corcodel.marian@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pd0-f180.google.com ([209.85.192.180]:33135 "EHLO
	mail-pd0-f180.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751344AbbHTNoG (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 20 Aug 2015 09:44:06 -0400
Received: by pdrh1 with SMTP id h1so14764330pdr.0
        for <netdev@vger.kernel.org>; Thu, 20 Aug 2015 06:44:05 -0700 (PDT)
In-Reply-To: <1440065553-15028-1-git-send-email-corcodel.marian@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 2015-08-20 at 13:12 +0300, Corcodel Marian wrote:
> Disable legacy interrupt on pci express interface use msi 
>  disable some bits from pci express interface wich is not   need on this nic.
> 
> 
> Signed-off-by: Corcodel Marian <corcodel.marian@gmail.com>
> 
> diff --git a/drivers/net/ethernet/realtek/r8169.c b/drivers/net/ethernet/realtek/r8169.c
> index 6d16de3..b1fb54f 100644
> --- a/drivers/net/ethernet/realtek/r8169.c
> +++ b/drivers/net/ethernet/realtek/r8169.c
> @@ -8164,6 +8164,13 @@ static int rtl_init_one(struct pci_dev *pdev, const struct pci_device_id *ent)
>  	if (!pci_is_pcie(pdev))
>  		netif_info(tp, probe, dev, "not PCI Express\n");
>  
> +	if (pci_is_pcie(pdev))
> +		pci_write_config_word(pdev, PCI_COMMAND, ~(PCI_COMMAND_FAST_BACK | PCI_COMMAND_WAIT |
> +					PCI_COMMAND_VGA_PALETTE | PCI_COMMAND_INVALIDATE | PCI_COMMAND_SPECIAL));
> +
> +	if (pci_is_pcie(pdev))
> +		pci_intx(pdev, 0);
> +
>  	/* Identify chip attached to board */
>  	rtl8169_get_mac_version(tp, dev, cfg->default_ver);
>  

Why is it needed ?

PCI_COMMAND_VGA_PALETTE is never used in a networking driver, why should
we eventually take care ?

What exact problem are you solving ?

We wont accept a patch without a clear description, given all the crap
you have sent.
