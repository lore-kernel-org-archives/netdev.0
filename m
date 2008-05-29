From: Jeff Garzik <jeff@garzik.org>
Subject: Re: [PATCH 2/2] 8139too: Make the OQO2 automatically use PIO mode.
Date: Thu, 29 May 2008 14:21:02 -0400
Message-ID: <483EF40E.7030802@garzik.org>
References: <20080429171403.GA21035@redhat.com> <48177905.4000409@garzik.org> <20080429215626.GC2859@redhat.com> <48179B56.7000606@garzik.org> <20080429153240.7200e1a3.akpm@linux-foundation.org> <4818546C.4060703@garzik.org> <20080529150849.GC8247@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Andrew Morton <akpm@linux-foundation.org>, netdev@vger.kernel.org
To: Dave Jones <davej@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from srv5.dvmed.net ([207.36.208.214]:37644 "EHLO mail.dvmed.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1758460AbYE2SVQ (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 29 May 2008 14:21:16 -0400
In-Reply-To: <20080529150849.GC8247@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Dave Jones wrote:
> The OQO model 2 has an RTL8139 from Atheros that doesn't like MMIO.
> Force it to always use polled IO.
> 
> Signed-off-by: Dave Jones <davej@redhat.com>
> 
> --- linux-2.6.25.noarch/drivers/net/8139too.c~	2008-05-28 21:07:36.000000000 -0400
> +++ linux-2.6.25.noarch/drivers/net/8139too.c	2008-05-28 21:19:57.000000000 -0400
> @@ -951,6 +951,14 @@ static int __devinit rtl8139_init_one (s
>  			   "Use the \"8139cp\" driver for improved performance and stability.\n");
>  	}
>  
> +	if (pdev->vendor == PCI_VENDOR_ID_REALTEK &&
> +	    pdev->device == PCI_DEVICE_ID_REALTEK_8139 &&
> +	    pdev->subsystem_vendor == PCI_VENDOR_ID_ATHEROS &&
> +	    pdev->subsystem_device == PCI_DEVICE_ID_REALTEK_8139) {
> +		printk(KERN_INFO "8139too: OQO Model 2 detected. Forcing PIO\n");
> +		use_pio = 1;
> +	}
> +

these days we almost never hand-craft PCI ID checks like this...  Add 
this to the pci_device_id table, and create a new RTL8139_PIO entry for 
driver_data that has your desired end result

That way, it is trivial to expand the list simply by updating the PCI ID 
table

Table-driven approaches are really superior for things like this




