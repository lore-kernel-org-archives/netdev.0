From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 04/12] phylib: add a way to make PHY time stamps
 possible.
Date: Wed, 16 Jun 2010 18:03:41 -0700 (PDT)
Message-ID: <20100616.180341.242128217.davem@davemloft.net>
References: <cover.1276615626.git.richard.cochran@omicron.at>
	<27c0ad283f025c2bb71e7ceb71be07f969939429.1276615626.git.richard.cochran@omicron.at>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linuxppc-dev@lists.ozlabs.org,
	devicetree-discuss@lists.ozlabs.org, khc@pm.waw.pl,
	linux-arm-kernel@lists.infradead.org
To: richardcochran@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:56253
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1752089Ab0FQBDa (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 16 Jun 2010 21:03:30 -0400
In-Reply-To: <27c0ad283f025c2bb71e7ceb71be07f969939429.1276615626.git.richard.cochran@omicron.at>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Richard Cochran <richardcochran@gmail.com>
Date: Tue, 15 Jun 2010 18:08:20 +0200

> +static inline void skb_tx_timetamp(struct phy_device *phy, struct sk_buff *skb)
> +{
> +	union skb_shared_tx *shtx = skb_tx(skb);
> +
> +	if (shtx->hardware && phy && phy->drv->txtstamp)
> +		phy->drv->txtstamp(phy, skb);
> +
> +	if (shtx->software && !shtx->in_progress)
> +		skb_tstamp_tx(skb, NULL);
> +}
> +
> +static inline void skb_rx_timetamp(struct phy_device *phy, struct sk_buff *skb)
> +{
> +	if (phy && phy->drv->rxtstamp)
> +		phy->drv->rxtstamp(phy, skb);
> +}

Since, as you say, this can provide a way to deal with the sw TX
timestamping sequencing problem we have right now, I'd rather
you implement this from the inside out instead of from the
outside in.

By this I mean you should provide these inline helpers by default
then we can begin to put them into the drivers.

You could also split the SW tstamp handling into a seperate inline
function, which drivers call immediately once they know they will
actually give the packet to the hardware for sending.
