From: Russell King - ARM Linux <linux@armlinux.org.uk>
Subject: Re: [PATCH net-next 10/18] net: mvpp2: use the GoP interrupt for
 link status changes
Date: Wed, 26 Jul 2017 20:38:20 +0100
Message-ID: <20170726193820.GR31807@n2100.armlinux.org.uk>
References: <20170724134848.19330-1-antoine.tenart@free-electrons.com>
 <20170724134848.19330-11-antoine.tenart@free-electrons.com>
 <20170726162648.GK12049@lunn.ch>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Antoine Tenart <antoine.tenart@free-electrons.com>,
        davem@davemloft.net, jason@lakedaemon.net,
        gregory.clement@free-electrons.com,
        sebastian.hesselbarth@gmail.com,
        thomas.petazzoni@free-electrons.com, nadavh@marvell.com,
        mw@semihalf.com, stefanc@marvell.com, netdev@vger.kernel.org,
        linux-arm-kernel@lists.infradead.org
To: Andrew Lunn <andrew@lunn.ch>
Return-path: <netdev-owner@vger.kernel.org>
Received: from pandora.armlinux.org.uk ([78.32.30.218]:43826 "EHLO
        pandora.armlinux.org.uk" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751022AbdGZTil (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 26 Jul 2017 15:38:41 -0400
Content-Disposition: inline
In-Reply-To: <20170726162648.GK12049@lunn.ch>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Jul 26, 2017 at 06:26:48PM +0200, Andrew Lunn wrote:
> And this is another bit of code you probably need to change in a while
> with phylink lands.

The way the MAC driver handles link up/down and configuration events
changes significantly when a MAC driver switches to phylink, since
a directly connected SFP cage needs to have the MAC reconfigured
between SGMII and 1000base-X modes.  If you add SFP+ into that, also
10Gbase-KR as well.

Note also that the "link up" condition for SFP (and probably SFF) is
more complex than just "is the module reporting that it's receiving
a signal" - especially with 1000base-X, there's negotiation to be
performed, so you also need to know (if the module is connected
directly to the MAC) whether the Serdes is in sync and has finished
negotiation (and itself says it has link with the remote end.)

With the Marvell 88x3310 PHY, the MAC driver already needs to switch
between 10Gbase-KR and SGMII modes, as the 88x3310 automatically
makes that switch on its MAC facing interface without software
intervention.

-- 
RMK's Patch system: http://www.armlinux.org.uk/developer/patches/
FTTC broadband for 0.8mile line: currently at 9.6Mbps down 400kbps up
according to speedtest.net.
