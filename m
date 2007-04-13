From: David Hollis <dhollis@davehollis.com>
Subject: Re: phylib usage
Date: Fri, 13 Apr 2007 17:16:30 -0400
Message-ID: <1176498990.3567.5.camel@dhollis-lnx.sunera.com>
References: <1176230461.7526.20.camel@dhollis-lnx.sunera.com>
	<20070410172052.16eae78c.kim.phillips@freescale.com>
	<20070411010356.GC9526@xi.wantstofly.org>
	<20070411164234.2c64bd92.kim.phillips@freescale.com>
	<1176475990.3766.3.camel@dhollis-lnx.sunera.com>
	<3E02570C-0A7B-40F6-9F5C-7EBDEA9FBA6F@freescale.com>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: Kim Phillips <kim.phillips@freescale.com>,
	Lennert Buytenhek <buytenh@wantstofly.org>,
	netdev@vger.kernel.org
To: Andy Fleming <afleming@freescale.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from vms040pub.verizon.net ([206.46.252.40]:53919 "EHLO
	vms040pub.verizon.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1030367AbXDMVWo (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 13 Apr 2007 17:22:44 -0400
Received: from smtp.davehollis.com ([71.251.104.144])
 by vms040.mailsrvcs.net (Sun Java System Messaging Server 6.2-6.01 (built Apr
 3 2006)) with ESMTPA id <0JGG00F0DGMSBQ45@vms040.mailsrvcs.net> for
 netdev@vger.kernel.org; Fri, 13 Apr 2007 16:20:53 -0500 (CDT)
In-reply-to: <3E02570C-0A7B-40F6-9F5C-7EBDEA9FBA6F@freescale.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Fri, 2007-04-13 at 13:00 -0500, Andy Fleming wrote:

> 
> >
> > Or are there too many cases where NIC x needs to do these fiddlings  
> > with
> > PHY y, where as NIC z has to do different fiddlings with PHY y?
> 
> 
> I worry about this point, but I believe that a proper abstraction  
> must be possible.  In almost every case, the PHY is a separate  
> device, which I have to think means that it can have its own driver,  
> decoupled from the ethernet driver.
> 

Yeah, it would be the biggest sticking point.  I'm curious as to whether
it is an actual issue, or more of a "I do it this way and it works, but
the phylib driver does it a different way and I don't like that" or some
such nonsense.

> >
> > Again, I don't have a lot of experience with Ethernet devices but in
> > looking at a lot of the different driver code, it looks like they all
> > fiddle with the PHYs in basically the same way, though some drivers do
> > more, some less.  Most likely due to lack of access to errata and such
> > or issues just not cropping up that need to be fixed.
> 
> 
> I agree.  I've been a little disheartened to see all the patches that  
> have come through to fix bugs in the PHY-handling code of various  
> ethernet drivers.  It would be great if that code could all get  
> collected into the PHY lib.  Then we'd only have to fix the bug once,  
> rather than once for every ethernet driver that uses that particular  
> PHY.
> 

Absolutely.  What really got me interested when phylib came around is
that the Ax88178 GBE device uses an external phy and the sample code I
received from ASIX had support for all different kinds of phy's (all of
which happen to be in phylib at the moment) but the code was atrocious.
Totally unmanageable, undocumented, you just couldn't tell what it was
doing.  I love the idea of having the device use phylib so I don't even
have to care what kind of phy may get hooked onto the device by an OEM.
As long as phylib has a driver, it just works.  I always like the idea
of passing off the handling of something to someone else so it's less
for me to be concerned with (heck, asix.c already piggy backs all over
usbnet.c so all that the driver is really doing is the setup and device
specific management, all other bits are handled in usbnet)


> If anyone has looked at porting an ethernet driver to the PHY lib,  
> and found it lacks a necessary feature, I'd love to hear about those  
> experiences.  The locking issue is a big one, but I, too, think that  
> it should be fairly straightforward to work around.
> 

Locking is the biggest sticking point for me.  The only other issue I
see is the string for the bus name (doesn't it turn out like phy0:0 or
something, it's been awhile).  I don't seem to have a way to map back to
what it turns in to, or I haven't figured out a way yet.  Nothing
insurmountable.


-- 
David Hollis <dhollis@davehollis.com>

