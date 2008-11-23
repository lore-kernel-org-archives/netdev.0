From: Jeff Garzik <jeff@garzik.org>
Subject: Re: [PATCH] 8139too: use err.h macros
Date: Sun, 23 Nov 2008 13:36:45 -0500
Message-ID: <20081123183645.GA11340@havoc.gtf.org>
References: <20081123102237.42cc99dd@extreme>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Francois Romieu <romieu@fr.zoreil.com>,
	David Miller <davem@davemloft.net>, netdev@vger.kernel.org
To: Stephen Hemminger <shemminger@linux-foundation.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from havoc.gtf.org ([69.61.125.42]:52680 "EHLO havoc.gtf.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751407AbYKWSgr (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sun, 23 Nov 2008 13:36:47 -0500
Content-Disposition: inline
In-Reply-To: <20081123102237.42cc99dd@extreme>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sun, Nov 23, 2008 at 10:22:37AM -0800, Stephen Hemminger wrote:
> Instead of using call by reference use the PTR_ERR macros to handle
> return value with error case. Compile tested only.
> 
> Signed-off-by: Stephen Hemminger <shemminger@vyatta.com>
> 
> --- a/drivers/net/8139too.c	2008-11-23 10:16:26.000000000 -0800
> +++ b/drivers/net/8139too.c	2008-11-23 10:19:05.000000000 -0800
> @@ -741,8 +741,7 @@ static void rtl8139_chip_reset (void __i
>  }
>  
>  
> -static int __devinit rtl8139_init_board (struct pci_dev *pdev,
> -					 struct net_device **dev_out)
> +static __devinit struct net_device * rtl8139_init_board (struct pci_dev *pdev)
>  {
>  	void __iomem *ioaddr;
>  	struct net_device *dev;

I won't NAK this, but I do wonder why a solution based on yucky
magic typecasting is preferred...?

	Jeff



