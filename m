From: Jeff Garzik <jgarzik@pobox.com>
Subject: Re: [PATCH 1/1 resend][arm/at91_ether.c]  logical/bitand typo in
 function reset_phy() (inactive), drivers/net/arm/at91_ether.c
Date: Wed, 30 Jan 2008 03:39:03 -0500
Message-ID: <47A037A7.4050102@pobox.com>
References: <479F8940.7030301@tiscali.nl>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: andrew@sanpeople.com, netdev@vger.kernel.org,
	linux-arm-kernel@lists.arm.linux.org.uk
To: Roel Kluin <12o3l@tiscali.nl>
Return-path: <netdev-owner@vger.kernel.org>
Received: from srv5.dvmed.net ([207.36.208.214]:47042 "EHLO mail.dvmed.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754457AbYA3IjT (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 30 Jan 2008 03:39:19 -0500
In-Reply-To: <479F8940.7030301@tiscali.nl>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Roel Kluin wrote:
> include/linux/mii.h:48:#define BMCR_RESET 0x8000
> 
> The function reset_phy() is in "#if 0" inactivated code
> --
> Replace logical "&&" by bit "&" before BMCR_RESET
> 
> Signed-off-by: Roel Kluin <12o3l@tiscali.nl>
> ---
> diff --git a/drivers/net/arm/at91_ether.c b/drivers/net/arm/at91_ether.c
> index 25b114a..0ae0d83 100644
> --- a/drivers/net/arm/at91_ether.c
> +++ b/drivers/net/arm/at91_ether.c
> @@ -384,7 +384,7 @@ static void reset_phy(struct net_device *dev)
>  	/* Wait until PHY reset is complete */
>  	do {
>  		read_phy(lp->phy_address, MII_BMCR, &bmcr);
> -	} while (!(bmcr && BMCR_RESET));
> +	} while (!(bmcr & BMCR_RESET));
>  
>  	disable_mdi();
>  	spin_unlock_irq(&lp->lock);

applied


