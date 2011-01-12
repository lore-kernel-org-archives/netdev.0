From: "Brandeburg, Jesse" <jesse.brandeburg@intel.com>
Subject: RE: [E1000-devel] [e100] Page allocation failure warning(?) in
 2.6.36.3
Date: Wed, 12 Jan 2011 10:05:11 -0800 (Pacific Standard Time)
Message-ID: <alpine.WNT.2.00.1101120958080.5816@JBRANDEB-DESK2.amr.corp.intel.com>
References: <314995.84049.qm@web121708.mail.ne1.yahoo.com> <1294853710.3981.108.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: Chris Rankin <rankincj@yahoo.com>,
	"e1000-devel@lists.sourceforge.net"
	<e1000-devel@lists.sourceforge.net>,
	"Dave, Tushar N" <tushar.n.dave@intel.com>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"Kirsher, Jeffrey T" <jeffrey.t.kirsher@intel.com>
To: David Miller <davem@davemloft.net>,
	Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga11.intel.com ([192.55.52.93]:47808 "EHLO mga11.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753457Ab1ALSFM (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 12 Jan 2011 13:05:12 -0500
In-Reply-To: <1294853710.3981.108.camel@edumazet-laptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Eric, thanks for doing this work!

On Wed, 12 Jan 2011, Eric Dumazet wrote:
> Apparently e100 driver uses GFP_ATOMIC allocations in setup phase, and
> your machine doesnt have enough memory.

This part looks great.
 
> I would try following patch, allowing the use of GFP_KERNEL at init
> time, to let vm games play.
> 
> Thanks
> 
> [PATCH] e100: use GFP_KERNEL allocations at device init stage
> 
> In lowmem conditions, e100 driver can fail its initialization, because
> of GFP_ATOMIC abuse.
> 
> Switch to GFP_KERNEL were applicable.
> 
> Add __GFP_NOWARN flag to GFP_ATOMIC allocations, since driver can cope
> with failed allocations (if setup succeeded)
> 
> Reported-by: Chris Rankin <rankincj@yahoo.com>
> Signed-off-by: Eric Dumazet <eric.dumazet@gmail.com>
> CC: Jeff Kirsher <jeffrey.t.kirsher@intel.com>

Reviewed-by: Jesse Brandeburg <jesse.brandeburg@intel.com>

> -		if (unlikely(e100_rx_alloc_skb(nic, rx)))
> +		if (unlikely(e100_rx_alloc_skb(nic, rx,
> +					       GFP_ATOMIC | __GFP_NOWARN)))

First, I don't think the following comment should hold up this patch.

As a policy question when I asked about using __GFP_NOWARN before in other 
Intel ethernet drivers the consensus seemed to be that the warning 
messages were useful.  All our drivers correctly handle runtime memory 
failures, but none of them are currently using __GFP_NOWARN.

Can I submit patches to change our other drivers to __GFP_NOWARN?  I think 
it will make for quite a few less reports of non-issues to the list.  All 
our drivers that I would be patching already have ethtool counters that 
count failed allocations.

