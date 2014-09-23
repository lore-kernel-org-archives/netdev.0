From: David Miller <davem@davemloft.net>
Subject: Re: [PATCHv6 net-next 1/3] sunvnet: upgrade to VIO protocol
 version 1.6
Date: Tue, 23 Sep 2014 12:24:20 -0400 (EDT)
Message-ID: <20140923.122420.1216927815526255624.davem@davemloft.net>
References: <541A2316.5010603@oracle.com>
	<2AB76E42-C12D-47C5-8476-0D0C611691A5@oracle.com>
	<541AD838.50700@oracle.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: Raghuram.Kothakota@oracle.com, netdev@vger.kernel.org
To: david.stevens@oracle.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:35289 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751783AbaIWQYX (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 23 Sep 2014 12:24:23 -0400
In-Reply-To: <541AD838.50700@oracle.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: David L Stevens <david.stevens@oracle.com>
Date: Thu, 18 Sep 2014 09:03:52 -0400

> So, if this is actually too much memory, I was more inclined to reduce the ring
> size rather than either add complicating code to handle active-ring reallocation
> that would typically be run once per boot, or another alternative of adding
> module parameters to specify the buffer size TSO/GSO will need 64K to perform
> well, regardless of the device MTU.

The only reason we are having this discussion is because of how we
handle TX packets.

I think we really should directly map the SKBs in vnet_start_xmit()
instead of having these preallocate TX buffers.

The only thing to accomodate is the VNET_PACKET_SKIP, but that
shouldn't be hard at all.

And I am rather certain that an LDC map call will be cheaper than
copying the entire packet.

Then the MTU will have no material impact on per-vnet_port memory
costs, and bulk sending performance should also increase.

David I know you've worked hard on this patch set, but I'm going to
defer on this series for now.  There are several implementation level
issues that are still seemingly up in the air.

I'm almost completely sold on your PMTU scheme, however if we do
direct mapping of SKBs in vnet_start_xmit() then the performance
characteristics with larger MTUs might be different.

Thanks.
