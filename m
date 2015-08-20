From: Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>
Subject: Re: [PATCH, net-next] r8169: Disable some bits on pcie
Date: Thu, 20 Aug 2015 15:57:04 +0300
Message-ID: <55D5CEA0.2090900@cogentembedded.com>
References: <1440065553-15028-1-git-send-email-corcodel.marian@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
To: Corcodel Marian <corcodel.marian@gmail.com>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-la0-f54.google.com ([209.85.215.54]:34038 "EHLO
	mail-la0-f54.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751576AbbHTM5H (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 20 Aug 2015 08:57:07 -0400
Received: by laba3 with SMTP id a3so21987278lab.1
        for <netdev@vger.kernel.org>; Thu, 20 Aug 2015 05:57:05 -0700 (PDT)
In-Reply-To: <1440065553-15028-1-git-send-email-corcodel.marian@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hello.

On 8/20/2015 1:12 PM, Corcodel Marian wrote:

> Disable legacy interrupt on pci express interface use msi
>   disable some bits from pci express interface wich is not   need on this nic.
>
>
> Signed-off-by: Corcodel Marian <corcodel.marian@gmail.com>
>
> diff --git a/drivers/net/ethernet/realtek/r8169.c b/drivers/net/ethernet/realtek/r8169.c
> index 6d16de3..b1fb54f 100644
> --- a/drivers/net/ethernet/realtek/r8169.c
> +++ b/drivers/net/ethernet/realtek/r8169.c
> @@ -8164,6 +8164,13 @@ static int rtl_init_one(struct pci_dev *pdev, const struct pci_device_id *ent)
>   	if (!pci_is_pcie(pdev))
>   		netif_info(tp, probe, dev, "not PCI Express\n");
>
> +	if (pci_is_pcie(pdev))
> +		pci_write_config_word(pdev, PCI_COMMAND, ~(PCI_COMMAND_FAST_BACK | PCI_COMMAND_WAIT |
> +					PCI_COMMAND_VGA_PALETTE | PCI_COMMAND_INVALIDATE | PCI_COMMAND_SPECIAL));

    Please start the continuation line under 'pdev' on the first line.

> +
> +	if (pci_is_pcie(pdev))
> +		pci_intx(pdev, 0);
> +

    Why two identical *if* statements? Please make it one.

MBR, Sergei
