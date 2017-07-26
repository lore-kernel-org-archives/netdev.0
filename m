From: Andrew Lunn <andrew@lunn.ch>
Subject: Re: [PATCH net-next 10/18] net: mvpp2: use the GoP interrupt for
 link status changes
Date: Wed, 26 Jul 2017 18:26:48 +0200
Message-ID: <20170726162648.GK12049@lunn.ch>
References: <20170724134848.19330-1-antoine.tenart@free-electrons.com>
 <20170724134848.19330-11-antoine.tenart@free-electrons.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: davem@davemloft.net, jason@lakedaemon.net,
        gregory.clement@free-electrons.com,
        sebastian.hesselbarth@gmail.com,
        thomas.petazzoni@free-electrons.com, nadavh@marvell.com,
        linux@armlinux.org.uk, mw@semihalf.com, stefanc@marvell.com,
        netdev@vger.kernel.org, linux-arm-kernel@lists.infradead.org
To: Antoine Tenart <antoine.tenart@free-electrons.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from vps0.lunn.ch ([178.209.37.122]:41029 "EHLO vps0.lunn.ch"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1750867AbdGZQ04 (ORCPT <rfc822;netdev@vger.kernel.org>);
        Wed, 26 Jul 2017 12:26:56 -0400
Content-Disposition: inline
In-Reply-To: <20170724134848.19330-11-antoine.tenart@free-electrons.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Jul 24, 2017 at 03:48:40PM +0200, Antoine Tenart wrote:
> This patch adds the GoP link interrupt support for when a port isn't
> connected to a PHY. Because of this the phylib callback is never called
> and the link status management isn't done. This patch use the GoP link
> interrupt in such cases to still have a minimal link management. Without
> this patch ports not connected to a PHY cannot work.

Hi Antoine

When is a GoP link interrupt signalled? When is a port without a PHY
actually up/down?

With SFF/SFP ports, you generally need a gpio line the fibre module
can use to indicate if it has link. Fixed-phy has such support, and
your link_change function will get called when the link changes.

And this is another bit of code you probably need to change in a while
with phylink lands.

     Andrew
