From: Al Viro <viro@ZenIV.linux.org.uk>
Subject: Re: Re-queueing of skb in vlan_skb_recv
Date: Fri, 11 Apr 2008 13:53:13 +0100
Message-ID: <20080411125313.GI9785@ZenIV.linux.org.uk>
References: <8A9D56C5E50F774BABE033F1710B357601084C42@BBY1EXM11.pmc_nt.nt.pmc-sierra.bc.ca> <47FF5DAB.1060906@trash.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Brian Oostenbrink <Brian_Oostenbrink@pmc-sierra.com>,
	linux-net@vger.kernel.org,
	Linux Netdev List <netdev@vger.kernel.org>
To: Patrick McHardy <kaber@trash.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from zeniv.linux.org.uk ([195.92.253.2]:46853 "EHLO
	ZenIV.linux.org.uk" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757919AbYDKMxT (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 11 Apr 2008 08:53:19 -0400
Content-Disposition: inline
In-Reply-To: <47FF5DAB.1060906@trash.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, Apr 11, 2008 at 02:46:35PM +0200, Patrick McHardy wrote:
> Brian Oostenbrink wrote:
> >In vlan_skb_recv, packets are generally stripped of their vlan header,
> >and then re-queued via netif_rx().  Is there a reason for re-queuing
> >these instead of calling netif_receive_skb() directly?  On our system
> >(an embedded linux router), this re-queuing has a significant
> >performance penalty.
> 
> Its done to save stack space. There's currently a discussion
> about making loopback use netif_receive_skb in case enough
> stack is still available. Once that patch gets merged I'll
> change VLAN in a similar way.

Another possibility would be to allow ->func() of packet_type to return an
skb for reprocessing...
