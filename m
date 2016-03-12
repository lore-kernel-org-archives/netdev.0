From: Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>
Subject: Re: [PATCH net v3.16]r8169: Not enable/disable bus mastering when is
 enabled on BIOS
Date: Sat, 12 Mar 2016 22:09:31 +0300
Message-ID: <56E4696B.1050808@cogentembedded.com>
References: <1457764426-6578-1-git-send-email-asd@marian1000.go.ro>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Francois Romieu <romieu@fr.zoreil.com>
To: Corcodel Marian <asd@marian1000.go.ro>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-lb0-f173.google.com ([209.85.217.173]:33743 "EHLO
	mail-lb0-f173.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752167AbcCLTJf (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 12 Mar 2016 14:09:35 -0500
Received: by mail-lb0-f173.google.com with SMTP id k15so195609371lbg.0
        for <netdev@vger.kernel.org>; Sat, 12 Mar 2016 11:09:34 -0800 (PST)
In-Reply-To: <1457764426-6578-1-git-send-email-asd@marian1000.go.ro>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hello.

On 03/12/2016 09:33 AM, Corcodel Marian wrote:

>   This patch not enable/disable bus mastering when is enabled on BIOS..
>   pci_disable_device function also disable bus mastering for, disable bus mastering
>    is dedicate function.
>
> Signed-off-by: Corcodel Marian <asd@marian1000.go.ro>
> ---
>   drivers/net/ethernet/realtek/r8169.c | 29 ++++++++++++++++++++++++++---
>   1 file changed, 26 insertions(+), 3 deletions(-)
>
> diff --git a/drivers/net/ethernet/realtek/r8169.c b/drivers/net/ethernet/realtek/r8169.c
> index 02aec96..ec555e7 100644
> --- a/drivers/net/ethernet/realtek/r8169.c
> +++ b/drivers/net/ethernet/realtek/r8169.c
[...]
> @@ -7103,7 +7120,13 @@ rtl_init_one(struct pci_dev *pdev, const struct pci_device_id *ent)
>
>   	rtl_ack_events(tp, 0xffff);
>
> -	pci_set_master(pdev);
> +	pci_read_config_word(pdev, PCI_COMMAND, &cmd);
> +	if (cmd & PCI_COMMAND_MASTER)
> +		tp->bios_support = true;
> +	else {

    Documentation/CodingStyle requites {} on all branches of the *if* 
statement if at least one branch has them.

> +		tp->bios_support = false;
> +		pci_set_master(pdev);
> +	}
>
>   	/*
>   	 * Pretend we are using VLANs; This bypasses a nasty bug where

MBR, Sergei
