From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next] tcp: tcp_transmit_skb() optimizations
Date: Fri, 11 Oct 2013 17:48:58 -0400 (EDT)
Message-ID: <20131011.174858.1461090000704613432.davem@davemloft.net>
References: <1381419780.4971.84.camel@edumazet-glaptop.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, fitz@cs.yale.edu, ycheng@google.com,
	ncardwell@google.com
To: eric.dumazet@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:56299 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755003Ab3JKVtA (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 11 Oct 2013 17:49:00 -0400
In-Reply-To: <1381419780.4971.84.camel@edumazet-glaptop.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <eric.dumazet@gmail.com>
Date: Thu, 10 Oct 2013 08:43:00 -0700

> From: Eric Dumazet <edumazet@google.com>
> 
> 1) We need to take a timestamp only for skb that should be cloned.
> 
> Other skbs are not in write queue and no rtt estimation is done on them.
> 
> 2) the unlikely() hint is wrong for receivers (they send pure ACK)
> 
> Signed-off-by: Eric Dumazet <edumazet@google.com>

This patch is correct, so I've applied it, but it points out a bug.

The __tcp_retransmit_skb() code that does a __pskb_copy() to handle
NET_IP_ALIGN violations and skb_headroom() overflows is buggy because
it needs to store a congestion control timestamp in the original 'skb'
since that's what we'll look at in the retransmit queue.
