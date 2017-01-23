From: Andrew Lunn <andrew@lunn.ch>
Subject: Re: [PATCH] phy: marvell: remove conflicting initializer
Date: Mon, 23 Jan 2017 16:19:41 +0100
Message-ID: <20170123151941.GG10895@lunn.ch>
References: <20170123121905.3245589-1-arnd@arndb.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Florian Fainelli <f.fainelli@gmail.com>,
        "David S. Miller" <davem@davemloft.net>,
        Charles-Antoine Couret <charles-antoine.couret@nexvision.fr>,
        Clemens Gruber <clemens.gruber@pqgruber.com>,
        netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: Arnd Bergmann <arnd@arndb.de>
Return-path: <netdev-owner@vger.kernel.org>
Received: from vps0.lunn.ch ([178.209.37.122]:41693 "EHLO vps0.lunn.ch"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1750962AbdAWPTw (ORCPT <rfc822;netdev@vger.kernel.org>);
        Mon, 23 Jan 2017 10:19:52 -0500
Content-Disposition: inline
In-Reply-To: <20170123121905.3245589-1-arnd@arndb.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Jan 23, 2017 at 01:18:41PM +0100, Arnd Bergmann wrote:
> One line was apparently pasted incorrectly during a new feature patch:
> 
> drivers/net/phy/marvell.c:2090:15: error: initialized field overwritten [-Werror=override-init]
>    .features = PHY_GBIT_FEATURES,
> 
> I'm removing the extraneous line here to avoid the W=1 warning and restore
> the previous flags value, and I'm slightly reordering the lines for consistency
> to make it less likely to happen again in the future. The ordering in the
> array is still not the same as in the structure definition, instead I picked
> the order that is most common in this file and that seems to make more sense
> here.
> 
> Fixes: 0b04680fdae4 ("phy: marvell: Add support for temperature sensor")
> Signed-off-by: Arnd Bergmann <arnd@arndb.de>

Hi Arnd

Thanks for this. I found one bug in my code while testing due to
duplicate probe initialisation. I was surprised at the time the
compiler did not warn me. I didn't think to try W=1. Is there any
legitimate need to allow multiple initialisation of a field? Can this
warning be made always on instead of only W=1?

Reviewed-by: Andrew Lunn <andrew@lunn.ch>

    Andrew
