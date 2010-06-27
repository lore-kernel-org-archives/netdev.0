From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] phylib: Add autoload support for the LXT973 phy.
Date: Sat, 26 Jun 2010 22:16:20 -0700 (PDT)
Message-ID: <20100626.221620.267962098.davem@davemloft.net>
References: <20100531130932.GA15845@riccoc20.at.omicron.at>
	<1277210293.21798.11.camel@localhost>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: richardcochran@gmail.com, netdev@vger.kernel.org
To: dwmw2@infradead.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:60440
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751251Ab0F0FQH (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 27 Jun 2010 01:16:07 -0400
In-Reply-To: <1277210293.21798.11.camel@localhost>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: David Woodhouse <dwmw2@infradead.org>
Date: Tue, 22 Jun 2010 13:38:13 +0100

> Commit e13647c1 (phylib: Add support for the LXT973 phy.) added a new ID
> but neglected to also add it to the MODULE_DEVICE_TABLE.
> 
> Signed-off-by: David Woodhouse <David.Woodhouse@intel.com>

Applied, thanks.

> When I did this stuff, I did wonder if we should make this happen
> automatically somehow. I pondered some dirty macro hack in
> phy_driver_register() which would do it somehow, but couldn't come up
> with anything that'd work.
> 
> Removing the phy_id and phy_id_mask from struct phy_driver and having a
> pointer to a match table would suck, since each driver only really
> matches one device/mask. (Even where a single C file has multiple
> drivers, they often differ in some methods or flags.)
> 
> The best option I can come up with right now, is probably to remove
> phy_id and phy_id_mask from phy_driver and put a pointer to the driver
> into the ID table, and take the ID table as the argument to
> phy_driver_register(). I'm not sure I like that very much though -- I'd
> prefer that we just remember to update the table and don't need to be
> forced :)
> 
> (Another cheap option is to pass the ID table as an extra argument to
> the existing phy_device_register(), I suppose, and it can just print a
> warning if it doesn't find the same phy_id and phy_id_mask in the table)

As our experience shows, people aren't remembering to do it so we have
to do something hard handed to make sure this doesn't break.

A compile time error out is the best, but if that is too hard or ugly
and we do it at run time then we should fail the register (not just
print a warning) if the table is incomplete.

Otherwise we run into cases where a developer adds several new IDs,
forgets some of the table entries, but only tries testing the ones he
did remember to add and doesn't notice the warning message.
