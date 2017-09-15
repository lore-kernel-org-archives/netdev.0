From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net] tcp: update skb->skb_mstamp more carefully
Date: Fri, 15 Sep 2017 14:37:06 -0700 (PDT)
Message-ID: <20170915.143706.992734259378949259.davem@davemloft.net>
References: <3c750ac3-8739-89ed-ce41-d4cde755171e@huawei.com>
        <1505313647.15310.165.camel@edumazet-glaptop3.roam.corp.google.com>
        <1505359839.15310.209.camel@edumazet-glaptop3.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: liujian56@huawei.com, edumazet@google.com, ycheng@google.com,
        hkchu@google.com, netdev@vger.kernel.org, weiyongjun1@huawei.com,
        wangkefeng.wang@huawei.com
To: eric.dumazet@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:57528 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1750841AbdIOVhH (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 15 Sep 2017 17:37:07 -0400
In-Reply-To: <1505359839.15310.209.camel@edumazet-glaptop3.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <eric.dumazet@gmail.com>
Date: Wed, 13 Sep 2017 20:30:39 -0700

> From: Eric Dumazet <edumazet@googl.com>
> 
> liujian reported a problem in TCP_USER_TIMEOUT processing with a patch
> in tcp_probe_timer() :
>       https://www.spinics.net/lists/netdev/msg454496.html
> 
> After investigations, the root cause of the problem is that we update
> skb->skb_mstamp of skbs in write queue, even if the attempt to send a
> clone or copy of it failed. One reason being a routing problem.
> 
> This patch prevents this, solving liujian issue.
> 
> It also removes a potential RTT miscalculation, since
> __tcp_retransmit_skb() is not OR-ing TCP_SKB_CB(skb)->sacked with
> TCPCB_EVER_RETRANS if a failure happens, but skb->skb_mstamp has
> been changed.
> 
> A future ACK would then lead to a very small RTT sample and min_rtt
> would then be lowered to this too small value.
> 
> Tested:
...
> Signed-off-by: Eric Dumazet <edumazet@googl.com>
> Reported-by: liujian <liujian56@huawei.com>

Applied and queued up for -stable, thanks.
