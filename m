From: Simon Farnsworth <simon.farnsworth@onelan.com>
Subject: Re: r8169 chips on some Intel D945GSEJT boards fail to work after
 PXE boot
Date: Thu, 24 Sep 2009 12:12:53 +0100
Message-ID: <4ABB5435.6040609@onelan.com>
References: <4ABA535E.2010801@onelan.com> <20090923205723.GA28058@electric-eye.fr.zoreil.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Francois Romieu <romieu@fr.zoreil.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from claranet-outbound-smtp00.uk.clara.net ([195.8.89.33]:40614 "EHLO
	claranet-outbound-smtp00.uk.clara.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751193AbZIXLMy (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 24 Sep 2009 07:12:54 -0400
In-Reply-To: <20090923205723.GA28058@electric-eye.fr.zoreil.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Francois Romieu wrote:
> Simon Farnsworth <simon.farnsworth@onelan.com> :
> [...]
>> Some boards are good, and just work, whether I boot via PXE or boot from
>> the local disk; dmesg.working and lspci.working are from a good board.
>>
>> Some boards are bad; they work fine if I boot from local disk (including
>> network), but the kernel cannot detect link, or send or receive data if
>> I PXE boot. dmesg.broken and lspci.broken are from a bad board.
> 
> No cunning theroy in sight but does reducing the amount of memory on a
> bad board from 1 Go to 512 Mo turn it into a good one ?
> 
We've tried this, and we've tried 2GB and 1GB modules; the failure to
boot sticks with the board, not with the memory module. On my most
recent attempt, the failing board isn't showing a correctable error
status, so I've not yet tried your patch, on the assumption that it just
clears the error status.

Is my assumption wrong? If not, is there anything else I can do that
would help you diagnose this?

> The failing board exhibits a correctable error status bit. Clearing it
> is the least we can do.
> 
> diff --git a/drivers/net/r8169.c b/drivers/net/r8169.c
> index 50c6a3c..79bc4ab 100644
> --- a/drivers/net/r8169.c
> +++ b/drivers/net/r8169.c
> @@ -2200,6 +2200,11 @@ rtl8169_init_one(struct pci_dev *pdev, const struct pci_device_id *ent)
>  	tp->pcie_cap = pci_find_capability(pdev, PCI_CAP_ID_EXP);
>  	if (!tp->pcie_cap && netif_msg_probe(tp))
>  		dev_info(&pdev->dev, "no PCI Express capability\n");
> +	else {
> +		pci_write_config_word(pdev, tp->pcie_cap + PCI_EXP_DEVSTA,
> +				      PCI_EXP_DEVSTA_CED | PCI_EXP_DEVSTA_NFED |
> +				      PCI_EXP_DEVSTA_FED | PCI_EXP_DEVSTA_URD);
> +	}
>  
>  	RTL_W16(IntrMask, 0x0000);
>  

-- 
Simon Farnsworth

