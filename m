From: Richard Cochran <richardcochran@gmail.com>
Subject: Re: [PATCH 0/4] Extend Time Stamping
Date: Wed, 30 Jun 2010 08:28:06 +0200
Message-ID: <20100630062806.GA3646@riccoc20.at.omicron.at>
References: <cover.1277737222.git.richard.cochran@omicron.at>
 <20100629.153134.25136559.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from fg-out-1718.google.com ([72.14.220.153]:13576 "EHLO
	fg-out-1718.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751847Ab0F3F2E (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 30 Jun 2010 01:28:04 -0400
Received: by fg-out-1718.google.com with SMTP id 22so49342fge.1
        for <netdev@vger.kernel.org>; Tue, 29 Jun 2010 22:28:03 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <20100629.153134.25136559.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Jun 29, 2010 at 03:31:34PM -0700, David Miller wrote:
> --------------------
> By this I mean you should provide these inline helpers by default
> then we can begin to put them into the drivers.
> --------------------
> 
> This means no config option.

Okay, but what about the PHY time stamping hooks?

I anticipate that people will complain about the "performance penalty"
of these extra checks in a critical path.

Richard


static inline void phy_tx_timestamp(struct phy_device *phy, struct sk_buff *skb)
{
	union skb_shared_tx *shtx = skb_tx(skb);
	if (shtx->hardware && phy && phy->drv->txtstamp)
	   phy->drv->txtstamp(phy, skb);
}

static inline void phy_rx_timestamp(struct phy_device *phy, struct sk_buff *skb)
{
	if (phy && phy->drv->rxtstamp)
	   phy->drv->rxtstamp(phy, skb);
}

