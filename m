From: Andy Fleming <afleming@freescale.com>
Subject: Re: phylib usage
Date: Fri, 13 Apr 2007 13:00:34 -0500
Message-ID: <3E02570C-0A7B-40F6-9F5C-7EBDEA9FBA6F@freescale.com>
References: <1176230461.7526.20.camel@dhollis-lnx.sunera.com> <20070410172052.16eae78c.kim.phillips@freescale.com> <20070411010356.GC9526@xi.wantstofly.org> <20070411164234.2c64bd92.kim.phillips@freescale.com> <1176475990.3766.3.camel@dhollis-lnx.sunera.com>
Mime-Version: 1.0 (Apple Message framework v752.2)
Content-Type: text/plain; charset=US-ASCII; delsp=yes; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Kim Phillips <kim.phillips@freescale.com>,
	Lennert Buytenhek <buytenh@wantstofly.org>,
	netdev@vger.kernel.org
To: David Hollis <dhollis@davehollis.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from az33egw02.freescale.net ([192.88.158.103]:44407 "EHLO
	az33egw02.freescale.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751988AbXDNUY0 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 14 Apr 2007 16:24:26 -0400
In-Reply-To: <1176475990.3766.3.camel@dhollis-lnx.sunera.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


On Apr 13, 2007, at 09:53, David Hollis wrote:

> On Wed, 2007-04-11 at 16:42 -0500, Kim Phillips wrote:
>> On Wed, 11 Apr 2007 03:03:56 +0200
>> Lennert Buytenhek <buytenh@wantstofly.org> wrote:
>
> There may not be as much, but there definitely are still cases where
> there are devices that may have one of three or four different PHYs.
> I'm not in the embedded world, but while I know that there are
> differences, it isn't THAT different that something as potentially
> useful as PHY abstraction wouldn't be useful for regular PCI/USB  
> network
> interfaces.


I don't think Kim intended to imply that non-embedded drivers can't  
use the PHY lib.  When I worked on this, it was my hope that it would  
be useful to all ethernet drivers, not just the one or two I was  
working on.  I suspect that I could do a better job evangelizing the  
code.


>
> Or are there too many cases where NIC x needs to do these fiddlings  
> with
> PHY y, where as NIC z has to do different fiddlings with PHY y?


I worry about this point, but I believe that a proper abstraction  
must be possible.  In almost every case, the PHY is a separate  
device, which I have to think means that it can have its own driver,  
decoupled from the ethernet driver.


>
> Again, I don't have a lot of experience with Ethernet devices but in
> looking at a lot of the different driver code, it looks like they all
> fiddle with the PHYs in basically the same way, though some drivers do
> more, some less.  Most likely due to lack of access to errata and such
> or issues just not cropping up that need to be fixed.


I agree.  I've been a little disheartened to see all the patches that  
have come through to fix bugs in the PHY-handling code of various  
ethernet drivers.  It would be great if that code could all get  
collected into the PHY lib.  Then we'd only have to fix the bug once,  
rather than once for every ethernet driver that uses that particular  
PHY.

If anyone has looked at porting an ethernet driver to the PHY lib,  
and found it lacks a necessary feature, I'd love to hear about those  
experiences.  The locking issue is a big one, but I, too, think that  
it should be fairly straightforward to work around.

Andy


