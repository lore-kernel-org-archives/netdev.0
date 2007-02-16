From: Ben Dooks <ben@fluff.org.uk>
Subject: Re: [PATCH] dm9000: do not kfree() netdevice
Date: Fri, 16 Feb 2007 09:56:47 +0000
Message-ID: <20070216095647.GA24236@fluff.org.uk>
References: <20070212120539.GA31390@fluff.org.uk>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: rmk@arm.linux.org.uk
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 87-194-8-8.bethere.co.uk ([87.194.8.8]:57187 "EHLO
	aeryn.fluff.org.uk" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1945918AbXBPJ4s (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 16 Feb 2007 04:56:48 -0500
Content-Disposition: inline
In-Reply-To: <20070212120539.GA31390@fluff.org.uk>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Mon, Feb 12, 2007 at 12:05:39PM +0000, Ben Dooks wrote:
> The DM9000 network driver is calling kfree() on an netdev
> causing the system to oops if the probe fails. The right
> thing to do is call free_netdev().
> 
> Thanks to Russell King for spotting this.
> 
> Signed-off-by: Ben Dooks <ben-linux@fluff.org>
> 
> diff -urpN -X ../dontdiff linux-2.6.20/drivers/net/dm9000.c linux-2.6.20-dmfix/drivers/net/dm9000.c
> --- linux-2.6.20/drivers/net/dm9000.c	2007-02-04 18:44:54.000000000 +0000
> +++ linux-2.6.20-dmfix/drivers/net/dm9000.c	2007-02-12 12:01:22.000000000 +0000
> @@ -601,7 +601,7 @@ dm9000_probe(struct platform_device *pde
>  	printk("%s: not found (%d).\n", CARDNAME, ret);
>  
>  	dm9000_release_board(pdev, db);
> -	kfree(ndev);
> +	free_netdev(ndev);
>  
>  	return ret;
>  }
> @@ -1194,7 +1194,7 @@ dm9000_drv_remove(struct platform_device
>  
>  	unregister_netdev(ndev);
>  	dm9000_release_board(pdev, (board_info_t *) ndev->priv);
> -	kfree(ndev);		/* free device structure */
> +	free_netdev(ndev);		/* free device structure */
>  
>  	PRINTK1("clean_module() exit\n");

Do I need to send this patch to a particual person
to ensure that it gets included into the kernel?

-- 
Ben (ben@fluff.org, http://www.fluff.org/)

  'a smiley only costs 4 bytes'
