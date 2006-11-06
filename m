From: Michael Buesch <mb@bu3sch.de>
Subject: Re: [PATCH] bcm43xx: Add error checking in bcm43xx_sprom_write()
Date: Mon, 6 Nov 2006 17:38:21 +0100
Message-ID: <200611061738.21918.mb@bu3sch.de>
References: <454F5960.mailHVB136L2I@lwfinger.net>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
Cc: John Linville <linville@tuxdriver.com>, bunk@stusta.de,
	netdev@vger.kernel.org, Bcm43xx-dev@lists.berlios.de,
	Stefano Brivio <st3@riseup.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from static-ip-62-75-166-246.inaddr.intergenia.de ([62.75.166.246]:39335
	"EHLO bu3sch.de") by vger.kernel.org with ESMTP id S1753409AbWKFQjs
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 6 Nov 2006 11:39:48 -0500
To: Larry Finger <Larry.Finger@lwfinger.net>
In-Reply-To: <454F5960.mailHVB136L2I@lwfinger.net>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Monday 06 November 2006 16:48, Larry Finger wrote:
> From: Adrian Bunk <bunk@stusta.de>
> 
> The Coverity checker noted that these "if (err)"'s couldn't ever be 
> true.
> 
> It seems the intention was to check the return values of the 
> bcm43xx_pci_write_config32()'s?

Whoops, I thought I had fixed this bug long time ago.
The patch is correct.

> Signed-off-by: Adrian Bunk <bunk@stusta.de>
> Signed-off-by: Larry Finger <Larry.Finger@lwfinger.net>

Signed-off-by: Michael Buesch <mb@bu3sch.de>

> Index: wireless-2.6/drivers/net/wireless/bcm43xx/bcm43xx_main.c
> ===================================================================
> --- wireless-2.6.orig/drivers/net/wireless/bcm43xx/bcm43xx_main.c
> +++ wireless-2.6/drivers/net/wireless/bcm43xx/bcm43xx_main.c
> @@ -750,7 +750,7 @@ int bcm43xx_sprom_write(struct bcm43xx_p
>  	if (err)
>  		goto err_ctlreg;
>  	spromctl |= 0x10; /* SPROM WRITE enable. */
> -	bcm43xx_pci_write_config32(bcm, BCM43xx_PCICFG_SPROMCTL, spromctl);
> +	err = bcm43xx_pci_write_config32(bcm, BCM43xx_PCICFG_SPROMCTL, spromctl);
>  	if (err)
>  		goto err_ctlreg;
>  	/* We must burn lots of CPU cycles here, but that does not
> @@ -772,7 +772,7 @@ int bcm43xx_sprom_write(struct bcm43xx_p
>  		mdelay(20);
>  	}
>  	spromctl &= ~0x10; /* SPROM WRITE enable. */
> -	bcm43xx_pci_write_config32(bcm, BCM43xx_PCICFG_SPROMCTL, spromctl);
> +	err = bcm43xx_pci_write_config32(bcm, BCM43xx_PCICFG_SPROMCTL, spromctl);
>  	if (err)
>  		goto err_ctlreg;
>  	mdelay(500);
> 

-- 
Greetings Michael.
