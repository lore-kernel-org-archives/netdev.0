From: Ben Hutchings <bhutchings@solarflare.com>
Subject: Re: [patch net-next v4 4/4] igb/igbvf: implement
 ndo_get_phys_port_id
Date: Thu, 25 Jul 2013 23:44:42 +0100
Message-ID: <1374792282.3058.35.camel@bwh-desktop.uk.level5networks.com>
References: <1374757385-10875-1-git-send-email-jiri@resnulli.us>
	    <1374757385-10875-5-git-send-email-jiri@resnulli.us>
	    <51F14F9F.1010703@intel.com>
	   <1374770653.3058.9.camel@bwh-desktop.uk.level5networks.com>
	   <51F167A6.808@intel.com>
	  <1374778266.3058.15.camel@bwh-desktop.uk.level5networks.com>
	  <51F1769E.3050906@intel.com>
	 <1374779745.3058.24.camel@bwh-desktop.uk.level5networks.com>
	 <51F18366.2040306@gmail.com> <51F1A666.8050001@intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: John Fastabend <john.fastabend@gmail.com>,
	Jiri Pirko <jiri@resnulli.us>, <netdev@vger.kernel.org>,
	<davem@davemloft.net>, <stephen@networkplumber.org>,
	<Narendra_K@Dell.com>, <john.r.fastabend@intel.com>,
	<or.gerlitz@gmail.com>, <jeffrey.t.kirsher@intel.com>,
	<jesse.brandeburg@intel.com>, <bruce.w.allan@intel.com>,
	<carolyn.wyborny@intel.com>, <donald.c.skidmore@intel.com>,
	<gregory.v.rose@intel.com>, <peter.p.waskiewicz.jr@intel.com>,
	<john.ronciak@intel.com>, <tushar.n.dave@intel.com>,
	<matthew.vick@intel.com>, <mitch.a.williams@intel.com>,
	<vyasevic@redhat.com>, <amwang@redhat.com>,
	<johannes@sipsolutions.net>
To: Alexander Duyck <alexander.h.duyck@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from webmail.solarflare.com ([12.187.104.25]:11590 "EHLO
	webmail.solarflare.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756840Ab3GYWou (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 25 Jul 2013 18:44:50 -0400
In-Reply-To: <51F1A666.8050001@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 2013-07-25 at 15:27 -0700, Alexander Duyck wrote:
> On 07/25/2013 12:58 PM, John Fastabend wrote:
> > On 07/25/2013 12:15 PM, Ben Hutchings wrote:
> >> On Thu, 2013-07-25 at 12:03 -0700, Alexander Duyck wrote:
[...]
> >>> Well like you mentioned, you could just pull this out out of
> >>> netdev->perm_addr.  You don't need to have anything driver specific as
> >>> long as that is the field you are using generic netdev or pci_dev
> >>> attributes to do the identification.
> >>
> >> For a PF driver that never shares the port with another PF, yes.  There
> >> are a handful of those drivers so it might be worth sharing an
> >> implementation that uses perm_addr, but it's so trivial...
> >>
> >>> All you need is something that
> >>> uniquely identifies the device in the system correct?
> >>
> >> The spec is that it is universally unique.  I don't know who's going to
> >> need that property but I think it's achievable since each physical port
> >> normally has at least one globally unique MAC address assigned at
> >> manufacturing time.
> >>
> >>> For that matter
> >>> it seems like you could probably just pull the domain, bus, device, and
> >>> function number out of the PCI device and that would probably work as
> >>> well as long as you cannot somehow have PFs running inside of guests.
> >>
> >> Some NICs have multiple PFs for the same port, and those could be
> >> assigned to guest VMs.
> >>
> >> All VF drivers would need some way to get the port ID, and that can't be
> >> done generically from inside a guest VM.
> >>
> >> Ben.
> >>
> >
> > I doubt you'll be able to think up a way to do this generically as Ben
> > points out. But also no reason for the complicated hash just use the
> > perm address of the PF and if you have multiple PFs elect one of the
> > n perm address to be the stand-in for the unique one.
> >
> > .John
> >
> 
> I think there may have been some miscommunication.  I wasn't talking
> about the VF drivers having a generic means of getting the ID.  I would
> just want all of the drivers to be using a similar approach for
> generating the port ID so that we reduce the risk of any kind of port ID
> collision.  We need to make sure we are all stuffing the 6 bytes of
> perm_addr into the 4 byte port ID using the same approach.

But we started with an up-to-32-byte port ID; why do you say 4 bytes?

Ben.

-- 
Ben Hutchings, Staff Engineer, Solarflare
Not speaking for my employer; that's the marketing department's job.
They asked us to note that Solarflare product names are trademarked.
