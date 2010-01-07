From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] mv643xx_eth: don't include cache padding in rx desc
 buffer size
Date: Thu, 07 Jan 2010 01:11:22 -0800 (PST)
Message-ID: <20100107.011122.67574781.davem@davemloft.net>
References: <20100105191532.GU1735@mail.wantstofly.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: buytenh@wantstofly.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:46504
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S932715Ab0AGJLP (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 7 Jan 2010 04:11:15 -0500
In-Reply-To: <20100105191532.GU1735@mail.wantstofly.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Lennert Buytenhek <buytenh@wantstofly.org>
Date: Tue, 5 Jan 2010 20:15:32 +0100

> From: Saeed Bishara <saeed@marvell.com>
> 
> If NET_SKB_PAD is not a multiple of the cache line size, mv643xx_eth 
> allocates a couple of extra bytes at the start of each receive buffer
> to make the data payload end up on a cache line boundary.
> 
> These extra bytes are skb_reserve()'d before DMA mapping, so they
> should not be included in the DMA map byte count (as the mapping is
> done starting at skb->data), nor should they be included in the
> receive descriptor buffer size field, or the hardware can end up
> DMAing beyond the end of the buffer, which can happen if someone
> sends us a larger-than-MTU sized packet.
> 
> This problem was introduced in commit 7fd96ce47ff ("mv643xx_eth:
> rework receive skb cache alignment", May 6 2009), but hasn't appeared
> to be problematic so far, probably as the main users of mv643xx_eth
> all have NET_SKB_PAD == L1_CACHE_BYTES.
> 
> Signed-off-by: Saeed Bishara <saeed@marvell.com>
> Signed-off-by: Lennert Buytenhek <buytenh@marvell.com>

Applied, thanks.
