From: Jeff Garzik <jeff@garzik.org>
Subject: Re: [PATCH] e100: Use pci_pme_active to clear PME_Status and disable
 PME#
Date: Sat, 13 Sep 2008 16:15:56 -0400
Message-ID: <48CC1F7C.7050908@garzik.org>
References: <200808051730.27599.alessandro.guido@gmail.com> <200808080000.07156.rjw@sisk.pl> <200808080014.25493.rjw@sisk.pl> <200808080018.05887.rjw@sisk.pl>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Jesse Barnes <jbarnes@virtuousgeek.org>,
	Alessandro Guido <alessandro.guido@gmail.com>,
	linux-kernel@vger.kernel.org, netdev@vger.kernel.org,
	pm list <linux-pm@lists.linux-foundation.org>
To: "Rafael J. Wysocki" <rjw@sisk.pl>
Return-path: <netdev-owner@vger.kernel.org>
Received: from srv5.dvmed.net ([207.36.208.214]:34873 "EHLO mail.dvmed.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752625AbYIMUQH (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sat, 13 Sep 2008 16:16:07 -0400
In-Reply-To: <200808080018.05887.rjw@sisk.pl>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Rafael J. Wysocki wrote:
> e100: Use pci_pme_active to clear PME_Status and disable PME#
> 
> Signed-off-by: Rafael J. Wysocki <rjw@sisk.pl>
> 
> ---
>  drivers/net/e100.c |    4 +---
>  1 file changed, 1 insertion(+), 3 deletions(-)
> 
> Index: linux-2.6/drivers/net/e100.c
> ===================================================================
> --- linux-2.6.orig/drivers/net/e100.c
> +++ linux-2.6/drivers/net/e100.c
> @@ -2738,9 +2738,7 @@ static int __devinit e100_probe(struct p
>  		nic->flags |= wol_magic;
>  
>  	/* ack any pending wake events, disable PME */
> -	err = pci_enable_wake(pdev, 0, 0);
> -	if (err)
> -		DPRINTK(PROBE, ERR, "Error clearing wake event\n");
> +	pci_pme_active(pdev, false);

Since I am rusty on my PCI...  why is this needed?


