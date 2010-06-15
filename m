From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next-2.6] loopback: Implement 64bit stats on 32bit
 arches
Date: Mon, 14 Jun 2010 23:14:12 -0700 (PDT)
Message-ID: <20100614.231412.39191304.davem@davemloft.net>
References: <1276531162.2478.121.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, bhutchings@solarflare.com
To: eric.dumazet@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:35927
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1750874Ab0FOGOB (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 15 Jun 2010 02:14:01 -0400
In-Reply-To: <1276531162.2478.121.camel@edumazet-laptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <eric.dumazet@gmail.com>
Date: Mon, 14 Jun 2010 17:59:22 +0200

> Uses a seqcount_t to synchronize stat producer and consumer, for packets
> and bytes counter, now u64 types.
> 
> (dropped counter being rarely used, stay a native "unsigned long" type)
> 
> No noticeable performance impact on x86, as it only adds two increments
> per frame. It might be more expensive on arches where smp_wmb() is not
> free.
> 
> Signed-off-by: Eric Dumazet <eric.dumazet@gmail.com>

Applied, but I suspect we might end up eventually needing to
abstract this kind of technique in a common place so other
spots can use it.
