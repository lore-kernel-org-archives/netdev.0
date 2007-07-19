From: Kumar Gala <galak@kernel.crashing.org>
Subject: Re: [PATCH 1/2] Fix error checking in Vitesse IRQ config
Date: Thu, 19 Jul 2007 14:57:15 -0500
Message-ID: <AC7300C2-1041-4D80-A8FE-1568C770821D@kernel.crashing.org>
References: <11847405503115-git-send-email-afleming@freescale.com>
Mime-Version: 1.0 (Apple Message framework v752.2)
Content-Type: text/plain; charset=US-ASCII; delsp=yes; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev <netdev@vger.kernel.org>,
	"linuxppc-dev@ozlabs.org list" <linuxppc-dev@ozlabs.org>,
	Andy Fleming <afleming@freescale.com>
To: Jeff Garzik <jeff@garzik.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from gate.crashing.org ([63.228.1.57]:34599 "EHLO gate.crashing.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751590AbXGST4y (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 19 Jul 2007 15:56:54 -0400
In-Reply-To: <11847405503115-git-send-email-afleming@freescale.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


On Jul 18, 2007, at 1:35 AM, Andy Fleming wrote:

> phy_read() returns a negative number if there's an error, but the
> error-checking code in the Vitesse driver's config_intr function
> triggers if phy_read() returns non-zero.  Correct that.
>
> Signed-off-by: Andy Fleming <afleming@freescale.com>

Jeff,

Can you make sure to send this to linus since its need to properly  
fix the Vitesse phy's used on the 8641HPCN and 8544 DS boards.

thanks

- k

> ---
> I made a really stupid mistake in the 4 patches I sent out,  
> earlier.  I
> thought those patches had been tested, but they hadn't been.  This one
> corrects a tiny error in the patch, and they have now been tested.   
> As before
> this change can be pulled from:
>
> http://opensource.freescale.com/pub/scm/linux-2.6-85xx.git netdev
>
> Really, REALLY sorry about that.  I have been given a paper bag of  
> appropriate
> size and shape to fit over my head.
>
>  drivers/net/phy/vitesse.c |    2 +-
>  1 files changed, 1 insertions(+), 1 deletions(-)
>
> diff --git a/drivers/net/phy/vitesse.c b/drivers/net/phy/vitesse.c
> index 6a53856..8874497 100644
> --- a/drivers/net/phy/vitesse.c
> +++ b/drivers/net/phy/vitesse.c
> @@ -109,7 +109,7 @@ static int vsc824x_config_intr(struct  
> phy_device *phydev)
>  		 */
>  		err = phy_read(phydev, MII_VSC8244_ISTAT);
>
> -		if (err)
> +		if (err < 0)
>  			return err;
>
>  		err = phy_write(phydev, MII_VSC8244_IMASK, 0);
> -- 
> 1.5.0.2.230.gfbe3d-dirty
>
> -
> To unsubscribe from this list: send the line "unsubscribe netdev" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html

