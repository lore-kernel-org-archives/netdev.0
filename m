From: "Waskiewicz Jr, Peter P" <peter.p.waskiewicz.jr@intel.com>
Subject: RE: [PATCH] NET: DCB generic netlink interface
Date: Wed, 11 Jun 2008 11:28:52 -0700
Message-ID: <D5C1322C3E673F459512FB59E0DDC329053C9888@orsmsx414.amr.corp.intel.com>
References: <20080605.074324.38999631.davem@davemloft.net> <D5C1322C3E673F459512FB59E0DDC3290538B840@orsmsx414.amr.corp.intel.com> <20080611175156.GR20815@postel.suug.ch>
Mime-Version: 1.0
Content-Type: text/plain;
	charset="us-ascii"
Content-Transfer-Encoding: 8BIT
Cc: "David Miller" <davem@davemloft.net>, <jeff@garzik.org>,
	<netdev@vger.kernel.org>
To: "Thomas Graf" <tgraf@suug.ch>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga01.intel.com ([192.55.52.88]:12380 "EHLO mga01.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751279AbYFKS2z convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 11 Jun 2008 14:28:55 -0400
Content-class: urn:content-classes:message
In-Reply-To: <20080611175156.GR20815@postel.suug.ch>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

> Everything is possible in software as long as the hardware doesn't
hide
> the congestion information. It would be very useful to pass congestion
> Information received by 802.1Qau frames to the kernel for use when
> selecting the nexthop or for the routing daemon to make decisions on.
> So far we could only react to link states, now we could actually react
to
> link congestion on the routing layer.

Congestion notification in 802.1Qau is certainly something we need to
support somewhere in the stack.  I was actually talking with one of our
hardware architects while I was in Israel last week about that exact
gap, since the BCN/QCN rate limiting will eventually drop packets if we
don't have a way of telling the upper layers to "slow down."  The
notification mechanism is also needed for 802.1Qbb, since the whole
point of the priority flow control is to provide a no-drop mechanism for
things like FCoE.  But if the upper layers (e.g. FCoE stack) don't know
to pause when the network is too congested, frames will be dropped,
which is bad.

802.1Qau is still being defined in IEEE unfortunately, and we and others
have no hardware that supports it to test the congestion notification
tag processing.  But it is something on our radar that needs to be
addressed.

> There is no doubt that doing the prioritization in hardware is much
> preferred but we should try and integrate it with other tc techniques.
> F.e. it would be great if we could control DCB via skb->tc_index if 
> that is possible. It would allow to define DCB traffic classes with
the
> rich features of existing classifiers. I've seen there is a mapping
> functionality although I haven't found any documentation on how to use
> it exactly.

The prioritization is only one piece.  The bandwidth aggregation,
different modes of defining group strict vs. link strict priorities
within a bandwidth group, etc., are all hardware modes.  These modes
need to be in sync with the link partner (switch, back to back NIC), and
are kept in sync with the DCBX protocol via LLDP.

> Another area of interest is sending congestion frames on our own. We
> could finally implement real ingress software shaping and turn every
> linux system into a DCB capable node.

Once 802.1Qau is defined, and IEEE decides to use BCN or QCN, I think
this is a great direction to go in.  Right now the congestion
notification stuff is too up in the air to latch onto unfortunately.

Thanks for the comments Thomas,

-PJ Waskiewicz
