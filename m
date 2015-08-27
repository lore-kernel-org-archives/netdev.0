From: "John W. Linville" <linville@tuxdriver.com>
Subject: Re: [RFC PATCH net-next 0/2] Add new switchdev device class
Date: Thu, 27 Aug 2015 09:54:14 -0400
Message-ID: <20150827135414.GA8113@tuxdriver.com>
References: <1440659806-56582-1-git-send-email-sfeldma@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, jiri@resnulli.us, davem@davemloft.net,
	f.fainelli@gmail.com, roopa@cumulusnetworks.com
To: sfeldma@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from charlotte.tuxdriver.com ([70.61.120.58]:38580 "EHLO
	smtp.tuxdriver.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754130AbbH0OAR (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 27 Aug 2015 10:00:17 -0400
Content-Disposition: inline
In-Reply-To: <1440659806-56582-1-git-send-email-sfeldma@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Aug 27, 2015 at 12:16:44AM -0700, sfeldma@gmail.com wrote:
> From: Scott Feldman <sfeldma@gmail.com>
> 
> In the switchdev model, we use netdevs to represent switchdev ports, but we
> have no representation for the switch itself.  So, introduce a new switchdev
> device class so we can define semantics and programming interfaces for the
> switch itself.  Switchdev device class isn't tied to any particular bus.
> 
> This patch set is just the skeleton to get us started.  It adds the sysfs
> object registration for the new class and defines a class-level attr "foo".
> With the new class, we could hook PM functions, for example, to handle power
> transitions at the switch level.  I registered rocker and get:
> 
>    $ ls /sys/class/switchdev/5254001235010000/
>    foo  power  subsystem  uevent
> 
> So what next?  I'd rather not build APIs around sysfs, so we need a netlink API
> we can build on top of this.  It's not really rtnl.  Maybe genl would work?
> What ever it is, we'd need to teach iproute2 about a new 'switch' command.
> 
> Netlink API would allow us to represent switch-wide objects such as registers,
> tables, stats, firmware, and maybe even control.  I think with with netlink
> TLVs, we can create a framework for these objects but still allow the switch
> driver provide switch-specific info.  For example, a table object:
> 
> [TABLES]
> 	[TABLE]
> 		[FIELDS]
> 			[FIELD]
> 				[ID, TYPE]
> 		[DATA]
> 			[ID, VALUE]
> 
> Maybe iproute2 has pretty-printers for specific switches like ethtool has for
> reg dumps.
> 
> I don't know about how this overlaps with DSA platform_class.  Florian?
> 
> Comments?

I think this makes a lot of sense, for many of the reasons you cite
later in the thread.  Switches are complex devices with multiple
facets that are difficult to map directly to existing abstractions
without creating artificial adaptations or leaving something out.
Giving the switch itself a representation in the device tree seems
like the right way to go.

John
-- 
John W. Linville		Someday the world will need a hero, and you
linville@tuxdriver.com			might be all we have.  Be ready.
