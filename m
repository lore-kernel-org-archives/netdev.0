From: Sam Ravnborg <sam@ravnborg.org>
Subject: Re: [2.6 patch] atm/suni.c: fix section mismatch
Date: Sat, 19 Jan 2008 14:29:04 +0100
Message-ID: <20080119132904.GC26615@uranus.ravnborg.org>
References: <20080119131851.GB8669@does.not.exist>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: chas@cmf.nrl.navy.mil, jgarzik@pobox.com, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: Adrian Bunk <bunk@kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from pasmtpa.tele.dk ([80.160.77.114]:42558 "EHLO pasmtpA.tele.dk"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1758987AbYASN25 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sat, 19 Jan 2008 08:28:57 -0500
Content-Disposition: inline
In-Reply-To: <20080119131851.GB8669@does.not.exist>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sat, Jan 19, 2008 at 03:18:51PM +0200, Adrian Bunk wrote:
> EXPORT_SYMBOL'ed code mustn't be __*init.
> 
> Signed-off-by: Adrian Bunk <bunk@kernel.org>
Acked-by: Sam Ravnborg <sam@ravnborg.org>
> 
> ---
> --- linux-2.6/drivers/atm/suni.c.old	2008-01-19 12:16:41.000000000 +0200
> +++ linux-2.6/drivers/atm/suni.c	2008-01-19 12:17:23.000000000 +0200
> @@ -275,35 +275,35 @@ static int suni_stop(struct atm_dev *dev
>  	*walk = PRIV((*walk)->dev)->next;
>  	if (!sunis) del_timer_sync(&poll_timer);
>  	spin_unlock_irqrestore(&sunis_lock,flags);
>  	kfree(PRIV(dev));
>  
>  	return 0;
>  }
>  
>  
>  static const struct atmphy_ops suni_ops = {
>  	.start		= suni_start,
>  	.ioctl		= suni_ioctl,
>  	.interrupt	= suni_int,
>  	.stop		= suni_stop,
>  };
>  
>  
> -int __devinit suni_init(struct atm_dev *dev)
> +int suni_init(struct atm_dev *dev)
>  {
>  	unsigned char mri;
>  
>  	mri = GET(MRI); /* reset SUNI */
>  	PUT(mri | SUNI_MRI_RESET,MRI);
>  	PUT(mri,MRI);
>  	PUT((GET(MT) & SUNI_MT_DS27_53),MT); /* disable all tests */
>  	REG_CHANGE(SUNI_TPOP_APM_S,SUNI_TPOP_APM_S_SHIFT,SUNI_TPOP_S_SONET,
>  	    TPOP_APM); /* use SONET */
>  	REG_CHANGE(SUNI_TACP_IUCHP_CLP,0,SUNI_TACP_IUCHP_CLP,
>  	    TACP_IUCHP); /* idle cells */
>  	PUT(SUNI_IDLE_PATTERN,TACP_IUCPOP);
>  	dev->phy = &suni_ops;
>  	return 0;
>  }
>  
>  EXPORT_SYMBOL(suni_init);
> 
> --
> To unsubscribe from this list: send the line "unsubscribe netdev" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
