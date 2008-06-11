From: Thomas Graf <tgraf@suug.ch>
Subject: Re: [PATCH] NET: DCB generic netlink interface
Date: Wed, 11 Jun 2008 19:51:56 +0200
Message-ID: <20080611175156.GR20815@postel.suug.ch>
References: <20080605.074324.38999631.davem@davemloft.net> <D5C1322C3E673F459512FB59E0DDC3290538B840@orsmsx414.amr.corp.intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: David Miller <davem@davemloft.net>, jeff@garzik.org,
	netdev@vger.kernel.org
To: "Waskiewicz Jr, Peter P" <peter.p.waskiewicz.jr@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from postel.suug.ch ([194.88.212.233]:38825 "EHLO postel.suug.ch"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755101AbYFKRvf (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 11 Jun 2008 13:51:35 -0400
Content-Disposition: inline
In-Reply-To: <D5C1322C3E673F459512FB59E0DDC3290538B840@orsmsx414.amr.corp.intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

* Waskiewicz Jr, Peter P <peter.p.waskiewicz.jr@intel.com> 2008-06-10 12:55
> I really don't think this is something that would work in software.  I
> agree that having a bandwidth grouping like 802.1Qaz would be somewhat
> useful, but that's the only piece of DCB that would work in software.
> And you can achieve the same behavior using sch_prio with cbq or htb on
> the nodes, minus the full link aggregation.
> 
> The 802.1Qbb, per-priority pause (flow control), cannot work in a
> software implementation.  This is a new flow control frame processed by
> the MAC for each priority on the link.  Also, the Rx filtering can't be
> emulated in software either.  The MAC filters on VLAN priority.  I know
> that can be configured with vconfig and set_ingress_map, but the whole
> point of the technology is to have the Rx processing done in the
> hardware's packet buffers, much like RSS filtering.

Everything is possible in software as long as the hardware doesn't hide
the congestion information. It would be very useful to pass congestion
information received by 802.1Qau frames to the kernel for use when
selecting the nexthop or for the routing daemon to make decisions on.
So far we could only react to link states, now we could actually react to
link congestion on the routing layer.

There is no doubt that doing the prioritization in hardware is much
preferred but we should try and integrate it with other tc techniques.
F.e. it would be great if we could control DCB via skb->tc_index if 
that is possible. It would allow to define DCB traffic classes with the
rich features of existing classifiers. I've seen there is a mapping
functionality although I haven't found any documentation on how to use
it exactly.

Another area of interest is sending congestion frames on our own. We
could finally implement real ingress software shaping and turn every
linux system into a DCB capable node.
