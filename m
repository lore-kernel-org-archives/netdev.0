From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next 0/3] tcp: improving RACK cpu performance
Date: Thu, 05 Oct 2017 21:26:12 -0700 (PDT)
Message-ID: <20171005.212612.1580802624897584218.davem@davemloft.net>
References: <20171004200000.39257-1-ycheng@google.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: ycheng@google.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:57368 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1750757AbdJFE0N (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 6 Oct 2017 00:26:13 -0400
In-Reply-To: <20171004200000.39257-1-ycheng@google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Yuchung Cheng <ycheng@google.com>
Date: Wed,  4 Oct 2017 12:59:57 -0700

> This patch set improves the CPU consumption of the RACK TCP loss
> recovery algorithm, in particular for high-speed networks. Currently,
> for every ACK in recovery RACK can potentially iterate over all sent
> packets in the write queue. On large BDP networks with non-trivial
> losses the RACK write queue walk CPU usage becomes unreasonably high.
> 
> This patch introduces a new queue in TCP that keeps only skbs sent and
> not yet (s)acked or marked lost, in time order instead of sequence
> order.  With that, RACK can examine this time-sorted list and only
> check packets that were sent recently, within the reordering window,
> per ACK. This is the fastest way without any write queue walks. The
> number of skbs examined per ACK is reduced by orders of magnitude.

That's a pretty risky way to implement the second SKB list.... but
you avoided making sk_buff larger so what can I say :-)

Series applied, thank.
