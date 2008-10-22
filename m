From: Jeff Garzik <jgarzik@pobox.com>
Subject: Re: [PATCH] 8139x: reduce message severity on driver overlap
Date: Wed, 22 Oct 2008 07:01:42 -0400
Message-ID: <48FF0816.6000303@pobox.com>
References: <20081021180427.6d4668d7@extreme>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Francois Romieu <romieu@fr.zoreil.com>, netdev@vger.kernel.org
To: Stephen Hemminger <shemminger@vyatta.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from srv5.dvmed.net ([207.36.208.214]:40075 "EHLO mail.dvmed.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753344AbYJVLBr (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 22 Oct 2008 07:01:47 -0400
In-Reply-To: <20081021180427.6d4668d7@extreme>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Stephen Hemminger wrote:
> The 8139 drivers are a source of error messages that confuse users.
> Since this device can not be disambiguated by normal PCI device id's two drivers
> match the same info. But the module utilities seem to correctly handle this overlap,
> they try one driver, then if that doesn't load try the other. Therefore there is
> no need for a message to be logged with error level severity, just using info
> level instead. Can't be completely silent because user might have configure one driver
> and forgot the other one.
> 
> Signed-off-by: Stephen Hemminger <shemminger@vyatta.com>
> 
> --- a/drivers/net/8139cp.c	2008-10-21 17:51:23.000000000 -0700
> +++ b/drivers/net/8139cp.c	2008-10-21 17:58:00.000000000 -0700
> @@ -1836,10 +1836,9 @@ static int cp_init_one (struct pci_dev *
>  
>  	if (pdev->vendor == PCI_VENDOR_ID_REALTEK &&
>  	    pdev->device == PCI_DEVICE_ID_REALTEK_8139 && pdev->revision < 0x20) {
> -		dev_err(&pdev->dev,
> -			   "This (id %04x:%04x rev %02x) is not an 8139C+ compatible chip\n",
> +		dev_info(&pdev->dev,
> +			   "This (id %04x:%04x rev %02x) is not an 8139C+ compatible chip, use 8139too\n",
>  		           pdev->vendor, pdev->device, pdev->revision);
> -		dev_err(&pdev->dev, "Try the \"8139too\" driver instead.\n");
>  		return -ENODEV;
>  	}
>  
> --- a/drivers/net/8139too.c	2008-10-21 17:51:27.000000000 -0700
> +++ b/drivers/net/8139too.c	2008-10-21 17:58:01.000000000 -0700
> @@ -946,10 +946,9 @@ static int __devinit rtl8139_init_one (s
>  	if (pdev->vendor == PCI_VENDOR_ID_REALTEK &&
>  	    pdev->device == PCI_DEVICE_ID_REALTEK_8139 && pdev->revision >= 0x20) {
>  		dev_info(&pdev->dev,
> -			   "This (id %04x:%04x rev %02x) is an enhanced 8139C+ chip\n",
> +			   "This (id %04x:%04x rev %02x) is an enhanced 8139C+ chip, use 8139cp\n",
>  		       	   pdev->vendor, pdev->device, pdev->revision);
> -		dev_info(&pdev->dev,
> -			   "Use the \"8139cp\" driver for improved performance and stability.\n");
> +		return -ENODEV;
>  	}
>  
>  	if (pdev->vendor == PCI_VENDOR_ID_REALTEK &&

applied


