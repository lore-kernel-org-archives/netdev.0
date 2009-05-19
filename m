From: Sergey Kononenko <sergk@sergk.org.ua>
Subject: Re: [IGB 2.6.29.3 bug] Re: WARNING at dev_disable_lro when enabling
 ip_forward
Date: Tue, 19 May 2009 23:46:29 +0300
Message-ID: <20090519234629.2b5f7550@vingilot.sergknet>
References: <20090519010147.772f0bff@vingilot.sergknet>
	<20090518.153531.126023429.davem@davemloft.net>
	<20090518155714.0f1a3b20@nehalam>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>, netdev@vger.kernel.org,
	jeffrey.t.kirsher@intel.com
To: Stephen Hemminger <shemminger@vyatta.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx3.hqhost.net ([80.77.80.130]:56936 "EHLO mail.hqhost.net"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1752701AbZESUqh (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 19 May 2009 16:46:37 -0400
In-Reply-To: <20090518155714.0f1a3b20@nehalam>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

> Does this fix it?
> 
> diff --git a/drivers/net/igb/igb_ethtool.c
> b/drivers/net/igb/igb_ethtool.c index 4bdfc2e..a425d85 100644
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
Yes, patch have fixed the problem. Thank you.

With best regards,
Sergey Kononenko.
