From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 3/5] lan78xx: update to use phylib
Date: Tue, 15 Sep 2015 14:46:38 -0700 (PDT)
Message-ID: <20150915.144638.155213100283923532.davem@davemloft.net>
References: <9235D6609DB808459E95D78E17F2E43D557D9F@CHN-SV-EXMX02.mchp-main.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: f.fainelli@gmail.com, netdev@vger.kernel.org
To: Woojung.Huh@microchip.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:54046 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751415AbbIOVql (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 15 Sep 2015 17:46:41 -0400
In-Reply-To: <9235D6609DB808459E95D78E17F2E43D557D9F@CHN-SV-EXMX02.mchp-main.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: <Woojung.Huh@microchip.com>
Date: Thu, 10 Sep 2015 22:16:11 +0000

> @@ -1287,42 +1074,30 @@ static int lan78xx_set_wol(struct net_device *netdev,
>  static int lan78xx_get_eee(struct net_device *net, struct ethtool_eee *edata)
>  {
>  	struct lan78xx_net *dev = netdev_priv(net);
> +	struct phy_device *phydev = net->phydev;
>  	int ret;
>  	u32 buf;
> -	u32 adv, lpadv;
>  
>  	ret = usb_autopm_get_interface(dev->intf);
>  	if (ret < 0)
>  		return ret;
>  
> +	ret = phy_ethtool_get_eee(phydev, edata);
> +	if (ret)
> +		return ret;
> +

You cannot return directly if phy_ethtool_get_eee() returns an error,
you must branch to the end of this function and properly perform
the usb_autopm_get_interface().
