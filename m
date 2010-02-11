From: robert@herjulf.net
Subject: [net-next-2.6 PATCH v5 0/3] Introduce n-tuple ethtool support
Date: Thu, 11 Feb 2010 09:02:23 +0100
Message-ID: <19315.47503.661788.785038@gargle.gargle.HOWL>
References: <20100211020310.23436.85885.stgit@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net, netdev@vger.kernel.org, gospo@redhat.com
To: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from av6-1-sn3.vrr.skanova.net ([81.228.9.179]:48945 "EHLO
	av6-1-sn3.vrr.skanova.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751259Ab0BKJFX (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 11 Feb 2010 04:05:23 -0500
In-Reply-To: <20100211020310.23436.85885.stgit@localhost.localdomain>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>



Nice. Next step would be to control the RSS-traffic. Doing this we 
can easily get total separation between "control" and "data" plane.
We did a dirty hack to separate out bgp/ssh to one queue/cpu. 
I think just a RSS_mask would be a good start - each bit controlling 
if queue should receive RSS traffic or not.

Cheers
				--ro


Jeff Kirsher writes:
 > One more round of fixes, based on feedback from Patrick McHardy
 > 
 > 1) Change the list count to an unsigned value
 > 2) Fix a memory leak
 > 3) Removed an unnecessary list traversal in the ethtool core
 > 4) Moved all list destruction to a helper function, allowing the driver
 > to control when it clears the list (aside from when free_netdev() kills
 > the cached list).
 > 
 > ---
 > 
 > Peter Waskiewicz (3):
 >       ixgbe: Bump driver version up
 >       ixgbe: Add support for the new ethtool n-tuple programming interface
 >       ethtool: Introduce n-tuple filter programming support
 > 
 > 
 >  drivers/net/ixgbe/ixgbe.h         |    4 
 >  drivers/net/ixgbe/ixgbe_82599.c   |  106 ++++++++++--
 >  drivers/net/ixgbe/ixgbe_ethtool.c |  111 ++++++++++++
 >  drivers/net/ixgbe/ixgbe_main.c    |   18 ++
 >  drivers/net/ixgbe/ixgbe_type.h    |    9 +
 >  include/linux/ethtool.h           |   50 ++++++
 >  include/linux/netdevice.h         |    3 
 >  net/core/dev.c                    |    6 +
 >  net/core/ethtool.c                |  332 +++++++++++++++++++++++++++++++++++++
 >  9 files changed, 619 insertions(+), 20 deletions(-)
 > 
 > -- 
 > Cheers,
 > Jeff
 > --
 > To unsubscribe from this list: send the line "unsubscribe netdev" in
 > the body of a message to majordomo@vger.kernel.org
 > More majordomo info at  http://vger.kernel.org/majordomo-info.html
