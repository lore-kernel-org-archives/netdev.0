From: "Waskiewicz Jr, Peter P" <peter.p.waskiewicz.jr@intel.com>
Subject: RE: [PATCH] NET: DCB generic netlink interface
Date: Wed, 4 Jun 2008 23:23:00 -0700
Message-ID: <D5C1322C3E673F459512FB59E0DDC32905348FD4@orsmsx414.amr.corp.intel.com>
References: <20080527141339.12851.98781.stgit@localhost.localdomain> <20080604.114456.32717312.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain;
	charset="us-ascii"
Content-Transfer-Encoding: 8BIT
Cc: <jeff@garzik.org>, <netdev@vger.kernel.org>
To: "David Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga01.intel.com ([192.55.52.88]:43258 "EHLO mga01.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751850AbYFEGYD convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 5 Jun 2008 02:24:03 -0400
Content-class: urn:content-classes:message
In-Reply-To: <20080604.114456.32717312.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

> From: David Miller [mailto:davem@davemloft.net] 
> Sent: Wednesday, June 04, 2008 11:45 AM
> To: Waskiewicz Jr, Peter P
> Cc: jeff@garzik.org; netdev@vger.kernel.org
> Subject: Re: [PATCH] NET: DCB generic netlink interface


> Overall the changes look OK.  In particular the netlink 
> implementation looks clean.
> 
> However we need to think about how this stuff overlaps with 
> existing 'tc' facilities.  For example, what we really need 
> to do here is define this generic DCB interface such that it 
> normally just sits on top of a software scheduler layer 
> implementation and therefore there are always non-NULL DCB 
> ops to invoke.

I'm not sure I follow this.  DCB is a scheduling policy, but that
scheduling policy is in the hardware.  The configuration interface,
which is what this is, happens out of band of any scheduling policies in
the kernel.  It's very analogous to the wireless configuration layer for
mac80211 that uses generic netlink.

> If there is a device that can implement this in hardware, 
> that's fine and we define some interface for invoking that.
> 
> Because of that, the netdevice is likely not the correct 
> place for the ops (the only actual ugly part of the patches 
> in my opinion).

I agree that having this in the netdevice isn't great.  But given the
nature of how the hardware can be configured (via a user on the host, or
via messages from a switch to the userspace utilities), I think it needs
to be in there.  It's also the only common place the userspace can
enumerate an ethernet device from userspace; tc is another way, but the
ethernet device is used, along with the qdisc, which is part of the
netdevice.  But I am certainly all ears for any suggestions to not have
it in the netdevice if it can be done.

> I'm still very active travelling which is why I haven't 
> responded to this earlier.  I ask that you express some 
> understanding about this as there is really nothing I can do 
> to review these kinds of important changes properly when I am 
> changing 10 timezones every other day.

I can certainly sympathize; I've been travelling in Israel this past
week, and will be getting back to Portland on Friday.  Having a 10-hour
difference from what your normal timezone is is certainly challenging.

> Besides we're still in bug fix phase, so nothing I say will 
> get this upstream into Linus's tree any faster, and we really 
> need to get something like this right because it will be hard 
> to undo this afterwards if we get it wrong.

Totally understood.  My goal though is to make sure any
feedback/suggestions can be digested prior to the merge window, since
the chances of getting any good review during the merge window is next
to impossible, given the amount of patches flying in that have already
been queued.  I just want to make sure I'm prepared for a good
submission by the time the merge window opens.

Thanks Dave.  Any guidance from you, or anyone else, as to how I can get
this into better shape for acceptance, I'm all ears.

Cheers,
-PJ Waskiewicz
