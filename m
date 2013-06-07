From: Ben Hutchings <bhutchings@solarflare.com>
Subject: Re: Generic interface to make physical port number used by a
 netdevice available to user space
Date: Fri, 7 Jun 2013 18:21:18 +0100
Message-ID: <1370625678.1903.26.camel@bwh-desktop.uk.level5networks.com>
References: <20130522075331.GA1363@fedora-17-guest.blr.amer.dell.com>
	 <20130523093421.3b20a0bd@nehalam.linuxnetplumber.net>
	 <E31FB011129F30488D5861F383904915210B96144A@BLRX7MCDC201.AMER.DELL.COM>
	 <20130531121201.GA1311@fedora-17-guest.blr.amer.dell.com>
	 <51B1F56D.5000007@intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: <stephen@networkplumber.org>, <netdev@vger.kernel.org>
To: John Fastabend <john.r.fastabend@intel.com>,
	Narendra K <narendra_k@dell.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from webmail.solarflare.com ([12.187.104.25]:24142 "EHLO
	webmail.solarflare.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754924Ab3FGRVX (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 7 Jun 2013 13:21:23 -0400
In-Reply-To: <51B1F56D.5000007@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, 2013-06-07 at 07:59 -0700, John Fastabend wrote:
> On 5/31/2013 5:13 AM, Narendra_K@Dell.com wrote:
> > On Mon, May 27, 2013 at 06:39:00PM +0530, Narendra_K@Dell.com wrote:
> >>
> >>> -----Original Message-----
> >>> From: Stephen Hemminger [mailto:stephen@networkplumber.org]
> >>> Sent: Thursday, May 23, 2013 10:04 PM
> >>> To: K, Narendra
> >>> Cc: netdev@vger.kernel.org
> >>> One idea would be to reuse the mostly outdated if_port field.
> >>> As far as I can see only drivers using it are legacy drivers which support
> >> AUI vs.
> >>> TP back in the old bad days of BNC Ethernet.
> >>
> >> Hi Stephen, thank you.
> >>
> >> I think if_port or dev_id would be fine. The difference seems to be  that
> >> dev_id is already exported to sysfs.
> >>
> >
> > I think the following options could be explored -
> >
> > 1. dev_id:
> > Do not initialize it to -1, but use it to indicate physical port number
> > used by netdevice.
> >
> > It is currently being used for indicating physical port number and
> > is also being used to differentiate OS instances as noted here.
> > http://marc.info/?l=linux-netdev&m=136992115300526&w=2
> >
> 
> My opinion would be to use dev_id as the comment in netdevice.h suggests
> it can be used for this. I'm not sure the addrconf.c bits are still
> valid.
> 
> If need be you could fix the check in addrconf to check for not -1.

Having looked at the qeth driver now, I think the comment in netdevice.h
should be changed to state that this is for distinguishing devices that
share a link-layer address, and the drivers using it for other purposes
should stop doing so (if that doesn't break userland).

[...]
> > 3. Add a new field 'physport' to 'struct net_device' and export it to sysfs.
> 
> Probably not we already have two fields that seem ill-defined no reason
> to add another to the confusion. If you absolutely can't make dev_id or
> if_port coherent then maybe but I really think one of the above two will
> work.

I think we should tighten up documentation and implementation of the
existing fields, but there is still a need for this new one.

One thing that needs to be clearly specified is the scope of the
physport identifier - the controller, board, physical machine, ... or
universe.  In a VM, controller and board scope are pretty useless as it
typically can't tell which devices belong to the same controller or
board anyway.  A universally unique identifier is probably not too hard
to implement as there is likely to be at least one MAC address
permanently assigned to each physical port.

Ben.

> >
> > It would be great to know your thoughts on which of the above would be
> > preferable.


-- 
Ben Hutchings, Staff Engineer, Solarflare
Not speaking for my employer; that's the marketing department's job.
They asked us to note that Solarflare product names are trademarked.
