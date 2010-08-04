From: Lennert Buytenhek <buytenh@wantstofly.org>
Subject: Re: [PATCH] net: add Fast Ethernet driver for PXA168.
Date: Wed, 4 Aug 2010 09:17:09 +0200
Message-ID: <20100804071709.GK21121@mail.wantstofly.org>
References: <20100804104750.GA9652@pe-dt013.marvell.com> <20100804065818.GI21121@mail.wantstofly.org> <AANLkTikqTLKX_F-PJGtChWc7SOjWJkO_3bNyNXcKZcb_@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Sachin Sanap <ssanap@marvell.com>, netdev@vger.kernel.org,
	akarkare@marvell.com, sarnaik@marvell.com, prakity@marvell.com,
	markb@marvell.com
To: Eric Miao <eric.y.miao@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from fw.wantstofly.org ([80.101.37.227]:49283 "EHLO
	mail.wantstofly.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757512Ab0HDHRK (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 4 Aug 2010 03:17:10 -0400
Content-Disposition: inline
In-Reply-To: <AANLkTikqTLKX_F-PJGtChWc7SOjWJkO_3bNyNXcKZcb_@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Aug 04, 2010 at 03:08:51PM +0800, Eric Miao wrote:

> And yeah we also found the driver to be very similar to mv643xx_eth
> at that time, though not sure how much it resembles. So it would be
> definitely good to have some comment why to make this a separate
> driver, instead of reusing mv643xx_eth.

As far as I can tell, the PXA168 ethernet unit was lifted from the
88E6208/6218 gateway ARM SoC (which is e.g. the SoC that is used in my
office Linksys ethernet switch, along with a Prestera), where it is
called the UniMAC.  This also explains why this thing has such extensive
address filtering capabilities, which you wouldn't expect to use in a
PXA-like application.

I'm not sure whether the Discovery/Orion GigE unit was just lifted from
that and extended to handle GigE, or that it went the other way round,
but in either case, the register sets have become too divergent to handle
them cleanly in one driver.  (I looked at this a year or so ago and found
this to be the case back then, so I'm not just saying this now to justify
the choice for two separate drivers post facto.)
