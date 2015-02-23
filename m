From: Guenter Roeck <linux@roeck-us.net>
Subject: Re: [RFT PATCH 1/2] net: dsa: mv88e6xxx: Add EEE support
Date: Mon, 23 Feb 2015 10:52:45 -0800
Message-ID: <20150223185245.GB23456@roeck-us.net>
References: <1424708770-3135-1-git-send-email-linux@roeck-us.net>
 <54EB671D.3000707@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, "David S. Miller" <davem@davemloft.net>,
	Andrew Lunn <andrew@lunn.ch>, linux-kernel@vger.kernel.org
To: Florian Fainelli <f.fainelli@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from bh-25.webhostbox.net ([208.91.199.152]:57717 "EHLO
	bh-25.webhostbox.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752284AbbBWSwu (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 23 Feb 2015 13:52:50 -0500
Received: from mailnull by bh-25.webhostbox.net with sa-checked (Exim 4.82)
	(envelope-from <linux@roeck-us.net>)
	id 1YPy7d-003IGU-9F
	for netdev@vger.kernel.org; Mon, 23 Feb 2015 18:52:49 +0000
Content-Disposition: inline
In-Reply-To: <54EB671D.3000707@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Feb 23, 2015 at 09:45:01AM -0800, Florian Fainelli wrote:
> On 23/02/15 08:26, Guenter Roeck wrote:
> > EEE configuration is similar for the various MV88E6xxx chips.
> > Add generic support for it.
> > 
> > Signed-off-by: Guenter Roeck <linux@roeck-us.net>
> 
> Reviewed-by: Florian Fainelli <f.fainelli@gmail.com>
> 
> > ---
> > Applies to net-next.
> > 
> > The code seems to be working, at least according to ethtool, but some
> > more testing with other chip types would be useful. Also, I am not sure
> > what to do with phy_init_eee.
> 
> phy_init_eee() is to be used in case you have a PHY which is not managed
> by the switch indirect or direct accesses, it looks like you are just
> fine with the current code.
> 
> One possible improvement could be ironing out the EEE
> enabling/resolution by ensuring that the link partner also supports EEE?
> Not sure if there is an existing register returning that from the
> switch, or if you need to do a direct read to the PHY?
> 

EEE configuration on Marvell switches is independent from link partner
capabilities. In the hardware available to me, EEE is enabled by
default with a strapping pin on the chip. Making it dependent on link
partner capabilities would be odd because it would mean that, if the
link is down or if the link partner doesn't support it, it could be
disabled, but it could no longer be re-enabled. This is what
phy_init_eee enforces today. I dropped calling it because I thought
that this behavior would be odd and inconsistent.

Question for me is if it makes sense to have phy_init_eee depend on
the link status or on link partner capabilities in the first place.
Personally I think it should only depend on local PHY capabilities,
and that it should be possible to configure EEE even if the link
is down or if the (current) link partner doesn't support it.

Consider the following: Assume both ends are configured to have EEE
disabled, even if the PHYs support it. Both ends run linux and call
phy_init_eee() to check for EEE capabilities. I have not tested it,
but I suspect that it is not currently possible to enable EEE on either
end because both ends believe that the link partner doesn't support it.
I'll test that theory once I get a system where I can control both ends.

Thanks,
Guenter
