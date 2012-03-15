From: "Michael Chan" <mchan@broadcom.com>
Subject: Re: [PATCH net-next 17/34] bnx2: stop using
 net_device.{base_addr, irq}.
Date: Thu, 15 Mar 2012 13:47:39 -0700
Message-ID: <1331844459.5136.83.camel@LTIRV-MCHAN1.corp.ad.broadcom.com>
References: <cover.1331814082.git.romieu@fr.zoreil.com>
 <13067b771f01e58a2f09e0fb3041cd41dcae6c21.1331814082.git.romieu@fr.zoreil.com>
Mime-Version: 1.0
Content-Type: text/plain;
 charset=cp1252
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, "David Miller" <davem@davemloft.net>
To: "Francois Romieu" <romieu@fr.zoreil.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mms2.broadcom.com ([216.31.210.18]:2097 "EHLO mms2.broadcom.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1161383Ab2COUrx (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 15 Mar 2012 16:47:53 -0400
In-Reply-To: <13067b771f01e58a2f09e0fb3041cd41dcae6c21.1331814082.git.romieu@fr.zoreil.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 2012-03-15 at 14:57 +0100, Francois Romieu wrote:
> @@ -8480,22 +8469,21 @@ bnx2_init_one(struct pci_dev *pdev, const
> struct pci_device_id *ent)
>                 goto error;
>         }
>  
> -       netdev_info(dev, "%s (%c%d) %s found at mem %lx, IRQ %d, node
> addr %pM\n",
> -                   board_info[ent->driver_data].name,
> +       netdev_info(dev, "%s (%c%d) %s found at mem %p, IRQ %d, "
> +                   "node addr %pM\n",
> board_info[ent->driver_data].name,
>                     ((CHIP_ID(bp) & 0xf000) >> 12) + 'A',
>                     ((CHIP_ID(bp) & 0x0ff0) >> 4),
> -                   bnx2_bus_string(bp, str),
> -                   dev->base_addr,
> -                   bp->pdev->irq, dev->dev_addr);
> +                   bnx2_bus_string(bp, str), bp->regview,

I think we should either remove the string "found at mem %lx", or keep
it the same as before by using pci_resource_start(pdev, 0) to display
the BAR address.  Changing it to display the mapped kernel address is
not useful to the user.

> +                   pdev->irq, dev->dev_addr);
>  
>         return 0;
>  
>  error:
> -       if (bp->regview)
> -               iounmap(bp->regview);
> +       iounmap(bp->regview);
>         pci_release_regions(pdev);
>         pci_disable_device(pdev);
>         pci_set_drvdata(pdev, NULL);
> +err_free:
>         free_netdev(dev);
>         return rc;
>  } 
