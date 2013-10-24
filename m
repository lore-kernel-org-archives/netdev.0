From: Joe Perches <joe@perches.com>
Subject: Re: [PATCH net-next] ns83820: printk() cleanup
Date: Thu, 24 Oct 2013 15:38:39 -0700
Message-ID: <1382654319.22433.88.camel@joe-AO722>
References: <1382651106-24550-1-git-send-email-Luke.Christopher.Jones@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="ISO-8859-1"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, "Luke C. Jones" <jonesl4@rpi.edu>
To: "Luke C. Jones" <luke.christopher.jones@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtprelay0005.hostedemail.com ([216.40.44.5]:33558 "EHLO
	smtprelay.hostedemail.com" rhost-flags-OK-OK-OK-FAIL)
	by vger.kernel.org with ESMTP id S1754267Ab3JXWio (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 24 Oct 2013 18:38:44 -0400
In-Reply-To: <1382651106-24550-1-git-send-email-Luke.Christopher.Jones@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 2013-10-24 at 21:45 +0000, Luke C. Jones wrote:
> In an effort to bring all printk calls up to style standards,
> added log levels to printk calls.
[]
> diff --git a/drivers/net/ethernet/natsemi/ns83820.c b/drivers/net/ethernet/natsemi/ns83820.c
[]
> @@ -1580,7 +1580,7 @@ static void ns83820_tx_timeout(struct net_device *ndev)
>  	{
>  		u32 isr;
>  		isr = readl(dev->base + ISR);
> -		printk("irq: %08x imr: %08x\n", isr, dev->IMR_cache);
> +		printk(KERN_DEBUG "irq: %08x imr: %08x\n", isr, dev->IMR_cache);

netdev_dbg(ndev, etc...)

> @@ -1603,7 +1603,7 @@ static void ns83820_tx_watch(unsigned long data)
>  	struct ns83820 *dev = PRIV(ndev);
>  
>  #if defined(DEBUG)
> -	printk("ns83820_tx_watch: %u %u %d\n",
> +	printk(KERN_DEBUG "ns83820_tx_watch: %u %u %d\n",
>  		dev->tx_done_idx, dev->tx_free_idx, atomic_read(&dev->nr_tx_skbs)
>  		);

netdev_dbg()

>  #endif
> @@ -2026,7 +2026,7 @@ static int ns83820_init_one(struct pci_dev *pci_dev,
>  		goto out_free_irq;
>  	}
>  
> -	printk("%s: ns83820.c: 0x22c: %08x, subsystem: %04x:%04x\n",
> +	printk(KERN_INFO "%s: ns83820.c: 0x22c: %08x, subsystem: %04x:%04x\n",
>  		ndev->name, le32_to_cpu(readl(dev->base + 0x22c)),
>  		pci_dev->subsystem_vendor, pci_dev->subsystem_device);
>  

netdev_info()
