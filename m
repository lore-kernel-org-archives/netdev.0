From: Andrew Lunn <andrew@lunn.ch>
Subject: Re: [PATCH RFC 08/13] phylink: add phylink infrastructure
Date: Tue, 1 Aug 2017 16:34:46 +0200
Message-ID: <20170801143446.GG23157@lunn.ch>
References: <20170725140138.GK31807@n2100.armlinux.org.uk>
 <E1da0Qb-0007Lq-FJ@rmk-PC.armlinux.org.uk>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Florian Fainelli <f.fainelli@gmail.com>, netdev@vger.kernel.org
To: Russell King <rmk+kernel@arm.linux.org.uk>
Return-path: <netdev-owner@vger.kernel.org>
Received: from vps0.lunn.ch ([178.209.37.122]:47917 "EHLO vps0.lunn.ch"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1751631AbdHAOes (ORCPT <rfc822;netdev@vger.kernel.org>);
        Tue, 1 Aug 2017 10:34:48 -0400
Content-Disposition: inline
In-Reply-To: <E1da0Qb-0007Lq-FJ@rmk-PC.armlinux.org.uk>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Jul 25, 2017 at 03:03:13PM +0100, Russell King wrote:
> The link between the ethernet MAC and its PHY has become more complex
> as the interface evolves.  This is especially true with serdes links,
> where the part of the PHY is effectively integrated into the MAC.
> 
> Serdes links can be connected to a variety of devices, including SFF
> modules soldered down onto the board with the MAC, a SFP cage with
> a hotpluggable SFP module which may contain a PHY or directly modulate
> the serdes signals onto optical media with or without a PHY, or even
> a classical PHY connection.
> 
> Moreover, the negotiation information on serdes links comes in two
> varieties - SGMII mode, where the PHY provides its speed/duplex/flow
> control information to the MAC, and 1000base-X mode where both ends
> exchange their abilities and each resolve the link capabilities.
> 
> This means we need a more flexible means to support these arrangements,
> particularly with the hotpluggable nature of SFP, where the PHY can
> be attached or detached after the network device has been brought up.
> 
> Ethtool information can come from multiple sources:
> - we may have a PHY operating in either SGMII or 1000base-X mode, in
>   which case we take ethtool/mii data directly from the PHY.
> - we may have a optical SFP module without a PHY, with the MAC
>   operating in 1000base-X mode - the ethtool/mii data needs to come
>   from the MAC.
> - we may have a copper SFP module with a PHY whic can't be accessed,
>   which means we need to take ethtool/mii data from the MAC.
> 
> Phylink aims to solve this by providing an intermediary between the
> MAC and PHY, providing a safe way for PHYs to be hotplugged, and
> allowing a SFP driver to reconfigure the serdes connection.
> 
> Phylink also takes over support of fixed link connections, where the
> speed/duplex/flow control are fixed, but link status may be controlled
> by a GPIO signal.  By avoiding the fixed-phy implementation, phylink
> can provide a faster response to link events: fixed-phy has to wait for
> phylib to operate its state machine, which can take several seconds.
> In comparison, phylink takes milliseconds.
> 
> Signed-off-by: Russell King <rmk+kernel@arm.linux.org.uk>

Reviewed-by: Andrew Lunn <andrew@lunn.ch>

    Andrew
