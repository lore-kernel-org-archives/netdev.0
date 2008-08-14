From: Jeff Garzik <jeff@garzik.org>
Subject: Re: AX88796: Fix locking in ethtool support
Date: Thu, 14 Aug 2008 04:44:38 -0400
Message-ID: <48A3F076.8080206@garzik.org>
References: <20080807162109.360877609@fluff.org.uk>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Ben Dooks <ben-linux@fluff.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from srv5.dvmed.net ([207.36.208.214]:52765 "EHLO mail.dvmed.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752471AbYHNIom (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 14 Aug 2008 04:44:42 -0400
In-Reply-To: <20080807162109.360877609@fluff.org.uk>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Ben Dooks wrote:
> Fix a pair of nasty locking problems in the ax88796 driver
> spotted by a sparse check:
> 
> warning: context imbalance in 'ax_get_settings' - wrong count at exit
> warning: context imbalance in 'ax_set_settings' - wrong count at exit
> 
> Signed-off-by: Ben Dooks <ben-linux@fluff.org>
> 
> Index: linux-2.6.27-rc2-quilt1/drivers/net/ax88796.c
> ===================================================================
> --- linux-2.6.27-rc2-quilt1.orig/drivers/net/ax88796.c	2008-08-07 17:15:01.000000000 +0100
> +++ linux-2.6.27-rc2-quilt1/drivers/net/ax88796.c	2008-08-07 17:17:45.000000000 +0100
> @@ -554,7 +554,7 @@ static int ax_get_settings(struct net_de
>  
>  	spin_lock_irqsave(&ax->mii_lock, flags);
>  	mii_ethtool_gset(&ax->mii, cmd);
> -	spin_lock_irqsave(&ax->mii_lock, flags);
> +	spin_unlock_irqrestore(&ax->mii_lock, flags);
>  
>  	return 0;
>  }
> @@ -567,7 +567,7 @@ static int ax_set_settings(struct net_de
>  
>  	spin_lock_irqsave(&ax->mii_lock, flags);
>  	rc = mii_ethtool_sset(&ax->mii, cmd);
> -	spin_lock_irqsave(&ax->mii_lock, flags);
> +	spin_unlock_irqrestore(&ax->mii_lock, flags);

applied


