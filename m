From: Ben Hutchings <bhutchings@solarflare.com>
Subject: Re: Generic interface to make physical port number used by a
 netdevice available to user space
Date: Wed, 22 May 2013 17:04:18 +0100
Message-ID: <1369238658.2670.9.camel@bwh-desktop.uk.level5networks.com>
References: <20130522075331.GA1363@fedora-17-guest.blr.amer.dell.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: <netdev@vger.kernel.org>
To: <Narendra_K@Dell.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from webmail.solarflare.com ([12.187.104.25]:42781 "EHLO
	webmail.solarflare.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755236Ab3EVQEX (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 22 May 2013 12:04:23 -0400
In-Reply-To: <20130522075331.GA1363@fedora-17-guest.blr.amer.dell.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 2013-05-22 at 13:24 +0530, Narendra_K@Dell.com wrote:
> Hello,
> 
> It is useful to know if network interfaces from NIC partitions 'map to/ use the'
> same physical port. For example,  when creating bonding in fault tolerance mode,
> if two network interfaces map to/use the same physical port, it might not have the
> desired result. This information is not available today in a standard format or
> it is not present.  If this information can be made available in a generic  way
> to user space, tools such as NetworkManager or Libteam  or Wicked can make smarter
> bonding decisions (such as warn users when setting up configurations which will
> not have desired effect).
> 
> The requirement is to have a generic interface using which kernel/drivers can
> provide information/hints to user space about the physical port number used by
> a network interface.
> 
> While looking for already existing generic facility, 'dev_id' sysfs attribute
> seemed relevant. Looking into the sources seemed to indicate that majority of 
> the drivers do not set it and it could be interpreted differently.

That is what it's for.  Unfortunately it is defined to be 0-based and as
you've seen the default (unknown) value is also 0, creating ambiguity.
(It also seems to be more common for user-facing documentation and
physical labels to use 1-based numbering.)

I wonder whether it would do any harm to make it signed and initialised
it to -1 in alloc_netdev_mqs() would do any harm?  That would make the
unknown case unambiguous.

> It would be great to know list's thoughts on  'dev_id' being used as the interface
> to make the physical port number information used by netdevice available to user
> space or do we need a new sysfs attribute for the same.
> 
> Note: I think in the scenario of SRIOV VF devices assigned to guest and being
> bonded, additional information would be needed to differentiate the network
> controller in the host.  But I suppose it is a different problem than this.

You're thinking about hybrid guest acceleration?  A combination of PCIe
serial number and port number should work.

Ben.

-- 
Ben Hutchings, Staff Engineer, Solarflare
Not speaking for my employer; that's the marketing department's job.
They asked us to note that Solarflare product names are trademarked.
