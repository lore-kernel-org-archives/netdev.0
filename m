From: Jeff Garzik <jgarzik@pobox.com>
Subject: Re: [PATCH 1/3] ixgbe: Add Data Center Bridging netlink listener
 for DCB runtime changes.
Date: Wed, 07 May 2008 17:13:29 -0400
Message-ID: <48221B79.2010808@pobox.com>
References: <20080502004254.14392.7599.stgit@localhost.localdomain> <20080502004300.14392.87943.stgit@localhost.localdomain> <481AF501.3030507@pobox.com> <D5C1322C3E673F459512FB59E0DDC3290509D540@orsmsx414.amr.corp.intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: "Waskiewicz Jr, Peter P" <peter.p.waskiewicz.jr@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from srv5.dvmed.net ([207.36.208.214]:57290 "EHLO mail.dvmed.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751154AbYEGVNc (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 7 May 2008 17:13:32 -0400
In-Reply-To: <D5C1322C3E673F459512FB59E0DDC3290509D540@orsmsx414.amr.corp.intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Waskiewicz Jr, Peter P wrote:
> I've given this much more thought, and have some additional feedback.
> While I see your point about each driver wanting to support DCB
> shouldn't have to create their own netlink interface, having the ioctl's
> in ethtool for every other driver not supporting DCB isn't necessary
> either.  I understand there are commands in ethtool that some drivers
> don't implement, but the required commands for DCB would add a pretty
> decent chunk of code into ethtool.  But for other advanced features
> today, many drivers implement sysfs interfaces to support tweaking of
> values outside of the ethtool umbrella.  Given this is less than a
> driver-only configuration tool, but it's a tool that is configuring the
> behavior of the entire network, we need one userspace tool that can
> communicate to all registered devices, and netlink lends itself well to
> that.
> 
> I also looked at Thomas' proposal, and it does look fine.  However, we'd
> have the same issue of needing to implement all the DCB commands in
> ethtool, which I'm still not totally convinced is the correct thing to
> do, given how the DCB stack from userspace to the link partner works.
> 
> Our long-term goal is to implement the dcbd (userspace daemon) interface
> in the kernel as a module interface, so the userspace commands interact
> with it and only it directly.  Much like the mac80211 interface, which
> the dcbd interface in the kernel would push the commands to registered
> drivers through a common kernel interface, most likely through the
> netdev.  We're not there yet, but we need to step before we run.  Hence
> why the driver is using netlink today.


If its complex enough, or doesn't fit the ioctl model well, it doesn't 
necessarily have to be via the ethtool ioctl.

Two goals I have, though, are

* the userspace ethtool utility configures this stuff.  Note I did /not/ 
say "must use ethtool ioctl."  The core idea behind ethtool is to 
centralize NIC-specific knowledge -- thus that's the place where 
chip-specific register dumping code resides.  So within reason, it's OK 
to put DCB-specific commands into ethtool that do not use the ethtool ioctl.

But like everything else in life, one must weight various costs.  Maybe 
it is complex enough to warrant a new tool.  We don't know until there's 
a design doc or review of the generic interface that will be used for DCB.

* the kernel portion can be used by other non-Intel drivers, i.e. a 
generic and separate piece.  We should not be embedding an entire 
netlink interface into each driver.

Regards,

	Jeff



