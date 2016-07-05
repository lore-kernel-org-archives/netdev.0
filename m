From: Francois Romieu <romieu@fr.zoreil.com>
Subject: Re: [PATCH net-next 3/9] net: r6040: Utilize skb_put_padto()
Date: Wed, 6 Jul 2016 00:44:55 +0200
Message-ID: <20160705224455.GA29178@electric-eye.fr.zoreil.com>
References: <1467668169-31547-1-git-send-email-f.fainelli@gmail.com>
 <1467668169-31547-4-git-send-email-f.fainelli@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, davem@davemloft.net
To: Florian Fainelli <f.fainelli@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from violet.fr.zoreil.com ([92.243.8.30]:53137 "EHLO
	violet.fr.zoreil.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751111AbcGEWpA (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 5 Jul 2016 18:45:00 -0400
Content-Disposition: inline
In-Reply-To: <1467668169-31547-4-git-send-email-f.fainelli@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Florian Fainelli <f.fainelli@gmail.com> :
[...]
> diff --git a/drivers/net/ethernet/rdc/r6040.c b/drivers/net/ethernet/rdc/r6040.c
> index 75776eee36f9..46ed093348da 100644
> --- a/drivers/net/ethernet/rdc/r6040.c
> +++ b/drivers/net/ethernet/rdc/r6040.c
> @@ -815,6 +815,9 @@ static netdev_tx_t r6040_start_xmit(struct sk_buff *skb,
>  	void __iomem *ioaddr = lp->base;
>  	unsigned long flags;
>  
> +	if (skb_put_padto(skb, ETH_ZLEN) < 0)
> +		return NETDEV_TX_OK;
> +

Missing dev->stats->tx_dropped++.

-- 
Ueimor
