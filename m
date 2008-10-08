From: Jarod Neuner <j.neuner@networkharbor.com>
Subject: Re: IGMP sent to Foreign VLAN
Date: Wed, 8 Oct 2008 18:34:56 -0500
Message-ID: <1223508896.24688.95.camel@deepthought.nh.local>
References: <1223322707.24688.46.camel@deepthought.nh.local>
	 <20081007.160702.189194318.davem@davemloft.net>
	 <48EBF677.1060602@trash.net>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: Patrick McHardy <kaber@trash.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from 75-150-216-245-Illinois.hfc.comcastbusiness.net ([75.150.216.245]:51473
	"EHLO mx.networkharbor.com" rhost-flags-OK-FAIL-OK-FAIL)
	by vger.kernel.org with ESMTP id S1754599AbYJHXe6 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 8 Oct 2008 19:34:58 -0400
In-Reply-To: <48EBF677.1060602@trash.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

> Patrick McHardy wrote:
> We've been talking about an IFF_ALLVLAN flag on netdev a while
> ago, which would disable VLAN hardware filters, similar to
> IFF_ALLMULTI. An additional flag on the ethernet device could
> indicate that it should receive unknown VLANs directly. That
> would introduce some possible inconsistencies however since the
> flag could be set without the VLAN code even loaded, in which
> case it would not have any effect.

My original thought was to do something like this in net/core/dev.c
using a method similar to handle_bridge or handle_macvlen.  So, if the
packet doesn't get handled by the ptype_base list and IFF_ALLVLAN is
set, then strip the header and let the packet through.  The sticky point
would be whether or not this policy should be enabled by default, as it
seems to be in other network stacks.

> 
> Another possibility would be to use a catch-all VLAN device with
> VID 0xfff (reserved for implementation use). This would allow
> to configure priority mappings, header reordering etc. and have
> separate statistics. The drivers could just use the magic VID
> as an indication to disable filtering, but I would still suggest
> to add the IFF_ALLVLAN flag because its useful on its own.

Most switches treat VLAN 1 as the "Default" or "Administration" VLAN.
It might make sense to map VLAN 1 to the incoming interface, and then
use that as a catch all.  Then again, that might be a terrible idea as
well. =)

> This can't be right though, the packet needs to be passed
> up the stack. The same change will also be needed in
> __vlan_hwaccel_rx().

Duly noted - thanks.

