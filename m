From: Andrew Lunn <andrew@lunn.ch>
Subject: Re: [PATCH] net: mv643xx_eth: ensure coalesce settings survive
 read-modify-write
Date: Tue, 1 Nov 2016 12:10:23 +0100
Message-ID: <20161101111023.GA4211@lunn.ch>
References: <E1c1Wdl-0000tO-Ql@rmk-PC.armlinux.org.uk>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Sebastian Hesselbarth <sebastian.hesselbarth@gmail.com>,
        netdev@vger.kernel.org
To: Russell King <rmk+kernel@armlinux.org.uk>
Return-path: <netdev-owner@vger.kernel.org>
Received: from vps0.lunn.ch ([178.209.37.122]:59739 "EHLO vps0.lunn.ch"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1168733AbcKALK0 (ORCPT <rfc822;netdev@vger.kernel.org>);
        Tue, 1 Nov 2016 07:10:26 -0400
Content-Disposition: inline
In-Reply-To: <E1c1Wdl-0000tO-Ql@rmk-PC.armlinux.org.uk>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Nov 01, 2016 at 10:50:01AM +0000, Russell King wrote:
> The coalesce settings behave badly when changing just one value:
> 
> ... # ethtool -c eth0
> rx-usecs: 249
> ... # ethtool -C eth0 tx-usecs 250
> ... # ethtool -c eth0
> rx-usecs: 248
> 
> This occurs due to rounding errors when calculating the microseconds
> value - the divisons round down.  This causes (eg) the rx-usecs to
> decrease by one every time the tx-usecs value is set as per the above.
> 
> Fix this by making the divison round-to-nearest.
> 
> Signed-off-by: Russell King <rmk+kernel@armlinux.org.uk>

Reviewed-by: Andrew Lunn <andrew@lunn.ch>

    Andrew
