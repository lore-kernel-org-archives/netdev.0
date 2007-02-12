From: Benjamin Herrenschmidt <benh@kernel.crashing.org>
Subject: Re: [PATCH] [v3] spidernet : add improved phy support
Date: Tue, 13 Feb 2007 08:40:57 +1100
Message-ID: <1171316457.20192.21.camel@localhost.localdomain>
References: <200702122135.34417.jens@de.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: jgarzik@pobox.com, Linas Vepstas <linas@austin.ibm.com>,
	James K Lewis <jim@jklewis.com>,
	Ishizaki Kou <kou.ishizaki@toshiba.co.jp>,
	netdev@vger.kernel.org, cbe-oss-dev@ozlabs.org
To: Jens Osterkamp <jens@de.ibm.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from gate.crashing.org ([63.228.1.57]:35158 "EHLO gate.crashing.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1030189AbXBLVlo (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 12 Feb 2007 16:41:44 -0500
In-Reply-To: <200702122135.34417.jens@de.ibm.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


> +static int bcm5461_enable_fiber(struct mii_phy* phy, int autoneg)
> +{
> +	/* select fiber mode, enable 1000 base-X registers */
> +	phy_write(phy, MII_NCONFIG, 0xfc0b);
> +
> +	if (autoneg) {
> +		/* enable fiber with no autonegotiation */
> +		phy_write(phy, MII_ADVERTISE, 0x01e0);
> +		phy_write(phy, MII_BMCR, 0x1140);
> +	} else {
> +		/* enable fiber with autonegotiation */
> +		phy_write(phy, MII_BMCR, 0x0140);
> +	}
> +
> +	phy->autoneg = autoneg;
> +
> +	return 0;
> +}

Something is backward... either the code or the comments...

Also, I dislike the autoneg bits without using any constants. Why not
use the normal setup_aneg() ? I think what is needed is a set_link_mode
or something like that that takes (fiber/copper) as an argument (or
better, use the proper names as documented by the chip).

Doesn't matter to much right now, if the code works. Have you had a
chance to check you don't break G5s with 5421 sungem ? If yes, then the
patch is good to go for now but we should revisit and/or try to merge
that with the generic PHY layer at one point.

Ben.
 

