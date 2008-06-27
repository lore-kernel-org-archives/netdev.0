From: Jeff Garzik <jeff@garzik.org>
Subject: Re: [PATCH] tc35815: Mark carrier-off before starting PHY
Date: Fri, 27 Jun 2008 01:34:03 -0400
Message-ID: <48647BCB.80700@garzik.org>
References: <20080625.114101.102912128.nemoto@toshiba-tops.co.jp>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: linux-mips@linux-mips.org, netdev@vger.kernel.org
To: Atsushi Nemoto <anemo@mba.ocn.ne.jp>
Return-path: <netdev-owner@vger.kernel.org>
Received: from srv5.dvmed.net ([207.36.208.214]:38894 "EHLO mail.dvmed.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753911AbYF0FeH (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 27 Jun 2008 01:34:07 -0400
In-Reply-To: <20080625.114101.102912128.nemoto@toshiba-tops.co.jp>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Atsushi Nemoto wrote:
> Call netif_carrier_off() before starting PHY device.  This is a
> behavior before converting to generic PHY layer.
> 
> Signed-off-by: Atsushi Nemoto <anemo@mba.ocn.ne.jp>
> ---
> diff --git a/drivers/net/tc35815.c b/drivers/net/tc35815.c
> index 10e4e85..dccea52 100644
> --- a/drivers/net/tc35815.c
> +++ b/drivers/net/tc35815.c
> @@ -1394,6 +1394,7 @@ tc35815_open(struct net_device *dev)
>  	tc35815_chip_init(dev);
>  	spin_unlock_irq(&lp->lock);
>  
> +	netif_carrier_off(dev);
>  	/* schedule a link state check */
>  	phy_start(lp->phy_dev);
>  
> @@ -2453,6 +2454,7 @@ static int tc35815_resume(struct pci_dev *pdev)
>  		return 0;
>  	pci_set_power_state(pdev, PCI_D0);
>  	tc35815_restart(dev);
> +	netif_carrier_off(dev);
>  	if (lp->phy_dev)

applied


