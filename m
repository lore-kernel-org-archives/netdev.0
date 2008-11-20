From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 2/6] mv643xx_eth: introduce per-port register area
 pointer
Date: Thu, 20 Nov 2008 03:59:19 -0800 (PST)
Message-ID: <20081120.035919.07437424.davem@davemloft.net>
References: <20081118222859.GT5006@xi.wantstofly.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: buytenh@wantstofly.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:42745
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1755439AbYKTL7T (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 20 Nov 2008 06:59:19 -0500
In-Reply-To: <20081118222859.GT5006@xi.wantstofly.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Lennert Buytenhek <buytenh@wantstofly.org>
Date: Tue, 18 Nov 2008 23:29:01 +0100

> The mv643xx_eth driver uses the rdl()/wrl() macros to read and
> write hardware registers.  Per-port registers are accessed in the
> following way:
> 
> 	#define PORT_STATUS(p)			(0x0444 + ((p) << 10))
> 
> 	[...]
> 
> 	static inline u32 rdl(struct mv643xx_eth_private *mp, int offset)
> 	{
> 		return readl(mp->shared->base + offset);
> 	}
> 
> 	[...]
> 
> 	port_status = rdl(mp, PORT_STATUS(mp->port_num));
> 
> By giving the per-port 'struct mv643xx_eth_private' its own
> 'void __iomem *base' pointer that points to the per-port register
> area, we can get rid of both the double indirection and the << 10
> that is done for every per-port register access -- this patch does
> that.
> 
> Signed-off-by: Lennert Buytenhek <buytenh@marvell.com>

Applied.
