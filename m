From: Peter P Waskiewicz Jr <peter.p.waskiewicz.jr@intel.com>
Subject: Re: ixgbe patch to provide NIC's tx/rx counters via ethtool
Date: Thu, 24 Sep 2009 11:28:28 -0700
Message-ID: <1253816908.3153.4.camel@localhost.localdomain>
References: <4ABAA2D0.4030608@candelatech.com>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: NetDev <netdev@vger.kernel.org>
To: Ben Greear <greearb@candelatech.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga09.intel.com ([134.134.136.24]:44304 "EHLO mga09.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753011AbZIXS2V (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 24 Sep 2009 14:28:21 -0400
In-Reply-To: <4ABAA2D0.4030608@candelatech.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 2009-09-23 at 15:36 -0700, Ben Greear wrote:
> When LRO is enabled, the received packet and byte counters represent the
> LRO'd packets, not the packets/bytes on the wire.  The Intel 82599 NIC has
> registers that keep count of the physical packets.  Add these counters to
> the ethtool stats.  The byte counters are 36-bit, but the high 4 bits were
> being ignored in the 2.6.31 ixgbe driver:  Read those as well to allow
> longer time between polling the stats to detect wraps.
> 
> Signed-off-by: Ben Greear <greearb@candelatech.com>
> 
> 
> Please do not apply this until the ixgbe authors ACK it.  There may
> have been reasons for not reading the high 4 bits, or they may dislike
> this approach entirely.

Aside from the trivial line-wrap on the comments, I'm fine with this
patch.  There is no issue I could find with the hardware that would
limit you from reading the high 4 bits.  And since we're reading it
already to clear the register, we might as well use the value we get
from it.

Acked-by: Peter P Waskiewicz Jr <peter.p.waskiewicz.jr@intel.com>

