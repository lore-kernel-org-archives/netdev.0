From: Russell King - ARM Linux <linux@armlinux.org.uk>
Subject: Re: [PATCH net] net: phy: Decrement phy_fixed_addr during unregister
Date: Fri, 24 Jun 2016 23:55:27 +0100
Message-ID: <20160624225527.GA1041@n2100.armlinux.org.uk>
References: <1466808251-19588-1-git-send-email-f.fainelli@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, davem@davemloft.net, andrew@lunn.ch,
	thomas.petazzoni@free-electrons.com
To: Florian Fainelli <f.fainelli@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from pandora.armlinux.org.uk ([78.32.30.218]:51379 "EHLO
	pandora.armlinux.org.uk" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750876AbcFXWzh (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 24 Jun 2016 18:55:37 -0400
Content-Disposition: inline
In-Reply-To: <1466808251-19588-1-git-send-email-f.fainelli@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, Jun 24, 2016 at 03:44:11PM -0700, Florian Fainelli wrote:
> If we have a system which uses fixed PHY devices and calls
> fixed_phy_register() then fixed_phy_unregister() we can exhaust the
> number of fixed PHYs available after a while, since we keep incrementing
> the variable phy_fixed_addr, but we never decrement it.
> 
> This patch fixes that by decrementing phy_fixed_addr during
> fixed_phy_del(), and in order to do that, we need to move the
> phy_fixed_addr integer and its spinlock above that function.

Is this really a good idea?

What if we have two fixed phys register, and the first one is
unregistered and a new one subsequently registered?

First phy registered, gets address 0, phy_fixed_addr becomes 1.
Second phy registered, gets address 1, phy_fixed_addr becomes 2.
First phy is unregistered, phy_fixed_addr becomes 1.
Third phy registered, gets address 1, conflicts with the second phy.

Obviously not a good outcome.

-- 
RMK's Patch system: http://www.armlinux.org.uk/developer/patches/
FTTC broadband for 0.8mile line: currently at 9.6Mbps down 400kbps up
according to speedtest.net.
