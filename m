From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] ipv6: raw: fix icmpv6_filter()
Date: Tue, 25 Sep 2012 13:23:07 -0400 (EDT)
Message-ID: <20120925.132307.47817320861046816.davem@davemloft.net>
References: <1348592620.26828.3215.camel@edumazet-glaptop>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: eric.dumazet@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:35481 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757247Ab2IYRXJ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 25 Sep 2012 13:23:09 -0400
In-Reply-To: <1348592620.26828.3215.camel@edumazet-glaptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <eric.dumazet@gmail.com>
Date: Tue, 25 Sep 2012 19:03:40 +0200

> From: Eric Dumazet <edumazet@google.com>
> 
> icmpv6_filter() should not modify its input, or else its caller
> would need to recompute ipv6_hdr() if skb->head is reallocated.
> 
> Use skb_header_pointer() instead of pskb_may_pull() and
> change the prototype to make clear both sk and skb are const.
> 
> Also, if icmpv6 header cannot be found, do not deliver the packet,
> as we do in IPv4.
> 
> Signed-off-by: Eric Dumazet <edumazet@google.com>
> ---
> Note: another patch is needed in mip6_mh_filter()

A rather pervasive issues, it appears.

Applied and queued up for -stable, thanks Eric.
