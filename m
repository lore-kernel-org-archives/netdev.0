From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] phylib: update mdiobus_alloc() to allocate extra
 private space
Date: Fri, 16 Dec 2011 15:31:37 -0500 (EST)
Message-ID: <20111216.153137.729586714371685980.davem@davemloft.net>
References: <1323967895-5205-1-git-send-email-timur@freescale.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: afleming@freescale.com, netdev@vger.kernel.org,
	linuxppc-dev@ozlabs.org
To: timur@freescale.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([198.137.202.13]:58399 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932590Ab1LPUcp (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 16 Dec 2011 15:32:45 -0500
In-Reply-To: <1323967895-5205-1-git-send-email-timur@freescale.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Timur Tabi <timur@freescale.com>
Date: Thu, 15 Dec 2011 10:51:35 -0600

> Augment mdiobus_alloc() to take a parameter indicating the number of extra
> bytes to allocate for private data.  Almost all callers of mdiobus_alloc()
> separately allocate a private data structure.  By allowing mdiobus_alloc()
> to allocate extra memory, the two allocations can be merged into one.
> 
> This patch does not change any of the callers to actually take advantage
> of this feature, however.  That change can be made by the individual
> maintainers at their leisure.  For now, all callers ask for zero additional
> bytes, which mimics the previous behavior.
> 
> Signed-off-by: Timur Tabi <timur@freescale.com>

Come on...

Not one driver even uses the new facility, and on top of it you edit
all of these drivers for no reason at all.

You could edit only two source files instead of more than 30 by simply
doing:

struct mii_bus *mdiobus_alloc_size(size_t size);

static inline struct mii_bus *mdiobus_alloc(void)
{
	return mdiobus_alloc_size(0):
}
