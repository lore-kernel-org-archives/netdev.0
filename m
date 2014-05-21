From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net v2] ipv6: gro: fix CHECKSUM_COMPLETE support
Date: Wed, 21 May 2014 17:20:16 -0400 (EDT)
Message-ID: <20140521.172016.831231990758100731.davem@davemloft.net>
References: <1400548164.5367.80.camel@edumazet-glaptop2.roam.corp.google.com>
	<1400561794.5367.89.camel@edumazet-glaptop2.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: hkchu@google.com, netdev@vger.kernel.org, edumazet@google.com
To: eric.dumazet@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:56140 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752687AbaEUVUR (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 21 May 2014 17:20:17 -0400
In-Reply-To: <1400561794.5367.89.camel@edumazet-glaptop2.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <eric.dumazet@gmail.com>
Date: Mon, 19 May 2014 21:56:34 -0700

> From: Eric Dumazet <edumazet@google.com>
> 
> When GRE support was added in linux-3.14, CHECKSUM_COMPLETE handling
> broke on GRE+IPv6 because we did not update/use the appropriate csum :
> 
> GRO layer is supposed to use/update NAPI_GRO_CB(skb)->csum instead of
> skb->csum
> 
> Tested using a GRE tunnel and IPv6 traffic. GRO aggregation now happens
> at the first level (ethernet device) instead of being done in gre
> tunnel. Native IPv6+TCP is still properly aggregated.
> 
> Fixes: bf5a755f5e918 ("net-gre-gro: Add GRE support to the GRO stack")
> Signed-off-by: Eric Dumazet <edumazet@google.com>
> Cc: Jerry Chu <hkchu@google.com>
> ---
> v2: use nlen instead of sizeof(*iph) to support extension headers

Applied and queued up for -stable, thanks.
