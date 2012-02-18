From: Ben Hutchings <bhutchings@solarflare.com>
Subject: Re: tg3: Use *_UNKNOWN ethtool definitions
Date: Sat, 18 Feb 2012 01:03:05 +0000
Message-ID: <1329526985.2822.29.camel@bwh-desktop>
References: <20120217064830.GA14483@mwanda>
	 <20120218005445.GA14067@mcarlson.broadcom.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Dan Carpenter <dan.carpenter@oracle.com>, <netdev@vger.kernel.org>
To: Matt Carlson <mcarlson@broadcom.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from exchange.solarflare.com ([216.237.3.220]:21700 "EHLO
	ocex02.SolarFlarecom.com" rhost-flags-OK-FAIL-OK-FAIL)
	by vger.kernel.org with ESMTP id S1752248Ab2BRBDI (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 17 Feb 2012 20:03:08 -0500
In-Reply-To: <20120218005445.GA14067@mcarlson.broadcom.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, 2012-02-17 at 16:54 -0800, Matt Carlson wrote:
> On Fri, Feb 17, 2012 at 09:48:30AM +0300, Dan Carpenter wrote:
> > Hello Matt Carlson,
> > 
> > The patch e740522e6d3a: "tg3: Use *_UNKNOWN ethtool definitions" from 
> > Feb 13, 2012, leads to the following Smatch warning:
> > drivers/net/ethernet/broadcom/tg3.c:1822 tg3_adjust_link()
> > 	 error: tp->link_config.active_speed is never equal to -1 (wrong type 0 - 65535).
> > 
> > -       if ((phydev->link && tp->link_config.active_speed == SPEED_INVALID) ||
> > -           (!phydev->link && tp->link_config.active_speed != SPEED_INVALID) ||
> > +       if ((phydev->link && tp->link_config.active_speed == SPEED_UNKNOWN) ||
> > +           (!phydev->link && tp->link_config.active_speed != SPEED_UNKNOWN) ||
> > 
> > Since tp->link_config.active_speed is an unsigned short, it never is
> > equal to SPEED_UNKNOWN (-1).
> > 
> > I introduced the SPEED_UNKNOWN so I feel bad that it's causing trouble
> > now.  :/
> > 
> > Also this warning:
> > drivers/net/ethernet/broadcom/tg3.c:3909 tg3_phy_copper_begin(14)
> > error: tp->link_config.speed is never equal to -1 (wrong type 0 - 65535).
> 
> Do you have any problems with changing SPEED_UNKNOWN from -1 to 0xffff?

I have a big problem with that - speed values are 32-bit in the ethtool
API.

Ben.

-- 
Ben Hutchings, Staff Engineer, Solarflare
Not speaking for my employer; that's the marketing department's job.
They asked us to note that Solarflare product names are trademarked.
