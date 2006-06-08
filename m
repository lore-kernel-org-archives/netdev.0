From: Jeff Garzik <jeff@garzik.org>
Subject: Re: [PATCH 2/2] PHYLIB/gianfar: Use phy_ethtool_get_link() for	get_link
 op
Date: Thu, 08 Jun 2006 10:58:22 -0400
Message-ID: <44883B0E.5090802@garzik.org>
References: <1149551334.10700.48.camel@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Andy Fleming <afleming@freescale.com>, netdev@vger.kernel.org,
	galak@kernel.crashing.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from srv5.dvmed.net ([207.36.208.214]:31436 "EHLO mail.dvmed.net")
	by vger.kernel.org with ESMTP id S964853AbWFHO60 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 8 Jun 2006 10:58:26 -0400
To: Nathaniel Case <ncase@xes-inc.com>
In-Reply-To: <1149551334.10700.48.camel@localhost.localdomain>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Nathaniel Case wrote:
> This patch makes the gianfar ethtool code use phy_ethtool_get_link() instead of
> ethtool_op_get_link().
> 
> Patch depends on previous one (1/2).
> 
> Signed-off-by: Nate Case <ncase@xes-inc.com>
> 
> ---
> 
> --- a/drivers/net/gianfar_ethtool.c	2006-06-05 11:27:19.000000000 -0500
> +++ b/drivers/net/gianfar_ethtool.c	2006-06-04 19:31:01.000000000 -0500
> @@ -228,6 +228,18 @@
>  		buf[i] = gfar_read(&theregs[i]);
>  }
>  
> +static u32 gfar_get_link(struct net_device *dev)
> +{
> +	struct gfar_private *priv = netdev_priv(dev);
> +	struct phy_device *phydev = priv->phydev;
> +
> +	if (NULL == phydev)
> +		return -ENODEV;

NAK, return code obviously wrong


