From: Russell King - ARM Linux <linux@armlinux.org.uk>
Subject: Re: [PATCH 1/5] net: phy: add 802.3 clause 45 support to phylib
Date: Fri, 2 Jun 2017 13:39:41 +0100
Message-ID: <20170602123940.GN22219@n2100.armlinux.org.uk>
References: <20170601102327.GF27796@n2100.armlinux.org.uk>
 <E1dGNJH-00043Y-Gl@rmk-PC.armlinux.org.uk>
 <34431c1b-025f-55e5-9f31-34e14493541b@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Andrew Lunn <andrew@lunn.ch>, netdev@vger.kernel.org
To: Florian Fainelli <f.fainelli@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from pandora.armlinux.org.uk ([78.32.30.218]:42952 "EHLO
        pandora.armlinux.org.uk" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751148AbdFBMjz (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 2 Jun 2017 08:39:55 -0400
Content-Disposition: inline
In-Reply-To: <34431c1b-025f-55e5-9f31-34e14493541b@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Jun 01, 2017 at 10:15:28AM -0700, Florian Fainelli wrote:
> On 06/01/2017 03:26 AM, Russell King wrote:
> > Add generic helpers for 802.3 clause 45 PHYs for >= 10Gbps support.
> > 
> > Signed-off-by: Russell King <rmk+kernel@armlinux.org.uk>
> > ---
> 
> > +	ctrl1 &= ~MDIO_CTRL1_SPEEDSEL;
> > +	/* PMA/PMD type selection is 1.7.5:0 not 1.7.3:0.  See 45.2.1.6.1. */
> > +	ctrl2 &= ~(MDIO_PMA_CTRL2_TYPE | 0x30);
> 
> You could add a define for this 0x30 to indicate that you are masking
> off the reserved bits (there are more entries that are reserved
> actually, but that would do for now).

They are not reserved according to 802.3-2015 and 802.3-2012:

802.3-2012: 45.2.1.6.1 PMA/PMD type selection (1.7.5:0)
802.3-2015: 45.2.1.6.3 PMA/PMD type selection (1.7.5:0)

which defines the type selection as occupying six bits, but the definition
in the UAPI mdio.h header file is:

#define MDIO_PMA_CTRL2_TYPE             0x000f  /* PMA/PMD type selection */

I presume that this is according to an earlier version of 802.3.
Changing this definition may cause userspace and/or kernel regressions,
so I propose something like:

#define MDIO_PMA_CTRL2_TYPE_2012        0x003f  /* PMA/PMD type selection */

instead.  The rest of the reserved entries are not specified as being
part of the type selection (yet) so it would be inappropriate to change
their value.

-- 
RMK's Patch system: http://www.armlinux.org.uk/developer/patches/
FTTC broadband for 0.8mile line: currently at 9.6Mbps down 400kbps up
according to speedtest.net.
