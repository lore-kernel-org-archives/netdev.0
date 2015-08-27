From: sfeldma@gmail.com
Subject: [RFC PATCH net-next 0/2] Add new switchdev device class
Date: Thu, 27 Aug 2015 00:16:44 -0700
Message-ID: <1440659806-56582-1-git-send-email-sfeldma@gmail.com>
Cc: jiri@resnulli.us, davem@davemloft.net, f.fainelli@gmail.com,
	roopa@cumulusnetworks.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f54.google.com ([209.85.220.54]:36682 "EHLO
	mail-pa0-f54.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750725AbbH0HOL (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 27 Aug 2015 03:14:11 -0400
Received: by padfo6 with SMTP id fo6so914236pad.3
        for <netdev@vger.kernel.org>; Thu, 27 Aug 2015 00:14:11 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Scott Feldman <sfeldma@gmail.com>

In the switchdev model, we use netdevs to represent switchdev ports, but we
have no representation for the switch itself.  So, introduce a new switchdev
device class so we can define semantics and programming interfaces for the
switch itself.  Switchdev device class isn't tied to any particular bus.

This patch set is just the skeleton to get us started.  It adds the sysfs
object registration for the new class and defines a class-level attr "foo".
With the new class, we could hook PM functions, for example, to handle power
transitions at the switch level.  I registered rocker and get:

   $ ls /sys/class/switchdev/5254001235010000/
   foo  power  subsystem  uevent

So what next?  I'd rather not build APIs around sysfs, so we need a netlink API
we can build on top of this.  It's not really rtnl.  Maybe genl would work?
What ever it is, we'd need to teach iproute2 about a new 'switch' command.

Netlink API would allow us to represent switch-wide objects such as registers,
tables, stats, firmware, and maybe even control.  I think with with netlink
TLVs, we can create a framework for these objects but still allow the switch
driver provide switch-specific info.  For example, a table object:

[TABLES]
	[TABLE]
		[FIELDS]
			[FIELD]
				[ID, TYPE]
		[DATA]
			[ID, VALUE]

Maybe iproute2 has pretty-printers for specific switches like ethtool has for
reg dumps.

I don't know about how this overlaps with DSA platform_class.  Florian?

Comments?


Scott Feldman (2):
  switchdev: create new switchdev device class
  rocker: register each switch as a switchdev

 drivers/net/ethernet/rocker/rocker.c |   23 ++++++++++
 include/net/switchdev.h              |   16 +++++++
 net/switchdev/switchdev.c            |   76 ++++++++++++++++++++++++++++++++++
 3 files changed, 115 insertions(+)

-- 
1.7.10.4
