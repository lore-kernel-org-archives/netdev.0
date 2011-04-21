From: Ben Hutchings <bhutchings@solarflare.com>
Subject: RE: rtnetlink and many VFs
Date: Thu, 21 Apr 2011 19:11:57 +0100
Message-ID: <1303409517.3165.39.camel@bwh-desktop>
References: <1303396576.3165.13.camel@bwh-desktop>
	 <43F901BD926A4E43B106BF17856F07550145FC7526@orsmsx508.amr.corp.intel.com>
	 <1303407628.3165.30.camel@bwh-desktop>
	 <43F901BD926A4E43B106BF17856F07550145FC75D6@orsmsx508.amr.corp.intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>,
	netdev <netdev@vger.kernel.org>,
	sf-linux-drivers <linux-net-drivers@solarflare.com>
To: "Rose, Gregory V" <gregory.v.rose@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from exchange.solarflare.com ([216.237.3.220]:1329 "EHLO
	exchange.solarflare.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750887Ab1DUSMA (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 21 Apr 2011 14:12:00 -0400
In-Reply-To: <43F901BD926A4E43B106BF17856F07550145FC75D6@orsmsx508.amr.corp.intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 2011-04-21 at 10:50 -0700, Rose, Gregory V wrote:
> > -----Original Message-----
> > From: Ben Hutchings [mailto:bhutchings@solarflare.com]
> > Sent: Thursday, April 21, 2011 10:40 AM
> > To: Rose, Gregory V
> > Cc: David Miller; netdev; sf-linux-drivers
> > Subject: RE: rtnetlink and many VFs
> > 
> > On Thu, 2011-04-21 at 10:02 -0700, Rose, Gregory V wrote:
> > > > -----Original Message-----
> > > > From: netdev-owner@vger.kernel.org [mailto:netdev-
> > owner@vger.kernel.org]
> > > > On Behalf Of Ben Hutchings
> > > > Sent: Thursday, April 21, 2011 7:36 AM
> > > > To: David Miller
> > > > Cc: netdev; sf-linux-drivers
> > > > Subject: rtnetlink and many VFs
> > > >
> > >
> > > As more VFs become possible it really needs a fix.  I was thinking
> > > about something along the lines of this:
> > >
> > > # ip link show eth(x) vf (n)
> > >
> > > Where eth(x) is the physical function that owns the VFs and (n) is the
> > > specific VF you want information for.  That way one could easily
> > > script something that loops through the VFs and gets the information
> > > for each.  This really becomes necessary when we start adding
> > > additional MAC and VLAN filters for each VF that need to be displayed.
> > > In that case you can only show a few VFs before you run out of space.
> > 
> > I think that what 'ip link show' is doing now seems to be perfectly
> > valid.  It allocates a 16K buffer which would be enough if netlink
> > didn't apply this PAGE_SIZE limit to single messages.
> 
> Ah, I hadn't seen that it was allocating 16K, that would then be
> enough for 128 VFs but in the future would not be enough for 40Gig (or
> higher speed) devices that might support two or 4 times that many VFs.

There are only 256 available function addresses per PCIe link, so there
can be at most 255 VFs associated with a single PF.

(The function number could be extended further by effectively assigning
multiple bus numbers to a link, but that would be a significantly more
disruptive change than ARI.)

> I still feel like eventually the number of VFs will outgrow the
> capability of a single message to handle, especially when VFs will
> have the capability of having multiple MAC address and VLAN filters
> assigned to them.  And it seems orthogonal to me to mirror the 'ip
> link set eth(x) vf (n)' syntax with a 'ip link show eth(x) vf (n)'
> syntax.
> 
> That's just me though.
[...]

I think it would be a useful extension, but we have to keep the current
API working as far as possible.

Ben.

-- 
Ben Hutchings, Senior Software Engineer, Solarflare
Not speaking for my employer; that's the marketing department's job.
They asked us to note that Solarflare product names are trademarked.

