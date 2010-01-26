From: Patrick McHardy <kaber@trash.net>
Subject: Re: Netlink usage question (for bonding comm with userspace)
Date: Tue, 26 Jan 2010 12:25:55 +0100
Message-ID: <4B5ED143.6000903@trash.net>
References: <15914.1264466901@death.nxdomain.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-15
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Jay Vosburgh <fubar@us.ibm.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from stinky.trash.net ([213.144.137.162]:65037 "EHLO
	stinky.trash.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752207Ab0AZL0A (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 26 Jan 2010 06:26:00 -0500
In-Reply-To: <15914.1264466901@death.nxdomain.ibm.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Jay Vosburgh wrote:
> 	Could any netlink gurus comment on my questions?  I'm hoping to
> figure out the right way to do what I need without working up patches
> that end up being excellent examples of the wrong way.  I've looked
> through the kernel, and it's almost a cases of too many choices (private
> netlink, rtnetlink, connector, genetlink) to sort through.
> 
> 	Background: I'm working on a bonding mode that involves two-way
> communication between bonding itself and a user-space daemon, and I'm
> trying to determine the best way to utilize netlink for this project
> with an eye towards forwards compatibility with future expansion (e.g.,
> general bonding setup via netlink).  For purposes of discussion, the
> communication requires that bonding-specific requests, responses and
> asynchronous events flow in both directions.
> 
> 	I could, for this project, use a netlink_kernel_create and
> socket(AF_NETLINK) pair to perform the communication (presumably adding
> a NETLINK_BONDING or the like to <linux/netlink.h>).
> 
> 	That, however, wouldn't dovetail with moving control of bonding
> into iproute2 ("ip link add link bond0 type bond mode whatever"), and it
> seems suboptimal to have two independent netlink gizmos in bonding.  I'm
> not planning to implement full bonding control via netlink at this time,
> but I don't want to do anything that would cause difficulty for doing so
> in the future.

I actually have an 75% finished patchset for rtnl_link support.

> 	I've done some prototyping with working through the existing
> rtnetlink infrastructure, adding an RTNLGRP_BONDING, AF_BONDING, etc,
> vaguely paralleling how the bridge code is architected.  What's unclear
> to me is how to insert the bonding-specific request / response message
> types into the rtnetlink infrastructure, or, indeed, if this is simply
> not the right way to go about this.
> 
> 	So, in summary:
> 
> 	For user / kernel communications via netlink: private socket,
> add to rtnetlink API, or something else (connector, genetlink, ...)?
> 
> 	Is having private socket netlink and rtnetlink in the same
> module a reasonable methodology?

It depends. If your requests and responses can be expressed as
device configuration and state changes then you could include them
in the bonding specific part of an rtnetlink message. Otherwise
you should use a private netlink family or genetlink.

> 	If rtnetlink is suitable, basic "do this" or "don't do this"
> thoughts?  The various HOWTOs google finds for me concentrate on the
> mechanisms, less so on interface selection / design.
> 
> 	Thoughts?
> 
> 	-J
> 
> ---
> 	-Jay Vosburgh, IBM Linux Technology Center, fubar@us.ibm.com
> --
> To unsubscribe from this list: send the line "unsubscribe netdev" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
> 

