From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 2/2 net-next] net: attempt high order allocations in
 sock_alloc_send_pskb()
Date: Sat, 10 Aug 2013 01:17:20 -0700 (PDT)
Message-ID: <20130810.011720.981603328762637226.davem@davemloft.net>
References: <1375997927.4004.131.camel@edumazet-glaptop>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, rientjes@google.com
To: eric.dumazet@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:55966 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S968373Ab3HJIRV (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 10 Aug 2013 04:17:21 -0400
In-Reply-To: <1375997927.4004.131.camel@edumazet-glaptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <eric.dumazet@gmail.com>
Date: Thu, 08 Aug 2013 14:38:47 -0700

> From: Eric Dumazet <edumazet@google.com>
> 
> Adding paged frags skbs to af_unix sockets introduced a performance
> regression on large sends because of additional page allocations, even
> if each skb could carry at least 100% more payload than before.
> 
> We can instruct sock_alloc_send_pskb() to attempt high order
> allocations.
> 
> Most of the time, it does a single page allocation instead of 8.
> 
> I added an additional parameter to sock_alloc_send_pskb() to
> let other users to opt-in for this new feature on followup patches.
> 
> Tested:
> 
> Before patch :
> 
> $ netperf -t STREAM_STREAM 
> STREAM STREAM TEST
> Recv   Send    Send                          
> Socket Socket  Message  Elapsed              
> Size   Size    Size     Time     Throughput  
> bytes  bytes   bytes    secs.    10^6bits/sec  
> 
>  2304  212992  212992    10.00    46861.15   
> 
> After patch :
> 
> $ netperf -t STREAM_STREAM 
> STREAM STREAM TEST
> Recv   Send    Send                          
> Socket Socket  Message  Elapsed              
> Size   Size    Size     Time     Throughput  
> bytes  bytes   bytes    secs.    10^6bits/sec  
> 
>  2304  212992  212992    10.00    57981.11   
> 
> 
> Signed-off-by: Eric Dumazet <edumazet@google.com>

Great work, applied, thanks Eric.
