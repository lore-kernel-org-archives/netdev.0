From: Jeff Garzik <jgarzik@pobox.com>
Subject: Re: [PATCH] Stop phy code from returning success to unknown ioctls.
Date: Sat, 01 Dec 2007 16:36:03 -0500
Message-ID: <4751D3C3.5090908@pobox.com>
References: <1196273071.30806.46.camel@pmac.infradead.org> <1196279794.30806.54.camel@pmac.infradead.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: linuxppc-dev@ozlabs.org, Domen Puncer <domen.puncer@telargo.com>,
	Grant Likely <grant.likely@secretlab.ca>,
	netdev@vger.kernel.org, afleming@freescale.com
To: David Woodhouse <dwmw2@infradead.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from srv5.dvmed.net ([207.36.208.214]:32929 "EHLO mail.dvmed.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750969AbXLAVgM (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sat, 1 Dec 2007 16:36:12 -0500
In-Reply-To: <1196279794.30806.54.camel@pmac.infradead.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

David Woodhouse wrote:
> This kind of sucks, and prevents the Fedora installer from using the
> device for network installs...
> 
> [root@efika phy]# iwconfig eth0                                                                                                                
> Warning: Driver for device eth0 has been compiled with an ancient version                                                                      
> of Wireless Extension, while this program support version 11 and later.                                                                        
> Some things may be broken...                                                                                                                   
>                                                                                                                                                
> eth0        ESSID:off/any  Nickname:""                                                                                                         
>           NWID:0  Channel:0  Access Point: 00:00:BF:81:14:E0                                                                                   
>           Bit Rate:-1.08206e+06 kb/s   Sensitivity=0/0                                                                                         
>           RTS thr:off   Fragment thr:off                                                                                                       
>           Encryption key:<too big>                                                                                                             
>           Power Management:off                                                                                                                 
>                                                                                                                                                
> Signed-off-by: David Woodhouse <dwmw2@infradead.org>
> 
> diff --git a/drivers/net/phy/phy.c b/drivers/net/phy/phy.c
> index 9bc1177..7c9e6e3 100644
> --- a/drivers/net/phy/phy.c
> +++ b/drivers/net/phy/phy.c
> @@ -406,6 +406,9 @@ int phy_mii_ioctl(struct phy_device *phydev,
>  				&& phydev->drv->config_init)
>  			phydev->drv->config_init(phydev);
>  		break;
> +
> +	default:
> +		return -ENOTTY;
>  	}
>  

applied


