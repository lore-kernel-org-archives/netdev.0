From: Valentine <vbarshak@ru.mvista.com>
Subject: Re: [PATCH] pasemi_mac: ethtool get settings fix
Date: Mon, 05 Oct 2009 16:59:07 +0400
Message-ID: <4AC9ED9B.5040400@ru.mvista.com>
References: <20091001222748.GA21276@ru.mvista.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: linuxppc-dev@ozlabs.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from ru.mvista.com ([213.79.90.228]:27764 "EHLO
	buildserver.ru.mvista.com" rhost-flags-OK-FAIL-OK-FAIL)
	by vger.kernel.org with ESMTP id S1753582AbZJEM7k (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 5 Oct 2009 08:59:40 -0400
In-Reply-To: <20091001222748.GA21276@ru.mvista.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Resending pasemi_mac ethtool patches...

Valentine Barshak wrote:
> Not all pasemi mac interfaces can have a phy attached.
> For example, XAUI has no phy and phydev is NULL for it.
> In this case ethtool get settings causes kernel crash.
> Fix it by returning -EOPNOTSUPP if there's no PHY attached.
> 
> Signed-off-by: Valentine Barshak <vbarshak@ru.mvista.com>
> ---
>  drivers/net/pasemi_mac_ethtool.c |    2 ++
>  1 file changed, 2 insertions(+)
> 
> --- linux-2.6.21.orig/drivers/net/pasemi_mac_ethtool.c	2008-11-06 18:10:38.000000000 +0300
> +++ linux-2.6.21/drivers/net/pasemi_mac_ethtool.c	2008-11-19 19:24:28.000000000 +0300
> @@ -71,6 +71,8 @@ pasemi_mac_ethtool_get_settings(struct n
>  	struct pasemi_mac *mac = netdev_priv(netdev);
>  	struct phy_device *phydev = mac->phydev;
>  
> +	if (!phydev)
> +		return -EOPNOTSUPP;
>  	return phy_ethtool_gset(phydev, cmd);
>  }
>  
> _______________________________________________
> Linuxppc-dev mailing list
> Linuxppc-dev@lists.ozlabs.org
> https://lists.ozlabs.org/listinfo/linuxppc-dev

