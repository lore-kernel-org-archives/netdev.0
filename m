From: Hannes Frederic Sowa <hannes@stressinduktion.org>
Subject: Re: ipv6: Should inet6_addr_del consider IFA_F_MANAGETEMPADDR?
Date: Tue, 8 Apr 2014 22:14:30 +0200
Message-ID: <20140408201430.GD27255@order.stressinduktion.org>
References: <53443F5D.6030509@web.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	jiri@resnulli.us, thaller@redhat.com
To: Heiner Kallweit <heiner.kallweit@web.de>
Return-path: <netdev-owner@vger.kernel.org>
Received: from order.stressinduktion.org ([87.106.68.36]:59077 "EHLO
	order.stressinduktion.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756551AbaDHUOb (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 8 Apr 2014 16:14:31 -0400
Content-Disposition: inline
In-Reply-To: <53443F5D.6030509@web.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

[cc Jiri + Thomas]

Hi!

On Tue, Apr 08, 2014 at 08:26:37PM +0200, Heiner Kallweit wrote:
> I stumbled accross the fact that inet6_addr_add as well as inet6_addr_modify
> consider IFA_F_TEMPORARY whilst inet6_addr_del does not.
> 
> My understanding of IFA_F_MANAGETEMPADDR is that it allows userspace applications
> to deal with temporary addresses w/o having to create / track (and possibly delete)
> each and every temporary address.
> 
> This works fine when creating / modifying a global address. However when a
> global address is deleted the orphaned temporary addresses remain.
> Shouldn't the userspace be able to set IFA_F_MANAGETEMPADDR also for RTM_DELADDR
> to signalize that the kernel should delete all related temporary addresses as well?

Sure, that is possible. I guess it was not done already because
inet6_addr_del did not handle IFA_FLAGS at all. But it should be a very
tiny change to pass that flag down. Please submit an iproute patch along
with your changes.

> It would be a rather small extension to manage_tempaddrs to add a "delete" parameter
> and set valid_lft=prefered_lft=0 for each temporary address if set.

I think valid_lft=prefered_lft=0; manage_tempaddr(...);
addrconf_verify_rtnl(); is enough to clean up the old temporary address.
No need for a further flag.

> Sorry if this was discussed before and I miss something.

I don't remember a discussion about that. ;)

Bye,

  Hannes
