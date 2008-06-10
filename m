From: "Waskiewicz Jr, Peter P" <peter.p.waskiewicz.jr@intel.com>
Subject: RE: [PATCH] NET: DCB generic netlink interface
Date: Tue, 10 Jun 2008 12:55:16 -0700
Message-ID: <D5C1322C3E673F459512FB59E0DDC3290538B840@orsmsx414.amr.corp.intel.com>
References: <20080527141339.12851.98781.stgit@localhost.localdomain><20080604.114456.32717312.davem@davemloft.net><D5C1322C3E673F459512FB59E0DDC32905348FD4@orsmsx414.amr.corp.intel.com> <20080605.074324.38999631.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain;
	charset="us-ascii"
Content-Transfer-Encoding: 8BIT
Cc: <jeff@garzik.org>, <netdev@vger.kernel.org>
To: "David Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga02.intel.com ([134.134.136.20]:32216 "EHLO mga02.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752917AbYFJTzN convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 10 Jun 2008 15:55:13 -0400
Content-class: urn:content-classes:message
In-Reply-To: <20080605.074324.38999631.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

> From: "Waskiewicz Jr, Peter P" <peter.p.waskiewicz.jr@intel.com>
> Date: Wed, 4 Jun 2008 23:23:00 -0700
> 
> > I'm not sure I follow this.  DCB is a scheduling policy, but that 
> > scheduling policy is in the hardware.  The configuration interface, 
> > which is what this is, happens out of band of any 
> scheduling policies 
> > in the kernel.  It's very analogous to the wireless configuration 
> > layer for
> > mac80211 that uses generic netlink.
> 
> And I'm saying we should have a equivalent software scheduler 
> in the kernel that can implement this if the hardware 
> offloaded version isn't present.

I really don't think this is something that would work in software.  I
agree that having a bandwidth grouping like 802.1Qaz would be somewhat
useful, but that's the only piece of DCB that would work in software.
And you can achieve the same behavior using sch_prio with cbq or htb on
the nodes, minus the full link aggregation.

The 802.1Qbb, per-priority pause (flow control), cannot work in a
software implementation.  This is a new flow control frame processed by
the MAC for each priority on the link.  Also, the Rx filtering can't be
emulated in software either.  The MAC filters on VLAN priority.  I know
that can be configured with vconfig and set_ingress_map, but the whole
point of the technology is to have the Rx processing done in the
hardware's packet buffers, much like RSS filtering.

This technology really is a hardware-based technology.  The piece that
we could effectively implement in software is the Tx priority grouping.
But that's a small piece of the whole technology.  All we're trying to
do is provide the method of configuring the hardware for this
technology, which is closely coupled with the FCoE work going on in the
SCSI world.  I don't think anyone would benefit trying to emulate it in
software, since everything we can implement in the software can already
be achieved using existing facilities.

> It overlaps existing functionality to a certain extent, and 
> there is no real reason for that overlap to exist.  The 
> question is which (the existing facilities or the new one) 
> subsumes which.

The existing facilities for traffic shaping and bandwidth aggregation do
overlap if you loaded those qdiscs with a DCB device.  But I don't think
the existing qdiscs should be removed or modified; the two technologies
are too different, in my opinion, to be combined in software.

Thanks Dave,
-PJ Waskiewicz
