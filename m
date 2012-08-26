From: Joe Perches <joe@perches.com>
Subject: Re: [PATCH] cs89x0 : packet reception not working
Date: Sun, 26 Aug 2012 15:26:01 -0700
Message-ID: <1346019961.2064.4.camel@joe2Laptop>
References: <1346017146-28248-1-git-send-email-jaccon.bastiaansen@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net, linux-arm-kernel@lists.infradead.org,
	netdev@vger.kernel.org, s.hauer@pengutronix.de, festevam@gmail.com
To: Jaccon Bastiaansen <jaccon.bastiaansen@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from perches-mx.perches.com ([206.117.179.246]:46357 "EHLO
	labridge.com" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1753327Ab2HZW0D (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sun, 26 Aug 2012 18:26:03 -0400
In-Reply-To: <1346017146-28248-1-git-send-email-jaccon.bastiaansen@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sun, 2012-08-26 at 23:39 +0200, Jaccon Bastiaansen wrote:
> The RxCFG register of the CS89x0 could be configured incorrectly
> (because of misplaced parentheses), resulting in the disabling
> of packet reception.

Thanks.

> diff --git a/drivers/net/ethernet/cirrus/cs89x0.c b/drivers/net/ethernet/cirrus/cs89x0.c
[]
> @@ -1261,10 +1261,10 @@ static void set_multicast_list(struct net_device *dev)
>  	 * so we have to enable interrupts on them also
>  	 */
>  	writereg(dev, PP_RxCFG,
> -		 (lp->curr_rx_cfg |
> -		  (lp->rx_mode == RX_ALL_ACCEPT)
> -		  ? (RX_CRC_ERROR_ENBL | RX_RUNT_ENBL | RX_EXTRA_DATA_ENBL)
> -		  : 0));
> +		 lp->curr_rx_cfg |
> +		 (lp->rx_mode == RX_ALL_ACCEPT
> +		 ? (RX_CRC_ERROR_ENBL | RX_RUNT_ENBL | RX_EXTRA_DATA_ENBL)
> +		 : 0));
>  	spin_unlock_irqrestore(&lp->lock, flags);
>  }

Perhaps it would be better to use something like:

	int cfg = lp->curr_rx_cfg;

	if (lp->rx_mode == RX_ALL_ACCEPT)
		cfg |= RX_CRC_ERROR_ENBL | RX_RUNT_ENBL | RX_EXTRA_DATA_ENBL;

	writereg(dev, PP_RxCFG, cfg);
