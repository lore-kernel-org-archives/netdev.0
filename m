From: Thomas Graf <tgraf@suug.ch>
Subject: Re: [PATCH] NET: DCB generic netlink interface
Date: Wed, 11 Jun 2008 23:26:27 +0200
Message-ID: <20080611212627.GS20815@postel.suug.ch>
References: <20080605.074324.38999631.davem@davemloft.net> <D5C1322C3E673F459512FB59E0DDC3290538B840@orsmsx414.amr.corp.intel.com> <20080611175156.GR20815@postel.suug.ch> <D5C1322C3E673F459512FB59E0DDC329053C9888@orsmsx414.amr.corp.intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: David Miller <davem@davemloft.net>, jeff@garzik.org,
	netdev@vger.kernel.org
To: "Waskiewicz Jr, Peter P" <peter.p.waskiewicz.jr@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from postel.suug.ch ([194.88.212.233]:43865 "EHLO postel.suug.ch"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752078AbYFKV0J (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 11 Jun 2008 17:26:09 -0400
Content-Disposition: inline
In-Reply-To: <D5C1322C3E673F459512FB59E0DDC329053C9888@orsmsx414.amr.corp.intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

* Waskiewicz Jr, Peter P <peter.p.waskiewicz.jr@intel.com> 2008-06-11 11:28
> Congestion notification in 802.1Qau is certainly something we need to
> support somewhere in the stack.  I was actually talking with one of our
> hardware architects while I was in Israel last week about that exact
> gap, since the BCN/QCN rate limiting will eventually drop packets if we
> don't have a way of telling the upper layers to "slow down."

That's already possible by calling netif_stop_queue() respectively
netif_stop_subqueue(). Much more important for the upper layers to
know is when a congestion is about to happen so it can be avoided
with routing decisions.

> The prioritization is only one piece.  The bandwidth aggregation,
> different modes of defining group strict vs. link strict priorities
> within a bandwidth group, etc., are all hardware modes.  These modes
> need to be in sync with the link partner (switch, back to back NIC), and
> are kept in sync with the DCBX protocol via LLDP.

Again, this piece of hardware basically implements a classful qdisc
like htb or cbq except that it's limited to a flat tree. Yet, the
capabilities of the hardware may not be sufficient, therefore it must
be possible to combine hardware shaping with software qdiscs. It is
therefore crucial to find common grounds to exchange traffic class
information. Is your piece of hardware strictly limited to map VLANs
to traffic classes or would it be possible to attach traffic class
information to the packet in some way? (skb->tc_index) Could you
elaborate on how classification works, especially the configurable
mapping?

The most difficult part for me, an probably others as well, is that there
are no public documents available yet which would describe the direction
of where this is going, how complete the current implementation actually
is. We're pretty much looking at a black box which doesn't work very well
with the existing architecture and requires a completely separate
configuration interface. If we merge a configuration interface for DCB
now it will be pretty much written in stone, yet we have no idea what
other vendors may need.
