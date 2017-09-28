From: Andrew Lunn <andrew@lunn.ch>
Subject: Re: [PATCH] Add a driver for Renesas uPD60620 and uPD60620A PHYs
Date: Fri, 29 Sep 2017 00:59:29 +0200
Message-ID: <20170928225929.GC19710@lunn.ch>
References: <AM5PR0701MB26574EBBE4E7CACC9173B345E4670@AM5PR0701MB2657.eurprd07.prod.outlook.com>
 <20170922175918.GD3470@lunn.ch>
 <ca1763c4-fb7b-cf49-6bcf-d9e2c29c7363@hotmail.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
        Florian Fainelli <f.fainelli@gmail.com>
To: Bernd Edlinger <bernd.edlinger@hotmail.de>
Return-path: <netdev-owner@vger.kernel.org>
Received: from vps0.lunn.ch ([185.16.172.187]:60542 "EHLO vps0.lunn.ch"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1750821AbdI1W7b (ORCPT <rfc822;netdev@vger.kernel.org>);
        Thu, 28 Sep 2017 18:59:31 -0400
Content-Disposition: inline
In-Reply-To: <ca1763c4-fb7b-cf49-6bcf-d9e2c29c7363@hotmail.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Bernd

> >> +	if (phy_state & BMSR_ANEGCOMPLETE) {
> > 
> > It is worth comparing this against genphy_read_status() which is the
> > reference implementation. You would normally check if auto negotiation
> > is enabled, not if it has completed. If it is enabled you read the
> > current negotiated state, even if it is not completed.
> > 
> 
> Do you suggest that there are cases where auto negotiation does not
> reach completion, and still provides a usable link status?

My experience is that it often return 10/half, since everything should
support that. And depending on what the MAC is doing, packets can
sometime get across the link.
 
> I have tried to connect to link partners with fixed configuration
> but even then the auto negotiation always competes normally.

Which is a bit odd.

There are a few different possibilities here.  The peer PHY driver is
broken. Rather than doing fixed, it actually set the possible
negotiation options to just the one setting you tried to fix it
to. And hence the uPD60620 device negotiated fine. Or the uPD60620 is
broken is said it negotiated, but in fact it failed.

What was the result? 10/Half, or the fixed values you set the peer to?
 
> 
> >From 2e101aed8466b314251972d1eaccfb43cf177078 Mon Sep 17 00:00:00 2001
> From: Bernd Edlinger <bernd.edlinger@hotmail.de>
> Date: Thu, 21 Sep 2017 15:46:16 +0200
> Subject: [PATCH 2/5] Add a driver for Renesas uPD60620 and uPD60620A PHYs.
> 
> Signed-off-by: Bernd Edlinger <bernd.edlinger@hotmail.de>

Please send this is a new patch. If we were to take this is is, all
the comments above would end up in the commit message.

> ---

Under the --- you can however add comments which don't go into the
commit log. Good practice is to list the things you changed since the
previous version.

Thanks
	Andrew
