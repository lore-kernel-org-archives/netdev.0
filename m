From: David Miller <davem@davemloft.net>
Subject: Re: Re-queueing of skb in vlan_skb_recv
Date: Fri, 11 Apr 2008 10:54:13 -0700 (PDT)
Message-ID: <20080411.105413.34923074.davem@davemloft.net>
References: <47FF5DAB.1060906@trash.net>
	<20080411125313.GI9785@ZenIV.linux.org.uk>
	<47FF614E.7040500@trash.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: viro@ZenIV.linux.org.uk, Brian_Oostenbrink@pmc-sierra.com,
	linux-net@vger.kernel.org, netdev@vger.kernel.org
To: kaber@trash.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:33004
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1760355AbYDKRyM (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 11 Apr 2008 13:54:12 -0400
In-Reply-To: <47FF614E.7040500@trash.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Patrick McHardy <kaber@trash.net>
Date: Fri, 11 Apr 2008 15:02:06 +0200

> Al Viro wrote:
> > On Fri, Apr 11, 2008 at 02:46:35PM +0200, Patrick McHardy wrote:
> >> Brian Oostenbrink wrote:
> >>> In vlan_skb_recv, packets are generally stripped of their vlan header,
> >>> and then re-queued via netif_rx().  Is there a reason for re-queuing
> >>> these instead of calling netif_receive_skb() directly?  On our system
> >>> (an embedded linux router), this re-queuing has a significant
> >>> performance penalty.
> >> Its done to save stack space. There's currently a discussion
> >> about making loopback use netif_receive_skb in case enough
> >> stack is still available. Once that patch gets merged I'll
> >> change VLAN in a similar way.
> > 
> > Another possibility would be to allow ->func() of packet_type to return an
> > skb for reprocessing...
> 
> That should work fine for VLAN, but not for loopback since its
> called on the TX path. I think I prefer Eric's suggested way
> because it doesn't require to change all the other existing
> packet_type users.

I think Al's idea is the most elegant proposed so far and we could do
something similar on the TX side as well.

Yes, it means diddling with a lot of call sites, but we do that all
the time and it's heaps better then these "check the stack space
remaining" hacks being proposed.
