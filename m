From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] netpoll: fix netpoll_send_udp() bugs
Date: Wed, 13 Jun 2012 15:58:02 -0700 (PDT)
Message-ID: <20120613.155802.1121407188815452311.davem@davemloft.net>
References: <1339565421.22704.310.camel@edumazet-glaptop>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, bogdan.hamciuc@freescale.com,
	herbert@gondor.apana.org.au, nhorman@tuxdriver.com
To: eric.dumazet@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:35684 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752648Ab2FMW6D (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 13 Jun 2012 18:58:03 -0400
In-Reply-To: <1339565421.22704.310.camel@edumazet-glaptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <eric.dumazet@gmail.com>
Date: Wed, 13 Jun 2012 07:30:21 +0200

> From: Eric Dumazet <edumazet@google.com>
> 
> Bogdan Hamciuc diagnosed and fixed following bug in netpoll_send_udp() :
> 
> "skb->len += len;" instead of "skb_put(skb, len);"
> 
> Meaning that _if_ a network driver needs to call skb_realloc_headroom(),
> only packet headers would be copied, leaving garbage in the payload.
> 
> However the skb_realloc_headroom() must be avoided as much as possible
> since it requires memory and netpoll tries hard to work even if memory
> is exhausted (using a pool of preallocated skbs)
> 
> It appears netpoll_send_udp() reserved 16 bytes for the ethernet header,
> which happens to work for typicall drivers but not all.
> 
> Right thing is to use LL_RESERVED_SPACE(dev)
> (And also add dev->needed_tailroom of tailroom)
> 
> This patch combines both fixes.
> 
> Many thanks to Bogdan for raising this issue.
> 
> Reported-by: Bogdan Hamciuc <bogdan.hamciuc@freescale.com>
> Signed-off-by: Eric Dumazet <edumazet@google.com>
> Tested-by: Bogdan Hamciuc <bogdan.hamciuc@freescale.com>

Applied and queued up for -stable, thanks Eric.
