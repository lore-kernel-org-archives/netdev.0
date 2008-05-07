From: "Waskiewicz Jr, Peter P" <peter.p.waskiewicz.jr@intel.com>
Subject: RE: [PATCH 1/3] ixgbe: Add Data Center Bridging netlink listener for DCB runtime changes.
Date: Wed, 7 May 2008 13:53:31 -0700
Message-ID: <D5C1322C3E673F459512FB59E0DDC3290509D540@orsmsx414.amr.corp.intel.com>
References: <20080502004254.14392.7599.stgit@localhost.localdomain> <20080502004300.14392.87943.stgit@localhost.localdomain> <481AF501.3030507@pobox.com>
Mime-Version: 1.0
Content-Type: text/plain;
	charset="us-ascii"
Content-Transfer-Encoding: 8BIT
Cc: <netdev@vger.kernel.org>
To: "Jeff Garzik" <jgarzik@pobox.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga02.intel.com ([134.134.136.20]:49391 "EHLO mga02.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1764163AbYEGUxa convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 7 May 2008 16:53:30 -0400
Content-class: urn:content-classes:message
In-Reply-To: <481AF501.3030507@pobox.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

> Seems to me we don't want each driver supporting this 
> technology to create their own netlink interface...
> 
> This seems more appropriate via ethtool, or ethtool-netlink 
> (Thomas Graf posted an RFC)
> 
> 	Jeff
> 

Jeff,

I've given this much more thought, and have some additional feedback.
While I see your point about each driver wanting to support DCB
shouldn't have to create their own netlink interface, having the ioctl's
in ethtool for every other driver not supporting DCB isn't necessary
either.  I understand there are commands in ethtool that some drivers
don't implement, but the required commands for DCB would add a pretty
decent chunk of code into ethtool.  But for other advanced features
today, many drivers implement sysfs interfaces to support tweaking of
values outside of the ethtool umbrella.  Given this is less than a
driver-only configuration tool, but it's a tool that is configuring the
behavior of the entire network, we need one userspace tool that can
communicate to all registered devices, and netlink lends itself well to
that.

I also looked at Thomas' proposal, and it does look fine.  However, we'd
have the same issue of needing to implement all the DCB commands in
ethtool, which I'm still not totally convinced is the correct thing to
do, given how the DCB stack from userspace to the link partner works.

Our long-term goal is to implement the dcbd (userspace daemon) interface
in the kernel as a module interface, so the userspace commands interact
with it and only it directly.  Much like the mac80211 interface, which
the dcbd interface in the kernel would push the commands to registered
drivers through a common kernel interface, most likely through the
netdev.  We're not there yet, but we need to step before we run.  Hence
why the driver is using netlink today.

Please let me know what you think.

Cheers,
-PJ Waskiewicz
