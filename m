From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next 00/17] tcp/dccp: lockless listener
Date: Sat, 03 Oct 2015 04:48:35 -0700 (PDT)
Message-ID: <20151003.044835.592539615085639060.davem@davemloft.net>
References: <1443811419-4798-1-git-send-email-edumazet@google.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, ycai@google.com, willemb@google.com,
	eric.dumazet@gmail.com
To: edumazet@google.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:55737 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752032AbbJCLdF (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 3 Oct 2015 07:33:05 -0400
In-Reply-To: <1443811419-4798-1-git-send-email-edumazet@google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <edumazet@google.com>
Date: Fri,  2 Oct 2015 11:43:22 -0700

> TCP listener refactoring : this is becoming interesting !
> 
> This patch series takes the steps to use normal TCP/DCCP ehash
> table to store SYN_RECV requests, instead of the private per-listener
> hash table we had until now.
> 
> SYNACK skb are now attached to their syn_recv request socket,
> so that we no longer heavily modify listener sk_wmem_alloc.
> 
> listener lock is no longer held in fast path, including
> SYNCOOKIE mode.
> 
> During my tests, my server was able to process 3,500,000
> SYN packets per second on one listener and still had available
> cpu cycles.
> 
> That is about 2 to 3 order of magnitude what we had with older kernels.
> 
> This effort started two years ago and I am pleased to reach expectations.
> 
> We'll probably extend SO_REUSEPORT to add proper cpu/numa affinities,
> so that heavy duty TCP servers can get proper siloing thanks to multi-queues
> NIC.

This looks amazing, series applied, thanks Eric!
