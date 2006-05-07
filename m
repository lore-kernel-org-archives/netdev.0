From: Michael Buesch <mb@bu3sch.de>
Subject: Re: Associate on 'ifconfig up'
Date: Sun, 7 May 2006 15:06:06 +0200
Message-ID: <200605071506.06552.mb@bu3sch.de>
References: <1146847107.2766.13.camel@pmac.infradead.org> <1146939849.2503.108.camel@shinybook.infradead.org>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: bcm43xx-dev@lists.berlios.de, netdev@vger.kernel.org,
	David Woodhouse <dwmw2@infradead.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from static-ip-62-75-166-246.inaddr.intergenia.de ([62.75.166.246]:63942
	"EHLO bu3sch.de") by vger.kernel.org with ESMTP id S932146AbWEGM7W
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Sun, 7 May 2006 08:59:22 -0400
To: linville@tuxdriver.com
In-Reply-To: <1146939849.2503.108.camel@shinybook.infradead.org>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Saturday 06 May 2006 20:24, David Woodhouse wrote:
> On Fri, 2006-05-05 at 17:38 +0100, David Woodhouse wrote:
> > I still need this hack to work around the fact that softmac doesn't
> > attempt to associate when we bring the device up...
> 
> It'd be quite good to get this fixed in 2.6.17 too. Otherwise, the
> device doesn't manage to associate if you use the fairly common sequence
> of iwconfig then dhclient.
> 
> It's a bit of an evil hack and it should really be fixed in softmac --
> but it's only moving an _existing_ hack from one place in the driver to
> another.
> 
> Signed-off-by: David Woodhouse <dwmw2@infradead.org>

Signed-off-by: Michael Buesch <mb@bu3sch.de>

John, please try to push this before 2.6.17.
Thanks.

> --- linux-2.6.16.ppc/drivers/net/wireless/bcm43xx/bcm43xx_main.c.orig	2006-05-05 17:14:26.000000000 +0100
> +++ linux-2.6.16.ppc/drivers/net/wireless/bcm43xx/bcm43xx_main.c	2006-05-05 17:15:19.000000000 +0100
> @@ -3263,6 +3263,9 @@ static int bcm43xx_init_board(struct bcm
>  	bcm43xx_sysfs_register(bcm);
>  	//FIXME: check for bcm43xx_sysfs_register failure. This function is a bit messy regarding unwinding, though...
>  
> +	/*FIXME: This should be handled by softmac instead. */
> +	schedule_work(&bcm->softmac->associnfo.work);
> +
>  	assert(err == 0);
>  out:
>  	return err;
> @@ -3937,9 +3940,6 @@ static int bcm43xx_resume(struct pci_dev
>  
>  	netif_device_attach(net_dev);
>  	
> -	/*FIXME: This should be handled by softmac instead. */
> -	schedule_work(&bcm->softmac->associnfo.work);
> -
>  	dprintk(KERN_INFO PFX "Device resumed.\n");
>  
>  	return 0;
> 

-- 
Greetings Michael.
