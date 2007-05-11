From: Kumar Gala <galak@kernel.crashing.org>
Subject: Re: [PATCH] phylib: phy_ethtool_{sset,gset} -- check phydev for NULL
Date: Fri, 11 May 2007 08:18:43 -0500
Message-ID: <0DF2860D-0764-4AD1-B8B9-205827FF28E3@kernel.crashing.org>
References: <8496f91a0705101029g794ee4a7t1c6a34ad13444c49@mail.gmail.com> <20070510105613.f564e083.randy.dunlap@oracle.com> <46436215.7030503@garzik.org> <8496f91a0705110358v2e6d9b7el19856eadd55ac596@mail.gmail.com>
Mime-Version: 1.0 (Apple Message framework v752.2)
Content-Type: text/plain; charset=US-ASCII; delsp=yes; format=flowed
Content-Transfer-Encoding: 7bit
Cc: "Jeff Garzik" <jeff@garzik.org>,
	"Randy Dunlap" <randy.dunlap@oracle.com>, netdev@vger.kernel.org
To: matvejchikov@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from nommos.sslcatacombnetworking.com ([67.18.224.114]:28720 "EHLO
	nommos.sslcatacombnetworking.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1757414AbXEKNTe (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 11 May 2007 09:19:34 -0400
In-Reply-To: <8496f91a0705110358v2e6d9b7el19856eadd55ac596@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


On May 11, 2007, at 5:58 AM, Matvejchikov Ilya wrote:

> Signed-off-by: Matvejchikov Ilya <matvejchikov@gmail.com>
> ---
>
> diff -purN linux-2.6.21-clean/drivers/net/phy/phy.c
> linux-2.6.21/drivers/net/phy/phy.c
> --- linux-2.6.21-clean/drivers/net/phy/phy.c	2007-04-26  
> 07:08:32.000000000 +0400
> +++ linux-2.6.21/drivers/net/phy/phy.c	2007-05-04  
> 08:22:01.000000000 +0400
> @@ -245,6 +245,9 @@ EXPORT_SYMBOL(phy_sanitize_settings);
>  */
> int phy_ethtool_sset(struct phy_device *phydev, struct ethtool_cmd  
> *cmd)
> {
> +	if (unlikely(!phydev))
> +		return -EINVAL;

Should this be -ENODEV?

> +
> 	if (cmd->phy_address != phydev->addr)
> 		return -EINVAL;
>
> @@ -289,6 +292,9 @@ EXPORT_SYMBOL(phy_ethtool_sset);
>
> int phy_ethtool_gset(struct phy_device *phydev, struct ethtool_cmd  
> *cmd)
> {
> +	if (unlikely(!phydev))
> +		return -EINVAL;

same question.

> +
> 	cmd->supported = phydev->supported;
>
> 	cmd->advertising = phydev->advertising;
> -
> To unsubscribe from this list: send the line "unsubscribe netdev" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html

