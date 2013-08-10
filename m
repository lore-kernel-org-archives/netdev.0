From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 1/2 net-next] af_unix: improve STREAM behavior with
 fragmented memory
Date: Sat, 10 Aug 2013 01:16:56 -0700 (PDT)
Message-ID: <20130810.011656.2120932434328303202.davem@davemloft.net>
References: <1375997852.4004.130.camel@edumazet-glaptop>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: rientjes@google.com, netdev@vger.kernel.org
To: eric.dumazet@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:55960 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S968371Ab3HJIRA (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 10 Aug 2013 04:17:00 -0400
In-Reply-To: <1375997852.4004.130.camel@edumazet-glaptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <eric.dumazet@gmail.com>
Date: Thu, 08 Aug 2013 14:37:32 -0700

> From: Eric Dumazet <edumazet@google.com>
> 
> unix_stream_sendmsg() currently uses order-2 allocations,
> and we had numerous reports this can fail.
> 
> The __GFP_REPEAT flag present in sock_alloc_send_pskb() is
> not helping.
> 
> This patch extends the work done in commit eb6a24816b247c
> ("af_unix: reduce high order page allocations) for
> datagram sockets.
> 
> This opens the possibility of zero copy IO (splice() and
> friends)
> 
> The trick is to not use skb_pull() anymore in recvmsg() path,
> and instead add a @consumed field in UNIXCB() to track amount
> of already read payload in the skb.
> 
> There is a performance regression for large sends
> because of extra page allocations that will be addressed
> in a follow-up patch, allowing sock_alloc_send_pskb()
> to attempt high order page allocations.
> 
> Signed-off-by: Eric Dumazet <edumazet@google.com>

Applied.
