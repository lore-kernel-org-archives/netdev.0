From: Francois Romieu <romieu@fr.zoreil.com>
Subject: Re: [RFT] Realtek 8168 ethernet support
Date: Fri, 2 Jun 2006 00:24:37 +0200
Message-ID: <20060601222436.GA12054@electric-eye.fr.zoreil.com>
References: <20060601200200.A0E0689D05D@zog.reactivated.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from electric-eye.fr.zoreil.com ([213.41.134.224]:54498 "EHLO
	fr.zoreil.com") by vger.kernel.org with ESMTP id S1750746AbWFAW2j
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 1 Jun 2006 18:28:39 -0400
To: Daniel Drake <dsd@gentoo.org>
Content-Disposition: inline
In-Reply-To: <20060601200200.A0E0689D05D@zog.reactivated.net>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Daniel Drake <dsd@gentoo.org> :
[...]
> @@ -1442,20 +1444,24 @@ rtl8169_init_board(struct pci_dev *pdev,
>  		}
>  	}
>  
> -	/* make sure PCI base addr 1 is MMIO */
> -	if (!(pci_resource_flags(pdev, 1) & IORESOURCE_MEM)) {
> -		if (netif_msg_probe(tp)) {
> -			printk(KERN_ERR PFX
> -			       "region #1 not an MMIO resource, aborting\n");
> -		}
> -		rc = -ENODEV;
> -		goto err_out_mwi;
> +	/* find MMIO resource: this varies between 8168 and 8169 */
> +	for (i = 0; i < 5; i++) {

I'd rather use pci_device_id->driver_data but it's an option.

Btw a 0x8167 may be encountered too.

A diff between latest versions of Realtek's code suggests that 
rtl_chip_info and mac_info need an update as well.

-- 
Ueimor
