From: Joe Perches <joe@perches.com>
Subject: Re: [PATCH net-next 1/6] epic100: replace printk with netdev_ calls
Date: Thu, 24 Oct 2013 23:41:06 -0700
Message-ID: <1382683266.2068.13.camel@joe-AO722>
References: <1382682422-22677-1-git-send-email-mathstuf@gmail.com>
	 <1382682422-22677-2-git-send-email-mathstuf@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="ISO-8859-1"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Ben Boeckel <mathstuf@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtprelay0032.hostedemail.com ([216.40.44.32]:54371 "EHLO
	smtprelay.hostedemail.com" rhost-flags-OK-OK-OK-FAIL)
	by vger.kernel.org with ESMTP id S1751192Ab3JYGlJ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 25 Oct 2013 02:41:09 -0400
In-Reply-To: <1382682422-22677-2-git-send-email-mathstuf@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, 2013-10-25 at 02:26 -0400, Ben Boeckel wrote:
> Signed-off-by: Ben Boeckel <mathstuf@gmail.com>

Hi Ben.

Please run your patches through checkpatch.pl

> diff --git a/drivers/net/ethernet/smsc/epic100.c b/drivers/net/ethernet/smsc/epic100.c
[]
> @@ -490,7 +488,7 @@ static int epic_init_one(struct pci_dev *pdev, const struct pci_device_id *ent)
>  	if (ret < 0)
>  		goto err_out_unmap_rx;
>  
> -	printk(KERN_INFO "%s: %s at %lx, IRQ %d, %pM\n",
> +	netdev_info(dev, "%s: %s at %lx, IRQ %d, %pM\n",
>  	       dev->name, pci_id_tbl[chip_idx].name,
>  	       (long)pci_resource_start(pdev, EPIC_BAR), pdev->irq,
>  	       dev->dev_addr);

Please align the subsequent lines to the open parenthesis
and this conversion would now emit dev->name twice.

Try:
	netdev_info(dev, "%s at %lx, IRQ %d, %pM\n",
		    pci_id_tbl[chip_idx].name,
		    (long)pci_resource_start(pdev, EPIC_BAR),
		    pdev->irq, dev->dev_addr);

> @@ -703,7 +701,7 @@ static int epic_open(struct net_device *dev)
>  			mdio_write(dev, ep->phys[0], MII_BMCR, media2miictl[dev->if_port&15]);
>  		if (dev->if_port == 1) {
>  			if (debug > 1)
> -				printk(KERN_INFO "%s: Using the 10base2 transceiver, MII "
> +				netdev_info(dev, "%s: Using the 10base2 transceiver, MII "
>  					   "status %4.4x.\n",

Please coalesce the format fragments into a single line.

>  					   dev->name, mdio_read(dev, ep->phys[0], MII_BMSR));

same problem with duplicate dev->name

etc.
