From: Ben Hutchings <bhutchings@solarflare.com>
Subject: Re: Generic interface to make physical port number used by a
 netdevice available to user space
Date: Thu, 23 May 2013 17:18:40 +0100
Message-ID: <1369325920.1950.20.camel@bwh-desktop.uk.level5networks.com>
References: <20130522075331.GA1363@fedora-17-guest.blr.amer.dell.com>
	 <1369238658.2670.9.camel@bwh-desktop.uk.level5networks.com>
	 <20130523132729.GA11584@fedora-17-guest.blr.amer.dell.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: <netdev@vger.kernel.org>
To: <Narendra_K@Dell.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from webmail.solarflare.com ([12.187.104.25]:38439 "EHLO
	webmail.solarflare.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1758828Ab3EWQUH (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 23 May 2013 12:20:07 -0400
In-Reply-To: <20130523132729.GA11584@fedora-17-guest.blr.amer.dell.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 2013-05-23 at 06:27 -0700, Narendra_K@Dell.com wrote:
> On Wed, May 22, 2013 at 09:34:18PM +0530, Ben Hutchings wrote:
> > 
> > On Wed, 2013-05-22 at 13:24 +0530, Narendra_K@Dell.com wrote:
> > > While looking for already existing generic facility, 'dev_id' sysfs attribute
> > > seemed relevant. Looking into the sources seemed to indicate that majority of
> > > the drivers do not set it and it could be interpreted differently.
> > 
> > That is what it's for.  Unfortunately it is defined to be 0-based and as
> > you've seen the default (unknown) value is also 0, creating ambiguity.
> > (It also seems to be more common for user-facing documentation and
> > physical labels to use 1-based numbering.)
> > 
> > I wonder whether it would do any harm to make it signed and initialised
> > it to -1 in alloc_netdev_mqs() would do any harm?  That would make the
> > unknown case unambiguous.
> > 
> > > It would be great to know list's thoughts on  'dev_id' being used as the
> > interface
> > > to make the physical port number information used by netdevice available to
> > user
> > > space or do we need a new sysfs attribute for the same.
> > >
> > > Note: I think in the scenario of SRIOV VF devices assigned to guest and being
> > > bonded, additional information would be needed to differentiate the network
> > > controller in the host.  But I suppose it is a different problem than this.
> > 
> > You're thinking about hybrid guest acceleration?  A combination of PCIe
> > serial number and port number should work.
> 
> Hi Ben,
> 
> Thank you for the response.
> 
> I was thinking about the scenario of VF0 and VF1 coming from PF0 in the host
> Network Controller 1 being direct assigned to a KVM guest via VTD and netdevices
> from VF0 and VF1 being bonded in the guest. Assuming that physical port number used
> by VF0 and VF1 is 1, additional information is needed to identify if port number 1
> is on Network controller 1 or Network controller 2. (In the host we could use
> PCI b/d/f to differentiate two Network Controllers). I think it is similar to
> hybrid guest acceleration on the VF assignment aspect.

OK.  Either way, the hypervisor or management stack will have to help
the guest by providing the identifier(s) to tie the devices together.  I
suggested PCIe serial number as the controller identifier.

Ben.

-- 
Ben Hutchings, Staff Engineer, Solarflare
Not speaking for my employer; that's the marketing department's job.
They asked us to note that Solarflare product names are trademarked.
