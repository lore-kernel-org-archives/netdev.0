From: Andy Fleming <afleming@freescale.com>
Subject: Re: [PATCH] Stop phy code from returning success to unknown ioctls.
Date: Tue, 4 Dec 2007 14:00:42 -0600
Message-ID: <8D34458A-2CE9-4FA7-AE28-4D148E08CCDF@freescale.com>
References: <1196273071.30806.46.camel@pmac.infradead.org> <1196279794.30806.54.camel@pmac.infradead.org>
Mime-Version: 1.0 (Apple Message framework v752.2)
Content-Type: text/plain; charset=US-ASCII; delsp=yes; format=flowed
Content-Transfer-Encoding: 7bit
Cc: jgarzik@pobox.com, linuxppc-dev@ozlabs.org,
	Domen Puncer <domen.puncer@telargo.com>,
	Grant Likely <grant.likely@secretlab.ca>,
	netdev@vger.kernel.org
To: David Woodhouse <dwmw2@infradead.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from az33egw02.freescale.net ([192.88.158.103]:60929 "EHLO
	az33egw02.freescale.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751519AbXLDUCk (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 4 Dec 2007 15:02:40 -0500
In-Reply-To: <1196279794.30806.54.camel@pmac.infradead.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


On Nov 28, 2007, at 13:56, David Woodhouse wrote:

> This kind of sucks, and prevents the Fedora installer from using the
> device for network installs...
>
> [root@efika phy]# iwconfig eth0
> Warning: Driver for device eth0 has been compiled with an ancient  
> version
> of Wireless Extension, while this program support version 11 and  
> later.
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

d'oh!

Acked-by: Andy Fleming <afleming@freescale.com>


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
>  	return 0;
>
> -- 
> dwmw2
>
> -
> To unsubscribe from this list: send the line "unsubscribe netdev" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html

