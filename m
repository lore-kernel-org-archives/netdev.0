From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] neigh: replace unres_qlen by unres_qlen_bytes
Date: Wed, 09 Nov 2011 00:18:43 -0500 (EST)
Message-ID: <20111109.001843.1753987502002673227.davem@davemloft.net>
References: <1320792301.26025.21.camel@edumazet-laptop>
	<20111108.174820.558780148839093199.davem@davemloft.net>
	<1320797656.26025.43.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: eric.dumazet@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([198.137.202.13]:37500 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750927Ab1KIFSp (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 9 Nov 2011 00:18:45 -0500
In-Reply-To: <1320797656.26025.43.camel@edumazet-laptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <eric.dumazet@gmail.com>
Date: Wed, 09 Nov 2011 01:14:16 +0100

> unres_qlen is the number of frames we are able to queue per unresolved
> neighbour. Its default value (3) was never changed and is responsible
> for strange drops, especially if IP fragments are used, or multiple
> sessions start in parallel. TCP initial congestion window is now bigger
> than 3.

BTW, it has been observed in practice that if a long living connection
suddently sends a burst of traffic after a very long idle period
(hitting ARP expiry) or something invalidates the ARP entry in use, we
will drop frames.  Because even if the ARP reply comes "fast" it's
never quick enough to beat the burst of frames.

And if this happens in a scenerio where such lost packets potentially
mean lost money...
