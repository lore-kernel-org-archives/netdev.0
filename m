From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next] net: relax expensive skb_unclone() in
 iptunnel_handle_offloads()
Date: Tue, 03 May 2016 00:23:27 -0400 (EDT)
Message-ID: <20160503.002327.1415458450222416618.davem@davemloft.net>
References: <1462036769.5535.180.camel@edumazet-glaptop3.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: eric.dumazet@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:39863 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750779AbcECEX3 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 3 May 2016 00:23:29 -0400
In-Reply-To: <1462036769.5535.180.camel@edumazet-glaptop3.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <eric.dumazet@gmail.com>
Date: Sat, 30 Apr 2016 10:19:29 -0700

> From: Eric Dumazet <edumazet@google.com>
> 
> Locally generated TCP GSO packets having to go through a GRE/SIT/IPIP
> tunnel have to go through an expensive skb_unclone()
> 
> Reallocating skb->head is a lot of work.
> 
> Test should really check if a 'real clone' of the packet was done.
> 
> TCP does not care if the original gso_type is changed while the packet
> travels in the stack.
> 
> This adds skb_header_unclone() which is a variant of skb_clone()
> using skb_header_cloned() check instead of skb_cloned().
> 
> This variant can probably be used from other points.
> 
> Signed-off-by: Eric Dumazet <edumazet@google.com>

Nice observation, applied, thanks Eric.
