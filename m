From: "pradeep singh" <pradeep.rautela@gmail.com>
Subject: Re: [PATCH 1/2] Fix error checking in Vitesse IRQ config
Date: Wed, 18 Jul 2007 12:30:37 +0530
Message-ID: <a901b49a0707180000g1c107323ub6c95a6ef3b5b2fe@mail.gmail.com>
References: <11847405503115-git-send-email-afleming@freescale.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linuxppc-dev@ozlabs.org
To: "Andy Fleming" <afleming@freescale.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from py-out-1112.google.com ([64.233.166.183]:64439 "EHLO
	py-out-1112.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751758AbXGRHAi (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 18 Jul 2007 03:00:38 -0400
Received: by py-out-1112.google.com with SMTP id d32so185378pye
        for <netdev@vger.kernel.org>; Wed, 18 Jul 2007 00:00:37 -0700 (PDT)
In-Reply-To: <11847405503115-git-send-email-afleming@freescale.com>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 7/18/07, Andy Fleming <afleming@freescale.com> wrote:
> phy_read() returns a negative number if there's an error, but the
> error-checking code in the Vitesse driver's config_intr function
> triggers if phy_read() returns non-zero.  Correct that.
>
> Signed-off-by: Andy Fleming <afleming@freescale.com>
> ---
> I made a really stupid mistake in the 4 patches I sent out, earlier.  I
> thought those patches had been tested, but they hadn't been.  This one
> corrects a tiny error in the patch, and they have now been tested.  As before
> this change can be pulled from:
>
> http://opensource.freescale.com/pub/scm/linux-2.6-85xx.git netdev
>
> Really, REALLY sorry about that.  I have been given a paper bag of appropriate
> size and shape to fit over my head.
>
>  drivers/net/phy/vitesse.c |    2 +-
>  1 files changed, 1 insertions(+), 1 deletions(-)
>
> diff --git a/drivers/net/phy/vitesse.c b/drivers/net/phy/vitesse.c
> index 6a53856..8874497 100644
> --- a/drivers/net/phy/vitesse.c
> +++ b/drivers/net/phy/vitesse.c
> @@ -109,7 +109,7 @@ static int vsc824x_config_intr(struct phy_device *phydev)
>                  */
>                 err = phy_read(phydev, MII_VSC8244_ISTAT);
>
> -               if (err)
> +               if (err < 0)
>                         return err;

but would that mean, if phy_read returns > 0 it is a success?

thanks
>
>                 err = phy_write(phydev, MII_VSC8244_IMASK, 0);
> --
> 1.5.0.2.230.gfbe3d-dirty
>
> -
> To unsubscribe from this list: send the line "unsubscribe netdev" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
>


-- 
Pradeep
