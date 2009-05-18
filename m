From: David Miller <davem@davemloft.net>
Subject: Re: [IGB 2.6.29.3 bug] Re: WARNING at dev_disable_lro when
 enabling ip_forward
Date: Mon, 18 May 2009 16:00:29 -0700 (PDT)
Message-ID: <20090518.160029.230477451.davem@davemloft.net>
References: <20090519010147.772f0bff@vingilot.sergknet>
	<20090518.153531.126023429.davem@davemloft.net>
	<20090518155714.0f1a3b20@nehalam>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: sergk@sergk.org.ua, netdev@vger.kernel.org,
	jeffrey.t.kirsher@intel.com
To: shemminger@vyatta.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:49525
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1754172AbZERXAc (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 18 May 2009 19:00:32 -0400
In-Reply-To: <20090518155714.0f1a3b20@nehalam>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Stephen Hemminger <shemminger@vyatta.com>
Date: Mon, 18 May 2009 15:57:14 -0700

> Does this fix it?

It should, but I think the ifdef is probably superfluous.

> diff --git a/drivers/net/igb/igb_ethtool.c b/drivers/net/igb/igb_ethtool.c
> index 4bdfc2e..a425d85 100644
> --- a/drivers/net/igb/igb_ethtool.c
> +++ b/drivers/net/igb/igb_ethtool.c
> @@ -2028,6 +2028,10 @@ static struct ethtool_ops igb_ethtool_ops = {
>  	.get_ethtool_stats      = igb_get_ethtool_stats,
>  	.get_coalesce           = igb_get_coalesce,
>  	.set_coalesce           = igb_set_coalesce,
> +#ifdef CONFIG_IGB_LRO
> +	.get_flags		= ethtool_op_get_flags,
> +	.set_flags		= ethtool_op_set_flags,
> +#endif
>  };
>  
>  void igb_set_ethtool_ops(struct net_device *netdev)
